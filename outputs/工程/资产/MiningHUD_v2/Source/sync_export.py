"""Merge actual Studio-exported HUD assets into the original local place only."""
from pathlib import Path
import re,copy,json,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parents[3]
place=PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx'
text=place.read_text(encoding='utf8');tree=ET.fromstring(text)
kit=ET.parse(ROOT/'Exports/MiningHUDKit.rbxmx').getroot().find('Item')
def name(n):return n.findtext('./Properties/string[@name="Name"]')
def child(n,s):return next(x for x in n.findall('Item')if name(x)==s)
def service(cls):return next(x for x in tree.findall('Item')if x.get('class')==cls)
def span(n):
    start=re.search(r'<Item\b[^>]*referent="'+re.escape(n.get('referent'))+r'"[^>]*>',text).start()
    depth=0
    for m in re.finditer(r'<Item\b[^>]*>|</Item>',text[start:]):
        depth+=-1 if m.group().startswith('</')else 1
        if depth==0:return start,start+m.end()
    raise ValueError('Unclosed Item')
def xml(n):return ET.tostring(n,encoding='unicode')
changes=[]
def add_or_replace(parent,node):
    old=next((n for n in parent.findall('Item')if name(n)==name(node)),None)
    if old is not None:
        a,b=span(old);changes.append((a,b,xml(node)))
    else:
        _,end=span(parent);at=end-len('</Item>');changes.append((at,at,xml(node)))
shared=child(service('ReplicatedStorage'),'Shared')
add_or_replace(shared,child(child(kit,'Shared'),'HUDTheme'))
add_or_replace(shared,child(child(kit,'Shared'),'HUDLayout'))
add_or_replace(shared,child(child(kit,'Shared'),'HUDDecor'))
add_or_replace(service('StarterGui'),child(kit,'MiningHUD'))
client=child(service('StarterPlayer'),'StarterPlayerScripts')
add_or_replace(client,child(child(kit,'Client'),'HUDController'))
for a,b,fragment in sorted(changes,key=lambda c:(c[0],c[1]),reverse=True):text=text[:a]+fragment+text[b:]
new=ET.fromstring(text)
refs=[n.get('referent')for n in new.iter('Item')]
assert len(refs)==len(set(refs)),'Duplicate Instance referents'
place.write_text(text,encoding='utf8',newline='\n')
print('Synced Studio HUD and 4 scripts into the existing original local place.')
