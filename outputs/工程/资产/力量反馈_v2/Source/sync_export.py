"""Sync the Studio-exported component into the existing local place, without rebuilding its world."""
from pathlib import Path
import re, xml.etree.ElementTree as ET
from xml.sax.saxutils import escape

ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT.parents[3]
place=PROJECT/'outputs/晶脉峡谷_三区矿洞初稿.rbxlx'
text=place.read_text(encoding='utf8')
tree=ET.fromstring(text)
def name(n): return n.findtext('./Properties/string[@name="Name"]')
def child(n,s): return next(x for x in n.findall('Item') if name(x)==s)
shared=child(next(x for x in tree.findall('Item') if x.get('class')=='ReplicatedStorage'),'Shared')
def span(n):
    ref=re.escape(n.get('referent'))
    start=re.search(r'<Item\b[^>]*referent="'+ref+r'"[^>]*>',text).start()
    depth=0
    for match in re.finditer(r'<Item\b[^>]*>|</Item>',text[start:]):
        depth+=-1 if match.group().startswith('</') else 1
        if depth==0: return start,start+match.end()
    raise ValueError('Unclosed Item')

template=ET.parse(ROOT/'Exports/PowerGainTemplate_v2.rbxmx').getroot().find('Item')
assert name(template)=='PowerGainTemplate'
assert child(template,'Icon').get('class')=='ImageLabel'
start,end=span(child(shared,'PowerGainTemplate'))
outside=text[:start]+text[end:]
assert all(n.get('referent') not in outside for n in template.iter('Item'))
replacement=ET.tostring(template,encoding='unicode')
changes=[(start,end,replacement)]
start,end=span(child(shared,'MiningFeedback'))
source=(PROJECT/'outputs/工程/src/ReplicatedStorage/Shared/MiningFeedback.luau').read_text(encoding='utf8')
item=text[start:end]
item,count=re.subn(r'<ProtectedString name="Source">.*?</ProtectedString>',lambda m:'<ProtectedString name="Source">'+escape(source)+'</ProtectedString>',item,flags=re.S)
assert count==1
changes.append((start,end,item))
for start,end,replacement in sorted(changes,reverse=True):text=text[:start]+replacement+text[end:]
ET.fromstring(text)
place.write_text(text,encoding='utf8',newline='\n')
print('Synced the exported ImageLabel component and MiningFeedback; other local place content preserved.')
