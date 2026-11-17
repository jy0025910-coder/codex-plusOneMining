local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local Shared=game.ReplicatedStorage:WaitForChild("Shared")
local Balance=require(Shared.GameBalance)
local Big=require(Shared.BigInteger)
local wire=game.ReplicatedStorage:WaitForChild("DigCamp")
local gui=player.PlayerGui:WaitForChild("MiningPanels",30)
if not gui then warn("MiningPanels did not replicate");return end
local panel=gui.Panel
local hudGui=player.PlayerGui:WaitForChild("MiningHUD",30)
if not hudGui then warn("MiningHUD did not replicate");return end
local hud=hudGui.Root
local template=gui.Templates.Row
local active="Shop"
local pending=false
local rowOrder=0
local function attribute(name,default)
    local value=player:GetAttribute(name)
    return value==nil and default or value
end
local function add(name,detail,action,enabled,callback)
    local item=template:Clone()
    item.Name="Entry"
    rowOrder+=1
    item.LayoutOrder=rowOrder
    item.Visible=true
    item:FindFirstChild("Name").Text=name
    item.Detail.Text=detail
    item.Action.Text=action or ""
    item.Action.Visible=action~=nil
    item.Action.Active=enabled==true
    item.Action.AutoButtonColor=enabled==true
    item.Action.BackgroundColor3=enabled and Color3.fromRGB(111,207,234) or Color3.fromRGB(176,185,173)
    if callback then item.Action.Activated:Connect(function()if enabled then callback()end end) end
    item.Parent=panel.List
end
local function request(kind,value)
    wire.Action:FireServer(kind,value)
end
local function render()
    if not gui.Enabled then return end
    local scroll=panel.List.CanvasPosition
    rowOrder=0
    for _,child in panel.List:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
    local power=attribute("Power","1")
    local coins=attribute("Coins","0")
    local rebirths=attribute("Rebirths",0)
    local tier=attribute("ToolTier",1)
    local route=attribute("RouteIndex",1)
    local depth=math.min(10,attribute("DeepestLayer",0)+1)
    panel.Title.Text=({Shop="镐子商店",Routes="选择矿道",Rebirth="重生与训练",Collection="矿石图鉴",Secrets="隐藏收藏与秘技"})[active]
    panel.Summary.Text="力量 "..Big.Format(power).." · 矿币 "..Big.Format(coins).." · "..attribute("Level",1).." 级 · 重生 "..rebirths.." / 20"
    if active=="Shop" then
        for i,tool in Balance.Tools do
            local owned=attribute("ToolOwned"..i,false)
            local accessible=rebirths>=tool.Rebirth
            local affordable=Big.Compare(coins,tool.Price)>=0
            local equipped=tier==i
            local action=equipped and "已装备" or owned and "装备" or i==10 and "隐藏掉落" or not accessible and "重生 "..tool.Rebirth or "购买"
            add(tool.Name,"力量 ×"..tool.Multiplier.."  品质 ×"..tool.Quality/100
                .."\n"..(i==10 and "隐藏获得，普通矿道也有机会发现" or ("售价 "..Big.Format(tool.Price).." 矿币")),
                action,not equipped and (owned or i~=10 and accessible and affordable),
                function()request(owned and "Equip" or "Buy",i)end)
        end
    elseif active=="Routes" then
        for i,mine in Balance.Routes do
            local accessible=rebirths>=mine.Required
            add(mine.Label.." · "..mine.Name,"十层 · 首墙 "..Big.Format(mine.Walls[1]).."\n"..(mine.Required==0 and "直接进入" or ("重生 "..mine.Required.." 次开放")),
                accessible and "进矿 / 重进" or "未开放",accessible,function()request("Route",i);gui.Enabled=false end)
        end
    elseif active=="Rebirth" then
        local can=attribute("Level",1)==50 and rebirths<20
        add("本轮 "..attribute("Level",1).." / 50 级","达到 50 级后重生，力量回到 1，镐、矿币和收藏保留。",
            rebirths>=20 and "已满二十次" or "重生",can,function()request("Rebirth")end)
        add("训练加成 ×"..Big.Format(Big.Power(4,rebirths)),"训练增量 = 区域倍率 × 镐倍率 × 重生加成\n经验与力量同步增加")
        for _,area in Balance.Trainings do
            add(area.Multiplier.."× 训练区","每次增加 "..Big.Format(Balance.TrainingGain(area.Multiplier,tier,rebirths)).." 力量 / 经验",
                rebirths>=area.Required and "已开放" or "需重生 "..area.Required,false)
        end
    elseif active=="Collection" then
        panel.Message.Text="带回绿色光幕出售后点亮图鉴。当前 "..attribute("CollectionCount",0).." / 50 · 本轮试玩按会话保存。"
        for i,ore in Balance.Minerals do
            local known=attribute("Discovered"..i,false)
            local value=Balance.Price(i,route,depth,Balance.Tools[tier].Quality)
            add((known and "✓ " or "◇ ")..ore.Name,ore.Fact.."\n主产 "..Balance.Routes[ore.Route].Name.." · 当前层参考 "..Big.Format(value).." 币",
                known and "已收录" or "待带回",false)
        end
    else
        panel.Message.Text="一次装备一个秘技。聚财影响出售收益，镐品质在出矿时记录。"
        add("卸下当前秘技","恢复普通收益与伤害。","卸下",attribute("EquippedSecret",0)~=0,function()request("Secret",0)end)
        for i,item in Balance.Secrets do
            local known=attribute("SecretOwned"..i,false)
            local equipped=attribute("EquippedSecret",0)==i
            add((known and "✓ " or "◇ ")..item.Name,item.Description,
                not known and "未发现" or equipped and "已装备" or "装备",known and not equipped,function()request("Secret",i)end)
        end
    end
    if active~="Collection" and active~="Secrets" then panel.Message.Text="五格背包 · 返回绿色光幕自动出售 · 按 G 打开或关闭手册" end
    panel.List.CanvasPosition=scroll
end
local function open(tab)
    active=tab
    gui.Enabled=true
    panel.List.CanvasPosition=Vector2.zero
    render()
end
panel.Close.Activated:Connect(function()gui.Enabled=false end)
for _,button in panel.Tabs:GetChildren() do
    if button:IsA("TextButton") then button.Activated:Connect(function()open(button.Name)end) end
end
local links={Shop="Shop",Pickaxe="Shop",Rebirth="Rebirth",Upgrade="Routes",Collection="Collection",Wheel="Secrets"}
for name,tab in links do hud.MenuGrid[name].Activated:Connect(function()open(tab)end) end
hud.MenuGrid.Idle.Activated:Connect(function()open("Rebirth")end)
wire.OpenPanel.OnClientEvent:Connect(open)
wire.Feedback.OnClientEvent:Connect(function(mode,message)
    if mode=="note" and gui.Enabled then panel.Message.Text=message end
end)
player.AttributeChanged:Connect(function()
    if not gui.Enabled or pending then return end
    pending=true
    task.delay(.3,function()pending=false;render()end)
end)
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.G then
        if gui.Enabled then gui.Enabled=false else open("Routes") end
    end
end)
