#!/usr/bin/env node

// Renders the five SCR-10 recovery states the contract lists as blocked:
// revoked, loading, error, offline, authorization-loss.
//
//   node design/screens/SCR-10-invitation-received/candidates/rev-3/render-join-recovery.cjs
//
// Deterministic and spec-driven, per `.claude/skills/ds-design-generate`:
// every colour resolves through the frozen B-2 tokens and every mark comes
// from the SVG Freeze registry at a licensed size and tone. Nothing is
// sampled from a raster.
//
// The design is `DESIGN.md`; the review that chose between its two directions
// for `revoked` and `authorization-loss` is `design-qa.md`.
//
// Composition follows the approved rev-2 `expired` state deliberately. To the
// person holding the link, revoked / expired / error / offline are one fact —
// *this cannot be used right now* — differing only in a cause they must not be
// told. Giving them different compositions would make that difference visible.

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../../../../..');

// Must run before sharp loads; see design/qa/scripts/fonts.cjs for why the
// old FONTCONFIG_FILE approach silently produced the wrong typeface.
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

const outDir = path.join(root, 'design/screens/SCR-10-invitation-received/candidates/rev-3');
const referenceRoot = path.join(root, 'design/qa/reference');

const W = 390;
const H = 844;
const SCALE = 3;
const MARGIN = 24;

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

const color = {
  canvas: token('color.semantic.canvas.ritual'),
  primary: token('color.semantic.text.onRitual.primary'),
  secondary: token('color.semantic.text.onRitual.secondary'),
  muted: token('color.semantic.text.onRitual.muted'),
  hairline: token('color.semantic.border.onRitual.hairline'),
  actionBg: token('color.semantic.action.primary.background'),
  actionFg: token('color.semantic.action.primary.foreground'),
  actionDisabledBg: token('color.semantic.action.primary.disabledBackground'),
  actionDisabledFg: token('color.semantic.action.primary.disabledForeground'),
  revoked: token('color.semantic.state.revoked'),
  error: token('color.semantic.state.error'),
  ritualLine: token('color.semantic.decorative.ritualLine'),
  terracotta: token('color.primitive.terracotta'),
};

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  authority: 'color.semantic.icon.authority',
  relationship: 'color.semantic.icon.relationship',
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

/// A registered mark, at a size and tone the freeze licenses. Throws rather
/// than rendering something plausible.
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
  const fill = iconToken(tone);
  const source = fs
    .readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', fill);
  const encoded = Buffer.from(source).toString('base64');
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${encoded}"/>`;
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, color.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// Shared composition
//
// `COMPANION`, not the relationship-category wordmark: this page can be opened
// by anyone holding a link, on a shared device, before authentication. The
// product's category is itself protected content.
function header() {
  return text(W / 2, 64, 'COMPANION', 12, color.muted, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });
}

/// The status field. A plain outlined circle, never a cross, strike or warning
/// pulse — an unusable invitation is not an emergency and must not be styled
/// as one. `mark.partner-bond` is deliberately withheld while invite truth is
/// unresolved: drawing the bond would be the app implying a relationship.
function statusField(cy, { mark = null, tone = 'muted' } = {}) {
  let body = `<circle cx="${W / 2}" cy="${cy}" r="40" fill="none" stroke="${color.ritualLine}" stroke-width="1"/>`;
  if (mark) body += asset(mark, W / 2 - 16, cy - 16, 32, tone);
  return body;
}

/// The headline. `display.ritual` — Cormorant 34/42 — because it is one thing,
/// centred, alone: the compositional test in `type-in-practice.md`, not an
/// authorship claim. See design-qa.md for why the narrower reading was wrong.
function headline(y, lines) {
  let body = '';
  lines.forEach((line, i) => {
    body += text(W / 2, y + i * 42, line, 34, color.primary, {
      family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
    });
  });
  return body;
}

function eyebrow(y, value, fill = color.muted) {
  return text(W / 2, y, value, 12, fill, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });
}

function body(y, lines, { fill = color.secondary, size = 16 } = {}) {
  let out = '';
  lines.forEach((line, i) => {
    out += text(W / 2, y + i * 24, line, size, fill, { anchor: 'middle' });
  });
  return out;
}

function divider(y) {
  return rect(MARGIN, y, W - MARGIN * 2, 1, color.hairline);
}

function primaryButton(y, label, { disabled = false } = {}) {
  const bg = disabled ? color.actionDisabledBg : color.actionBg;
  const fg = disabled ? color.actionDisabledFg : color.actionFg;
  return rect(MARGIN, y, W - MARGIN * 2, 56, bg, 10)
    + text(W / 2, y + 34, label, 16, fg, { weight: 600, anchor: 'middle', tracking: 0.1 });
}

function textLink(y, label) {
  return text(W / 2, y, label, 13, color.secondary, { anchor: 'middle', weight: 500 });
}

/// The privacy footnote, with the private-space icon beside it. Colour never
/// carries the meaning alone.
function footnote(y, value) {
  const size = 20;
  // Inter 13 runs ~6.4px per character at this weight; enough to centre the
  // icon-plus-text pair as one unit rather than centring the text and letting
  // the icon push it off-axis.
  const textWidth = value.length * 6.4;
  const left = (W - (size + 8 + textWidth)) / 2;
  return asset('icon.private-space', left, y - 14, size, 'muted')
    + text(left + size + 8, y, value, 13, color.muted);
}

// ---------------------------------------------------------------------------
// The five states

/// Revoked — Direction A. Names the result, never the cause or the actor.
/// "Unavailable" also covers an access-relation change, which "closed" does
/// not: `state.invite-revoked` is registered to SCR-09, not this screen.
function revoked() {
  let b = header();
  b += statusField(214);
  b += eyebrow(320, 'PRIVATE INVITATION · UNAVAILABLE', color.revoked);
  b += headline(378, ['This invitation is', 'no longer available.']);
  b += body(444, ['No invitation details are shown here.']);
  b += divider(492);
  b += text(W / 2, 542, 'You have not joined anything.', 22, color.primary, {
    weight: 600, anchor: 'middle', tracking: -0.2,
  });
  b += body(578, ['If you need a new invitation, ask the', 'person who shared this link.'], {
    fill: color.muted, size: 14,
  });
  b += primaryButton(664, 'I have another link');
  b += textLink(748, 'Return to private entrance');
  b += footnote(792, 'This link cannot be used to join anything.');
  return page(b);
}

/// Loading — no headline. A resolving surface states nothing, because
/// anything it stated would be a guess about invite truth. No skeleton lines
/// shaped like names: their shape leaks the kind and amount of hidden content.
function loading() {
  let b = header();
  b += statusField(214);
  // A quiet arc on the status circle, not a spinner: the same geometry as the
  // resolved states so the page does not jump when truth arrives.
  b += `<path d="M ${W / 2} 174 A 40 40 0 0 1 ${W / 2 + 40} 214" fill="none" stroke="${color.terracotta}" stroke-width="1.5" stroke-linecap="round" stroke-opacity="0.9"/>`;
  b += eyebrow(320, 'PRIVATE INVITATION');
  b += body(392, ['Checking this invitation…'], { fill: color.secondary });
  b += body(424, ['Nothing is shown until it is confirmed.'], {
    fill: color.muted, size: 14,
  });
  b += footnote(792, 'This page is private until it resolves.');
  return page(b);
}

/// Error — the one state that keeps a live action. The invite token is
/// retained in route state for the retry; it is never rendered.
function error() {
  let b = header();
  b += statusField(214);
  b += eyebrow(320, 'PRIVATE INVITATION · NOT CONFIRMED', color.error);
  b += headline(378, ["We couldn't check", 'this invitation.']);
  b += body(444, ['Nothing has changed, and nothing was sent.']);
  b += divider(492);
  b += body(534, ['This link is still here. Trying again is safe.'], {
    fill: color.muted, size: 14,
  });
  b += primaryButton(664, 'Try again');
  b += textLink(748, 'Return to private entrance');
  b += footnote(792, 'No invitation details were loaded.');
  return page(b);
}

/// Offline — never infers validity. The distinction from `error` is that the
/// person can act on this one: reconnect. So retry is disabled rather than
/// absent, which says the action exists and is not available yet.
function offline() {
  let b = header();
  b += statusField(214);
  b += eyebrow(320, 'PRIVATE INVITATION · OFFLINE');
  b += headline(378, ["You're offline."]);
  b += body(430, ['This invitation cannot be checked', 'without a connection.']);
  b += divider(500);
  b += body(542, ['Its status is unknown, not expired.'], {
    fill: color.muted, size: 14,
  });
  b += primaryButton(664, 'Try again', { disabled: true });
  b += textLink(748, 'Return to private entrance');
  b += footnote(792, 'Nothing is stored on this device.');
  return page(b);
}

/// Authorization loss — Direction A, the account checkpoint.
///
/// Never says "sign in": that is untrue when a valid but ineligible account is
/// already present, and the page must not reveal which account is signed in or
/// whether one is. `state.auth-restored` is deliberately absent — restoration
/// has not happened — and `state.locked` is not in this screen's contract and
/// would read as an accusation.
function authorizationLoss() {
  let b = header();
  b += statusField(214);
  b += eyebrow(320, 'PRIVATE INVITATION · ACCOUNT NEEDED');
  b += headline(378, ['Confirm your account', 'to continue.']);
  b += body(444, ['This invitation is not shown until', 'we know who is looking.']);
  b += divider(508);
  b += body(550, ['Confirming an account does not join anything.'], {
    fill: color.muted, size: 14,
  });
  b += primaryButton(664, 'Confirm account');
  b += textLink(748, 'Use a different account');
  b += footnote(792, 'Nothing here is shared with anyone else.');
  return page(b);
}

const states = [
  ['revoked', 'Revoked', revoked],
  ['loading', 'Loading', loading],
  ['error', 'Error and retry', error],
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
  const cols = 5;
  const tw = 156;
  const th = Math.round((H / W) * tw);
  const cardW = tw + 34;
  const cardH = th + 58;
  const gap = 16;
  const width = 40 + cols * cardW + (cols - 1) * gap;
  const height = 132 + Math.ceil(rendered.length / cols) * (cardH + gap);

  const base = sharp({
    create: {
      width, height, channels: 4,
      background: color.canvas,
    },
  });

  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="80">`
      + text(20, 40, 'SCR-10 · rev-3 · recovery states', 20, color.primary, { weight: 600 })
      + text(20, 64, 'The five states the contract lists as blocked.', 13, color.muted)
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
    .toFile(path.join(referenceRoot, 'scr10-recovery-state-family-board.png'));
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
  process.stdout.write(`SCR-10 recovery rendered · ${rendered.length} states\n`);
  process.stdout.write(`${path.join(referenceRoot, 'scr10-recovery-state-family-board.png')}\n`);
}

main().catch((e) => {
  process.stderr.write(`${e.stack}\n`);
  process.exit(1);
});
