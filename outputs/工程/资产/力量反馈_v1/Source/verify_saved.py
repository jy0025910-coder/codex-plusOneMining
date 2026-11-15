from pathlib import Path
import xml.etree.ElementTree as ET
import copy,json
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parents[3]
def name(x):return x.findtext('./Properties/string[@name="Name"]')or ''
def child(x,n):return next(c for c in x.findall('Item')if name(c)==n)
def service(r,c):return next(x for x in r.findall('Item')if x.get('class')==c)
def canonical(node):
    n=copy.deepcopy(node)
    for o in n.iter('Item'):
        o.attrib.pop('referent',None)
        p=o.find('Properties')
        if p is not None:
            for e in list(p):
                if e.tag in ('Ref','UniqueId'):p.remove(e)
    for e in n.iter():
        if e.text is not None and not e.text.strip():e.text=None
        if e.tail is not None and not e.tail.strip():e.tail=None
    return ET.tostring(n,encoding='utf8')
old=ET.parse(PROJECT/'work/strength_feedback_before/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
new=ET.parse(PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
checks={
 'map_unchanged':canonical(child(service(old,'Workspace'),'Gem Gulch'))==canonical(child(service(new,'Workspace'),'Gem Gulch')),
 'lighting_unchanged':canonical(service(old,'Lighting'))==canonical(service(new,'Lighting')),
 'server_assets_unchanged':canonical(service(old,'ServerStorage'))==canonical(service(new,'ServerStorage')),
}
shared=child(service(new,'ReplicatedStorage'),'Shared');template=child(shared,'PowerGainTemplate')
icon=child(template,'Icon');amount=child(template,'Amount')
checks['pickaxe_viewport_icon']=icon.get('class')=='ViewportFrame'
checks['seven_existing_mesh_parts']=sum(o.get('class')=='MeshPart'for o in icon.iter('Item'))==7
checks['no_template_scripts']=not any(o.get('class')in('Script','ModuleScript','LocalScript')for o in template.iter('Item'))
targets=[
 (child(child(service(new,'ServerScriptService'),'Services'),'MiningService'),'ServerScriptService/Services/MiningService.luau'),
 (child(child(service(new,'StarterPlayer'),'StarterPlayerScripts'),'DigController'),'StarterPlayer/StarterPlayerScripts/DigController.client.luau'),
 (child(shared,'MiningFeedback'),'ReplicatedStorage/Shared/MiningFeedback.luau'),
 (child(shared,'PrototypeConfig'),'ReplicatedStorage/Shared/PrototypeConfig.luau')]
for node,path in targets:
    stored=node.findtext('./Properties/ProtectedString[@name="Source"]')or ''
    local=(PROJECT/'outputs/工程/src'/path).read_text(encoding='utf8')
    checks['source_matches_'+name(node)]=stored.strip().replace('\r\n','\n')==local.strip().replace('\r\n','\n')
out=ROOT/'Exports';out.mkdir(exist_ok=True)
r=ET.Element('roblox',version='4');ET.SubElement(r,'External').text='null';ET.SubElement(r,'External').text='nil';r.append(copy.deepcopy(template))
ET.ElementTree(r).write(out/'PowerGainTemplate.rbxmx',encoding='utf8',xml_declaration=True)
report={'checks':checks,'play':{'mode':'Solo one client','click_gain':1,'click_no_swing':True,'popup_cleanup':True,'gate_auto_hp_sample':[46,10],'gate1_completed':True,'auto_stops_after_leaving':True,'ore_auto_sample':[3,5],'full_bag_stops':True,'training_gain':1,'respawn_popup_camera':True},'not_tested':['Two clients','Touch','Controller','Mobile performance'],'icon':'Existing Tool.IronPickaxe, no new image uploads','screenshot':'Temporary enlarged review component; harness removed'}
(ROOT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert all(checks.values()),report
print(json.dumps(checks))
