import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const dir = path.dirname(fileURLToPath(import.meta.url));
const previous = path.join(dir, '../矿道探勘手册_v1');
const earlier = fs.readFileSync(path.join(previous, 'design-data.js'), 'utf8');
const catalog = vm.runInNewContext(earlier + `\n({
  routes: zones.map(({ name, color, stops, hazard }) => ({ name, color, stops, hazard })),
  minerals: ore.map(({ id, z, i, name, fact, type, hex }) => ({ id, route: z, rank: i, name, fact, type, hex })),
  tools: picks.map(({ name, m }) => ({ name, multiplier: m })),
  hidden: secrets.map(([name, type]) => ({ name, type }))
})`);
const text = name => fs.readFileSync(path.join(dir, name), 'utf8');
const image = (file, mime) => 'data:image/' + mime + ';base64,' + fs.readFileSync(file).toString('base64');
const parts = {
    '__STYLE__': text('style.css'),
    '__CATALOG__': JSON.stringify(catalog),
    '__MODEL__': text('balance.js') + '\n' + text('economy.js') + '\n' + text('equipment.js'),
    '__APP__': text('app.js') + '\n' + text('progression.js'),
    '__WALL_PHOTO__': image(path.join(dir, '../../工程/资产/峡谷围墙_整图_v3/Renders/Studio_Wall_Close.jpg'), 'jpeg'),
    '__TOOLS_PLATE__': image(path.join(previous, '十把矿镐_原画.png'), 'png')
};
const html = text('page.template.html').replace(/__(?:STYLE|CATALOG|MODEL|APP|WALL_PHOTO|TOOLS_PLATE)__/g, token => parts[token]);
fs.writeFileSync(path.join(dir, '晶脉峡谷_破墙与矿价.html'), html);
