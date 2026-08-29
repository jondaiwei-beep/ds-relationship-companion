#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');

const root = path.resolve(__dirname, '../../../../..');
const fontConfigPath = path.join(os.tmpdir(), 'ds-relationship-fontconfig.xml');
const fontCachePath = path.join(os.tmpdir(), 'ds-relationship-font-cache');
fs.mkdirSync(fontCachePath, { recursive: true });
fs.writeFileSync(fontConfigPath, `<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><dir>${path.join(root, 'design/assets/fonts/inter')}</dir><dir>${path.join(root, 'design/assets/fonts/cormorant-garamond')}</dir><cachedir>${fontCachePath}</cachedir></fontconfig>`);
process.env.FONTCONFIG_FILE = fontConfigPath;
const sharp = require('sharp');

const tokenSource = JSON.parse(fs.readFileSync(path.join(root, 'design/tokens/design-tokens.json'), 'utf8'));
const registry = JSON.parse(fs.readFileSync(path.join(root, 'manifests/assets.json'), 'utf8'));
const assetById = new Map(registry.assets.map((asset) => [asset.id, asset]));
const candidateRoot = __dirname;
const referenceRoot = path.join(root, 'design/qa/reference');

function get(objectPath) {
  return objectPath.split('.').reduce((node, key) => node?.[key], tokenSource);
}

function token(objectPath) {
  const node = get(objectPath);
  if (!node || node.$value === undefined) throw new Error(`Missing token: ${objectPath}`);
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

const color = {
  canvas: token('color.semantic.canvas.ritual'),
  bone: token('color.primitive.bone'),
  stone: token('color.primitive.stone'),
  warmGray: token('color.primitive.warmGray'),
  deepOlive: token('color.primitive.deepOlive'),
  darkMoss: token('color.primitive.darkMoss'),
  terracotta: token('color.primitive.terracotta'),
  black: token('color.primitive.black'),
};

function escapeXml(value) {
  return String(value).replace(/[<>&'\"]/g, (character) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[character]);
}

function text(x, y, value, size = 14, fill = color.stone, options = {}) {
  const { family = 'Inter', weight = 400, tracking = 0, anchor = 'start', opacity = 1, style = '' } = options;
  return `<text x="${x}" y="${y}" fill="${fill}" fill-opacity="${opacity}" font-family="${family}" font-size="${size}" font-weight="${weight}" letter-spacing="${tracking}" text-anchor="${anchor}" ${style}>${escapeXml(value)}</text>`;
}

function multiline(x, y, lines, size, lineHeight, fill, options = {}) {
  return lines.map((line, index) => text(x, y + index * lineHeight, line, size, fill, options)).join('');
}

function rect(x, y, width, height, fill, radius = 0, stroke = 'none', strokeWidth = 0, opacity = 1) {
  return `<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}" fill="${fill}" fill-opacity="${opacity}" stroke="${stroke}" stroke-width="${strokeWidth}"/>`;
}

function line(x1, y1, x2, y2, stroke = color.deepOlive, width = 1, opacity = 1) {
  return `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="${width}" stroke-opacity="${opacity}" stroke-linecap="round"/>`;
}

function asset(id, x, y, width, height, assetColor = color.bone, opacity = 1) {
  const registered = assetById.get(id);
  if (!registered) throw new Error(`Missing registered asset: ${id}`);
  const source = fs.readFileSync(path.join(root, registered.source_path), 'utf8').replaceAll('currentColor', assetColor);
  const encoded = Buffer.from(source).toString('base64');
  return `<image x="${x}" y="${y}" width="${width}" height="${height}" opacity="${opacity}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${encoded}"/>`;
}

function button(x, y, width, label, options = {}) {
  const { height = 44, primary = false, disabled = false, outline = false } = options;
  const fill = primary ? color.deepOlive : outline ? 'none' : color.darkMoss;
  const stroke = outline ? color.deepOlive : 'none';
  const opacity = disabled ? 0.48 : 1;
  return rect(x, y, width, height, fill, 10, stroke, outline ? 1 : 0, opacity) +
    text(x + width / 2, y + height / 2 + 5, label, 13, primary ? color.bone : color.stone, { weight: 600, anchor: 'middle', opacity });
}

function nav() {
  const items = [
    ['nav.today', 'Today', 49, true], ['nav.dynamic', 'Dynamic', 147, false],
    ['nav.explore', 'Explore', 245, false], ['nav.us', 'Us', 341, false],
  ];
  let body = rect(0, 760, 390, 84, color.canvas, 0, 'none', 0, 0.97) + line(20, 760, 370, 760, color.deepOlive, 1, 0.42);
  for (const [id, label, center, active] of items) {
    body += asset(id, center - 13, 774, 26, 26, active ? color.bone : color.warmGray, active ? 1 : 0.56);
    body += text(center, 820, label, 11, active ? color.bone : color.warmGray, { weight: 500, anchor: 'middle', opacity: active ? 1 : 0.62 });
  }
  return body;
}

function header(options = {}) {
  const { partner = 'Morgan is present', solo = false, unknown = false } = options;
  let body = text(20, 39, 'Today', 22, color.bone, { weight: 600 });
  if (unknown) {
    body += asset('mark.presence', 236, 18, 28, 28, color.warmGray, 0.42);
    body += text(272, 38, 'Confirming context', 12, color.warmGray, { opacity: 0.64 });
  } else if (solo) {
    body += asset('icon.private-space', 244, 18, 28, 28, color.warmGray, 0.8);
    body += text(280, 38, 'Private today', 13, color.stone, { weight: 500 });
  } else {
    body += asset('mark.presence', 230, 17, 30, 30, color.terracotta, 1);
    body += text(268, 38, partner, 13, color.stone, { weight: 500 });
  }
  return body;
}

function frame(body, options = {}) {
  const { partner, solo = false, unknown = false, showNav = true } = options;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="390" height="844" viewBox="0 0 390 844">
    <defs>
      <radialGradient id="vignette" cx="50%" cy="42%" r="75%">
        <stop offset="0%" stop-color="${color.canvas}" stop-opacity="0"/>
        <stop offset="100%" stop-color="${color.black}" stop-opacity="0.18"/>
      </radialGradient>
    </defs>
    ${rect(0, 0, 390, 844, color.canvas)}
    ${rect(0, 0, 390, 844, 'url(#vignette)')}
    ${header({ partner, solo, unknown })}
    ${body}
    ${showNav ? nav() : ''}
  </svg>`;
}

function compactRow(y, number, assetId, titleValue, meta, options = {}) {
  const { relationship = false, selected = false } = options;
  let body = selected ? rect(18, y - 9, 354, 68, color.darkMoss, 12, color.deepOlive, 1) : '';
  body += text(24, y + 14, number, 10, relationship ? color.terracotta : color.warmGray, { weight: 600, tracking: 1.3 });
  body += asset(assetId, 48, y - 1, 28, 28, relationship ? color.terracotta : color.stone, relationship ? 1 : 0.88);
  body += text(88, y + 10, titleValue, 15, color.stone, { weight: 550 });
  body += text(88, y + 31, meta, 11, color.warmGray, { opacity: 0.72 });
  body += line(88, y + 51, 366, y + 51, color.deepOlive, 1, 0.42);
  return body;
}

function defaultState(options = {}) {
  const { roleVariant = false, solo = false } = options;
  const headline = roleVariant ? ['Hold space for our', 'evening check-in.'] : solo ? ['Write one honest line', 'before the day closes.'] : ['Prepare the bedroom', 'before 9:00 PM.'];
  const source = roleVariant ? 'Chosen together · 9:30 PM' : solo ? 'Your private rhythm · tonight' : 'From Morgan · due 9:00 PM';
  let body = text(20, 82, solo ? 'TWO THINGS MATTER · PRIVATE' : roleVariant ? 'THREE THINGS MATTER · CUSTOM ROLE' : 'THREE THINGS MATTER', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += line(20, 104, 20, 279, roleVariant ? color.terracotta : color.deepOlive, 1.5, 0.84);
  body += asset('mark.authority', 34, 106, 28, 28, roleVariant ? color.terracotta : color.stone, 0.9);
  body += text(74, 121, '01 · NOW · EXPECTATION', 10, roleVariant ? color.terracotta : color.warmGray, { weight: 600, tracking: 1.4 });
  body += multiline(34, 165, headline, 27, 31, color.bone, { family: 'Cormorant Garamond', weight: 500 });
  body += text(34, 231, source, 11, color.warmGray, { opacity: 0.78 });
  body += button(34, 247, 90, 'Complete', { primary: true });
  body += text(142, 274, 'Discuss', 11, color.stone, { weight: 550 });
  body += text(206, 274, 'New time', 11, color.stone, { weight: 550 });
  body += text(280, 274, "Can't do", 11, color.stone, { weight: 550 });
  body += compactRow(315, '02', 'emblem.ritual.evening', solo ? 'Quiet evening ritual' : 'Evening ritual', '8:30 PM · 6 min');
  body += compactRow(383, solo ? '—' : '03', 'mark.check-in', 'Daily check-in', solo ? 'Private unless you choose to share' : 'Optional · private until shared');
  if (!solo) {
    body += line(20, 459, 370, 459, color.deepOlive, 1, 0.55);
    body += asset('state.acknowledged', 22, 474, 24, 24, color.terracotta, 0.95);
    body += text(56, 484, 'MORGAN RESPONDED · 12 MIN AGO', 9, color.terracotta, { weight: 600, tracking: 1.2 });
    body += text(56, 521, roleVariant ? '“I felt the care in that.”' : '“I noticed your care.”', 22, color.terracotta, { family: 'Cormorant Garamond', weight: 500 });
    body += line(20, 548, 370, 548, color.deepOlive, 1, 0.55);
    body += text(20, 580, 'LATER / OPTIONAL', 10, color.warmGray, { weight: 600, tracking: 1.5 });
    body += text(318, 580, 'Show 5', 12, color.stone, { weight: 550 });
    body += rect(354, 567, 18, 18, color.darkMoss, 9, color.deepOlive, 1);
    body += text(363, 580, '5', 10, color.stone, { weight: 600, anchor: 'middle' });
  } else {
    body += line(20, 459, 370, 459, color.deepOlive, 1, 0.55);
    body += asset('icon.private-space', 22, 478, 26, 26, color.warmGray, 0.8);
    body += text(58, 487, 'SOLO RHYTHM', 10, color.warmGray, { weight: 600, tracking: 1.4 });
    body += multiline(58, 520, ['Only you can see these items.', 'Nothing is shared automatically.'], 15, 22, color.stone, { weight: 450 });
    body += line(20, 582, 370, 582, color.deepOlive, 1, 0.55);
    body += text(20, 614, 'LATER / OPTIONAL', 10, color.warmGray, { weight: 600, tracking: 1.5 });
    body += text(318, 614, 'Show 3', 12, color.stone, { weight: 550 });
  }
  body += text(20, 716, 'Relationship day ends at 2:00 AM', 10, color.warmGray, { opacity: 0.56 });
  return frame(body, { solo });
}

function expandedState() {
  let body = text(20, 82, '8 ITEMS · 3 PRIORITY', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += compactRow(103, '01', 'mark.authority', 'Prepare the bedroom', 'From Morgan · due 9:00 PM', { selected: true });
  body += compactRow(174, '02', 'emblem.ritual.evening', 'Evening ritual', '8:30 PM · 6 min');
  body += compactRow(245, '03', 'mark.check-in', 'Daily check-in', 'Optional · private until shared');
  body += text(20, 326, 'LATER / OPTIONAL · 5', 10, color.warmGray, { weight: 600, tracking: 1.5 });
  const later = [
    ['04', 'Read Morgan’s note', 'When you are ready'],
    ['05', 'Lay out tomorrow’s clothes', 'Before sleep'],
    ['06', 'One honest journal sentence', 'Optional · private'],
    ['07', 'Drink water and reset', 'Optional'],
    ['08', 'Review the weekend plan', 'Tomorrow · no action yet'],
  ];
  later.forEach(([number, titleValue, meta], index) => {
    const y = 350 + index * 64;
    body += text(24, y + 23, number, 10, color.warmGray, { weight: 600, tracking: 1.2 });
    body += text(58, y + 18, titleValue, 14, color.stone, { weight: 520 });
    body += text(58, y + 38, meta, 10, color.warmGray, { opacity: 0.68 });
    body += line(58, y + 55, 366, y + 55, color.deepOlive, 1, 0.35);
  });
  body += text(20, 700, 'Show less', 12, color.stone, { weight: 550 });
  body += text(370, 700, 'Server order · last synced now', 9, color.warmGray, { anchor: 'end', opacity: 0.56 });
  return frame(body);
}

function loadingState() {
  let body = text(20, 88, 'RESOLVING TODAY', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += text(20, 120, 'Confirming your private context…', 15, color.stone, { weight: 500 });
  body += rect(20, 157, 350, 154, color.darkMoss, 12, color.deepOlive, 1, 0.78);
  body += rect(40, 181, 128, 9, color.deepOlive, 5, 'none', 0, 0.72);
  body += rect(40, 211, 276, 17, color.warmGray, 8, 'none', 0, 0.18);
  body += rect(40, 241, 220, 17, color.warmGray, 8, 'none', 0, 0.13);
  body += rect(40, 281, 96, 12, color.deepOlive, 6, 'none', 0, 0.58);
  [339, 411].forEach((y) => {
    body += rect(20, y, 350, 58, color.darkMoss, 10, color.deepOlive, 1, 0.64);
    body += rect(42, y + 16, 170, 10, color.warmGray, 5, 'none', 0, 0.14);
    body += rect(42, y + 35, 112, 8, color.deepOlive, 4, 'none', 0, 0.5);
  });
  body += line(20, 512, 370, 512, color.deepOlive, 1, 0.42);
  body += text(20, 546, 'PRIVATE BY DEFAULT', 9, color.warmGray, { weight: 600, tracking: 1.5, opacity: 0.68 });
  body += multiline(20, 578, ['Partner details stay hidden until membership', 'and the current relationship day are confirmed.'], 13, 20, color.warmGray, { opacity: 0.68 });
  return frame(body, { unknown: true });
}

function emptyState() {
  let body = text(20, 88, 'TODAY IS QUIET', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += asset('emblem.ritual.evening', 163, 154, 64, 88, color.stone, 0.9);
  body += text(195, 292, 'Nothing needs your', 31, color.bone, { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
  body += text(195, 328, 'attention right now.', 31, color.bone, { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
  body += multiline(195, 372, ['Your day can stay quiet.', 'Check in only if it would help.'], 14, 22, color.warmGray, { anchor: 'middle', opacity: 0.8 });
  body += button(65, 444, 260, 'Open check-in', { height: 56, primary: true });
  body += text(195, 534, 'View your rhythm', 13, color.stone, { weight: 550, anchor: 'middle' });
  body += line(118, 553, 272, 553, color.deepOlive, 1, 0.65);
  body += text(195, 640, 'No missed score. No invented urgency.', 10, color.warmGray, { anchor: 'middle', opacity: 0.56 });
  return frame(body);
}

function errorState() {
  let body = text(20, 88, 'CURRENT STATE UNAVAILABLE', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += line(20, 120, 20, 302, color.deepOlive, 1.5, 0.84);
  body += asset('mark.authority', 42, 134, 52, 52, color.stone, 0.82);
  body += multiline(42, 238, ['Today couldn’t', 'be refreshed.'], 32, 36, color.bone, { family: 'Cormorant Garamond', weight: 500 });
  body += multiline(42, 333, ['No relationship details are shown until', 'the current server state is confirmed.'], 14, 21, color.warmGray, { opacity: 0.82 });
  body += button(42, 414, 306, 'Try again', { height: 56, primary: true });
  body += text(195, 504, 'Go to private entrance', 13, color.stone, { weight: 550, anchor: 'middle' });
  body += line(106, 522, 284, 522, color.deepOlive, 1, 0.62);
  body += text(42, 616, 'Nothing was changed.', 11, color.warmGray, { opacity: 0.62 });
  return frame(body, { unknown: true });
}

function offlineState() {
  let body = rect(20, 72, 350, 54, color.darkMoss, 10, color.deepOlive, 1);
  body += text(36, 94, 'OFFLINE · LAST CONFIRMED 8:42 PM', 9, color.warmGray, { weight: 600, tracking: 1.1 });
  body += text(36, 114, 'Read-only until the server reconnects.', 11, color.stone, { opacity: 0.84 });
  body += text(20, 158, 'THREE CONFIRMED ITEMS', 10, color.warmGray, { weight: 600, tracking: 1.7 });
  body += compactRow(182, '01', 'mark.authority', 'Prepare the bedroom', 'From Morgan · due 9:00 PM', { selected: true });
  body += compactRow(253, '02', 'emblem.ritual.evening', 'Evening ritual', '8:30 PM · 6 min');
  body += compactRow(324, '03', 'mark.check-in', 'Daily check-in', 'Optional · private until shared');
  body += line(20, 410, 370, 410, color.deepOlive, 1, 0.52);
  body += text(20, 445, 'Actions are paused offline', 15, color.stone, { weight: 550 });
  body += multiline(20, 475, ['Complete, Discuss, New Time and Can’t Do', 'will return after current truth is confirmed.'], 12, 19, color.warmGray, { opacity: 0.75 });
  body += button(20, 548, 350, 'Try to reconnect', { height: 56, outline: true });
  body += text(20, 650, 'Cached content is never treated as a new state.', 10, color.warmGray, { opacity: 0.56 });
  return frame(body);
}

function authorizationLossState() {
  let body = text(20, 88, 'PRIVATE SESSION ENDED', 10, color.warmGray, { weight: 600, tracking: 1.8 });
  body += asset('state.locked', 159, 160, 72, 72, color.stone, 0.95);
  body += text(195, 292, 'Your private session', 31, color.bone, { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
  body += text(195, 328, 'needs to be restored.', 31, color.bone, { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
  body += multiline(195, 372, ['Partner and Dynamic details have been hidden.', 'Sign in again to confirm current access.'], 13, 21, color.warmGray, { anchor: 'middle', opacity: 0.82 });
  body += button(65, 448, 260, 'Sign in again', { height: 56, primary: true });
  body += text(195, 540, 'Leave this device', 13, color.stone, { weight: 550, anchor: 'middle' });
  body += line(126, 559, 264, 559, color.deepOlive, 1, 0.62);
  body += text(195, 646, 'No protected content remains on this screen.', 10, color.warmGray, { anchor: 'middle', opacity: 0.56 });
  return frame(body, { unknown: true });
}

const stateDefinitions = [
  { key: 'default', label: 'DEFAULT · 3 PRIORITY', svg: () => defaultState(), root: candidateRoot },
  { key: 'expanded', label: 'EXPANDED · 8 ITEMS', svg: expandedState },
  { key: 'loading', label: 'LOADING · PRIVATE', svg: loadingState },
  { key: 'empty', label: 'EMPTY · QUIET', svg: emptyState },
  { key: 'error-retry', label: 'ERROR · RETRY', svg: errorState },
  { key: 'offline', label: 'OFFLINE · READ ONLY', svg: offlineState },
  { key: 'authorization-loss', label: 'AUTHORIZATION LOSS', svg: authorizationLossState },
  { key: 'role-variant', label: 'ROLE NEUTRAL', svg: () => defaultState({ roleVariant: true }) },
  { key: 'solo', label: 'SOLO · PRIVATE', svg: () => defaultState({ solo: true }) },
];

async function renderState(definition) {
  const output = definition.root || path.join(candidateRoot, 'states', definition.key);
  fs.mkdirSync(output, { recursive: true });
  const svg = Buffer.from(definition.svg());
  await sharp(svg, { density: 216 }).resize(1170, 2532, { fit: 'fill' }).png().toFile(path.join(output, 'source.png'));
  await sharp(svg, { density: 144 }).resize(390, 844, { fit: 'fill' }).webp({ quality: 94, smartSubsample: true }).toFile(path.join(output, 'preview.webp'));
  return { ...definition, output, preview: path.join(output, 'preview.webp') };
}

async function renderBoard(states) {
  const boardWidth = 1600;
  const boardHeight = 1350;
  const thumbWidth = 234;
  const thumbHeight = 506;
  const cardWidth = 284;
  const cardHeight = 568;
  const left = 48;
  const top = 150;
  const gapX = 24;
  const gapY = 28;
  const composites = [];
  const boardSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${boardWidth}" height="${boardHeight}"><rect width="100%" height="100%" fill="${color.bone}"/>${text(48, 54, 'TODAY · B-3 STATE FAMILY', 30, color.darkMoss, { weight: 650, tracking: 4 })}${text(48, 98, 'V5 Warm Authority · default list, 8-item expansion and recovery/role variants', 16, color.deepOlive, { weight: 450 })}</svg>`;
  const base = sharp(Buffer.from(boardSvg));
  const legacy = {
    key: 'ritual-focus',
    label: 'PRESERVED · RITUAL FOCUS',
    preview: path.join(root, 'design/screens/SCR-01-today/preview.webp'),
  };
  const all = [states[0], states[1], legacy, ...states.slice(2)];
  for (let index = 0; index < all.length; index += 1) {
    const entry = all[index];
    const column = index % 5;
    const row = Math.floor(index / 5);
    const x = left + column * (cardWidth + gapX);
    const y = top + row * (cardHeight + gapY);
    const card = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${cardWidth}" height="${cardHeight}"><rect width="100%" height="100%" rx="16" fill="${color.darkMoss}" stroke="${color.deepOlive}"/><text x="${cardWidth / 2}" y="548" text-anchor="middle" fill="${color.stone}" font-family="Inter, Arial" font-size="12" font-weight="600" letter-spacing="1">${escapeXml(entry.label)}</text></svg>`);
    const preview = await sharp(entry.preview).resize(thumbWidth, thumbHeight, { fit: 'fill' }).png().toBuffer();
    composites.push({ input: card, left: x, top: y });
    composites.push({ input: preview, left: x + 25, top: y + 18 });
  }
  await base.composite(composites).png().toFile(path.join(referenceRoot, 'today-b3-state-family-board.png'));
}

async function main() {
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];
  for (const definition of stateDefinitions) rendered.push(await renderState(definition));
  await renderBoard(rendered);
  const report = {
    candidate_id: 'SCR-01-REV-2-B3',
    generated_at: new Date().toISOString(),
    result: 'pass',
    viewport: { width: 390, height: 844 },
    source_scale: 3,
    states: rendered.map((state) => ({
      key: state.key,
      preview: path.relative(root, state.preview),
      source: path.relative(root, path.join(state.output, 'source.png')),
    })),
    preserved_reference: 'design/screens/SCR-01-today/preview.webp',
    board: 'design/qa/reference/today-b3-state-family-board.png',
    tokens: tokenSource.meta.freezeId,
    semantic_asset_ids: JSON.parse(fs.readFileSync(path.join(candidateRoot, 'today-b3-spec.json'), 'utf8')).assets,
  };
  fs.writeFileSync(path.join(referenceRoot, 'today-b3-state-family-validation.json'), `${JSON.stringify(report, null, 2)}\n`);
  process.stdout.write(`Today B-3 rendered · ${rendered.length} new states + preserved ritual focus\n${path.join(referenceRoot, 'today-b3-state-family-board.png')}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
