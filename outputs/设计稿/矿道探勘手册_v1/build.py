"""编译离线手册；正文、互动、插画均嵌入一个 HTML。"""
from pathlib import Path
from PIL import Image
from io import BytesIO
import base64
d=Path(__file__).resolve().parent
with Image.open(d/'十把矿镐_原画.png') as im:
    stream=BytesIO()
    im.convert('RGB').save(stream,'JPEG',quality=91,optimize=True)
art='data:image/jpeg;base64,'+base64.b64encode(stream.getvalue()).decode('ascii')
s=(d/'manual.template.html').read_text('utf-8').replace('__DATA__',(d/'design-data.js').read_text('utf-8')).replace('__APP__',(d/'interaction.js').read_text('utf-8')).replace('__ART__',art)
(d/'晶脉峡谷_核心玩法.html').write_text(s,'utf-8')
