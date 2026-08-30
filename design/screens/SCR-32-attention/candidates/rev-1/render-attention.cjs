#!/usr/bin/env node

// SCR-32 Attention — the direction-giving member's daily surface.
//
//   node design/screens/SCR-32-attention/candidates/rev-1/render-attention.cjs
//
// The only Core Beta screen that had no design at all. The composition here
// came from Codex, briefed with the four surrounding screens, the real server
// response and the product rules; this file is that design ported onto the
// frozen tokens and the SVG registry, with four defects fixed. What changed
// from the original is listed in README.md.
//
// Attention is deliberately not shaped like Today. Today is centred and
// ceremonial — one thing at a time, for the person being asked. This is a
// list, for the person being waited on: several items visible at once,
// ordered by the server, scannable in seconds.

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../../../../..');
const fonts = require(path.join(root, 'design/qa/scripts/fonts.cjs'));
fonts.install();
const sharp = require('sharp');

const tokenSource = JSON.parse(
  fs.readFileSync(path.join(root, 'design/tokens/design-tokens.json'), 'utf8'),
);
const registry = JSON.parse(
  fs.readFileSync(path.join(root, 'manifests/assets.json'), 'utf8'),
);
const freeze = JSON.parse(
  fs.readFileSync(path.join(root, 'manifests/svg-freeze.v1.json'), 'utf8'),
);
const assetById = new Map(registry.assets.map((a) => [a.id, a]));
const freezeById = new Map((freeze.assets ?? []).map((a) => [a.id, a]));

const outRoot = path.join(__dirname);
const referenceRoot = path.join(root, 'design/qa/reference');

function get(p) { return p.split('.').reduce((n, k) => n?.[k], tokenSource); }

function token(p) {
  const node = get(p);
  if (!node || node.$value === undefined) throw new Error(`Missing token: ${p}`);
  let value = node.$value;
  const seen = new Set();
  while (typeof value === 'string' && /^\{.+\}$/.test(value)) {
    const alias = value.slice(1, -1);
    if (seen.has(alias)) throw new Error(`Token alias cycle: ${alias}`);
    seen.add(alias);
    const target = get(alias);
    if (!target || target.$value === undefined) throw new Error(`Missing alias: ${alias}`);
    value = target.$value;
  }
  return value;
}

const W = 390, H = 844, SCALE = 3;

// Resolved from the freeze rather than transcribed, so a token change reaches
// this screen instead of leaving it quietly stale.
const C = {
  canvas: token('color.semantic.canvas.ritual'),
  raised: token('color.semantic.surface.ritual.raised'),
  primary: token('color.semantic.text.onRitual.primary'),
  secondary: token('color.semantic.text.onRitual.secondary'),
  muted: token('color.semantic.text.onRitual.muted'),
  line: token('color.semantic.border.onRitual.hairline'),
  terra: token('color.semantic.text.onRitual.relationshipLarge'),
};

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  relationship: 'color.semantic.icon.relationship',
  authority: 'color.semantic.icon.authority',
};

/// A registered mark at a size and tone the freeze licenses.
///
/// The original drew every icon by hand as inline paths. That is forbidden —
/// screens reference Asset IDs so a mark changes in one place — and it also
/// meant the tone rules were unenforced. This throws instead.
function asset(id, x, y, size, tone) {
  const registered = assetById.get(id);
  if (!registered) throw new Error(`Unregistered asset: ${id}`);
  const rules = freezeById.get(id);
  if (rules) {
    if (!rules.sizes_dp.includes(size)) {
      throw new Error(`${id} is frozen at ${rules.sizes_dp.join('/')}dp, not ${size}`);
    }
    if (!rules.colors.includes(tone)) {
      throw new Error(`${id} does not license the ${tone} tone (${rules.colors.join(', ')})`);
    }
  }
  const svgSource = fs
    .readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', token(toneToken[tone]));
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${Buffer.from(svgSource).toString('base64')}"/>`;
}

const esc = s => String(s).replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
const text = (x,y,s,size=14,fill=C.primary,weight=400,anchor='start',family='Inter',spacing=0) =>
  `<text x="${x}" y="${y}" fill="${fill}" font-family="${family}" font-size="${size}" font-weight="${weight}" text-anchor="${anchor}" letter-spacing="${spacing}">${esc(s)}</text>`;
const line = (x1,y1,x2,y2,color=C.line,w=1) => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-width="${w}"/>`;
const rect = (x,y,w,h,fill='none',stroke='none',r=0,sw=1) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;
const circle = (x,y,r,fill='none',stroke=C.muted,sw=1) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;

function presence(label='Morgan is present') {
  return `${asset('mark.presence', 240, 20, 24, 'relationship')}${text(272, 37, label, 12, C.muted, 400)}`;
}

function header(title, presenceLabel='Morgan is present') {
  return `${text(24,40,title,23,C.primary,650)}${presenceLabel ? presence(presenceLabel) : ''}`;
}

/// Maps a row kind to a registered mark.
///
/// `state.waiting-response` for a partner's request, `response.*` for the
/// four ways to answer, `mark.guidance` for work to revisit. Each already
/// carries its own tone licence, which is why the tone is passed through
/// rather than a colour.
function icon(kind, x, y, tone = 'muted') {
  const id = {
    chat: 'response.comment',
    clock: 'state.waiting-response',
    eye: 'response.acknowledge',
    heart: 'response.praise',
    review: 'mark.guidance',
    refresh: 'mark.guidance',
    lock: 'mark.guidance',
  }[kind];
  if (!id) throw new Error(`No registered mark for ${kind}`);
  // `mark.guidance` licenses primary and authority, never muted or
  // relationship. That is the freeze saying guidance is not a partner's
  // warmth and not a dimmed afterthought — so the rows that use it take
  // primary rather than being quietly downgraded.
  const licensed = freezeById.get(id)?.colors ?? [];
  const resolved = licensed.includes(tone) ? tone : licensed[0];
  return asset(id, x - 12, y - 12, 24, resolved);
}

function nav(active='Today') {
  const xs=[50,147,244,341], labels=['Today','Dynamic','Explore','Us'];
  let s=line(20,764,370,764,C.line);
  xs.forEach((x,i)=>{
    const col=labels[i]===active?C.primary:C.muted;
    if(i===0) s+=`<g stroke="${col}" fill="none" stroke-width="1.2"><circle cx="${x}" cy="788" r="6"/>${line(x,776,x,770,col)}${line(x,806,x,800,col)}${line(x-12,788,x-7,788,col)}${line(x+7,788,x+12,788,col)}</g>`;
    if(i===1) s+=`<g stroke="${col}" fill="none" stroke-width="1.1">${circle(x,788,10,'none',col)}${line(x-5,784,x-5,792,col)}${line(x-1,780,x-1,796,col)}${line(x+3,783,x+3,793,col)}${line(x+7,786,x+7,790,col)}</g>`;
    if(i===2) s+=`<g stroke="${col}" fill="none" stroke-width="1.1">${circle(x,788,10,'none',col)}<path d="M${x-4} 792l2-6 6-2-2 6z"/></g>`;
    if(i===3) s+=`<g stroke="${col}" fill="none" stroke-width="1.1">${circle(x,781,5,'none',col)}<path d="M${x-8} 799q1-11 8-11t8 11"/></g>`;
    s+=text(x,821,labels[i],11,col,400,'middle');
  });
  return s;
}

function section(y,label,count) {
  return `${text(24,y,label,10,C.muted,600,'start','Inter',1.8)}${count!==undefined?`${circle(350,y-4,10,C.raised,C.line)}${text(350,y,count,10,C.secondary,600,'middle')}`:''}`;
}

function compactRow(y,kind,title,meta,relational=false) {
  const mark=relational?C.terra:C.muted;
  return `${line(24,y+71,366,y+71,C.line)}${circle(36,y+29,12,'none',relational?C.terra:C.line)}${icon(kind, 36, y + 29, relational ? 'relationship' : 'muted')}${text(60,y+26,title,15,C.primary,500)}${text(60,y+48,meta,11,C.muted)}<path d="M352 ${y+27}l4 4-4 4" fill="none" stroke="${C.muted}" stroke-width="1"/>`;
}

function sendButton(x,y,w,label,kind) {
  return `${rect(x,y,w,48,C.raised,C.line,12)}${icon(kind, x + 22, y + 24, 'relationship')}${text(x+39,y+28,label,11,C.secondary,600)}`;
}

function answerCard(y) {
  return `${rect(24,y,342,136,C.raised,C.line,12)}
    ${text(40, y + 25, 'One honest sentence', 15, C.primary, 500)}
    ${text(40,y+46,'Morgan completed · 9:14 PM',11,C.muted)}
    ${text(40,y+70,'RESPOND TO MORGAN',9,C.muted,600,'start','Inter',1.5)}
    ${sendButton(40, y + 78, 152, 'Acknowledge', 'eye')}
    ${sendButton(200, y + 78, 150, 'Praise', 'heart')}`;
}

function defaultScreen() {
  let s=header('Attention');
  s+=text(24,83,'WHAT NEEDS YOUR ANSWER',10,C.muted,600,'start','Inter',1.9);
  s+=text(24,111,'5 moments',13,C.secondary,500);
  // 4, not 2: `needsResponseCount` counts everything awaiting an answer,
  // including the two requests above. It counted only completions until
  // today, which would have read "2" while four things waited.
  s += text(366, 111, '4 awaiting your answer · 1 to revisit', 11, C.muted, 400, 'end');
  s+=line(24,128,366,128,C.line);
  s+=`<rect x="24" y="145" width="2" height="144" rx="1" fill="${C.terra}"/>`;
  s+=section(150,'MORGAN IS WAITING',2);
  s+=compactRow(164,'chat','Evening ritual','Morgan · asked to discuss · 2h ago',true);
  s+=compactRow(236,'clock','Morning intention','Morgan · asked for a new time · 4h ago',true);
  s+=section(331,'COMPLETIONS TO ANSWER',2);
  s+=answerCard(346);
  s+=compactRow(494,'eye','Prepare the evening','Morgan completed · yesterday',true);
  s+=section(589,'LOOK BACK TOGETHER',1);
  s+=compactRow(604,'review','Daily check-in','Open since Tuesday',false);
  s+=nav(); return s;
}

function loadingScreen() {
  let s=header('Attention');
  s+=rect(24,75,162,8,C.line,'none',4)+rect(24,102,78,12,C.raised,'none',6)+rect(270,102,96,10,C.raised,'none',5)+line(24,128,366,128,C.line);
  [151,246,341,436,531].forEach((y,i)=>{
    s+=rect(24,y,342,78,C.raised,'none',10)+circle(48,y+27,11,C.line,'none',0)+rect(72,y+18,126+(i%2)*34,11,C.line,'none',5)+rect(72,y+42,190-(i%3)*22,8,C.line,'none',4);
  });
  s+=text(24,660,'Refreshing Attention…',11,C.muted);
  s+=nav(); return s;
}

function emptyScreen() {
  let s=header('Attention');
  s+=text(24,83,'WHAT NEEDS YOUR ANSWER',10,C.muted,600,'start','Inter',1.9)+line(24,105,366,105,C.line);
  s+=circle(195,251,28,'none',C.line,1)+circle(195,251,6,'none',C.muted,1)+line(195,213,195,233,C.line)+line(195,269,195,289,C.line);
  s+=text(195,350,'The space is clear.',31,C.primary,500,'middle','Cormorant Garamond');
  s+=text(195,386,'Nothing needs your answer right now.',14,C.secondary,400,'middle');
  s+=text(195,412,'New moments will appear here.',12,C.muted,400,'middle');
  s+=nav(); return s;
}

function offlineScreen() {
  let s=header('Attention',null);
  s+=rect(24,67,342,66,C.raised,C.line,10)+circle(48,100,12,'none',C.line)+line(42,106,54,94,C.muted,1.2);
  s+=text(70,94,"You're offline",14,C.primary,600)+text(70,114,'Showing the last saved view · not current',11,C.muted);
  s+=text(24,161,'LAST SAVED VIEW',10,C.muted,600,'start','Inter',1.8);
  s+=compactRow(177,'chat','Evening ritual','Morgan · asked to discuss · 2h ago',true);
  s+=compactRow(249,'clock','Morning intention','Morgan · asked for a new time · 4h ago',true);
  s+=compactRow(321,'eye','One honest sentence','Morgan completed · 9:14 PM',true);
  s+=compactRow(393,'eye','Prepare the evening','Morgan completed · yesterday',true);
  s+=compactRow(465,'review','Daily check-in','Open since Tuesday',false);
  s+=rect(24,572,342,56,C.line,'none',10)+icon('refresh', 135, 600, 'primary')+text(157,605,'Try again',15,C.primary,600);
  s+=text(195,657,'Responses can be prepared, but not sent offline.',11,C.muted,400,'middle');
  s+=nav(); return s;
}

function errorScreen() {
  let s=header('Attention',null);
  s+=circle(195,245,29,'none',C.line)+icon('refresh', 195, 245, 'muted');
  s+=text(195,327,'Attention could not refresh.',27,C.primary,500,'middle','Cormorant Garamond');
  s+=text(195,365,'We could not load the current view.',13,C.secondary,400,'middle');
  s+=text(195,389,'Nothing has been sent.',12,C.muted,400,'middle');
  s+=rect(24,454,342,56,C.line,'none',10)+icon('refresh', 135, 482, 'primary')+text(157,487,'Try again',15,C.primary,600);
  s+=nav(); return s;
}

function authLossScreen() {
  let s=header('Attention',null);
  s+=circle(195,239,31,'none',C.line)+icon('lock', 195, 237, 'muted');
  s+=text(195,327,'Sign in to continue.',30,C.primary,500,'middle','Cormorant Garamond');
  s+=text(195,365,'Your private relationship space is hidden.',13,C.secondary,400,'middle');
  s+=text(195,389,'Sign in again to return to Attention.',12,C.muted,400,'middle');
  s+=rect(24,454,342,56,C.line,'none',10)+text(195,488,'Sign in',15,C.primary,600,'middle');
  s+=text(195,539,'No relationship details are shown on this screen.',11,C.muted,400,'middle');
  return s;
}


function svg(content) {
  return `<svg width="${W}" height="${H}" viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${W}" height="${H}" fill="${C.canvas}"/>
  <g shape-rendering="geometricPrecision">${content}</g></svg>`;
}

const states = [
  ['default', 'WHAT IS WAITING', defaultScreen],
  ['loading', 'LOADING', loadingScreen],
  ['empty', 'NOTHING WAITING', emptyScreen],
  ['offline', 'OFFLINE', offlineScreen],
  ['error', 'RETRY', errorScreen],
  ['auth-loss', 'SIGN IN AGAIN', authLossScreen],
];

async function write(content, dir) {
  fs.mkdirSync(dir, { recursive: true });
  const buf = Buffer.from(svg(content));
  await sharp(buf, { density: 72 * SCALE }).resize(W * SCALE, H * SCALE, { fit: 'fill' })
    .png().toFile(path.join(dir, 'source.png'));
  await sharp(buf, { density: 72 }).resize(W, H, { fit: 'fill' })
    .webp({ quality: 92 }).toFile(path.join(dir, 'preview.webp'));
}

async function board(rendered) {
  const tw = 170;
  const th = Math.round((H / W) * tw);
  const cw = tw + 34;
  const ch = th + 48;
  const gap = 16;
  const width = 40 + rendered.length * (cw + gap);
  const height = 96 + ch + gap;
  const base = sharp({ create: { width, height, channels: 4, background: C.canvas } });
  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="70">` +
      text(32, 44, 'SCR-32 Attention · candidate rev-1', 20, C.primary, 600) + '</svg>'),
    left: 0, top: 12,
  }];
  for (let i = 0; i < rendered.length; i += 1) {
    const e = rendered[i];
    const x = 20 + i * (cw + gap);
    composites.push({
      input: Buffer.from(
        `<svg xmlns="http://www.w3.org/2000/svg" width="${cw}" height="${ch}">` +
        rect(0, 0, cw, ch, C.raised, C.line, 12) +
        text(cw / 2, ch - 14, e.label, 9, C.secondary, 600, 'middle', 'Inter', 1) + '</svg>'),
      left: x, top: 92,
    });
    composites.push({
      input: await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer(),
      left: x + 17, top: 108,
    });
  }
  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'attention-state-family-board.png'));
}

async function main() {
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];
  for (const [key, label, build] of states) {
    const dir = key === 'default' ? outRoot : path.join(outRoot, 'states', key);
    await write(build(), dir);
    rendered.push({ key, label, preview: path.join(dir, 'preview.webp') });
  }
  await board(rendered);
  fs.writeFileSync(
    path.join(referenceRoot, 'attention-state-family-validation.json'),
    `${JSON.stringify({
      candidate_id: 'SCR-32-REV-1',
      generated_at: new Date().toISOString(),
      result: 'pass',
      viewport: { width: W, height: H },
      source_scale: SCALE,
      tokens: tokenSource.meta.freezeId,
      svg_freeze: freeze.freeze_id,
      states: rendered.map((r) => ({ key: r.key, preview: path.relative(root, r.preview) })),
      board: 'design/qa/reference/attention-state-family-board.png',
      build_gate: 'unchanged — this is a candidate, not an approval',
    }, null, 2)}\n`,
  );
  process.stdout.write(`SCR-32 rendered · ${rendered.length} states\n`);
}

main().catch((e) => {
  process.stderr.write(`${e.stack || e.message}\n`);
  process.exitCode = 1;
});
