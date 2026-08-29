#!/usr/bin/env node

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const failures = [];

function hash(file) {
  return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
}

function assert(condition, message) {
  if (!condition) failures.push(message);
}

const registry = JSON.parse(fs.readFileSync(path.join(root, 'manifests/assets.json'), 'utf8'));
const svgAssets = registry.assets.filter((asset) => asset.kind !== 'texture');
assert(svgAssets.length === 33, `expected 33 SVG assets, found ${svgAssets.length}`);

for (const asset of svgAssets) {
  const canonical = path.join(root, asset.source_path);
  const bundled = path.join(root, 'app/assets/svg', path.basename(asset.source_path));
  assert(fs.existsSync(bundled), `${asset.id}: bundled SVG missing`);
  if (fs.existsSync(bundled)) assert(hash(canonical) === hash(bundled), `${asset.id}: bundled SVG drift`);
}

for (const family of ['inter', 'cormorant-garamond']) {
  const canonicalDir = path.join(root, 'design/assets/fonts', family);
  for (const filename of fs.readdirSync(canonicalDir).filter((name) => /\.(?:ttf|otf)$/i.test(name))) {
    const canonical = path.join(canonicalDir, filename);
    const bundled = path.join(root, 'app/assets/fonts', family, filename);
    assert(fs.existsSync(bundled), `${filename}: bundled font missing`);
    if (fs.existsSync(bundled)) assert(hash(canonical) === hash(bundled), `${filename}: bundled font drift`);
  }
}

const canonicalTexture = path.join(root, 'design/assets/textures/ritual-grain-128.png');
const bundledTexture = path.join(root, 'app/assets/textures/ritual-grain-128.png');
assert(fs.existsSync(bundledTexture), 'bundled ritual texture missing');
if (fs.existsSync(bundledTexture)) assert(hash(canonicalTexture) === hash(bundledTexture), 'bundled ritual texture drift');
const textureReport = JSON.parse(fs.readFileSync(path.join(root, 'design/qa/reference/texture-freeze-b4-v1-validation.json'), 'utf8'));
assert(textureReport.sha256 === hash(canonicalTexture), 'B-4 texture hash differs from validation report');
assert(textureReport.application.opacity === 0.035, 'B-4 texture opacity drift');
assert(textureReport.application.blend_mode === 'softLight', 'B-4 texture blend drift');

const assetDart = fs.readFileSync(path.join(root, 'app/lib/src/design_system/ds_assets.dart'), 'utf8');
for (const asset of svgAssets) assert(assetDart.includes(`'${asset.id}'`), `${asset.id}: missing Dart semantic ID`);

const tokenDart = fs.readFileSync(path.join(root, 'app/lib/src/design_system/generated/ds_design_tokens.g.dart'), 'utf8');
const canonicalTokenDart = fs.readFileSync(path.join(root, 'design/tokens/generated/ds_design_tokens.dart'), 'utf8');
assert(tokenDart === canonicalTokenDart, 'app B-2 token binding drift');
for (const name of ['DsColors', 'DsRadii', 'DsControlSizes', 'DsLayoutSizes', 'DsOpacity', 'DsSpacing', 'DsShadows']) {
  assert(tokenDart.includes(`class ${name}`), `${name}: missing generated token class`);
}

function dartFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const target = path.join(directory, entry.name);
    return entry.isDirectory() ? dartFiles(target) : entry.name.endsWith('.dart') ? [target] : [];
  });
}

for (const file of dartFiles(path.join(root, 'app/lib'))) {
  if (file.endsWith('ds_design_tokens.g.dart')) continue;
  const source = fs.readFileSync(file, 'utf8');
  assert(!/Color\(0x[0-9A-Fa-f]+\)/.test(source), `${path.relative(root, file)}: raw color found`);
  assert(!/#[0-9A-Fa-f]{6,8}\b/.test(source), `${path.relative(root, file)}: raw hex found`);
}

if (failures.length) {
  process.stderr.write(`${failures.join('\n')}\n`);
  process.exit(1);
}

process.stdout.write('Design foundation validation passed: 33 SVGs, 7 fonts, B-2 tokens, B-4 texture, no raw app colors.\n');
