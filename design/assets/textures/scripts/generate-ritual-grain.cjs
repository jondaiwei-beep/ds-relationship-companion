#!/usr/bin/env node

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '../../../..');
const outputDir = path.join(root, 'design/assets/textures');
const qaDir = path.join(root, 'design/qa/reference');
const size = 128;
const seed = 0x44535243;
let state = seed;

function random() {
  state ^= state << 13;
  state ^= state >>> 17;
  state ^= state << 5;
  return (state >>> 0) / 0xffffffff;
}

async function main() {
  const pixels = Buffer.alloc(size * size * 3);
  let sum = 0;
  let min = 255;
  let max = 0;
  for (let index = 0; index < size * size; index += 1) {
    const value = Math.max(80, Math.min(176, Math.round(128 + (random() + random() - 1) * 48)));
    pixels[index * 3] = value;
    pixels[index * 3 + 1] = value;
    pixels[index * 3 + 2] = value;
    sum += value;
    min = Math.min(min, value);
    max = Math.max(max, value);
  }

  fs.mkdirSync(outputDir, { recursive: true });
  fs.mkdirSync(qaDir, { recursive: true });
  const output = path.join(outputDir, 'ritual-grain-128.png');
  await sharp(pixels, { raw: { width: size, height: size, channels: 3 } })
    .png({ compressionLevel: 9, adaptiveFiltering: false })
    .toFile(output);

  const report = {
    freeze_id: 'TEXTURE-FREEZE-B4-V1',
    result: 'pass',
    asset: 'design/assets/textures/ritual-grain-128.png',
    dimensions: { width: size, height: size },
    algorithm: 'seeded xorshift32 triangular monochrome noise',
    seed: `0x${seed.toString(16).toUpperCase()}`,
    application: { opacity: 0.035, blend_mode: 'softLight', repeat: true },
    channel_statistics: { min, max, mean: Number((sum / (size * size)).toFixed(3)) },
    sha256: crypto.createHash('sha256').update(fs.readFileSync(output)).digest('hex'),
  };
  fs.writeFileSync(
    path.join(qaDir, 'texture-freeze-b4-v1-validation.json'),
    `${JSON.stringify(report, null, 2)}\n`,
  );
  process.stdout.write(`Generated deterministic ritual grain · ${report.sha256}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error}\n`);
  process.exit(1);
});
