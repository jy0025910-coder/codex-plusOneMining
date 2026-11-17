local Factory = {}
local function text(parent,name,content,size)
    local label=Instance.new("TextLabel")
    label.Name=name;label.Text=content;label.Font=Enum.Font.FredokaOne
    label.TextSize=size or 18;label.TextColor3=Color3.fromRGB(35,52,61)
    label.BackgroundTransparency=1;label.TextXAlignment=Enum.TextXAlignment.Left
    label.Parent=parent
    return label
end
local function button(parent,name,content)
    local result=Instance.new("TextButton")
    result.Name=name;result.Text=content;result.Font=Enum.Font.FredokaOne;result.TextSize=17
    result.TextColor3=Color3.fromRGB(24,47,60);result.BackgroundColor3=Color3.fromRGB(115,212,237)
    result.BorderSizePixel=0;result.Parent=parent
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=result
    local line=Instance.new("UIStroke");line.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;line.Thickness=2;line.Color=Color3.fromRGB(42,68,77);line.Parent=result
    return result
end
function Factory.Build(parent)
    local previous=parent:FindFirstChild("MiningPanels")
    if previous then previous:Destroy() end
    local gui=Instance.new("ScreenGui")
    gui.Name="MiningPanels";gui.ResetOnSpawn=false;gui.Enabled=false;gui.DisplayOrder=30
    local panel=Instance.new("Frame")
    panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5)
    panel.Size=UDim2.fromScale(.90,.84);panel.BackgroundColor3=Color3.fromRGB(249,240,213);panel.Parent=gui
    local max=Instance.new("UISizeConstraint");max.MaxSize=Vector2.new(920,720);max.Parent=panel
    local round=Instance.new("UICorner");round.CornerRadius=UDim.new(0,14);round.Parent=panel
    local outline=Instance.new("UIStroke");outline.Thickness=4;outline.Color=Color3.fromRGB(40,60,70);outline.Parent=panel
    local title=text(panel,"Title","矿工手册",25);title.Position=UDim2.fromOffset(16,10);title.Size=UDim2.new(1,-70,0,35)
    local close=button(panel,"Close","×");close.AnchorPoint=Vector2.new(1,0);close.Position=UDim2.new(1,-12,0,10);close.Size=UDim2.fromOffset(40,35)
    local summary=text(panel,"Summary","",14);summary.Position=UDim2.fromOffset(16,49);summary.Size=UDim2.new(1,-32,0,42);summary.TextWrapped=true
    local tabs=Instance.new("Frame");tabs.Name="Tabs";tabs.BackgroundTransparency=1;tabs.Position=UDim2.fromOffset(14,96);tabs.Size=UDim2.new(1,-28,0,36);tabs.Parent=panel
    local layout=Instance.new("UIListLayout");layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.FillDirection=Enum.FillDirection.Horizontal;layout.Padding=UDim.new(0,5);layout.Parent=tabs
    for index,tab in {{"Shop","矿镐"},{"Routes","矿道"},{"Rebirth","重生"},{"Collection","图鉴"},{"Secrets","秘技"}} do
        local b=button(tabs,tab[1],tab[2]);b.LayoutOrder=index;b.Size=UDim2.new(.19,0,1,0)
    end
    local list=Instance.new("ScrollingFrame")
    list.Name="List";list.Position=UDim2.fromOffset(14,144);list.Size=UDim2.new(1,-28,1,-198)
    list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=5
    list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
    local stack=Instance.new("UIListLayout");stack.SortOrder=Enum.SortOrder.LayoutOrder;stack.Padding=UDim.new(0,8);stack.Parent=list
    local message=text(panel,"Message","",14);message.Position=UDim2.new(0,16,1,-45);message.Size=UDim2.new(1,-32,0,36);message.TextWrapped=true
    local templates=Instance.new("Folder");templates.Name="Templates";templates.Parent=gui
    local row=Instance.new("Frame");row.Name="Row";row.Visible=false;row.Size=UDim2.new(1,-8,0,100);row.BackgroundColor3=Color3.fromRGB(224,234,220);row.BorderSizePixel=0;row.Parent=templates
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=row
    local name=text(row,"Name","",18);name.Position=UDim2.fromOffset(10,5);name.Size=UDim2.new(1,-112,0,28)
    local detail=text(row,"Detail","",13);detail.Position=UDim2.fromOffset(10,34);detail.Size=UDim2.new(1,-118,1,-39);detail.TextWrapped=true;detail.TextYAlignment=Enum.TextYAlignment.Top
    local action=button(row,"Action","");action.AnchorPoint=Vector2.new(1,.5);action.Position=UDim2.new(1,-9,.5,0);action.Size=UDim2.fromOffset(96,46);action.TextWrapped=true;action.TextSize=15
    gui.Parent=parent
    return gui
end
return Factory
