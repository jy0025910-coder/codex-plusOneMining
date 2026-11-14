local Config = require(game.ReplicatedStorage.Shared.PrototypeConfig)
local Visuals = require(script.Parent.ZoneVisuals)
local Factory = require(script.Parent.MerchantAssets)
local assets = game.ServerStorage.GameAssets
local MiningAssets = require(script.Parent.MiningAssets)
local Builder = {}
local V, C = Vector3.new, CFrame.new
local sand = Color3.fromRGB(218,177,119)
local rock = Color3.fromRGB(178,117,77)
local slate = Color3.fromRGB(99,105,105)
local cream = Color3.fromRGB(255,239,194)

local function model(parent,name)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent
    return m
end
local function part(parent,name,size,cf,color,solid,material)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=solid==true
    p.CanTouch=false
    p.CanQuery=solid==true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function label(parent,name,cf,size,caption,color)
    local anchor=part(parent,name,V(.1,.1,.1),cf,cream)
    anchor.Transparency=1
    anchor.CanQuery=false
    local gui=Instance.new("BillboardGui")
    gui.Name="Lettering"
    gui.Size=UDim2.fromScale(size.X,size.Y)
    gui.MaxDistance=100
    gui.LightInfluence=0
    gui.Parent=anchor
    local text=Instance.new("TextLabel")
    text.Name="Title"
    text.Size=UDim2.fromScale(1,1)
    text.BackgroundTransparency=1
    text.Font=Enum.Font.GothamBold
    text.TextScaled=true
    text.Text=caption
    text.TextColor3=color or cream
    text.TextStrokeColor3=Color3.fromRGB(54,45,37)
    text.TextStrokeTransparency=.15
    text.Parent=gui
    return text
end
local function lamp(parent,x,z)
    part(parent,"Lantern foot",V(1,.3,1),C(x,.15,z),slate,true)
    part(parent,"Lantern post",V(.32,2.2,.32),C(x,1.4,z),slate,true)
    local glass=part(parent,"Warm lamp",V(.65,.8,.65),C(x,2.7,z),cream,false,Enum.Material.Neon)
    part(parent,"Lantern cap",V(.9,.18,.9),C(x,3.2,z),slate)
    local light=Instance.new("PointLight")
    light.Color=Color3.fromRGB(255,210,134)
    light.Brightness=.7
    light.Range=12
    light.Parent=glass
end
local function ore(parent,name,pos,color,crystal)
    local m=model(parent,name)
    local main=part(m,"Target",V(4.8,3.8,4.2),C(pos+V(0,2.2,0)),color,true)
    m.PrimaryPart=main
    local index=tonumber(name:match("%d+")) or 1
    MiningAssets.ReplaceRock(m,index,name:find("TrainingRock")~=nil,color)
    return m,main
end
local function board(parent,x,title,color,kind)
    local m=model(parent,kind)
    local panel=part(m,"Board",V(10,12,.5),C(x,7.1,4)*CFrame.Angles(0,-.16,0),color,true)
    local surface=Instance.new("SurfaceGui")
    surface.Name="Scores"
    surface.Face=Enum.NormalId.Back
    surface.CanvasSize=Vector2.new(540,660)
    surface.LightInfluence=0
    surface.Parent=panel
    local frame=Instance.new("Frame")
    frame.Size=UDim2.fromScale(1,1)
    frame.BackgroundColor3=Color3.fromRGB(38,57,60)
    frame.BorderSizePixel=8
    frame.BorderColor3=color
    frame.Parent=surface
    for i=0,6 do
        local t=Instance.new("TextLabel")
        t.Name=i==0 and "Title" or "Row"..i
        t.Position=UDim2.fromOffset(22,18+i*86)
        t.Size=UDim2.fromOffset(496,i==0 and 70 or 64)
        t.BackgroundTransparency=1
        t.TextColor3=i==0 and color or cream
        t.Font=Enum.Font.GothamBold
        t.TextScaled=true
        t.Text=i==0 and title or (i==1 and "等待矿工上榜" or "")
        t.Parent=frame
    end
    panel:SetAttribute("BoardStat",kind)
    panel:AddTag("CampLeaderboard")
    for _,dx in {-3.5,3.5}do part(m,"Board leg",V(.5,2,.6),C(x+dx,1,4),slate,true)end
end

function Builder.Build()
    local existing=workspace:FindFirstChild("Gem Gulch")
    if existing and existing:GetAttribute("PrototypeVersion")==Config.Version then return existing end
    local town=model(nil,"Gem Gulch")
    town:SetAttribute("AssetId","World.CanyonTown")
    town:SetAttribute("PrototypeVersion",Config.Version)
    local floor=part(town,"Desert floor",V(130,2,245),C(0,-1,-53),sand,true,Enum.Material.Sand)
    town.PrimaryPart=floor
    local paving=model(town,"Sandstone paving")
    -- Warm grey sandstone slabs form a clear plaza with alternating long joints.
    for row=0,13 do
        for col=0,17 do
            local x=-51+col*6
            local z=-24+row*5
            local brightness=(row+col)%3*5
            part(paving,"Sandstone slab",V(5.91,.16,4.91),C(x,.08,z),Color3.fromRGB(173+brightness,164+brightness,144+brightness),true)
        end
    end
    local landscaping=model(town,"Canyon rim")
    for _,side in {-1,1} do
        for i=0,8 do
            local z=42-i*10
            local h=14+(i%3)*4
            part(landscaping,"Sandstone cliff",V(11,h,10.3),C(side*61,h/2,z),rock,true,Enum.Material.Sandstone)
            part(landscaping,"Cliff cap",V(11.4,.7,10.5),C(side*61,h+.2,z),sand,true)
        end
    end
    -- At the rear, the canyon opens into one narrow mine.
    for _,x in {-39,39}do
        part(landscaping,"Mine shoulder",V(44,24,12),C(x,12,-30),rock,true,Enum.Material.Sandstone)
        part(landscaping,"Mine shoulder cap",V(45,1,13),C(x,24,-30),sand,true)
    end
    part(landscaping,"Mine lintel cliff",V(30,9,12),C(0,21,-30),rock,true,Enum.Material.Sandstone)
    local spawn=Instance.new("SpawnLocation")
    spawn.Name="Arrival"
    spawn.Size=V(7,.2,6)
    spawn.CFrame=C(0,.25,36)
    spawn.Anchored=true
    spawn.Neutral=true
    spawn.Transparency=1
    spawn.CanCollide=false
    spawn.Duration=0
    spawn.Parent=town
    label(town,"Hub title",C(0,11,34),Vector2.new(18,2),"晶脉峡谷  ·  矿工休息站")
    local buyer=assets.Stations.OreBuyer:Clone()
    buyer.Name="OreBuyer"
    buyer:PivotTo(C(-17,.18,27))
    buyer.Parent=town
    -- Reuse the existing NPC and counter contract for the tool store.
    local shop=Factory.CreateStall(town,"ToolShop",C(17,.18,27),{Title="镐子铺",Canopy=Color3.fromRGB(66,173,212),Accent=Color3.fromRGB(70,121,132)})
    Factory.AttachMerchant(shop)
    local upgrade=part(shop,"Upgrade",V(.2,.2,.2),C(17,3.5,30),cream)
    upgrade.Transparency=1
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="Interact";prompt.ActionText="升级工具 · 16 金币";prompt.ObjectText="镐子铺";prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=upgrade
    Visuals.Create(shop,"ShopZone",C(17,.18,35),{Color=Color3.fromRGB(61,190,245)})
    local training=model(town,"Training")
    label(training,"Training title",C(-34,11,8),Vector2.new(17,2),"训练矿场",Color3.fromRGB(138,230,228))
    for i,cfg in Config.Trainings do
        local z=18-(i-1)*14
        local pad=Visuals.Create(training,"TrainingPad"..i,C(-35,.19,z),{
            Color=cfg.Color,Tag="TrainingZone",Attributes={TrainingIndex=i,Gain=cfg.Gain,RequiredPower=cfg.Required},
        })
        local m,target=ore(training,"TrainingRock"..i,V(-35,.2,z),cfg.Color,i>1)
        target.CanQuery=true
        m:SetAttribute("TrainingIndex",i)
        label(m,"Training label",C(-35,7.7,z),Vector2.new(13,2.2),cfg.Name.."\n+"..cfg.Gain.." 力量 / 次"..(cfg.Required>0 and (" · 需 "..cfg.Required) or ""))
    end
    local rankings=model(town,"Rankings")
    label(rankings,"Rank title",C(34,16,1),Vector2.new(18,2),"矿工荣誉榜",Color3.fromRGB(255,209,110))
    board(rankings,27,"力量榜",Color3.fromRGB(255,198,84),"Power")
    board(rankings,40,"金币榜",Color3.fromRGB(93,221,156),"Coins")
    label(rankings,"Board scope",C(34,1,12),Vector2.new(16,1),"当前服务器")
    local mine=model(town,"Mine")
    label(mine,"Mine title",C(0,15,-23),Vector2.new(22,2.4),"深入矿洞",cream)
    for _,x in {-13.5,13.5}do
        part(mine,"Entrance timber",V(1.2,13,1.3),C(x,6.5,-23),Color3.fromRGB(113,76,48),true)
    end
    part(mine,"Entrance beam",V(29,1.2,1.5),C(0,13,-23),Color3.fromRGB(139,96,59),true)
    for i,cfg in Config.Layers do
        local front=-25-(i-1)*34
        local room=model(mine,"Layer"..i)
        room:SetAttribute("LayerIndex",i)
        room:SetAttribute("RareChance",cfg.RareChance)
        part(room,"Cave floor",V(28,.3,34),C(0,.1,front-17),Color3.fromRGB(134-i*9,126-i*8,108-i*6),true,Enum.Material.Slate)
        for _,side in {-1,1}do
            part(room,"Cave side",V(3,15,34),C(side*15,7.5,front-17),rock:Lerp(slate,.3+i*.1),true,Enum.Material.Sandstone)
            for j=0,2 do part(room,"Rock rib",V(2,12,3),C(side*13.8,6,front-7-j*10),Color3.fromRGB(125,102,83),true)end
        end
        part(room,"Cave ceiling",V(33,2,34),C(0,15,front-17),Color3.fromRGB(106,91,77),true,Enum.Material.Slate)
        local wall=part(room,"Gate",V(26,11,1.4),C(0,5.5,front),cfg.Color,true,Enum.Material.Sandstone)
        wall:SetAttribute("TargetKind","Gate")
        wall:SetAttribute("LayerIndex",i)
        wall:SetAttribute("MaxHealth",cfg.WallHealth)
        wall:AddTag("MineTarget")
        for j=-3,3 do part(room,"Gate seam",V(.055,10,.04),C(j*3.4,5.5,front+.72),cfg.Color:Lerp(Color3.new(0,0,0),.2))end
        label(room,"Gate label",C(0,11.8,front+1),Vector2.new(23,2.8),"第 "..i.." 层 · "..cfg.Name.."\n岩壁耐久 "..cfg.WallHealth.."  |  稀有矿 "..math.round(cfg.RareChance*100).."%",cream)
        for j=1,3 do
            local x=({-8,7,-6})[j]
            local z=front-9-(j-1)*8
            local m,target=ore(room,"OreNode"..j,V(x,.25,z),cfg.Color,true)
            target:SetAttribute("TargetKind","Ore")
            target:SetAttribute("LayerIndex",i)
            target:SetAttribute("MaxHealth",cfg.OreHealth)
            target:AddTag("MineTarget")
            for _,p in m:GetDescendants()do if p:IsA("BasePart")then p:SetAttribute("TargetRoot",target.Name)end end
            label(m,"Ore label",C(x,6.5,z),Vector2.new(9,1.3),"矿脉 · "..cfg.OreHealth.." 耐久")
        end
        for _,x in {-11,11}do lamp(room,x,front-13)end
    end
    part(mine,"Deep rock end",V(30,15,3),C(0,7.5,-128),slate,true,Enum.Material.Slate)
    label(mine,"Demo end",C(0,5,-123),Vector2.new(20,2),"已到达本次勘探终点")
    for _,p in {{-10,32},{10,32},{-10,15},{10,15},{-10,-7},{10,-7},{-22,5},{22,15}}do lamp(town,p[1],p[2])end
    local old=workspace:FindFirstChild("Gem Gulch")
    town.Parent=workspace
    if old then old:Destroy()end
    return town
end

return Builder
