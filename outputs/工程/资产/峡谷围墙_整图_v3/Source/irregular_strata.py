"""Deform the approved textured wall family; retain topology/UV/material identity."""
import bpy,bmesh,math,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OLD=ROOT.parent/'营地原生样板_v1/Material_v2'
bpy.ops.wm.open_mainfile(filepath=str(OLD/'CanyonWall_Kit_Material_v2.blend'))
scene=bpy.context.scene
walls=[bpy.data.objects[n] for n in ('CanyonWall_A_v2','CanyonWall_B_v2','CanyonWall_Corner_v2')]
report=[]
for i,o in enumerate(walls):
    height=max(v.co.z for v in o.data.vertices)
    old_dims=o.dimensions.copy()
    for v in o.data.vertices:
        x,y,z=v.co
        # Each stratum meanders independently, with different local slopes.
        # Envelope preserves flat ground and the approved upper silhouette.
        envelope=max(0,math.sin(math.pi*max(0,min(1,z/height))))**.75
        offset=(1.9*math.sin(x*.18+z*.24+i*1.7)
                +1.05*math.sin(x*.39-y*.14-z*.13+i*.8)
                +.55*math.sin(y*.29+x*.1+z*.4))
        v.co.z+=offset*envelope
        # Fade parts of former groove lips rather than tracing continuous rings.
        phase=z-.40*math.sin(x*.23+.3)-.022*x-.10*math.sin(y*.30)
        d=min(abs(phase-h) for h in (6.5,14.5,23,31.5) if h<height-2)
        old=max(0,1-d/.55)*.012*.32
        fade=.15+.85*(.5+.5*math.sin(x*.23+y*.17+z*.19+i))**2
        if old>0:
            factor=(1-old*fade)/(1-old)
            v.co.x*=factor;v.co.y*=factor
    o.data.update()
    bm=bmesh.new();bm.from_mesh(o.data)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bad=sum(not e.is_manifold for e in bm.edges)
    bm.to_mesh(o.data);bm.free();assert bad==0
    o.name=o.name.replace('_v2','_v3');o.data.name=o.name+'_Geometry'
    o['AssetVersion']=3;o['StrataRevision']='Independent height-field warp and local groove fade'
    report.append({'name':o.name,'triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'uv_layers':len(o.data.uv_layers),'non_manifold_edges':bad,'size':list(o.dimensions)})
bpy.ops.object.select_all(action='DESELECT')
for o in walls:o.location=(0,0,0);o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(ROOT/'Exports/CanyonWall_Irregular_v3.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
for i,o in enumerate(walls):o.location=(i*36,0,0)
scene.render.threads_mode='FIXED';scene.render.threads=4;scene.cycles.samples=20
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'Source/CanyonWall_Irregular_v3.blend'))
scene.render.filepath=str(ROOT/'Renders/Blender_Irregular_Strata.png')
bpy.ops.render.render(write_still=True)
(ROOT/'geometry_report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('IRREGULAR_STRATA_READY',flush=True)
