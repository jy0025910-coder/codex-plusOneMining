"""Export the actual saved Roblox library, preserving referenced SharedStrings."""
from pathlib import Path
from copy import deepcopy
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
place=ROOT.parents[2]/'晶脉峡谷_三区矿洞初稿.rbxlx'
data=ET.parse(place).getroot()
library=next(x for x in data.iter('Item')if x.attrib.get('class')=='Folder'and x.findtext('Properties/string[@name="Name"]')=='TrainingRocks')
names=[x.findtext('Properties/string[@name="Name"]')for x in library.findall('Item')]
assert set(names)=={'PracticeRock_A_Classic','PracticeRock_B_Rune','PracticeRock_C_Layered'}
expected={'110965572345599','91216537322638','113713316021185'}
mesh_ids=set()
for x in library.iter():
    if x.attrib.get('name')in {'MeshId','MeshContent'}:
        value=x.findtext('url')or x.findtext('uri')or x.text or''
        if 'rbxassetid://'in value:mesh_ids.add(value.split('//')[-1])
if not mesh_ids:print([(x.tag,x.attrib,x.text,[(c.tag,c.text)for c in x])for x in library.iter()if'Mesh'in x.attrib.get('name','')])
assert mesh_ids==expected,mesh_ids
output=ET.Element('roblox',{'version':'4'})
ET.SubElement(output,'External').text='null';ET.SubElement(output,'External').text='nil';output.append(deepcopy(library))
refs={x.text for x in library.iter('SharedString')};shared=data.find('SharedStrings')
if shared is not None and refs:
    target=ET.SubElement(output,'SharedStrings')
    for x in shared:
        if x.attrib.get('md5')in refs:target.append(deepcopy(x))
path=ROOT/'Exports'/'PracticeRock_TrainingLibrary.rbxmx'
ET.ElementTree(output).write(path,encoding='utf-8',xml_declaration=True)
print({'templates':names,'meshIds':sorted(mesh_ids),'bytes':path.stat().st_size})
