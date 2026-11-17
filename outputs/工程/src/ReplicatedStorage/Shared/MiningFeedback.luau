local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Style = require(script.Parent.MiningStyle)
local RockImpact = require(script.Parent.RockImpact)
local Feedback = {}
Feedback.__index = Feedback

function Feedback.new(gui, player)
    return setmetatable({gui = gui, player = player, rng = Random.new()}, Feedback)
end

function Feedback:ClickRing(position)
    local ring = Instance.new("Frame")
    ring.Name = "ClickRing"
    ring.AnchorPoint = Vector2.new(.5, .5)
    ring.Position = UDim2.fromOffset(position.X, position.Y)
    ring.Size = UDim2.fromOffset(12, 12)
    ring.BackgroundTransparency = 1
    ring.Parent = self.gui
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = ring
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 225, 145)
    stroke.Thickness = 2
    stroke.Parent = ring
    TweenService:Create(ring, TweenInfo.new(.25), {Size = UDim2.fromOffset(55, 55)}):Play()
    TweenService:Create(stroke, TweenInfo.new(.25), {Transparency = 1}):Play()
    Debris:AddItem(ring, .28)
end

function Feedback:CreatePowerPopup(amount)
    local template=script.Parent:FindFirstChild("PowerGainTemplate")
    if not template then return end
    local popup=template:Clone();popup.Name="PowerGain";popup.Visible=true
    popup.Amount.Text="+"..amount
    -- Keep older reusable viewport templates compatible; v2 uses a flat image.
    if popup.Icon:IsA("ViewportFrame") then
        local camera=popup.Icon:FindFirstChildOfClass("Camera") or Instance.new("Camera")
        camera.Name="IconCamera";camera.CFrame=popup.Icon:GetAttribute("PreviewCameraFrame")
        camera.FieldOfView=popup.Icon:GetAttribute("PreviewFieldOfView")
        camera.Parent=popup.Icon;popup.Icon.CurrentCamera=camera
    end
    return popup
end

function Feedback:Power(amount)
    local popup=self:CreatePowerPopup(amount)
    if not popup then return end
    local previous=self.lastPowerPosition
    local position
    for _=1,4 do
        position=Vector2.new(self.rng:NextNumber(.23,.77),self.rng:NextNumber(.28,.64))
        if not previous or (position-previous).Magnitude>.16 then break end
    end
    self.lastPowerPosition=position
    popup.Position=UDim2.fromScale(position.X,position.Y)
    popup.Rotation=self.rng:NextNumber(-7,7)
    popup.Parent=self.gui
    local reduced=game:GetService("GuiService").ReducedMotionEnabled
    local viewport=workspace.CurrentCamera.ViewportSize
    local size=math.clamp(math.min(viewport.X/1000,viewport.Y/620),.68,1.18)
    local scale=popup.PopScale
    scale.Scale=reduced and size or size*.65
    if not reduced then
        popup.Icon.Rotation=-12
        TweenService:Create(popup.Icon,TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=0}):Play()
        TweenService:Create(scale,TweenInfo.new(.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=size}):Play()
        TweenService:Create(popup,TweenInfo.new(.78,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=popup.Position-UDim2.fromOffset(0,62*size)}):Play()
    end
    task.delay(.46,function()
        if popup.Parent then TweenService:Create(popup,TweenInfo.new(.26),{GroupTransparency=1}):Play()end
    end)
    Debris:AddItem(popup,.76)
end

function Feedback:Impact(target)
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    RockImpact.Play(target,root,self.rng)
end

function Feedback:Stroke(target, amount, speed)
    task.delay(Style.ImpactTime / (speed or 1), function()
        self:Impact(target)
        if amount and amount ~= 0 and amount ~= "0" then self:Power(amount) end
    end)
end

return Feedback
