#!/usr/bin/env node

// Renders the SCR-04 / SCR-05 / SCR-06 state family and a review board.
//
// Deterministic and spec-driven: every colour resolves through the frozen
// B-2 tokens, every mark comes from the SVG Freeze registry at a licensed
// size and tone, and the copy comes from the decision record. Nothing here
// is sampled from the raster previews.
//
//   node design/screens/SCR-04-private-entrance/candidates/rev-2/render-entrance.cjs
//
// The three screens share one renderer because they are one composition with
// three arrangements — the same mark, the same descending thread, the same
// lock and footer. Rendering them apart is how the three drift.

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

const outRoot = path.join(root, 'design/screens');
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
  error: token('color.semantic.state.error'),
  terracotta: token('color.primitive.terracotta'),
};

// The freeze names a tone for each mark; these are the tokens those tones
// resolve to on the Ritual canvas. Kept explicit rather than derived from the
// freeze's short names, because the mapping is not mechanical: `authority` is
// Deep Olive, a surface colour that disappears on this canvas, so a mark that
// licenses only `authority` and `primary` takes `primary` here.
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

/// A registered mark, at a size and tone the freeze licenses.
///
/// Throws rather than rendering something plausible: an unlicensed tone is
/// how Terracotta ends up on a lock icon, and a size outside the frozen set
/// is how stroke weight stops matching across screens.
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
  // The freeze names the token for each tone, so this cannot drift from it.
  // `authority` resolves to Deep Olive, which is a surface colour — correct
  // for a mark on the Living canvas, invisible on the Ritual one. The
  // entrance is Ritual, so its marks take `primary`.
  const fill = iconToken(tone);
  const source = fs
    .readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', fill);
  const encoded = Buffer.from(source).toString('base64');
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${encoded}"/>`;
}

/// The thread descending from the mark to a point of light.
///
/// The one piece of pure atmosphere in the composition, and the reason the
/// entrance reads as considered rather than empty. Kept in all three screens.
function thread(x, top, bottom, { glow = true } = {}) {
  // Fades in from nothing rather than starting at full strength: the
  // reference reads as light gathering, and a flat line reads as a border.
  const id = `thread-${Math.round(top)}-${Math.round(bottom)}`;
  let body =
    `<defs><linearGradient id="${id}" x1="0" y1="0" x2="0" y2="1">` +
    `<stop offset="0" stop-color="${color.terracotta}" stop-opacity="0.05"/>` +
    `<stop offset="0.55" stop-color="${color.terracotta}" stop-opacity="0.38"/>` +
    `<stop offset="1" stop-color="${color.terracotta}" stop-opacity="0.9"/>` +
    `</linearGradient></defs>` +
    `<rect x="${x - 0.5}" y="${top}" width="1" height="${bottom - top}" fill="url(#${id})"/>`;
  if (glow) {
    body += `<circle cx="${x}" cy="${bottom}" r="14" fill="${color.terracotta}" fill-opacity="0.07"/>`;
    body += `<circle cx="${x}" cy="${bottom}" r="6" fill="${color.terracotta}" fill-opacity="0.16"/>`;
    body += `<circle cx="${x}" cy="${bottom}" r="1.8" fill="${color.terracotta}" fill-opacity="0.95"/>`;
  }
  return body;
}

function primaryButton(y, label, { disabled = false, busy = false } = {}) {
  const w = W - MARGIN * 2;
  const bg = disabled || busy ? color.actionDisabledBg : color.actionBg;
  const fg = disabled || busy ? color.actionDisabledFg : color.actionFg;
  let body = rect(MARGIN, y, w, 56, bg, 10);
  const label_ = busy ? `${label}…` : label;
  body += text(W / 2, y + 34, label_, 16, fg, { weight: 600, anchor: 'middle', tracking: 0.1 });
  return body;
}

function textLink(y, label, { anchor = 'middle', x = W / 2, size = 13 } = {}) {
  return text(x, y, label, size, color.secondary, { anchor, weight: 500 });
}

/// Label, value, hairline. No box: the canvas holds almost nothing, and a
/// filled field would be the loudest thing on the screen.
function field(y, label, value, o = {}) {
  const { error = null, muted = false, reveal = false } = o;
  const w = W - MARGIN * 2;
  const lineColour = error ? color.error : color.hairline;
  let body = text(MARGIN, y, label, 11, error ? color.error : color.muted, {
    weight: 500, tracking: 1.2,
  });
  body += text(MARGIN, y + 32, value, 16, muted ? color.muted : color.primary);
  if (reveal) {
    body += text(W - MARGIN, y + 32, 'Show', 13, color.muted, { anchor: 'end' });
  }
  body += rect(MARGIN, y + 44, w, 1, lineColour);
  if (error) body += text(MARGIN, y + 64, error, 13, color.error);
  return body;
}

function checkbox(y, label, { checked = false, error = false } = {}) {
  const box = 22;
  let body = rect(MARGIN, y, box, box, 'none', 3, error ? color.error : color.hairline, 1);
  if (checked) {
    body += `<path d="M${MARGIN + 5} ${y + 11} l4 4 l8 -8" stroke="${color.primary}" stroke-width="1.6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  body += text(MARGIN + box + 12, y + 16, label, 14, error ? color.error : color.secondary);
  return body;
}

/// REQ-TRUST-001, on every entrance surface.
///
/// Placed after the primary actions and kept visually quiet: with the
/// category words removed from the rest of the screen, "For adults 18+" is
/// the strongest remaining signal about what this product is, so it must not
/// also be the loudest thing on the page.
function trustFooter(y) {
  let body = asset('state.locked', W / 2 - 10, y, 20, 'muted');
  const lines = [
    'For adults 18+. Use of this service is subject to our Terms.',
    'See how we handle data in our Privacy Policy.',
    'Accounts are private by default.',
  ];
  lines.forEach((l, i) => {
    body += text(W / 2, y + 40 + i * 15, l, 10, color.muted, {
      anchor: 'middle', opacity: 0.72,
    });
  });
  return body;
}

function backArrow() {
  return `<path d="M32 44 l-10 -9 l10 -9" stroke="${color.secondary}" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, color.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// SCR-04 · Private Entrance
// ---------------------------------------------------------------------------

function entrance({ offline = false, opening = false } = {}) {
  let b = text(W / 2, 46, 'Companion', 12, color.muted, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });

  b += asset('mark.authority', W / 2 - 32, 118, 64, 'primary');
  b += thread(W / 2, 194, 358);

  b += text(W / 2, 424, 'A private space,', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += text(W / 2, 466, 'on your terms.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });

  b += text(W / 2, 512, 'Private. Considered. Yours.', 12, color.muted, {
    anchor: 'middle', tracking: 2.6,
  });

  if (offline) {
    b += rect(MARGIN, 556, W - MARGIN * 2, 44, color.actionDisabledBg, 8);
    b += text(W / 2, 583, "You're offline. Connect to continue.", 13, color.secondary, {
      anchor: 'middle',
    });
  }

  b += primaryButton(624, opening ? 'Opening' : 'Continue', { busy: opening });
  b += textLink(704, 'I already have an account');
  b += trustFooter(748);
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-05 · Sign In
// ---------------------------------------------------------------------------

function signIn(o = {}) {
  const {
    mode = 'password', error = null, fieldError = null, busy = false,
    linkSent = false, offline = false, authLoss = false,
  } = o;

  let b = backArrow();
  b += asset('mark.authority', W / 2 - 20, 78, 40, 'primary');

  if (linkSent) {
    b += text(W / 2, 168, 'Check your email', 12, color.muted, {
      anchor: 'middle', weight: 500, tracking: 2.4,
    });
    b += text(W / 2, 224, 'A link is on its way.', 34, color.primary, {
      family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
    });
    b += thread(W / 2, 258, 336, { glow: false });
    [
      'If this email can be used to sign in,',
      "we'll send a link. Check your inbox",
      'and spam folder.',
    ].forEach((l, i) => {
      b += text(W / 2, 392 + i * 22, l, 14, color.secondary, { anchor: 'middle' });
    });
    b += primaryButton(560, 'Resend link');
    b += textLink(640, 'Use a different email');
    b += textLink(676, 'Use password instead');
    b += trustFooter(720);
    return page(b);
  }

  if (!authLoss && !offline) {
    b += text(W / 2, 148, 'Welcome back', 12, color.muted, {
      anchor: 'middle', weight: 500, tracking: 2.4,
    });
  }
  b += text(W / 2, 200, 'Return to your space.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += thread(W / 2, 236, 344, { glow: true });

  // Above the heading, not above the fields: it is context for the screen
  // rather than for one input, and putting it in the form pushed the footer
  // 36dp past the bottom of the viewport.
  if (authLoss || offline) {
    b += rect(MARGIN, 112, W - MARGIN * 2, 38, color.actionDisabledBg, 8);
    b += text(
      W / 2, 136,
      authLoss ? 'Please sign in to continue.' : "You're offline. Connect, then try again.",
      12, color.secondary, { anchor: 'middle' },
    );
  }

  const top = 396;

  if (mode === 'link') {
    b += field(top, 'EMAIL', 'you@example.com', { muted: true });
    [
      "We'll send a one-time sign-in link",
      'to the email you enter.',
    ].forEach((l, i) => {
      b += text(MARGIN, top + 92 + i * 20, l, 13, color.muted);
    });
    b += primaryButton(top + 168, busy ? 'Sending link' : 'Send sign-in link', { busy });
    b += textLink(top + 248, 'Use password instead');
    b += trustFooter(top + 292);
    return page(b);
  }

  b += field(top, 'EMAIL', 'you@example.com', {
    muted: !fieldError,
    error: fieldError === 'email' ? 'Enter a valid email address.' : null,
  });
  const pwTop = top + (fieldError === 'email' ? 108 : 84);
  b += field(pwTop, 'PASSWORD', '••••••••', { reveal: true });

  const errTop = pwTop + 76;
  if (error) {
    b += text(MARGIN, errTop, error, 13, color.error);
  }

  const buttonTop = error ? errTop + 44 : errTop + 16;
  b += primaryButton(buttonTop, busy ? 'Signing in' : 'Sign in', { busy });
  b += textLink(buttonTop + 80, 'Use an email sign-in link');
  b += textLink(buttonTop + 116, 'Create an account');
  b += trustFooter(buttonTop + 156);
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-06 · Create Account
// ---------------------------------------------------------------------------

function createAccount(o = {}) {
  const {
    ageChecked = false, ageError = false, fieldError = null,
    busy = false, uncertain = false, offline = false,
  } = o;

  let b = backArrow();
  b += asset('mark.authority', W / 2 - 16, 66, 32, 'primary');
  b += text(W / 2, 136, 'Create an account', 12, color.muted, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });
  b += text(W / 2, 188, 'Begin privately.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += thread(W / 2, 214, 296, { glow: true });

  let y = 330;
  if (uncertain || offline) {
    b += rect(MARGIN, 310, W - MARGIN * 2, offline ? 44 : 62, color.actionDisabledBg, 8);
    if (offline) {
      b += text(W / 2, 337, "You're offline. Connect, then try again.", 13, color.secondary, {
        anchor: 'middle',
      });
      y = 380;
    } else {
      [
        "We couldn't confirm whether the account was",
        'created. Try signing in before creating it again.',
      ].forEach((l, i) => {
        b += text(W / 2, 330 + i * 17, l, 12, color.secondary, { anchor: 'middle' });
      });
      y = 374;
    }
  }

  b += field(y, 'EMAIL', 'you@example.com', {
    muted: !fieldError,
    error: fieldError === 'email' ? 'Enter a valid email address.' : null,
  });
  const pwTop = y + (fieldError === 'email' ? 108 : 84);
  b += field(pwTop, 'CREATE PASSWORD', '10–256 characters', {
    muted: true,
    reveal: true,
    error: fieldError === 'password' ? 'Use at least 10 characters.' : null,
  });

  const cbTop = pwTop + (fieldError === 'password' ? 96 : 76);
  b += checkbox(cbTop, 'I confirm that I am 18 or older.', {
    checked: ageChecked, error: ageError,
  });
  if (ageError) {
    b += text(MARGIN, cbTop + 46, 'Confirm that you are 18 or older to create an account.', 12, color.error);
  }

  const buttonTop = cbTop + (ageError ? 68 : 46);
  b += primaryButton(buttonTop, busy ? 'Creating account' : 'Create account', { busy });
  b += text(W / 2, buttonTop + 82, 'By creating an account, you agree to the Terms', 11, color.muted, {
    anchor: 'middle', opacity: 0.8,
  });
  b += text(W / 2, buttonTop + 98, 'and acknowledge the Privacy Policy.', 11, color.muted, {
    anchor: 'middle', opacity: 0.8,
  });
  b += textLink(buttonTop + 132, 'Already have an account? Sign in');
  b += trustFooter(buttonTop + 168);
  return page(b);
}

// ---------------------------------------------------------------------------

const screens = [
  {
    id: 'SCR-04', dir: 'SCR-04-private-entrance', name: 'Private Entrance',
    states: [
      ['default', 'DEFAULT', () => entrance()],
      ['opening', 'OPENING', () => entrance({ opening: true })],
      ['offline', 'OFFLINE', () => entrance({ offline: true })],
    ],
  },
  {
    id: 'SCR-05', dir: 'SCR-05-sign-in', name: 'Sign In',
    states: [
      ['default', 'DEFAULT', () => signIn()],
      ['busy', 'SIGNING IN', () => signIn({ busy: true })],
      ['error', 'REFUSED', () => signIn({
        error: "We couldn't sign you in with those details.",
      })],
      ['field-error', 'FIELD ERROR', () => signIn({ fieldError: 'email' })],
      ['link-mode', 'EMAIL LINK', () => signIn({ mode: 'link' })],
      ['link-sent', 'LINK SENT', () => signIn({ linkSent: true })],
      ['offline', 'OFFLINE', () => signIn({ offline: true })],
      ['authorization-loss', 'AUTH LOSS', () => signIn({ authLoss: true })],
    ],
  },
  {
    id: 'SCR-06', dir: 'SCR-06-create-account', name: 'Create Account',
    states: [
      ['default', 'DEFAULT', () => createAccount()],
      ['ready', 'AGE CONFIRMED', () => createAccount({ ageChecked: true })],
      ['busy', 'CREATING', () => createAccount({ ageChecked: true, busy: true })],
      ['age-error', 'AGE NOT CONFIRMED', () => createAccount({ ageError: true })],
      ['password-error', 'PASSWORD TOO SHORT', () => createAccount({
        ageChecked: true, fieldError: 'password',
      })],
      ['uncertain', 'RESULT UNCERTAIN', () => createAccount({
        ageChecked: true, uncertain: true,
      })],
      ['offline', 'OFFLINE', () => createAccount({ ageChecked: true, offline: true })],
    ],
  },
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
  const cols = 6;
  const tw = 150;
  const th = Math.round((H / W) * tw);
  const cardW = tw + 34;
  const cardH = th + 62;
  const gap = 16;
  const rows = Math.ceil(rendered.length / cols);
  const width = 40 + cols * (cardW + gap);
  const height = 96 + rows * (cardH + gap);

  const base = sharp({
    create: { width, height, channels: 4, background: color.canvas },
  });
  const composites = [];
  const title = Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="70">` +
    text(32, 44, 'Entrance state family · SCR-04 / 05 / 06 · candidate rev-2', 20, color.primary, { weight: 600 }) +
    '</svg>',
  );
  composites.push({ input: title, left: 0, top: 12 });

  for (let i = 0; i < rendered.length; i += 1) {
    const e = rendered[i];
    const x = 20 + (i % cols) * (cardW + gap);
    const y = 92 + Math.floor(i / cols) * (cardH + gap);
    const card = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${cardW}" height="${cardH}">` +
      rect(0, 0, cardW, cardH, color.actionDisabledBg, 12, color.hairline, 1) +
      text(cardW / 2, cardH - 26, e.screen, 9, color.muted, { anchor: 'middle', weight: 600, tracking: 1 }) +
      text(cardW / 2, cardH - 12, e.label, 9, color.secondary, { anchor: 'middle', weight: 600, tracking: 1 }) +
      '</svg>',
    );
    const thumb = await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer();
    composites.push({ input: card, left: x, top: y });
    composites.push({ input: thumb, left: x + 17, top: y + 16 });
  }

  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'entrance-state-family-board.png'));
}

async function main() {
  // A render in the wrong typeface looks fine and is wrong. Stop instead.
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];

  for (const screen of screens) {
    for (const [key, label, build] of screen.states) {
      const dir = key === 'default'
        ? path.join(outRoot, screen.dir, 'candidates/rev-2')
        : path.join(outRoot, screen.dir, 'candidates/rev-2/states', key);
      await write(build(), dir);
      rendered.push({
        screen: screen.id,
        key,
        label,
        preview: path.join(dir, 'preview.webp'),
      });
    }
  }

  await board(rendered);

  const report = {
    candidate_id: 'ENTRANCE-REV-2',
    generated_at: new Date().toISOString(),
    result: 'pass',
    viewport: { width: W, height: H },
    source_scale: SCALE,
    copy_decision: 'product/decisions/d8-entrance-copy.md',
    state_family: 'product/decisions/entrance-state-family.md',
    tokens: tokenSource.meta.freezeId,
    svg_freeze: freeze.freeze_id,
    states: rendered.map((r) => ({
      screen: r.screen,
      key: r.key,
      preview: path.relative(root, r.preview),
    })),
    board: 'design/qa/reference/entrance-state-family-board.png',
    build_gate: 'unchanged — these are candidates, not approvals',
  };
  fs.writeFileSync(
    path.join(referenceRoot, 'entrance-state-family-validation.json'),
    `${JSON.stringify(report, null, 2)}\n`,
  );

  process.stdout.write(
    `Entrance rendered · ${rendered.length} states across 3 screens\n` +
    `${path.join(referenceRoot, 'entrance-state-family-board.png')}\n`,
  );
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
