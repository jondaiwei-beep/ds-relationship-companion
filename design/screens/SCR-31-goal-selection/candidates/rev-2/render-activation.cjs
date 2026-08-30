#!/usr/bin/env node

// SCR-31 / 07 / 08 / 12 — the activation wizard, state family.
//
//   node design/screens/SCR-31-goal-selection/candidates/rev-2/render-activation.cjs
//
// Four screens, one command. The "1 of 4" in the approved candidates is
// accurate rather than decorative: nothing reaches the server until step
// three's Continue, which fires `POST /v1/dynamics` and then asks for a
// starting rhythm.
//
// That asymmetry is the whole shape of this state family, and it is why
// there are so few states. Steps one and two are pure local choice — no
// loading, no error, no offline, because nothing is being asked of anyone.
// Steps three and four carry the full recovery set, because that is where
// the wizard finally speaks.
//
// Behaviour: product/decisions/activation-state-family.md

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

const outRoot = path.join(root, 'design/screens');
const referenceRoot = path.join(root, 'design/qa/reference');

const W = 390;
const H = 844;
const SCALE = 3;
const M = 24;

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

const C = {
  canvas: token('color.semantic.canvas.ritual'),
  raised: token('color.semantic.surface.ritual.raised'),
  primary: token('color.semantic.text.onRitual.primary'),
  secondary: token('color.semantic.text.onRitual.secondary'),
  muted: token('color.semantic.text.onRitual.muted'),
  line: token('color.semantic.border.onRitual.hairline'),
  actionBg: token('color.semantic.action.primary.background'),
  actionFg: token('color.semantic.action.primary.foreground'),
  disabledBg: token('color.semantic.action.primary.disabledBackground'),
  disabledFg: token('color.semantic.action.primary.disabledForeground'),
  error: token('color.semantic.state.error'),
  terra: token('color.semantic.text.onRitual.relationshipLarge'),
};

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  relationship: 'color.semantic.icon.relationship',
  authority: 'color.semantic.icon.authority',
  decorative: 'color.semantic.decorative.botanical',
};

function esc(v) {
  return String(v).replace(/[<>&'"]/g, (c) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[c]);
}

function text(x, y, s, size, fill, o = {}) {
  const { family = 'Inter', weight = 400, tracking = 0, anchor = 'start', opacity = 1 } = o;
  return `<text x="${x}" y="${y}" fill="${fill}" fill-opacity="${opacity}" font-family="${family}" font-size="${size}" font-weight="${weight}" letter-spacing="${tracking}" text-anchor="${anchor}">${esc(s)}</text>`;
}

function rect(x, y, w, h, fill, r = 0, stroke = 'none', sw = 1, opacity = 1) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" fill-opacity="${opacity}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

function circle(cx, cy, r, fill = 'none', stroke = 'none', sw = 1) {
  return `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

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
  const src = fs.readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', token(toneToken[tone]));
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${Buffer.from(src).toString('base64')}"/>`;
}

/// Back arrow and "n of 4". The step count is honest: the wizard really is
/// four screens and one command.
function step(n, { back = true } = {}) {
  let b = text(W - M, 44, `${n} of 4`, 11, C.muted, { anchor: 'end', tracking: 0.6 });
  if (back) {
    b += `<path d="M32 44 l-10 -9 l10 -9" stroke="${C.secondary}" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  return b;
}

function eyebrow(y, s) {
  return text(M, y, s, 10, C.muted, { weight: 600, tracking: 1.9 });
}

function heading(y, lines) {
  return lines.map((l, i) => text(M, y + i * 40, l, 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500,
  })).join('');
}

/// The primary action, which stays visually available even when nothing is
/// chosen yet.
///
/// Pressing it then explains what is missing. A silently disabled control is
/// unreachable for a keyboard or screen-reader user and tells a sighted one
/// nothing either — the same reasoning as the 18+ checkbox on SCR-06.
function primary(y, label, o = {}) {
  const { busy = false, unmet = false } = o;
  const off = busy;
  let b = rect(M, y, W - M * 2, 56, off ? C.disabledBg : C.actionBg, 10);
  b += text(W / 2, y + 34, busy ? `${label}…` : label, 16,
    off ? C.disabledFg : C.actionFg, { weight: 600, anchor: 'middle' });
  if (unmet) b += text(W / 2, y + 78, unmet, 12, C.error, { anchor: 'middle' });
  return b;
}

function banner(y, message, { tone = 'muted' } = {}) {
  return rect(M, y, W - M * 2, 44, C.disabledBg, 8) +
    text(W / 2, y + 27, message, 12, tone === 'error' ? C.error : C.secondary,
      { anchor: 'middle' });
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, C.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// SCR-31 · What do you want more of
// ---------------------------------------------------------------------------

/// The five outcomes of REQ-ACT-001, in the order the requirement lists them.
///
/// Not decoration: `StarterRhythmService` picks different starter content per
/// outcome, so this choice is the first thing that changes what the product
/// does. (The server accepted any string and silently fell back to CLOSER
/// until 0853745.)
const GOALS = [
  'Closer', 'Structure', 'Service & devotion', 'Accountability',
  'Explore together',
];

function goals({ chosen = 0, unmet = false } = {}) {
  let b = step(1, { back: false });
  b += asset('mark.authority', W / 2 - 16, 52, 32, 'primary');
  b += eyebrow(96, 'BEGIN WITH INTENTION');
  b += heading(134, ['What would you', 'like more of now?']);
  b += text(M, 214, 'Choose the feeling you want your', 13, C.muted);
  b += text(M, 234, 'dynamic to hold. You can change this later.', 13, C.muted);

  // Decorative only, and the freeze licenses exactly one tone for it.
  b += `<g opacity="0.5">${asset('motif.botanical.goal-branch', 214, 246, 160, 'decorative')}</g>`;

  const top = 288;
  b += rect(M + 12, top, 1, GOALS.length * 60 - 44, C.line);
  GOALS.forEach((label, i) => {
    const y = top + i * 60;
    const on = chosen === i;
    b += circle(M + 12, y + 8, 8, C.canvas, on ? C.terra : C.line, 1.2);
    if (on) b += circle(M + 12, y + 8, 4, C.terra);
    b += text(M + 36, y + 14, label, on ? 20 : 15,
      on ? C.primary : C.secondary,
      on ? { family: 'Cormorant Garamond', weight: 500 } : {});
    if (on) b += rect(M + 36, y + 24, 108, 1, C.terra);
  });

  b += text(M, 636, 'This shapes your starting rhythm—not your limits.', 12, C.muted);
  b += primary(672, 'Continue', {
    unmet: unmet ? 'Choose one to continue.' : false,
  });
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-07 · Who is beginning this
// ---------------------------------------------------------------------------

const ROLES = ['Dominant', 'submissive', 'Switch', 'Custom'];

function roles({ solo = false, role = 1, named = true, unmet = false } = {}) {
  let b = step(2);
  b += eyebrow(96, 'BEGIN TOGETHER');
  b += heading(134, ['Who is beginning', 'this with you?']);
  b += text(M, 214, 'Start privately or open this space with a partner.', 13, C.muted);

  // Two circles, not a switch: choosing to begin alone is a real option, not
  // the off position of something else.
  const cy = 320;
  [[128, 'With a partner', 'mark.partner-bond', !solo],
   [286, 'For myself', 'icon.private-space', solo]].forEach(([cx, label, id, on]) => {
    b += circle(cx, cy, 58, 'none', on ? C.terra : C.line, on ? 1.3 : 1);
    // `mark.partner-bond` licenses only primary and relationship — the freeze
    // refusing to let the bond between two people be a dimmed decoration. So
    // the unselected partner circle stays primary and is distinguished by its
    // ring and label instead of by fading the mark.
    const bond = id === 'mark.partner-bond';
    b += asset(id, cx - 20, cy - 26, bond ? 40 : 28,
      on ? (bond ? 'relationship' : 'primary') : (bond ? 'primary' : 'muted'));
    b += text(cx, cy + 34, label, 12, on ? C.primary : C.muted,
      { anchor: 'middle', weight: on ? 600 : 400 });
    if (on) b += circle(cx, cy - 58, 5, C.terra);
  });
  b += rect(196, cy - 1, 22, 1, C.line);

  b += eyebrow(452, 'YOUR STARTING ROLE');
  const rx = [58, 141, 232, 320];
  ROLES.forEach((label, i) => {
    const on = named && role === i;
    b += circle(rx[i], 492, 9, C.canvas, on ? C.terra : C.line, 1.2);
    if (on) b += circle(rx[i], 492, 4.5, C.terra);
    b += text(rx[i], 524, label, 11, on ? C.primary : C.muted,
      { anchor: 'middle', weight: on ? 600 : 400 });
  });
  b += rect(58, 492, 262, 1, C.line);

  // The escape hatch, and it is not a lesser option. A couple that does not
  // want to name a role must not be blocked — the column is nullable at every
  // layer for the same reason.
  b += rect(M, 552, W - M * 2, 44, named ? C.canvas : C.raised, 8,
    named ? C.line : C.terra, 1);
  b += text(W / 2, 579, "I'd rather not name one", 13,
    named ? C.muted : C.primary, { anchor: 'middle', weight: named ? 400 : 600 });

  b += text(M, 632, 'A starting point, not a limit.', 13, C.secondary);
  b += text(M, 654, 'You can change this later.', 13, C.muted);
  b += primary(690, 'Continue', {
    unmet: unmet ? 'Choose how you are beginning.' : false,
  });
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-08 · How much structure — the first step that reaches the server
// ---------------------------------------------------------------------------

const LEVELS = ['Light', 'Steady', 'Defined'];
const LEVEL_COPY = [
  'Few expectations, easy to keep.',
  'Clear expectations with room to adjust.',
  'A firm shape you both rely on.',
];

function structure(o = {}) {
  const {
    level = 1, together = true, busy = false, error = null, offline = false,
  } = o;

  let b = step(3);
  b += eyebrow(96, 'YOUR STRUCTURE');
  b += heading(134, ['How much structure', 'feels right?']);
  b += text(M, 214, 'Choose a starting rhythm. Nothing here', 13, C.muted);
  b += text(M, 234, "removes either person's voice.", 13, C.muted);

  // An arc, because the three are a continuum rather than three buttons.
  const cxs = [64, 195, 326];
  b += `<path d="M64 316 Q195 262 326 316" fill="none" stroke="${C.line}" stroke-width="1"/>`;
  cxs.forEach((cx, i) => {
    const cy = i === 1 ? 282 : 316;
    const on = level === i;
    b += circle(cx, cy, on ? 10 : 7, C.canvas, on ? C.terra : C.line, 1.3);
    if (on) b += circle(cx, cy, 5, C.terra);
  });
  b += text(195, 340, LEVELS[level], 24, C.primary,
    { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
  b += text(195, 366, LEVEL_COPY[level], 12, C.muted, { anchor: 'middle' });
  b += text(64, 396, 'Light', 11, level === 0 ? C.primary : C.muted, { anchor: 'middle' });
  b += text(326, 396, 'Defined', 11, level === 2 ? C.primary : C.muted, { anchor: 'middle' });

  b += eyebrow(444, 'YOUR CONTEXT');
  b += text(M, 476, 'Long-distance', 12, together ? C.muted : C.primary);
  b += text(W - M, 476, 'Together', 12, together ? C.primary : C.muted, { anchor: 'end' });
  b += rect(120, 471, 150, 1, C.line);
  b += circle(together ? 262 : 128, 471, 6, C.terra);

  [['icon.timezone', 'Timezone', 'America / Los Angeles · detected', 512],
   ['icon.boundaries', 'Boundaries & preferences', 'Add the essentials · optional', 574],
  ].forEach(([id, title, meta, y]) => {
    b += rect(M, y, W - M * 2, 1, C.line);
    b += asset(id, M + 4, y + 18, 24, 'muted');
    b += text(M + 40, y + 28, title, 14, C.primary);
    b += text(M + 40, y + 48, meta, 11, C.muted);
    b += `<path d="M356 ${y + 28} l5 5 l-5 5" fill="none" stroke="${C.muted}" stroke-width="1"/>`;
  });
  b += rect(M, 636, W - M * 2, 1, C.line);

  if (error) b += banner(660, error, { tone: 'error' });
  else if (offline) b += banner(660, "You're offline. Connect, then try again.");
  else b += text(M, 676, 'You can refine this together later.', 12, C.muted);

  b += primary(716, busy ? 'Setting up' : 'Continue', { busy });
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-12 · The starting rhythm — the first thing that becomes real
// ---------------------------------------------------------------------------

const RHYTHM = [
  ['01', 'RITUAL', 'Evening check-in', 'A pause for presence before the day closes.', 'emblem.ritual.evening'],
  ['02', 'EXPECTATION', 'One honest sentence', 'Share what you need today.', 'mark.guidance'],
  ['03', 'CHECK-IN', 'Daily check-in', 'Mood · Energy · Need', 'mark.check-in'],
];

function rhythm(o = {}) {
  const { loading = false, busy = false, error = null, offline = false, uncertain = false } = o;

  let b = step(4);
  b += eyebrow(96, 'YOUR STARTING RHYTHM');
  b += heading(134, ['A small rhythm', 'to begin.']);
  b += text(M, 208, 'Keep what feels right. Replace anything that doesn’t.', 12, C.muted);

  if (loading) {
    // Skeleton keeps the geometry so the page does not jump when the
    // suggestion arrives.
    [252, 372, 492].forEach((y) => {
      b += rect(M, y, W - M * 2, 96, C.raised, 10);
      b += rect(M + 56, y + 24, 150, 12, C.line, 6);
      b += rect(M + 56, y + 52, 208, 9, C.line, 5);
    });
    b += text(W / 2, 636, 'Finding a rhythm for you…', 12, C.muted, { anchor: 'middle' });
    b += primary(716, 'Start this rhythm', { busy: true });
    return page(b);
  }

  if (error || offline || uncertain) {
    b += banner(252, error
      ? "We couldn't load a starting rhythm."
      : offline
        ? "You're offline. Connect, then try again."
        : "We couldn't confirm whether this was set up.",
      { tone: error ? 'error' : 'muted' });
    if (uncertain) {
      b += text(W / 2, 322, 'Check whether it was created before', 12, C.secondary, { anchor: 'middle' });
      b += text(W / 2, 342, 'setting it up again.', 12, C.secondary, { anchor: 'middle' });
      b += primary(400, 'Go to Today');
      b += text(W / 2, 496, 'Try setting up again', 13, C.secondary, { anchor: 'middle', weight: 500 });
    } else {
      b += text(W / 2, 322, 'Your choices are kept.', 12, C.secondary, { anchor: 'middle' });
      b += primary(400, 'Try again');
    }
    return page(b);
  }

  b += rect(M + 46, 250, 1, 302, C.line);
  RHYTHM.forEach(([n, kind, title, meta, id], i) => {
    const y = 252 + i * 104;
    b += text(M, y + 22, n, 20, C.muted, { family: 'Cormorant Garamond', weight: 500 });
    b += circle(M + 46, y + 16, 6, C.canvas, C.terra, 1.2);
    b += asset(id, M + 68, y, id === 'emblem.ritual.evening' ? 48 : 40,
      id === 'emblem.ritual.evening' ? 'muted' : 'primary');
    b += text(M + 128, y + 12, kind, 9, C.muted, { weight: 600, tracking: 1.5 });
    b += text(M + 128, y + 38, title, 19, C.primary,
      { family: 'Cormorant Garamond', weight: 500 });
    b += text(M + 128, y + 60, meta, 11, C.muted);
    b += text(W - M, y + 38, 'Replace', 11, C.terra, { anchor: 'end', weight: 500 });
    b += rect(W - M - 46, y + 44, 46, 1, C.terra, 0, 'none', 1, 0.6);
    if (i < RHYTHM.length - 1) b += rect(M + 128, y + 84, 214, 1, C.line);
  });

  b += circle(M + 46, 588, 10, C.canvas, C.line, 1);
  b += text(M + 42, 593, '+', 15, C.muted);
  b += text(M + 74, 593, 'Add another expectation', 13, C.secondary);

  b += text(M, 660, 'Start light. Adjust together.', 12, C.muted);
  b += primary(716, busy ? 'Starting' : 'Start this rhythm', { busy });
  return page(b);
}

// ---------------------------------------------------------------------------

const screens = [
  {
    id: 'SCR-31', dir: 'SCR-31-goal-selection', rev: 'rev-2', states: [
      ['default', 'CLOSER CHOSEN', () => goals()],
      ['other-goal', 'ACCOUNTABILITY', () => goals({ chosen: 3 })],
      ['nothing-chosen', 'NOTHING CHOSEN', () => goals({ chosen: -1, unmet: true })],
    ],
  },
  {
    id: 'SCR-07', dir: 'SCR-07-role-orientation', rev: 'rev-3', states: [
      ['default', 'WITH A PARTNER', () => roles()],
      ['solo', 'FOR MYSELF', () => roles({ solo: true, named: false })],
      ['unnamed-role', 'NO ROLE NAMED', () => roles({ named: false })],
    ],
  },
  {
    id: 'SCR-08', dir: 'SCR-08-relationship-structure', rev: 'rev-3', states: [
      ['default', 'STEADY', () => structure()],
      ['light', 'LIGHT', () => structure({ level: 0 })],
      ['long-distance', 'LONG-DISTANCE', () => structure({ together: false })],
      ['busy', 'SETTING UP', () => structure({ busy: true })],
      ['error', 'RETRY', () => structure({ error: "We couldn't set that up. Try again." })],
      ['offline', 'OFFLINE', () => structure({ offline: true })],
    ],
  },
  {
    id: 'SCR-12', dir: 'SCR-12-relationship-foundation', rev: 'rev-3', states: [
      ['default', 'PROPOSED', () => rhythm()],
      ['loading', 'LOADING', () => rhythm({ loading: true })],
      ['busy', 'STARTING', () => rhythm({ busy: true })],
      ['error', 'RETRY', () => rhythm({ error: true })],
      ['offline', 'OFFLINE', () => rhythm({ offline: true })],
      ['uncertain', 'RESULT UNCERTAIN', () => rhythm({ uncertain: true })],
    ],
  },
];

async function write(svg, dir) {
  fs.mkdirSync(dir, { recursive: true });
  const buf = Buffer.from(svg);
  await sharp(buf, { density: 72 * SCALE }).resize(W * SCALE, H * SCALE, { fit: 'fill' })
    .png().toFile(path.join(dir, 'source.png'));
  await sharp(buf, { density: 72 }).resize(W, H, { fit: 'fill' })
    .webp({ quality: 92 }).toFile(path.join(dir, 'preview.webp'));
}

async function board(rendered) {
  const cols = 6;
  const tw = 150;
  const th = Math.round((H / W) * tw);
  const cw = tw + 34;
  const ch = th + 62;
  const gap = 16;
  const rows = Math.ceil(rendered.length / cols);
  const width = 40 + cols * (cw + gap);
  const height = 96 + rows * (ch + gap);
  const base = sharp({ create: { width, height, channels: 4, background: C.canvas } });
  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="70">` +
      text(32, 44, 'Activation · SCR-31 / 07 / 08 / 12', 20, C.primary, { weight: 600 }) +
      '</svg>'),
    left: 0, top: 12,
  }];
  for (let i = 0; i < rendered.length; i += 1) {
    const e = rendered[i];
    const x = 20 + (i % cols) * (cw + gap);
    const y = 92 + Math.floor(i / cols) * (ch + gap);
    composites.push({
      input: Buffer.from(
        `<svg xmlns="http://www.w3.org/2000/svg" width="${cw}" height="${ch}">` +
        rect(0, 0, cw, ch, C.disabledBg, 12, C.line, 1) +
        text(cw / 2, ch - 26, e.screen, 9, C.muted, { anchor: 'middle', weight: 600, tracking: 1 }) +
        text(cw / 2, ch - 12, e.label, 9, C.secondary, { anchor: 'middle', weight: 600, tracking: 1 }) +
        '</svg>'),
      left: x, top: y,
    });
    composites.push({
      input: await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer(),
      left: x + 17, top: y + 16,
    });
  }
  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'activation-state-family-board.png'));
}

async function main() {
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];
  for (const screen of screens) {
    for (const [key, label, build] of screen.states) {
      const dir = key === 'default'
        ? path.join(outRoot, screen.dir, 'candidates', screen.rev)
        : path.join(outRoot, screen.dir, 'candidates', screen.rev, 'states', key);
      await write(build(), dir);
      rendered.push({ screen: screen.id, key, label, preview: path.join(dir, 'preview.webp') });
    }
  }
  await board(rendered);
  fs.writeFileSync(
    path.join(referenceRoot, 'activation-state-family-validation.json'),
    `${JSON.stringify({
      candidate_id: 'ACTIVATION-WIZARD',
      generated_at: new Date().toISOString(),
      result: 'pass',
      viewport: { width: W, height: H },
      source_scale: SCALE,
      state_family: 'product/decisions/activation-state-family.md',
      tokens: tokenSource.meta.freezeId,
      svg_freeze: freeze.freeze_id,
      states: rendered.map((r) => ({
        screen: r.screen, key: r.key, preview: path.relative(root, r.preview),
      })),
      board: 'design/qa/reference/activation-state-family-board.png',
      build_gate: 'unchanged — these are candidates, not approvals',
    }, null, 2)}\n`,
  );
  process.stdout.write(`Activation rendered · ${rendered.length} states across 4 screens\n`);
}

main().catch((e) => {
  process.stderr.write(`${e.stack || e.message}\n`);
  process.exitCode = 1;
});
