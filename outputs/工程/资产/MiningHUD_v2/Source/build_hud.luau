-- Edit-time authoring: creates editable Instances once, never at player runtime.
local shared=game.ReplicatedStorage.Shared
local fresh=shared.HUDTheme:Clone();fresh.Parent=shared
local T=require(fresh);fresh:Destroy()
local decorModule=shared.HUDDecor:Clone();decorModule.Parent=shared
local Decor=require(decorModule);decorModule:Destroy()
local C=T.Colors
local function make(class,name,parent,props)
    local o=Instance.new(class);o.Name=name
    for k,v in props or {}do o[k]=v end
    o.Parent=parent;return o
end
local function corner(o,r)make("UICorner","Corners",o,{CornerRadius=UDim.new(0,r or 10)})end
local function stroke(o,width,color)
    return make("UIStroke","Outline",o,{Color=color or C.Ink,Thickness=width or 3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,LineJoinMode=Enum.LineJoinMode.Round})
end
local function gradient(o,a,b)
    make("UIGradient","Tint",o,{Color=ColorSequence.new(a,b),Rotation=90})
end
local function frame(name,parent,props)
    props=props or {};props.BorderSizePixel=0
    return make("Frame",name,parent,props)
end
local function label(name,parent,text,size,props)
    local p={BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamBlack,TextSize=size or 22,
        TextColor3=C.White,TextStrokeTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=4}
    for k,v in props or {}do p[k]=v end
    local o=make("TextLabel",name,parent,p)
    make("UIStroke","TextInk",o,{Color=C.Ink,Thickness=2,LineJoinMode=Enum.LineJoinMode.Round})
    return o
end
local function icon(name,parent,id,size,pos)
    return make("ImageLabel",name,parent,{BackgroundTransparency=1,Image=T.Icons[id],ScaleType=Enum.ScaleType.Fit,
        Size=size or UDim2.fromScale(1,1),Position=pos or UDim2.new(),ZIndex=3})
end
local function button(name,parent,color)
    local o=make("TextButton",name,parent,{Text="",BackgroundColor3=color,BorderSizePixel=0,
        AutoButtonColor=false,Selectable=true,ZIndex=2})
    corner(o,7);stroke(o,3)
    make("UIScale","InteractionScale",o,{Scale=1})
    return o
end
local gui=make("ScreenGui","MiningHUD",nil,{ResetOnSpawn=false,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=3,Enabled=false})
gui:SetAttribute("AssetId","UI.MiningHUD");gui:SetAttribute("AssetVersion",2)
gui:SetAttribute("PurchasesEnabled",false)
local root=frame("Root",gui,{BackgroundTransparency=1,Size=UDim2.fromScale(1,1)})
local top=frame("TopRow",root,{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,10),Size=UDim2.fromOffset(934,90)})
local head=frame("LevelHeader",top,{BackgroundColor3=C.Slate,Size=UDim2.fromOffset(720,54)})
corner(head,10);stroke(head,3);gradient(head,C.Steel,C.Slate)
local badge=frame("LevelBadge",head,{BackgroundColor3=C.Amber,Size=UDim2.fromOffset(132,54)})
corner(badge,10);stroke(badge,3);gradient(badge,C.Amber,C.Orange)
label("Label",badge,"等级 4",29)
local track=frame("ProgressTrack",head,{BackgroundColor3=C.Ink,Size=UDim2.new(1,-145,0,42),Position=UDim2.fromOffset(139,6),ClipsDescendants=true})
corner(track,8)
local fill=frame("Fill",track,{BackgroundColor3=C.Amber,Size=UDim2.fromScale(T.Preview.XP/T.Preview.NextXP,1)})
corner(fill,8);gradient(fill,C.Amber,C.Orange)
label("ProgressText",track,"58 / 68",28)
label("Remaining",head,"还差 10 升级 · 示例",17,{Position=UDim2.new(.24,0,1,4),Size=UDim2.new(.76,0,0,23)})
label("Power",head,"力量 1",19,{Position=UDim2.new(0,0,1,4),Size=UDim2.new(.25,0,0,23),TextColor3=C.Cream})
local multi=button("MultiplierOffer",top,C.MenuBlue)
multi.Position=UDim2.fromOffset(734,0);multi.Size=UDim2.fromOffset(200,76)
icon("FirstPickaxe",multi,"Pickaxe",UDim2.new(.35,0,.87,0),UDim2.fromScale(.01,.04))
local second=icon("SecondPickaxe",multi,"Pickaxe",UDim2.new(.35,0,.87,0),UDim2.fromScale(.13,.04));second.Rotation=10
label("Multiplier",multi,"×2",24,{Position=UDim2.fromScale(.23,.48),Size=UDim2.fromScale(.23,.44),Font=Enum.Font.FredokaOne})
label("Label",multi,"双倍力量",24,{Position=UDim2.fromScale(.44,.04),Size=UDim2.fromScale(.53,.42)})
local multiPrice=label("Price",multi,"R$ 9",23,{BackgroundTransparency=0,BackgroundColor3=C.TealDark,Position=UDim2.fromScale(.48,.52),Size=UDim2.fromScale(.47,.38),Font=Enum.Font.FredokaOne})
corner(multiPrice,6)
local menu=frame("MenuGrid",root,{BackgroundTransparency=1,BackgroundColor3=C.Slate,Position=UDim2.fromOffset(16,140),Size=UDim2.fromOffset(172,376)})
corner(menu,10)
make("UIGridLayout","Grid",menu,{CellSize=UDim2.fromOffset(82,88),CellPadding=UDim2.fromOffset(8,8),FillDirectionMaxCells=2,SortOrder=Enum.SortOrder.LayoutOrder})
for i,item in T.Menus do
    local tile=button(item.Id,menu,C[item.Color]);tile.LayoutOrder=i
    tile:SetAttribute("PreviewOnly",true)
    local art=icon("Icon",tile,item.Id,UDim2.new(1,-10,1,-23),UDim2.new(.5,0,0,1));art.AnchorPoint=Vector2.new(.5,0)
    label("Label",tile,item.Label,19,{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,25)})
end
local menuToggle=button("MenuToggle",root,C.MenuBlue);menuToggle.Visible=false;menuToggle.Size=UDim2.fromOffset(58,58)
icon("Icon",menuToggle,"Shop",UDim2.new(1,-8,1,-19),UDim2.fromOffset(4,0))
label("Label",menuToggle,"菜单",14,{Position=UDim2.fromScale(0,.68),Size=UDim2.fromScale(1,.3)})
local resources=frame("ResourceList",root,{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-20),Size=UDim2.fromOffset(226,154)})
make("UIListLayout","List",resources,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
for i,item in {{"Backpack","背包","0 / 5"},{"Currency","金币","0"},{"Rebirth","重生","0"}}do
    local row=frame(item[1].."Row",resources,{BackgroundTransparency=1,Size=UDim2.fromOffset(282,52),LayoutOrder=i})
    Decor.ResourceShade(row)
    local art=icon("Icon",row,item[1],UDim2.fromOffset(54,54),UDim2.new(0,26,.5,0));art.AnchorPoint=Vector2.new(.5,.5)
    label("Label",row,item[2],17,{Position=UDim2.fromOffset(54,0),Size=UDim2.new(0,48,1,0)})
    local value=label("Value",row,item[3],42,{Position=UDim2.fromOffset(62,0),Size=UDim2.new(1,-68,1,0),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.FredokaOne,TextColor3=i==2 and C.Money or C.White})
    value.TextInk.Thickness=3.5
end
local offers=frame("PowerOffers",root,{BackgroundTransparency=1,Size=UDim2.fromOffset(218,293),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-16,.46,0)})
make("UIListLayout","List",offers,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
for i,item in T.Offers do
    local tile=button("Offer"..i,offers,C.Cream);tile.LayoutOrder=i;tile.Size=UDim2.fromOffset(178,132)
    tile.BackgroundTransparency=1;tile.Outline:Destroy();tile.Corners:Destroy()
    tile:SetAttribute("PreviewOnly",true)
    Decor.Burst(tile)
    local art=icon("Icon",tile,"Pickaxe",UDim2.fromScale(.68,.7),UDim2.fromScale(.5,.37));art.AnchorPoint=Vector2.new(.5,.5)
    local formatted=i==3 and "1,500"or tostring(item.Amount)
    local amount=label("Label",tile,"+"..formatted,38,{Position=UDim2.fromScale(0,.68),Size=UDim2.fromScale(1,.3),Font=Enum.Font.FredokaOne})
    amount.TextInk.Thickness=3.5
    local price=label("Price",tile,"R$ "..item.Price,24,{Position=UDim2.fromScale(.56,.06),Size=UDim2.fromScale(.44,.26),Font=Enum.Font.FredokaOne,TextColor3=C.Money})
    price.TextInk.Thickness=3
end
local offersToggle=button("OffersToggle",root,C.MenuGold);offersToggle.Visible=false;offersToggle.AnchorPoint=Vector2.new(1,0);offersToggle.Size=UDim2.fromOffset(58,58)
icon("Icon",offersToggle,"Pickaxe",UDim2.new(1,-8,1,-19),UDim2.fromOffset(4,0))
label("Label",offersToggle,"礼包",14,{Position=UDim2.fromScale(0,.68),Size=UDim2.fromScale(1,.3)})
local status=frame("Status",root,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
label("Guide",status,"点击 +1 力量 · 走近矿石自动敲击",15,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-8),Size=UDim2.fromOffset(600,26),Font=Enum.Font.GothamBold})
label("Toast",status,"",22,{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,102),Size=UDim2.fromOffset(620,48),Font=Enum.Font.GothamBold})
label("Target",status,"",20,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-76),Size=UDim2.fromOffset(600,32),Font=Enum.Font.GothamBold})
local ret=button("ReturnToCamp",root,C.MenuBlue);ret.AnchorPoint=Vector2.new(1,1);ret.Size=UDim2.fromOffset(132,32);ret.Position=UDim2.new(1,-16,1,-45)
label("Label",ret,"返回休息站",15)
label("PreviewNote",root,"界面预览 · 商品未开放",12,{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-8),Size=UDim2.fromOffset(220,24),TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.GothamBold})
local old=game.StarterGui:FindFirstChild(gui.Name)
gui.Parent=game.StarterGui;if old then old:Destroy()end
return {path=gui:GetFullName(),descendants=#gui:GetDescendants()}
