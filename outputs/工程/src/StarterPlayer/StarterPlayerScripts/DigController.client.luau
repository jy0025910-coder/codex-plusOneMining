local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Shared = game.ReplicatedStorage:WaitForChild("Shared")
local Big = require(Shared.BigInteger)
local Balance = require(Shared.GameBalance)
local Style = require(Shared.MiningStyle)
require(Shared.MiningAnimator).Start()
local player=Players.LocalPlayer
local wire=game.ReplicatedStorage:WaitForChild("DigCamp")
local camp=workspace:WaitForChild("Gem Gulch")
local gui=player.PlayerGui:WaitForChild("FieldKit",30)
if not gui then warn("FieldKit did not replicate");return end
gui:ClearAllChildren()
local effects=require(Shared.MiningFeedback).new(gui,player)
local hudGui=player.PlayerGui:WaitForChild("MiningHUD",30)
if not hudGui then warn("MiningHUD did not replicate");return end
local hud=hudGui.Root
local drops=Instance.new("Folder");drops.Name="LocalMiningDrops";drops.Parent=workspace
local batchId=0
local dropObjects={}
local noticeId=0
local rainbow={}
local function announce(message)
    noticeId+=1
    local current=noticeId
    hud.Status.Toast.Text=message
    task.delay(3,function()if current==noticeId then hud.Status.Toast.Text="" end end)
end
local function clearDrops()
    drops:ClearAllChildren();table.clear(dropObjects);table.clear(rainbow)
end
local function refresh()
    local mine=camp:FindFirstChild("Mine")
    local route=player:GetAttribute("RouteIndex") or 1
    local profile=Balance.Routes[route]
    for i=1,10 do
        local room=mine and mine:FindFirstChild("Layer"..i)
        if not room then continue end
        local hp=player:GetAttribute("Gate"..i.."HP") or profile.Walls[i]
        local gate=room.Gate
        local open=hp=="0"
        gate.CanCollide=not open;gate.CanQuery=not open
        gate.LocalTransparencyModifier=open and 1 or 0
        gate.Color=Color3.fromHex(profile.Hex)
        for _,part in room:GetChildren() do
            if part.Name=="Gate seam" then part.LocalTransparencyModifier=open and 1 or 0 end
        end
        room["Gate label"].Lettering.Title.Text=profile.Label.." · 第 "..i.." 层\n"..(open and "已打通" or (Big.Format(hp).." / "..Big.Format(profile.Walls[i])))
        local track=room["Gate label"].Lettering:FindFirstChild("HealthTrack")
        if track then track.Fill.Size=UDim2.fromScale(math.clamp(tonumber(hp)/tonumber(profile.Walls[i]),0,1),1) end
    end
    local full=(player:GetAttribute("Ore")or 0)>=5
    local training=(player:GetAttribute("TrainingGain")or 0)>0
    hud.Status.Guide.Text=full and "背包满了 · 返回绿色光幕出售，再选择矿道进矿"
        or training and "正在训练 · 力量和经验同步增长，离开光幕停止"
        or "点击增加力量与经验 · 训练区自动敲 · 矿道入口选择矿道"
end
for _,key in {"Power","TrainingGain","Ore","RouteIndex","Overheated"} do player:GetAttributeChangedSignal(key):Connect(refresh) end
for i=1,10 do player:GetAttributeChangedSignal("Gate"..i.."HP"):Connect(refresh) end
hud.ReturnToCamp.Activated:Connect(function()wire.ReturnToCamp:FireServer()end)
local function practice(position)
    local inset=GuiService:GetGuiInset()
    effects:ClickRing(position-inset)
    wire.Practice:FireServer()
end
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 then practice(UIS:GetMouseLocation())
    elseif input.KeyCode==Enum.KeyCode.F or input.KeyCode==Enum.KeyCode.ButtonX then wire.Practice:FireServer() end
end)
UIS.TouchTapInWorld:Connect(function(position,processed)if not processed then practice(position) end end)
local function showDrops(id,items)
    clearDrops();batchId=id
    for index,item in items do
        local hidden=item.Secret~=nil
        local ore=not hidden and Balance.Minerals[item.Id]
        local color=hidden and Color3.fromRGB(209,129,252) or Color3.fromHex(ore.Hex)
        local holder=Instance.new("Model");holder.Name=hidden and Balance.Secrets[item.Secret].Name or ore.Name
        local visual=game.ReplicatedStorage.MiningVisualAssets.OreRock:Clone()
        visual.Name="Visual";visual:ScaleTo(hidden and .55 or .40)
        visual:PivotTo(CFrame.new(item.Position)*CFrame.Angles(0,index*.72,0))
        visual.Parent=holder
        for _,part in visual:GetDescendants() do
            if part:IsA("BasePart") then part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.Color=color end
        end
        local anchor=Instance.new("Part")
        anchor.Name="Pickup";anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true
        anchor.CanCollide=false;anchor.CanQuery=false;anchor.Position=item.Position+Vector3.new(0,1.3,0);anchor.Parent=holder
        local glow=Instance.new("Part")
        glow.Name="Glow";glow.Shape=Enum.PartType.Cylinder;glow.Size=Vector3.new(.08,2.8,2.8)
        glow.CFrame=CFrame.new(item.Position-Vector3.new(0,1.2,0))*CFrame.Angles(0,0,math.pi/2)
        glow.Color=hidden and color or ore.Rank>=8 and Color3.fromRGB(255,209,105) or Color3.fromRGB(203,231,230)
        glow.Material=Enum.Material.Neon;glow.Transparency=hidden and .45 or .75;glow.Anchored=true
        glow.CanCollide=false;glow.CanQuery=false;glow.CanTouch=false;glow.Parent=holder
        local light=Instance.new("PointLight");light.Range=8;light.Brightness=hidden and 1.5 or .35;light.Color=glow.Color;light.Parent=anchor
        local label=Instance.new("BillboardGui")
        label.Name="Price";label.Size=UDim2.fromScale(3.7,2);label.StudsOffset=Vector3.new(0,2,0);label.MaxDistance=75;label.Parent=anchor
        local text=Instance.new("TextLabel")
        text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextScaled=true;text.Font=Enum.Font.FredokaOne
        text.TextColor3=hidden and Color3.fromRGB(237,204,255) or Color3.fromRGB(255,245,211)
        text.TextStrokeColor3=Color3.fromRGB(24,40,50);text.TextStrokeTransparency=0
        text.Text=holder.Name.."\n"..(hidden and "隐藏发现" or (Big.Format(item.Value).." 币"))
        text.Parent=label
        local prompt=Instance.new("ProximityPrompt")
        prompt.ActionText="拾取";prompt.ObjectText=holder.Name;prompt.HoldDuration=0;prompt.RequiresLineOfSight=false
        prompt.MaxActivationDistance=9;prompt.Parent=anchor
        prompt.Triggered:Connect(function()wire.Action:FireServer("Pickup",id,index)end)
        holder.Parent=drops;dropObjects[index]=holder
        if hidden then table.insert(rainbow,{glow=glow,light=light}) end
    end
end
wire.Feedback.OnClientEvent:Connect(function(mode,a,b,c)
    if mode=="note" then announce(a)
    elseif mode=="sale" then announce("售出 "..b.." 块矿石 · +"..Big.Format(a).." 矿币")
    elseif mode=="practice" then effects:Power(Big.Format(b))
    elseif mode=="train" then effects:Stroke(a,Big.Format(b),c)
    elseif mode=="hit" then
        effects:Stroke(a,0,Style.AutoSwingSpeed)
        hud.Status.Target.Text="岩壁 "..Big.Format(b).." / "..Big.Format(c)
    elseif mode=="reveal" then showDrops(a,b)
    elseif mode=="clearDrops" then clearDrops()
    elseif mode=="pickup" and a==batchId then
        if dropObjects[b] then dropObjects[b]:Destroy();dropObjects[b]=nil end
    end
end)
local phase=0
Run.RenderStepped:Connect(function(dt)
    phase+=dt
    for _,record in rainbow do
        if record.glow.Parent then
            local color=Color3.fromHSV((phase*.15)%1,.5,1)
            record.glow.Color=color;record.light.Color=color
        end
    end
end)
local function view(character)
    local root=character:WaitForChild("HumanoidRootPart",10)
    if root and player.Character==character then
        task.wait(.2)
        workspace.CurrentCamera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,10,24),root.Position+Vector3.new(0,2,-5))
    end
end
player.CharacterAdded:Connect(view)
if player.Character then task.spawn(view,player.Character) end
refresh()
