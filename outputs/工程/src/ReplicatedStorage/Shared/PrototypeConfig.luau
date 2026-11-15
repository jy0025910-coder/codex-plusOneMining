local Style = require(script.Parent.MiningStyle)
return {
    Version = 2,
    TrainingInterval = .8 / Style.AutoSwingSpeed,
    HitInterval = .38,
    Hub = {HalfSize=84, RoadHalfWidth=13, MineFront=-78, Arrival=Vector3.new(0,.3,64)},
    Trainings = {
        {Name="基础练习石", Gain=1, Required=0, Color=Color3.fromRGB(255,209,70), StoneColor=Color3.fromRGB(117,111,134), PracticeAsset="PracticeRock_A_Classic", PracticeScale=1, PracticeYaw=-math.pi/2, Height=6.5, Position=Vector3.new(-60,.24,30)},
        {Name="符文练习石", Gain=3, Required=30, Color=Color3.fromRGB(118,221,245), StoneColor=Color3.fromRGB(17,157,221), PracticeAsset="PracticeRock_B_Rune", PracticeScale=1, PracticeYaw=-math.pi/2, Height=6.5, Position=Vector3.new(-60,.24,0)},
        {Name="层岩练习石", Gain=6, Required=100, Color=Color3.fromRGB(193,145,237), StoneColor=Color3.fromRGB(143,85,209), PracticeAsset="PracticeRock_C_Layered", PracticeScale=1, PracticeYaw=-math.pi/2, Height=6.5, Position=Vector3.new(-60,.24,-30)},
    },
    Layers = {
        {Name="浅层铜脉", WallHealth=100, OreHealth=45, RareChance=.10, Color=Color3.fromRGB(211,145,86)},
        {Name="青晶回廊", WallHealth=300, OreHealth=90, RareChance=.15, Color=Color3.fromRGB(77,199,176)},
        {Name="紫晶深处", WallHealth=900, OreHealth=180, RareChance=.20, Color=Color3.fromRGB(164,120,222)},
    },
}
