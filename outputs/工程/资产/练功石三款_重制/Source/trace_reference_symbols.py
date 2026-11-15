from pathlib import Path
from PIL import Image,ImageOps,ImageFilter
import json
ROOT=Path(__file__).resolve().parents[1]
source=Image.open('C:/Users/Administrator/AppData/Local/Temp/codex-clipboard-e444bac0-a7a6-4573-b22a-4371b71e6bde.png').convert('RGB')
result={}
for name,box in [('A',(398,80,513,203)),('B',(702,79,799,173)),('C',(982,77,1086,176))]:
    region=source.crop(box);mask=Image.new('L',region.size)
    for y in range(region.height):
        for x in range(region.width):
            r,g,b=region.getpixel((x,y))
            test=(r>170 and g>105 and b<115 and r-g<105) if name=='A' else (r>115 and g>210 and b>215) if name=='B' else (r>190 and g>145 and b>215 and b-r<65)
            mask.putpixel((x,y),255 if test else 0)
    # Discard pale rock-edge fragments outside the central emblem, retaining
    # disconnected inner diamonds belonging to the same symbol.
    unseen={(x,y)for y in range(mask.height)for x in range(mask.width)if mask.getpixel((x,y))}
    groups=[]
    while unseen:
        stack=[unseen.pop()];group=[]
        while stack:
            x,y=stack.pop();group.append((x,y))
            for point in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if point in unseen:unseen.remove(point);stack.append(point)
        groups.append(group)
    print(name,[(len(g),(min(p[0]for p in g),min(p[1]for p in g),max(p[0]for p in g),max(p[1]for p in g)))for g in sorted(groups,key=len,reverse=True)[:6]])
    clean=Image.new('L',mask.size)
    for g in groups:
        if len(g)<12:continue
        cx=(min(p[0]for p in g)+max(p[0]for p in g))/2
        cy=(min(p[1]for p in g)+max(p[1]for p in g))/2
        if abs(cx-mask.width/2)<mask.width*.22 and abs(cy-mask.height/2)<mask.height*.22:
            for p in g:clean.putpixel(p,255)
    mask=clean
    bbox=mask.getbbox();assert bbox
    mask=mask.crop(bbox);mask=ImageOps.expand(mask,border=3,fill=0)
    mask.save(ROOT/'Source'/('ReferenceMark_'+name+'.png'))
    result[name]={'width':mask.width,'height':mask.height,'rows':[[mask.getpixel((x,y))/255 for x in range(mask.width)]for y in range(mask.height)],'source_crop':box,'method':'Color-isolated user-reference symbol silhouette; no background projection'}
(ROOT/'Source'/'reference_symbols.json').write_text(json.dumps(result),encoding='utf-8')
print({k:(v['width'],v['height'])for k,v in result.items()})
