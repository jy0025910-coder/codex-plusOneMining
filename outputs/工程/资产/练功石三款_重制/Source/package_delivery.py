from pathlib import Path
import zipfile,json
ROOT=Path(__file__).resolve().parents[1]
manifest=json.loads((ROOT/'asset_manifest.json').read_text(encoding='utf-8'))
assert len(manifest['variants'])==3
target=ROOT.parent/'练功石三款_重制_交付.zip'
with zipfile.ZipFile(target,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6)as archive:
    for file in sorted(ROOT.rglob('*')):
        if not file.is_file() or file.suffix not in {'.blend','.fbx','.glb','.rbxmx','.png','.py','.json','.md'}:continue
        if any(part.endswith('.fbm')for part in file.parts)or'__pycache__'in file.parts:continue
        archive.write(file,ROOT.name+'/'+file.relative_to(ROOT).as_posix())
with zipfile.ZipFile(target)as archive:
    assert archive.testzip()is None
    print({'archive':str(target),'files':len(archive.infolist()),'bytes':target.stat().st_size})
