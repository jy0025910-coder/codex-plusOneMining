import bpy,bmesh,math,random,json,struct,zlib,sys
from pathlib import Path
from mathutils import Vector
import numpy as np
def rgb(hexcolor):return np.array([int(hexcolor[i:i+2],16)/255 for i in (0,2,4)],dtype=np.float64)
def line_distance(x,z,path):
    best=np.full_like(x,100.0,dtype=np.float64)
    for (ax,az),(bx,bz) in zip(path,path[1:]):
        dx,dz=bx-ax,bz-az
        t=np.clip(((x-ax)*dx+(z-az)*dz)/(dx*dx+dz*dz),0,1)
        best=np.minimum(best,np.sqrt((x-ax-dx*t)**2+(z-az-dz*t)**2))
    return best

def paint(profile,points,normal,shade):
    x,y,z=points[...,0],points[...,1],points[...,2]
    base,light,dark=rgb(profile['base']),rgb(profile['light']),rgb(profile['dark'])
    # Limited color bands are authored surface color, not baked cast shadows.
    tone=base*(1-shade)+light*shade if shade>=0 else base*(1+shade)+dark*(-shade)
    colors=np.broadcast_to(tone,points.shape).copy()
    kind=profile['kind'];front=(y<-.7)&(normal[1]<-.10)
    mark,shadow=rgb(profile['mark']),rgb(profile['mark_shadow'])
    if kind=='vein':
        primary=[(-1.45,6.35),(-1.62,5.35),(-1.04,4.65),(-1.42,3.8),(-.81,3.15),(-1.16,2.48),(-.66,1.12)]
        branch=[(-1.08,3.50),(-.12,3.05),(.42,2.03)]
        d=np.minimum(line_distance(x,z,primary),line_distance(x,z,branch))
        mask=front&(d<.064);rim=front&(d<.095)&~mask
        side=(x>2)&(normal[0]>.2)
        sd=line_distance(y,z,[(-1.2,4.6),(-.65,4.1),(.12,3.9),(.35,3.15)])
        mask|=side&(sd<.055);rim|=side&(sd<.080)&~mask
        back=(y>.5)&(normal[1]>.2)
        bd=line_distance(x,z,[(-1.1,5.3),(-1.8,4.65),(-1.55,4.0)])
        mask|=back&(bd<.04)
        colors[rim]=shadow;colors[mask]=mark
    elif kind=='diamond':
        d=np.abs(x)+np.abs(z-3.48)
        outer=np.abs(d-.87)<.09;inner=np.abs(d-.34)<.065
        rim=front&((np.abs(d-.87)<.125)|(np.abs(d-.34)<.095))
        colors[rim]=shadow;colors[front&(outer|inner)]=mark
        theta=np.arctan2(y,x)
        layer=2.18+.10*np.sin(theta*2+.5)
        band=np.abs(z-layer)<.065
        colors[band]=rgb(profile['light'])*.55+mark*.45
    elif kind=='spiral':
        theta=np.arctan2(y,x)
        layer1=2.25+.16*np.sin(theta*2+.7)
        layer2=4.45+.15*np.sin(theta*2-.5)
        d=np.minimum(np.abs(z-layer1),np.abs(z-layer2))
        colors[d<.115]=shadow
        colors[(d<.040)&(normal[2]<.4)]=base*.45+mark*.55
        path=[]
        for t in np.linspace(0,math.pi*3.4,90):
            radius=.58*(1-t/(math.pi*3.4))+.06
            path.append((radius*math.cos(t),3.45+radius*math.sin(t)))
        sd=line_distance(x,z,path)
        colors[front&(sd<.086)]=shadow
        colors[front&(sd<.055)]=mark
    return np.clip(colors,0,1)

def png_write(path,array):
    height,width,_=array.shape
    def chunk(tag,data):return struct.pack('>I',len(data))+tag+data+struct.pack('>I',zlib.crc32(tag+data)&0xffffffff)
    scan=b''.join(b'\0'+array[row].tobytes()for row in range(height))
    data=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(scan,6))+chunk(b'IEND',b'')
    path.write_bytes(data)

def atlas(profile,o):
    size=2048;faces=list(o.data.polygons)
    image=np.zeros((size,size,3),dtype=np.uint8);image[:]=np.round(rgb(profile['base'])*255).astype(np.uint8)
    uv=o.data.uv_layers.new(name='PracticeRock_Atlas')
    bpy.context.view_layer.objects.active=o
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(60),island_margin=.015)
    bpy.ops.object.mode_set(mode='OBJECT')
    faces=list(o.data.polygons);uv=o.data.uv_layers.active
    for index,face in enumerate(faces):
        coords=np.array([(uv.data[i].uv.x*size,(1-uv.data[i].uv.y)*size)for i in face.loop_indices])
        px,py=np.maximum(0,np.floor(coords.min(axis=0)-3).astype(int))
        hx,hy=np.minimum(size,np.ceil(coords.max(axis=0)+3).astype(int))
        vertices=np.array([o.data.vertices[v].co[:]for v in face.vertices],dtype=np.float64)
        yy,xx=np.mgrid[py:hy,px:hx];xy=np.stack((xx+.5,yy+.5),axis=-1)-coords[0]
        matrix=np.stack((coords[1]-coords[0],coords[2]-coords[0]),axis=1)
        if abs(np.linalg.det(matrix))<1e-7:continue
        ab=xy@np.linalg.inv(matrix).T;a,b=ab[...,0],ab[...,1]
        tolerance=2.0/max(1,min(np.linalg.norm(matrix[:,0]),np.linalg.norm(matrix[:,1])))
        inside=(a>=-tolerance)&(b>=-tolerance)&(a+b<=1+tolerance)
        points=vertices[0]+a[...,None]*(vertices[1]-vertices[0])+b[...,None]*(vertices[2]-vertices[0])
        normal=face.normal
        shade=.52 if normal.z>.55 else .13 if normal.z>.05 else -.30 if normal.z<-.45 else -.10
        colors=paint(profile,points,normal,max(-.5,min(.65,shade)),face.material_index)
        image[py:hy,px:hx][inside]=np.round(colors[inside]*255).astype(np.uint8)
    path=ROOT/'Textures'/(profile['name']+'_BaseColor.png');png_write(path,image)
    mat=bpy.data.materials.new(profile['name']+'_Material');mat.use_nodes=True
    bs=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    bs.inputs['Roughness'].default_value=.83;bs.inputs['Metallic'].default_value=0;bs.inputs['Specular IOR Level'].default_value=.15;bs.inputs['Emission Strength'].default_value=0
    texture=mat.node_tree.nodes.new('ShaderNodeTexImage');texture.name='Single BaseColor Atlas'
    texture.image=bpy.data.images.load(str(path),check_existing=False);texture.image.colorspace_settings.name='sRGB';texture.image.pack();texture.interpolation='Linear'
    mat.node_tree.links.new(texture.outputs['Color'],bs.inputs['Base Color']);o.data.materials.clear();o.data.materials.append(mat)
    return path

def setup_preview(scene):
    scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
    scene.render.threads_mode='FIXED';scene.render.threads=4
    scene.render.resolution_x=1100;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
    scene.render.image_settings.file_format='PNG';scene.render.film_transparent=False
    scene.world.use_nodes=True
    bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.72,.72,.72,1);bg.inputs['Strength'].default_value=.7
    scene.view_settings.view_transform='Standard'
    preview=bpy.data.collections.new('90_Preview_ExcludeFromExport');scene.collection.children.link(preview)
    def move(o):
        for c in list(o.users_collection):c.objects.unlink(o)
        preview.objects.link(o)
    floor_mat=bpy.data.materials.new('Preview warm neutral ground');floor_mat.use_nodes=True
    bs=next(n for n in floor_mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Base Color'].default_value=(.82,.78,.71,1);bs.inputs['Roughness'].default_value=.9
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.035));plane=bpy.context.object;plane.name='PreviewGround';move(plane);plane.data.materials.append(floor_mat)
    for pos,energy,area in [((-7,-10,12),1000,7),((9,-1,9),450,6),((0,7,10),600,5)]:
        bpy.ops.object.light_add(type='AREA',location=pos);lamp=bpy.context.object;move(lamp);lamp.data.energy=energy;lamp.data.shape='DISK';lamp.data.size=area;lamp.rotation_euler=(Vector((0,0,3))-lamp.location).to_track_quat('-Z','Y').to_euler()
    bpy.ops.object.camera_add(location=(10,-15,10));camera=bpy.context.object;camera.name='ReviewCamera';move(camera);camera.data.type='ORTHO';camera.data.ortho_scale=12.0;scene.camera=camera
    camera.rotation_euler=(Vector((0,0,3))-camera.location).to_track_quat('-Z','Y').to_euler()
    return camera,preview

def inspect(o):
    bm=bmesh.new();bm.from_mesh(o.data)
    result={'triangles':len(o.data.polygons),'vertices':len(o.data.vertices),'non_manifold_edges':sum(not e.is_manifold for e in bm.edges),'loose_vertices':sum(not v.link_faces for v in bm.verts)}
    bm.free();result['dimensions']=[round(v,5)for v in o.dimensions];result['mesh_objects']=1;result['materials']=len(o.data.materials);result['scale']=list(o.scale);result['rotation']=list(o.rotation_euler);result['origin']='bottom_center';result['emission']=False;result['uv_layers']=len(o.data.uv_layers)
    assert result['non_manifold_edges']==0 and result['loose_vertices']==0,result
    assert all(abs(a-b)<.001 for a,b in zip(result['dimensions'],[8,6.5,6.5])),result
    return result

