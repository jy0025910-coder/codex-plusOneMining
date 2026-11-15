"""Normalize the user-selected B PNG for UI delivery, preserving alpha and artwork."""
from pathlib import Path
from PIL import Image
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
source=ROOT/'Icons/Pickaxe_B_Original.png'
im=Image.open(source).convert('RGBA')
original_size=im.size
im=im.resize((512,512),Image.Resampling.LANCZOS)
out=ROOT/'Icons/Pickaxe_B_512.png';im.save(out)
alpha=im.getchannel('A');assert alpha.getextrema()==(0,255)
record={'selected':'B','source':'Built-in image_gen; user selected second design','source_size':original_size,'delivery_size':im.size,'alpha_extrema':alpha.getextrema(),'normalization':'Uniform resize only; no repainting or silhouette changes','sha256':hashlib.sha256(out.read_bytes()).hexdigest()}
(ROOT/'icon_manifest.json').write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(record))
