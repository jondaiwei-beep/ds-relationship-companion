// Makes the repository's bundled fonts visible to sharp's text rendering.
//
// Must be required BEFORE `sharp`, because fontconfig reads its configuration
// once at load.
//
// The renderers used to write a fontconfig file to `os.tmpdir()` and point
// `FONTCONFIG_FILE` at it. On macOS that silently stopped working: sharp
// bundles its own fontconfig, which does not honour `FONTCONFIG_FILE`, so
// every family fell back to a system sans. Nothing failed — the renders just
// came out in the wrong typeface, and `render-today-b3.cjs` stopped
// reproducing its own committed output without anyone noticing.
//
// So this installs the bundled faces into the user font directory, which
// fontconfig scans on every platform this runs on, and then verifies that the
// display face actually resolves. A renderer that cannot prove its own
// typeface must stop, not produce a plausible picture in the wrong font.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.resolve(__dirname, '../../..');
const families = ['inter', 'cormorant-garamond'];

function userFontDir() {
  if (process.platform === 'darwin') return path.join(os.homedir(), 'Library/Fonts');
  if (process.platform === 'win32') return path.join(os.homedir(), 'AppData/Local/Microsoft/Windows/Fonts');
  return path.join(os.homedir(), '.local/share/fonts');
}

function install() {
  const target = userFontDir();
  fs.mkdirSync(target, { recursive: true });
  let copied = 0;
  for (const family of families) {
    const dir = path.join(root, 'design/assets/fonts', family);
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith('.ttf')) continue;
      const to = path.join(target, file);
      const from = path.join(dir, file);
      // Only when missing or stale, so a render does not rewrite the user's
      // font directory on every run.
      if (!fs.existsSync(to) || fs.statSync(to).mtimeMs < fs.statSync(from).mtimeMs) {
        fs.copyFileSync(from, to);
        copied += 1;
      }
    }
  }
  if (copied > 0) {
    try {
      execFileSync('fc-cache', ['-f', target], { stdio: 'ignore' });
    } catch {
      // fc-cache is a convenience; fontconfig rescans the directory anyway.
    }
  }
  return copied;
}

/// Renders one glyph and fails if the display face did not take.
///
/// Cormorant and Inter differ enough at 40px that a substituted sans is
/// obvious in the pixel count. Cheap, and it is the only thing standing
/// between a silent fallback and a committed render in the wrong typeface.
async function assertDisplayFaceResolves(sharp) {
  const draw = (family) => sharp(Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="300" height="60">` +
    `<rect width="100%" height="100%" fill="#000"/>` +
    `<text x="6" y="44" fill="#fff" font-family="${family}" font-size="40" font-weight="500">Handgloves</text>` +
    `</svg>`,
  )).raw().toBuffer();

  const [serif, sans] = await Promise.all([
    draw('Cormorant Garamond'),
    draw('Helvetica'),
  ]);
  if (Buffer.compare(serif, sans) === 0) {
    throw new Error(
      'Cormorant Garamond did not resolve — sharp is substituting a system ' +
      'font. Renders would be produced in the wrong typeface. Check that ' +
      `${userFontDir()} contains CormorantGaramond-*.ttf.`,
    );
  }
}

module.exports = { install, assertDisplayFaceResolves, userFontDir };
