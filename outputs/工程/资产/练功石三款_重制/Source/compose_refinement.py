from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageOps
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
before=ROOT.parents[3]/'work'/'rock_refinement_20261115_before'
hashes=json.loads((before/'blue_variant_sha256.json').read_text(encoding='utf-8'))
for relative,digest in hashes.items():assert hashlib.sha256((ROOT/relative).read_bytes()).hexdigest()==digest,relative
canvas=Image.new('RGB',(1280,1220),(244,244,249));draw=ImageDraw.Draw(canvas)
font='C:/Windows/Fonts/msyh.ttc';title=ImageFont.truetype(font,28);label=ImageFont.truetype(font,21)
draw.text((28,15),'左右款微调 · 同一视角前后对照',font=title,fill=(40,37,63))
for i,(name,heading)in enumerate([('PracticeRock_A_Classic','灰色款：右侧收薄，左侧向上补齐'),('PracticeRock_C_Layered','紫色款：两道层缝减浅')]):
    x=20+i*630
    draw.rounded_rectangle((x,65,x+610,1170),15,fill='white')
    draw.text((x+18,80),heading,font=label,fill=(64,51,99))
    for row,(source,text)in enumerate([(before,'调整前'),(ROOT,'调整后')]):
        y=120+row*520
        draw.text((x+18,y),text,font=label,fill=(92,89,110))
        image=Image.open(source/'Renders'/(name+'_Hero.png')).convert('RGB').crop((75,125,1040,940))
        image=ImageOps.contain(image,(580,475));canvas.paste(image,(x+(610-image.width)//2,y+34+(475-image.height)//2))
draw.text((28,1185),'中间蓝色款的源文件、导出文件、贴图与预览均未改动。',font=label,fill=(85,83,102))
canvas.save(ROOT/'Renders'/'A_C_Refinement_Before_After.png')
(ROOT/'refinement_manifest.json').write_text(json.dumps({'asset_revision':3,'changes':{'A':'Right-hand lower/upper/back wrapping masses narrowed and thinned; left upper mass raised, extended upward and brought slightly forward.','C':'Both strata reduced to ~40% of previous inset depth, slightly narrower, with lighter seam base color.','B':'Unchanged: all ten artifact hashes match.'},'unchanged_blue_files':hashes,'evidence':'Renders/A_C_Refinement_Before_After.png','studio_import':'Not performed in this Blender-only refinement.'},ensure_ascii=False,indent=2),encoding='utf-8')
print({'blue_files_unchanged':len(hashes),'comparison':'A_C_Refinement_Before_After.png'})
