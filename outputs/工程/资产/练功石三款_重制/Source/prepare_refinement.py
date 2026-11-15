"""Keep the accepted before views and record the unchanged blue variant."""
from pathlib import Path
import shutil,hashlib,json
ROOT=Path(__file__).resolve().parents[1]
backup=ROOT.parents[3]/'work'/'rock_refinement_20261115_before'
backup.mkdir(parents=True,exist_ok=True)
for name in ['PracticeRock_A_Classic','PracticeRock_C_Layered']:
    for relative in [Path('Source')/(name+'.blend'),Path('Renders')/(name+'_Hero.png')]:
        target=backup/relative;target.parent.mkdir(exist_ok=True)
        if not target.exists():shutil.copy2(ROOT/relative,target)
for filename in ['build_rocks.py','variant_profiles.json']:
    target=backup/'Source'/filename
    if not target.exists():shutil.copy2(ROOT/'Source'/filename,target)
hashes={}
for folder in ['Source','Exports','Textures','Renders']:
    for file in (ROOT/folder).glob('PracticeRock_B_Rune*'):
        if file.is_file()and file.suffix in ['.blend','.fbx','.glb','.png']:
            hashes[file.relative_to(ROOT).as_posix()]=hashlib.sha256(file.read_bytes()).hexdigest()
(backup/'blue_variant_sha256.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
print({'backup':str(backup),'blue_files_recorded':len(hashes)})
