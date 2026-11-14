-- Procedural mining poses evaluated after the Animator. Supports Motor6D and AnimationConstraint.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Style = require(script.Parent.MiningStyle)
local Animator = {}
local started = false
local scopes = {}
local aliases = {
    RightShoulder = {"RightShoulder", "Right Shoulder"},
    LeftShoulder = {"LeftShoulder", "Left Shoulder"},
    RightElbow = {"RightElbow"}, LeftElbow = {"LeftElbow"}, RightWrist = {"RightWrist"}, Waist = {"Waist"},
}
local function pose(raise, elbow, lean)
    return {RightShoulder=Vector3.new(raise, 0, -9), LeftShoulder=Vector3.new(raise*.55, 0, 13),
        RightElbow=Vector3.new(elbow, 0, 0), LeftElbow=Vector3.new(elbow*.6, 0, 0), RightWrist=Vector3.zero, Waist=Vector3.new(lean, 0, 0)}
end
local raised, impact = pose(153, 28, -6), pose(0, 7, 12)
local carry = {RightShoulder=Vector3.new(90, 0, 0), RightElbow=Vector3.new(90, 0, 0), RightWrist=Vector3.zero}
local function authored(record, angle)
    local rotation = CFrame.Angles(math.rad(angle.X), math.rad(angle.Y), math.rad(angle.Z))
    return record.basis:Inverse() * rotation * record.basis
end
local function equipped(character)
    for _, child in character:GetChildren() do
        if child:IsA("Tool") and child:GetAttribute("AssetId")=="Tool.IronPickaxe" then return true end
    end
    return false
end
local function bind(character)
    local scope = {character=character, joints={}}
    for name, names in aliases do
        for _, alias in names do
            local joint = character:FindFirstChild(alias, true)
            if joint and (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then
                scope.joints[name] = {joint=joint, basis=joint.C0.Rotation}
                break
            end
        end
    end
    scopes[character] = scope
    return scope
end
local function restore(scope)
    for _, record in scope.joints do
        if record.applied and record.joint.Parent then record.joint.Transform = record.base end
        record.applied = false
    end
end
function Animator.Start()
    if started then return end
    started = true
    -- Remove our previous frame before the regular Animator evaluates its tracks.
    RunService.PreAnimation:Connect(function()
        for character, scope in scopes do
            restore(scope)
            if not character.Parent then scopes[character] = nil end
        end
    end)
    RunService.PreSimulation:Connect(function()
        local now = workspace:GetServerTimeNow()
        for _, player in Players:GetPlayers() do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 or not equipped(character) then continue end
            local start = character:GetAttribute("MiningStrokeAt")
            local t = start and math.max(0, (now-start)*(character:GetAttribute("MiningStrokeSpeed") or 1)) or Style.StrokeDuration
            local scope = scopes[character] or bind(character)
            local first, second, alpha, weight = raised, raised, 0, 0
            if t >= 0 and t < Style.WindupTime then
                weight = 1-(1-t/Style.WindupTime)^2
            elseif t < Style.ImpactTime then
                first, second, alpha, weight = raised, impact, 1-(1-(t-Style.WindupTime)/(Style.ImpactTime-Style.WindupTime))^2, 1
            elseif t < Style.HoldTime then
                first, second, alpha, weight = impact, impact, 0, 1
            elseif t < Style.StrokeDuration then
                first, second, alpha, weight = impact, impact, 0, (1-(t-Style.HoldTime)/(Style.StrokeDuration-Style.HoldTime))^2
            end
            for name, record in scope.joints do
                local joint = record.joint
                if not joint.Parent then continue end
                local a = first[name]:Lerp(second[name], alpha)
                record.base = joint.Transform
                record.applied = true
                local rest = carry[name] and authored(record, carry[name]) or record.base
                joint.Transform = rest:Lerp(authored(record, a), weight)
            end
        end
    end)
end
return Animator
