-- Studio Edit-mode utility for this account's permanent, native-imported mesh assets.
-- Prefabs can also be inserted directly from IronPickaxe.rbxmx and SandstoneOre.rbxmx.
-- Another Roblox owner should import the GLBs under their account and update the registry.
local AssetService=game:GetService("AssetService")
local Registry=game:GetService("HttpService"):JSONDecode([==[{"SandstoneOre":[{"cf":[-0.12730392813682556,1.5122592449188232,1.631047248840332,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.003","id":"rbxassetid://90911214001208","material":"Metal","color":[0.7764706015586853,0.4745098054409027,0.26274511218070984],"size":[3.6679532527923584,1.9032806158065796,0.7786182165145874]},{"cf":[-0.12730392813682556,1.5969812870025635,1.631047248840332,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.0032","id":"rbxassetid://131164641494293","material":"Metal","color":[0.9098039269447327,0.6313725709915161,0.3686274588108063],"size":[3.6679532527923584,1.8422508239746094,0.7786182165145874]},{"cf":[-0.17025743424892426,1.5420782566070557,1.5739679336547852,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.0033","id":"rbxassetid://114804157657368","material":"Metal","color":[0.47058823704719543,0.3333333432674408,0.24313725531101227],"size":[3.831306219100952,2.012016773223877,0.7706670761108398]},{"cf":[-0.014265072531998158,1.3362736701965332,-0.13574790954589844,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere","id":"rbxassetid://103481504145292","material":"SmoothPlastic","color":[0.7882353067398071,0.5803921818733215,0.4274509847164154],"size":[5.485349655151367,2.6083383560180664,4.0640740394592285]},{"cf":[-0.07480240613222122,2.1108970642089844,-0.11003207415342331,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere2","id":"rbxassetid://135710007219358","material":"SmoothPlastic","color":[0.8627451062202454,0.6549019813537598,0.48627451062202454],"size":[5.320796966552734,2.1216180324554443,3.999701976776123]},{"cf":[-0.004306804854422808,1.3362736701965332,-0.13433170318603516,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere3","id":"rbxassetid://108369544029107","material":"SmoothPlastic","color":[0.7215686440467834,0.5215686559677124,0.3960784375667572],"size":[5.465435028076172,2.6083383560180664,4.06690788269043]},{"cf":[-0.016719825565814972,2.5999395847320557,-0.08974075317382812,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere4","id":"rbxassetid://111423440175368","material":"SmoothPlastic","color":[0.9058823585510254,0.7137255072593689,0.545098066329956],"size":[5.0514936447143555,2.1555423736572266,3.578716993331909]},{"cf":[-0.014265076257288456,1.273115634918213,-0.1772165298461914,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere5","id":"rbxassetid://117787009657391","material":"SmoothPlastic","color":[0.6627451181411743,0.48235294222831726,0.3764705955982208],"size":[5.485349655151367,2.482022285461426,3.9811370372772217]}],"IronPickaxe":[{"cf":[0.07499933242797852,1.870652416229248,-9.703841508112987e-09,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"IronHeadMesh","id":"rbxassetid://113435551451318","material":"SmoothPlastic","color":[0.36470588235294116,0.5686274509803921,0.7411764705882353],"size":[4.474999904632568,1.86619530916214,0.9620000749826432]},{"cf":[0.07499933242797852,1.771281078338623,-1.0595489106890456e-05,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"IronHeadMesh2","id":"rbxassetid://118577249175651","material":"SmoothPlastic","color":[0.8313725490196079,0.9254901960784314,1.0],"size":[4.474999904632568,1.6734377145767212,0.6188496172428132]},{"cf":[0.07499932311475277,1.4881978421211242,-0.16639620251953602,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"IronHeadMesh3","id":"rbxassetid://95090846946149","material":"SmoothPlastic","color":[0.20784313725490197,0.3411764705882353,0.47058823529411764],"size":[4.474999904632568,1.1033728122711182,0.2962063059210777]},{"cf":[0.014583301544189452,-0.025125462341308635,-0.00038995869399514047,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"LeatherWrapMesh","id":"rbxassetid://114434715381781","material":"SmoothPlastic","color":[1.0,0.7176470588235294,0.2627450980392157],"size":[0.5275279611349105,1.2732353210449219,0.4719120979309082]},{"cf":[-0.02099914290010929,0.9090999218940735,0.023534586653113365,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"WalnutShaftMesh","id":"rbxassetid://99107064360598","material":"SmoothPlastic","color":[0.6509803921568628,0.4117647058823529,0.2235294117647059],"size":[0.5102554202079773,3.6581999826431275,0.3742845177650451]},{"cf":[-0.020999148115515707,0.9090999218940735,-0.023526570573449132,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"WalnutShaftMesh2","id":"rbxassetid://101616529106124","material":"SmoothPlastic","color":[0.7686274509803922,0.5372549019607843,0.29411764705882354],"size":[0.5102554202079773,3.6581999826431275,0.3743002891540527]},{"cf":[-0.046487045288085935,0.9090999218940735,-5.336512140274862e-06,-1,0,-8.742277657347586e-08,0,1,0,8.742277657347586e-08,0,-1],"name":"WalnutShaftMesh3","id":"rbxassetid://112247525006348","material":"SmoothPlastic","color":[0.5019607843137255,0.3137254901960784,0.17647058823529413],"size":[0.35511276721954343,3.6581999826431275,0.42134275436401364]}]}]==])
local assets=assert(game.ServerStorage:FindFirstChild("GameAssets"),"Insert GameAssets first")
local function folder(name)
    local f=assets:FindFirstChild(name)
    if not f then f=Instance.new("Folder");f.Name=name;f.Parent=assets end
    return f
end
local function build(parent,rows,handle)
    for _,r in rows do
        local p=AssetService:CreateMeshPartAsync(Content.fromUri(r.id))
        p.Name=r.name;p.Size=Vector3.new(table.unpack(r.size));p.CFrame=CFrame.new(table.unpack(r.cf))
        p.Color=Color3.new(table.unpack(r.color));p.Material=Enum.Material[r.material]
        p.Anchored=handle==nil;p.Massless=handle~=nil
        p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
        p:SetAttribute("BlenderSource","MiningAssets.blend")
        if r.role then p:SetAttribute("MeshRole",r.role);p:SetAttribute("BaseColor",p.Color)end
        p.Parent=parent
        if handle then local w=Instance.new("WeldConstraint");w.Part0=handle;w.Part1=p;w.Parent=p end
        task.wait()
    end
end
local tool=Instance.new("Tool");tool.Name="IronPickaxe";tool.ToolTip="铁镐";tool.CanBeDropped=false
 tool.Grip=CFrame.Angles(0,math.pi/2,0);tool:SetAttribute("AssetId","Tool.IronPickaxe");tool:SetAttribute("AssetVersion",2)
local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.23,.3,.23);h.Transparency=1;h.Massless=true
h.CanCollide=false;h.CanTouch=false;h.CanQuery=false;h.Parent=tool
build(tool,Registry.IronPickaxe,h)
local rock=Instance.new("Model");rock.Name="SandstoneOre";rock:SetAttribute("AssetId","Rock.SandstoneOre");rock:SetAttribute("AssetVersion",1)
local pivot=Instance.new("Part");pivot.Name="AssetPivot";pivot.Size=Vector3.one*.1;pivot.Transparency=1;pivot.Anchored=true
pivot.CanCollide=false;pivot.CanTouch=false;pivot.CanQuery=false;pivot.Parent=rock;rock.PrimaryPart=pivot
build(rock,Registry.SandstoneOre)
for _,pair in {{folder("Tools"),tool},{folder("Ores"),rock}}do
    local old=pair[1]:FindFirstChild(pair[2].Name)
    pair[2].Parent=pair[1]
    if old then old:Destroy()end
end
return "Mining prefabs rebuilt"
