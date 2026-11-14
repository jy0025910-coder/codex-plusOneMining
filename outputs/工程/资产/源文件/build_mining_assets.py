"""Blender source generator for the iron pickaxe and sandstone ore family."""
import bpy
import bmesh
import math
import json
import random
from pathlib import Path
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[1]
EXPORT=ROOT/"导出"
EXPORT.mkdir(parents=True,exist_ok=True)
scene=bpy.context.scene
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
collections={}
def collection(name):
    c=bpy.data.collections.new(name)
    scene.collection.children.link(c)
    collections[name]=c
    return c
pick=collection("IronPickaxe")
stone=collection("SandstoneOre")
def move(obj,coll):
    for c in list(obj.users_collection):c.objects.unlink(obj)
    coll.objects.link(obj)
def mat(name,hexcolor,metal=0,rough=.6):
    c=tuple(int(hexcolor[i:i+2],16)/255 for i in (0,2,4))
    m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True
    bs=next(n for n in m.node_tree.nodes if n.type=="BSDF_PRINCIPLED")
    bs.inputs["Base Color"].default_value=(*c,1)
    bs.inputs["Metallic"].default_value=metal;bs.inputs["Roughness"].default_value=rough
    return m
iron=[mat("Forged iron","5D91BD",.25,.38),mat("Silver edge","D4ECFF",.3,.3),mat("Iron underside","355778",.25,.4)]
wood=[mat("Walnut","A66939"),mat("Wood light","C4894B"),mat("Wood dark","80502D")]
leather=[mat("Ochre leather","FFB743",0,.7),mat("Leather edge","D98B2E",0,.75)]
rockm=[mat("Sandstone "+str(i),c)for i,c in enumerate(["C9946D","DCA77C","B88565","E7B68B","A97B60"])]
copper=[mat("Copper","C67943",.45,.47),mat("Copper edge","E8A15E",.5,.38),mat("Mineral seam","78553E")]

def mesh(name,verts,faces,mats,coll,roles=None):
    me=bpy.data.meshes.new(name+"Mesh");me.from_pydata(verts,[],faces);me.update()
    o=bpy.data.objects.new(name,me);coll.objects.link(o)
    for m in mats:me.materials.append(m)
    if roles:
        for p,i in zip(me.polygons,roles):p.material_index=i
    return o
def bevel(o,width=.04,segments=1):
    bpy.context.view_layer.objects.active=o
    mod=o.modifiers.new("Soft forged edges","BEVEL");mod.width=width;mod.segments=segments
    bpy.ops.object.modifier_apply(modifier=mod.name)
def cube(name,pos,size,mats,coll,bev=.03):
    bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.name=name;o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    move(o,coll)
    for m in mats:o.data.materials.append(m)
    if bev:bevel(o,bev,2)
    return o
def sweep(name,sections,mats,coll):
    # Octagonal section: broad front planes, narrow bevel catches.
    shape=[(-1,-.6),(-.7,-1),(.7,-1),(1,-.6),(1,.6),(.7,1),(-.7,1),(-1,.6)]
    verts=[]
    for x,z,halfheight,halfdepth in sections:
        for a,b in shape:verts.append((x,b*halfdepth,z+a*halfheight))
    faces=[];roles=[]
    faces.append(tuple(range(7,-1,-1)));roles.append(0)
    for i in range(len(sections)-1):
        for j in range(8):
            faces.append((i*8+j,i*8+(j+1)%8,(i+1)*8+(j+1)%8,(i+1)*8+j))
            roles.append(1 if j in (0,3,4,7)else 2 if j==6 else 0)
    faces.append(tuple(range((len(sections)-1)*8,len(sections)*8)));roles.append(1)
    return mesh(name,verts,faces,mats,coll,roles)

# The blade follows the front silhouette in the concept sheet.
sections=[
    (-1.73,2.66,.018,.025),(-1.43,2.94,.10,.075),(-1.02,3.20,.17,.105),
    (-.53,3.43,.23,.15),(-.24,3.47,.25,.17),(.24,3.47,.25,.17),
    (.58,3.40,.23,.15),(1.06,3.17,.17,.105),(1.48,2.87,.095,.065),(1.85,2.49,.012,.018)]
blade=sweep("IronHead",sections,iron,pick)
bevel(blade,.025,1)
cube("HeadSocket",(0,0,3.44),(.52,.46,.76),iron,pick,.055)
cube("TopSocketBand",(0,0,3.79),(.66,.52,.15),iron,pick,.035)
cube("BottomSocketBand",(0,0,3.10),(.66,.52,.15),iron,pick,.035)

# A tapered octagonal shaft retains broad readable wood faces.
verts=[];faces=[];roles=[]
for z,rad,cx in [(0,.13,-.035),(.12,.16,-.02),(.7,.15,.02),(1.5,.145,.03),(2.3,.16,0),(3.0,.18,-.025),(3.94,.16,0),(4.02,.12,0)]:
    for j in range(8):
        a=j*math.pi/4;verts.append((cx+rad*math.cos(a),rad*.87*math.sin(a),z))
faces.append(tuple(range(7,-1,-1)));roles.append(2)
for i in range(7):
    for j in range(8):
        faces.append((8*i+j,8*i+(j+1)%8,8*(i+1)+(j+1)%8,8*(i+1)+j));roles.append(j%3)
faces.append(tuple(range(56,64)));roles.append(1)
shaft=mesh("WalnutShaft",verts,faces,wood,pick,roles);bevel(shaft,.018,1)
verts=[];faces=[]
turns=5.2;steps=120
for i in range(steps+1):
    t=i/steps;a=t*turns*math.pi*2
    z=.32+t*1.12
    for dz in (-.105,.105):
        verts.append((.01+.164*math.cos(a),.145*math.sin(a),z+dz))
for i in range(steps):faces.append((i*2,i*2+1,i*2+3,i*2+2))
wrap=mesh("LeatherWrap",verts,faces,leather,pick)
solid=wrap.modifiers.new("Leather thickness","SOLIDIFY");solid.thickness=.018
bpy.context.view_layer.objects.active=wrap;bpy.ops.object.modifier_apply(modifier=solid.name)
bevel(wrap,.009,1)

# Fuse the three lobes before reducing them to broad sculpted planes.
lobes=[]
for pos,scale in [((0,.25,1.66),(2.25,1.95,2.05)),((-1.45,-.68,.93),(1.35,1.25,1.22)),((1.45,-.25,1.0),(1.30,1.42,1.35))]:
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3,radius=1,location=pos)
    o=bpy.context.object;o.scale=scale;move(o,stone);lobes.append(o)
bpy.ops.object.select_all(action="DESELECT")
for o in lobes:o.select_set(True)
bpy.context.view_layer.objects.active=lobes[0];bpy.ops.object.join()
boulder=bpy.context.object;boulder.name="StoneBody"
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
remesh=boulder.modifiers.new("Fused stone mass","REMESH");remesh.mode="VOXEL";remesh.voxel_size=.21
bpy.ops.object.modifier_apply(modifier=remesh.name)
smooth=boulder.modifiers.new("Soften lobe transition","SMOOTH");smooth.factor=1.2;smooth.iterations=3
bpy.ops.object.modifier_apply(modifier=smooth.name)
dec=boulder.modifiers.new("Broad stone planes","DECIMATE");dec.ratio=.12
bpy.ops.object.modifier_apply(modifier=dec.name)
for v in boulder.data.vertices:v.co.z=max(.035,v.co.z)
boulder.data.update()
bm=bmesh.new();bm.from_mesh(boulder.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.025);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.005);bm.to_mesh(boulder.data);bm.free()
for m in rockm:boulder.data.materials.append(m)
randomizer=random.Random(29)
for p in boulder.data.polygons:
    p.use_smooth=False
    p.material_index=3 if p.normal.z>.65 else 1 if p.normal.z>.3 else randomizer.choice([0,0,2,4])
bevel(boulder,.045,1)

for i,(x,z,s) in enumerate([(-1.8,.60,.30),(-1.53,.82,.16),(-1.32,1.0,.11),(1.0,2.85,.28),(1.35,2.66,.38),(1.65,2.47,.19),(1.82,2.34,.12)]):
    hit,point,normal,_=boulder.closest_point_on_mesh(Vector((x,-2.5,z)))
    if not hit:continue
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=point+normal*.055)
    o=bpy.context.object;o.name="CopperInclusion"+str(i);o.scale=(s,s*.45,s*.72)
    o.rotation_euler=normal.to_track_quat("Y","Z").to_euler()
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    move(o,stone)
    for m in copper[:2]:o.data.materials.append(m)
    for p in o.data.polygons:p.material_index=int(p.normal.z>.2)
    # Dark stone directly under a fragment reads as a shallow inset seam.
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=point+normal*.005)
    seam=bpy.context.object;seam.name="InsetSeam"+str(i);seam.scale=(s*1.5,s*.13,s*.85);seam.rotation_euler=o.rotation_euler
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    move(seam,stone);seam.data.materials.append(copper[2])

def combined_mesh(coll,name,selection):
    objs=[o for o in coll.objects if selection(o)]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:o.select_set(True)
    bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join()
    o=bpy.context.object;o.name=name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    return o
iron_obj=combined_mesh(pick,"Iron",lambda o:o.name.startswith(("Iron","Head","TopSocket","BottomSocket")))
wood_obj=combined_mesh(pick,"Wood",lambda o:o.name.startswith("Walnut"))
leather_obj=combined_mesh(pick,"Leather",lambda o:o.name.startswith("Leather"))
seams=combined_mesh(stone,"Inclusions",lambda o:o.name.startswith(("CopperInclusion","InsetSeam")))

# Chunky cartoon proportions. Match the native MeshPart sizing recipe in NativeMeshRegistry.
for obj in pick.objects:
    for vertex in obj.data.vertices:
        x,y,z=vertex.co
        if obj.name=="Iron":vertex.co=(x*1.25,y*1.85,(z-3.44)*1.35+3.15)
        elif obj.name=="Wood":vertex.co=(x*1.4,y*1.4,z*.91)
        else:vertex.co=(x*1.45,y*1.45,z*.96+.05)
    obj.data.update()

bundle={}
def export_data(coll,offset):
    parts=[]
    for o in coll.objects:
        if o.type!="MESH":continue
        me=o.data;me.calc_loop_triangles()
        # Blender Z-up to Roblox Y-up. Center each part for mesh placement.
        transformed=[Vector((v.co.x,v.co.z-offset,-v.co.y))for v in me.vertices]
        lo=Vector([min(v[i]for v in transformed)for i in range(3)])
        hi=Vector([max(v[i]for v in transformed)for i in range(3)])
        center=(lo+hi)/2
        verts=[[round(x,6)for x in v-center]for v in transformed]
        faces=[]
        for tri in me.loop_triangles:
            mat=me.materials[tri.material_index]
            color=mat.diffuse_color
            normal=tri.normal
            faces.append({"v":[i+1 for i in tri.vertices],"c":[round(x,5)for x in color[:3]],"n":[round(normal.x,6),round(normal.z,6),round(-normal.y,6)]})
        parts.append({"name":o.name,"center":list(center),"size":list(hi-lo),"vertices":verts,"faces":faces,"material":"Metal"if o.name in ("Iron","Inclusions")else"SmoothPlastic"})
    return parts
bundle["IronPickaxe"]=export_data(pick,.92)
bundle["SandstoneOre"]=export_data(stone,0)
(EXPORT/"MiningMeshData.json").write_text(json.dumps(bundle,separators=(",",":")),encoding="utf-8")
for coll in (pick,stone):
    bpy.ops.object.select_all(action="DESELECT")
    for o in coll.objects:o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(EXPORT/(coll.name+".glb")),export_format="GLB",use_selection=True,export_apply=True)

# Preserve separate named source collections and a simple preview camera.
stone.hide_render=True
for o in pick.objects:o.select_set(True)
bpy.ops.object.camera_add(location=(5,-8,5.3))
camera=bpy.context.object;camera.rotation_euler=(Vector((0,0,2))-camera.location).to_track_quat("-Z","Y").to_euler();camera.data.type="ORTHO";camera.data.ortho_scale=5.7;scene.camera=camera
for pos,power,size in [((2,-4,7),550,5),((-4,-1,4),300,4),((1,4,6),500,3)]:
    bpy.ops.object.light_add(type="AREA",location=pos);lamp=bpy.context.object;lamp.data.energy=power;lamp.data.shape="DISK";lamp.data.size=size;lamp.rotation_euler=(Vector((0,0,2))-lamp.location).to_track_quat("-Z","Y").to_euler()
scene.world.color=(.35,.35,.35)
scene.render.engine="CYCLES";scene.cycles.samples=32
scene.render.resolution_x=900;scene.render.resolution_y=900;scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"
scene.view_settings.view_transform="AgX"
scene.render.film_transparent=True
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/"源文件/MiningAssets.blend"))
scene.render.filepath=str(EXPORT/"IronPickaxe_preview.png");bpy.ops.render.render(write_still=True)
stone.hide_render=False;pick.hide_render=True
camera.location=(7,-10,6);camera.rotation_euler=(Vector((0,0,1.7))-camera.location).to_track_quat("-Z","Y").to_euler();camera.data.ortho_scale=7.4
scene.render.filepath=str(EXPORT/"SandstoneOre_preview.png");bpy.ops.render.render(write_still=True)
print("ASSET_REPORT",json.dumps({k:[{"name":p["name"],"vertices":len(p["vertices"]),"triangles":len(p["faces"])}for p in parts]for k,parts in bundle.items()}),flush=True)
