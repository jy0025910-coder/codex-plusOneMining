const priceSheets = [
    '20 26 34 42 55 95 160 380 950 2500',
    '420 650 900 1400 2100 3800 7000 16000 48000 120000',
    '25000 40000 65000 100000 160000 400000 1200000 4000000 14000000 48000000',
    '8000000 14000000 22000000 36000000 58000000 160000000 600000000 2500000000 12000000000 70000000000',
    '12000000000 18000000000 25000000000 40000000000 60000000000 320000000000 2000000000000 18000000000000 180000000000000 2500000000000000'
];
const startingPrices = priceSheets.flatMap(row => row.split(' '));
const extraStops = ['砂灯岔口', '背风台', '余温栈', '冰晶岔口', '星盘前庭'];
// Each route has one modestly priced specimen which can appear in any mine.
for (const [route, value] of ['20','30','45','65','90'].entries()) startingPrices[route*10] = value;
const grouped = value => BigInt(value).toLocaleString('en-US');
const validPrice = value => typeof value === 'string' && /^(0|[1-9]\d{0,29})$/.test(value);

function compact(value) {
    const n = BigInt(value);
    const suffixes = ['', 'K', 'M', 'B', 'T', 'P', 'E'];
    let unit = 1n;
    let index = 0;
    while (index < suffixes.length - 1 && n >= unit * 1000n) {
        unit *= 1000n;
        index++;
    }
    if (!index) return String(n);
    let tenths = (n * 10n + unit / 2n) / unit;
    if (tenths === 10000n && index < suffixes.length - 1) {
        tenths = 10n;
        index++;
    }
    return String(tenths / 10n) + (tenths % 10n ? '.' + String(tenths % 10n) : '') + suffixes[index];
}

function stopNames(route, count) {
    const names = [...catalog.routes[route].stops];
    if (count === 10) names.splice(8, 0, extraStops[route]);
    return names;
}

const themes = [
    {label:'人间', name:'砂灯旧坑', start:10, end:60, tool:1, luck:0, effect:'旧矿灯照亮入口，行走与挥镐均为常速。'},
    {label:'风峡', name:'鸣风铜峡', start:75, end:400, tool:2, luck:0.65, effect:'风袋拉直两秒后吹出横风。站在挡风柱背面可避开后退。'},
    {label:'火焰', name:'余烬炉脉', start:500, end:2500, tool:4, luck:1.30, effect:'脚下红纹提前两秒亮起。连续踩热地两秒，镐伤减半，回冷砖两秒恢复。'},
    {label:'寒冰', name:'蓝镜冰窟', start:3000, end:15000, tool:8, luck:1.95, effect:'霜面移动速度降至 65%，走绳纹地恢复。'},
    {label:'神域', name:'天衡星庭', start:18000, end:100000, tool:12, luck:2.60, effect:'照门楣的三枚星纹踩踏板可走近路，踩错回上一格。'}
];
const secretItems = [
    ['灯影短剑','纪念剑','装备时点亮矿灯，标出返程灯站。'],
    ['砂声石','奇石','摆入展柜，轻敲会听见旧矿车的回声。'],
    ['乘风步谱','秘技','装备后移动速度提高 15%，方便往返搬矿。'],
    ['回响铜心','奇石','每面墙破开后，以铜铃声提示是否出现外道矿。'],
    ['余烬长剑','纪念剑','佩戴时显示火道冷却砖的方位。'],
    ['赤阳锻力经','秘技','装备后有效力量提高 12%，用于入层门槛与敲墙伤害。'],
    ['凝霜定息诀','秘技','装备后冰地步速由正常的 65% 提高到 85%。'],
    ['冻光琥珀','奇石','展柜中可旋转观察被封存的古叶。'],
    ['观星寻脉录','秘技','装备后每墙隐藏率加 0.5‰，仍受总上限约束。'],
    ['星图罗盘镐','隐藏镐','12× 镐，能指示已发现的地标，与其他镐互换装备。']
];
const firstFloors = [1,1,1,2,3,4,5,6,7];
const firstLayer = (ore, count) => firstFloors[ore.rank] ?? count;
const defaultWeights = [27,21,16,12,9,6,4,2.7,1.6,0.7];
const entryTools = [1,2,4,8,12];

function wallSpec(route, layer, count) {
    const theme = themes[route];
    const progress = (layer - 1) / (count - 1);
    const required = Math.round(theme.start * (theme.end / theme.start) ** progress);
    const targetHits = Math.round(6 + route + (3 + route * 0.75) * progress);
    return {required, targetHits, hp: required * entryTools[route] * targetHits};
}
function oreDistribution(route, layer, count, settings) {
    const requirement = wallSpec(route, layer, count).required;
    const groups = themes.map((_, source) => {
        const pool = catalog.minerals.filter(ore => {
            if (ore.route !== source || firstLayer(ore, count) > layer) return false;
            return source === route || ore.rank === 0 || wallSpec(source, firstLayer(ore, count), count).required <= requirement;
        });
        return {pool, total:pool.reduce((sum,ore) => sum + settings.weights[ore.id-1], 0)};
    });
    return catalog.minerals.map(ore => {
        const group = groups[ore.route];
        const share = (ore.route === route ? 100 - settings.foreign : settings.foreign / 4) / 100;
        const p = group.pool.includes(ore) ? share * settings.weights[ore.id-1] / group.total : 0;
        return {ore, p};
    });
}
function perWall(p) {
    return [3,4,5].reduce((sum,n) => sum - Math.expm1(n * Math.log1p(-p)),0) / 3;
}
function sample(rows, rng = Math.random) {
    let ticket = rng();
    for (const row of rows) {
        ticket -= row.p;
        if (row.p > 0 && ticket < 0) return row;
    }
    return rows.findLast(row => row.p > 0);
}
function hiddenOdds(route, layer, multiplier, strength, cap, skill) {
    const strengthBonus = Math.min(2, Math.log10(strength) * 0.4);
    const terms = [2, themes[route].luck, (layer-1)*0.4, (multiplier-1)*0.2, strengthBonus, skill === 'star' ? 0.5 : 0];
    const raw = terms.reduce((sum, v) => sum+v, 0);
    const perMille = Math.min(cap,raw);
    const rows = secretItems.map((item,i) => {
        const source = Math.floor(i/2);
        const share = source === route ? 0.8 : 0.05;
        return {item, i, p: share * (i%2 ? 0.4 : 0.6)};
    });
    return {terms,raw,perMille,rows};
}
function breakWall(distribution, odds, route, rng = Math.random) {
    const n = 3 + Math.floor(rng()*3);
    const minerals = Array.from({length:n}, () => sample(distribution,rng).ore);
    const prize = rng() < odds.perMille/1000 ? {hidden:sample(odds.rows,rng).i} : {coins:[10,200,10000,4000000,6000000000][route]};
    return {minerals,prize,perMille:odds.perMille,opened:false};
}
