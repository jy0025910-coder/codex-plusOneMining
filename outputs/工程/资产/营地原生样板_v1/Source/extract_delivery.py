"""Verify the saved place and export the native reusable kit, no Studio edits."""
from pathlib import Path
import copy, json, hashlib, xml.etree.ElementTree as ET
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
PLACE=ROOT.parents[2]/'晶脉峡谷_三区矿洞初稿.rbxlx'
BEFORE=ROOT.parents[3]/'work/camp_sample_before/晶脉峡谷_三区矿洞初稿.rbxlx'
def name(o):return o.findtext('./Properties/string[@name="Name"]')or ''
def child(o,n):return next(x for x in o.findall('Item')if name(x)==n)
def walk(o,path=''):
    counts={}
    for c in o.findall('Item'):
        key=(c.get('class'),name(c));counts[key]=counts.get(key,0)+1
        p=path+'/'+key[0]+':'+key[1]+'#'+str(counts[key])
        yield p,c
        yield from walk(c,p)
tree=ET.parse(PLACE).getroot();before=ET.parse(BEFORE).getroot()
ws=next(o for o in tree.findall('Item')if o.get('class')=='Workspace')
ss=next(o for o in tree.findall('Item')if o.get('class')=='ServerStorage')
env=child(child(ss,'GameAssets'),'Environment');sample=child(ws,'Camp Art Sample')
def export(node,path):
    root=ET.Element('roblox',version='4');ET.SubElement(root,'External').text='null';ET.SubElement(root,'External').text='nil';root.append(copy.deepcopy(node));ET.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
export(env,ROOT/'Exports/Camp_Sample_Library.rbxmx')
export(sample,ROOT/'Exports/Camp_Art_Sample.rbxmx')
old_sources={p:o.findtext('./Properties/ProtectedString[@name="Source"]')for p,o in walk(before)if o.get('class')in ('Script','LocalScript','ModuleScript')}
new_sources={p:o.findtext('./Properties/ProtectedString[@name="Source"]')for p,o in walk(tree)if o.get('class')in ('Script','LocalScript','ModuleScript')}
changed=[p for p,v in old_sources.items()if p in new_sources and (v or '').replace('\r\n','\n')!=(new_sources[p]or '').replace('\r\n','\n')]
missing=[p for p in old_sources if p not in new_sources]
def town_signature(root):
    w=next(x for x in root.findall('Item')if x.get('class')=='Workspace');town=child(w,'Gem Gulch');records=[]
    for p,o in walk(town):
        props=o.find('Properties');selected=[]
        if props is not None:
            for x in props:
                if x.tag in ('Ref','UniqueId'):continue
                # Parent and cross-instance identities are references, not visual data.
                selected.append((x.tag,x.get('name'),ET.tostring(x,encoding='unicode')))
        records.append((p,o.get('class'),sorted(selected)))
    return hashlib.sha256(json.dumps(records,ensure_ascii=False).encode()).hexdigest()
images={}
for p in list((ROOT/'Renders').glob('*.png'))+list((ROOT/'Renders').glob('*.jpg')):
    with Image.open(p)as im:im.verify()
    with Image.open(p)as im:images[p.name]={'size':list(im.size),'format':im.format,'bytes':p.stat().st_size}
owned_missing=[p for p in missing if not p.startswith('/Workspace:Workspace#1/Folder:Folder#1/')]
report={'place':str(PLACE),'saved_contains_sample':True,'existing_script_sources_changed':changed,'owned_game_scripts_missing':owned_missing,'external_demo_scripts_absent_vs_saved_disk_baseline':missing,'baseline_note':'The disk snapshot can differ from the live user-edited scene at task start. This task did not edit Workspace.Folder. Do not restore external demo scripts from the older disk snapshot.','existing_town_serialized_properties_identical':town_signature(before)==town_signature(tree),'image_checks':images,'exports':['Camp_Sample_Library.rbxmx','Camp_Art_Sample.rbxmx']}
assert not changed and not owned_missing,report
assert report['existing_town_serialized_properties_identical'], 'Existing town properties changed; inspect before claiming unchanged.'
(ROOT/'delivery_verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
