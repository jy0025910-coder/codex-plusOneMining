"""QA contact sheet: unmodified same-camera Studio captures, no retouching."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
a=Image.open(ROOT/'Renders/Studio_Before.jpg').convert('RGB')
b=Image.open(ROOT/'Renders/Studio_After.jpg').convert('RGB')
assert a.size==b.size
w,h=a.size;sheet=Image.new('RGB',(w*2+24,h+66),'#25313d')
sheet.paste(a,(8,58));sheet.paste(b,(w+16,58))
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',28)
d=ImageDraw.Draw(sheet);d.text((24,10),'调整前 · Studio 实景',font=font,fill='white');d.text((w+32,10),'调整后 · 相同机位与光照',font=font,fill='white')
sheet.save(ROOT/'Renders/Studio_Before_After.png')
for p in (ROOT/'Renders').glob('*'):
    if p.suffix.lower() in ('.png','.jpg'):
        with Image.open(p)as im:im.verify()
print('QA_CONTACT_SHEET_SAVED',sheet.size)
