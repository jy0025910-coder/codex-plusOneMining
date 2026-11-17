const $=s=>document.getElementById(s),pad=(n,w=2)=>String(n).padStart(w,'0'),tag=o=>'#'+pad(o.id,3);
let stage=1,bag=[],pending=null,bank=0n,collected=new Set(),notice='试着装满五格，再敲第六块。';
const weighted=(items,r=Math.random())=>{let n=r*items.reduce((w,o)=>w+o.w,0);for(const o of items){n-=o.w;if(n<0)return o}return items.at(-1)};
function go(g){
 if(g!==stage&&pending){notice='已把未选的露头留在原地。';pending=null}
 stage=g;let z=Math.floor((g-1)/9),d=(g-1)%9+1,Z=zones[z],items=pool(g),total=items.reduce((a,o)=>a+o.w,0);
 $('zoneTabs').innerHTML=zones.map((v,i)=>'<button data-z="'+i+'" aria-pressed="'+(z===i)+'">'+pad(i+1)+' '+v.name+'</button>').join('');
 $('stopTabs').innerHTML=Z.stops.map((v,i)=>'<button aria-label="第'+(i+1)+'格 '+v+'" data-g="'+(z*9+i+1)+'" aria-pressed="'+(d===i+1)+'"><small>格</small>'+pad(i+1)+'</button>').join('');
 $('routeInfo').innerHTML='<div class="two"><article class="panel" style="border-top:5px solid '+Z.color+'"><div class="tag">'+Z.rank+'级　/　'+coord(g)+'</div><h3>'+Z.stops[d-1]+'</h3><p>'+Z.hazard+'</p><p class="field"><b>'+Z.verb+'</b> · '+Z.hint+'</p><p>本格新开放：'+(items.filter(o=>o.d===d).map(o=>o.name).join('、')||'复用已开放标本，提升品质与回收价。')+'</p><small>岩壁耐久 '+wall(g)+'　·　推荐基础力量 '+rec(g)+'　·　'+ideal(g).name+' '+ideal(g).m+'×</small></article><article class="panel rows"><table><caption>本格野外货源 · 矿币/块</caption><thead><tr><th>标本</th><th>自然掉率</th><th>回收售价</th></tr></thead><tbody>'+items.map(o=>'<tr><td>'+tag(o)+' '+o.name+'</td><td>'+(100*o.w/total).toFixed(1)+'%</td><td class="money" title="'+price(o,g)+'">'+fmt(price(o,g))+'</td></tr>').join('')+'</tbody></table><small>权重归一，百分比取一位小数。此前开放的本矿道标本仍在池中。</small></article></div>';
 $('tripName').textContent=Z.stops[d-1]+' · 第 '+g+' 格';$('power').value=rec(g);$('equip').value=ideal(g).i;
 $('expect').innerHTML='在这里连续取五块：平均 <b>'+fmt(BigInt(Math.round(bagEV(g))))+'</b> 币（从 '+fmt(price(items[0],g)*5n)+' 到 '+fmt(price(items.at(-1),g)*5n)+'）。不计换货或委托。';
 damage();renderBag()
}
function damage(){let p=picks[+$('equip').value],v=Number($('power').value);if(!p||!Number.isFinite(v)||v<1||v>1e6){$('dmg').textContent='基础力量可试算 1 至 1,000,000。';return}let hit=Math.max(1,Math.floor(v*p.m)),n=Math.ceil(wall(stage)/hit),oreHP=Math.ceil(wall(stage)*.45),k=Math.ceil(oreHP/hit);$('dmg').innerHTML='每击 <b>'+hit+'</b>　·　破墙 '+n+' 击　·　破一块露头 '+k+' 击。<br>无机关时估算本格一趟：约 '+Math.round(22+.38*(n+k*5))+' 秒（走路交货 22 秒，连续挥镐间隔 0.38 秒，首次破墙）。'}
function dig(){if(pending)return;let o=weighted(pool(stage)),s={o,g:stage,c:price(o,stage)};if(bag.length<5){bag.push(s);notice=(collected.has(o.id)?'已收录':'待盖章')+' · '+tag(o)+' '+o.name+' 入袋。'}else{pending=s;notice='第六块：'+tag(o)+' '+o.name+' · '+fmt(s.c)+' 币'+(collected.has(o.id)?'（已有章）':'（未盖章）')+'。点下面要换出的格子，或留原袋。'}renderBag()}
function renderBag(){$('slots').innerHTML=Array.from({length:5},(_,i)=>{let s=bag[i];return '<button class="slot '+(pending?'can':'')+'" data-slot="'+i+'" '+(!pending?'disabled':'')+' title="'+(s?'开采于 '+coord(s.g):'空位')+'">'+(s?s.o.name+'<b>'+fmt(s.c)+'</b><small>'+(collected.has(s.o.id)?'已有章':'待盖章')+'</small>':'空格 '+(i+1))+'</button>'}).join('');
 $('msg').textContent=notice;$('skip').hidden=!pending;$('fill').disabled=bag.length===5||!!pending;$('dig').disabled=!!pending;$('sell').disabled=!bag.length||!!pending;$('wallet').innerHTML='本袋 <b>'+fmt(bag.reduce((v,s)=>v+s.c,0n))+'</b>　·　钱包 <b title="'+bank+'">'+fmt(bank)+'</b>　·　已盖章 <b>'+collected.size+' / 50</b>'}
function atlas(){let z=+$('atlasZone').value,q=$('search').value.trim().toLowerCase(),visible=ore.filter(o=>(z<0||o.z===z)&&(!q||(tag(o)+o.name+o.fact+o.type).toLowerCase().includes(q))&&(!$('missing').checked||!collected.has(o.id)));
 $('count').textContent='显示 '+visible.length+' / 50 件';$('cards').innerHTML=visible.map(o=>{let g=o.z*9+o.d,v=price(o,g);return '<article class="spec" style="--sw:#'+o.hex+'"><div class="num"><span class="sw"></span> '+tag(o)+'　'+o.type+'</div><h3>'+o.name+(collected.has(o.id)?' <small class="checks">✓ 已收录</small>':'')+'</h3><p>'+o.fact+'</p><small>'+coord(g)+' 起</small><br><small title="'+v+' 币">首出卖 '+fmt(v)+' · 复制品买 '+fmt(v*2n)+'</small></article>'}).join('')||'<p>这一页没有匹配的标本，试试不同名称或矿道。</p>'}
$('zoneTabs').onclick=e=>{let b=e.target.closest('[data-z]');if(b)go(+b.dataset.z*9+1)};$('stopTabs').onclick=e=>{let b=e.target.closest('[data-g]');if(b)go(+b.dataset.g)};
$('equip').innerHTML=picks.map(p=>'<option value="'+p.i+'">'+p.name+' '+p.m+'×</option>').join('');
$('power').oninput=damage;$('equip').onchange=damage;$('dig').onclick=dig;$('fill').onclick=()=>{while(bag.length<5)dig()};
$('skip').onclick=()=>{pending=null;notice='保留了原来的五块矿。';renderBag()};
$('slots').onclick=e=>{let b=e.target.closest('[data-slot]');if(!pending||!b)return;let i=+b.dataset.slot,old=bag[i];bag[i]=pending;notice='留下了'+pending.o.name+'，换出了'+old.o.name+'。';pending=null;renderBag()};
$('sell').onclick=()=>{if(pending||!bag.length)return;let before=collected.size,total=bag.reduce((s,x)=>s+x.c,0n);for(const s of bag)collected.add(s.o.id);bank+=total;notice='收矿员：本趟 '+fmt(total)+' 币到账，新盖 '+(collected.size-before)+' 枚章。';bag=[];renderBag();atlas()};
$('atlasZone').innerHTML='<option value="-1">全部矿道</option>'+zones.map((z,i)=>'<option value="'+i+'">'+z.name+'</option>').join('');
$('atlasZone').onchange=atlas;$('search').oninput=atlas;$('missing').onchange=atlas;
$('toolrows').innerHTML=picks.map(p=>{let c=pickCost(p);return '<tr><td><b>'+pad(p.i+1)+' '+p.name+'</b><br><small>'+p.look+'</small></td><td>'+p.m+'×</td><td>'+Math.floor(30*p.m)+' / 击</td><td>'+(p.g?coord(p.g):'营地出生')+'<br><b title="'+c+'">'+(p.i===9?'解谜必得 · 不出售':p.i?fmt(c)+' 币':'免费')+'</b></td><td title="'+(c*35n/100n)+'">'+(c?fmt(c*35n/100n):'不回收')+'</td><td>'+(c?(Number(c)/bagEV(p.g)).toFixed(1)+' 均袋':'—')+'</td></tr>'}).join('');
$('hiddenRows').innerHTML=secrets.map(([name,t,where,how,effect],i)=>'<details><summary><span class="num">H'+pad(i+1)+'</span>　'+name+'　<small>'+t+' · '+where+'</small></summary><p>线索：'+how+'<br>收藏效果：'+effect+'</p></details>').join('');
go(1);atlas();
