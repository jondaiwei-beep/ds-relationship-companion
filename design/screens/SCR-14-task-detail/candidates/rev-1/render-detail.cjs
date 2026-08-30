#!/usr/bin/env node

// SCR-14 — occurrence detail, state family.
//
//   node design/screens/SCR-14-task-detail/candidates/rev-1/render-detail.cjs
//
// Deterministic and spec-driven, per `.claude/skills/ds-design-generate`:
// colours resolve through the frozen B-2 tokens and marks come from the SVG
// Freeze registry at licensed sizes and tones. Nothing is sampled from the
// reference raster — which is itself wrong in three places, recorded in
// `design-qa.md`: it offers photographic proof, it offers only completion, and
// it frames completion as a notification.
//
// Design is `DESIGN.md`; the review is `design-qa.md`.
//
// The load-bearing rule: **actions render from the server's `allowedActions`,
// never from the state**. Every builder here takes the action list as data for
// that reason. An absent action is withheld, not disabled.

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../../../../..');

// Must run before sharp loads; see design/qa/scripts/fonts.cjs.
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

const outDir = path.join(root, 'design/screens/SCR-14-task-detail/candidates/rev-1');
const referenceRoot = path.join(root, 'design/qa/reference');

const W = 390;
const H = 844;
const SCALE = 3;

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

function dp(p) {
  const v = token(p);
  if (typeof v === 'number') return v;
  if (v && typeof v.value === 'number') return v.value;
  throw new Error(`Not a dimension token: ${p}`);
}

const M = dp('size.layout.mobileInset');
const BTN = dp('size.control.button');

const C = {
  canvas: token('color.semantic.canvas.ritual'),
  primary: token('color.semantic.text.onRitual.primary'),
  secondary: token('color.semantic.text.onRitual.secondary'),
  muted: token('color.semantic.text.onRitual.muted'),
  hairline: token('color.semantic.border.onRitual.hairline'),
  rule: token('color.semantic.decorative.ritualLine'),
  actionBg: token('color.semantic.action.primary.background'),
  actionFg: token('color.semantic.action.primary.foreground'),
  disabledBg: token('color.semantic.action.primary.disabledBackground'),
  disabledFg: token('color.semantic.action.primary.disabledForeground'),
  needsReview: token('color.semantic.state.needsReview'),
  waiting: token('color.semantic.state.waiting'),
  error: token('color.semantic.state.error'),
  relationship: token('color.semantic.text.onRitual.relationshipLarge'),
};

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  relationship: 'color.semantic.icon.relationship',
};

function esc(v) {
  return String(v).replace(/[<>&'"]/g, (c) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[c]);
}

function text(x, y, value, size, fill, o = {}) {
  const {
    family = 'Inter', weight = 400, tracking = 0, anchor = 'start', opacity = 1,
  } = o;
  return `<text x="${x}" y="${y}" fill="${fill}" fill-opacity="${opacity}" font-family="${family}" font-size="${size}" font-weight="${weight}" letter-spacing="${tracking}" text-anchor="${anchor}">${esc(value)}</text>`;
}

function rect(x, y, w, h, fill, r = 0, stroke = 'none', sw = 0) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

/// The only registered SCR-14 mark, at a licensed size and tone. Throws on
/// anything else — a review or waiting mark would be an asset-contract change,
/// not something to improvise here.
function asset(id, x, y, size, tone) {
  const registered = assetById.get(id);
  if (!registered) throw new Error(`Unregistered asset: ${id}`);
  if (!(registered.used_by ?? []).includes('SCR-14')) {
    throw new Error(`${id} is not in SCR-14's asset contract`);
  }
  const rules = freezeById.get(id);
  if (rules) {
    if (!rules.sizes_dp.includes(size)) {
      throw new Error(`${id} is frozen at ${rules.sizes_dp.join('/')}dp, not ${size}`);
    }
    if (!rules.colors.includes(tone)) {
      throw new Error(`${id} does not license the ${tone} tone`);
    }
  }
  const fill = token(toneToken[tone]);
  const source = fs.readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', fill);
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${Buffer.from(source).toString('base64')}"/>`;
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, C.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// Shared composition

function header(context = 'TODAY / TASK') {
  let b = text(M, 44, context, 11, C.muted, { weight: 500, tracking: 2.2 });
  // Close, drawn as chrome rather than a registered mark — the design says
  // explicitly that the close control is navigation, not an SCR-14 asset.
  const cx = W - M - 8;
  b += `<path d="M${cx - 7} 37 l14 14 M${cx + 7} 37 l-14 14" stroke="${C.primary}" stroke-width="1.4" stroke-linecap="round"/>`;
  return b;
}

/// The editorial vertical rule, kept from the reference. It runs from the
/// temporal block through the last section and carries no node.
function editorialRule(top, bottom) {
  return rect(M + 6, top, 1, bottom - top, C.rule);
}

function eyebrow(y, value, fill = C.muted) {
  return text(M + 30, y, value, 11, fill, { weight: 500, tracking: 2.2 });
}

/// The expectation itself: `display.ritual`, because it is the one thing the
/// screen is about. It is written by the creator and read by the assignee, so
/// it is a compositional claim, not an authorship one — the distinction
/// `type-in-practice.md` now records.
function expectation(y, lines) {
  let b = '';
  lines.forEach((l, i) => {
    b += text(M + 30, y + i * 40, l, 31, C.primary, {
      family: 'Cormorant Garamond', weight: 500,
    });
  });
  return b;
}

function section(y, label, lines) {
  let b = text(M + 30, y, label, 11, C.muted, { weight: 500, tracking: 2.2 });
  lines.forEach((l, i) => {
    b += text(M + 30, y + 28 + i * 22, l, 15, C.secondary);
  });
  return b;
}

function divider(y) {
  return rect(M + 30, y, W - M * 2 - 30, 1, C.hairline);
}

const LABEL = {
  complete: 'Complete', discuss: 'Discuss', reschedule: 'New time',
  cant_do: 'Can’t do', withdraw: 'Withdraw request',
  acknowledge: 'Acknowledge', praise: 'Praise', comment: 'Comment',
  review: 'Review', excuse: 'Excuse', continue: 'Continue',
  adjust: 'Adjust', cancel: 'Cancel',
};

/// Actions rendered straight from `allowedActions` (REQ-STATE-001).
///
/// Four actions become a two-column grid of four identical controls — equal
/// geometry is how adjustment reads as a peer of completion rather than as a
/// deviation from it (red line #3). Three or one lay out full width.
function actions(y, allowed, { label = 'WHAT FITS NOW' } = {}) {
  if (allowed.length === 0) return '';
  let b = text(M, y, label, 11, C.muted, { weight: 500, tracking: 2.2 });
  const top = y + 22;
  const gap = 12;
  if (allowed.length === 4) {
    const w = (W - M * 2 - gap) / 2;
    allowed.forEach((a, i) => {
      const x = M + (i % 2) * (w + gap);
      const ry = top + Math.floor(i / 2) * (BTN + gap);
      b += rect(x, ry, w, BTN, C.actionBg, 10);
      b += text(x + w / 2, ry + BTN / 2 + 6, LABEL[a] ?? a, 16, C.actionFg, {
        weight: 600, anchor: 'middle', tracking: 0.1,
      });
    });
  } else {
    allowed.forEach((a, i) => {
      const ry = top + i * (BTN + gap);
      b += rect(M, ry, W - M * 2, BTN, C.actionBg, 10);
      b += text(W / 2, ry + BTN / 2 + 6, LABEL[a] ?? a, 16, C.actionFg, {
        weight: 600, anchor: 'middle', tracking: 0.1,
      });
    });
  }
  return b;
}

/// The shared reading region: temporal block, expectation, attribution, then
/// Intention / Completion / Boundary. Returns the y it ended at.
function detailBody(b, { eyebrowText, eyebrowColor = C.muted, time, purpose = true }) {
  let out = b;
  out += editorialRule(96, purpose ? 470 : 396);
  out += eyebrow(124, eyebrowText, eyebrowColor);
  out += text(M + 30, 150, time, 14, C.secondary);
  out += expectation(206, ['Prepare the room', 'before 8:00 PM.']);
  out += text(M + 30, 274, 'Set by Morgan', 14, C.secondary);
  let y = 320;
  if (purpose) {
    out += section(y, 'INTENTION', ['Create a calm space for our', 'evening ritual.']);
    out += divider(y + 68);
    y += 96;
  }
  out += section(y, 'COMPLETION', ['A short note is enough.']);
  out += divider(y + 46);
  out += section(y + 74, 'BOUNDARY', ['Pause if this no longer feels right.']);
  return { svg: out, y: y + 74 };
}

// ---------------------------------------------------------------------------
// The eight states

/// Default — ACTIVE, the assignee. All four actions as peers, and a private
/// note that travels only with `complete`. No photo row: the contract says
/// remove Proof, and evidence of compliance is a surveillance pattern.
function active() {
  // ACTIVE carries the most content of any state, so the note and the actions
  // are placed from where the detail actually ended rather than at fixed y —
  // hardcoding put the note label on top of the BOUNDARY line.
  const { svg, y } = detailBody(header(), { eyebrowText: 'DUE', time: '8:00 PM' });
  let b = svg;
  const noteTop = y + 62;
  b += text(M, noteTop, 'PRIVATE NOTE WITH COMPLETION (OPTIONAL)', 11, C.muted, {
    weight: 500, tracking: 1.6,
  });
  b += text(M, noteTop + 32, 'What did you attend to?', 15, C.muted);
  b += rect(M, noteTop + 46, W - M * 2, 1, C.hairline);
  b += actions(noteTop + 84, ['complete', 'discuss', 'reschedule', 'cant_do']);
  return page(b);
}

/// Needs review — REQ-REVIEW-001, and the reason this screen matters.
///
/// "Past-due active work becomes Needs Review. The software does not assign
/// punishment or consequence." Direction A: the fact and its meaning are read
/// together, before the expectation, with no surface or icon to give them
/// weight they should not have. `needsReview` resolves to Stone — the freeze
/// itself encodes that this is not an alarm.
function needsReview() {
  const { svg } = detailBody(header(), {
    eyebrowText: 'NEEDS REVIEW',
    eyebrowColor: C.needsReview,
    time: 'Due 8:00 PM',
  });
  let b = svg;
  b += text(M + 30, 174, 'This is past due. It only needs another look.', 14, C.secondary);
  b += actions(560, ['complete', 'discuss', 'reschedule', 'cant_do']);
  return page(b);
}

/// Adjustment open — the assignee's own request is pending, so the server
/// permits exactly one thing. This is the affordance Today has no room for,
/// and the reason a NEED_TO_DISCUSS item is currently a dead end for its own
/// author. The endpoint does not exist yet; see design-qa.md.
function adjustmentOpen() {
  const { svg } = detailBody(header(), {
    eyebrowText: 'BEING DISCUSSED', time: 'Due 8:00 PM',
  });
  let b = svg;
  b += text(M + 30, 174, 'You asked to talk about this.', 14, C.secondary);
  b += text(M, 556, 'Morgan has not answered yet.', 14, C.muted);
  b += actions(600, ['withdraw'], { label: 'IF YOU CHANGED YOUR MIND' });
  return page(b);
}

/// Waiting for acknowledgement. The completion is real and marked; the moment
/// is not finished. Completion is never acknowledgement (REQ-COMPLETE-001),
/// so no action is offered — there is nothing for this person to do but wait
/// for a human.
function waitingAck() {
  const { svg } = detailBody(header(), {
    eyebrowText: 'COMPLETED', time: '9:14 PM', purpose: false,
  });
  let b = svg;
  b += asset('state.completed', M + 30, 470, 32, 'primary');
  b += text(M + 30, 546, 'Your part is complete.', 17, C.primary, { weight: 600 });
  b += text(M + 30, 574, 'Waiting for Morgan to respond.', 15, C.waiting);
  b += text(M, 646, 'Nothing here says this is finished until they answer.',
    13, C.muted);
  return page(b);
}

/// Loading. No name-shaped skeletons: the shape of a placeholder leaks the
/// kind and amount of hidden content.
function loading() {
  let b = header();
  b += editorialRule(96, 300);
  b += eyebrow(124, 'CHECKING');
  b += text(M + 30, 206, 'Opening this', 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M + 30, 246, 'expectation.', 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M + 30, 296, 'Its current state is being confirmed.', 14, C.muted);
  return page(b);
}

/// Error. The context is retained: nothing the person typed is lost, and the
/// retry is explicit.
function error() {
  let b = header();
  b += editorialRule(96, 300);
  b += eyebrow(124, 'NOT CONFIRMED', C.error);
  b += text(M + 30, 206, "We couldn't open", 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M + 30, 246, 'this expectation.', 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M + 30, 296, 'Nothing has changed. Trying again is safe.', 14, C.secondary);
  // Retry is local recovery chrome, not a server action. It is drawn directly
  // rather than through `actions()`, which renders only what `allowedActions`
  // returned — putting it there would imply the server offered it.
  b += rect(M, 596, W - M * 2, BTN, C.actionBg, 10);
  b += text(W / 2, 596 + BTN / 2 + 6, 'Try again', 16, C.actionFg, {
    weight: 600, anchor: 'middle', tracking: 0.1,
  });
  return page(b);
}

/// Offline. No mutation without server confirmation, so every action is
/// withheld rather than disabled — an absent action is the honest form. The
/// detail already on the device stays readable.
function offline() {
  const { svg } = detailBody(header(), {
    eyebrowText: 'OFFLINE', time: 'Due 8:00 PM',
  });
  let b = svg;
  b += text(M + 30, 174, 'This is the last confirmed version.', 14, C.secondary);
  b += rect(M, 556, W - M * 2, 44, C.disabledBg, 8);
  b += text(W / 2, 583, "You're offline — actions return when you reconnect.",
    12, C.secondary, { anchor: 'middle' });
  b += text(M, 640, 'Nothing is sent or queued while offline.', 13, C.muted);
  return page(b);
}

/// Authorization loss. The house treatment, matching SCR-09 and the core loop:
/// withhold everything, carry it with geometry rather than a mark this screen
/// does not register.
function authorizationLoss() {
  let b = text(W / 2, 44, 'PRIVATE', 11, C.muted, {
    anchor: 'middle', weight: 500, tracking: 2.2,
  });
  b += `<circle cx="${W / 2}" cy="238" r="40" fill="none" stroke="${C.hairline}" stroke-width="1"/>`;
  b += text(W / 2, 344, 'Sign in to continue.', 31, C.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += text(W / 2, 386, 'This expectation is hidden.', 15, C.secondary, { anchor: 'middle' });
  b += text(W / 2, 412, 'Sign in again to return to it.', 13, C.muted, { anchor: 'middle' });
  b += rect(M, 486, W - M * 2, BTN, C.actionBg, 10);
  b += text(W / 2, 486 + BTN / 2 + 6, 'Sign in', 16, C.actionFg, {
    weight: 600, anchor: 'middle', tracking: 0.1,
  });
  b += text(W / 2, 580, 'No relationship details are shown on this screen.', 12,
    C.muted, { anchor: 'middle' });
  return page(b);
}

const states = [
  ['default', 'ACTIVE', active],
  ['needs-review', 'NEEDS REVIEW', needsReview],
  ['adjustment-open', 'BEING DISCUSSED', adjustmentOpen],
  ['waiting-ack', 'WAITING FOR A HUMAN', waitingAck],
  ['loading', 'CHECKING', loading],
  ['error', 'RETRY', error],
  ['offline', 'OFFLINE', offline],
  ['authorization-loss', 'SIGN IN AGAIN', authorizationLoss],
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
  const cols = 4;
  const tw = 168;
  const th = Math.round((H / W) * tw);
  const cardW = tw + 34;
  const cardH = th + 58;
  const gap = 16;
  const width = 40 + cols * cardW + (cols - 1) * gap;
  const height = 132 + Math.ceil(rendered.length / cols) * (cardH + gap);
  const base = sharp({ create: { width, height, channels: 4, background: C.canvas } });

  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="80">`
      + text(20, 40, 'SCR-14 · rev-1 · occurrence detail', 20, C.primary, { weight: 600 })
      + text(20, 64, 'Actions render from the server’s allowedActions, never from the state.',
        13, C.muted)
      + '</svg>',
    ),
    left: 0,
    top: 20,
  }];

  for (const [i, e] of rendered.entries()) {
    const x = 20 + (i % cols) * (cardW + gap);
    const y = 112 + Math.floor(i / cols) * (cardH + gap);
    const card = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${cardW}" height="${cardH}">`
      + rect(0, 0, cardW, cardH, C.disabledBg, 12, C.hairline, 1)
      + text(cardW / 2, cardH - 20, e.label, 10, C.secondary, {
        anchor: 'middle', weight: 600, tracking: 1,
      })
      + '</svg>',
    );
    const thumb = await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer();
    composites.push({ input: card, left: x, top: y });
    composites.push({ input: thumb, left: x + 17, top: y + 16 });
  }

  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'scr14-detail-state-family-board.png'));
}

async function main() {
  // A render in the wrong typeface looks fine and is wrong. Stop instead.
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];

  for (const [key, label, build] of states) {
    const dir = key === 'default' ? outDir : path.join(outDir, 'states', key);
    await write(build(), dir);
    rendered.push({ key, label, preview: path.join(dir, 'preview.webp') });
  }

  await board(rendered);
  process.stdout.write(`SCR-14 rendered · ${rendered.length} states\n`);
  process.stdout.write(`${path.join(referenceRoot, 'scr14-detail-state-family-board.png')}\n`);
}

main().catch((e) => {
  process.stderr.write(`${e.stack}\n`);
  process.exit(1);
});
