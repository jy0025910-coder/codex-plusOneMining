
// Weighted draws without replacement. Five visible minerals are guaranteed.
const probabilityCache = new Map();
function mineralPool(mineRoute, depth) {
    const base=[30,22,16,11,8,5,3.5,2.3,1.4,.8];
    const deep=[22,19,16,12,10,8,5,4,2.5,1.5];
    const progress=(depth-1)/(config.layers-1);
    const amounts=catalog.minerals.map(ore=>config.weights[ore.id-1]
        *(1+(deep[ore.rank]/base[ore.rank]-1)*progress));
    const totals=themes.map((_,r)=>catalog.minerals.filter(ore=>ore.route===r)
        .reduce((sum,ore)=>sum+amounts[ore.id-1],0));
    return catalog.minerals.map(ore=>({ore,p:(ore.route===mineRoute?1-config.foreign/100:config.foreign/400)
        *amounts[ore.id-1]/totals[ore.route]}));
}
function drawFive(rows, random=Math.random) {
    const available=rows.filter(row=>row.p>0).map(row=>({...row}));
    const picked=[];
    for(let i=0;i<5;i++){
        const total=available.reduce((sum,row)=>sum+row.p,0);
        let ticket=random()*total;
        let index=available.findIndex(row=>{ticket-=row.p;return ticket<0});
        if(index<0)index=available.length-1;
        picked.push(available.splice(index,1)[0]);
    }
    return picked;
}
function inclusionOdds(mineRoute, depth) {
    const key=[mineRoute,depth,config.layers,config.foreign,...config.weights].join(',');
    if(probabilityCache.has(key))return probabilityCache.get(key);
    const rows=mineralPool(mineRoute,depth),counts=Array(50).fill(0),trials=20000;
    let seed=19349663+mineRoute*73856093+depth*83492791;
    function random(){
        seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;
        return (seed>>>0)/4294967296;
    }
    for(let n=0;n<trials;n++){
        for(const row of drawFive(rows,random))counts[row.ore.id-1]++;
    }
    const result=counts.map(count=>count/trials);
    if(probabilityCache.size>=60)probabilityCache.delete(probabilityCache.keys().next().value);
    probabilityCache.set(key,result);
    return result;
}
