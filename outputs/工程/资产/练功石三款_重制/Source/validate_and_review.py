import bpy,bmesh,json,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
names=['PracticeRock_A_Classic','PracticeRock_B_Rune','PracticeRock_C_Layered']
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'Source'/(names[0]+'.blend')))
rocks=[bpy.data.objects[names[0]]]
for name in names[1:]:
    with bpy.data.libraries.load(str(ROOT/'Source'/(name+'.blend')),link=False)as(src,dst):dst.objects=[name]
    o=dst.objects[0];bpy.context.scene.collection.objects.link(o);rocks.append(o)
reports={}
for o in rocks:
    bm=bmesh.new();bm.from_mesh(o.data)
    r={'triangles':sum(len(p.vertices)-2 for p in o.data.polygons),'vertices':len(o.data.vertices),'non_manifold_edges':sum(not e.is_manifold for e in bm.edges),'loose_vertices':sum(not v.link_faces for v in bm.verts),'dimensions':list(o.dimensions),'mesh_objects':1,'materials':len(o.data.materials),'uv_layers':len(o.data.uv_layers),'scale':list(o.scale),'rotation':list(o.rotation_euler),'bottom':min(v.co.z for v in o.data.vertices),'volume':abs(bm.calc_volume()),'texture_size':[2048,2048]}
    unseen=set(bm.verts);components=0
    while unseen:
        components+=1;todo=[unseen.pop()]
        while todo:
            v=todo.pop()
            for e in v.link_edges:
                w=e.other_vert(v)
                if w in unseen:unseen.remove(w);todo.append(w)
    bm.free();r['connected_components']=components
    node=next(n for n in o.data.materials[0].node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    r['emission_strength']=node.inputs['Emission Strength'].default_value
    r['packed_images']=[bool(n.image.packed_file)for n in o.data.materials[0].node_tree.nodes if n.type=='TEX_IMAGE']
    assert r['triangles']<=1000 and r['non_manifold_edges']==0 and r['loose_vertices']==0 and components==1,r
    assert all(abs(a-b)<.001 for a,b in zip(o.dimensions,[8,6.5,6.5])) and r['bottom']==0,r
    assert r['materials']==1 and r['uv_layers']==1 and r['emission_strength']==0 and all(r['packed_images']),r
    reports[o.name]=r
    for view in ['Hero','Front','Right','Back','Top']:assert (ROOT/'Renders'/(o.name+'_'+view+'.png')).exists()
    assert (ROOT/'Exports'/(o.name+'.fbx')).stat().st_size>10000
for name in names:
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.import_scene.fbx(filepath=str(ROOT/'Exports'/(name+'.fbx')),use_image_search=True)
    imported=list(bpy.context.selected_objects);mesh=next(o for o in imported if o.type=='MESH')
    bpy.context.view_layer.update()
    r={'mesh_objects':sum(o.type=='MESH'for o in imported),'triangles':sum(len(p.vertices)-2 for p in mesh.data.polygons),'dimensions':list(mesh.dimensions),'uv_layers':len(mesh.data.uv_layers)}
    assert r['mesh_objects']==1 and r['triangles']==reports[name]['triangles'] and r['uv_layers']==1,r
    assert all(abs(a-b)<.001 for a,b in zip(r['dimensions'],[8,6.5,6.5])),r
    reports[name]['fbx_roundtrip']=r
    for o in imported:bpy.data.objects.remove(o,do_unlink=True)
for i,o in enumerate(rocks):o.location.x=(i-1)*10.5
scene=bpy.context.scene
for o in list(bpy.data.objects):
    if o.type=='LIGHT':bpy.data.objects.remove(o,do_unlink=True)
for loc,power,size in [((0,-10,16),2400,20),((-12,-4,9),500,15),((12,4,14),800,15)]:
    bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=size;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
camera=scene.camera;camera.location=(9,-32,15);camera.rotation_euler=(Vector((0,0,2.8))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=34.5
scene.render.resolution_x=1800;scene.render.resolution_y=800;scene.cycles.samples=24
scene.render.filepath=str(ROOT/'Renders'/'Three_Rocks_Remade.png')
bpy.ops.object.select_all(action='DESELECT')
for o in rocks:o.select_set(True)
bpy.context.view_layer.objects.active=rocks[0]
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'Source'/'Three_Rocks_Review.blend'))
bpy.ops.render.render(write_still=True)
(ROOT/'asset_manifest.json').write_text(json.dumps({'asset_version':3,'tool':bpy.app.version_string,'method':'Blender cut-plane solids, true inset fracture bands, UV inlaid symbols','visual_status':'A/C refinements awaiting user review; accepted blue variant preserved','reference':'User three-rock design sheet and subsequent A/C adjustment request','studio_test':'Not repeated for this Blender refinement. Prior version import screenshot is not evidence for this revision.','variants':reports},ensure_ascii=False,indent=2),encoding='utf-8')
print('REVIEW_VALIDATED',json.dumps(reports),flush=True)
