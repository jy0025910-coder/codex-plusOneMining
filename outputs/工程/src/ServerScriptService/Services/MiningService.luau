local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Collection = game:GetService("CollectionService")
local Shared = game.ReplicatedStorage.Shared
local Balance = require(Shared.GameBalance)
local Big = require(Shared.BigInteger)
local Config = require(Shared.PrototypeConfig)
local Inventory = require(script.Parent.InventoryService)
local Equipment = require(script.Parent.MiningAssets)
local Motion = require(script.Parent.MiningMotion)
local Style = require(Shared.MiningStyle)
local wire = game.ReplicatedStorage.DigCamp
local Service = {}
local states = {}
local rng = Random.new()
local camp
local started = false

local function living(player)
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if root and humanoid and humanoid.Health>0 then return root,humanoid end
end
local function note(player,message)
    wire.Feedback:FireClient(player,"note",message)
end
local function sync(player,state)
    local level,xp,nextXP=Balance.LevelProgress(state.xp,state.rebirths)
    player:SetAttribute("Power",state.power)
    player:SetAttribute("Level",level)
    player:SetAttribute("XP",xp)
    player:SetAttribute("NextXP",nextXP)
    player:SetAttribute("TotalXP",state.xp)
    player:SetAttribute("Rebirths",state.rebirths)
    player:SetAttribute("ToolTier",state.tier)
    player:SetAttribute("ToolQuality",Balance.Tools[state.tier].Quality)
    player:SetAttribute("Damage",Balance.Damage(state.power,state.tier,state.secret,false))
    player:SetAttribute("RouteIndex",state.route)
    player:SetAttribute("DeepestLayer",state.unlocked)
    player:SetAttribute("EquippedSecret",state.secret)
    local discoveries=0
    for id=1,10 do
        local owned=state.secrets[id]==true
        player:SetAttribute("SecretOwned"..id,owned)
        if owned then discoveries+=1 end
    end
    player:SetAttribute("HiddenCount",discoveries)
    for id=1,10 do player:SetAttribute("ToolOwned"..id,state.tools[id]==true) end
    for i=1,10 do
        player:SetAttribute("Gate"..i.."HP",state.gates[i])
        player:SetAttribute("Gate"..i.."Max",Balance.Routes[state.route].Walls[i])
    end
end
local function updateTool(player,state)
    local tool=Equipment.GetEquipped(player.Character)
    if tool then
        tool.Name=Balance.Tools[state.tier].Name
        tool:SetAttribute("PowerMultiplier",Balance.Tools[state.tier].Multiplier)
        tool:SetAttribute("QualityMultiplier",Balance.Tools[state.tier].Quality/100)
        tool.ToolTip="力量 ×"..Balance.Tools[state.tier].Multiplier.." · 品质 ×"..Balance.Tools[state.tier].Quality/100
    end
end
local function grantStrength(player,state,area)
    local gain=Balance.TrainingGain(area,state.tier,state.rebirths)
    state.power=Big.Add(state.power,gain)
    state.xp=Big.Add(state.xp,gain)
    sync(player,state)
    return gain
end
local function resetMine(player,state,route)
    state.route=route
    state.unlocked=0
    state.gates=table.clone(Balance.Routes[route].Walls)
    state.batch=nil
    state.batchId+=1
    Motion.Stop(player)
    wire.Feedback:FireClient(player,"clearDrops")
    sync(player,state)
end
local function init(player)
    if states[player] then return end
    local state={power="1",xp="0",rebirths=0,tier=1,tools={[1]=true},secrets={},secret=0,
        route=1,unlocked=0,gates=table.clone(Balance.Routes[1].Walls),batchId=0,batch=nil,
        lastPractice=0,lastHit=0,lastAction=0,lastNote=0,training=0}
    states[player]=state
    Inventory.Create(player)
    player:SetAttribute("CollectionCount",0)
    player:SetAttribute("ProgressStorage","Session")
    local function equip(character)
        local humanoid=character:WaitForChild("Humanoid",10)
        local backpack=player:WaitForChild("Backpack",10)
        if not humanoid or not backpack or player.Character~=character then return end
        Equipment.Equip(player,character,humanoid,backpack)
        updateTool(player,state)
    end
    player.CharacterAdded:Connect(equip)
    if player.Character then task.spawn(equip,player.Character) end
    sync(player,state)
end
function Service.Practice(player)
    local state=states[player]
    if not state or not living(player) or not Equipment.GetEquipped(player.Character) then return end
    local now=os.clock()
    if now-state.lastPractice<Config.PracticeInterval then return end
    state.lastPractice=now
    wire.Feedback:FireClient(player,"practice",nil,grantStrength(player,state,1))
end
local function reveal(player,state,index)
    local quality=Balance.Tools[state.tier].Quality
    local gate=camp.Mine["Layer"..index].Gate
    local batch={}
    for i=1,5 do
        local id=Balance.RollMineral(state.route,index,rng)
        table.insert(batch,{
            Id=id,Value=Balance.Price(id,state.route,index,quality),Quality=quality,
            Position=gate.Position+Vector3.new((i-3)*4,-3.5,-9),Taken=false})
    end
    if rng:NextNumber()<Balance.HiddenChance(state.route,index,state.tier,state.power,state.secret) then
        table.insert(batch,{Secret=Balance.RollSecret(state.route,rng),
            Position=gate.Position+Vector3.new(0,-2,-15),Taken=false})
    end
    state.batchId+=1;state.batch=batch
    wire.Feedback:FireClient(player,"reveal",state.batchId,batch)
end
local function hitGate(player,state,gate)
    local index=gate:GetAttribute("LayerIndex")
    if index~=state.unlocked+1 or os.clock()-state.lastHit<Config.HitInterval then return end
    local root=living(player)
    if not root or not Equipment.GetEquipped(player.Character) then return end
    local point=gate.CFrame:PointToObjectSpace(root.Position)
    if math.abs(point.X)>13 or point.Z<0 or point.Z>Config.AutoGateDistance then return end
    if state.batch then
        for _,drop in state.batch do
            if not drop.Taken then
                if os.clock()-state.lastNote>4 then note(player,"先拾取本层掉落，或回营出售后重新进矿");state.lastNote=os.clock() end
                return
            end
        end
    end
    state.lastHit=os.clock()
    local damage=Balance.Damage(state.power,state.tier,state.secret,player:GetAttribute("Overheated")==true)
    state.gates[index]=Big.Subtract(state.gates[index],damage)
    player:SetAttribute("Gate"..index.."HP",state.gates[index])
    Motion.Play(player,gate,Style.AutoSwingSpeed)
    wire.Feedback:FireClient(player,"hit",gate,state.gates[index],Balance.Routes[state.route].Walls[index])
    if state.gates[index]=="0" then
        state.unlocked=index
        player:SetAttribute("DeepestLayer",index)
        reveal(player,state,index)
        note(player,"矿墙打通！五块矿石已出现，走近拾取")
    end
end
local function pickup(player,state,batchId,index)
    if type(batchId)~="number" or type(index)~="number" or index%1~=0 or not state.batch or batchId~=state.batchId then return end
    local item=state.batch[index]
    local root=living(player)
    if not item or item.Taken or not root or (root.Position-item.Position).Magnitude>12 then return end
    if item.Secret then
        item.Taken=true
        state.secrets[item.Secret]=true
        if item.Secret==10 then state.tools[10]=true end
        sync(player,state)
        note(player,"发现隐藏款 · "..Balance.Secrets[item.Secret].Name)
    else
        if not Inventory.Add(player,{Id=item.Id,Value=item.Value,Quality=item.Quality}) then note(player,"五格背包已满，回绿色光幕出售");return end
        item.Taken=true
        note(player,Balance.Minerals[item.Id].Name.." · "..Big.Format(item.Value).." 矿币")
    end
    wire.Feedback:FireClient(player,"pickup",batchId,index)
end
local function action(player,kind,value,extra)
    local state=states[player]
    if not state or not living(player) or type(kind)~="string" then return end
    if kind=="Pickup" then pickup(player,state,value,extra);return end
    if os.clock()-state.lastAction<.2 then return end
    state.lastAction=os.clock()
    if kind=="Buy" or kind=="Equip" then
        if type(value)~="number" or value%1~=0 or not Balance.Tools[value] then return end
        local tool=Balance.Tools[value]
        if kind=="Buy" and not state.tools[value] then
            if value==10 then note(player,"罗盘镐来自隐藏掉落");return end
            if state.rebirths<tool.Rebirth then note(player,"此镐需重生 "..tool.Rebirth.." 次");return end
            if not Inventory.Spend(player,tool.Price) then note(player,"矿币不足，售价 "..Big.Format(tool.Price));return end
            state.tools[value]=true
        end
        if not state.tools[value] then return end
        state.tier=value;updateTool(player,state);sync(player,state)
        note(player,"已装备 "..tool.Name.." · 品质 ×"..tool.Quality/100)
    elseif kind=="Route" then
        if type(value)~="number" or value%1~=0 or not Balance.Routes[value] then return end
        if state.rebirths<Balance.Routes[value].Required then note(player,"此矿道需重生 "..Balance.Routes[value].Required.." 次");return end
        if Inventory.Count(player)>0 then note(player,"先到绿色光幕出售背包里的矿，再重新进矿");return end
        resetMine(player,state,value)
        player.Character:PivotTo(camp.Mine.Layer1.Gate.CFrame*CFrame.new(0,-2,7))
        note(player,"进入 "..Balance.Routes[value].Name.." · 靠近墙自动挥镐")
    elseif kind=="Rebirth" then
        if state.rebirths>=20 then note(player,"已完成二十次重生");return end
        if Balance.LevelProgress(state.xp,state.rebirths)<50 then note(player,"本轮达到 50 级即可重生");return end
        state.rebirths+=1;state.power="1";state.xp="0"
        resetMine(player,state,1)
        player.Character:PivotTo(camp.Arrival.CFrame*CFrame.new(0,3,0))
        note(player,"重生成功！训练加成 ×"..Big.Format(Big.Power(4,state.rebirths)))
    elseif kind=="Secret" then
        if type(value)~="number" or value%1~=0 or value<0 or value>10 then return end
        if value~=0 and not state.secrets[value] then return end
        if value==10 then
            state.tier=10;updateTool(player,state)
        else state.secret=value end
        sync(player,state)
        note(player,value==0 and "已卸下秘技" or "已装备 "..Balance.Secrets[value].Name)
    end
end
local function trainingAt(state,root)
    for _,zone in Collection:GetTagged("TrainingZone") do
        if not zone:IsDescendantOf(camp.Training) then continue end
        local point=zone.CFrame:PointToObjectSpace(root.Position)
        local half=zone.Size*.5
        if math.abs(point.X)<=half.X and math.abs(point.Y)<=half.Y and math.abs(point.Z)<=half.Z then
            local index=zone:GetAttribute("TrainingIndex")
            local profile=Balance.Trainings[index]
            if profile and state.rebirths>=profile.Required then
                return profile.Multiplier,camp.Training["TrainingRock"..index].Target
            end
            return 0,nil,profile and profile.Required
        end
    end
    return 0
end
local function step(dt)
    for player,state in states do
        local root,humanoid=living(player)
        if not root then continue end
        local area,rock,locked=trainingAt(state,root)
        local equipped=Equipment.GetEquipped(player.Character)
        if not equipped then area=0 end
        if locked and os.clock()-state.lastNote>4 then note(player,"此训练区需重生 "..locked.." 次");state.lastNote=os.clock() end
        player:SetAttribute("TrainingGain",area)
        local nextRoom=camp.Mine:FindFirstChild("Layer"..(state.unlocked+1))
        local inMine=root.Position.Z<-76
        local hot=inMine and state.route==3 and (os.clock()%8)>5
        player:SetAttribute("Overheated",hot)
        local walkSpeed=inMine and state.route==4 and 10.4 or 16
        humanoid.WalkSpeed=state.secret==3 and walkSpeed*1.15 or walkSpeed
        if area>0 then
            state.training+=dt
            if state.training>=Config.TrainingInterval then
                state.training=0
                local gain=grantStrength(player,state,area)
                Motion.Play(player,rock,Style.AutoSwingSpeed)
                wire.Feedback:FireClient(player,"train",rock,gain,Style.AutoSwingSpeed)
            end
            player:SetAttribute("AutoMining",false)
        else
            state.training=0
            local near=equipped and nextRoom and (root.Position-nextRoom.Gate.Position).Magnitude<19
            player:SetAttribute("AutoMining",near==true)
            if near then hitGate(player,state,nextRoom.Gate) end
        end
        if nextRoom then
            local point=nextRoom.Gate.CFrame:PointToObjectSpace(root.Position)
            if point.Z<-.9 and math.abs(point.X)<18 then
                player.Character:PivotTo(nextRoom.Gate.CFrame*CFrame.new(0,-2,4))
            end
        end
    end
end
local function updateBoards()
    local rankings=camp:FindFirstChild("Rankings")
    if not rankings then return end
    for _,spec in {{"Power","CollectionCount","矿石图鉴榜"},{"Coins","HiddenCount","隐藏收藏榜"}} do
        local model=rankings:FindFirstChild(spec[1])
        local board=model and model:FindFirstChild("Board")
        local frame=board and board.Scores.Frame
        if not frame then continue end
        frame.Title.Text=spec[3]
        local list=Players:GetPlayers()
        table.sort(list,function(a,b)
            local av,bv=a:GetAttribute(spec[2])or 0,b:GetAttribute(spec[2])or 0
            return av==bv and a.UserId<b.UserId or av>bv
        end)
        for i=1,6 do
            local p=list[i]
            frame["Row"..i].Text=p and (i.."  "..p.DisplayName.."  "..(p:GetAttribute(spec[2])or 0)) or ""
        end
    end
end
function Service.Start()
    if started then return end
    started=true
    camp=require(script.Parent.ProgressionWorld).Build(require(script.Parent.WorldBuilder).Build())
    for _,name in {"Action","OpenPanel"} do
        if not wire:FindFirstChild(name) then local event=Instance.new("RemoteEvent");event.Name=name;event.Parent=wire end
    end
    Players.PlayerAdded:Connect(init)
    Players.PlayerRemoving:Connect(function(player)states[player]=nil;Motion.Stop(player)end)
    for _,player in Players:GetPlayers() do init(player) end
    wire.Practice.OnServerEvent:Connect(Service.Practice)
    wire.Action.OnServerEvent:Connect(action)
    wire.ReturnToCamp.OnServerEvent:Connect(function(player)
        local state=states[player]
        if state and living(player) and os.clock()-(state.returnAt or 0)>1 then
            state.returnAt=os.clock();Motion.Stop(player)
            player.Character:PivotTo(camp.Arrival.CFrame*CFrame.new(0,3,0))
        end
    end)
    camp.ToolShop.Upgrade.Interact.Triggered:Connect(function(player)
        local root=living(player)
        if root and (root.Position-camp.ToolShop.Upgrade.Position).Magnitude<15 then wire.OpenPanel:FireClient(player,"Shop") end
    end)
    for _,entrance in camp.MineEntrances:GetChildren() do
        if entrance:IsA("BasePart") and entrance:FindFirstChild("ChooseMine") then
            entrance.ChooseMine.Triggered:Connect(function(player)
                local root=living(player)
                if root and (root.Position-entrance.Position).Magnitude<15 then action(player,"Route",entrance:GetAttribute("RouteIndex")) end
            end)
        end
    end
    local elapsed,boardTime=0,0
    Run.Heartbeat:Connect(function(dt)
        elapsed+=dt
        boardTime+=dt
        if boardTime>=2 then boardTime=0;updateBoards() end
        if elapsed<.05 then return end
        local delta=elapsed;elapsed=0;step(delta)
    end)
end
return Service
