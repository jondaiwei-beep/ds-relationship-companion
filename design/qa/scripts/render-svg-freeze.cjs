#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '../../..');
const manifestPath = path.join(root, 'manifests/svg-freeze.v1.json');
const registryPath = path.join(root, 'manifests/assets.json');
const outputDir = path.join(root, 'design/qa/reference');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const registry = JSON.parse(fs.readFileSync(registryPath, 'utf8'));
const registryById = new Map(registry.assets.map((asset) => [asset.id, asset]));

const palette = {
  bone: '#F4F1EB',
  stone: '#E7E3DA',
  warmGray: '#BAB6AC',
  deepOlive: '#2F3A2E',
  darkMoss: '#1E241F',
  terracotta: '#B5533B',
};

const relationshipIds = new Set([
  'mark.presence',
  'mark.partner-bond',
  'state.acknowledged',
  'state.invite-accepted',
  'response.acknowledge',
  'response.praise',
  'response.comment',
  'response.review',
]);

function escapeXml(value) {
  return value.replace(/[<>&'\"]/g, (character) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[character]);
}

function textSvg(text, width, height, options = {}) {
  const {
    x = 0,
    y = 0,
    size = 16,
    color = palette.bone,
    weight = 400,
    anchor = 'start',
    tracking = 0,
  } = options;
  return Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">` +
    `<text x="${x}" y="${y}" text-anchor="${anchor}" fill="${color}" ` +
    `font-family="Inter, Arial, sans-serif" font-size="${size}" font-weight="${weight}" ` +
    `letter-spacing="${tracking}">${escapeXml(text)}</text></svg>`,
  );
}

function validateSvg(asset, source) {
  const failures = [];
  if (!/<svg\b/i.test(source)) failures.push('missing svg root');
  if (!/viewBox="[^"]+"/i.test(source)) failures.push('missing viewBox');
  if (!/currentColor/.test(source)) failures.push('missing currentColor');
  if (/<text\b/i.test(source)) failures.push('embedded text');
  if (/<image\b/i.test(source)) failures.push('embedded raster image');
  if (/<filter\b/i.test(source)) failures.push('filter');
  if (/\b(?:href|xlink:href)=/i.test(source)) failures.push('external reference');
  if (/#[0-9a-f]{3,8}\b/i.test(source)) failures.push('hard-coded hex color');
  if (/\b(?:rgb|hsl)a?\(/i.test(source)) failures.push('hard-coded functional color');
  return failures;
}

async function renderAsset(asset, width, height, color) {
  const registered = registryById.get(asset.id);
  if (!registered) throw new Error(`${asset.id}: missing asset registry entry`);
  const sourcePath = path.join(root, registered.source_path);
  if (!fs.existsSync(sourcePath)) throw new Error(`${asset.id}: source does not exist`);
  const source = fs.readFileSync(sourcePath, 'utf8');
  const failures = validateSvg(asset, source);
  if (failures.length) throw new Error(`${asset.id}: ${failures.join(', ')}`);
  const colored = source.replaceAll('currentColor', color);
  const buffer = await sharp(Buffer.from(colored), { density: 240 })
    .resize(width, height, {
      fit: 'contain',
      withoutEnlargement: false,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer();
  return { buffer, sourcePath };
}

async function renderOverview() {
  const width = 1600;
  const height = 1560;
  const columns = 5;
  const cardWidth = 288;
  const cardHeight = 174;
  const gap = 18;
  const left = 44;
  const top = 190;
  const composites = [
    { input: textSvg('SVG FREEZE · V1', width, 64, { x: 44, y: 44, size: 32, color: palette.darkMoss, weight: 600, tracking: 4 }), left: 0, top: 0 },
    { input: textSvg('33 native vector masters · V5 Warm Authority', width, 48, { x: 44, y: 32, size: 18, color: palette.deepOlive, tracking: 0.5 }), left: 0, top: 68 },
    { input: textSvg('Bone / Stone / Deep Olive / Dark Moss / Terracotta · currentColor contract', width, 48, { x: 44, y: 30, size: 14, color: palette.deepOlive }), left: 0, top: 116 },
  ];

  for (let index = 0; index < manifest.assets.length; index += 1) {
    const asset = manifest.assets[index];
    const column = index % columns;
    const row = Math.floor(index / columns);
    const x = left + column * (cardWidth + gap);
    const y = top + row * (cardHeight + gap);
    const isBotanical = asset.id.startsWith('motif.botanical');
    const color = relationshipIds.has(asset.id)
      ? palette.terracotta
      : isBotanical ? palette.warmGray : palette.bone;
    const iconWidth = isBotanical ? 92 : 84;
    const iconHeight = isBotanical ? 104 : 84;
    const { buffer } = await renderAsset(asset, iconWidth, iconHeight, color);
    const label = asset.id;
    const geometry = `${asset.view_box}  ·  ${asset.sizes_dp.join('/')} dp`;
    composites.push({
      input: Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${cardWidth}" height="${cardHeight}"><rect width="100%" height="100%" rx="14" fill="${palette.darkMoss}"/><rect x="1" y="1" width="${cardWidth - 2}" height="${cardHeight - 2}" rx="13" fill="none" stroke="${palette.deepOlive}"/></svg>`),
      left: x,
      top: y,
    });
    composites.push({ input: buffer, left: x + Math.round((cardWidth - iconWidth) / 2), top: y + 16 });
    composites.push({ input: textSvg(label, cardWidth - 24, 26, { x: 0, y: 18, size: 13, color: palette.stone, weight: 500 }), left: x + 12, top: y + 118 });
    composites.push({ input: textSvg(geometry, cardWidth - 24, 20, { x: 0, y: 14, size: 10, color: palette.warmGray }), left: x + 12, top: y + 145 });
  }

  const boardPath = path.join(outputDir, 'svg-freeze-v1-board.png');
  await sharp({ create: { width, height, channels: 4, background: palette.bone } })
    .composite(composites)
    .png()
    .toFile(boardPath);
  return boardPath;
}

async function renderBotanicalBoard() {
  const width = 1600;
  const height = 900;
  const botanical = manifest.assets.filter((asset) => asset.id.startsWith('motif.botanical'));
  const composites = [
    { input: textSvg('BOTANICAL LAYER · DETAIL QA', width, 64, { x: 48, y: 44, size: 29, color: palette.bone, weight: 600, tracking: 4 }), left: 0, top: 0 },
    { input: textSvg('Decorative only · low contrast · never carries state or interaction meaning', width, 42, { x: 48, y: 30, size: 16, color: palette.warmGray }), left: 0, top: 66 },
  ];
  const cardWidth = 470;
  const cardHeight = 680;
  const gap = 46;
  for (let index = 0; index < botanical.length; index += 1) {
    const asset = botanical[index];
    const x = 48 + index * (cardWidth + gap);
    const y = 150;
    const { buffer } = await renderAsset(asset, 300, 510, palette.warmGray);
    composites.push({
      input: Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${cardWidth}" height="${cardHeight}"><rect width="100%" height="100%" rx="20" fill="${palette.darkMoss}" stroke="${palette.deepOlive}" stroke-width="2"/></svg>`),
      left: x,
      top: y,
    });
    composites.push({ input: buffer, left: x + 85, top: y + 45 });
    composites.push({ input: textSvg(asset.id, cardWidth - 48, 30, { x: 0, y: 22, size: 15, color: palette.stone, weight: 500 }), left: x + 24, top: y + 582 });
    composites.push({ input: textSvg(`opacity ${asset.opacity_range.join('–')} · ${asset.view_box}`, cardWidth - 48, 26, { x: 0, y: 18, size: 12, color: palette.warmGray }), left: x + 24, top: y + 622 });
  }
  const boardPath = path.join(outputDir, 'svg-freeze-v1-botanical-board.png');
  await sharp({ create: { width, height, channels: 4, background: palette.darkMoss } })
    .composite(composites)
    .png()
    .toFile(boardPath);
  return boardPath;
}

async function main() {
  fs.mkdirSync(outputDir, { recursive: true });
  const seen = new Set();
  const results = [];
  for (const asset of manifest.assets) {
    if (seen.has(asset.id)) throw new Error(`${asset.id}: duplicate ID`);
    seen.add(asset.id);
    const { sourcePath } = await renderAsset(asset, 256, 256, palette.bone);
    results.push({ id: asset.id, source_path: path.relative(root, sourcePath), status: 'pass' });
  }
  const orphanRegistryAssets = registry.assets.filter((asset) => !seen.has(asset.id));
  if (orphanRegistryAssets.length) {
    throw new Error(`freeze manifest missing registry assets: ${orphanRegistryAssets.map((asset) => asset.id).join(', ')}`);
  }
  const board = await renderOverview();
  const botanicalBoard = await renderBotanicalBoard();
  const validation = {
    freeze_id: manifest.freeze_id,
    generated_at: new Date().toISOString(),
    result: 'pass',
    asset_count: results.length,
    checks: ['source exists', 'SVG parses', 'viewBox', 'currentColor', 'no text', 'no raster', 'no filters', 'no external references', 'no hard-coded colors'],
    assets: results,
    boards: [path.relative(root, board), path.relative(root, botanicalBoard)],
  };
  fs.writeFileSync(path.join(outputDir, 'svg-freeze-v1-validation.json'), `${JSON.stringify(validation, null, 2)}\n`);
  process.stdout.write(`SVG Freeze V1 PASS · ${results.length} assets\n${board}\n${botanicalBoard}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
