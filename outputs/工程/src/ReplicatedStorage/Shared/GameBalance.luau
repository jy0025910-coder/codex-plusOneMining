-- Approved v5 economy snapshot. Decimal prices and XP are exact.
local Balance = {
    Minerals = {{
        Id = 1,
        Name = "砂岩",
        Route = 1,
        Rank = 1,
        Type = "岩石",
        Fact = "砂粒胶结成岩，耐用的品种可做建筑石材。",
        Hex = "dba774",
        Base = "20"
    },{
        Id = 2,
        Name = "石灰岩",
        Route = 1,
        Rank = 2,
        Type = "岩石",
        Fact = "主要含碳酸钙，是制造水泥的重要原料。",
        Hex = "b8b6a8",
        Base = "30"
    },{
        Id = 3,
        Name = "石膏",
        Route = 1,
        Rank = 3,
        Type = "矿物",
        Fact = "石膏经加工能做墙板，也能用来翻制模型。",
        Hex = "e7d4ba",
        Base = "45"
    },{
        Id = 4,
        Name = "页岩",
        Route = 1,
        Rank = 4,
        Type = "岩石",
        Fact = "细泥固结成层，常可沿薄层分开，部分可用于制砖。",
        Hex = "898a94",
        Base = "70"
    },{
        Id = 5,
        Name = "花岗岩",
        Route = 1,
        Rank = 5,
        Type = "岩石",
        Fact = "可见几种交错的晶粒，常被切成台面或铺路石。",
        Hex = "c4aeb1",
        Base = "110"
    },{
        Id = 6,
        Name = "板岩",
        Route = 1,
        Rank = 6,
        Type = "岩石",
        Fact = "常沿平整的面劈成薄片，可作屋瓦。",
        Hex = "788790",
        Base = "180"
    },{
        Id = 7,
        Name = "方解石",
        Route = 1,
        Rank = 7,
        Type = "矿物",
        Fact = "透明晶体能让线条出现双影，可用来演示双折射。",
        Hex = "f1cba5",
        Base = "320"
    },{
        Id = 8,
        Name = "岩盐",
        Route = 1,
        Rank = 8,
        Type = "矿物",
        Fact = "其主要成分是氯化钠；提纯后有食用和工业用途。",
        Hex = "f2baba",
        Base = "650"
    },{
        Id = 9,
        Name = "石墨",
        Route = 1,
        Rank = 9,
        Type = "矿物",
        Fact = "片层容易滑动，所以能在纸上留下铅笔笔迹。",
        Hex = "616978",
        Base = "1500"
    },{
        Id = 10,
        Name = "白水晶",
        Route = 1,
        Rank = 10,
        Type = "宝石",
        Fact = "无色石英可作饰品；石英晶体的压电性质也用于计时。",
        Hex = "cee6eb",
        Base = "4000"
    },{
        Id = 11,
        Name = "赤铁矿",
        Route = 2,
        Rank = 1,
        Type = "金属矿物",
        Fact = "炼铁的重要原料；磨成的粉末常为红褐色。",
        Hex = "a35b4c",
        Base = "24"
    },{
        Id = 12,
        Name = "磁铁矿",
        Route = 2,
        Rank = 2,
        Type = "金属矿物",
        Fact = "常能被磁铁明显吸引，也是铁矿石的重要组成。",
        Hex = "596577",
        Base = "36"
    },{
        Id = 13,
        Name = "黄铜矿",
        Route = 2,
        Rank = 3,
        Type = "金属矿物",
        Fact = "黄铜色的晶粒是提取铜的重要来源。",
        Hex = "d4a848",
        Base = "54"
    },{
        Id = 14,
        Name = "孔雀石",
        Route = 2,
        Rank = 4,
        Type = "矿物",
        Fact = "天然色带可琢成装饰石，也曾被用作绿色颜料。",
        Hex = "2fac77",
        Base = "84"
    },{
        Id = 15,
        Name = "蓝铜矿",
        Route = 2,
        Rank = 5,
        Type = "矿物",
        Fact = "鲜蓝的铜矿物，历史上曾被研制成蓝色颜料。",
        Hex = "347eb7",
        Base = "132"
    },{
        Id = 16,
        Name = "黄铁矿",
        Route = 2,
        Rank = 6,
        Type = "矿物",
        Fact = "表面像金子，立方晶形常被用作观察晶体的标本。",
        Hex = "b69c51",
        Base = "216"
    },{
        Id = 17,
        Name = "自然铜",
        Route = 2,
        Rank = 7,
        Type = "自然元素",
        Fact = "天然金属铜可呈枝状；铜导电好，常做电线。",
        Hex = "c47b50",
        Base = "384"
    },{
        Id = 18,
        Name = "锡石",
        Route = 2,
        Rank = 8,
        Type = "金属矿物",
        Fact = "主要的锡矿物；锡可用于制造焊料。",
        Hex = "957263",
        Base = "780"
    },{
        Id = 19,
        Name = "菱铁矿",
        Route = 2,
        Rank = 9,
        Type = "金属矿物",
        Fact = "含铁的碳酸盐，可用作铁的来源。",
        Hex = "b59b7a",
        Base = "1800"
    },{
        Id = 20,
        Name = "绿松石",
        Route = 2,
        Rank = 10,
        Type = "宝石",
        Fact = "蓝绿相间，适于磨成弧面，用作镶嵌饰件。",
        Hex = "48c1b5",
        Base = "4800"
    },{
        Id = 21,
        Name = "玄武岩",
        Route = 3,
        Rank = 1,
        Type = "岩石",
        Fact = "熔岩在地表较快冷却形成，可用作铺路骨料。",
        Hex = "696673",
        Base = "28"
    },{
        Id = 22,
        Name = "浮石",
        Route = 3,
        Rank = 2,
        Type = "岩石",
        Fact = "火山玻璃中有许多气孔，常作轻质或磨料材料。",
        Hex = "c6aca1",
        Base = "42"
    },{
        Id = 23,
        Name = "黑曜石",
        Route = 3,
        Rank = 3,
        Type = "火山玻璃",
        Fact = "断面有贝壳般弧纹，抛光后可作装饰。",
        Hex = "544e66",
        Base = "63"
    },{
        Id = 24,
        Name = "硫黄",
        Route = 3,
        Rank = 4,
        Type = "自然元素",
        Fact = "天然硫常呈黄色；工业硫是生产硫酸的原料。",
        Hex = "e4ca52",
        Base = "98"
    },{
        Id = 25,
        Name = "铬铁矿",
        Route = 3,
        Rank = 5,
        Type = "金属矿物",
        Fact = "是铬的重要来源；铬是不锈钢中的关键成分。",
        Hex = "777881",
        Base = "154"
    },{
        Id = 26,
        Name = "钛铁矿",
        Route = 3,
        Rank = 6,
        Type = "金属矿物",
        Fact = "可用于生产钛白粉，让涂料呈现明亮白色。",
        Hex = "787187",
        Base = "252"
    },{
        Id = 27,
        Name = "石榴石",
        Route = 3,
        Rank = 7,
        Type = "宝石族",
        Fact = "除了做首饰，一些品种还磨成工业磨料。",
        Hex = "b54e59",
        Base = "448"
    },{
        Id = 28,
        Name = "橄榄石",
        Route = 3,
        Rank = 8,
        Type = "矿物",
        Fact = "透明美丽的黄绿色晶体可作宝石，称为贵橄榄石。",
        Hex = "a2bc56",
        Base = "910"
    },{
        Id = 29,
        Name = "红玉髓",
        Route = 3,
        Rank = 9,
        Type = "宝石",
        Fact = "橙红的玉髓常被雕成印章或串珠。",
        Hex = "d37652",
        Base = "2100"
    },{
        Id = 30,
        Name = "红宝石",
        Route = 3,
        Rank = 10,
        Type = "宝石",
        Fact = "红色的宝石级刚玉；微量铬赋予它鲜艳的颜色。",
        Hex = "c94b62",
        Base = "5600"
    },{
        Id = 31,
        Name = "大理岩",
        Route = 4,
        Rank = 1,
        Type = "岩石",
        Fact = "石灰岩等受变质作用形成，可用于雕刻或饰面。",
        Hex = "d4dbdf",
        Base = "32"
    },{
        Id = 32,
        Name = "滑石",
        Route = 4,
        Rank = 2,
        Type = "矿物",
        Fact = "质地很软，在工业中可作造纸或涂料的填料。",
        Hex = "aaccbe",
        Base = "48"
    },{
        Id = 33,
        Name = "白云母",
        Route = 4,
        Rank = 3,
        Type = "矿物",
        Fact = "能剥成很薄的片，耐热绝缘，可用于电器。",
        Hex = "d7c8a3",
        Base = "72"
    },{
        Id = 34,
        Name = "萤石",
        Route = 4,
        Rank = 4,
        Type = "矿物",
        Fact = "用于冶金等领域；部分标本在紫外光下会发光。",
        Hex = "9b8ed7",
        Base = "112"
    },{
        Id = 35,
        Name = "重晶石",
        Route = 4,
        Rank = 5,
        Type = "矿物",
        Fact = "拿起来比外表看起来重，常给钻井泥浆加重。",
        Hex = "c9b9b0",
        Base = "176"
    },{
        Id = 36,
        Name = "天青石",
        Route = 4,
        Rank = 6,
        Type = "矿物",
        Fact = "是锶的矿物来源；锶盐可使焰火呈红色。",
        Hex = "9dc8dd",
        Base = "288"
    },{
        Id = 37,
        Name = "烟晶",
        Route = 4,
        Rank = 7,
        Type = "宝石",
        Fact = "是褐色到烟灰色的石英，可切磨成宝石。",
        Hex = "a28e82",
        Base = "512"
    },{
        Id = 38,
        Name = "月光石",
        Route = 4,
        Rank = 8,
        Type = "宝石",
        Fact = "特定长石内部的微细层会散射光，形成漂浮般的光晕。",
        Hex = "b6cde6",
        Base = "1040"
    },{
        Id = 39,
        Name = "海蓝宝石",
        Route = 4,
        Rank = 9,
        Type = "宝石",
        Fact = "蓝色到绿蓝色的绿柱石，常被切成通透的刻面宝石。",
        Hex = "65c9da",
        Base = "2400"
    },{
        Id = 40,
        Name = "蓝宝石",
        Route = 4,
        Rank = 10,
        Type = "宝石",
        Fact = "是宝石级刚玉的一类，除了蓝色也有其他颜色。",
        Hex = "507ebb",
        Base = "6400"
    },{
        Id = 41,
        Name = "拉长石",
        Route = 5,
        Rank = 1,
        Type = "矿物",
        Fact = "转动某些标本会看见变彩，常作装饰石。",
        Hex = "76969f",
        Base = "36"
    },{
        Id = 42,
        Name = "玛瑙",
        Route = 5,
        Rank = 2,
        Type = "宝石",
        Fact = "常见分层的色带，适合雕刻或切片观察。",
        Hex = "c29687",
        Base = "54"
    },{
        Id = 43,
        Name = "紫水晶",
        Route = 5,
        Rank = 3,
        Type = "宝石",
        Fact = "紫色石英可长成晶簇，常作观赏矿物与饰品。",
        Hex = "aa85c9",
        Base = "81"
    },{
        Id = 44,
        Name = "黄水晶",
        Route = 5,
        Rank = 4,
        Type = "宝石",
        Fact = "从淡黄到棕橙的透明石英可切成刻面宝石。",
        Hex = "e3b560",
        Base = "126"
    },{
        Id = 45,
        Name = "碧玺",
        Route = 5,
        Rank = 5,
        Type = "宝石族",
        Fact = "属于电气石族；同一晶体有时可见多种颜色。",
        Hex = "5caa89",
        Base = "198"
    },{
        Id = 46,
        Name = "托帕石",
        Route = 5,
        Rank = 6,
        Type = "宝石",
        Fact = "常被切磨作宝石，硬度高却可能沿特定方向裂开。",
        Hex = "dbae8a",
        Base = "324"
    },{
        Id = 47,
        Name = "尖晶石",
        Route = 5,
        Rank = 7,
        Type = "宝石",
        Fact = "红色的尖晶石曾被误当红宝石，实际是另一种矿物。",
        Hex = "cf7d9f",
        Base = "576"
    },{
        Id = 48,
        Name = "欧泊",
        Route = 5,
        Rank = 8,
        Type = "宝石材料",
        Fact = "一些欧泊的微小结构会分开不同色光，产生变彩。",
        Hex = "c5d9c4",
        Base = "1170"
    },{
        Id = 49,
        Name = "祖母绿",
        Route = 5,
        Rank = 9,
        Type = "宝石",
        Fact = "绿色的绿柱石，与海蓝宝石属于同一矿物种。",
        Hex = "559b79",
        Base = "2700"
    },{
        Id = 50,
        Name = "金刚石",
        Route = 5,
        Rank = 10,
        Type = "矿物",
        Fact = "硬度很高，可做切削和研磨工具；宝石级可作钻石。",
        Hex = "cfdef5",
        Base = "7200"
    }},
    Tools = {{
        Name = "营地铁镐",
        Multiplier = 1,
        Quality = 100,
        Price = "0",
        Rebirth = 0
    },{
        Name = "铜尺勘镐",
        Multiplier = 1.5,
        Quality = 110,
        Price = "150",
        Rebirth = 0
    },{
        Name = "风标轮镐",
        Multiplier = 2,
        Quality = 120,
        Price = "9500",
        Rebirth = 0
    },{
        Name = "赤鳍炉镐",
        Multiplier = 3,
        Quality = 135,
        Price = "127600",
        Rebirth = 1
    },{
        Name = "黑曜陶镐",
        Multiplier = 4,
        Quality = 150,
        Price = "864800",
        Rebirth = 2
    },{
        Name = "霜鳍凿镐",
        Multiplier = 6,
        Quality = 175,
        Price = "11215700",
        Rebirth = 3
    },{
        Name = "深蓝螺旋镐",
        Multiplier = 8,
        Quality = 200,
        Price = "340917600",
        Rebirth = 5
    },{
        Name = "紫曜环轨镐",
        Multiplier = 10,
        Quality = 230,
        Price = "9061248000",
        Rebirth = 7
    },{
        Name = "日冕铸镐",
        Multiplier = 12,
        Quality = 260,
        Price = "4292462400000",
        Rebirth = 10
    },{
        Name = "星图罗盘镐",
        Multiplier = 12,
        Quality = 300,
        Price = "0",
        Rebirth = 0
    }},
    Routes = {{
        Name = "砂灯旧坑",
        Label = "人间",
        Hex = "dba774",
        Luck = 1,
        Required = 0,
        Walls = {"500","1420","4030","11400","32500","92300","262000","744000","2110000","6000000"}
    },{
        Name = "鸣风铜峡",
        Label = "风峡",
        Hex = "a35b4c",
        Luck = 1.15,
        Required = 2,
        Walls = {"1200000","2720000","6150000","13900000","31500000","71400000","162000000","366000000","828000000","1875000000"}
    },{
        Name = "余烬炉脉",
        Label = "火焰",
        Hex = "696673",
        Luck = 1.35,
        Required = 5,
        Walls = {"375000000","802000000","1720000000","3670000000","7850000000","16800000000","35900000000","76800000000","164000000000","351562500000"}
    },{
        Name = "蓝镜冰窟",
        Label = "寒冰",
        Hex = "d4dbdf",
        Luck = 1.5,
        Required = 8,
        Walls = {"70312500000","124000000000","219000000000","387000000000","683000000000","1210000000000","2130000000000","3760000000000","6640000000000","11718750000000"}
    },{
        Name = "天衡星庭",
        Label = "神域",
        Hex = "76969f",
        Luck = 1.8,
        Required = 10,
        Walls = {"2343750000000","16600000000000","117000000000000","827000000000000","5840000000000000","41300000000000000","292000000000000000","2060000000000000000","14600000000000000000","102996826171875000000"}
    }},
    Secrets = {{
        Id = 1,
        Name = "灯影短剑",
        Kind = "纪念剑",
        Description = "点亮返程矿灯。",
        Route = 1
    },{
        Id = 2,
        Name = "砂声石",
        Kind = "奇石",
        Description = "陈列并记录发现者。",
        Route = 1
    },{
        Id = 3,
        Name = "乘风步谱",
        Kind = "身法",
        Description = "装备时移速 ×1.15。",
        Route = 2
    },{
        Id = 4,
        Name = "回响铜心",
        Kind = "奇石",
        Description = "陈列时泛青铜光。",
        Route = 2
    },{
        Id = 5,
        Name = "聚财盆",
        Kind = "聚财",
        Description = "装备时出售矿石收入 ×2。",
        Route = 3
    },{
        Id = 6,
        Name = "丰藏秘卷",
        Kind = "聚财",
        Description = "装备时出售矿石收入 ×3。",
        Route = 3
    },{
        Id = 7,
        Name = "磐岩锻力经",
        Kind = "锻力",
        Description = "装备时伤害 ×1.5。",
        Route = 4
    },{
        Id = 8,
        Name = "玄霜锻力诀",
        Kind = "锻力",
        Description = "装备时伤害 ×2。",
        Route = 4
    },{
        Id = 9,
        Name = "观星寻脉录",
        Kind = "幸运",
        Description = "装备时隐藏总率 ×1.25。",
        Route = 5
    },{
        Id = 10,
        Name = "星图罗盘镐",
        Kind = "隐藏镐",
        Description = "装备时镐倍率为 12×。",
        Route = 5
    }},
    LevelXP = {"4","5","5","6","6","7","8","9","10","11","12","13","14","16","17","19","21","23","26","28","31","34","38","42","46","51","56","62","68","75","82","90","99","109","120","132","146","160","176","194","214","235","259","284","313","344","379","417","484"},
    Trainings = {{
        Multiplier = 1,
        Required = 0
    },{
        Multiplier = 2,
        Required = 0
    },{
        Multiplier = 4,
        Required = 2
    },{
        Multiplier = 6,
        Required = 5
    },{
        Multiplier = 8,
        Required = 8
    },{
        Multiplier = 10,
        Required = 10
    }},
    Weights = {30,22,16,11,8,5,3.5,2.3,1.4,0.8},
    DeepWeights = {22,19,16,12,10,8,5,4,2.5,1.5}
}

local Big = require(script.Parent.BigInteger)
function Balance.TrainingGain(area, tier, rebirths)
    local value = tostring(area * math.round(Balance.Tools[tier].Multiplier * 100))
    for _ = 1, rebirths do value = Big.Multiply(value,4) end
    return Big.Divide(value,100)
end
function Balance.Damage(power, tier, secret, hot)
    local value = Big.Divide(Big.Multiply(power,math.round(Balance.Tools[tier].Multiplier*100)),100)
    if secret == 7 then value = Big.Divide(Big.Multiply(value,3),2) end
    if secret == 8 then value = Big.Multiply(value,2) end
    if hot then value = Big.Divide(value,2) end
    return Big.Compare(value,"1") < 0 and "1" or value
end
function Balance.LevelProgress(xp, rebirths)
    local left = xp
    for level = 1, 49 do
        local needed = Balance.LevelXP[level]
        for _ = 1, rebirths do needed = Big.Multiply(needed,5) end
        if Big.Compare(left,needed) < 0 then return level,left,needed end
        left = Big.Subtract(left,needed)
    end
    return 50,"1","1"
end
function Balance.Price(id, route, depth, quality)
    local value = Balance.Minerals[id].Base
    for _ = 2, route do value = Big.Multiply(value,100) end
    value = Big.Multiply(value,2^(depth-1))
    return Big.Divide(Big.Multiply(value,quality),100)
end
function Balance.Distribution(route, depth)
    local rows, totals = {}, {0,0,0,0,0}
    for _,ore in Balance.Minerals do
        local weight = Balance.Weights[ore.Rank]
        weight *= 1 + (Balance.DeepWeights[ore.Rank]/Balance.Weights[ore.Rank]-1)*(depth-1)/9
        totals[ore.Route] += weight
        table.insert(rows,{Id=ore.Id,Weight=weight})
    end
    for _,row in rows do
        local source = Balance.Minerals[row.Id].Route
        row.Probability = (source==route and .94 or .015)*row.Weight/totals[source]
    end
    return rows
end
function Balance.RollMineral(route, depth, rng)
    local ticket = rng:NextNumber()
    for _,row in Balance.Distribution(route,depth) do
        ticket -= row.Probability
        if ticket <= 0 then return row.Id end
    end
    return 50
end
function Balance.HiddenChance(route, depth, tier, power, secret)
    local strengthBonus = 1 + math.min(1,math.log10(math.max(1,tonumber(power)))/12)
    local perSlot = .001*Balance.Routes[route].Luck*(1+.18*(depth-1))
        *(1+.06*(Balance.Tools[tier].Multiplier-1))*strengthBonus*(secret==9 and 1.25 or 1)
    perSlot = math.min(.01,perSlot)
    return 1-(1-perSlot)^5
end
function Balance.RollSecret(route, rng)
    local total = 0
    for _,item in Balance.Secrets do total += item.Route==route and 4 or 1 end
    local ticket = rng:NextNumber()*total
    for _,item in Balance.Secrets do
        ticket -= item.Route==route and 4 or 1
        if ticket <= 0 then return item.Id end
    end
    return 10
end
return Balance
