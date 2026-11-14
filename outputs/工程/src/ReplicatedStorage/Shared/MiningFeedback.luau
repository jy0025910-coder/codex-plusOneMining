local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Style = require(script.Parent.MiningStyle)
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
    local contact = root.Position + root.CFrame.LookVector * 3
    local color = Color3.fromRGB(205, 160, 110)
    if target and target:IsDescendantOf(workspace) then
        local offset = root.Position - target.Position
        local toward = offset.Magnitude > .01 and offset.Unit or Vector3.zAxis
        contact = target.Position + toward * math.min(target.Size.X, target.Size.Z) * .48
        if target:GetAttribute("TargetKind") ~= "Gate" then
            contact = Vector3.new(contact.X, target.Position.Y + .2, contact.Z)
        end
        color = target:GetAttribute("TargetKind") == "Gate" and target.Color or color
        local flash = Instance.new("Highlight")
        flash.Adornee = target:GetAttribute("TargetKind") == "Gate" and target or target.Parent
        flash.FillColor = Color3.fromRGB(255, 241, 187)
        flash.FillTransparency = .63
        flash.OutlineTransparency = 1
        flash.DepthMode = Enum.HighlightDepthMode.Occluded
        flash.Parent = target
        TweenService:Create(flash, TweenInfo.new(.17), {FillTransparency = 1}):Play()
        Debris:AddItem(flash, .20)
    end
    for i = 1, 7 do
        local chip = Instance.new("WedgePart")
        chip.Name = "MiningChip"
        local size = self.rng:NextNumber(.10, .22)
        chip.Size = Vector3.new(size, size * .7, size * 1.15)
        chip.Color = i % 3 == 0 and Color3.fromRGB(255, 213, 117) or color
        chip.Material = Enum.Material.SmoothPlastic
        chip.Anchored = true
        chip.CanCollide = false
        chip.CanQuery = false
        chip.CanTouch = false
        chip.CFrame = CFrame.new(contact) * CFrame.Angles(self.rng:NextNumber(), self.rng:NextNumber(), self.rng:NextNumber())
        chip.Parent = workspace
        local burst = Vector3.new(self.rng:NextNumber(-1.6, 1.6), self.rng:NextNumber(.4, 1.6), self.rng:NextNumber(-1.6, 1.6))
        TweenService:Create(chip, TweenInfo.new(.14), {Position = contact + burst}):Play()
        task.delay(.14, function()
            if chip.Parent then
                TweenService:Create(chip, TweenInfo.new(.22), {Position = chip.Position - Vector3.new(0, 1, 0), Transparency = 1}):Play()
            end
        end)
        Debris:AddItem(chip, .39)
    end
    local sound = Instance.new("Sound")
    sound.Name = "PickaxeImpact"
    sound.SoundId = "rbxasset://sounds/action_jump_land.mp3"
    sound.Volume = .23
    sound.PlaybackSpeed = self.rng:NextNumber(1.2, 1.5)
    sound.Parent = root
    sound:Play()
    Debris:AddItem(sound, 1.2)
end

function Feedback:Stroke(target, amount, speed)
    task.delay(Style.ImpactTime / (speed or 1), function()
        self:Impact(target)
        if amount and amount > 0 then self:Power(amount) end
    end)
end

return Feedback
