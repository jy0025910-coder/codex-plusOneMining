const themes = [
 {label:'人间',name:'砂灯旧坑',color:'#e6b775',bonus:1,effect:'矿灯照亮通道，基础速度。'},
 {label:'风峡',name:'鸣风铜峡',color:'#76ceb1',bonus:1.15,effect:'横风使人后退，挡风柱背面可避开。身法秘技更常见。'},
 {label:'火焰',name:'余烬炉脉',color:'#ff9475',bonus:1.35,effect:'热纹提前两秒亮起，踩入后伤害暂降至 50%。聚财秘技更常见。'},
 {label:'寒冰',name:'蓝镜冰窟',color:'#87bff0',bonus:1.5,effect:'冰面移动速度为 65%，绳纹地恢复。锻力秘技更常见。'},
 {label:'神域',name:'天衡星庭',color:'#c3a5ef',bonus:1.8,effect:'按三枚星纹走近路，踩错退一格。收藏奇物更常见。'}
];
const secrets = [
 ['灯影短剑','纪念剑','点亮返程矿灯。','普通展示',0],
 ['砂声石','奇石','陈列并记录发现者。','标本收藏',0],
 ['乘风步谱','身法','装备时移速 ×1.15。','移动速度',1],
 ['回响铜心','奇石','陈列时泛青铜光。','标本收藏',1],
 ['聚财盆','聚财','装备时出售矿石收入 ×2。','矿币 ×2',2],
 ['丰藏秘卷','聚财','装备时出售矿石收入 ×3。','矿币 ×3',2],
 ['磐岩锻力经','锻力','装备时伤害 ×1.5。','伤害 ×1.5',3],
 ['玄霜锻力诀','锻力','装备时伤害 ×2。','伤害 ×2',3],
 ['观星寻脉录','幸运','装备时隐藏总率 ×1.25。','幸运 ×1.25',4],
 ['星图罗盘镐','隐藏镐','装备时镐倍率为 12×。','矿镐 12×',4]
];
function makeConfig(){
 return {version:5,layers:10,growth:4,routeGrowth:10000,foreign:6,baseHidden:0.1,cap:1,weights:catalog.minerals.map(o=>[30,22,16,11,8,5,3.5,2.3,1.4,.8][o.rank]),
 prices:catalog.minerals.map(o=>String(BigInt([20,30,45,70,110,180,320,650,1500,4000][o.rank])*BigInt(100+o.route*20)/100n))};
}
function validConfig(c){
 return c&&c.version===5&&[9,10].includes(c.layers)&&[2,3,4,5].includes(c.growth)&&[100,1000,10000].includes(c.routeGrowth)
 &&Number.isFinite(c.foreign)&&c.foreign>=0&&c.foreign<=20&&Number.isFinite(c.baseHidden)&&c.baseHidden>=0&&c.baseHidden<=5&&Number.isFinite(c.cap)&&c.cap>0&&c.cap<=10
 &&Array.isArray(c.prices)&&c.prices.length===50&&c.prices.every(v=>typeof v==='string'&&/^(0|[1-9]\d{0,35})$/.test(v))
 &&Array.isArray(c.weights)&&c.weights.length===50&&c.weights.every(w=>Number.isFinite(w)&&w>=.01&&w<=10000);
}
function compact(n){
 n=BigInt(n);const suffix=['','K','M','B','T','P','E','Z','Y','R','Q'];
 let unit=1n,index=0;while(index<suffix.length-1&&n>=unit*1000n){unit*=1000n;index++}
 if(!index)return n.toString();let tenths=(n*10n+unit/2n)/unit;
 if(tenths>=10000n&&index<suffix.length-1){tenths=10n;index++}
 return String(tenths/10n)+(tenths%10n?'.'+String(tenths%10n):'')+suffix[index];
}
function hpAt(r,l){return balancedWall(r,l,config.layers)}
function damage(){
 const p=BigInt($('power').value||1);const multiplier=catalog.tools[+$('tool').value].multiplier;
 let d=p*BigInt(Math.round(multiplier*100))/100n;
 if($('skill').value==='rock')d=d*3n/2n;
 if($('skill').value==='frost')d*=2n;
 if($('hot').checked&&route===2)d/=2n;
 return d>0n?d:1n;
}
function chance(){
 const power=playerValid()?Number($('power').value):1,tool=catalog.tools[+$('tool').value].multiplier;
 const parts=[config.baseHidden,themes[route].bonus,1+.18*(layer-1),1+.06*(tool-1),1+Math.min(1,Math.log10(Math.max(1,power))/12),$('skill').value==='star'?1.25:1];
 return {parts,pct:Math.min(config.cap,parts.reduce((a,b)=>a*b,1))};
}
function pool(){ return mineralPool(route,layer); }
function hiddenPool(){
 const weights=secrets.map(s=>s[4]===route?4:1),sum=weights.reduce((a,b)=>a+b);
 return secrets.map((s,i)=>({secret:s,id:i,p:weights[i]/sum}));
}
function atLeast(p){return -Math.expm1(5*Math.log1p(-p));}
function sample(rows){
 let t=Math.random();for(const row of rows){t-=row.p;if(t<0)return row}return rows.at(-1);
}
function timeText(hits){
 const seconds=hits*38n/100n;
 if(hits===0n)return '已破墙';if(hits===1n)return '约 0.38 秒';if(seconds<60n)return '约 '+Number(hits)*.38+' 秒';
 if(seconds<3600n)return '约 '+seconds/60n+' 分钟';if(seconds<86400n)return '约 '+seconds/3600n+' 小时';return '约 '+compact(seconds/86400n)+' 天';
}
