const rebirthGates = [0, 2, 5, 8, 10];
const trainingAreas = [{multiplier:1,rebirth:0},{multiplier:2,rebirth:0},{multiplier:4,rebirth:2},{multiplier:6,rebirth:5},{multiplier:8,rebirth:8},{multiplier:10,rebirth:10}];
const plannedTools = [2,3,4,6,6,8,8,10,10,10,12];
const routeLast = [6000000n,1875000000n,351562500000n,11718750000000n,102996826171875000000n];
const routeFirst = [500n,1200000n,375000000n,70312500000n,2343750000000n];
const baseLevelCosts = (() => {
    const weights = Array.from({length:49}, (_,i) => 1.10 ** i);
    const sum = weights.reduce((a,b) => a+b);
    const costs = weights.map(weight => BigInt(Math.floor(5000*weight/sum)));
    costs[48] += 5000n-costs.reduce((a,b)=>a+b,0n);
    return costs;
})();
function levelCost(level, rebirths) { return baseLevelCosts[level-1]*5n**BigInt(rebirths); }
function xpForLevel(level, rebirths) { return baseLevelCosts.slice(0,level-1).reduce((a,b)=>a+b,0n)*5n**BigInt(rebirths); }
function levelAt(xp, rebirths) {
    let level=1;
    while(level<50 && xp>=xpForLevel(level+1,rebirths)) level++;
    return level;
}
function roundTarget(rebirths) { return 5000n*5n**BigInt(rebirths); }
function rebirthCost(rebirths) { return rebirths>=20?null:roundTarget(rebirths); }
function trainingGain(area, tool, rebirths) {
    return BigInt(area)*BigInt(Math.round(tool*100))*4n**BigInt(rebirths)/100n;
}
function balancedWall(r, depth, count) {
    if(depth===1) return routeFirst[r];
    if(depth===count) return routeLast[r];
    const value=Number(routeFirst[r])*(Number(routeLast[r])/Number(routeFirst[r]))**((depth-1)/(count-1));
    return BigInt(Math.round(Number(value.toPrecision(3))));
}
function maxTraining(rebirths) { return trainingAreas.filter(area=>area.rebirth<=rebirths).at(-1).multiplier; }
function plannedTool(rebirths) { return plannedTools[Math.min(rebirths,10)]; }
function estimateSeconds(rebirths) {
    if(rebirths>=20) return null;
    const gain=trainingGain(maxTraining(rebirths),plannedTool(rebirths),rebirths);
    return Number((roundTarget(rebirths)+gain-1n)/gain)*(0.8/1.5);
}
let completed=0;
let earnedXP=0n;
