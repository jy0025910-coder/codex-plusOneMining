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

function Feedback:Power(amount)
    local number = Instance.new("TextLabel")
    number.Name = "PowerGain"
    number.AnchorPoint = Vector2.new(.5, .5)
    number.Position = UDim2.fromScale(self.rng:NextNumber(.25, .78), self.rng:NextNumber(.25, .66))
    number.Size = UDim2.fromOffset(150, 65)
    number.BackgroundTransparency = 1
    number.Font = Enum.Font.GothamBlack
    number.Text = "+" .. amount
    number.TextColor3 = Color3.fromRGB(177, 255, 160)
    number.TextStrokeColor3 = Color3.fromRGB(37, 70, 49)
    number.TextStrokeTransparency = .12
    number.TextSize = 43
    number.Rotation = self.rng:NextNumber(-8, 8)
    number.Parent = self.gui
    local scale = Instance.new("UIScale")
    scale.Scale = .5
    scale.Parent = number
    TweenService:Create(scale, TweenInfo.new(.14, Enum.EasingStyle.Back), {Scale = 1}):Play()
    TweenService:Create(number, TweenInfo.new(.75), {Position = number.Position - UDim2.fromOffset(0, 65)}):Play()
    task.delay(.40, function()
        if number.Parent then
            TweenService:Create(number, TweenInfo.new(.3), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        end
    end)
    Debris:AddItem(number, .78)
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
        if amount and amount > 0 then self:Power(amount) end
    end)
end

return Feedback
