local Players = game:GetService("Players")
local Style = require(game.ReplicatedStorage.Shared.MiningStyle)
local Motion = {}
local scopes = {}

function Motion.Stop(player)
    local scope = scopes[player]
    if not scope then return end
    scopes[player] = nil
    if scope.character.Parent then
        scope.character:SetAttribute("MiningStrokeAt", nil)
        scope.character:SetAttribute("MiningStrokeSpeed", nil)
    end
    if scope.humanoid.Parent then scope.humanoid.AutoRotate = scope.autoRotate end
end

function Motion.Play(player, target, speed)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local old = scopes[player]
    local autoRotate = old and old.character == character and old.autoRotate or humanoid.AutoRotate
    if old and old.character ~= character then Motion.Stop(player) end
    local scope = {character = character, humanoid = humanoid, autoRotate = autoRotate}
    scopes[player] = scope
    if target and target:IsA("BasePart") then
        local goal = Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)
        if (goal - root.Position).Magnitude > .2 then root.CFrame = CFrame.lookAt(root.Position, goal) end
    end
    humanoid.AutoRotate = false
    speed = speed or 1
    character:SetAttribute("MiningStrokeSpeed", speed)
    character:SetAttribute("MiningStrokeAt", workspace:GetServerTimeNow())
    task.delay(Style.StrokeDuration / speed, function()
        if scopes[player] == scope then Motion.Stop(player) end
    end)
end

Players.PlayerRemoving:Connect(Motion.Stop)
return Motion
