local Style = require(script.Parent.MiningStyle)
return {
    Version = 2,
    TrainingInterval = .8 / Style.AutoSwingSpeed,
    HitInterval = .38,
    Hub = {HalfSize=84, RoadHalfWidth=13, MineFront=-78, Arrival=Vector3.new(0,.3,64)},
    Trainings = {
        {Name="巨型铜矿", Gain=1, Required=0, Color=Color3.fromRGB(255,177,68), StoneColor=Color3.fromRGB(231,161,91), Scale=2.65, Stretch=Vector3.new(1.13,1.08,1), Height=10.6, Position=Vector3.new(-60,.24,30)},
        {Name="青晶矿簇", Gain=3, Required=30, Color=Color3.fromRGB(53,244,207), StoneColor=Color3.fromRGB(92,171,187), Scale=2.45, Stretch=Vector3.new(.95,1.05,1.08), Height=11.8, Crown="MintCrystal", Position=Vector3.new(-60,.24,0)},
        {Name="紫晶矿簇", Gain=6, Required=100, Color=Color3.fromRGB(193,118,255), StoneColor=Color3.fromRGB(148,112,201), Scale=2.65, Stretch=Vector3.new(1.03,.98,1.08), Height=12.6, Crown="Amethyst", Position=Vector3.new(-60,.24,-30)},
    },
    Layers = {
        {Name="浅层铜脉", WallHealth=100, OreHealth=45, RareChance=.10, Color=Color3.fromRGB(211,145,86)},
        {Name="青晶回廊", WallHealth=300, OreHealth=90, RareChance=.15, Color=Color3.fromRGB(77,199,176)},
        {Name="紫晶深处", WallHealth=900, OreHealth=180, RareChance=.20, Color=Color3.fromRGB(164,120,222)},
    },
}
