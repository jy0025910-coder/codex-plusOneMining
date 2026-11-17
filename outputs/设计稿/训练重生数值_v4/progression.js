function showProgression() {
    const tool = catalog.tools[Number($('tool').value)].multiplier;
    const area = Number($('area').value);
    const gain = trainingGain(area, tool, completed);
    const next = rebirthCost(completed);
    const power = playerValid() ? BigInt($('power').value) : 1n;
    $('trainInfo').textContent = '已重生 ' + completed + ' 次 · 训练加成 ×' + compact(4n ** BigInt(completed))
        + ' · 每次训练 +' + compact(gain) + ' 力量'
        + (next ? ' · 下次重生需 ' + compact(next) + ' 当前力量' : ' · 已达重生上限');
    $('rebirthNow').disabled = next === null || power < next;
    $('rebirth').value = completed;
    $('rebirthRows').innerHTML = Array.from({length:20}, (_, index) => {
        const n = index + 1;
        return '<tr><td>第 ' + n + ' 次</td><td title="' + rebirthCost(index) + '">'
            + compact(rebirthCost(index)) + '</td><td>×' + compact(4n ** BigInt(n))
            + '</td><td>' + maxTraining(index) + '× / ' + plannedTool(index) + '×</td><td>'
            + compact(trainingGain(maxTraining(index), plannedTool(index), index))
            + '</td><td>' + (estimateSeconds(index)/60).toFixed(1) + ' 分钟</td></tr>';
    }).join('');
    $('mapRows').innerHTML = themes.map((theme, r) => '<tr><td>' + theme.label + ' · ' + theme.name
        + '</td><td>' + rebirthGates[r] + ' 次</td>' + Array.from({length:config.layers}, (_, i) =>
        '<td title="' + balancedWall(r, i+1, config.layers) + '">' + compact(balancedWall(r, i+1, config.layers)) + '</td>').join('') + '</tr>').join('');
    $('mapHead').innerHTML = '<th>矿道</th><th>重生开放</th>' + Array.from({length:config.layers},(_,i)=>'<th>'+(i+1)+' 层</th>').join('');
    $('trainAreas').innerHTML = trainingGates.map((gate,i)=>'<span class="area-tag">'+(i+1)+'× 区 · R'+gate+'</span>').join('');
    const locked = completed < rebirthGates[route];
    if (locked) {
        $('remaining').textContent += '　此道需重生 ' + rebirthGates[route] + ' 次开放，当前为数值预览。';
        $('auto').disabled = true;
    }
}
function refreshAreas() {
    const old = Number($('area').value || 1);
    const max = maxTraining(completed);
    $('area').innerHTML = Array.from({length:max},(_,i)=>'<option value="'+(i+1)+'">'+(i+1)+'× 训练区</option>').join('');
    $('area').value = Math.min(old,max);
}
const originalRender = render;
render = function() { originalRender(); showProgression(); };
const originalRenderWall = renderWall;
renderWall = function() { originalRenderWall(); showProgression(); };
$('rebirth').onchange = () => {
    completed = Number($('rebirth').value);
    refreshAreas();
    reset();
};
$('area').onchange = showProgression;
function addTraining(ticks) {
    if (!playerValid()) return;
    const tool = catalog.tools[Number($('tool').value)].multiplier;
    const increment = trainingGain(Number($('area').value), tool, completed) * BigInt(ticks);
    $('power').value = (BigInt($('power').value) + increment).toString();
    stop();
    render();
}
$('trainOnce').onclick = () => addTraining(1);
$('trainMinute').onclick = () => addTraining(112);
$('rebirthNow').onclick = () => {
    const cost = rebirthCost(completed);
    if (cost === null || !playerValid() || BigInt($('power').value) < cost) return;
    completed++;
    $('power').value = '1';
    refreshAreas();
    reset();
};
refreshAreas();
render();
