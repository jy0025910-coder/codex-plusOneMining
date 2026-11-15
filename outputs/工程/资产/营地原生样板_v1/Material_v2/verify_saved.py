"""Saved-file verification of the wall-only material revision."""
from pathlib import Path
import xml.etree.ElementTree as ET,copy,json,hashlib
ROOT=Path(__file__).resolve().parent
PROJECT=ROOT.parents[4]
PLACE=ROOT.parents[3]/'晶脉峡谷_三区矿洞初稿.rbxlx'
BEFORE=PROJECT/'work/wall_texture_v2_before/晶脉峡谷_三区矿洞初稿.rbxlx'
def name(o):return o.findtext('./Properties/string[@name="Name"]')or ''
def child(o,n):return next(x for x in o.findall('Item')if name(x)==n)
def service(root,c):return next(x for x in root.findall('Item')if x.get('class')==c)
def clean(node):
    n=copy.deepcopy(node)
    for o in n.iter('Item'):
        o.attrib.pop('referent',None)
        p=o.find('Properties')
        if p is not None:
            for x in list(p):
                if x.tag in ('Ref','UniqueId'):p.remove(x)
    for element in n.iter():
        if element.text is not None and not element.text.strip():element.text=None
        if element.tail is not None and not element.tail.strip():element.tail=None
    return ET.tostring(n,encoding='utf-8')
def without_walls(root):
    s=copy.deepcopy(child(service(root,'Workspace'),'Camp Art Sample'))
    s.remove(child(s,'Continuous sandstone sample'))
    # Root metadata records the new wall material revision; other instances are checked.
    s.remove(s.find('Properties'))
    return clean(s)
old=ET.parse(BEFORE).getroot();new=ET.parse(PLACE).getroot()
checks={
 'original_town_unchanged':clean(child(service(old,'Workspace'),'Gem Gulch'))==clean(child(service(new,'Workspace'),'Gem Gulch')),
 'sample_paving_stall_npc_rock_zone_unchanged':without_walls(old)==without_walls(new),
 'lighting_unchanged':clean(service(old,'Lighting'))==clean(service(new,'Lighting')),
}
def colliders(root):
    wall=child(child(service(root,'Workspace'),'Camp Art Sample'),'Continuous sandstone sample')
    return {name(m):clean(child(m,'Simple cliff collision'))for m in wall.findall('Item')if m.get('class')=='Model'}
checks['wall_collision_proxies_unchanged']=colliders(old)==colliders(new)
env=child(child(service(new,'ServerStorage'),'GameAssets'),'Environment')
sample=child(service(new,'Workspace'),'Camp Art Sample')
def export(node,path):
    r=ET.Element('roblox',version='4');ET.SubElement(r,'External').text='null';ET.SubElement(r,'External').text='nil';r.append(copy.deepcopy(node));ET.ElementTree(r).write(path,encoding='utf-8',xml_declaration=True)
export(env,ROOT/'Exports/Camp_Sample_Library_v2.rbxmx')
export(sample,ROOT/'Exports/Camp_Art_Sample_v2.rbxmx')
report={'checks':checks,'place':str(PLACE),'scope':'Wall visual meshes and albedo only, plus edit-time authoring material-version metadata','not_tested':['Full gameplay loop','Multi-client','Mobile performance'],'exports':['Camp_Sample_Library_v2.rbxmx','Camp_Art_Sample_v2.rbxmx']}
(ROOT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert all(checks.values()),report
print(json.dumps(checks))
