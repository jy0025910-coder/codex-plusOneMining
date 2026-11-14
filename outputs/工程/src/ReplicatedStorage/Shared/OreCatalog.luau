-- Item ids are stable save/network identifiers. Only the server grants items.
local OreCatalog = {}

OreCatalog.Capacity = 5
OreCatalog.Items = {
    Stone = { Name = "石块", Value = 3, Color = Color3.fromRGB(165, 164, 151) },
    Copper = { Name = "铜矿", Value = 7, Color = Color3.fromRGB(229, 154, 89) },
    MintCrystal = { Name = "青晶矿", Value = 18, Color = Color3.fromRGB(87, 219, 196) },
    Amethyst = { Name = "紫晶矿", Value = 32, Color = Color3.fromRGB(191, 140, 240) },
    Gold = { Name = "金矿", Value = 50, Color = Color3.fromRGB(251, 201, 79) },
}

return OreCatalog
