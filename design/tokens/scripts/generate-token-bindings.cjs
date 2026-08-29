#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../../..');
const sourcePath = path.join(root, 'design/tokens/design-tokens.json');
const outputDir = path.join(root, 'design/tokens/generated');
const appOutputPath = path.join(root, 'app/lib/src/design_system/generated/ds_design_tokens.g.dart');
const tokens = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));

function get(pathValue) {
  return pathValue.split('.').reduce((node, key) => node?.[key], tokens);
}

function resolve(value, stack = []) {
  if (typeof value === 'string') {
    const match = value.match(/^\{(.+)\}$/);
    if (!match) return value;
    if (stack.includes(match[1])) throw new Error(`Alias cycle: ${[...stack, match[1]].join(' → ')}`);
    const token = get(match[1]);
    if (!token || token.$value === undefined) throw new Error(`Missing alias: ${match[1]}`);
    return resolve(token.$value, [...stack, match[1]]);
  }
  return value;
}

function flatten(node, prefix = [], result = []) {
  for (const [key, value] of Object.entries(node)) {
    if (key.startsWith('$')) continue;
    const next = [...prefix, key];
    if (value && typeof value === 'object' && '$value' in value) {
      result.push({ path: next.join('.'), type: value.$type, value: resolve(value.$value) });
    } else if (value && typeof value === 'object') {
      flatten(value, next, result);
    }
  }
  return result;
}

function camel(value) {
  return value.replace(/[-_.]+(.)?/g, (_, character) => character ? character.toUpperCase() : '');
}

function kebab(value) {
  return value.replace(/([a-z0-9])([A-Z])/g, '$1-$2').replace(/[._]/g, '-').toLowerCase();
}

function dartColor(hex) {
  const raw = hex.slice(1);
  if (raw.length === 6) return `Color(0xFF${raw.toUpperCase()})`;
  if (raw.length === 8) return `Color(0x${raw.slice(6).toUpperCase()}${raw.slice(0, 6).toUpperCase()})`;
  throw new Error(`Unsupported color: ${hex}`);
}

function dartClass(name, entries, valueFormatter, nameFormatter = (entry) => camel(entry.path.split('.').slice(2).join('.'))) {
  const body = entries.map((entry) => `  static const ${nameFormatter(entry)} = ${valueFormatter(entry.value)};`).join('\n');
  return `abstract final class ${name} {\n${body}\n}`;
}

const flat = flatten(tokens);
const primitive = flat.filter((entry) => entry.path.startsWith('color.primitive.'));
const semantic = flat.filter((entry) => entry.path.startsWith('color.semantic.'));
const radii = flat.filter((entry) => entry.path.startsWith('radius.'));
const borders = flat.filter((entry) => entry.path.startsWith('borderWidth.'));
const controls = flat.filter((entry) => entry.path.startsWith('size.control.'));
const layout = flat.filter((entry) => entry.path.startsWith('size.layout.') || entry.path === 'size.touchTarget');
const opacity = flat.filter((entry) => entry.path.startsWith('opacity.'));
const spaces = flat.filter((entry) => entry.path.startsWith('space.'));
const shadows = flat.filter((entry) => entry.path.startsWith('shadow.'));

function dartShadow(value) {
  return [
    'BoxShadow(',
    `      color: ${dartColor(value.color)},`,
    `      offset: Offset(${value.offsetX.value}.0, ${value.offsetY.value}.0),`,
    `      blurRadius: ${value.blur.value}.0,`,
    `      spreadRadius: ${value.spread.value}.0)`,
  ].join('\n');
}

const dart = `// GENERATED FROM design/tokens/design-tokens.json. DO NOT EDIT BY HAND.\n` +
`// Freeze: ${tokens.meta.freezeId} · ${tokens.meta.version}\n\n` +
`import 'package:flutter/material.dart';\n\n` +
`${dartClass('DsPrimitiveColors', primitive, dartColor)}\n\n` +
`${dartClass('DsColors', semantic, dartColor)}\n\n` +
`${dartClass('DsRadii', radii, (value) => `${value.value}.0`, (entry) => camel(entry.path.split('.').slice(1).join('.')))}\n\n` +
`${dartClass('DsBorderWidths', borders, (value) => `${value.value}`, (entry) => camel(entry.path.split('.').slice(1).join('.')))}\n\n` +
`${dartClass('DsControlSizes', controls, (value) => `${value.value}.0`)}\n\n` +
`${dartClass('DsLayoutSizes', layout, (value) => `${value.value}.0`, (entry) => camel(entry.path.replace(/^size\.(layout\.)?/, '')))}\n\n` +
`${dartClass('DsOpacity', opacity, (value) => `${value}`, (entry) => camel(entry.path.split('.').slice(1).join('.')))}\n\n` +
`${dartClass('DsSpacing', spaces, (value) => `${value.value}.0`, (entry) => `space${entry.path.split('.')[1]}`)}\n\n` +
`${dartClass('DsShadows', shadows, dartShadow, (entry) => camel(entry.path.split('.').slice(1).join('.')))}\n`;

const appDart = dart;

const cssEntries = flat.filter((entry) =>
  entry.path.startsWith('color.') ||
  entry.path.startsWith('space.') ||
  entry.path.startsWith('radius.') ||
  entry.path.startsWith('borderWidth.') ||
  entry.path.startsWith('size.') ||
  entry.path.startsWith('opacity.') ||
  entry.path.startsWith('shadow.')
);
const cssValue = (entry) => {
  if (entry.type === 'dimension') return `${entry.value.value}${entry.value.unit === 'dp' ? 'px' : entry.value.unit}`;
  if (entry.type === 'shadow') {
    const value = entry.value;
    return `${value.offsetX.value}px ${value.offsetY.value}px ${value.blur.value}px ${value.spread.value}px ${value.color}`;
  }
  return `${entry.value}`;
};
const css = `/* GENERATED FROM design/tokens/design-tokens.json. DO NOT EDIT BY HAND. */\n` +
`/* Freeze: ${tokens.meta.freezeId} · ${tokens.meta.version} */\n\n:root {\n` +
cssEntries.map((entry) => `  --ds-${kebab(entry.path)}: ${cssValue(entry)};`).join('\n') +
`\n}\n`;

fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(path.join(outputDir, 'ds_design_tokens.dart'), dart);
fs.writeFileSync(path.join(outputDir, 'ds-design-tokens.css'), css);
fs.mkdirSync(path.dirname(appOutputPath), { recursive: true });
fs.writeFileSync(appOutputPath, appDart);
process.stdout.write(`Generated ${primitive.length + semantic.length} colors, ${spaces.length} spacing, ${radii.length + borders.length + controls.length + layout.length + opacity.length} geometry/opacity and ${shadows.length} shadow tokens.\n`);
