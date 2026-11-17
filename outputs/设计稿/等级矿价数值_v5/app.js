const $=id=>document.getElementById(id);
const percent=p=>(p*100).toLocaleString('en-US',{maximumFractionDigits:6})+'%';
let config=makeConfig();
try{const saved=JSON.parse(localStorage.getItem('mining-v5'));if(validConfig(saved))config=saved}catch{}
let route=0,layer=1,remaining=hpAt(0,1),loot=null,bag=[],wallet=0n,timer=null;
const collection=new Set();
function save(){
 try{localStorage.setItem('mining-v5',JSON.stringify(config));$('saveStatus').textContent='参数已存到当前浏览器，可导出配置留存。'}
 catch{$('saveStatus').textContent='请导出参数留存，当前预览无法使用本地保存。'}
}
function stop(){clearInterval(timer);timer=null}
function reset(){stop();remaining=hpAt(route,layer);loot=null;render()}
function playerValid(){return /^[1-9]\d{0,29}$/.test($('power').value)}
function currentDamage(){return playerValid()?damage():1n}
function required(hp){return (hp+currentDamage()-1n)/currentDamage()}
function recommendedPower(hp){
 const multiplier=catalog.tools[+$('tool').value].multiplier;
 let m=BigInt(Math.round(multiplier*100));
 if($('skill').value==='rock')m=m*3n/2n;
 if($('skill').value==='frost')m*=2n;
 if(route===2&&$('hot').checked)m/=2n;
 return (hp*100n+12n*m-1n)/(12n*m);
}
function renderWall(){
 $('location').textContent=themes[route].label+'矿道 · 第 '+layer+' 层';
 $('wallTitle').textContent=layer===config.layers?'终层矿墙':'第 '+layer+' 层矿墙';
 $('effect').textContent=themes[route].effect;
 $('hp').textContent=compact(hpAt(route,layer));
 $('damage').textContent=playerValid()?compact(damage()):'—';
 $('hits').textContent=playerValid()?compact(required(hpAt(route,layer)))+' 击':'—';
 $('hp').title=hpAt(route,layer).toLocaleString('en-US');
 $('bar').style.width=(Number(remaining)*100/Number(hpAt(route,layer)))+'%';
 $('remaining').textContent='剩余 '+compact(remaining)+' / '+compact(hpAt(route,layer))+'　'+(playerValid()?timeText(required(remaining)):'请输入正整数力量。');
 $('auto').disabled=!!loot||!playerValid()||timer!==null;
 $('resolve').disabled=!!loot||!playerValid();
 $('collect').disabled=!loot||loot.every(o=>o.taken)||(bag.length>=5&&!loot.some(o=>o.hidden!==undefined&&!o.taken));
 $('sell').disabled=!bag.length;
 $('batch').textContent=loot?loot.length+' 件掉落':'等待破墙';
 if(!loot)$('loot').innerHTML='<p class="hint">墙后藏着什么？<br>敲开后就能看见名称、价格和稀有光效。</p>';
 else $('loot').innerHTML=loot.map((item,i)=>{
  const secret=item.hidden!==undefined;
  const ore=secret?null:catalog.minerals[item.oreId-1];
  const name=secret?secrets[item.hidden][0]:ore.name;
  return '<button class="'+(secret?'hiddenLoot':ore.rank>=7?'rare':'')+'" data-loot="'+i+'" '+(item.taken||(bag.length>=5&&!secret)?'disabled':'')+'><div class="rock" style="--rock:#'+(ore?.hex??'b999e7')+'"></div><b>'+name+'</b><small>'+(secret?'隐藏 · 彩光':ore.rank>=7?'稀有 · 金光':'普通 · 柔光')+'</small><b>'+(secret?secrets[item.hidden][3]:compact(mineralPrice(ore.id,item.sourceRoute,item.sourceDepth))+' 币')+'</b><small>'+(item.taken?'已拾取':'拾取')+'</small></button>';
 }).join('');
 $('lootStatus').textContent=loot?'固定五种矿石可逐件拾取。额外隐藏款直接进入收藏。':'';
 $('bag').textContent='背包 '+bag.length+' / 5　·　矿币 '+compact(wallet)+'　·　隐藏收藏 '+collection.size+' / 10';
 const p=chance().pct/100;
 $('luck').textContent='隐藏基础单次率 '+percent(p)+'　·　每墙至少一件 '+percent(atLeast(p));
}
function renderCurve(){
 $('curveRows').innerHTML=Array.from({length:config.layers},(_,i)=>{
  const hp=hpAt(route,i+1),hits=required(hp);
  return '<tr class="'+(i+1===layer?'selected':'')+'"><td>第 '+(i+1)+' 层</td><td title="'+hp+'">'+compact(hp)+'</td><td>'+(playerValid()?compact(hits)+' 击':'—')+'</td><td>'+(playerValid()?timeText(hits):'—')+'</td><td>'+compact(recommendedPower(hp))+'</td></tr>';
 }).join('');
}
function renderMinerals(){
 const search=$('search').value.trim(),filter=+$('filter').value,inclusion=inclusionOdds(route,layer);
 $('oreRows').innerHTML=pool().filter(({ore})=>(filter<0||ore.route===filter)&&(ore.name+String(ore.id).padStart(3,'0')).includes(search)).map(({ore,p})=>{
  const chancePerSlot=p;
  return '<tr><td><details><summary>'+ore.name+'</summary><p>'+ore.fact+'</p></details></td><td>'+themes[ore.route].name+'</td><td><input class="price" aria-label="'+ore.name+'价格" data-price="'+ore.id+'" inputmode="numeric" value="'+config.prices[ore.id-1]+'"><small>'+compact(mineralPrice(ore.id,route,layer))+' 本层矿币</small></td><td><input class="weight" aria-label="'+ore.name+'权重" data-weight="'+ore.id+'" type="number" min=".01" max="10000" step="any" value="'+config.weights[ore.id-1]+'"></td><td>'+percent(chancePerSlot)+'</td><td>'+percent(inclusion[ore.id-1])+'</td></tr>';
 }).join('');
}
function renderSecrets(){
 const odds=chance(),p=odds.pct/100;
 $('hiddenTotal').textContent='每墙至少一次 '+percent(atLeast(p));
 $('formula').textContent='单矿位隐藏率 = '+odds.parts.map((n,i)=>['基础 '+n.toFixed(2)+'%','矿道 ×'+n,'深度 ×'+n.toFixed(2),'镐子 ×'+n.toFixed(2),'力量 ×'+n.toFixed(2),'秘技 ×'+n.toFixed(2)][i]).join(' × ')+'，封顶 '+config.cap+'%。';
 $('secretRows').innerHTML=hiddenPool().map(({secret,id,p:share})=>'<tr><td>'+secret[0]+'<small>'+secret[1]+'</small></td><td>'+themes[secret[4]].name+'</td><td>'+secret[2]+'</td><td>'+percent(atLeast(p)*share)+'</td><td>'+'1 件'+'</td></tr>').join('');
}
function render(){
 $('routes').innerHTML=themes.map((theme,i)=>'<button class="'+(route===i?'active':'')+'" data-route="'+i+'" style="--tint:'+theme.color+'"><b>'+theme.label+'矿道</b><small>'+theme.name+'</small><small>首墙 '+compact(hpAt(i,1))+' · 幸运 ×'+theme.bonus+'</small></button>').join('');
 $('depthLabel').textContent=themes[route].name+' · 第 '+layer+' 层';$('layerRange').textContent=layer+' / '+config.layers;
 $('depth').max=config.layers;$('depth').value=layer;
 renderWall();renderCurve();renderMinerals();renderSecrets();
}
function breakWall(){
 stop();remaining=0n;
 const minerals=pool(),hidden=hiddenPool(),p=chance().pct/100;
 loot=drawFive(minerals).map(({ore})=>({oreId:ore.id,sourceRoute:route,sourceDepth:layer,taken:false}));
 if(Math.random()<atLeast(p))loot.push({hidden:sample(hidden).id,taken:false});
 renderWall();
}
function hit(){
 if(!playerValid()){stop();renderWall();return}
 remaining=remaining>damage()?remaining-damage():0n;
 if(!remaining)breakWall();else renderWall();
}
function sync(){
 for(const id of ['layers','growth','routeGrowth','foreign','baseHidden','cap'])$(id).value=config[id];
}
$('tool').innerHTML=catalog.tools.map((tool,i)=>'<option value="'+i+'">'+tool.name+' · '+tool.multiplier+'×</option>').join('');
$('filter').innerHTML+=themes.map((theme,i)=>'<option value="'+i+'">'+theme.name+'</option>').join('');
$('routes').onclick=e=>{const b=e.target.closest('[data-route]');if(b){route=+b.dataset.route;layer=1;reset()}};
$('depth').oninput=()=>{layer=+$('depth').value;reset()};
$('power').oninput=()=>{stop();render()};
for(const id of ['tool','skill','hot'])$(id).onchange=()=>{stop();render()};
$('auto').onclick=()=>{timer=setInterval(hit,380);hit()};
$('resolve').onclick=breakWall;$('retry').onclick=reset;
$('suggest').onclick=()=>{$('power').value=recommendedPower(hpAt(route,layer)).toString();stop();render()};
function take(i){
 if(!loot||loot[i].taken)return;
 if(loot[i].hidden!==undefined){
  collection.add(loot[i].hidden);loot[i].taken=true;return;
 }
 if(bag.length>=5)return;
 bag.push({...loot[i]});loot[i].taken=true;
}
$('loot').onclick=e=>{const b=e.target.closest('[data-loot]');if(b){take(+b.dataset.loot);renderWall()}};
$('collect').onclick=()=>{loot?.forEach((_,i)=>take(i));renderWall()};
$('sell').onclick=()=>{
 const multiplier=$('skill').value==='money2'?2n:$('skill').value==='money3'?3n:1n;
 const value=bag.filter(item=>item.oreId).reduce((sum,item)=>sum+mineralPrice(item.oreId,item.sourceRoute,item.sourceDepth),0n)*multiplier;
 const special=bag.filter(item=>item.hidden!==undefined).length;
 bag.filter(item=>item.hidden!==undefined).forEach(item=>collection.add(item.hidden));
 wallet+=value;bag=[];renderWall();
 $('lootStatus').textContent='售出矿石获得 '+compact(value)+' 币'+(special?'，'+special+' 件隐藏物品进入收藏。':'。');
};
for(const id of ['layers','growth','routeGrowth','foreign','baseHidden','cap'])$(id).onchange=()=>{
 const next={...config,[id]:Number($(id).value)};
 if(!validConfig(next)){$('saveStatus').textContent='参数超出可试算范围，已保留原值。';sync();return}
 config=next;layer=Math.min(layer,config.layers);save();
 if(['layers','growth','routeGrowth'].includes(id))reset();else render();
};
$('filter').onchange=renderMinerals;$('search').oninput=renderMinerals;
$('oreRows').onchange=e=>{
 const input=e.target,id=Number(input.dataset.price??input.dataset.weight)-1;
 if(!Number.isInteger(id)||id<0||id>=50)return;
 const prices=[...config.prices],weights=[...config.weights];
 if(input.dataset.price)prices[id]=input.value.trim();else weights[id]=Number(input.value);
 const next={...config,prices,weights};
 if(validConfig(next)){config=next;save();renderWall()}
 else $('saveStatus').textContent='卖价需为 0 至 36 位整数，权重为 0.01–10000，已保留原值。';
 renderMinerals();
};
$('export').onclick=()=>{
 const url=URL.createObjectURL(new Blob([JSON.stringify(config,null,2)],{type:'application/json'}));
 const a=document.createElement('a');a.href=url;a.download='晶脉峡谷-矿道参数-v5.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),3000);
};
$('import').onchange=async e=>{
 try{const next=JSON.parse(await e.target.files[0].text());if(!validConfig(next))throw Error();config=next;layer=Math.min(layer,config.layers);sync();save();reset()}
 catch{$('saveStatus').textContent='配置格式或数值范围有误，已保留当前参数。'}
 e.target.value='';
};
sync();render();

