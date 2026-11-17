local Config = require(game.ReplicatedStorage.Shared.PrototypeConfig)
local Balance = require(game.ReplicatedStorage.Shared.GameBalance)
local Big = require(game.ReplicatedStorage.Shared.BigInteger)
local Visuals = require(script.Parent.ZoneVisuals)
local Factory = require(script.Parent.MiningAssets)
local World = {}
local function part(parent,name,size,cf,color,solid)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true
    p.CanCollide=solid==true;p.CanTouch=false;p.CanQuery=solid==true
    p.Material=Enum.Material.SmoothPlastic;p.Parent=parent
    return p
end
local function label(parent,name,position,text)
    local anchor=part(parent,name,Vector3.new(.1,.1,.1),CFrame.new(position),Color3.new(1,1,1))
    anchor.Transparency=1
    local gui=Instance.new("BillboardGui")
    gui.Name="Lettering";gui.Size=name:match("^Name") and UDim2.fromScale(9,2.8) or UDim2.fromScale(16,3.1);gui.MaxDistance=95;gui.LightInfluence=0;gui.Parent=anchor
    local title=Instance.new("TextLabel")
    title.Name="Title";title.Size=UDim2.fromScale(1,1);title.BackgroundTransparency=1
    title.Font=Enum.Font.FredokaOne;title.TextScaled=true;title.TextColor3=Color3.fromRGB(255,242,207)
    title.TextStrokeColor3=Color3.fromRGB(35,41,48);title.TextStrokeTransparency=.1;title.Text=text;title.Parent=gui
    return anchor
end
function World.Build(camp)
    if camp:GetAttribute("CoreWorldVersion")==1 then return camp end
    local oldMine=camp:FindFirstChild("Mine")
    assert(oldMine and oldMine:FindFirstChild("Layer1"),"Missing mine template")
    local roomTemplate=oldMine.Layer1:Clone()
    local origin=roomTemplate.Gate.Position
    local newMine=Instance.new("Model");newMine.Name="Mine"
    for i=1,10 do
        local room=roomTemplate:Clone();room.Name="Layer"..i
        local delta=Vector3.new(0,0,-(i-1)*34)
        for _,o in room:GetDescendants() do
            if o:IsA("BasePart") then o.CFrame+=delta end
        end
        for _,child in room:GetChildren() do
            if child.Name:match("^OreNode") then child:Destroy() end
        end
        local gate=room.Gate
        gate:SetAttribute("LayerIndex",i);gate:SetAttribute("MaxHealth",Balance.Routes[1].Walls[i])
        gate:SetAttribute("TargetKind","Gate");gate:AddTag("MineTarget")
        room:SetAttribute("LayerIndex",i)
        room["Gate label"].Lettering.Title.Text="第 "..i.." 层\n岩壁 "..Big.Format(Balance.Routes[1].Walls[i])
        local lettering=room["Gate label"].Lettering
        lettering.Title.Size=UDim2.fromScale(1,.72)
        local track=Instance.new("Frame");track.Name="HealthTrack";track.Position=UDim2.fromScale(.1,.78)
        track.Size=UDim2.fromScale(.8,.12);track.BackgroundColor3=Color3.fromRGB(36,41,48);track.BorderSizePixel=0;track.Parent=lettering
        local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(1,1)
        fill.BorderSizePixel=0;fill.BackgroundColor3=Color3.fromRGB(255,199,80);fill.Parent=track
        room.Parent=newMine
        task.wait()
    end
    roomTemplate:Destroy()
    oldMine:Destroy()
    newMine.Parent=camp
    part(newMine,"FinalBoundary",Vector3.new(32,17,3),CFrame.new(origin+Vector3.new(0,3,-340)),Color3.fromRGB(91,91,104),true)
    label(newMine,"FinalSign",origin+Vector3.new(0,3,-332),"本矿道勘探完成 · 返回出售")
    local selections=Instance.new("Folder");selections.Name="MineEntrances";selections.Parent=camp
    for i,route in Balance.Routes do
        local pos=Vector3.new((i-3)*10,2,-56)
        local panel=part(selections,"Entrance"..i,Vector3.new(8,4,.5),CFrame.new(pos),Color3.fromHex(route.Hex),true)
        panel:SetAttribute("RouteIndex",i)
        label(selections,"Name"..i,pos+Vector3.new(0,3,0),route.Label.."矿道\n"..(route.Required==0 and "直接进入" or "重生 "..route.Required.." 次"))
        local prompt=Instance.new("ProximityPrompt")
        prompt.Name="ChooseMine";prompt.ActionText="选择矿道";prompt.ObjectText=route.Name
        prompt.MaxActivationDistance=11;prompt.RequiresLineOfSight=false;prompt.Parent=panel
    end
    if camp:FindFirstChild("Training") then camp.Training:Destroy() end
    local training=Instance.new("Model");training.Name="Training";training.Parent=camp
    for i,area in Balance.Trainings do
        local column=(i-1)%2;local row=math.floor((i-1)/2)
        local pos=Vector3.new(-68+column*21,.65,38-row*29)
        local profile=Config.Trainings[(i-1)%3+1]
        local holder=Instance.new("Model");holder.Name="TrainingRock"..i;holder:SetAttribute("TrainingIndex",i)
        holder.Parent=training
        local visual=Factory.CreateTrainingRockVisual(holder,CFrame.new(pos)*CFrame.Angles(0,-math.pi/2,0),{
            PracticeAsset=profile.PracticeAsset,PracticeScale=.85})
        local bounds,size=visual:GetBoundingBox()
        local target=part(holder,"Target",size,bounds,profile.Color,false)
        target.Transparency=1;target.CanQuery=true;target:SetAttribute("TargetKind","Training")
        target:SetAttribute("TrainingIndex",i);target:SetAttribute("ImpactColor",profile.Color);target:SetAttribute("LargeImpact",true)
        target:AddTag("TrainingTarget")
        local collider=part(holder,"Collider",Vector3.new(size.X*.70,size.Y*.80,size.Z*.70),bounds,profile.Color,true)
        collider.Transparency=1
        local zone=Visuals.Create(training,"TrainingPad"..i,CFrame.new(pos+Vector3.new(0,-.15,0)),{
            Scale=1.4,Color=profile.Color,Tag="TrainingZone",Attributes={
                TrainingIndex=i,Gain=area.Multiplier,RequiredRebirth=area.Required,RequiredPower=0}})
        label(holder,"Training label",pos+Vector3.new(0,8.5,0),area.Multiplier.."× 力量训练\n"..(area.Required==0 and "开放" or "需重生 "..area.Required.." 次"))
        part(training,"PadBase"..i,Vector3.new(18,.25,22),CFrame.new(pos-Vector3.new(0,.5,0)),Color3.fromRGB(140,150,145),true)
        task.wait()
    end
    local public=game.ReplicatedStorage:FindFirstChild("MiningVisualAssets")
    if not public then public=Instance.new("Folder");public.Name="MiningVisualAssets";public.Parent=game.ReplicatedStorage end
    if not public:FindFirstChild("OreRock") then
        local ore=game.ServerStorage.GameAssets.Ores.SandstoneOre:Clone()
        ore.Name="OreRock"
        for _,o in ore:GetDescendants() do if o:IsA("BasePart") then o.Anchored=true;o.CanCollide=false;o.CanQuery=false;o.CanTouch=false end end
        ore.Parent=public
    end
    camp.ToolShop.Upgrade.Interact.ActionText="打开镐子商店"
    camp:SetAttribute("CoreWorldVersion",1)
    return camp
end
return World
