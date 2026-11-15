from pathlib import Path
import json,hashlib
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
manifest=json.loads((ROOT/'asset-manifest.json').read_text(encoding='utf8'))
report=[]
for item in manifest['assets']:
    path=ROOT/item['path']
    with Image.open(path)as im:
        assert im.mode=='RGBA',path
        alpha=im.getchannel('A');bounds=alpha.getbbox();extrema=alpha.getextrema()
        assert extrema==(0,255)and bounds,path
        assert path.stat().st_size<20*1024*1024,path
        item['technical']={'width':im.width,'height':im.height,'alpha_extrema':extrema,'content_bounds':bounds,'normalization':'Original transparent PNG, no repainting or resizing','sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        report.append({'id':item['id'],'size':im.size,'alpha':extrema,'bytes':path.stat().st_size})
(ROOT/'asset-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
(ROOT/'asset_qa.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(report))
