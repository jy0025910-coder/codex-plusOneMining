-- A shop owns its sign and mount points. Each visible tintable part declares its role.
local assets = game:GetService("ServerStorage"):WaitForChild("GameAssets")
local Factory = {}

function Factory.CreateStall(parent, name, placement, options)
    options = options or {}
    local stall = assets.Buildings.MarketStall:Clone()
    stall.Name = name
    stall.SignAnchor.Lettering.Title.Text = options.Title or "矿石收购"
    for _, part in stall:GetDescendants() do
        local role = part:GetAttribute("TintRole")
        if role and options[role] and part:IsA("BasePart") then
            part.Color = options[role]
        end
    end
    stall:PivotTo(placement)
    stall.Parent = parent
    return stall
end

function Factory.AttachMerchant(stall, options)
    options = options or {}
    local merchant = assets.Characters.ProspectorMerchant:Clone()
    merchant.Name = options.Name or "Merchant"
    merchant:PivotTo(stall.Mounts.NpcMount.CFrame)
    merchant.Parent = stall
    return merchant
end

return Factory
