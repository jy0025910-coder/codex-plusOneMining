local assets = game:GetService("ServerStorage"):WaitForChild("GameAssets")
local Style = require(game.ReplicatedStorage.Shared.MiningStyle)
local Config = require(game.ReplicatedStorage.Shared.PrototypeConfig)
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
    tool.Grip = Style.Grip
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
    if options.Stretch then
        local pivot = visual:GetPivot()
        for _, part in visual:GetDescendants() do
            if part:IsA("BasePart") and part~=visual.PrimaryPart then
                local localCF=pivot:ToObjectSpace(part.CFrame)
                part.Size=part.Size*options.Stretch
                part.CFrame=pivot*CFrame.new(localCF.Position*options.Stretch)*localCF.Rotation
            end
        end
    end
    for _, part in visual:GetDescendants() do
        if not part:IsA("MeshPart") then continue end
        local base = part:GetAttribute("BaseColor") or part.Color
        if part:GetAttribute("MeshRole") == "Inclusions" and options.MineralColor then
            local reference = Color3.fromRGB(198, 121, 67)
            local tint = options.MineralColor
            part.Color = Color3.new(math.min(1, base.R / reference.R * tint.R), math.min(1, base.G / reference.G * tint.G), math.min(1, base.B / reference.B * tint.B))
        elseif options.StoneTint then
            local tint = options.StoneTint
            local shade = math.clamp(math.max(base.R,base.G,base.B)/.86,.68,1.12)
            part.Color = Color3.new(math.min(1,tint.R*shade),math.min(1,tint.G*shade),math.min(1,tint.B*shade))
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
    local profile=isTraining and Config.Trainings[index] or nil
    local scale=profile and profile.Scale or .95
    local height=profile and profile.Height or 3.9*scale
    local rotation=profile and ({0,.42,-.35})[index] or index*.5
    local oldOffset=target:GetAttribute("RockBaseOffset") or 2.2
    local ground=target.CFrame*CFrame.new(0,-oldOffset,0)
    local visual=Factory.CreateRockVisual(model,ground*CFrame.Angles(0,rotation,0),{
        Scale=scale,Stretch=profile and profile.Stretch,
        MineralColor=profile and profile.Color or color,
        StoneTint=profile and profile.StoneColor or color,
    })
    if profile and profile.Crown then
        local crown=assets.Props.OreSamples[profile.Crown]:Clone()
        crown.Name="MineralCrown"
        crown:ScaleTo(index==2 and 3.2 or 3.8)
        for _,part in crown:GetDescendants()do
            if part:IsA("BasePart")then
                part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
                if part.Transparency<1 then part.Color=profile.Color:Lerp(Color3.new(1,1,1),part.Name:find("tip") and .28 or 0) end
            end
        end
        crown:PivotTo(visual:GetPivot()*CFrame.new(.3,index==2 and 6.5 or 6.3,0)*CFrame.Angles(0,0,index==2 and -.10 or .12))
        crown.Parent=visual
    end
    visual:SetAttribute("RestPivot",visual:GetPivot())
    target.CFrame=ground*CFrame.new(0,height/2,0)
    target:SetAttribute("RockBaseOffset",height/2)
    target:SetAttribute("ImpactColor",profile and profile.Color or color)
    target:SetAttribute("LargeImpact",isTraining)
    target.Color=profile and profile.StoneColor or color
    target.Transparency = 1
    target.Shape = Enum.PartType.Block
    target.Size = Vector3.new(5.4*scale*(profile and profile.Stretch.X or 1),height,4.0*scale)
    target.CanQuery = true
    if isTraining then
        target:SetAttribute("TargetKind", "Training")
        target:SetAttribute("TrainingIndex", index)
        target:AddTag("TrainingTarget")
    end
end

return Factory
