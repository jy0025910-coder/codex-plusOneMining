"""Move HUD ownership to the authored GUI while preserving mining and input code."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parents[3]
path=PROJECT/'outputs/工程/src/StarterPlayer/StarterPlayerScripts/DigController.client.luau'
source=path.read_text(encoding='utf8')
if 'local hud=p:' in source:
    print('Already migrated');raise SystemExit
(PROJECT/'work/hud_before/DigController.client.luau').write_text(source,encoding='utf8')
source=source.replace('local catalog=require(game.ReplicatedStorage.Shared.OreCatalog)\n','')
start=source.index('local function text(')
end=source.index('local function refresh()')
source=source[:start]+'''local hud=p:WaitForChild("PlayerGui"):WaitForChild("MiningHUD"):WaitForChild("Root")
local guide=hud.Status.Guide
local toast=hud.Status.Toast
local targetText=hud.Status.Target
hud.ReturnToCamp.Activated:Connect(function()wire.ReturnToCamp:FireServer()end)
'''+source[end:]
start=source.index('    power.Text=')
end=source.index('    guide.Text=',start)
source=source[:start]+source[end:]
source=source.replace('for i=1,5 do inv:WaitForChild("Slot"..i).Changed:Connect(refresh)end\n','')
start=source.index('local function resize()')
end=source.index('resize();refresh()',start)+len('resize();refresh()')
source=source[:start]+'refresh()'+source[end:]
source=source.replace('    local value=p:GetAttribute("Power")or 1\n','').replace('    local coins=p:GetAttribute("Coins")or 0\n','')
path.write_text(source,encoding='utf8',newline='\n')
print('Preserved mining input and gate/impact behavior; HUD shell now comes from StarterGui.MiningHUD.')
