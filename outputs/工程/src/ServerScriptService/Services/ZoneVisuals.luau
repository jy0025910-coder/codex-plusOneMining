local assets = game:GetService("ServerStorage"):WaitForChild("GameAssets")
local Visuals = {}

-- One editable prefab supplies the gradient, double border and sparse stars.
function Visuals.Create(parent, name, placement, options)
    options = options or {}
    local zone = assets.Interactions.AutoSellZone:Clone()
    zone.Name = name
    zone:PivotTo(CFrame.identity)
    local trigger = zone.Trigger
    trigger:RemoveTag("OreSellZone")
    trigger:SetAttribute("Enabled", options.Sell == true)
    if options.Sell then trigger:AddTag("OreSellZone") end
    if options.Tag then trigger:AddTag(options.Tag) end
    for key, value in options.Attributes or {} do trigger:SetAttribute(key,value) end
    if zone:FindFirstChild("FloorLabel") then
        zone.FloorLabel.Lettering.Title.Text = options.Label or ""
    end
    if options.Color then
        for _, object in zone:GetDescendants() do
            if object:IsA("UIGradient") then
                object.Color = ColorSequence.new(options.Color:Lerp(Color3.new(1,1,1),.45),options.Color)
            elseif object:IsA("BasePart") and object.Material == Enum.Material.Neon then
                object.Color = options.Color
            elseif object:IsA("ParticleEmitter") then
                object.Color = ColorSequence.new(options.Color:Lerp(Color3.new(1,1,1),.65))
            end
        end
    end
    zone:PivotTo(placement)
    zone.Parent = parent
    return zone
end

return Visuals
