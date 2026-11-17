function showProgression() {
    const tool=catalog.tools[Number($('tool').value)].multiplier;
    const gain=trainingGain(Number($('area').value),tool,completed);
    const level=levelAt(earnedXP,completed);
    const next=rebirthCost(completed);
    $('trainInfo').textContent='重生 '+completed+' 次 · 当前 '+level+' / 50 级 · 累计经验 '
        +compact(earnedXP)+' / '+compact(roundTarget(completed))+' · 每次训练 +'+compact(gain)+' 力量与经验';
    $('levelBar').max=Number(roundTarget(completed));
    $('levelBar').value=Number(earnedXP);
    $('rebirthNow').disabled=next===null||level<50;
    $('rebirth').value=completed;
    $('rebirthRows').innerHTML=Array.from({length:20},(_,r)=>'<tr><td>第 '+(r+1)+' 次</td><td title="'+roundTarget(r)+'">'
        +compact(roundTarget(r))+' XP</td><td>×'+compact(4n**BigInt(r+1))+'</td><td>'+maxTraining(r)+'× / '+plannedTool(r)+'×</td><td>'
        +compact(trainingGain(maxTraining(r),plannedTool(r),r))+'</td><td>'+(estimateSeconds(r)/60).toFixed(1)+' 分钟</td></tr>').join('');
    $('mapRows').innerHTML=themes.map((theme,r)=>'<tr><td>'+theme.label+' · '+theme.name+'</td><td>'+rebirthGates[r]+' 次</td>'
        +Array.from({length:config.layers},(_,i)=>'<td title="'+balancedWall(r,i+1,config.layers)+'">'
        +compact(balancedWall(r,i+1,config.layers))+'</td>').join('')+'</tr>').join('');
    $('mapHead').innerHTML='<th>矿道</th><th>重生开放</th>'+Array.from({length:config.layers},(_,i)=>'<th>'+(i+1)+' 层</th>').join('');
    $('trainAreas').innerHTML=trainingAreas.map(area=>'<span class="area-tag">'+area.multiplier+'× 区 · R'+area.rebirth+'</span>').join('');
    $('xpRows').innerHTML=Array.from({length:49},(_,i)=>'<tr><td>'+(i+1)+' → '+(i+2)+' 级</td><td title="'+levelCost(i+1,completed)+'">'
        +compact(levelCost(i+1,completed))+'</td><td title="'+xpForLevel(i+2,completed)+'">'+compact(xpForLevel(i+2,completed))
        +'</td><td>'+compact((levelCost(i+1,completed)+gain-1n)/gain)+' 次</td></tr>').join('');
    const choice=Number($('levelChoice').value);
    $('levelPreview').textContent=choice===50?'50 级为本轮满级，累计需 '+compact(roundTarget(completed))+' XP。'
        :'升 '+choice+' → '+(choice+1)+' 级需要 '+levelCost(choice,completed).toLocaleString('en-US')+' XP。';
    if(completed<rebirthGates[route]) {
        $('remaining').textContent+='　此道需重生 '+rebirthGates[route]+' 次开放，当前为数值预览。';
        $('auto').disabled=true;
    }
    showEquipment();
    showOreInspector();
}
function refreshAreas() {
    const old=Number($('area').value||1);
    const allowed=trainingAreas.filter(area=>area.rebirth<=completed);
    $('area').innerHTML=allowed.map(area=>'<option value="'+area.multiplier+'">'+area.multiplier+'× 训练区</option>').join('');
    $('area').value=allowed.some(area=>area.multiplier===old)?old:allowed.at(-1).multiplier;
}
const originalRender=render;
render=function(){originalRender();showProgression()};
const originalRenderWall=renderWall;
renderWall=function(){originalRenderWall();showProgression()};
$('rebirth').onchange=()=>{
    completed=Number($('rebirth').value);
    earnedXP=0n;
    $('power').value='1';
    refreshAreas();
    reset();
};
$('area').onchange=showProgression;
function addTraining(ticks) {
    if(!playerValid()) return;
    const tool=catalog.tools[Number($('tool').value)].multiplier;
    const increment=trainingGain(Number($('area').value),tool,completed)*BigInt(ticks);
    $('power').value=(BigInt($('power').value)+increment).toString();
    earnedXP+=increment;
    stop();
    render();
}
$('trainOnce').onclick=()=>addTraining(1);
$('trainMinute').onclick=()=>addTraining(112);
$('rebirthNow').onclick=()=>{
    if(completed>=20||levelAt(earnedXP,completed)<50)return;
    completed++;
    earnedXP=0n;
    $('power').value='1';
    refreshAreas();
    reset();
};
$('levelChoice').onchange=showProgression;
$('oreChoice').innerHTML=themes.map((theme,r)=>'<optgroup label="'+theme.name+'">'
    +catalog.minerals.filter(ore=>ore.route===r).map(ore=>'<option value="'+ore.id+'">'+ore.name+'</option>').join('')+'</optgroup>').join('');
$('oreChoice').onchange=showOreInspector;
$('chosenBase').onchange=()=>{
    const prices=[...config.prices];
    prices[Number($('oreChoice').value)-1]=$('chosenBase').value.trim();
    const next={...config,prices};
    if(validConfig(next)){config=next;save();render()}
    else{$('saveStatus').textContent='基础价请填 0 至 36 位非负整数。';showOreInspector()}
};
$('gearRows').onclick=e=>{
    const button=e.target.closest('[data-buy]');
    if(!button)return;
    const index=Number(button.dataset.buy),cost=gearPrice(index);
    if(index===0||index===9||ownedTools.has(index)||completed<toolMilestones[index].rebirth||wallet<cost)return;
    wallet-=cost;
    ownedTools.add(index);
    $('tool').value=index;
    stop();
    render();
};
refreshAreas();
render();
