const element = id => document.getElementById(id);
const format = value => Number(value.toFixed(6)).toLocaleString('en-US',{maximumFractionDigits:6});
const pct = p => format(p*100)+'%';
const storageKey = 'gem-gulch-mining-table-v2.1';
const defaults = () => ({
    version:2, count:9, foreign:6, cap:10, prices:[...startingPrices],
    weights:catalog.minerals.map(ore => defaultWeights[ore.rank])
});
function validateSettings(value) {
    return value && value.version===2 && [9,10].includes(value.count)
        && [2,6,10,15].includes(value.foreign) && [3,5,10,20].includes(value.cap)
        && Array.isArray(value.prices) && value.prices.length===50 && value.prices.every(validPrice)
        && Array.isArray(value.weights) && value.weights.length===50
        && value.weights.every(weight => Number.isFinite(weight) && weight>=0.01 && weight<=1000);
}
let settings=defaults();
try {
    const restored=JSON.parse(localStorage.getItem(storageKey));
    if(validateSettings(restored)) settings=restored;
} catch { /* File previews can run without persistent storage. */ }
function save() {
    try {
        localStorage.setItem(storageKey,JSON.stringify(settings));
        element('saved').textContent='参数已保存到当前浏览器。导出配置可以换设备继续调整。';
    } catch {
        element('saved').textContent='当前浏览器限制本地保存，请导出配置留存。';
    }
}
let route=0,layer=1;
let bag=[],wallet=0n,sessionNote='';
const walls=new Map(),finds=new Map();
let ticker=null;
function key(){return [settings.count,route,layer].join('/')}
function currentWall(){
    if(!walls.has(key())) walls.set(key(),{remaining:wallSpec(route,layer,settings.count).hp,reward:null,taken:[]});
    return walls.get(key());
}
function player(){
    const power=Number(element('power').value);
    const valid=element('power').value!=='' && Number.isInteger(power) && power>=1 && power<=1e9;
    const base=valid?power:1;
    const multiplier=catalog.tools[Number(element('tool').value)].multiplier;
    const skill=element('skill').value;
    const effective=skill==='yang'?Math.floor(base*112/100):base;
    const hot=route===2 && element('heat').checked;
    return {base,valid,multiplier,effective,skill,damage:Math.max(1,Math.floor(effective*multiplier*(hot?0.5:1)))};
}
function getOdds(){
    const p=player();
    return hiddenOdds(route,layer,p.multiplier,p.base,settings.cap,p.skill);
}
function stopTimer(){if(ticker!==null) clearInterval(ticker);ticker=null}
function routeMenu(){
    element('routes').innerHTML=themes.map((t,i)=>`<button data-route="${i}" aria-pressed="${route===i}" style="--sw:${catalog.routes[i].color}"><b>${t.label} · ${t.name}</b><small>门槛 ${grouped(t.start)}　幸运 +${format(t.luck)}‰</small></button>`).join('');
    element('layer').innerHTML=stopNames(route,settings.count).map((name,i)=>`<option value="${i+1}">第 ${i+1} 层 · ${name}</option>`).join('');
    element('layer').value=layer;
}
function renderWall(){
    const wall=currentWall(),spec=wallSpec(route,layer,settings.count),p=player();
    const allowed=p.valid && p.effective>=spec.required;
    const hits=Math.ceil(wall.remaining/p.damage);
    element('where').textContent=themes[route].label+'矿道　/　第 '+layer+' 层';
    element('stop').textContent=stopNames(route,settings.count)[layer-1];
    const move=p.skill==='wind'?'　步谱移速 +15%。':(p.skill==='ice' && route===3?'　定息诀使冰上步速恢复到 85%。':'');
    element('terrain').textContent=themes[route].effect+move;
    element('heatWrap').hidden=route!==2;
    element('wallStats').innerHTML=[['进层所需力量',grouped(spec.required)],['你的有效力量',p.valid?grouped(p.effective):'—'],['你的每击伤害',p.valid?grouped(p.damage):'—']].map(([label,v])=>`<span>${label}<b>${v}</b></span>`).join('');
    element('hpbar').max=spec.hp;element('hpbar').value=wall.remaining;
    let note='请输入 1 至 10 亿的整数力量。';
    if(p.valid) note=allowed ? '还需 '+hits+' 击，约 '+format(Math.round(hits*.38*10)/10)+' 秒。' : '还差 '+grouped(spec.required-p.effective)+' 点有效力量才能进层。';
    element('hptext').textContent='墙耐久 '+grouped(wall.remaining)+' / '+grouped(spec.hp)+'。'+(wall.reward?'墙已打开。':note);
    element('hit').disabled=!allowed||!!wall.reward||ticker!==null;
    element('fast').disabled=!allowed||!!wall.reward;
    const distribution=wall.reward;
    if(!distribution) element('drops').textContent='敲开这面墙，就能看见矿石名称和回收价。';
    else element('drops').innerHTML=distribution.minerals.map((ore,i)=>{
        const taken=wall.taken.includes(i);
        return `<button data-pick="${i}" style="--sw:#${ore.hex}" ${taken||bag.length===5?'disabled':''}>${ore.name}<br><b>${compact(settings.prices[ore.id-1])} 币</b><small>${ore.route===route?'本地矿':'外道矿'} · ${taken?'已装袋':'装入背包'}</small></button>`;
    }).join('');
    const odds=distribution?distribution.perMille:getOdds().perMille;
    element('chance').textContent=(distribution?'破墙时已锁定':'当前每墙')+'隐藏率 '+format(odds)+'‰（'+format(odds/10)+'%）。';
    element('open').disabled=!distribution||distribution.opened;
    element('prize').textContent=distribution?.opened?distribution.description:'';
    element('bagInfo').textContent='背包 '+bag.length+' / 5　·　钱包 '+compact(wallet)+' 币　·　隐藏收藏 '+finds.size+' / 10。 '+sessionNote;
}
function strike(fast=false){
    const state=currentWall(),p=player();
    if(!p.valid || state.reward || p.effective<wallSpec(route,layer,settings.count).required){stopTimer();renderWall();return}
    state.remaining=fast?0:Math.max(0,state.remaining-p.damage);
    if(!state.remaining){
        stopTimer();
        state.reward=breakWall(oreDistribution(route,layer,settings.count,settings),getOdds(),route);
    }
    renderWall();
}
function renderMinerals(){
    const filter=element('filter').value,query=element('search').value.trim();
    const rows=oreDistribution(route,layer,settings.count,settings);
    const visible=rows.filter(({ore})=>(filter==='all'||ore.route===Number(filter)) && (ore.name+String(ore.id).padStart(3,'0')+ore.type).includes(query));
    element('poolNote').textContent=themes[route].name+'第 '+layer+' 层，本地矿 '+(100-settings.foreign)+'%，外道矿 '+settings.foreign+'%。当前显示 '+visible.length+' / 50 种。';
    element('oreRows').innerHTML=visible.map(({ore,p})=>{
        const id=ore.id;
        return `<tr><td><details><summary><span class="oreId">${String(id).padStart(3,'0')}</span><i class="chip" style="--sw:#${ore.hex}"></i>${ore.name}</summary><small>${ore.type} · ${ore.fact}</small></details></td><td>${themes[ore.route].name}</td><td>${firstLayer(ore,settings.count)}</td><td><input data-price="${id}" class="price" inputmode="numeric" aria-label="${ore.name}卖价" value="${settings.prices[id-1]}"><small> ${compact(settings.prices[id-1])}</small></td><td><input class="weight" data-weight="${id}" aria-label="${ore.name}权重" type="number" min=".01" max="1000" step="any" value="${settings.weights[id-1]}"></td><td>${pct(p)}</td><td>${pct(perWall(p))}</td></tr>`;
    }).join('');
}
function renderSecrets(){
    const odds=getOdds();
    element('oddsTotal').textContent='当前每墙隐藏总率 '+format(odds.perMille)+'‰（'+format(odds.perMille/10)+'%）';
    const labels=['基础','矿道幸运','深度','镐子','基础力量','秘技'];
    element('oddsTerms').textContent=odds.terms.map((v,i)=>labels[i]+' '+format(v)+'‰').join(' + ')+' = '+format(odds.raw)+'‰，按上限 '+settings.cap+'‰ 结算。';
    element('secretRows').innerHTML=odds.rows.map(({item,i,p})=>`<tr><td><b>${item[0]}</b><br><small>${item[1]}</small></td><td>${themes[Math.floor(i/2)].name}</td><td>${item[2]}</td><td>${pct(p*odds.perMille/1000)}</td></tr>`).join('');
    element('normalPrize').textContent='普通奖为 '+grouped([10,200,10000,4000000,6000000000][route])+' 矿币，每匣概率 '+format(100-odds.perMille/10)+'%。每匣独立抽取。';
}
function renderCurve(){
    const p=player();
    element('wallRows').innerHTML=stopNames(route,settings.count).map((name,i)=>{
        const spec=wallSpec(route,i+1,settings.count);
        const yours=!p.valid?'请输入力量':p.effective<spec.required?'力量不足':Math.ceil(spec.hp/p.damage)+' 击';
        return `<tr class="${i+1===layer?'active-row':''}"><td>${i+1} · ${name}</td><td>${grouped(spec.required)}</td><td>${grouped(spec.hp)}</td><td>${entryTools[route]}×</td><td>${spec.targetHits}</td><td>${yours}</td></tr>`;
    }).join('');
}
function renderAll(){routeMenu();renderWall();renderMinerals();renderSecrets();renderCurve()}
function setSelectors(){
    element('count').value=settings.count;element('foreign').value=settings.foreign;element('cap').value=settings.cap;
}
element('tool').innerHTML=catalog.tools.map((item,i)=>`<option value="${i}">${item.name} · ${item.multiplier}×</option>`).join('');
element('filter').innerHTML='<option value="all">全部 50 种</option>'+themes.map((t,i)=>`<option value="${i}">${t.name}</option>`).join('');
element('routes').onclick=e=>{
    const button=e.target.closest('[data-route]');if(!button)return;
    stopTimer();route=Number(button.dataset.route);layer=1;sessionNote='';element('heat').checked=false;renderAll();
};
element('layer').onchange=()=>{stopTimer();layer=Number(element('layer').value);sessionNote='';renderAll()};
element('count').onchange=()=>{stopTimer();settings.count=Number(element('count').value);layer=Math.min(layer,settings.count);save();renderAll()};
element('foreign').onchange=()=>{settings.foreign=Number(element('foreign').value);save();renderMinerals()};
element('cap').onchange=()=>{settings.cap=Number(element('cap').value);save();renderSecrets();renderWall()};
function playerChanged(){stopTimer();renderWall();renderCurve();renderSecrets()}
element('power').oninput=playerChanged;
for(const id of ['tool','skill','heat']) element(id).onchange=playerChanged;
element('recommended').onclick=()=>{
    element('power').value=wallSpec(route,layer,settings.count).required;
    element('tool').value=catalog.tools.findIndex(tool=>tool.multiplier===entryTools[route]);
    element('skill').value='';element('heat').checked=false;playerChanged();
};
element('hit').onclick=()=>{if(ticker===null){ticker=setInterval(()=>strike(),380);strike()}};
element('fast').onclick=()=>strike(true);
element('drops').onclick=e=>{
    const target=e.target.closest('[data-pick]');if(!target||bag.length>=5)return;
    const state=currentWall(),i=Number(target.dataset.pick);
    if(!state.reward||state.taken.includes(i))return;
    state.taken.push(i);bag.push(state.reward.minerals[i]);sessionNote='';renderWall();
};
element('open').onclick=()=>{
    const reward=currentWall().reward;if(!reward||reward.opened)return;
    reward.opened=true;
    if(reward.prize.hidden!==undefined){
        const id=reward.prize.hidden,number=(finds.get(id)??0)+1;
        finds.set(id,number);
        reward.description='第 '+number+' 次发现「'+secretItems[id][0]+'」';
    }else{wallet+=BigInt(reward.prize.coins);reward.description='获得 '+grouped(reward.prize.coins)+' 矿币，已入账。'}
    renderWall();
};
element('sell').onclick=()=>{
    stopTimer();const income=bag.reduce((sum,ore)=>sum+BigInt(settings.prices[ore.id-1]),0n);
    wallet+=income;sessionNote='本次卖出 '+bag.length+' 块，共 '+compact(income)+' 币。';bag=[];walls.clear();layer=1;renderAll();
};
element('filter').onchange=renderMinerals;element('search').oninput=renderMinerals;
element('oreRows').onchange=e=>{
    const input=e.target;const isPrice=input.hasAttribute('data-price');
    if(!isPrice&&!input.hasAttribute('data-weight'))return;
    const id=Number(isPrice?input.dataset.price:input.dataset.weight)-1;
    const value=isPrice?input.value.trim():Number(input.value);
    if(isPrice?!validPrice(value):!Number.isFinite(value)||value<0.01||value>1000){
        element('saved').textContent=isPrice?'卖价请填 0 至 30 位的非负整数，已保留原价。':'权重范围是 0.01–1000，已保留原权重。';renderMinerals();return;
    }
    if(isPrice) settings.prices[id]=value;else settings.weights[id]=value;
    save();
    const next=oreDistribution(route,layer,settings.count,settings);
    for(const row of element('oreRows').rows){
        const priceInput=row.querySelector('[data-price]');
        const index=Number(priceInput.dataset.price)-1;
        row.cells[3].querySelector('small').textContent=' '+compact(settings.prices[index]);
        row.cells[5].textContent=pct(next[index].p);
        row.cells[6].textContent=pct(perWall(next[index].p));
    }
    renderWall();
};
element('oreRows').onkeydown=e=>{if(e.key==='Enter' && e.target instanceof HTMLInputElement)e.target.blur()};
element('export').onclick=()=>{
    const file=new Blob([JSON.stringify(settings,null,2)],{type:'application/json'});
    const url=URL.createObjectURL(file),a=document.createElement('a');a.href=url;a.download='晶脉峡谷-矿价与概率.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),3000);
};
element('import').onchange=async e=>{
    const file=e.target.files[0];if(!file)return;
    try{
        const next=JSON.parse(await file.text());if(!validateSettings(next))throw Error();
        stopTimer();settings=next;layer=Math.min(layer,settings.count);setSelectors();save();renderAll();
    }catch{element('saved').textContent='配置格式或数值范围有误，保留当前设置。'}
    e.target.value='';
};
setSelectors();renderAll();
