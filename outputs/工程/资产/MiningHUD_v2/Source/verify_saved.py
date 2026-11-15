"""Check UI-only scope, native prefab parity, and source ownership after integration."""
from pathlib import Path
import copy,json,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parents[3]
def name(n):return n.findtext('./Properties/string[@name="Name"]')
def child(n,s):return next(x for x in n.findall('Item')if name(x)==s)
def service(n,s):return next(x for x in n.findall('Item')if x.get('class')==s)
def canon(n):
    n=copy.deepcopy(n)
    for o in n.iter('Item'):
        o.attrib.pop('referent',None)
        for p in list(o.find('Properties')):
            if p.tag in ('Ref','UniqueId'):o.find('Properties').remove(p)
    for o in n.iter():
        if o.text is not None and not o.text.strip():o.text=None
        if o.tail is not None and not o.tail.strip():o.tail=None
    return ET.tostring(n,encoding='utf8')
old=ET.parse(PROJECT/'work/hud_polish_before/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
new=ET.parse(PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx').getroot()
kit=ET.parse(ROOT/'Exports/MiningHUDKit.rbxmx').getroot().find('Item')
checks={s+'_unchanged':canon(service(old,s))==canon(service(new,s))for s in ['Workspace','Lighting','ServerStorage','ServerScriptService']}
shared=child(service(new,'ReplicatedStorage'),'Shared')
for key in ['PowerGainTemplate','MiningFeedback','MiningAnimator','PrototypeConfig']:
    checks[key+'_unchanged']=canon(child(child(service(old,'ReplicatedStorage'),'Shared'),key))==canon(child(shared,key))
gui=child(service(new,'StarterGui'),'MiningHUD')
checks['one_hud']=sum(name(n)=='MiningHUD'for n in service(new,'StarterGui').findall('Item'))==1
checks['native_gui_matches_export']=canon(gui)==canon(child(kit,'MiningHUD'))
checks['separate_icon_labels']=sum(n.get('class')=='ImageLabel'for n in gui.iter('Item'))==18
checks['authored_menu_buttons']=len([n for n in child(child(gui,'Root'),'MenuGrid').findall('Item')if n.get('class')=='TextButton'])==8
targets=[(child(shared,'HUDTheme'),'ReplicatedStorage/Shared/HUDTheme.luau'),(child(shared,'HUDLayout'),'ReplicatedStorage/Shared/HUDLayout.luau')]
targets.append((child(shared,'HUDDecor'),'ReplicatedStorage/Shared/HUDDecor.luau'))
client=child(service(new,'StarterPlayer'),'StarterPlayerScripts')
targets += [(child(client,'HUDController'),'StarterPlayer/StarterPlayerScripts/HUDController.client.luau'),(child(client,'DigController'),'StarterPlayer/StarterPlayerScripts/DigController.client.luau')]
for node,path in targets:
    stored=node.findtext('./Properties/ProtectedString[@name="Source"]')or ''
    source=(PROJECT/'outputs/工程/src'/path).read_text(encoding='utf8')
    checks['source_matches_'+name(node)]=stored.strip().replace('\r\n','\n')==source.strip().replace('\r\n','\n')
    if name(node)=='HUDController':checks['no_purchase_calls']='MarketplaceService'not in source and 'PromptProductPurchase'not in source
root=child(gui,'Root')
checks['flat_menu_tiles']=all(not any(x.get('class')=='UIGradient'for x in n.findall('Item'))for n in child(root,'MenuGrid').findall('Item')if n.get('class')=='TextButton')
checks['transparent_resource_rows']=all(n.findtext('./Properties/float[@name="BackgroundTransparency"]')=='1'for n in child(root,'ResourceList').findall('Item')if n.get('class')=='Frame')
checks['three_reward_glows']=sum(name(n)=='RewardGlow'for n in gui.iter('Item'))==3
checks['twelve_fading_rays']=sum(name(n)=='CenterToEdge'for n in gui.iter('Item'))==12
oldclient=child(service(old,'StarterPlayer'),'StarterPlayerScripts')
checks['mining_controller_unchanged']=canon(child(oldclient,'DigController'))==canon(child(client,'DigController'))
report={'checks':checks,'scope':'HUD v2 flat buttons, native fading reward rays, shaded resources; gameplay unchanged'}
(ROOT/'static_verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
assert all(checks.values()),report
print(json.dumps(checks))
