"""Bake the painted sandstone source onto existing wall UVs in Blender.
No paving, stall, characters, lighting, collision proxies or gameplay changes.
"""
import bpy,bmesh,math,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parent
BASE=ROOT.parent
bpy.ops.wm.open_mainfile(filepath=str(BASE/'Source/CanyonWall_Kit.blend'))
scene=bpy.context.scene
scene.render.engine='CYCLES';scene.cycles.samples=1
scene.render.threads_mode='FIXED';scene.render.threads=4
source=bpy.data.images.load(str(ROOT/'Textures/Sandstone_PaintedStrata_Source.png'),check_existing=False)
source.colorspace_settings.name='sRGB';source.pack()
walls=[bpy.data.objects[n]for n in ('CanyonWall_A','CanyonWall_B','CanyonWall_Corner')]
records=[]
def active(o):
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
for i,o in enumerate(walls):
    active(o)
    original_name=o.name
    # Soften the old machined-looking equal-width groove lips. Keep silhouette.
    for v in o.data.vertices:
        x,y,z=v.co
        phase=z-.40*math.sin(x*.23+.3)-.022*x-.10*math.sin(y*.30)
        distance=min(abs(phase-h)for h in (6.5,14.5,23,31.5)if h<o.dimensions.z-2)
        old=max(0,1-distance/.55)*.012
        new=old*.32
        if old>0:
            f=(1-new)/(1-old);v.co.x*=f;v.co.y*=f
    o.data.update()
    # Recalculate normals after the shallow lip adjustment.
    bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
    mat=bpy.data.materials.new(original_name+'_PaintedStrata_v2');mat.use_nodes=True
    nodes=mat.node_tree.nodes;nodes.clear();links=mat.node_tree.links
    coord=nodes.new('ShaderNodeTexCoord')
    mapping=nodes.new('ShaderNodeMapping');mapping.vector_type='POINT'
    mapping.inputs['Scale'].default_value=(1.15,.8,.85)
    mapping.inputs['Location'].default_value=(i*.17,i*.09,i*.13)
    links.new(coord.outputs['Generated'],mapping.inputs['Vector'])
    split=nodes.new('ShaderNodeSeparateXYZ');links.new(mapping.outputs['Vector'],split.inputs[0])
    combine=nodes.new('ShaderNodeCombineXYZ')
    # Mirrored repetition has no value discontinuity even if raster edges differ.
    for j in range(3):
        ping=nodes.new('ShaderNodeMath');ping.operation='PINGPONG';ping.inputs[1].default_value=1
        links.new(split.outputs[j],ping.inputs[0]);links.new(ping.outputs[0],combine.inputs[j])
    tex=nodes.new('ShaderNodeTexImage');tex.image=source;tex.projection='BOX';tex.projection_blend=.18
    links.new(combine.outputs[0],tex.inputs['Vector'])
    emit=nodes.new('ShaderNodeEmission');emit.inputs['Strength'].default_value=1
    links.new(tex.outputs['Color'],emit.inputs['Color'])
    out=nodes.new('ShaderNodeOutputMaterial');links.new(emit.outputs[0],out.inputs['Surface'])
    o.data.materials.clear();o.data.materials.append(mat)
    image=bpy.data.images.new(original_name+'_BaseColor_v2',width=2048,height=2048,alpha=False)
    image.colorspace_settings.name='sRGB'
    target=nodes.new('ShaderNodeTexImage');target.image=image;target.label='UV bake target';nodes.active=target
    scene.render.bake.use_clear=True;scene.render.bake.margin=12;scene.render.bake.use_selected_to_active=False
    bpy.ops.object.bake(type='EMIT')
    image.filepath_raw=str(ROOT/'Textures'/(original_name+'_BaseColor_v2.png'));image.file_format='PNG';image.save();image.pack()
    nodes.clear()
    bs=nodes.new('ShaderNodeBsdfPrincipled');bs.inputs['Roughness'].default_value=.94;bs.inputs['Metallic'].default_value=0;bs.inputs['Specular IOR Level'].default_value=.08
    uvtex=nodes.new('ShaderNodeTexImage');uvtex.image=image;links.new(uvtex.outputs['Color'],bs.inputs['Base Color'])
    out=nodes.new('ShaderNodeOutputMaterial');links.new(bs.outputs[0],out.inputs['Surface'])
    o.name=original_name+'_v2';o.data.name=o.name+'_Geometry';o['AssetVersion']=2
    o['MaterialSource']='ImageGen painted strata, Blender mirrored box projection baked to existing UV atlas'
    o['GrooveDepthChange']='Old lip inset reduced to 32 percent; collision unchanged in Studio'
    bm=bmesh.new();bm.from_mesh(o.data);bad=sum(not e.is_manifold for e in bm.edges);bm.free();assert bad==0
    records.append({'name':o.name,'triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'non_manifold_edges':bad,'size_blender':list(o.dimensions),'uv_layers':len(o.data.uv_layers),'materials':len(o.data.materials),'texture_size':[2048,2048],'texture':image.filepath_raw})
    print('WALL_MATERIAL_BAKED',json.dumps(records[-1]),flush=True)
positions=[o.location.copy()for o in walls]
bpy.ops.object.select_all(action='DESELECT')
for o in walls:o.location=(0,0,0);o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports/CanyonWall_Material_v2.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
for o,p in zip(walls,positions):o.location=p
scene.cycles.samples=20
scene.render.resolution_x=1500;scene.render.resolution_y=750
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'CanyonWall_Kit_Material_v2.blend'))
scene.render.filepath=str(ROOT/'Renders/Blender_Material_v2.png');bpy.ops.render.render(write_still=True)
(ROOT/'geometry_material_report.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf8')
print('WALL_MATERIAL_V2_COMPLETE',flush=True)
