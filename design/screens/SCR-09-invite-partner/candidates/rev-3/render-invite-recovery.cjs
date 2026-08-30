#!/usr/bin/env node

// Renders the four SCR-09 states the contract lists as blocked:
// loading, share-error, offline, authorization-loss.
//
//   node design/screens/SCR-09-invite-partner/candidates/rev-3/render-invite-recovery.cjs
//
// Deterministic and spec-driven, per `.claude/skills/ds-design-generate`:
// colours resolve through the frozen B-2 tokens and marks come from the SVG
// Freeze registry at licensed sizes and tones. Nothing is sampled from a
// raster.
//
// Design is `DESIGN.md`; the review that chose between its directions is
// `design-qa.md`.
//
// This is the SENDING side of the invite handshake, and it diverges from
// SCR-10 deliberately. The viewer here is authenticated, inside their own
// Dynamic, and owns the invitation — so `offline` keeps their code visible
// and `share-error` keeps the whole Pending composition. Withholding an
// owner's own work is not privacy, it is losing it. Only
// `authorization-loss` converges with the receiving side, because there we
// do not yet know it is their work.

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

const outDir = path.join(root, 'design/screens/SCR-09-invite-partner/candidates/rev-3');
const referenceRoot = path.join(root, 'design/qa/reference');

const W = 390;
const H = 844;
const SCALE = 3;

function get(p) {
  return p.split('.').reduce((n, k) => n?.[k], tokenSource);
}

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

/// Dimension tokens carry `{value, unit}`; this is the number.
function dp(p) {
  const v = token(p);
  if (typeof v === 'number') return v;
  if (v && typeof v.value === 'number') return v.value;
  throw new Error(`Not a dimension token: ${p}`);
}

const M = dp('size.layout.mobileInset');

const color = {
  canvas: token('color.semantic.canvas.ritual'),
  raised: token('color.semantic.surface.ritual.raised'),
  primary: token('color.semantic.text.onRitual.primary'),
  secondary: token('color.semantic.text.onRitual.secondary'),
  muted: token('color.semantic.text.onRitual.muted'),
  hairline: token('color.semantic.border.onRitual.hairline'),
  actionBg: token('color.semantic.action.primary.background'),
  actionFg: token('color.semantic.action.primary.foreground'),
  actionDisabledBg: token('color.semantic.action.primary.disabledBackground'),
  actionDisabledFg: token('color.semantic.action.primary.disabledForeground'),
  error: token('color.semantic.state.error'),
  ritualLine: token('color.semantic.decorative.ritualLine'),
  terracotta: token('color.primitive.terracotta'),
};

const DISABLED = token('opacity.disabled');

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  authority: 'color.semantic.icon.authority',
  relationship: 'color.semantic.icon.relationship',
  // The freeze licenses a `decorative` tone that the icon group does not
  // carry; it resolves to the botanical colour, as in SCR-02 and SCR-31.
  decorative: 'color.semantic.decorative.botanical',
};

function iconToken(tone) {
  const named = toneToken[tone];
  if (!named) throw new Error(`Unknown tone: ${tone}`);
  return token(named);
}

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

function rect(x, y, w, h, fill, r = 0, stroke = 'none', sw = 0, opacity = 1) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" fill-opacity="${opacity}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

/// A registered mark at a size and tone the freeze licenses. Throws rather
/// than rendering something plausible.
function asset(id, x, y, size, tone, opacity = 1) {
  const registered = assetById.get(id);
  if (!registered) throw new Error(`Unregistered asset: ${id}`);
  if (!(registered.used_by ?? []).includes('SCR-09')) {
    throw new Error(`${id} is not in SCR-09's asset contract`);
  }
  const rules = freezeById.get(id);
  if (rules) {
    if (!rules.sizes_dp.includes(size)) {
      throw new Error(`${id} is frozen at ${rules.sizes_dp.join('/')}dp, not ${size}`);
    }
    if (!rules.colors.includes(tone)) {
      throw new Error(`${id} does not license the ${tone} tone (${rules.colors.join(', ')})`);
    }
  }
  const fill = iconToken(tone);
  const source = fs
    .readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', fill);
  const encoded = Buffer.from(source).toString('base64');
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" opacity="${opacity}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${encoded}"/>`;
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, color.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// The approved rev-2 composition, band by band. Every state reserves the same
// bands so nothing jumps between them.

function header(status, { statusColor = color.muted, back = true } = {}) {
  let b = '';
  if (back) {
    b += `<path d="M30 44 l-10 -9 l10 -9" stroke="${color.secondary}" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  b += text(W / 2, 41, 'Private invitation', 16, color.primary, { anchor: 'middle' });
  if (status) {
    b += text(W - M, 40, status, 12, statusColor, {
      anchor: 'end', weight: 500, tracking: 2.4,
    });
  }
  return b;
}

/// The botanical branch, low-contrast, down the right edge. Decorative only.
function branch() {
  return asset('motif.botanical.invite-branch', W - 148, 168, 160, 'decorative', 0.30);
}

/// The bond mark's reserved slot: 80dp, per `space.20`.
const BOND_TOP = 96;
const BOND_SIZE = 80;

// `primary`, not `relationship`: the approved Pending render draws the rings
// as a pale outline and reserves Terracotta for the single point at their
// centre. A wholly Terracotta mark reads as an alert.
function bond(tone = 'primary') {
  return asset('mark.partner-bond', W / 2 - BOND_SIZE / 2, BOND_TOP, BOND_SIZE, tone);
}

function headline(y, lines) {
  let b = '';
  lines.forEach((l, i) => {
    b += text(W / 2, y + i * 42, l, 34, color.primary, {
      family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
    });
  });
  return b;
}

function para(y, lines, { fill = color.secondary, size = 16, anchor = 'middle', x = W / 2 } = {}) {
  let b = '';
  lines.forEach((l, i) => {
    b += text(x, y + i * 22, l, size, fill, { anchor });
  });
  return b;
}

/// The four-node lifecycle track. `current` is an index, or null for none.
///
/// The contract asks `loading` to "preserve lifecycle geometry without
/// revealing stale state", which reads as a contradiction until you separate
/// the two: the track holds its place with every node hollow, so the geometry
/// is intact and no node claims to be true.
///
/// `cached` outlines a node instead of filling it — the one place the screen
/// shows a position it cannot vouch for, and the outline is paired with words
/// so colour never carries it alone.
function track(y, { current = null, cached = null } = {}) {
  const labels = ['Pending', 'Accepted', 'Expired', 'Revoked'];
  const left = M + 14;
  const right = W - M - 14;
  const step = (right - left) / (labels.length - 1);
  let b = rect(left, y - 0.5, right - left, 1, color.hairline);
  labels.forEach((label, i) => {
    const x = left + i * step;
    const isCurrent = i === current;
    const isCached = i === cached;
    const ring = isCurrent ? color.terracotta : (isCached ? color.secondary : color.hairline);
    b += `<circle cx="${x}" cy="${y}" r="9" fill="${color.canvas}" stroke="${ring}" stroke-width="${isCached ? 1.6 : 1.2}"/>`;
    if (isCurrent) b += `<circle cx="${x}" cy="${y}" r="4" fill="${color.terracotta}"/>`;
    b += text(x, y + 30, label, 12, isCurrent ? color.primary : color.muted, {
      anchor: 'middle', weight: isCurrent ? 500 : 400,
    });
  });
  return b;
}

function ritualButton(y, label, icon, { disabled = false } = {}) {
  const h = dp('size.control.buttonRitual');
  const bg = disabled ? color.actionDisabledBg : color.actionBg;
  const fg = disabled ? color.actionDisabledFg : color.actionFg;
  let b = rect(M, y, W - M * 2, h, bg, 10);
  // Icon and label centred as one unit: Inter 16 semibold runs ~8.4px per
  // character, so the pair is measured rather than eyeballed.
  const textWidth = label.length * 8.4;
  const groupLeft = (W - (24 + 14 + textWidth)) / 2;
  if (icon) b += asset(icon, groupLeft, y + h / 2 - 12, 24, 'primary', disabled ? DISABLED : 1);
  b += text(groupLeft + 24 + 14, y + h / 2 + 6, label, 16, fg, { weight: 600, tracking: 0.1 });
  return b;
}

/// A list row: icon, label, hairline beneath. Disabled rows state their reason
/// rather than disappearing — a hidden control is indistinguishable from one
/// that never existed.
function listRow(y, label, icon, { disabled = false, chevron = true } = {}) {
  const h = dp('size.control.listRow');
  const fg = disabled ? color.muted : color.primary;
  let b = asset(icon, M, y + h / 2 - 10, 20, 'muted', disabled ? DISABLED : 1);
  b += text(M + 34, y + h / 2 + 5, label, 16, fg, { opacity: disabled ? DISABLED : 1 });
  if (chevron && !disabled) {
    b += `<path d="M${W - M - 8} ${y + h / 2 - 5} l5 5 l-5 5" stroke="${color.secondary}" stroke-width="1.3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  b += rect(M, y + h, W - M * 2, 1, color.hairline);
  return b;
}

function codeBlock(y, code, note, { label = 'PRIVATE LINK / CODE' } = {}) {
  let b = text(M, y, label, 12, color.muted, { weight: 500, tracking: 2.4 });
  b += text(M, y + 42, code, 28, color.primary, {
    family: 'Cormorant Garamond', weight: 500, tracking: 3,
  });
  b += asset('icon.copy', W - M - 24, y + 20, 24, 'muted');
  if (note) b += text(M, y + 70, note, 14, color.muted);
  return b;
}

// ---------------------------------------------------------------------------
// The four states

/// Loading — Direction A. Every band reserved, no band asserting anything.
/// The bond mark is withheld rather than faded: it carries relationship state,
/// so a faded one still states a state.
function loading() {
  let b = header('CHECKING');
  b += headline(300, ['Checking this invitation.']);
  b += para(352, ["We're confirming its current status."], { fill: color.muted });
  b += track(700, { current: null });
  return page(b);
}

/// Share error — Direction A. The live invitation never leaves the screen.
/// "Still active" and "this same invitation" defuse the duplicate-link
/// ambiguity before the person can reach the button.
function shareError() {
  let b = header('PENDING', { statusColor: color.terracotta });
  b += branch();
  b += bond();
  b += headline(232, ['A private space', 'is ready for Morgan.']);
  b += codeBlock(320, 'RITUAL-7K4M', 'Expires in 6 days');
  b += text(M, 428, "SHARING DIDN'T COMPLETE", 12, color.error, {
    weight: 500, tracking: 2.4,
  });
  b += para(456, ['Your invitation is still active.'], {
    anchor: 'start', x: M, fill: color.primary,
  });
  b += para(480, ['Only sharing was interrupted. Try again', 'to share this same invitation.'], {
    anchor: 'start', x: M, fill: color.muted, size: 14,
  });
  b += ritualButton(534, 'Share again', 'icon.share');
  b += listRow(614, 'Copy link', 'icon.copy');
  b += listRow(614 + 73, 'Revoke invitation', 'icon.revoke');
  b += track(786, { current: 0 });
  return page(b);
}

/// Offline — the owner keeps their own content. Revoke is disabled with its
/// reason stated, never queued: a revoke that seems to succeed offline and
/// does not leaves someone believing a live link is dead.
function offline() {
  let b = header('OFFLINE');
  b += branch();
  b += bond();
  b += headline(226, ['Your invitation', 'is still here.']);
  b += para(312, ["You're offline. You can still share or", 'copy the saved link.']);
  b += para(362, ['Its current status will be checked when', 'you reconnect.'], {
    fill: color.muted, size: 14,
  });
  b += codeBlock(418, 'RITUAL-7K4M', 'Last confirmed: Pending');
  b += ritualButton(510, 'Share invitation', 'icon.share');
  b += listRow(590, 'Copy link', 'icon.copy');
  b += listRow(663, 'Revoke unavailable offline', 'icon.revoke', { disabled: true });
  b += text(M, 752, 'Revoking needs a connection and will not be queued.', 13, color.muted);
  b += track(786, { cached: 0 });
  return page(b);
}

/// Authorization loss — the one state that converges with SCR-10. No partner
/// name, no code, no lifecycle position: we do not yet know this is their
/// work. `state.locked` and `state.auth-restored` are deliberately absent —
/// neither is in this screen's asset contract, and the first would accuse.
function authorizationLoss() {
  // No `Private invitation` title here: this state withholds the invitation,
  // and naming it in the header would disclose what the page is about.
  let b = text(W / 2, 41, 'ACCOUNT NEEDED', 12, color.muted, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });
  b += `<circle cx="${W / 2}" cy="${BOND_TOP + BOND_SIZE / 2}" r="40" fill="none" stroke="${color.ritualLine}" stroke-width="1"/>`;
  b += headline(268, ['Confirm your account', 'to continue.']);
  b += para(340, ['This invitation is not shown until', 'we know who is looking.']);
  b += rect(M, 404, W - M * 2, 1, color.hairline);
  b += para(444, ['Confirming an account does not change', 'the invitation.'], {
    fill: color.muted, size: 14,
  });
  b += ritualButton(544, 'Confirm account', null);
  b += text(W / 2, 648, 'Use a different account', 13, color.secondary, {
    anchor: 'middle', weight: 500,
  });
  b += text(W / 2, 800, 'No Dynamic details are shown until access is confirmed.', 13, color.muted, {
    anchor: 'middle',
  });
  return page(b);
}

const states = [
  ['loading', 'Loading', loading],
  ['share-error', 'Share / error retry', shareError],
  ['offline', 'Offline', offline],
  ['authorization-loss', 'Authorization loss', authorizationLoss],
];

async function write(svg, dir) {
  fs.mkdirSync(dir, { recursive: true });
  const buffer = Buffer.from(svg);
  await sharp(buffer, { density: 72 * SCALE })
    .resize(W * SCALE, H * SCALE, { fit: 'fill' })
    .png()
    .toFile(path.join(dir, 'source.png'));
  await sharp(buffer, { density: 72 })
    .resize(W, H, { fit: 'fill' })
    .webp({ quality: 92 })
    .toFile(path.join(dir, 'preview.webp'));
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

  const base = sharp({
    create: { width, height, channels: 4, background: color.canvas },
  });

  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="80">`
      + text(20, 40, 'SCR-09 · rev-3 · invite recovery states', 20, color.primary, { weight: 600 })
      + text(20, 64, 'The four states the contract lists as blocked.', 13, color.muted)
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
      + rect(0, 0, cardW, cardH, color.actionDisabledBg, 12, color.hairline, 1)
      + text(cardW / 2, cardH - 20, e.label, 10, color.secondary, {
        anchor: 'middle', weight: 600, tracking: 1,
      })
      + '</svg>',
    );
    const thumb = await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer();
    composites.push({ input: card, left: x, top: y });
    composites.push({ input: thumb, left: x + 17, top: y + 16 });
  }

  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'scr09-invite-recovery-board.png'));
}

async function main() {
  // A render in the wrong typeface looks fine and is wrong. Stop instead.
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];

  for (const [key, label, build] of states) {
    const dir = path.join(outDir, 'states', key);
    await write(build(), dir);
    rendered.push({ key, label, preview: path.join(dir, 'preview.webp') });
  }

  await board(rendered);
  process.stdout.write(`SCR-09 recovery rendered · ${rendered.length} states\n`);
  process.stdout.write(`${path.join(referenceRoot, 'scr09-invite-recovery-board.png')}\n`);
}

main().catch((e) => {
  process.stderr.write(`${e.stack}\n`);
  process.exit(1);
});
