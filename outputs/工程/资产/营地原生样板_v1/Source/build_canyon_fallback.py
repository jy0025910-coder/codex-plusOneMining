"""Local Blender fallback for the wall only; original native paving/stall stay editable."""
import bpy, bmesh, math, random, itertools, json, struct, zlib
from pathlib import Path
from mathutils import Vector, Euler
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
for n in ('Exports','Textures','Renders'):(ROOT/n).mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def active(o):
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
def convex(name,center,size,seed,rotation=(0,0,0)):
    rng=random.Random(seed);planes=[]
    for axis in range(3):
        for sign in (-1,1):
            n=np.zeros(3);n[axis]=sign
            if axis<2:n[2]=rng.uniform(.02,.16)
            elif sign>0:n[0]=rng.uniform(-.13,.13);n[1]=rng.uniform(-.08,.08)
            planes.append((n,1.0))
    for a,b in ((0,1),(0,2),(1,2)):
        for sa,sb in itertools.product((-1,1),repeat=2):
            if b==2 and sb==-1:continue # cliffs sit on broad flat bases, no undercut boulder feet
            n=np.zeros(3);n[a]=sa;n[b]=sb*rng.uniform(.8,1.2)
            planes.append((n,rng.uniform(1.35,1.62)))
    planes += [(np.array((1,-.25,.18)),1.08),(np.array((-.9,-.3,.12)),1.03)]
    normals=np.array([p[0]for p in planes]);dist=np.array([p[1]for p in planes]);pts=[]
    for ids in itertools.combinations(range(len(planes)),3):
        matrix=normals[list(ids)]
        if abs(np.linalg.det(matrix))<1e-7:continue
        p=np.linalg.solve(matrix,dist[list(ids)])
        if np.all(normals@p<=dist+1e-6)and not any(np.linalg.norm(p-q)<1e-5 for q in pts):pts.append(p)
    rot=Euler(rotation).to_matrix();bm=bmesh.new()
    for p in pts:bm.verts.new(rot@Vector(tuple(p*np.array(size)/2))+Vector(center))
    bmesh.ops.convex_hull(bm,input=list(bm.verts),use_existing_faces=False)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bmesh.ops.dissolve_limit(bm,angle_limit=.01,verts=list(bm.verts),edges=list(bm.edges),delimit=set())
    mesh=bpy.data.meshes.new(name);bm.to_mesh(mesh);bm.free()
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);return o
def combine(a,b):
    active(a);m=a.modifiers.new('Join overlapping cliff mass','BOOLEAN');m.operation='UNION';m.solver='EXACT';m.object=b
    bpy.ops.object.modifier_apply(modifier=m.name);bpy.data.objects.remove(b,do_unlink=True)
def strata(o,heights):
    # Fine shallow creases with a gently sloped continuous height field.
    def wave(x,y):return .40*math.sin(x*.23+.3)+.022*x+.10*math.sin(y*.30)
    for v in o.data.vertices:v.co.z-=wave(v.co.x,v.co.y)
    bm=bmesh.new();bm.from_mesh(o.data)
    for h in heights:
        for dh in (-.55,-.13,0,.13,.55):
            bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-5,plane_co=(0,0,h+dh),plane_no=(0,0,1))
    for v in bm.verts:
        d=min(abs(v.co.z-h)for h in heights)
        amount=max(0,1-d/.55)*.012
        v.co.x*=1-amount;v.co.y*=1-amount
        v.co.z+=wave(v.co.x,v.co.y)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
def png(path,a):
    def chunk(t,d):return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    h,w,_=a.shape;scan=b''.join(b'\0'+a[r].tobytes()for r in range(h))
    path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(scan,6))+chunk(b'IEND',b''))
def paint(points,n):
    x,y,z=points[...,0],points[...,1],points[...,2]
    base=np.array((204.,109.,61.))
    tone=1+(.045 if n.z>.45 else -.02 if n.z<-.4 else .0)
    noise=1.8*np.sin(x*.58+z*.4)*np.cos(y*.42-z*.2)+.8*np.sin(x*3.1+z*2.3)
    colors=np.broadcast_to(base*tone,points.shape).copy()+noise[...,None]
    phase=z-.40*np.sin(x*.23+.3)-.022*x-.1*np.sin(y*.3)
    # A continuous painted geology rhythm, no masonry cells or photo noise.
    bands=.025*np.sin(phase*.63)+.012*np.sin(phase*1.52+.7)
    colors*=1+bands[...,None]
    for h in (6.5,14.5,23,31.5):
        d=abs(phase-h)
        colors*=1-(.12*np.exp(-(d/.085)**2))[...,None]
        colors+=np.exp(-((d-.18)/.13)**2)[...,None]*np.array((3.5,2.8,1.8))
    return np.clip(colors,0,255)
def texture(o):
    active(o);bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(angle_limit=1.0,island_margin=.012);bpy.ops.object.mode_set(mode='OBJECT')
    size=1024;a=np.zeros((size,size,3),dtype=np.uint8);a[:]=(204,109,61)
    uv=o.data.uv_layers.active
    for face in o.data.polygons:
        coords=np.array([(uv.data[i].uv.x*size,(1-uv.data[i].uv.y)*size)for i in face.loop_indices])
        lo=np.maximum(0,np.floor(coords.min(axis=0)-3).astype(int));hi=np.minimum(size,np.ceil(coords.max(axis=0)+3).astype(int))
        px,py=lo;hx,hy=hi
        if hx<=px or hy<=py:continue
        verts=np.array([o.data.vertices[i].co[:]for i in face.vertices]);matrix=np.stack((coords[1]-coords[0],coords[2]-coords[0]),axis=1)
        if abs(np.linalg.det(matrix))<1e-8:continue
        yy,xx=np.mgrid[py:hy,px:hx];ab=(np.stack((xx+.5,yy+.5),axis=-1)-coords[0])@np.linalg.inv(matrix).T
        u,v=ab[...,0],ab[...,1];tol=2/max(1,min(np.linalg.norm(matrix[:,0]),np.linalg.norm(matrix[:,1])))
        inside=(u>=-tol)&(v>=-tol)&(u+v<=1+tol)
        pts=verts[0]+u[...,None]*(verts[1]-verts[0])+v[...,None]*(verts[2]-verts[0])
        a[py:hy,px:hx][inside]=np.round(paint(pts,face.normal)[inside]).astype(np.uint8)
    path=ROOT/'Textures'/(o.name+'_BaseColor.png');png(path,a)
    mat=bpy.data.materials.new(o.name+'_MatteSandstone');mat.use_nodes=True
    bs=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Roughness'].default_value=.94;bs.inputs['Metallic'].default_value=0;bs.inputs['Specular IOR Level'].default_value=.10
    node=mat.node_tree.nodes.new('ShaderNodeTexImage');node.image=bpy.data.images.load(str(path));node.image.pack();mat.node_tree.links.new(node.outputs['Color'],bs.inputs['Base Color']);o.data.materials.clear();o.data.materials.append(mat)
    return path
PROFILES=[
 ('CanyonWall_A', [((-3,0,16),(25,17,32),31,(0,.02,-.035)),((9,1.2,11),(16,19,22),54,(.02,-.035,.055)),((-1,3.3,30),(19,14,15),64,(0,-.07,-.025))],(32,20,38)),
 ('CanyonWall_B', [((2,0,18),(25,19,36),83,(0,-.03,.02)),((-9,-.8,10),(16,17,21),91,(0,.03,-.04)),((4,3.5,35),(18,14,12),127,(0,.05,.04))],(32,21,41)),
 ('CanyonWall_Corner', [((0,0,12),(25,21,24),141,(0,.02,.02)),((-3,4,25),(19,16,16),158,(0,-.04,-.035))],(26,22,32)),
]
objects=[];report=[]
for name,shapes,dims in PROFILES:
    pieces=[convex(name+str(i),p,s,seed,r)for i,(p,s,seed,r)in enumerate(shapes)]
    o=pieces[0]
    for b in pieces[1:]:combine(o,b)
    active(o);bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.dissolve_limit(bm,angle_limit=.012,verts=list(bm.verts),edges=list(bm.edges),delimit=set());bm.to_mesh(o.data);bm.free()
    lo=Vector([min(v.co[i]for v in o.data.vertices)for i in range(3)]);hi=Vector([max(v.co[i]for v in o.data.vertices)for i in range(3)])
    scale=[(dims[i]/(hi[i]-lo[i]))for i in range(3)]
    center=(lo+hi)/2
    for v in o.data.vertices:v.co=Vector(((v.co.x-center.x)*scale[0],(v.co.y-center.y)*scale[1],(v.co.z-lo.z)*scale[2]))
    strata(o,[h for h in (6.5,14.5,23,31.5)if h<dims[2]-2])
    bevel=o.modifiers.new('Small chipped edge bevel','BEVEL');bevel.width=.10;bevel.segments=1;bevel.limit_method='ANGLE';bevel.angle_limit=.6;bpy.ops.object.modifier_apply(modifier=bevel.name)
    tri=o.modifiers.new('Runtime triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
    if len(o.data.polygons)>1200:
        dec=o.modifiers.new('Standard wall triangle budget','DECIMATE');dec.ratio=1160/len(o.data.polygons);dec.use_collapse_triangulate=True;bpy.ops.object.modifier_apply(modifier=dec.name)
    for f in o.data.polygons:f.use_smooth=False
    o.name=name;o.data.name=name+'_Geometry';o['ModelingRoute']='Blender fallback after native wall review';o['AssetVersion']=1
    tex=texture(o);active(o)
    bm=bmesh.new();bm.from_mesh(o.data);bad=sum(not e.is_manifold for e in bm.edges);bm.free();assert bad==0,(name,bad)
    report.append({'name':name,'triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'dimensions_blender':list(o.dimensions),'non_manifold_edges':bad,'texture':tex.name,'uv_layers':len(o.data.uv_layers),'materials':len(o.data.materials)})
    bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports'/(name+'.fbx')),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
    objects.append(o)
    print('WALL_BUILT',json.dumps(report[-1]),flush=True)
# Combined export for one Studio import; source mesh coordinates remain local.
bpy.ops.object.select_all(action='DESELECT')
for o in objects:o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports/CanyonWall_Kit.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
(ROOT/'wall_geometry_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
# Review scene uses the same meshes without altering export geometry.
for i,o in enumerate(objects):o.location=(i*36,0,0)
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=20;scene.cycles.use_denoising=True;scene.render.threads_mode='FIXED';scene.render.threads=4
scene.render.resolution_x=1500;scene.render.resolution_y=750;scene.render.resolution_percentage=100
scene.world.use_nodes=True;bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.68,.75,.82,1);bg.inputs['Strength'].default_value=.7
scene.view_settings.view_transform='Standard'
bpy.ops.object.light_add(type='AREA',location=(5,-35,60));bpy.context.object.data.energy=45000;bpy.context.object.data.size=35
bpy.ops.object.camera_add(location=(53,-110,60));cam=bpy.context.object;cam.data.type='ORTHO';cam.data.ortho_scale=122;cam.rotation_euler=(Vector((36,0,18))-cam.location).to_track_quat('-Z','Y').to_euler();scene.camera=cam
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'Source/CanyonWall_Kit.blend'))
scene.render.filepath=str(ROOT/'Renders/Blender_Wall_Review.png');bpy.ops.render.render(write_still=True)
print('CANYON_WALL_KIT_COMPLETE',flush=True)
