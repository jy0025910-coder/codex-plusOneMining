"""Slightly cooler B material variation and a fresh image delivery after HTTP 502.
Rebake in Blender; mesh and UV geometry are unchanged.
"""
import bpy
from pathlib import Path
ROOT=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'CanyonWall_Kit_Material_v2.blend'))
bpy.ops.object.select_all(action='DESELECT')
o=bpy.data.objects['CanyonWall_B_v2'];o.select_set(True);bpy.context.view_layer.objects.active=o
o.location=(0,0,0);o.name='CanyonWall_B_SurfaceFix'
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1
mat=o.data.materials[0];nodes=mat.node_tree.nodes;links=mat.node_tree.links
source=bpy.data.images.load(str(ROOT/'Textures/CanyonWall_B_BaseColor_v2.png'),check_existing=False)
nodes.clear();tex=nodes.new('ShaderNodeTexImage');tex.image=source
multiply=nodes.new('ShaderNodeVectorMath');multiply.operation='MULTIPLY';multiply.inputs[1].default_value=(.985,.995,1)
links.new(tex.outputs['Color'],multiply.inputs[0]);emit=nodes.new('ShaderNodeEmission');links.new(multiply.outputs[0],emit.inputs['Color'])
out=nodes.new('ShaderNodeOutputMaterial');links.new(emit.outputs[0],out.inputs['Surface'])
target=bpy.data.images.new('CanyonWall_B_BaseColor_v2b',width=2048,height=2048,alpha=False)
target.colorspace_settings.name='sRGB';bake=nodes.new('ShaderNodeTexImage');bake.image=target;nodes.active=bake
scene.render.bake.use_selected_to_active=False;scene.render.bake.margin=12;bpy.ops.object.bake(type='EMIT')
target.filepath_raw=str(ROOT/'Textures/CanyonWall_B_BaseColor_v2b.png');target.file_format='PNG';target.save();target.pack()
nodes.clear();bs=nodes.new('ShaderNodeBsdfPrincipled');bs.inputs['Roughness'].default_value=.94;bs.inputs['Specular IOR Level'].default_value=.08
tex=nodes.new('ShaderNodeTexImage');tex.image=target;links.new(tex.outputs['Color'],bs.inputs['Base Color']);out=nodes.new('ShaderNodeOutputMaterial');links.new(bs.outputs[0],out.inputs['Surface'])
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports/CanyonWall_B_SurfaceFix.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'CanyonWall_B_SurfaceFix.blend'))
walls=[bpy.data.objects['CanyonWall_A_v2'],o,bpy.data.objects['CanyonWall_Corner_v2']]
bpy.ops.object.select_all(action='DESELECT')
for item in walls:item.location=(0,0,0);item.select_set(True)
o.name='CanyonWall_B_v2'
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports/CanyonWall_Material_v2.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
for index,item in enumerate(walls):item.location=(index*36,0,0)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'CanyonWall_Kit_Material_v2.blend'))
print('B_SURFACE_RETRY_EXPORTED',flush=True)
