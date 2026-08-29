#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const registry = JSON.parse(fs.readFileSync(path.join(root, 'manifests/assets.json'), 'utf8'));
const svgFreeze = JSON.parse(fs.readFileSync(path.join(root, 'manifests/svg-freeze.v1.json'), 'utf8'));
const frozenById = new Map(svgFreeze.assets.map((asset) => [asset.id, asset]));

function camel(value) {
  return value.replace(/[-_.]+(.)?/g, (_, character) => character ? character.toUpperCase() : '');
}

function copy(source, destination) {
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.copyFileSync(source, destination);
}

const svgAssets = registry.assets.filter((asset) => asset.kind !== 'texture');
for (const asset of svgAssets) {
  copy(
    path.join(root, asset.source_path),
    path.join(root, 'app/assets/svg', path.basename(asset.source_path)),
  );
}

const fontFamilies = ['inter', 'cormorant-garamond'];
for (const family of fontFamilies) {
  const sourceDir = path.join(root, 'design/assets/fonts', family);
  for (const filename of fs.readdirSync(sourceDir)) {
    if (!/\.(?:ttf|otf)$/i.test(filename)) continue;
    copy(path.join(sourceDir, filename), path.join(root, 'app/assets/fonts', family, filename));
  }
}

copy(
  path.join(root, 'design/assets/textures/ritual-grain-128.png'),
  path.join(root, 'app/assets/textures/ritual-grain-128.png'),
);

const toneNames = ['primary', 'muted', 'authority', 'relationship', 'decorative'];
// Assets live inside this package, so every path needs the package prefix.
// A bare 'assets/...' path resolves against the HOST application, which 404s
// in any app that depends on the design system — the same failure mode as an
// unqualified font family.
const PKG = 'packages/ds_relationship_companion';

const constants = [];
for (const asset of svgAssets) {
  const frozen = frozenById.get(asset.id);
  if (!frozen) throw new Error(`${asset.id}: missing SVG freeze entry`);
  const tones = frozen.colors.map((tone) => `DsAssetTone.${tone}`).join(', ');
  constants.push(
    `  static const ${camel(asset.id)} = DsAssetId._(\n` +
    `    '${asset.id}',\n` +
    `    '${PKG}/assets/svg/${path.basename(asset.source_path)}',\n` +
    `    {${tones}},\n` +
    `  );`,
  );
}

const allNames = svgAssets.map((asset) => `    ${camel(asset.id)},`).join('\n');
const dart = `// GENERATED FROM manifests/assets.json AND manifests/svg-freeze.v1.json.\n` +
`// DO NOT EDIT BY HAND.\n\n` +
`enum DsAssetTone { ${toneNames.join(', ')} }\n\n` +
`final class DsAssetId {\n` +
`  const DsAssetId._(this.id, this.path, this.allowedTones);\n\n` +
`  final String id;\n` +
`  final String path;\n` +
`  final Set<DsAssetTone> allowedTones;\n` +
`}\n\n` +
`abstract final class DsAssets {\n` +
`${constants.join('\n\n')}\n\n` +
`  static const all = <DsAssetId>[\n${allNames}\n  ];\n\n` +
`  static DsAssetId byId(String id) =>\n` +
`      all.singleWhere((asset) => asset.id == id);\n` +
`}\n\n` +
`abstract final class DsTextureAssets {\n` +
`  static const ritualGrain =\n      '${PKG}/assets/textures/ritual-grain-128.png';\n` +
`}\n`;

const output = path.join(root, 'app/lib/src/design_system/ds_assets.dart');
fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, dart);
process.stdout.write(`Synced ${svgAssets.length} SVGs, 7 fonts, 1 texture and generated the semantic Dart registry.\n`);
