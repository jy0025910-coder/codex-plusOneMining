"""Verify the saved icon-only migration and export the actual reusable component."""
from pathlib import Path
import xml.etree.ElementTree as ET
import copy,json
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parents[3]
def name(x):return x.findtext('./Properties/string[@name="Name"]')or ''
def child(x,n):return next(c for c in x.findall('Item')if name(c)==n)
def service(r,c):return next(x for x in r.findall('Item')if x.get('class')==c)
def canon(node):
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
old=ET.parse(PROJECT/'work/pickaxe_icon_b_before/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
new=ET.parse(PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
shared=child(service(new,'ReplicatedStorage'),'Shared');previous=child(child(service(old,'ReplicatedStorage'),'Shared'),'PowerGainTemplate')
template=child(shared,'PowerGainTemplate');icon=child(template,'Icon')
checks={
 'map_unchanged':canon(child(service(old,'Workspace'),'Gem Gulch'))==canon(child(service(new,'Workspace'),'Gem Gulch')),
 'lighting_unchanged':canon(service(old,'Lighting'))==canon(service(new,'Lighting')),
 'server_assets_unchanged':canon(service(old,'ServerStorage'))==canon(service(new,'ServerStorage')),
 'server_gameplay_unchanged':canon(service(old,'ServerScriptService'))==canon(service(new,'ServerScriptService')),
 'number_style_unchanged':canon(child(previous,'Amount'))==canon(child(template,'Amount')),
 'uses_image_label':icon.get('class')=='ImageLabel',
 'no_viewport_mesh_camera':not any(o.get('class')in('ViewportFrame','WorldModel','MeshPart','Camera')for o in template.iter('Item')),
}
source=child(shared,'MiningFeedback').findtext('./Properties/ProtectedString[@name="Source"]')or ''
local=(PROJECT/'outputs/工程/src/ReplicatedStorage/Shared/MiningFeedback.luau').read_text(encoding='utf8')
checks['source_matches']=source.strip().replace('\r\n','\n')==local.strip().replace('\r\n','\n')
image=icon.findtext('./Properties/Content[@name="ImageContent"]/uri') or icon.findtext('./Properties/Content[@name="Image"]/url')
checks['uploaded_image_configured']=bool(image and image.startswith('rbxassetid://')and image[13:].isdigit())
exported=ET.parse(ROOT/'Exports/PowerGainTemplate_v2.rbxmx').getroot().find('Item')
checks['matches_studio_component_export']=canon(exported)==canon(template)
report={'checks':checks,'image':image,'scope':'Selected cartoon pickaxe B replaces the UI thumbnail; number and all gameplay preserved','not_tested':['Mobile device performance','Multiplayer']}
(ROOT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert all(checks.values()),report
print(json.dumps(checks))
