
// Five independent draws from the complete weighted mineral pool.
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
    const total=rows.reduce((sum,row)=>sum+row.p,0);
    return Array.from({length:5},()=>{
        let ticket=random()*total;
        for(const row of rows){
            ticket-=row.p;
            if(ticket<0)return row;
        }
        return rows.findLast(row=>row.p>0);
    });
}
function wallAppearanceOdds(mineRoute, depth) {
    return mineralPool(mineRoute,depth).map(row=>-Math.expm1(5*Math.log1p(-row.p)));
}
