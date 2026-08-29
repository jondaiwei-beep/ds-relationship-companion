#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '../../..');
const sourcePath = path.join(root, 'design/tokens/design-tokens.json');
const outputDir = path.join(root, 'design/qa/reference');
const tokens = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));

function get(pathValue) {
  return pathValue.split('.').reduce((node, key) => node?.[key], tokens);
}

function resolve(value, stack = []) {
  if (typeof value !== 'string') return value;
  const match = value.match(/^\{(.+)\}$/);
  if (!match) return value;
  if (stack.includes(match[1])) throw new Error(`Alias cycle: ${[...stack, match[1]].join(' → ')}`);
  const token = get(match[1]);
  if (!token || token.$value === undefined) throw new Error(`Missing alias: ${match[1]}`);
  return resolve(token.$value, [...stack, match[1]]);
}

function value(pathValue) {
  const token = get(pathValue);
  if (!token || token.$value === undefined) throw new Error(`Missing token: ${pathValue}`);
  return resolve(token.$value);
}

function luminance(hex) {
  const channels = hex.slice(1, 7).match(/../g).map((part) => parseInt(part, 16) / 255)
    .map((channel) => channel <= 0.03928 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4);
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function contrast(foreground, background) {
  const a = luminance(foreground);
  const b = luminance(background);
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

function escapeXml(text) {
  return String(text).replace(/[<>&'\"]/g, (character) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[character]);
}

function text(x, y, content, size, fill, weight = 400, tracking = 0, anchor = 'start') {
  return `<text x="${x}" y="${y}" fill="${fill}" font-family="Inter, Arial, sans-serif" font-size="${size}" font-weight="${weight}" letter-spacing="${tracking}" text-anchor="${anchor}">${escapeXml(content)}</text>`;
}

function rect(x, y, width, height, fill, radius = 0, stroke = 'none', strokeWidth = 0) {
  return `<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}" fill="${fill}" stroke="${stroke}" stroke-width="${strokeWidth}"/>`;
}

function semantic(pathValue) {
  return value(`color.semantic.${pathValue}`);
}

function buildBoard() {
  const width = 1600;
  const height = 1390;
  const bone = value('color.primitive.bone');
  const stone = value('color.primitive.stone');
  const warmGray = value('color.primitive.warmGray');
  const deepOlive = value('color.primitive.deepOlive');
  const darkMoss = value('color.primitive.darkMoss');
  const terracotta = value('color.primitive.terracotta');
  const ritualBlack = value('color.primitive.ritualBlack');
  const oliveMist = value('color.primitive.oliveMist');
  const parts = [rect(0, 0, width, height, bone)];

  parts.push(text(48, 58, 'TOKEN FREEZE · B-2 · V1', 31, darkMoss, 650, 4));
  parts.push(text(48, 98, 'V5 Warm Authority · semantic color, surface, geometry and control contract', 17, deepOlive, 400));
  parts.push(text(1552, 58, '#080B07', 18, deepOlive, 600, 1, 'end'));
  parts.push(text(1552, 90, 'RITUAL CANVAS', 11, oliveMist, 600, 2.5, 'end'));

  parts.push(rect(40, 135, 970, 515, ritualBlack, 16));
  parts.push(text(72, 180, 'RITUAL STRUCTURE', 14, warmGray, 600, 3));
  parts.push(text(72, 225, 'Near-black is the canvas. Moss raises. Olive commands.', 24, bone, 500));
  const darkSwatches = [
    ['canvas.ritual', ritualBlack], ['surface.raised', darkMoss], ['surface.action', deepOlive], ['relationship', terracotta],
  ];
  darkSwatches.forEach(([label, color], index) => {
    const x = 72 + index * 220;
    parts.push(rect(x, 260, 190, 86, color, 10, index === 0 ? deepOlive : color, 1));
    parts.push(text(x, 374, label, 13, stone, 550));
    parts.push(text(x, 398, color, 12, warmGray, 400, 0.8));
  });
  const ritualPairs = [
    ['Primary / Bone', bone], ['Secondary / Stone', stone], ['Muted / Warm Gray', warmGray], ['Relationship / Terracotta', terracotta],
  ];
  ritualPairs.forEach(([label, color], index) => {
    const y = 442 + index * 42;
    const ratio = contrast(color, ritualBlack);
    parts.push(text(72, y, label, 15, color, 500));
    parts.push(text(610, y, `${ratio.toFixed(2)}:1`, 14, color, 600));
    parts.push(text(720, y, index === 3 ? 'LARGE / MARK ONLY' : 'AA NORMAL TEXT', 11, index === 3 ? terracotta : warmGray, 600, 1.2));
  });
  parts.push(rect(700, 570, 260, 56, deepOlive, 10));
  parts.push(text(830, 606, 'Primary action · 56', 15, bone, 600, 0.2, 'middle'));

  parts.push(rect(1030, 135, 530, 515, stone, 16));
  parts.push(text(1062, 180, 'LIVING LAYER', 14, oliveMist, 650, 3));
  parts.push(text(1062, 225, 'Warm, legible, never sterile.', 25, darkMoss, 550));
  const lightSwatches = [['canvas', bone], ['raised', stone], ['muted text', oliveMist]];
  lightSwatches.forEach(([label, color], index) => {
    const y = 270 + index * 96;
    parts.push(rect(1062, y, 112, 68, color, 10, deepOlive, 1));
    parts.push(text(1194, y + 28, label, 14, darkMoss, 600));
    parts.push(text(1194, y + 52, color, 12, deepOlive, 400));
  });
  parts.push(text(1062, 574, 'Primary text', 18, darkMoss, 600));
  parts.push(text(1062, 606, 'Muted copy remains 4.74:1', 15, oliveMist, 450));

  parts.push(text(48, 706, 'CONTROL GEOMETRY', 14, deepOlive, 650, 3));
  parts.push(text(48, 742, '48 is touch safety. 56 is standard. 64 is ritual.', 22, darkMoss, 550));
  const controlRows = [
    ['Icon / target', 48], ['Standard button', 56], ['Ritual CTA', 64], ['Selection row', 64], ['List row', 72], ['Bottom navigation', 80],
  ];
  controlRows.forEach(([label, size], index) => {
    const x = 48 + index * 250;
    const h = size * 1.3;
    parts.push(rect(x, 800, 210, h, index === 2 ? deepOlive : darkMoss, size === 48 ? 999 : 10, index === 2 ? deepOlive : warmGray, 1));
    parts.push(text(x + 105, 800 + h / 2 + 5, `${size}dp`, 14, bone, 650, 0, 'middle'));
    parts.push(text(x, 918, label, 13, deepOlive, 550));
  });
  parts.push(text(48, 968, 'RADIUS', 12, oliveMist, 650, 2));
  const radii = [['4', 4], ['8', 8], ['control 10', 10], ['card 12', 12], ['sheet 16', 16], ['capsule', 999]];
  radii.forEach(([label, radius], index) => {
    const x = 48 + index * 160;
    parts.push(rect(x, 990, 126, 74, stone, radius, deepOlive, 1));
    parts.push(text(x + 63, 1035, label, 13, darkMoss, 550, 0, 'middle'));
  });
  parts.push(text(1060, 968, 'BORDER', 12, oliveMist, 650, 2));
  [['hairline', 1], ['selected', 1.5], ['focus', 2]].forEach(([label, border], index) => {
    const x = 1060 + index * 160;
    parts.push(rect(x, 990, 126, 74, index === 2 ? ritualBlack : stone, 10, index === 2 ? bone : deepOlive, border));
    parts.push(text(x + 63, 1084, `${label} ${border}`, 12, deepOlive, 550, 0, 'middle'));
  });

  parts.push(rect(40, 1130, 1520, 210, ritualBlack, 16));
  parts.push(text(72, 1174, 'STATE SEMANTICS', 14, warmGray, 650, 3));
  const states = [
    ['COMPLETED', bone], ['WAITING', warmGray], ['PARTNER ACTIVE', terracotta], ['NEEDS REVIEW', stone], ['PAUSED', warmGray], ['FINAL DESTRUCTIVE', terracotta],
  ];
  states.forEach(([label, color], index) => {
    const x = 72 + index * 240;
    parts.push(`<circle cx="${x + 10}" cy="1238" r="8" fill="${color}"/>`);
    parts.push(text(x + 30, 1243, label, 12, index === 2 || index === 5 ? stone : color, 650, 1));
    parts.push(text(x, 1285, index === 2 ? 'human presence' : index === 5 ? 'outline only' : 'icon + label', 12, warmGray, 400));
  });
  parts.push(text(72, 1320, 'No state relies on color alone. Terracotta is relational, not generic warning red.', 13, warmGray, 450));
  parts.push(text(1552, 1370, 'TOKEN-FREEZE-B2-V1 · 2026-08-29', 11, oliveMist, 600, 1.2, 'end'));

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">${parts.join('')}</svg>`;
}

async function main() {
  if (tokens.meta.status !== 'frozen' || tokens.meta.freezeId !== 'TOKEN-FREEZE-B2-V1') {
    throw new Error('Token metadata is not frozen as TOKEN-FREEZE-B2-V1');
  }
  const required = [
    'color.semantic.canvas.ritual', 'color.semantic.surface.ritual.raised',
    'color.semantic.surface.ritual.action', 'color.semantic.text.onRitual.primary',
    'color.semantic.text.onLiving.muted', 'color.semantic.state.completed',
    'radius.control', 'radius.card', 'radius.sheet', 'borderWidth.hairline',
    'size.touchTarget', 'size.control.button', 'size.control.buttonRitual',
  ];
  required.forEach(value);
  const pairs = [
    ['text.onRitual.primary', 'canvas.ritual', 4.5],
    ['text.onRitual.secondary', 'canvas.ritual', 4.5],
    ['text.onRitual.muted', 'canvas.ritual', 4.5],
    ['action.primary.foreground', 'action.primary.background', 4.5],
    ['text.onLiving.primary', 'canvas.living', 4.5],
    ['text.onLiving.muted', 'canvas.living', 4.5],
  ].map(([foreground, background, threshold]) => {
    const ratio = contrast(semantic(foreground), semantic(background));
    return { foreground: `color.semantic.${foreground}`, background: `color.semantic.${background}`, ratio: Number(ratio.toFixed(2)), threshold, status: ratio >= threshold ? 'pass' : 'fail' };
  });
  if (pairs.some((pair) => pair.status === 'fail')) throw new Error('Required text contrast failed');
  if (value('size.touchTarget').value < 48 || value('size.control.iconButton').value < 48) throw new Error('Touch target below 48dp');
  if (value('size.control.buttonRitual').value <= value('size.control.button').value) throw new Error('Ritual CTA must remain taller than standard CTA');

  const bindingPaths = [
    'design/tokens/generated/ds_design_tokens.dart',
    'design/tokens/generated/ds-design-tokens.css',
  ];
  for (const bindingPath of bindingPaths) {
    const content = fs.readFileSync(path.join(root, bindingPath), 'utf8');
    if (!content.includes(tokens.meta.freezeId)) throw new Error(`${bindingPath}: stale generated binding`);
  }
  fs.mkdirSync(outputDir, { recursive: true });
  const boardPath = path.join(outputDir, 'token-freeze-b2-v1-board.png');
  await sharp(Buffer.from(buildBoard()), { density: 180 }).png().toFile(boardPath);
  const relationshipContrast = contrast(semantic('text.onRitual.relationshipLarge'), semantic('canvas.ritual'));
  const report = {
    freeze_id: tokens.meta.freezeId,
    generated_at: new Date().toISOString(),
    result: 'pass',
    source: path.relative(root, sourcePath),
    required_contrast_pairs: pairs,
    restricted_pair: {
      foreground: 'color.semantic.text.onRitual.relationshipLarge',
      background: 'color.semantic.canvas.ritual',
      ratio: Number(relationshipContrast.toFixed(2)),
      status: 'restricted',
      rule: 'large text >=24sp regular or >=19sp bold, icon, line or mark only; not normal body text',
    },
    geometry_checks: {
      touch_target_dp: value('size.touchTarget').value,
      standard_button_dp: value('size.control.button').value,
      ritual_button_dp: value('size.control.buttonRitual').value,
      control_radius_dp: value('radius.control').value,
      card_radius_dp: value('radius.card').value,
      sheet_radius_dp: value('radius.sheet').value,
    },
    generated_bindings: bindingPaths,
    qa_board: path.relative(root, boardPath),
  };
  fs.writeFileSync(path.join(outputDir, 'token-freeze-b2-v1-validation.json'), `${JSON.stringify(report, null, 2)}\n`);
  process.stdout.write(`Token Freeze B-2 PASS · ${pairs.length} required contrast pairs\n${boardPath}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
