-- One source for the approved mining HUD palette, art and preview content.
local Theme = {}
Theme.Colors = {
    Ink=Color3.fromRGB(12,24,35), Slate=Color3.fromRGB(35,57,73),
    Teal=Color3.fromRGB(22,184,168), TealDark=Color3.fromRGB(12,116,120),
    Amber=Color3.fromRGB(255,188,34), Orange=Color3.fromRGB(241,138,16),
    Cream=Color3.fromRGB(255,244,209), Purple=Color3.fromRGB(146,107,225),
    White=Color3.fromRGB(255,255,255), Steel=Color3.fromRGB(92,125,153),
}
Theme.Icons = {
    Pickaxe="rbxassetid://140555305371223",
    Backpack="rbxassetid://102271797036965", Currency="rbxassetid://105302444263341",
    Rebirth="rbxassetid://92301858592436", Shop="rbxassetid://137695969149889",
    Wheel="rbxassetid://126494586189170", Upgrade="rbxassetid://124675921997614",
    Collection="rbxassetid://112658581546029", Idle="rbxassetid://129176837191977",
    Friends="rbxassetid://99576971828611",
}
Theme.Menus = {
    {Id="Shop",Label="商店",Color="Amber"}, {Id="Wheel",Label="幸运轮",Color="Teal"},
    {Id="Pickaxe",Label="铁镐",Color="Teal"}, {Id="Upgrade",Label="强化",Color="Teal"},
    {Id="Rebirth",Label="重生",Color="Purple"}, {Id="Collection",Label="图鉴",Color="Teal"},
    {Id="Idle",Label="挂机",Color="Teal"}, {Id="Friends",Label="好友",Color="Teal"},
}
-- Visual placeholders only. No product IDs or MarketplaceService calls in this slice.
Theme.Preview = {Level=4, XP=58, NextXP=68, DoublePrice=9}
Theme.Offers = {
    {Amount=150,Price=15}, {Amount=600,Price=49}, {Amount=1500,Price=79},
}
return Theme
