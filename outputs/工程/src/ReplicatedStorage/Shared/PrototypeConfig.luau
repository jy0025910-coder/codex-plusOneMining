return {
    Version = 1,
    TrainingInterval = .8,
    HitInterval = .38,
    Trainings = {
        {Name="砂岩练习石", Gain=1, Required=0, Color=Color3.fromRGB(199,151,98)},
        {Name="青铜矿簇", Gain=3, Required=30, Color=Color3.fromRGB(73,180,163)},
        {Name="紫晶矿簇", Gain=6, Required=100, Color=Color3.fromRGB(163,113,219)},
    },
    Layers = {
        {Name="浅层铜脉", WallHealth=100, OreHealth=45, RareChance=.10, Color=Color3.fromRGB(211,145,86)},
        {Name="青晶回廊", WallHealth=300, OreHealth=90, RareChance=.15, Color=Color3.fromRGB(77,199,176)},
        {Name="紫晶深处", WallHealth=900, OreHealth=180, RareChance=.20, Color=Color3.fromRGB(164,120,222)},
    },
}
