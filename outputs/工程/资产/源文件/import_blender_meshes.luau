-- Studio Edit-mode utility for this account's permanent, native-imported mesh assets.
-- Prefabs can also be inserted directly from IronPickaxe.rbxmx and SandstoneOre.rbxmx.
-- Another Roblox owner should import the GLBs under their account and update the registry.
local AssetService=game:GetService("AssetService")
local Registry=game:GetService("HttpService"):JSONDecode([==[{"SandstoneOre":[{"cf":[-0.12730392813682557,1.5122592449188233,1.631047248840332,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.003","id":"rbxassetid://90911214001208","material":"Metal","color":[0.7764706015586853,0.4745098054409027,0.26274511218070986],"size":[3.6679532527923586,1.9032806158065797,0.7786182165145874]},{"cf":[-0.12730392813682557,1.5969812870025635,1.631047248840332,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.0032","id":"rbxassetid://131164641494293","material":"Metal","color":[0.9098039269447327,0.6313725709915161,0.3686274588108063],"size":[3.6679532527923586,1.8422508239746094,0.7786182165145874]},{"cf":[-0.17025743424892426,1.5420782566070557,1.5739679336547852,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"Inclusions","name":"Inclusions_Icosphere.0033","id":"rbxassetid://114804157657368","material":"Metal","color":[0.47058823704719546,0.3333333432674408,0.24313725531101228],"size":[3.831306219100952,2.012016773223877,0.7706670761108398]},{"cf":[-0.014265072531998158,1.3362736701965333,-0.13574790954589845,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere","id":"rbxassetid://103481504145292","material":"SmoothPlastic","color":[0.7882353067398071,0.5803921818733215,0.4274509847164154],"size":[5.485349655151367,2.6083383560180666,4.0640740394592289]},{"cf":[-0.07480240613222122,2.1108970642089845,-0.11003207415342331,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere2","id":"rbxassetid://135710007219358","material":"SmoothPlastic","color":[0.8627451062202454,0.6549019813537598,0.48627451062202456],"size":[5.320796966552734,2.1216180324554445,3.999701976776123]},{"cf":[-0.004306804854422808,1.3362736701965333,-0.13433170318603517,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere3","id":"rbxassetid://108369544029107","material":"SmoothPlastic","color":[0.7215686440467835,0.5215686559677124,0.3960784375667572],"size":[5.465435028076172,2.6083383560180666,4.06690788269043]},{"cf":[-0.016719825565814973,2.5999395847320558,-0.08974075317382813,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere4","id":"rbxassetid://111423440175368","material":"SmoothPlastic","color":[0.9058823585510254,0.7137255072593689,0.545098066329956],"size":[5.0514936447143559,2.1555423736572267,3.578716993331909]},{"cf":[-0.014265076257288456,1.273115634918213,-0.1772165298461914,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"role":"StoneBody","name":"StoneBody_Icosphere5","id":"rbxassetid://117787009657391","material":"SmoothPlastic","color":[0.6627451181411743,0.48235294222831728,0.3764705955982208],"size":[5.485349655151367,2.482022285461426,3.9811370372772219]}],"IronPickaxe":[{"cf":[0.05999946594238281,2.253816604614258,-5.245319734115128e-9,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"IronHeadMesh","id":"rbxassetid://113435551451318","material":"Metal","color":[0.40784314274787905,0.4745098054409027,0.5372549295425415],"size":[3.5799999237060549,1.3823668956756592,0.5200000405311585]},{"cf":[0.05999946594238281,2.180208206176758,-0.000005727291409129975,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"IronHeadMesh2","id":"rbxassetid://118577249175651","material":"Metal","color":[0.7137255072593689,0.7803921699523926,0.8235294222831726],"size":[3.5799999237060549,1.2395834922790528,0.3345133066177368]},{"cf":[0.059999458491802219,1.9705169200897217,-0.08994389325380326,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"IronHeadMesh3","id":"rbxassetid://95090846946149","material":"Metal","color":[0.2235294133424759,0.26274511218070986,0.30588236451148989],"size":[3.5799999237060549,0.8173131942749023,0.16011151671409608]},{"cf":[0.010057449340820313,-0.039922356605529788,-0.0002689370303414762,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"LeatherWrapMesh","id":"rbxassetid://114434715381781","material":"SmoothPlastic","color":[0.7882353067398071,0.5411764979362488,0.21960784494876862],"size":[0.3638123869895935,1.326286792755127,0.3254566192626953]},{"cf":[-0.01499938778579235,1.0899999141693116,0.016810419037938119,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"WalnutShaftMesh","id":"rbxassetid://99107064360598","material":"SmoothPlastic","color":[0.4745098054409027,0.29019609093666079,0.1764705926179886],"size":[0.36446815729141238,4.019999980926514,0.2673460841178894]},{"cf":[-0.01499939151108265,1.0899999141693116,-0.016804693266749383,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"WalnutShaftMesh2","id":"rbxassetid://101616529106124","material":"SmoothPlastic","color":[0.5843137502670288,0.3803921639919281,0.23529411852359773],"size":[0.36446815729141238,4.019999980926514,0.26735734939575198]},{"cf":[-0.03320503234863281,1.0899999141693116,-0.0000038117943859106164,-1,0,-8.742277657347586e-8,0,1,0,8.742277657347586e-8,0,-1],"name":"WalnutShaftMesh3","id":"rbxassetid://112247525006348","material":"SmoothPlastic","color":[0.35686275362968447,0.2235294133424759,0.1568627506494522],"size":[0.2536519765853882,4.019999980926514,0.30095911026000979]}]}]==])
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
 tool.Grip=CFrame.Angles(0,0,math.rad(8));tool:SetAttribute("AssetId","Tool.IronPickaxe");tool:SetAttribute("AssetVersion",1)
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
