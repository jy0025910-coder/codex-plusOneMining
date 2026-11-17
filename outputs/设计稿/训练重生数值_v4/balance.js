const rebirthGates = [0, 2, 5, 8, 10];
const trainingGates = [0, 0, 0, 1, 2, 3, 5, 7, 10, 12];
const plannedTools = [2, 3, 4, 6, 6, 8, 8, 10, 10, 10, 12];
const routeLast = [
    125000n * 4n * 12n,
    15625000n * 8n * 15n,
    1953125000n * 10n * 18n,
    48828125000n * 12n * 20n,
    286102294921875000n * 12n * 30n
];
const routeFirst = [500n, 1200000n, 375000000n, 70312500000n, 2343750000000n];

function rebirthCost(completed) {
    return completed >= 20 ? null : 5000n * 5n ** BigInt(completed);
}
function trainingGain(area, tool, completed) {
    return BigInt(area) * BigInt(Math.round(tool * 100)) * 4n ** BigInt(completed) / 100n;
}
function balancedWall(r, depth, count) {
    if (depth === 1) return routeFirst[r];
    if (depth === count) return routeLast[r];
    const first = Number(routeFirst[r]);
    const last = Number(routeLast[r]);
    const value = first * (last / first) ** ((depth - 1) / (count - 1));
    return BigInt(Math.round(Number(value.toPrecision(3))));
}
function maxTraining(completed) {
    return trainingGates.findLastIndex(gate => gate <= completed) + 1;
}
function plannedTool(completed) {
    return plannedTools[Math.min(completed, plannedTools.length - 1)];
}
function estimateSeconds(completed) {
    const cost = rebirthCost(completed);
    if (cost === null) return null;
    const gain = trainingGain(maxTraining(completed), plannedTool(completed), completed);
    return Number((cost - 1n + gain - 1n) / gain) * (0.8 / 1.5);
}

let completed = 0;
