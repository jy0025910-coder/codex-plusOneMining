"""Review the selected PNG at HUD sizes; artwork is only uniformly resized."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
im=Image.open(ROOT/'Icons/Pickaxe_B_512.png').convert('RGBA')
fontpath='C:/Program Files/Roblox/Versions/version-63eb6055af4e4688/content/fonts/FredokaOne-Regular.ttf'
label=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',18)
sheet=Image.new('RGB',(760,230),(48,66,82));d=ImageDraw.Draw(sheet)
for i,s in enumerate((.68,1,1.18)):
    x=30+i*245;y=45
    p=im.resize((round(86*s),round(86*s)),Image.Resampling.LANCZOS)
    sheet.paste(p,(x,y),p)
    f=ImageFont.truetype(fontpath,round(70*s))
    d.text((x+round(83*s),y+round(6*s)),'+1',font=f,fill='white',stroke_width=round(4*s),stroke_fill=(20,15,19))
    d.text((x,180),str(s)+'× 组合比例',font=label,fill=(237,241,247))
sheet.save(ROOT/'Renders/Selected_B_SizeReview.png')
