local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Big = require(Shared.BigInteger)
local Balance = require(Shared.GameBalance)
local Inventory = {}
local accounts = {}
local function replicate(player,account)
    local total = "0"
    for _,item in account.items do total = Big.Add(total,item.Value) end
    player:SetAttribute("Coins",account.coins)
    player:SetAttribute("Capacity",5)
    player:SetAttribute("Ore",#account.items)
    player:SetAttribute("SaleValue",total)
    local bag = player:FindFirstChild("OreInventory")
    if not bag then bag=Instance.new("Folder");bag.Name="OreInventory";bag.Parent=player end
    for i=1,5 do
        local slot=bag:FindFirstChild("Slot"..i)
        if not slot then slot=Instance.new("StringValue");slot.Name="Slot"..i;slot.Parent=bag end
        local item=account.items[i]
        slot.Value=item and tostring(item.Id) or ""
        slot:SetAttribute("UnitValue",item and item.Value or "0")
        slot:SetAttribute("OreName",item and Balance.Minerals[item.Id].Name or "")
        slot:SetAttribute("Quality",item and item.Quality or 100)
    end
end
function Inventory.Create(player)
    if not accounts[player] then accounts[player]={coins="0",items={}};replicate(player,accounts[player]) end
end
function Inventory.Count(player)
    return accounts[player] and #accounts[player].items or 0
end
function Inventory.Balance(player)
    return accounts[player] and accounts[player].coins or "0"
end
function Inventory.Add(player,item)
    local account=accounts[player]
    if not account or #account.items>=5 or type(item)~="table" or not Balance.Minerals[item.Id] or not Big.IsValid(item.Value) then return false end
    table.insert(account.items,table.clone(item))
    replicate(player,account)
    return true
end
function Inventory.SellAll(player)
    local account=accounts[player]
    if not account or #account.items==0 then return nil end
    local total,count="0",#account.items
    for _,item in account.items do
        total=Big.Add(total,item.Value)
        player:SetAttribute("Discovered"..item.Id,true)
    end
    local multiplier=player:GetAttribute("EquippedSecret")==5 and 2 or player:GetAttribute("EquippedSecret")==6 and 3 or 1
    total=Big.Multiply(total,multiplier)
    account.items={}
    account.coins=Big.Add(account.coins,total)
    replicate(player,account)
    local discovered=0
    for id=1,50 do if player:GetAttribute("Discovered"..id) then discovered+=1 end end
    player:SetAttribute("CollectionCount",discovered)
    return {Count=count,Total=total}
end
function Inventory.Spend(player,cost)
    local account=accounts[player]
    if not account or not Big.IsValid(cost) or Big.Compare(cost,"0")<=0 or Big.Compare(account.coins,cost)<0 then return false end
    account.coins=Big.Subtract(account.coins,cost)
    replicate(player,account)
    return true
end
function Inventory.Refresh(player)
    if accounts[player] then replicate(player,accounts[player]) end
end
function Inventory.Export(player)
    local account=accounts[player]
    return account and {coins=account.coins,items=table.clone(account.items)}
end
function Inventory.Import(player,data)
    if type(data)~="table" or not Big.IsValid(data.coins) then return false end
    local account={coins=Big.Normalize(data.coins),items={}}
    for _,item in type(data.items)=="table" and data.items or {} do
        if #account.items<5 and type(item)=="table" and Balance.Minerals[item.Id] and Big.IsValid(item.Value) then
            table.insert(account.items,{Id=item.Id,Value=Big.Normalize(item.Value),Quality=type(item.Quality)=="number" and item.Quality or 100})
        end
    end
    accounts[player]=account
    replicate(player,account)
    return true
end
Players.PlayerRemoving:Connect(function(player)task.delay(5,function()accounts[player]=nil end)end)
return Inventory
