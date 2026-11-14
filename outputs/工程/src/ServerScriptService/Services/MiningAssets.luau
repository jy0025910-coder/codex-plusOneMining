local assets = game:GetService("ServerStorage"):WaitForChild("GameAssets")
local Factory = {}

function Factory.GetEquipped(character)
    if not character then return nil end
    for _, child in character:GetChildren() do
        if child:IsA("Tool") and child:GetAttribute("AssetId") == "Tool.IronPickaxe" then
            return child
        end
    end
    return nil
end

function Factory.Equip(player, character, humanoid, backpack)
    if player.Character ~= character then return nil end
    local current = Factory.GetEquipped(character)
    if current then return current end
    local tool = assets.Tools.IronPickaxe:Clone()
    tool.Name = "铁镐"
    for _, part in tool:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.Massless = true
            part.CanCollide = false
        end
    end
    tool.Parent = backpack
    humanoid:EquipTool(tool)
    return tool
end

function Factory.CreateRockVisual(parent, placement, options)
    options = options or {}
    local visual = assets.Ores.SandstoneOre:Clone()
    visual.Name = "RockVisual"
    if options.Scale then visual:ScaleTo(options.Scale) end
    for _, part in visual:GetDescendants() do
        if not part:IsA("MeshPart") then continue end
        local base = part:GetAttribute("BaseColor") or part.Color
        if part:GetAttribute("MeshRole") == "Inclusions" and options.MineralColor then
            local reference = Color3.fromRGB(198, 121, 67)
            local tint = options.MineralColor
            part.Color = Color3.new(math.min(1, base.R / reference.R * tint.R), math.min(1, base.G / reference.G * tint.G), math.min(1, base.B / reference.B * tint.B))
        elseif options.StoneTint then
            local tint = options.StoneTint
            part.Color = Color3.new(base.R * tint.R, base.G * tint.G, base.B * tint.B)
        end
    end
    visual:PivotTo(placement)
    visual.Parent = parent
    return visual
end

function Factory.ReplaceRock(model, index, isTraining, color)
    local target = model:FindFirstChild("Target")
    if not target then return end
    for _, child in model:GetChildren() do
        local oldGeometry = child:IsA("BasePart") and not child:FindFirstChildOfClass("BillboardGui")
        if child ~= target and (oldGeometry or child.Name == "RockVisual") then
            child:Destroy()
        end
    end
    local scale = isTraining and ({1, 1.1, 1.2})[index] or .87
    local rotation = isTraining and ({0, .85, -.55})[index] or index * .5
    local placement = target.CFrame * CFrame.new(0, -2.2, 0) * CFrame.Angles(0, rotation, 0)
    Factory.CreateRockVisual(model, placement, {
        Scale = scale,
        MineralColor = isTraining and index == 1 and Color3.fromRGB(238, 157, 89) or color,
        StoneTint = index > 1 and Color3.fromRGB(210, 218, 216) or Color3.new(1, 1, 1),
    })
    target.Transparency = 1
    target.Shape = Enum.PartType.Block
    target.Size = Vector3.new(5.8, 3.9, 4.8) * scale
    target.CanQuery = true
    if isTraining then
        target:SetAttribute("TargetKind", "Training")
        target:SetAttribute("TrainingIndex", index)
        target:AddTag("TrainingTarget")
    end
end

return Factory
