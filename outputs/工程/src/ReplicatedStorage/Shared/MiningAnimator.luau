-- Procedural mining poses evaluated after the Animator. Supports Motor6D and AnimationConstraint.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Animator = {}
local started = false
local scopes = {}
local aliases = {
    RightShoulder = {"RightShoulder", "Right Shoulder"},
    LeftShoulder = {"LeftShoulder", "Left Shoulder"},
    RightElbow = {"RightElbow"}, LeftElbow = {"LeftElbow"}, Waist = {"Waist"},
}
local function pose(raise, elbow, lean)
    return {RightShoulder=Vector3.new(raise, 0, -9), LeftShoulder=Vector3.new(raise*.55, 0, 13),
        RightElbow=Vector3.new(elbow, 0, 0), LeftElbow=Vector3.new(elbow*.6, 0, 0), Waist=Vector3.new(lean, 0, 0)}
end
local raised, impact = pose(153, 28, -6), pose(0, 7, 12)
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
            local start = character and character:GetAttribute("MiningStrokeAt")
            if not start then continue end
            local t = now - start
            if t < 0 or t >= .60 then continue end
            local scope = scopes[character] or bind(character)
            local first, second, alpha, weight
            if t < .17 then
                first, second, alpha, weight = raised, raised, 0, 1-(1-t/.17)^2
            elseif t < .27 then
                first, second, alpha, weight = raised, impact, 1-(1-(t-.17)/.10)^2, 1
            elseif t < .34 then
                first, second, alpha, weight = impact, impact, 0, 1
            else
                first, second, alpha, weight = impact, impact, 0, (1-(t-.34)/.26)^2
            end
            for name, record in scope.joints do
                local joint = record.joint
                if not joint.Parent then continue end
                local a = first[name]:Lerp(second[name], alpha)
                local rotation = CFrame.Angles(math.rad(a.X), math.rad(a.Y), math.rad(a.Z))
                local authored = record.basis:Inverse() * rotation * record.basis
                record.base = joint.Transform
                record.applied = true
                joint.Transform = record.base:Lerp(authored, weight)
            end
        end
    end)
end
return Animator
