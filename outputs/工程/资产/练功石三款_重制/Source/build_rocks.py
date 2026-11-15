"""Image-led remake: hewn convex masses, interlocked silhouette, inlaid strata.
Run one variant per Blender process: -- A (or B, C). No radial ring construction.
"""
import bpy,bmesh,math,random,json,sys,itertools
from pathlib import Path
from mathutils import Vector,Euler
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
import rock_pipeline as pipe
ROOT=Path(__file__).resolve().parents[1];pipe.ROOT=ROOT
PROFILES={
 'A':{'name':'PracticeRock_A_Classic','kind':'gold_spiral','seed':32,'base':'756F86','light':'A9A2B5','dark':'484454','mark':'FFD146','mark_shadow':'C8902E'},
 'B':{'name':'PracticeRock_B_Rune','kind':'diamond','seed':54,'base':'119DDD','light':'76DDF5','dark':'086799','mark':'B6FAFF','mark_shadow':'37CADA'},
 'C':{'name':'PracticeRock_C_Layered','kind':'spiral','seed':86,'base':'8F55D1','light':'C391ED','dark':'59338A','mark':'E9B9FF','mark_shadow':'B876E4'},
}
REFERENCE_MARKS=json.loads((ROOT/'Source/reference_symbols.json').read_text(encoding='utf-8'))

def active(o):
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o

def convex_stone(name,center,size,seed,rotation=(0,0,0),taper=.17):
    """Intersect broad hand-placed cut planes, preserving planar rock facets."""
    rng=random.Random(seed);planes=[]
    # Front receives the biggest clean striking face; back is equally solid.
    for axis in range(3):
        for sign in (-1,1):
            n=np.zeros(3);n[axis]=sign
            if axis<2:n[2]=taper+rng.uniform(-.055,.055)
            elif sign>0:n[0]=rng.uniform(-.12,.12);n[1]=rng.uniform(-.10,.10)
            planes.append((n,1.0))
    # Differently sized chipped corners; no regular hexagonal tessellation.
    for a,b in ((0,1),(0,2),(1,2)):
        for sa,sb in itertools.product((-1,1),repeat=2):
            n=np.zeros(3);n[a]=sa;n[b]=sb*rng.uniform(.82,1.16)
            planes.append((n,rng.uniform(1.28,1.56)))
    for normal,distance in [((1,-.24,.16),1.02),((-1,.19,-.18),1.04),((.20,-1,.30),1.12)]:
        planes.append((np.array(normal),distance+rng.uniform(-.045,.045)))
    for signs in [(-1,-1,1),(1,-1,1),(-1,1,1),(1,1,-1)]:
        planes.append((np.array(signs,dtype=float),rng.uniform(1.85,2.13)))
    pts=[]
    normals=np.array([p[0]for p in planes]);dist=np.array([p[1]for p in planes])
    for combo in itertools.combinations(range(len(planes)),3):
        matrix=normals[list(combo)]
        if abs(np.linalg.det(matrix))<1e-7:continue
        p=np.linalg.solve(matrix,dist[list(combo)])
        if np.all(normals@p<=dist+1e-6) and not any(np.linalg.norm(p-q)<1e-5 for q in pts):pts.append(p)
    rot=Euler(rotation).to_matrix();verts=[]
    for p in pts:verts.append(rot@Vector((p[0]*size[0]/2,p[1]*size[1]/2,p[2]*size[2]/2))+Vector(center))
    bm=bmesh.new()
    for p in verts:bm.verts.new(p)
    bmesh.ops.convex_hull(bm,input=list(bm.verts),use_existing_faces=False)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bmesh.ops.dissolve_limit(bm,angle_limit=math.radians(1),verts=list(bm.verts),edges=list(bm.edges),delimit=set())
    mesh=bpy.data.meshes.new(name+'_Geo');bm.to_mesh(mesh);bm.free()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    for m in LABEL_MATS:o.data.materials.append(m)
    return o

def boolean(target,cutter,operation='UNION'):
    active(target);mod=target.modifiers.new(operation+' hand-cut volume','BOOLEAN');mod.operation=operation;mod.solver='EXACT';mod.object=cutter
    bpy.ops.object.modifier_apply(modifier=mod.name);bpy.data.objects.remove(cutter,do_unlink=True)

def clipped_copy(source,name,normal,z,keep_above):
    mesh=source.data.copy();o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    bm=bmesh.new();bm.from_mesh(mesh)
    cut=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,plane_co=(0,0,z),plane_no=normal,clear_inner=keep_above,clear_outer=not keep_above)
    edges=[e for e in bm.edges if e.is_boundary]
    if edges:bmesh.ops.holes_fill(bm,edges=edges,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free();return o

def inlaid_seam(source,z,slope,width=.17,shrink=.945,wave=.0):
    """A connected inset stone vein inside an actual oblique crevice."""
    def warp(x,y):return wave*(math.sin(x*.65+.6)+.035*y*y)
    for v in source.data.vertices:v.co.z-=warp(v.co.x,v.co.y)
    source.data.update()
    n=Vector((-slope,-.035,1)).normalized()
    low=clipped_copy(source,'Lower joined rock',n,z-width/2,False)
    high=clipped_copy(source,'Upper joined rock',n,z+width/2,True)
    belt=clipped_copy(source,'Inset mineral-free strata',n,z-width/2-.01,True)
    cut=clipped_copy(belt,'Belt clipped top',n,z+width/2+.01,False)
    bpy.data.objects.remove(belt,do_unlink=True);belt=cut
    for v in belt.data.vertices:v.co.x*=shrink;v.co.y*=shrink
    for f in belt.data.polygons:f.material_index=1
    bpy.data.objects.remove(source,do_unlink=True)
    boolean(low,belt);boolean(low,high)
    for v in low.data.vertices:v.co.z+=warp(v.co.x,v.co.y)
    return low

def clean_and_scale(o,name):
    active(o);bm=bmesh.new();bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001)
    bmesh.ops.dissolve_limit(bm,angle_limit=math.radians(1),verts=list(bm.verts),edges=list(bm.edges),delimit={'MATERIAL'})
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
    # Keep hand-cut corners; a very narrow bevel produces readable chipped rims.
    bevel=o.modifiers.new('Narrow worn stone corners','BEVEL');bevel.width=.065;bevel.segments=1;bevel.limit_method='ANGLE';bevel.angle_limit=math.radians(25)
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    tri=o.modifiers.new('Explicit triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
    if len(o.data.polygons)>950:
        dec=o.modifiers.new('Runtime silhouette budget','DECIMATE');dec.ratio=940/len(o.data.polygons);dec.use_collapse_triangulate=True;bpy.ops.object.modifier_apply(modifier=dec.name)
    # Deform the final closed triangles, never a non-planar Boolean operand.
    # This preserves all three solid strata while bending their seam silhouettes.
    if name.endswith('Layered'):
        for v in o.data.vertices:v.co.z+=.34*math.sin(v.co.x*.65+.6)*min(1,max(0,v.co.z/.7))
    lo=Vector([min(v.co[i]for v in o.data.vertices)for i in range(3)]);hi=Vector([max(v.co[i]for v in o.data.vertices)for i in range(3)])
    dim=hi-lo;center=(lo+hi)/2
    for v in o.data.vertices:v.co=Vector(((v.co.x-center.x)*8/dim.x,(v.co.y-center.y)*6.5/dim.y,(v.co.z-lo.z)*6.5/dim.z))
    o.data.update();bpy.context.view_layer.update();o.name=name;o.data.name=name+'_Geometry'
    for f in o.data.polygons:f.use_smooth=False
    o['AssetVersion']=3 if name!='PracticeRock_B_Rune'else 2;o['ModelingMethod']='Intersected cut-plane masses, joined stone and oblique inset seams';o['TargetSizeStuds']=[8.,6.5,6.5]
    assert len(o.data.polygons)<=1000,len(o.data.polygons)
    return o

def build(code,p):
    if code=='A':
        shapes=[((-.12,.12,3.12),(5.9,5.8,6.30),(0,0,-.035),.22),
                ((-2.62,.25,2.0),(2.7,4.8,3.95),(0,.06,-.12),.05),
                ((-2.42,-.05,4.38),(2.50,4.6,3.3),(.02,-.18,.11),.19),
                ((2.45,.45,1.32),(2.60,4.25,2.68),(0,-.08,.10),.08),
                ((2.40,.55,3.65),(2.12,3.9,2.90),(.03,.19,-.14),.20),
                ((-2.55,-1.76,.48),(1.75,1.90,1.12),(.04,-.08,.14),.02),
                ((1.77,1.70,3.15),(2.70,2.90,4.9),(.05,.10,.08),.14)]
    elif code=='B':
        shapes=[((-.12,.05,3.15),(6.55,5.8,6.3),(0,-.035,.04),.24),
                ((-2.60,.12,1.65),(2.65,4.5,3.35),(.03,-.08,-.12),.02),
                ((2.63,.30,1.20),(2.70,4.75,2.45),(.03,.12,.04),.13),
                ((2.30,.40,3.68),(2.50,4.60,3.15),(-.04,.10,-.09),.22),
                ((-.48,.48,5.72),(4.75,4.6,1.40),(.02,-.04,-.11),.17)]
    else:
        shapes=[((.0,.08,2.90),(7.25,5.9,5.75),(0,-.10,-.045),.36),
                ((-.50,.18,5.15),(4.65,4.75,2.42),(.03,-.03,.12),.24),
                ((2.45,.15,1.05),(2.85,4.60,2.15),(0,.06,-.07),.08),
                ((-2.35,.35,2.10),(2.70,4.55,3.40),(.03,-.09,.12),.15)]
    chunks=[convex_stone('Chiseled stone mass '+str(i),pos,size,p['seed']+i*17,rot,taper)for i,(pos,size,rot,taper)in enumerate(shapes)]
    result=chunks[0]
    for o in chunks[1:]:boolean(result,o)
    # Actual removal of a few exposed corners rather than a painted triangular patch.
    for i,(pos,size) in enumerate([((-1.75,-2.72,5.35),(.72,.52,.54)),((2.64,-2.25,2.96),(.48,.55,.60))]):
        cutter=convex_stone('Strike-chip negative',pos,size,p['seed']+100+i,(.1,.25,-.14),0)
        boolean(result,cutter,'DIFFERENCE')
    if code=='B':result=inlaid_seam(result,2.22,.20,width=.28,shrink=.967)
    if code=='C':
        result=inlaid_seam(result,2.00,.22,width=.11,shrink=.982)
        result=inlaid_seam(result,4.91,.11,width=.085,shrink=.985)
    return clean_and_scale(result,p['name'])

def paint(p,points,normal,shade,material_index=0):
    x,y,z=points[...,0],points[...,1],points[...,2]
    base,light,dark=map(pipe.rgb,[p['base'],p['light'],p['dark']]);mark,shadow=map(pipe.rgb,[p['mark'],p['mark_shadow']])
    shade=.62 if normal.z>.65 else .20 if normal.z>.20 else -.20 if normal.z<-.35 else 0
    tone=base*(1-shade)+light*shade if shade>=0 else base*(1+shade)+dark*(-shade)
    if material_index==1:tone=(mark*.92+light*.08)if p['kind']=='diamond' else dark*.35+base*.65
    colors=np.broadcast_to(tone,points.shape).copy()
    front=(y<-.9)&(normal.y<-.25)
    if p['kind']=='gold_spiral':
        path=[(.67,4.99),(.00,5.54),(-.91,4.66),(-1.26,3.81),(-.61,2.89),(.38,2.79),(1.08,3.51),(.97,4.36),(.26,4.77),(-.39,4.32),(-.48,3.68),(.06,3.34),(.48,3.70),(.43,4.10),(.12,4.24)]
        path=[(a*.80,b*.80+.72)for a,b in path]
        d=pipe.line_distance(x,z,path);colors[front&(d<.137)]=shadow;colors[front&(d<.102)]=mark
        cracks=[[(-2.2,4.9),(-1.95,4.57),(-2.09,4.1)],[(2.23,3.34),(1.89,3.55),(1.66,3.32)], [(-1.75,1.1),(-1.60,1.58),(-1.82,1.92)]]
    elif p['kind']=='diamond':
        d=np.abs(x+.12)+np.abs(z-4.05)
        colors[front&((np.abs(d-.97)<.137)|(d<.29))]=shadow
        colors[front&((np.abs(d-.97)<.097)|(d<.245))]=mark
        cracks=[[(-1.62,5.93),(-1.75,5.55),(-1.40,5.28)],[(2.15,4.84),(1.87,4.58),(2.02,4.28)], [(-2.43,2.16),(-2.22,2.49),(-2.38,2.91)]]
    else:
        path=[]
        for t in np.linspace(0,math.pi*3.1,100):
            radius=.78*(1-t/(math.pi*3.1))+.06
            path.append((-.18+radius*math.cos(t+.3),3.61+radius*math.sin(t+.3)))
        d=pipe.line_distance(x,z,path);colors[front&(d<.131)]=shadow;colors[front&(d<.088)]=mark
        cracks=[[(-2.5,3.4),(-2.23,3.66),(-2.30,3.96)],[(2.10,1.55),(1.84,1.82),(1.92,2.09)]]
    for path in cracks:
        d=pipe.line_distance(x,z,path);colors[front&(d<.012)]=dark*.55+base*.45
    # Match the supplied emblem silhouette, including its detached center mark.
    # Sample only a binary symbol mask; no reference lighting/background is pasted.
    key='A'if p['kind']=='gold_spiral'else'B'if p['kind']=='diamond'else'C'
    entry=REFERENCE_MARKS[key];mask=np.array(entry['rows'])
    width,cx,cz={'A':(2.28,0,4.05),'B':(2.04,-.12,4.05),'C':(1.92,-.12,3.66)}[key]
    height=width*entry['height']/entry['width']
    u=(x-cx)/width+.5;v=(cz-z)/height+.5
    # Reset the old procedural sign region, then use the actual traced silhouette.
    sign_region=front&(np.abs(x-cx)<1.8)&(np.abs(z-cz)<1.5)
    colors[sign_region]=tone
    ix=np.clip(u*(entry['width']-1),0,entry['width']-1.001);iy=np.clip(v*(entry['height']-1),0,entry['height']-1.001)
    x0=np.floor(ix).astype(int);y0=np.floor(iy).astype(int);tx=ix-x0;ty=iy-y0
    alpha=mask[y0,x0]*(1-tx)*(1-ty)+mask[y0,x0+1]*tx*(1-ty)+mask[y0+1,x0]*(1-tx)*ty+mask[y0+1,x0+1]*tx*ty
    apply=front&(u>=0)&(u<=1)&(v>=0)&(v<=1)
    colors[apply]=colors[apply]*(1-alpha[apply,None])+mark*alpha[apply,None]
    return np.clip(colors,0,1)

pipe.paint=paint
code=sys.argv[sys.argv.index('--')+1] if '--'in sys.argv else 'A';p=PROFILES[code]
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
LABEL_MATS=[bpy.data.materials.new('Stone color label'),bpy.data.materials.new('Inset seam color label')]
o=build(code,p);geometry=pipe.inspect(o)
bm=bmesh.new();bm.from_mesh(o.data);unseen=set(bm.verts);components=0
while unseen:
    components+=1;todo=[unseen.pop()]
    while todo:
        v=todo.pop()
        for e in v.link_edges:
            w=e.other_vert(v)
            if w in unseen:unseen.remove(w);todo.append(w)
bm.free();assert components==1,components;geometry['connected_components']=components
print('GEOMETRY_READY',code,json.dumps(geometry),flush=True)
tex=pipe.atlas(p,o);active(o)
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports'/(p['name']+'.fbx')),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
bpy.ops.export_scene.gltf(filepath=str(ROOT/'Exports'/(p['name']+'.glb')),export_format='GLB',use_selection=True,export_apply=True)
(ROOT/'Exports'/tex.name).write_bytes(tex.read_bytes())
camera,preview=pipe.setup_preview(bpy.context.scene);scene=bpy.context.scene
scene.cycles.samples=24;scene.render.resolution_x=1100;scene.render.resolution_y=1000
camera.data.ortho_scale=11.8;camera.location=(6,-16,9);camera.rotation_euler=(Vector((0,0,3.1))-camera.location).to_track_quat('-Z','Y').to_euler()
active(o)
for area in bpy.context.screen.areas if bpy.context.screen else []:
    if area.type=='VIEW_3D':area.spaces.active.region_3d.view_perspective='CAMERA';area.spaces.active.shading.type='MATERIAL'
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'Source'/(p['name']+'.blend')))
views=[('Hero',(6,-16,9)),('Front',(0,-18,3.25)),('Right',(18,0,3.25)),('Back',(0,18,3.25)),('Top',(0,-.001,20))]
if '--hero-only'in sys.argv:views=views[:1]
for label,position in views:
    camera.location=position;camera.rotation_euler=(Vector((0,0,3.25))-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(ROOT/'Renders'/(p['name']+'_'+label+'.png'));bpy.ops.render.render(write_still=True)
geometry['mesh_objects']=1;geometry['materials']=1;geometry['uv_layers']=len(o.data.uv_layers);geometry['texture_size']=[2048,2048]
(ROOT/(p['name']+'_manifest.json')).write_text(json.dumps(geometry,indent=2),encoding='utf-8')
(ROOT/'Source'/'variant_profiles.json').write_text(json.dumps(PROFILES,indent=2),encoding='utf-8')
print('VARIANT_COMPLETE',code,json.dumps(geometry),flush=True)
