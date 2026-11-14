local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Inventory = require(script.Parent.InventoryService)
local Feedback = game:GetService("ReplicatedStorage").DigCamp.Feedback

local SellZones = {}
local connection
local elapsed = 0

function SellZones.Contains(zone, root)
    local p = zone.CFrame:PointToObjectSpace(root.Position)
    local half = zone.Size * .5
    return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
end

function SellZones.Step()
    local zones = CollectionService:GetTagged("OreSellZone")
    for _, player in Players:GetPlayers() do
        if Inventory.Count(player) == 0 then continue end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then continue end
        for _, zone in zones do
            if not zone:IsA("BasePart") or not zone:IsDescendantOf(workspace) then continue end
            if zone:GetAttribute("Enabled") == false then continue end
            if not SellZones.Contains(zone, root) then continue end
            local receipt = Inventory.SellAll(player)
            if receipt then
                Feedback:FireClient(player, "sale", receipt.Total, receipt.Count)
                zone:SetAttribute("LastSaleCount", receipt.Count)
                zone:SetAttribute("LastSaleTotal", receipt.Total)
            end
            break
        end
    end
end

function SellZones.Start()
    if connection then return end
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < .15 then return end
        elapsed = 0
        SellZones.Step()
    end)
end

return SellZones
