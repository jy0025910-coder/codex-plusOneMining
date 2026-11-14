local Players = game:GetService("Players")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.OreCatalog)

local Inventory = {}
local accounts = {}

local function replicate(player, account)
    local total = 0
    for _, oreId in account.items do
        total += Catalog.Items[oreId].Value
    end
    player:SetAttribute("Coins", account.coins)
    player:SetAttribute("Capacity", Catalog.Capacity)
    player:SetAttribute("Ore", #account.items)
    player:SetAttribute("SaleValue", total)

    -- Five real, inspectable slots let HUDs render each item independently.
    local bag = player:FindFirstChild("OreInventory")
    if not bag then
        bag = Instance.new("Folder")
        bag.Name = "OreInventory"
        bag.Parent = player
    end
    for i = 1, Catalog.Capacity do
        local slot = bag:FindFirstChild("Slot" .. i)
        if not slot then
            slot = Instance.new("StringValue")
            slot.Name = "Slot" .. i
            slot.Parent = bag
        end
        local oreId = account.items[i]
        slot:SetAttribute("UnitValue", oreId and Catalog.Items[oreId].Value or 0)
        slot.Value = oreId or ""
    end
end

function Inventory.Create(player)
    if accounts[player] then return end
    accounts[player] = { items = {}, coins = 0 }
    replicate(player, accounts[player])
end

function Inventory.Count(player)
    local account = accounts[player]
    return account and #account.items or 0
end

function Inventory.Balance(player)
    local account = accounts[player]
    return account and account.coins or 0
end

function Inventory.Add(player, oreId)
    local account = accounts[player]
    if not account or not Catalog.Items[oreId] then return false end
    if #account.items >= Catalog.Capacity then return false end
    table.insert(account.items, oreId)
    replicate(player, account)
    return true
end

function Inventory.SellAll(player)
    local account = accounts[player]
    if not account or #account.items == 0 then return nil end
    local total = 0
    local count = #account.items
    for _, oreId in account.items do
        total += Catalog.Items[oreId].Value
    end
    -- This transaction never yields. Overlapping zones cannot sell an item twice.
    account.items = {}
    account.coins += total
    replicate(player, account)
    return { Count = count, Total = total }
end

function Inventory.Spend(player, cost)
    local account = accounts[player]
    if not account or type(cost) ~= "number" or cost <= 0 or cost % 1 ~= 0 then return false end
    if account.coins < cost then return false end
    account.coins -= cost
    replicate(player, account)
    return true
end

function Inventory.Refresh(player)
    local account = accounts[player]
    if account then replicate(player, account) end
end

Players.PlayerRemoving:Connect(function(player)
    accounts[player] = nil
end)

return Inventory
