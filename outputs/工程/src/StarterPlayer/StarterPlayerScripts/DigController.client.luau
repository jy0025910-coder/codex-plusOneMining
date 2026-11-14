local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Collection=game:GetService("CollectionService")
local p=Players.LocalPlayer
local wire=game.ReplicatedStorage:WaitForChild("DigCamp")
local cfg=require(game.ReplicatedStorage.Shared.PrototypeConfig)
local catalog=require(game.ReplicatedStorage.Shared.OreCatalog)
local camp=workspace:WaitForChild("Gem Gulch")
local gui=p:WaitForChild("PlayerGui"):WaitForChild("FieldKit")
gui:ClearAllChildren()
gui.ResetOnSpawn=false
local function text(name,parent,size,pos,fontSize)
    local t=Instance.new("TextLabel")
    t.Name=name;t.Size=size;t.Position=pos
    t.BackgroundTransparency=1;t.TextColor3=Color3.fromRGB(255,241,210)
    t.Font=Enum.Font.GothamBold;t.TextSize=fontSize or 20
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.Parent=parent
    return t
end
local panel=Instance.new("Frame")
panel.Name="MiningHUD";panel.Position=UDim2.fromOffset(16,16);panel.Size=UDim2.fromOffset(320,159)
panel.BackgroundColor3=Color3.fromRGB(31,60,65);panel.BackgroundTransparency=.08;panel.BorderSizePixel=0;panel.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=panel
local scale=Instance.new("UIScale");scale.Parent=panel
local title=text("Title",panel,UDim2.fromOffset(290,26),UDim2.fromOffset(15,10),14);title.Text="晶脉峡谷  /  矿工休息站"
local power=text("Power",panel,UDim2.fromOffset(290,31),UDim2.fromOffset(15,41),24)
local bag=text("Bag",panel,UDim2.fromOffset(290,27),UDim2.fromOffset(15,76),18)
local depth=text("Depth",panel,UDim2.fromOffset(290,24),UDim2.fromOffset(15,107),16)
local slots=text("Slots",gui,UDim2.fromOffset(650,34),UDim2.fromOffset(18,183),14)
slots.TextStrokeTransparency=.35;slots.TextStrokeColor3=Color3.fromRGB(25,45,47)
local guide=text("Guide",gui,UDim2.fromOffset(660,56),UDim2.new(.5,-330,1,-81),17)
guide.TextXAlignment=Enum.TextXAlignment.Center;guide.TextStrokeTransparency=.25
guide.BackgroundColor3=Color3.fromRGB(31,60,65);guide.BackgroundTransparency=.08
local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=guide
local toast=text("Toast",gui,UDim2.fromOffset(620,44),UDim2.new(.5,-310,.18,0),22)
toast.TextXAlignment=Enum.TextXAlignment.Center;toast.TextStrokeTransparency=.25;toast.Text=""
local targetText=text("Target",gui,UDim2.fromOffset(600,36),UDim2.new(.5,-300,.73,0),21)
targetText.TextXAlignment=Enum.TextXAlignment.Center;targetText.TextStrokeTransparency=.2;targetText.Text=""
local returnButton=Instance.new("TextButton")
returnButton.Name="ReturnToCamp";returnButton.Size=UDim2.fromOffset(138,42);returnButton.Position=UDim2.new(1,-155,0,18)
returnButton.Text="返回休息站";returnButton.Font=Enum.Font.GothamBold;returnButton.TextSize=17;returnButton.BackgroundColor3=Color3.fromRGB(47,103,111);returnButton.TextColor3=Color3.fromRGB(255,239,203);returnButton.Parent=gui
local buttonCorner=Instance.new("UICorner");buttonCorner.CornerRadius=UDim.new(0,10);buttonCorner.Parent=returnButton
returnButton.Activated:Connect(function()wire.ReturnToCamp:FireServer()end)
local inv=p:WaitForChild("OreInventory")
local function refresh()
    local value=p:GetAttribute("Power")or 1
    local training=p:GetAttribute("TrainingGain")or 0
    local coins=p:GetAttribute("Coins")or 0
    local count=p:GetAttribute("Ore")or 0
    power.Text="力量 "..value..(training>0 and ("  ·  自动训练 +"..training) or "")
    bag.Text="背包 "..count.."/5     金币 "..coins
    depth.Text="已打通 "..(p:GetAttribute("DeepestLayer")or 0).."/"..#cfg.Layers.." 层"
    local names={}
    for i=1,5 do
        local item=inv:FindFirstChild("Slot"..i)
        local ore=item and catalog.Items[item.Value]
        table.insert(names,ore and (ore.Name.." "..ore.Value.."金")or "空格")
    end
    slots.Text=table.concat(names,"  |  ")
    guide.Text=count>=5 and "背包满了 · 返回摊位，走进绿色光幕出售" or training>0 and "正在自动敲矿训练 · 离开光幕即可停止" or "左侧训练增长力量  ·  前方敲墙进入矿洞  ·  点击 / F 键敲击"
    for i=1,#cfg.Layers do
        local layer=camp.Mine:FindFirstChild("Layer"..i)
        if layer then
            local hp=p:GetAttribute("Gate"..i.."HP")or cfg.Layers[i].WallHealth
            layer.Gate.CanCollide=hp>0
            layer.Gate.CanQuery=hp>0
            layer.Gate.LocalTransparencyModifier=hp==0 and 1 or 0
            for _,part in layer:GetChildren()do
                if part.Name=="Gate seam"then part.LocalTransparencyModifier=hp==0 and 1 or 0 end
            end
            layer["Gate label"].Lettering.Title.Text=hp==0 and ("第 "..i.." 层 · "..cfg.Layers[i].Name.."\n稀有矿 "..math.round(cfg.Layers[i].RareChance*100).."%")or ("第 "..i.." 层 · 岩壁 "..hp.."/"..cfg.Layers[i].WallHealth.."\n稀有矿 "..math.round(cfg.Layers[i].RareChance*100).."%")
        end
    end
end
for _,key in {"Power","TrainingGain","Coins","Ore","DeepestLayer"}do p:GetAttributeChangedSignal(key):Connect(refresh)end
for i=1,#cfg.Layers do p:GetAttributeChangedSignal("Gate"..i.."HP"):Connect(refresh)end
for i=1,5 do inv:WaitForChild("Slot"..i).Changed:Connect(refresh)end
local function resize()
    local vp=workspace.CurrentCamera.ViewportSize
    local s=math.clamp(vp.X/1000,.65,1)
    scale.Scale=s
    slots.Position=UDim2.fromOffset(18,20+159*s)
    slots.Size=UDim2.fromOffset(math.min(650,vp.X-36),42);slots.TextWrapped=true
    guide.Size=UDim2.fromOffset(math.min(660,vp.X-24),56);guide.Position=UDim2.new(.5,-math.min(660,vp.X-24)/2,1,-81);guide.TextSize=vp.X<700 and 13 or 17
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
resize();refresh()
local mouse=p:GetMouse()
local hovered
local function findTarget(part)
    if not part then return nil end
    if part:HasTag("MineTarget")then return part end
    local model=part:FindFirstAncestorOfClass("Model")
    local target=model and model:FindFirstChild("Target")
    return target and target:HasTag("MineTarget") and target or nil
end
local function send(part)
    local target=findTarget(part)
    if target then wire.Dig:FireServer(target)end
end
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 then send(mouse.Target)
    elseif input.KeyCode==Enum.KeyCode.F or input.KeyCode==Enum.KeyCode.ButtonX then send(hovered)end
end)
UIS.TouchTapInWorld:Connect(function(pos,processed)
    if processed then return end
    local cam=workspace.CurrentCamera
    local ray=cam:ViewportPointToRay(pos.X,pos.Y)
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={p.Character}
    local result=workspace:Raycast(ray.Origin,ray.Direction*100,params)
    if result then send(result.Instance)end
end)
Run.RenderStepped:Connect(function()
    hovered=findTarget(mouse.Target)
    if hovered and targetText:GetAttribute("Busy")~=true then
        local layer=hovered:GetAttribute("LayerIndex")
        local hp=hovered:GetAttribute("TargetKind")=="Gate" and p:GetAttribute("Gate"..layer.."HP")or hovered:GetAttribute("MaxHealth")
        targetText.Text=hp>0 and ("点击敲击  ·  耐久 "..hp.."  ·  每次伤害 "..(p:GetAttribute("Power")or 1))or ""
    elseif not hovered and targetText:GetAttribute("Busy")~=true then targetText.Text=""end
end)
local noticeId=0
local function announce(value)
    noticeId+=1;local id=noticeId;toast.Text=value
    task.delay(2.2,function()if noticeId==id then toast.Text=""end end)
end
local toolGrip
local function swing()
    local tool=p.Character and p.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    toolGrip=toolGrip or tool.Grip
    tool.Grip=toolGrip*CFrame.Angles(-.8,0,.15)
    Tween:Create(tool,TweenInfo.new(.23),{Grip=toolGrip}):Play()
end
local function popup(target,value)
    local g=Instance.new("BillboardGui")
    g.Name="HitReading";g.Adornee=target;g.Size=UDim2.fromOffset(180,42);g.StudsOffset=Vector3.new(0,4.5,0);g.AlwaysOnTop=true;g.Parent=gui
    local t=text("Value",g,UDim2.fromScale(1,1),UDim2.fromScale(0,0),23);t.Text=value;t.TextColor3=Color3.fromRGB(174,255,205);t.TextStrokeTransparency=.15;t.TextXAlignment=Enum.TextXAlignment.Center
    Tween:Create(g,TweenInfo.new(.65),{StudsOffset=Vector3.new(0,6,0)}):Play()
    Tween:Create(t,TweenInfo.new(.65),{TextTransparency=1}):Play();Debris:AddItem(g,.7)
end
wire.Feedback.OnClientEvent:Connect(function(mode,a,b,c)
    if mode=="note"then announce(a)
    elseif mode=="sale"then announce("已售出 "..b.." 块矿石  +"..a.." 金币")
    elseif mode=="train"then swing();popup(a,"+"..b.." 力量")
    elseif mode=="hit"then
        swing();popup(a,"-"..(p:GetAttribute("Power")or 1))
        targetText:SetAttribute("Busy",true);targetText.Text="剩余耐久 "..b.."/"..c
        task.delay(.5,function()targetText:SetAttribute("Busy",false)end)
    end
end)
local function view(character)
    local root=character:WaitForChild("HumanoidRootPart",10)
    if not root or p.Character~=character then return end
    task.wait(.2)
    local cam=workspace.CurrentCamera
    cam.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,10,24),root.Position+Vector3.new(0,2,-5))
end
if p.Character then task.spawn(view,p.Character)end
p.CharacterAdded:Connect(function(char)toolGrip=nil;view(char)end)
