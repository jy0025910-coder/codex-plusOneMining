"""Compare saved place against checkpoint; export the actual saved native models."""
from pathlib import Path
import xml.etree.ElementTree as ET
import copy,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT.parents[3]
PLACE=PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx'
BEFORE=PROJECT/'work/canyon_integration_before/晶脉峡谷_三区矿洞初稿.rbxlx'
def name(o):return o.findtext('./Properties/string[@name="Name"]') or ''
def child(o,n):return next(x for x in o.findall('Item') if name(x)==n)
def service(r,c):return next(x for x in r.findall('Item') if x.get('class')==c)
def canonical(node):
    o=copy.deepcopy(node)
    for item in o.iter('Item'):
        item.attrib.pop('referent',None)
        p=item.find('Properties')
        if p is not None:
            for e in list(p):
                if e.tag in ('Ref','UniqueId'):p.remove(e)
    for e in o.iter():
        if e.text is not None and not e.text.strip():e.text=None
        if e.tail is not None and not e.tail.strip():e.tail=None
    return ET.tostring(o,encoding='utf8')
old=ET.parse(BEFORE).getroot();new=ET.parse(PLACE).getroot()
oldtown=child(service(old,'Workspace'),'Gem Gulch');town=child(service(new,'Workspace'),'Gem Gulch')
checks={}
checks['town_children_except_rim_unchanged']=(
    [canonical(c)for c in oldtown.findall('Item')if name(c)!='Canyon rim']==
    [canonical(c)for c in town.findall('Item')if name(c)!='Canyon rim'])
checks['lighting_unchanged']=canonical(service(old,'Lighting'))==canonical(service(new,'Lighting'))
def scripts(root):
    def walk(item,path):
        path=path+'/'+name(item)
        if item.get('class') in ('Script','LocalScript','ModuleScript'):
            src=item.findtext('./Properties/ProtectedString[@name="Source"]') or ''
            yield path,src
        for c in item.findall('Item'):yield from walk(c,path)
    return dict(pair for item in root.findall('Item') for pair in walk(item,''))
a=scripts(old);b=scripts(new)
changed=[p for p in sorted(set(a)|set(b)) if a.get(p)!=b.get(p)]
checks['only_environment_script_changed']=changed==['/ServerScriptService/Services/CampEnvironment']
source=(PROJECT/'outputs/工程/src/ServerScriptService/Services/CampEnvironment.luau').read_text(encoding='utf8').strip()
checks['environment_source_matches']=b['/ServerScriptService/Services/CampEnvironment'].strip().replace('\r\n','\n')==source.replace('\r\n','\n')
checks['no_staging_model']=not any(name(c)=='CanyonWall_Irregular_v3'for c in service(new,'Workspace').findall('Item'))
env=child(child(service(new,'ServerStorage'),'GameAssets'),'Environment')
rim=child(town,'Canyon rim');kit=child(env,'CanyonMeshKit')
checks['visual_count_78']=sum(i.get('class')=='MeshPart'for i in rim.iter('Item'))==78
checks['zero_rim_scripts']=not any(i.get('class')in('Script','LocalScript','ModuleScript')for i in rim.iter('Item'))
checks['preview_archived']=name(child(child(env,'ReviewSamples'),'Camp Art Sample'))=='Camp Art Sample'
def export(node,path):
    r=ET.Element('roblox',version='4');ET.SubElement(r,'External').text='null';ET.SubElement(r,'External').text='nil'
    r.append(copy.deepcopy(node));ET.ElementTree(r).write(path,encoding='utf8',xml_declaration=True)
export(kit,ROOT/'Exports/CanyonMeshKit_v3.rbxmx')
export(rim,ROOT/'Exports/CanyonRim_Integrated_v3.rbxmx')
report={'checks':checks,'changed_scripts':changed,'place_sha256':hashlib.sha256(PLACE.read_bytes()).hexdigest(),'checkpoint':'7bd5c82','visual_instances':78,'colliders':34,'templates':{'A':{'mesh':112904994536981,'texture':80241492425048},'B':{'mesh':135907110245641,'texture':124207543160591},'Corner':{'mesh':114785705213439,'texture':113511616860746}},'play_evidence':{'mode':'Solo, one client','unique_content_preload':'6/6 Success in Edit and Client','auto_training_gain':1,'training_stops_after_leaving':True,'gate1_hp':[100,0],'deepest_layer':1,'walk_into_first_room_z':-93.22147,'left_boundary_stopped_x':-90.0291},'not_tested':['Complete 5-ore sell-upgrade loop','Multiplayer','Mobile','Performance benchmark']}
(ROOT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert all(checks.values()),report
print(json.dumps(checks))
