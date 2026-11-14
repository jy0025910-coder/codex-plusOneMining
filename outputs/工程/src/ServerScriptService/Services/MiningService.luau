local Players = game:GetService("Players")
local Collection = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Inventory = require(script.Parent.InventoryService)
local Config = require(game.ReplicatedStorage.Shared.PrototypeConfig)
local Catalog = require(game.ReplicatedStorage.Shared.OreCatalog)
local Equipment = require(script.Parent.MiningAssets)
local Motion = require(script.Parent.MiningMotion)
local wire = game.ReplicatedStorage.DigCamp
local Service = {}
local states = {}
local started = false
local rng = Random.new()
local camp

local function living(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return nil end
    return root, humanoid
end
local function within(player, target, range)
    local root = living(player)
    return root and (root.Position-target.Position).Magnitude <= range
end
local function note(player, text)
    wire.Feedback:FireClient(player,"note",text)
end
local function init(player)
    if states[player] then return end
    local state = {power=1,tier=1,unlocked=0,gates={},nodes={},lastHit=0,training=0,lastNote=0}
    states[player] = state
    Inventory.Create(player)
    player:SetAttribute("Power",1)
    player:SetAttribute("ToolTier",1)
    player:SetAttribute("DeepestLayer",0)
    player:SetAttribute("TrainingGain",0)
    for index, layer in Config.Layers do
        state.gates[index] = layer.WallHealth
        player:SetAttribute("Gate"..index.."HP",layer.WallHealth)
    end
    local function equip(character)
        local h=character:WaitForChild("Humanoid",10)
        local backpack=player:WaitForChild("Backpack",10)
        if not h or not backpack or player.Character~=character then return end
        Equipment.Equip(player, character, h, backpack)
    end
    player.CharacterAdded:Connect(equip)
    if player.Character then task.spawn(equip,player.Character)end
end

function Service.Hit(player,target)
    local state=states[player]
    if not state or typeof(target)~="Instance" or not target:IsA("BasePart") then return end
    if not target:IsDescendantOf(camp.Mine) or not target:HasTag("MineTarget") then return end
    if not within(player,target,19) or os.clock()-state.lastHit<Config.HitInterval then return end
    local character=player.Character
    if not Equipment.GetEquipped(character) then return end
    local index=target:GetAttribute("LayerIndex")
    if typeof(index)~="number" or not Config.Layers[index] then return end
    state.lastHit=os.clock()
    local kind=target:GetAttribute("TargetKind")
    if kind=="Gate" then
        if index~=state.unlocked+1 then return end
        local hp=math.max(0,state.gates[index]-state.power)
        state.power += 1
        player:SetAttribute("Power",state.power)
        Motion.Play(player,target)
        state.gates[index]=hp
        player:SetAttribute("Gate"..index.."HP",hp)
        wire.Feedback:FireClient(player,"hit",target,hp,Config.Layers[index].WallHealth)
        if hp==0 then
            state.unlocked=index
            player:SetAttribute("DeepestLayer",index)
            note(player,"岩壁打通！第 "..index.." 层 · 稀有矿 "..math.round(Config.Layers[index].RareChance*100).."%")
        end
        return
    end
    if kind~="Ore" or index>state.unlocked then return end
    if Inventory.Count(player)>=Catalog.Capacity then note(player,"背包已满，回绿色光幕出售");return end
    local health=state.nodes[target] or Config.Layers[index].OreHealth
    health=math.max(0,health-state.power)
    state.nodes[target]=health
    state.power += 1
    player:SetAttribute("Power",state.power)
    Motion.Play(player,target)
    wire.Feedback:FireClient(player,"hit",target,health,Config.Layers[index].OreHealth)
    if health==0 then
        local roll=rng:NextNumber()
        local rareChance=Config.Layers[index].RareChance
        local oreId
        if roll<rareChance then
            oreId=({"MintCrystal","Amethyst","Gold"})[rng:NextInteger(1,3)]
        else
            oreId=rng:NextNumber()<.45 and "Copper" or "Stone"
        end
        if Inventory.Add(player,oreId) then
            state.nodes[target]=nil
            note(player,"采得 "..Catalog.Items[oreId].Name.." · "..Catalog.Items[oreId].Value.." 金币")
        end
    end
end

function Service.Practice(player, target)
    local state = states[player]
    if not state or not living(player) or not Equipment.GetEquipped(player.Character) then return end
    if os.clock() - state.lastHit < .35 then return end
    if target ~= nil then
        if typeof(target) ~= "Instance" or not target:IsA("BasePart") then return end
        if not target:IsDescendantOf(camp.Training) or not target:HasTag("TrainingTarget") then return end
        if not within(player,target,19) then return end
        local index = target:GetAttribute("TrainingIndex")
        if not Config.Trainings[index] or state.power < Config.Trainings[index].Required then return end
    end
    state.lastHit = os.clock()
    state.power += 1
    player:SetAttribute("Power",state.power)
    Motion.Play(player,target)
    wire.Feedback:FireClient(player,"practice",target,1)
end

local function stepTraining(dt)
    for player,state in states do
        local root=living(player)
        local gain=0
        local rock
        if root and Equipment.GetEquipped(player.Character) then
            for _,zone in Collection:GetTagged("TrainingZone")do
                if not zone:IsDescendantOf(camp) then continue end
                local p=zone.CFrame:PointToObjectSpace(root.Position)
                local half=zone.Size*.5
                if math.abs(p.X)>half.X or math.abs(p.Y)>half.Y or math.abs(p.Z)>half.Z then continue end
                local required=zone:GetAttribute("RequiredPower")
                if state.power<required then
                    if os.clock()-state.lastNote>3 then note(player,"此训练石需要 "..required.." 力量");state.lastNote=os.clock()end
                    break
                end
                gain=zone:GetAttribute("Gain")
                rock=camp.Training["TrainingRock"..zone:GetAttribute("TrainingIndex")].Target
                break
            end
        end
        if gain == 0 and (player:GetAttribute("TrainingGain") or 0) > 0 then Motion.Stop(player) end
        player:SetAttribute("TrainingGain",gain)
        if gain>0 then
            state.training+=dt
            if state.training>=Config.TrainingInterval then
                state.training=0
                state.power+=gain
                player:SetAttribute("Power",state.power)
                Motion.Play(player,rock)
                wire.Feedback:FireClient(player,"train",rock,gain)
            end
        else
            state.training=0
        end
        if root then
            -- Physical gate visuals are local. Progress is also enforced by the server.
            local nextGate=camp.Mine:FindFirstChild("Layer"..(state.unlocked+1))
            if nextGate then
                local gate=nextGate.Gate
                local p=gate.CFrame:PointToObjectSpace(root.Position)
                if p.Z<-.9 and math.abs(p.X)<18 then
                    player.Character:PivotTo(gate.CFrame*CFrame.new(0,-gate.Size.Y/2+3,4))
                end
            end
        end
    end
end
local function updateBoards()
    for _,board in Collection:GetTagged("CampLeaderboard")do
        local stat=board:GetAttribute("BoardStat")
        local list=Players:GetPlayers()
        table.sort(list,function(a,b)
            local av,bv=a:GetAttribute(stat)or 0,b:GetAttribute(stat)or 0
            if av==bv then return a.UserId<b.UserId end
            return av>bv
        end)
        for i=1,6 do
            local p=list[i]
            board.Scores.Frame["Row"..i].Text=p and (i.."  "..p.DisplayName.."   "..(p:GetAttribute(stat)or 0)) or ""
        end
    end
end

function Service.Start()
    if started then return end
    started=true
    camp=require(script.Parent.WorldBuilder).Build()
    Players.PlayerAdded:Connect(init)
    Players.PlayerRemoving:Connect(function(p)states[p]=nil;Motion.Stop(p)end)
    for _,p in Players:GetPlayers()do init(p)end
    wire.Dig.OnServerEvent:Connect(Service.Hit)
    wire:WaitForChild("Practice").OnServerEvent:Connect(Service.Practice)
    local returnEvent=wire:FindFirstChild("ReturnToCamp")
    if not returnEvent then
        returnEvent=Instance.new("RemoteEvent")
        returnEvent.Name="ReturnToCamp"
        returnEvent.Parent=wire
    end
    local returnTimes={}
    returnEvent.OnServerEvent:Connect(function(player)
        if not living(player) or os.clock()-(returnTimes[player]or 0)<2 then return end
        returnTimes[player]=os.clock()
        player.Character:PivotTo(camp.Arrival.CFrame*CFrame.new(0,3,0))
    end)
    Players.PlayerRemoving:Connect(function(player)returnTimes[player]=nil end)
    local prompt=camp.ToolShop.Upgrade.Interact
    prompt.Triggered:Connect(function(player)
        local state=states[player]
        if not state or not within(player,camp.ToolShop.Upgrade,15)then return end
        local costs={16,48}
        local cost=costs[state.tier]
        if not cost then note(player,"本次试玩已升满");return end
        if not Inventory.Spend(player,cost)then note(player,"还需要 "..cost.." 金币升级");return end
        state.tier+=1
        player:SetAttribute("ToolTier",state.tier)
        -- Tool upgrades add a permanent amount of power for this session.
        state.power+=({0,15,45})[state.tier]
        player:SetAttribute("Power",state.power)
        note(player,"工具升级，力量增加")
    end)
    local accumulator,boards=0,0
    RunService.Heartbeat:Connect(function(dt)
        accumulator+=dt;boards+=dt
        if accumulator>=.15 then local elapsed=accumulator;accumulator=0;stepTraining(elapsed)end
        if boards>=2 then boards=0;updateBoards()end
    end)
end

return Service
