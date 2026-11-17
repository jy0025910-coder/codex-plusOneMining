const toolQualityPercent = [100,110,120,135,150,175,200,230,260,300];
function qualityPercent() { return toolQualityPercent[Number($('tool').value)]; }
function qualityValue(oreId, mineRoute, depth, quality=qualityPercent()) {
    return mineralPrice(oreId,mineRoute,depth)*BigInt(quality)/100n;
}
function droppedValue(item) {
    if(item.unitPrice!==undefined) return BigInt(item.unitPrice);
    return qualityValue(item.oreId,item.sourceRoute,item.sourceDepth,item.qualityPercent??100);
}
const routePriceFactors = [1n,100n,10000n,1000000n,100000000n];
const toolMilestones = [
    {rebirth:0,route:0,depth:1,bags:0},
    {rebirth:0,route:0,depth:1,bags:0},
    {rebirth:0,route:0,depth:3,bags:3},
    {rebirth:1,route:0,depth:6,bags:4},
    {rebirth:2,route:1,depth:2,bags:4},
    {rebirth:3,route:1,depth:5,bags:5},
    {rebirth:5,route:2,depth:3,bags:5},
    {rebirth:7,route:2,depth:7,bags:6},
    {rebirth:10,route:4,depth:2,bags:8},
    {rebirth:0,route:0,depth:1,bags:0}
];
const ownedTools = new Set([0]);
function mineralPrice(oreId, mineRoute, depth) {
    return BigInt(config.prices[oreId-1])*routePriceFactors[mineRoute]*2n**BigInt(depth-1);
}
function expectedOreValue(mineRoute, depth, quality=100) {
    return mineralPool(mineRoute,depth).reduce((sum,row)=>
        sum+Number(qualityValue(row.ore.id,mineRoute,depth,quality))*row.p,0);
}
function gearPrice(index) {
    if(index===0||index===9) return 0n;
    if(index===1) return 150n;
    const goal=toolMilestones[index];
    return BigInt(Math.ceil(expectedOreValue(goal.route,goal.depth,toolQualityPercent[index-1])*5*goal.bags/100))*100n;
}
function showEquipment() {
    $('gearRows').innerHTML=catalog.tools.map((tool,index)=>{
        const goal=toolMilestones[index],cost=gearPrice(index),ev=expectedOreValue(goal.route,goal.depth,toolQualityPercent[Math.max(0,index-1)])*5;
        const ordinary=index>0&&index<9;
        const accessible=completed>=goal.rebirth;
        return '<tr><td>'+tool.name+'</td><td>'+tool.multiplier+'×</td><td>'+toolQualityPercent[index]/100+'×</td><td>'
            +(index===9?'任意道隐藏掉落':'重生 '+goal.rebirth+' · '+themes[goal.route].label+' '+goal.depth+' 层')
            +'</td><td title="'+cost+'">'+(index===9?'隐藏获得':compact(cost)+' 矿币')+'</td><td>'
            +(ordinary?compact(cost*35n/100n):'—')+'</td><td>'+(ordinary?(Number(cost)/ev).toFixed(1)+' 袋':'—')
            +'</td><td><button data-buy="'+index+'" '+(!ordinary||ownedTools.has(index)||!accessible||wallet<cost?'disabled':'')+'>'
            +(ownedTools.has(index)?'已拥有':!accessible?'重生未达':'购买并装备')+'</button></td></tr>';
    }).join('');
    $('gearNote').textContent='当前镐品质 ×'+qualityPercent()/100+' · 钱包 '+compact(wallet)+' 矿币。上方装备栏可任选镐进行评审。购买按钮按重生条件扣款，深度列为预计攒价地点。';
}
function showOreInspector() {
    const ore=catalog.minerals[Number($('oreChoice').value)-1];
    $('oreDescription').textContent=ore.name+' · '+ore.type+' · 主产 '+themes[ore.route].name+'。'+ore.fact;
    $('chosenBase').value=config.prices[ore.id-1];
    $('orePrices').innerHTML=Array.from({length:config.layers},(_,i)=>'<tr><td>'+themes[route].name+' · '+(i+1)+' 层</td><td title="'
        +qualityValue(ore.id,route,i+1)+'">'+compact(qualityValue(ore.id,route,i+1))+' 矿币</td><td>'
        +compact(qualityValue(ore.id,route,i+1)*2n)+' / '+compact(qualityValue(ore.id,route,i+1)*3n)+'</td></tr>').join('');
    $('routeIncome').innerHTML=themes.map((theme,r)=>{
        const values=catalog.minerals.filter(ore=>ore.route===r).map(ore=>qualityValue(ore.id,r,layer));
        const min=values.reduce((a,b)=>a<b?a:b),max=values.reduce((a,b)=>a>b?a:b);
        return '<tr><td>'+theme.name+' · '+layer+' 层</td><td>'+compact(min)+'—'+compact(max)
            +'</td><td>'+compact(BigInt(Math.round(expectedOreValue(r,layer,qualityPercent())*5)))+'</td></tr>';
    }).join('');
}
