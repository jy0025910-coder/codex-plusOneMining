local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local shared=game.ReplicatedStorage:WaitForChild("Shared")
local Theme=require(shared:WaitForChild("HUDTheme"))
local Layout=require(shared:WaitForChild("HUDLayout"))
local p=Players.LocalPlayer
local gui=p:WaitForChild("PlayerGui"):WaitForChild("MiningHUD")
local root=gui:WaitForChild("Root")
local connections={}
local menuOpen,offersOpen=false,false
local function connect(event,fn)table.insert(connections,event:Connect(fn))end
local function comma(value)
    local text=tostring(math.floor(tonumber(value)or 0))
    local result,n=text,0
    repeat result,n=result:gsub("^(-?%d+)(%d%d%d)","%1,%2")until n==0
    return result
end
local function refresh()
    root.ResourceList.BackpackRow.Value.Text=comma(p:GetAttribute("Ore")).." / "..comma(p:GetAttribute("Capacity")or 5)
    root.ResourceList.CurrencyRow.Value.Text=comma(p:GetAttribute("Coins"))
    root.ResourceList.RebirthRow.Value.Text=comma(p:GetAttribute("Rebirths"))
    local head=root.TopRow.LevelHeader
    head.Power.Text="力量 "..comma(p:GetAttribute("Power")or 1)
    local live=p:GetAttribute("Level")~=nil and p:GetAttribute("XP")~=nil and p:GetAttribute("NextXP")~=nil
    local level=live and p:GetAttribute("Level")or Theme.Preview.Level
    local xp=live and p:GetAttribute("XP")or Theme.Preview.XP
    local maximum=math.max(1,live and p:GetAttribute("NextXP")or Theme.Preview.NextXP)
    head.LevelBadge.Label.Text="等级 "..comma(level)
    head.ProgressTrack.ProgressText.Text=comma(xp).." / "..comma(maximum)
    head.ProgressTrack.Fill.Size=UDim2.fromScale(math.clamp(xp/maximum,0,1),1)
    head.Remaining.Text="还差 "..comma(math.max(0,maximum-xp)).." 升级"..(live and ""or " · 示例")
    head:SetAttribute("UsesPreviewProgress",not live)
end
local function resize()
    root.MenuToggle.Label.Text=menuOpen and "收起"or "菜单"
    root.OffersToggle.Label.Text=offersOpen and "收起"or "礼包"
    Layout.Apply(root,root.AbsoluteSize,menuOpen,offersOpen)
end
local notice=0
local function preview(message)
    notice+=1;local id=notice
    root.Status.Toast.Text=message
    task.delay(2.2,function()if gui.Parent and notice==id and root.Status.Toast.Text==message then root.Status.Toast.Text=""end end)
end
connect(root.MenuToggle.Activated,function()
    menuOpen=not menuOpen;offersOpen=false
    root.MenuToggle.Label.Text=menuOpen and "收起"or "菜单";resize()
end)
connect(root.OffersToggle.Activated,function()
    offersOpen=not offersOpen;menuOpen=false
    root.OffersToggle.Label.Text=offersOpen and "收起"or "礼包";resize()
end)
for _,item in Theme.Menus do
    connect(root.MenuGrid[item.Id].Activated,function()preview(item.Label.." · 界面展示，功能稍后接入")end)
end
for _,tile in root.PowerOffers:GetChildren()do
    if tile:IsA("TextButton")then connect(tile.Activated,function()preview("力量礼包展示 · 暂未开放购买")end)end
end
connect(root.TopRow.MultiplierOffer.Activated,function()preview("双倍力量展示 · 暂未开放购买")end)
local tweens={}
for _,button in root:GetDescendants()do
    if button:IsA("TextButton")then
        local scale=button:FindFirstChild("InteractionScale")
        local function animate(value)
            if tweens[button]then tweens[button]:Cancel()end
            if GuiService.ReducedMotionEnabled then scale.Scale=1;return end
            local tween=TweenService:Create(scale,TweenInfo.new(.1),{Scale=value})
            tweens[button]=tween;tween:Play()
        end
        connect(button.MouseEnter,function()animate(1.025)end)
        connect(button.MouseLeave,function()animate(1)end)
        connect(button.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(.97)end
        end)
        connect(button.InputEnded,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(1)end
        end)
    end
end
for _,key in {"Ore","Capacity","Coins","Power","Rebirths","Level","XP","NextXP"}do connect(p:GetAttributeChangedSignal(key),refresh)end
connect(root:GetPropertyChangedSignal("AbsoluteSize"),resize)
connect(script.Destroying,function()
    for _,connection in connections do connection:Disconnect()end
    for _,tween in tweens do tween:Cancel()end
end)
refresh();resize();gui.Enabled=true
task.spawn(function()
    local images={}
    for _,o in root:GetDescendants()do if o:IsA("ImageLabel")then table.insert(images,o)end end
    local ok,err=pcall(function()game:GetService("ContentProvider"):PreloadAsync(images)end)
    if not ok then warn("MiningHUD icon preload: "..tostring(err))end
end)
