"""Build a portable XML companion to the engine-produced RBXM, then validate in Studio."""
from pathlib import Path
import json,base64,struct,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
serial=0
def sub(parent,tag,text=None,**attrs):
    n=ET.SubElement(parent,tag,attrs)
    if text is not None:n.text=str(text).lower()if isinstance(text,bool)else str(text)
    return n
def attr_blob(attrs):
    blob=struct.pack('<I',len(attrs))
    for k,v in sorted(attrs.items()):
        b=k.encode();blob+=struct.pack('<I',len(b))+b
        if isinstance(v,bool):blob+=b'\x03'+bytes([v])
        elif isinstance(v,(int,float)):blob+=b'\x06'+struct.pack('<d',v)
        elif isinstance(v,str):
            b=v.encode();blob+=b'\x02'+struct.pack('<I',len(b))+b
        else:raise TypeError((k,v))
    return base64.b64encode(blob).decode()
def node(data,parent):
    global serial
    serial+=1
    item=sub(parent,'Item',**{'class':data['c'],'referent':f'RBXHUDPOLISH{serial:06d}'})
    props=sub(item,'Properties')
    if data.get('a'):sub(props,'BinaryString',attr_blob(data['a']),name='AttributesSerialize')
    for p in data['p']:
        typ,val,name=p['t'],p.get('v'),p['n']
        if val is None:sub(props,'Ref','null',name=name);continue
        simple={'Enum':'token','ProtectedString':'ProtectedString','string':'string','bool':'bool','int':'int','int64':'int64','float':'float','double':'double'}
        if typ in simple:sub(props,simple[typ],val,name=name)
        elif typ in ('UDim2','UDim','Vector2','Color3'):
            e=sub(props,typ,name=name)
            keys={'UDim2':['XS','XO','YS','YO'],'UDim':['S','O'],'Vector2':['X','Y'],'Color3':['R','G','B']}[typ]
            for k,v in zip(keys,val):sub(e,k,v)
        elif typ=='Rect2D':
            e=sub(props,typ,name=name)
            for key,a in [('min',val[:2]),('max',val[2:])]:
                q=sub(e,key);sub(q,'X',a[0]);sub(q,'Y',a[1])
        elif typ=='Content':
            e=sub(props,'Content',name=name)
            sub(e,'uri',val)if val else sub(e,'null')
        elif typ=='Font':
            e=sub(props,'Font',name=name);sub(sub(e,'Family'),'url',val[0]);sub(e,'Weight',val[1]);sub(e,'Style',val[2])
        elif typ in ('NumberSequence','ColorSequence'):
            sub(props,typ,' '.join(str(x)for k in val for x in k)+' ',name=name)
        else:raise ValueError((name,typ))
    for child in data['children']:node(child,item)
root=ET.Element('roblox',version='4');sub(root,'External','null');sub(root,'External','nil')
snapshot=json.loads((ROOT/'Source/native_snapshot.json').read_text(encoding='utf8'))
node(snapshot,root)
ET.ElementTree(root).write(ROOT/'Exports/MiningHUDKit.rbxmx',encoding='utf-8',xml_declaration=True)
print({'instances':serial,'xml_bytes':(ROOT/'Exports/MiningHUDKit.rbxmx').stat().st_size})
