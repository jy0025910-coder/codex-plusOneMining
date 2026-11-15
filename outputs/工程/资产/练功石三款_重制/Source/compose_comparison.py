"""Arrange unaltered reference crops and real Blender renders for visual review."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageOps
ROOT=Path(__file__).resolve().parents[1]
ref=Image.open('C:/Users/Administrator/AppData/Local/Temp/codex-clipboard-e444bac0-a7a6-4573-b22a-4371b71e6bde.png').convert('RGB')
font='C:/Windows/Fonts/msyh.ttc'
board=Image.new('RGB',(1440,960),(242,243,249));draw=ImageDraw.Draw(board)
draw.text((30,15),'参考图与 Blender 实模对照',font=ImageFont.truetype(font,30),fill=(37,35,57))
names=['PracticeRock_A_Classic','PracticeRock_B_Rune','PracticeRock_C_Layered']
labels=['A · 经典岩石 / 金色螺旋','B · 蓝青岩石 / 斜裂带','C · 紫色岩石 / 弯折岩层']
for i,(name,label,box)in enumerate(zip(names,labels,[(320,16,611,264),(609,15,902,264),(900,16,1180,264)])):
    x=20+i*475
    draw.rounded_rectangle((x,66,x+465,925),18,fill='white')
    draw.text((x+18,78),label,font=ImageFont.truetype(font,22),fill=(63,48,101))
    draw.text((x+18,115),'你的示意图',font=ImageFont.truetype(font,18),fill=(88,87,109))
    image=ImageOps.contain(ref.crop(box),(425,330));board.paste(image,(x+(465-image.width)//2,147+(330-image.height)//2))
    draw.text((x+18,495),'本轮重做 · 真实 Blender 渲染',font=ImageFont.truetype(font,18),fill=(88,87,109))
    image=Image.open(ROOT/'Renders'/(name+'_Hero.png')).convert('RGB').crop((70,110,1040,925))
    image=ImageOps.contain(image,(435,370));board.paste(image,(x+(465-image.width)//2,532+(370-image.height)//2))
board.save(ROOT/'Renders'/'Reference_vs_Blender.png')
print('Comparison saved')
