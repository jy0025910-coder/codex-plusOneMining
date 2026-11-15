require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("MiningAnimator")).Start()
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local p=Players.LocalPlayer
local wire=game.ReplicatedStorage:WaitForChild("DigCamp")
local cfg=require(game.ReplicatedStorage.Shared.PrototypeConfig)
local camp=workspace:WaitForChild("Gem Gulch")
local gui=p:WaitForChild("PlayerGui"):WaitForChild("FieldKit")
gui:ClearAllChildren()
gui.ResetOnSpawn=false
local FeedbackEffects = require(game.ReplicatedStorage.Shared.MiningFeedback)
local feedbackEffects = FeedbackEffects.new(gui,p)
local GuiService = game:GetService("GuiService")
local hud=p:WaitForChild("PlayerGui"):WaitForChild("MiningHUD"):WaitForChild("Root")
local guide=hud.Status.Guide
local toast=hud.Status.Toast
local targetText=hud.Status.Target
hud.ReturnToCamp.Activated:Connect(function()wire.ReturnToCamp:FireServer()end)
local function refresh()
    local training=p:GetAttribute("TrainingGain")or 0
    local count=p:GetAttribute("Ore")or 0
    local mining=p:GetAttribute("AutoMining")==true
    guide.Text=count>=5 and "背包满了 · 返回摊位，走进绿色光幕出售" or training>0 and "正在自动敲矿训练 · 离开光幕即可停止" or mining and "正在自动采矿 · 走开即可停止" or "点击 +1 力量  ·  走进左侧练习区自动敲击  ·  靠近矿门自动挖掘"
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
for _,key in {"Power","TrainingGain","AutoMining","Coins","Ore","DeepestLayer"}do p:GetAttributeChangedSignal(key):Connect(refresh)end
for i=1,#cfg.Layers do p:GetAttributeChangedSignal("Gate"..i.."HP"):Connect(refresh)end
refresh()
local mouse=p:GetMouse()
local hovered
local function findTarget(part)
    if not part then return nil end
    if part:HasTag("MineTarget") or part:HasTag("TrainingTarget")then return part end
    local model=part:FindFirstAncestorOfClass("Model")
    local target=model and model:FindFirstChild("Target")
    return target and (target:HasTag("MineTarget") or target:HasTag("TrainingTarget")) and target or nil
end
local function send()
    wire.Practice:FireServer()
end
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        local inset = GuiService:GetGuiInset()
        feedbackEffects:ClickRing(UIS:GetMouseLocation()-inset)
        send()
    elseif input.KeyCode==Enum.KeyCode.F or input.KeyCode==Enum.KeyCode.ButtonX then send()end
end)
UIS.TouchTapInWorld:Connect(function(pos,processed)
    if processed then return end
    local inset = GuiService:GetGuiInset()
    feedbackEffects:ClickRing(pos-inset)
    send()
end)
Run.RenderStepped:Connect(function()
    hovered=findTarget(mouse.Target)
    if hovered and hovered:GetAttribute("TargetKind")=="Training" and targetText:GetAttribute("Busy")~=true then
        targetText.Text="走进光幕自动练习  ·  点击额外 +1 力量"
    elseif hovered and targetText:GetAttribute("Busy")~=true then
        local layer=hovered:GetAttribute("LayerIndex")
        local hp=hovered:GetAttribute("TargetKind")=="Gate" and p:GetAttribute("Gate"..layer.."HP")or hovered:GetAttribute("MaxHealth")
        targetText.Text=hp>0 and ("靠近自动敲击  ·  耐久 "..hp.."  ·  每次伤害 "..(p:GetAttribute("Power")or 1))or ""
    elseif not hovered and targetText:GetAttribute("Busy")~=true then targetText.Text=""end
end)
local noticeId=0
local function announce(value)
    noticeId+=1;local id=noticeId;toast.Text=value
    task.delay(2.2,function()if noticeId==id then toast.Text=""end end)
end
wire.Feedback.OnClientEvent:Connect(function(mode,a,b,c)
    if mode=="note"then announce(a)
    elseif mode=="sale"then announce("已售出 "..b.." 块矿石  +"..a.." 金币")
    elseif mode=="practice" then feedbackEffects:Power(b)
    elseif mode=="train" then feedbackEffects:Stroke(a,b,c)
    elseif mode=="hit"then
        feedbackEffects:Stroke(a,1,require(game.ReplicatedStorage.Shared.MiningStyle).AutoSwingSpeed)
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
p.CharacterAdded:Connect(view)
