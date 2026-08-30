#!/usr/bin/env node

// Renders the SCR-02 / SCR-33 / SCR-03 state family and a review board.
//
//   node design/screens/SCR-02-task-completion/candidates/rev-3/render-loop.cjs
//
// One renderer for the three screens because they are one moment seen three
// times: something was completed, someone responded, the response arrived.
// The visual thread — the emblem, the descending line, Terracotta reserved
// for what a human said — has to hold across all three or the loop stops
// reading as a loop.
//
// Behaviour comes from product/decisions/core-loop-state-family.md; the
// conflict codes in it were measured against a running server.

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
  disabledBg: token('color.semantic.action.primary.disabledBackground'),
  disabledFg: token('color.semantic.action.primary.disabledForeground'),
  error: token('color.semantic.state.error'),
  // Terracotta, and only for what a human said or is waiting on. The freeze
  // licenses it as the `relationship` tone; the type scale restricts it to
  // 24sp regular or larger, which is why partner words are Cormorant here.
  relationship: token('color.semantic.text.onRitual.relationshipLarge'),
  waiting: token('color.semantic.state.waiting'),
  completed: token('color.semantic.state.completed'),
  raised: token('color.semantic.surface.ritual.raised'),
};

const toneToken = {
  primary: 'color.semantic.icon.primary',
  muted: 'color.semantic.icon.muted',
  relationship: 'color.semantic.icon.relationship',
  decorative: 'color.semantic.decorative.botanical',
};

function esc(v) {
  return String(v).replace(/[<>&'"]/g, (c) => ({
    '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;',
  })[c]);
}

function text(x, y, value, size, fill, o = {}) {
  const { family = 'Inter', weight = 400, tracking = 0, anchor = 'start', opacity = 1 } = o;
  return `<text x="${x}" y="${y}" fill="${fill}" fill-opacity="${opacity}" font-family="${family}" font-size="${size}" font-weight="${weight}" letter-spacing="${tracking}" text-anchor="${anchor}">${esc(value)}</text>`;
}

function rect(x, y, w, h, fill, r = 0, stroke = 'none', sw = 0, opacity = 1) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" fill-opacity="${opacity}" stroke="${stroke}" stroke-width="${sw}"/>`;
}

/// A registered mark at a size and tone the freeze licenses.
///
/// Throws rather than rendering something plausible. The tone licences carry
/// product meaning here: `state.completed` may not take the relationship
/// tone, because completion is not warmth from a partner.
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
  const named = toneToken[tone];
  if (!named) throw new Error(`Unknown tone: ${tone}`);
  const source = fs
    .readFileSync(path.join(root, registered.source_path), 'utf8')
    .replaceAll('currentColor', token(named));
  return `<image x="${x}" y="${y}" width="${size}" height="${size}" preserveAspectRatio="xMidYMid meet" href="data:image/svg+xml;base64,${Buffer.from(source).toString('base64')}"/>`;
}

/// The descending thread, carried over from the entrance.
function thread(x, top, bottom, { glow = false } = {}) {
  const id = `t${Math.round(top)}${Math.round(bottom)}`;
  let b =
    `<defs><linearGradient id="${id}" x1="0" y1="0" x2="0" y2="1">` +
    `<stop offset="0" stop-color="${color.relationship}" stop-opacity="0.06"/>` +
    `<stop offset="0.6" stop-color="${color.relationship}" stop-opacity="0.3"/>` +
    `<stop offset="1" stop-color="${color.relationship}" stop-opacity="${glow ? 0.85 : 0.22}"/>` +
    `</linearGradient></defs>` +
    `<rect x="${x - 0.5}" y="${top}" width="1" height="${bottom - top}" fill="url(#${id})"/>`;
  if (glow) {
    b += `<circle cx="${x}" cy="${bottom}" r="10" fill="${color.relationship}" fill-opacity="0.08"/>`;
    b += `<circle cx="${x}" cy="${bottom}" r="2" fill="${color.relationship}" fill-opacity="0.9"/>`;
  }
  return b;
}

function header(title, presence) {
  let b = text(M, 40, title, 22, color.primary, { weight: 600 });
  if (presence) {
    b += asset('mark.presence', 236, 20, 24, 'relationship');
    b += text(268, 38, presence, 12, color.relationship);
  }
  return b;
}

function nav() {
  const items = [
    ['nav.today', 'Today', 49, true], ['nav.dynamic', 'Dynamic', 147, false],
    ['nav.explore', 'Explore', 245, false], ['nav.us', 'Us', 341, false],
  ];
  let b = rect(0, 764, W, 80, color.canvas) +
    rect(20, 764, 350, 1, color.hairline);
  for (const [id, label, cx, active] of items) {
    b += asset(id, cx - 12, 776, 24, active ? 'primary' : 'muted');
    b += text(cx, 820, label, 11, active ? color.primary : color.muted, {
      weight: 500, anchor: 'middle',
    });
  }
  return b;
}

function primary(y, label, o = {}) {
  const { busy = false, disabled = false } = o;
  const off = busy || disabled;
  return rect(M, y, W - M * 2, 56, off ? color.disabledBg : color.actionBg, 10) +
    text(W / 2, y + 34, busy ? `${label}…` : label, 16,
      off ? color.disabledFg : color.actionFg,
      { weight: 600, anchor: 'middle' });
}

function banner(y, message, { tone = 'muted' } = {}) {
  return rect(M, y, W - M * 2, 44, color.disabledBg, 8) +
    text(W / 2, y + 27, message, 12,
      tone === 'error' ? color.error : color.secondary, { anchor: 'middle' });
}

function page(body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">${rect(0, 0, W, H, color.canvas)}${body}</svg>`;
}

// ---------------------------------------------------------------------------
// SCR-02 · Completion, and waiting for a human response
// ---------------------------------------------------------------------------

/// Two nodes, and the second one only fills when a person answers.
///
/// This is the whole difference between this product and a checklist:
/// completion is not acknowledgement, and the geometry says so before any
/// copy does (REQ-COMPLETE-001).
function progress(y, { answered = false, partner = 'Morgan' }) {
  const left = 88;
  const right = W - 88;
  let b = rect(left, y + 11, right - left, 1, color.hairline);
  b += `<circle cx="${left}" cy="${y + 11}" r="9" fill="none" stroke="${color.completed}" stroke-width="1.5"/>`;
  b += `<circle cx="${left}" cy="${y + 11}" r="4" fill="${color.completed}"/>`;
  b += `<circle cx="${right}" cy="${y + 11}" r="9" fill="none" stroke="${answered ? color.relationship : color.waiting}" stroke-width="1.5"/>`;
  if (answered) {
    b += `<circle cx="${right}" cy="${y + 11}" r="4" fill="${color.relationship}"/>`;
  }
  b += text(left, y + 40, 'COMPLETED', 10, color.muted, { tracking: 1.4, anchor: 'middle' });
  b += text(right, y + 40,
    answered ? `${partner.toUpperCase()} REPLIED` : `WAITING FOR ${partner.toUpperCase()}`,
    10, answered ? color.relationship : color.waiting,
    { tracking: 1.4, anchor: 'middle' });
  return b;
}

function completion(o = {}) {
  const {
    busy = false, error = null, offline = false, answered = false,
    alreadyDone = false, note = 'I felt calm and focused.',
  } = o;

  let b = header('Evening ritual', answered ? 'Morgan replied' : 'Morgan will respond');
  b += asset('emblem.ritual.evening', W / 2 - 24, 74, 48, 'muted');
  b += text(W / 2, 148, 'EVENING RITUAL', 10, color.muted, { tracking: 2.4, anchor: 'middle' });
  b += thread(W / 2, 168, 236);

  const headline = alreadyDone ? 'Already recorded.' : 'Your service\nis recorded.';
  headline.split('\n').forEach((line, i) => {
    b += text(W / 2, 292 + i * 42, line, 34, color.primary, {
      family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
    });
  });
  b += text(W / 2, 366, 'COMPLETED AT 9:14 PM', 10, color.muted,
    { tracking: 1.8, anchor: 'middle' });

  b += progress(396, { answered });

  if (alreadyDone) {
    // Another device got there first. Not an error — ordinary two-device life.
    b += text(W / 2, 476, 'You recorded this on another device.', 14,
      color.secondary, { anchor: 'middle' });
  } else if (answered) {
    b += text(W / 2, 476, 'Morgan has responded.', 14, color.secondary, { anchor: 'middle' });
  } else {
    ['Your part is complete.', "Morgan's acknowledgement", 'will appear here.']
      .forEach((l, i) => {
        b += text(W / 2, 476 + i * 22, l, 14, color.secondary, { anchor: 'middle' });
      });
  }

  if (error) b += banner(552, error, { tone: 'error' });
  else if (offline) b += banner(552, "You're offline. Connect, then try again.");

  const noteTop = error || offline ? 610 : 556;
  if (!answered && !alreadyDone) {
    b += text(M + 8, noteTop, 'PRIVATE NOTE · ONLY YOU', 9, color.muted, { tracking: 1.6 });
    b += rect(M, noteTop + 10, W - M * 2, 56, color.raised, 8, color.hairline, 1);
    b += asset('motif.botanical.note-sprig', M + 12, noteTop + 26, 24, 'decorative');
    b += text(M + 46, noteTop + 44, note, 14, color.secondary);
  }

  b += primary(688, busy ? 'Recording' : 'Return to Today', { busy });
  b += nav();
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-33 · The composer
// ---------------------------------------------------------------------------

const RESPONSES = [
  ['response.acknowledge', 'Acknowledge'],
  ['response.praise', 'Praise'],
  ['response.comment', 'Comment'],
  ['response.review', 'Review'],
];

function composer(o = {}) {
  const {
    selected = 1, words = '', busy = false, error = null, offline = false,
    needsWords = false, alreadyAnswered = false, suggestion = true,
  } = o;

  let b = header('Attention', 'Morgan is present');
  b += asset('emblem.ritual.evening', W / 2 - 24, 72, 48, 'muted');
  b += text(W / 2, 146, 'EVENING RITUAL', 10, color.muted, { tracking: 2.4, anchor: 'middle' });
  b += thread(W / 2, 164, 232, { glow: true });

  ['Morgan completed', 'this at 9:14 PM.'].forEach((l, i) => {
    b += text(W / 2, 272 + i * 34, l, 27, color.primary, {
      family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
    });
  });

  if (alreadyAnswered) {
    // 409 OCCURRENCE_NOT_WAITING_ACK. Someone already responded, possibly on
    // another device. Showing what was sent beats reporting a failure.
    b += rect(0, 372, W, H - 372, color.raised);
    b += rect(0, 372, W, 1, color.hairline);
    b += text(M, 410, 'Already answered', 17, color.primary, { weight: 600 });
    b += text(M, 446, 'This was answered from another device.', 14, color.secondary);
    ['I noticed your care and', 'intention tonight.'].forEach((l, i) => {
      b += text(W / 2, 512 + i * 32, l, 22, color.relationship, {
        family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
      });
    });
    b += text(W / 2, 578, 'SENT AT 9:26 PM', 10, color.muted, { tracking: 1.8, anchor: 'middle' });
    b += primary(660, 'Close');
    return page(b);
  }

  b += rect(0, 372, W, H - 372, color.raised);
  b += rect(0, 372, W, 1, color.hairline);
  b += text(M, 410, 'Respond to Morgan', 17, color.primary, { weight: 600 });

  RESPONSES.forEach(([id, label], i) => {
    const cx = 62 + i * 90;
    const on = i === selected;
    b += `<circle cx="${cx}" cy="${462}" r="22" fill="none" stroke="${on ? color.relationship : color.hairline}" stroke-width="${on ? 1.4 : 1}"/>`;
    b += asset(id, cx - 12, 450, 24, on ? 'relationship' : 'muted');
    b += text(cx, 500, label, 10, on ? color.relationship : color.muted,
      { anchor: 'middle', weight: on ? 600 : 400 });
    if (on) b += rect(cx - 14, 510, 28, 1, color.relationship);
  });

  b += text(M, 542, 'YOUR WORDS', 9, needsWords ? color.error : color.muted, { tracking: 1.6 });
  b += rect(M, 552, W - M * 2, 62, color.canvas, 8,
    needsWords ? color.error : color.hairline, 1);
  if (words) {
    b += text(M + 12, 582, words, 14, color.primary);
  } else if (selected >= 2) {
    b += text(M + 12, 582, 'Say what you noticed…', 14, color.muted);
  }

  if (needsWords) {
    b += text(M, 634, 'A comment needs your words.', 12, color.error);
  } else if (suggestion) {
    // A chip, outside the field. Tapping adopts it; nothing is pre-filled.
    //
    // The approved candidate shows this prose already inside the text area.
    // Being able to edit it is not the same as having chosen it, and Send
    // would then read as agreement to the system's wording — which red
    // line #2 exists to prevent. The screen's own contract already requires
    // suggestions to stay "visibly system-provided and visually subordinate
    // until an explicit send". This is that, drawn.
    b += rect(M, 626, 250, 30, color.canvas, 15, color.hairline, 1);
    b += text(M + 14, 645, 'Suggest: “I noticed your care”', 11, color.muted);
    b += text(M, 676, 'Suggestions are private until you send.', 10, color.muted);
  }

  if (error) b += banner(628, error, { tone: 'error' });
  else if (offline) b += banner(628, "You're offline. Connect, then try again.");

  b += primary(696, busy ? 'Sending' : 'Send to Morgan', { busy });
  b += text(W / 2, 792, 'Not now', 13, color.secondary, { anchor: 'middle', weight: 500 });
  return page(b);
}

// ---------------------------------------------------------------------------
// SCR-03 · The response arrives
// ---------------------------------------------------------------------------

function received(o = {}) {
  const { wordless = false, loading = false, error = null, offline = false } = o;

  let b = header('Acknowledgement', loading || error ? null : 'Morgan is present');

  if (loading) {
    b += asset('emblem.ritual.evening', W / 2 - 24, 96, 48, 'muted');
    [[110, 300, 170], [95, 348, 200], [70, 396, 140]].forEach(([x, y, w]) => {
      b += rect(x, y, w, 14, color.raised, 7);
    });
    b += nav();
    return page(b);
  }

  if (error) {
    b += text(W / 2, 380, "We couldn't load this.", 22, color.primary,
      { family: 'Cormorant Garamond', weight: 500, anchor: 'middle' });
    b += text(W / 2, 414, 'Try again in a moment.', 14, color.secondary, { anchor: 'middle' });
    b += primary(480, 'Try again');
    b += nav();
    return page(b);
  }

  b += asset('emblem.ritual.evening', W / 2 - 24, 96, 48, 'muted');
  b += text(W / 2, 190, 'EVENING RITUAL', 10, color.muted, { tracking: 2.4, anchor: 'middle' });
  b += thread(W / 2, 210, 320);

  b += text(W / 2, 348, 'You are seen.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += thread(W / 2, 372, 452, { glow: true });

  if (wordless) {
    // An acknowledgement with no words. Rendered as a neutral statement of
    // what happened — never quoted, never given invented wording, because
    // the system may not speak in a partner's voice (red line #2).
    b += asset('state.acknowledged', W / 2 - 16, 492, 32, 'relationship');
    b += text(W / 2, 556, 'Morgan acknowledged this.', 16, color.secondary,
      { anchor: 'middle' });
  } else {
    // Their words, in Terracotta Cormorant: visually distinct from every
    // system line on the screen (REQ-ACK-001), and above the 24sp floor the
    // token freeze sets for Terracotta text.
    ['I noticed your care and', 'intention tonight.'].forEach((l, i) => {
      b += text(W / 2, 512 + i * 36, l, 24, color.relationship, {
        family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
      });
    });
  }

  b += text(W / 2, 610, 'RECEIVED AT 9:26 PM', 10, color.muted,
    { tracking: 1.8, anchor: 'middle' });

  if (offline) {
    // Their words already arrived and are already on this device. Hiding them
    // would lose a human response the person has every right to keep reading —
    // the opposite of what offline should protect. What is withheld is any
    // claim that this is still the latest state.
    b += banner(632, "You're offline — this is the last confirmed response.");
    b += primary(692, 'Close ritual');
  } else {
    b += primary(668, 'Close ritual');
  }
  b += nav();
  return page(b);
}

// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// The recovery states REQ-RECOVERY-001 requires and rev-3 had not yet drawn:
// authorization loss on all three screens, loading on SCR-02 and SCR-33, and
// offline on SCR-03.
//
// None of these three screens registers a lock mark, so authorization loss is
// carried by geometry — an empty outlined circle where the screen's own mark
// would sit — rather than by an icon borrowed from another screen's contract.

/// Authorization loss, shared by all three core-loop screens.
///
/// It withholds the relationship entirely: no partner name, no expectation
/// title, no note, no navigation. This is the one place in the loop where the
/// person may not be who the session says they are, and the loop's content is
/// exactly what must not leak. No `nav()`: the tabs name the product's
/// surfaces, which is itself something to withhold on a shared device.
function authLoss(where) {
  let b = text(W / 2, 40, 'PRIVATE', 12, color.muted, {
    anchor: 'middle', weight: 500, tracking: 2.4,
  });
  b += `<circle cx="${W / 2}" cy="238" r="40" fill="none" stroke="${color.hairline}" stroke-width="1"/>`;
  b += text(W / 2, 344, 'Sign in to continue.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500, anchor: 'middle',
  });
  b += text(W / 2, 386, 'Your private space is hidden.', 15, color.secondary, {
    anchor: 'middle',
  });
  b += text(W / 2, 412, `Sign in again to return to ${where}.`, 13, color.muted, {
    anchor: 'middle',
  });
  b += primary(486, 'Sign in');
  b += text(W / 2, 580, 'No relationship details are shown on this screen.', 12,
    color.muted, { anchor: 'middle' });
  return page(b);
}

/// SCR-02 loading. The two-node progress is the screen's whole argument, so it
/// holds its geometry with neither node filled — the same reasoning as SCR-09's
/// lifecycle track. A filled first node would claim the completion landed.
function completionLoading() {
  let b = header('Evening ritual', null);
  b += text(M, 128, 'CHECKING', 11, color.muted, { tracking: 2.4, weight: 500 });
  b += text(M, 188, 'Confirming where', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M, 230, 'this stands.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  const left = 88;
  const right = W - 88;
  b += rect(left, 331, right - left, 1, color.hairline);
  b += `<circle cx="${left}" cy="331" r="9" fill="none" stroke="${color.hairline}" stroke-width="1.5"/>`;
  b += `<circle cx="${right}" cy="331" r="9" fill="none" stroke="${color.hairline}" stroke-width="1.5"/>`;
  b += text(left, 360, 'COMPLETED', 10, color.muted, { tracking: 1.4, anchor: 'middle' });
  b += text(right, 360, 'RESPONSE', 10, color.muted, { tracking: 1.4, anchor: 'middle' });
  b += text(M, 428, 'Nothing is shown until the server confirms it.', 14, color.muted);
  b += nav();
  return page(b);
}

/// SCR-33 loading. The composer withholds its four response paths until the
/// occurrence is confirmed: offering Acknowledge before knowing the state is
/// how a person sends into a moment that has already been answered.
function composerLoading() {
  let b = header('Respond', null);
  b += text(M, 128, 'CHECKING', 11, color.muted, { tracking: 2.4, weight: 500 });
  b += text(M, 188, 'Opening this', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M, 230, 'moment.', 34, color.primary, {
    family: 'Cormorant Garamond', weight: 500,
  });
  b += text(M, 300, 'Your response options appear once it is confirmed.', 14, color.muted);
  b += rect(M, 344, W - M * 2, 1, color.hairline);
  b += primary(560, 'Send', { disabled: true });
  return page(b);
}


const screens = [
  {
    id: 'SCR-02', dir: 'SCR-02-task-completion', states: [
      ['default', 'WAITING', () => completion()],
      ['busy', 'RECORDING', () => completion({ busy: true })],
      ['error', 'RETRY', () => completion({ error: "Couldn't record that. Try again." })],
      ['offline', 'OFFLINE', () => completion({ offline: true })],
      ['already-completed', 'ALREADY DONE', () => completion({ alreadyDone: true })],
      ['answered', 'PARTNER REPLIED', () => completion({ answered: true })],
      ['loading', 'CHECKING', () => completionLoading()],
      ['authorization-loss', 'SIGN IN AGAIN', () => authLoss('Today')],
    ],
  },
  {
    id: 'SCR-33', dir: 'SCR-33-acknowledgement-composer', states: [
      ['default', 'TWO TAPS', () => composer({ selected: 0, suggestion: false })],
      ['praise', 'PRAISE SELECTED', () => composer({ selected: 1 })],
      ['words', 'WITH WORDS', () => composer({
        selected: 2, words: 'I noticed your care tonight.', suggestion: false,
      })],
      ['needs-words', 'COMMENT, NO WORDS', () => composer({
        selected: 2, needsWords: true, suggestion: false,
      })],
      ['busy', 'SENDING', () => composer({ selected: 1, busy: true, suggestion: false })],
      ['error', 'RETRY', () => composer({
        selected: 1, error: "Couldn't send that. Try again.", suggestion: false,
      })],
      ['offline', 'OFFLINE', () => composer({ selected: 1, offline: true, suggestion: false })],
      ['already-answered', 'ALREADY ANSWERED', () => composer({ alreadyAnswered: true })],
      ['loading', 'CHECKING', () => composerLoading()],
      ['authorization-loss', 'SIGN IN AGAIN', () => authLoss('your response')],
    ],
  },
  {
    id: 'SCR-03', dir: 'SCR-03-partner-acknowledgement', states: [
      ['default', 'THEIR WORDS', () => received()],
      ['wordless', 'WORDLESS', () => received({ wordless: true })],
      ['loading', 'LOADING', () => received({ loading: true })],
      ['error', 'RETRY', () => received({ error: true })],
      ['offline', 'OFFLINE', () => received({ offline: true })],
      ['authorization-loss', 'SIGN IN AGAIN', () => authLoss('their response')],
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

  const base = sharp({ create: { width, height, channels: 4, background: color.canvas } });
  const composites = [{
    input: Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="70">` +
      text(32, 44, 'Core loop · SCR-02 / 33 / 03 · candidate rev-3', 20, color.primary, { weight: 600 }) +
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
        rect(0, 0, cw, ch, color.disabledBg, 12, color.hairline, 1) +
        text(cw / 2, ch - 26, e.screen, 9, color.muted, { anchor: 'middle', weight: 600, tracking: 1 }) +
        text(cw / 2, ch - 12, e.label, 9, color.secondary, { anchor: 'middle', weight: 600, tracking: 1 }) +
        '</svg>'),
      left: x, top: y,
    });
    composites.push({
      input: await sharp(e.preview).resize(tw, th, { fit: 'fill' }).png().toBuffer(),
      left: x + 17, top: y + 16,
    });
  }

  await base.composite(composites).png()
    .toFile(path.join(referenceRoot, 'core-loop-state-family-board.png'));
}

async function main() {
  await fonts.assertDisplayFaceResolves(sharp);
  fs.mkdirSync(referenceRoot, { recursive: true });
  const rendered = [];

  for (const screen of screens) {
    for (const [key, label, build] of screen.states) {
      const dir = key === 'default'
        ? path.join(outRoot, screen.dir, 'candidates/rev-3')
        : path.join(outRoot, screen.dir, 'candidates/rev-3/states', key);
      await write(build(), dir);
      rendered.push({ screen: screen.id, key, label, preview: path.join(dir, 'preview.webp') });
    }
  }

  await board(rendered);

  fs.writeFileSync(
    path.join(referenceRoot, 'core-loop-state-family-validation.json'),
    `${JSON.stringify({
      candidate_id: 'CORE-LOOP-REV-3',
      generated_at: new Date().toISOString(),
      result: 'pass',
      viewport: { width: W, height: H },
      source_scale: SCALE,
      state_family: 'product/decisions/core-loop-state-family.md',
      tokens: tokenSource.meta.freezeId,
      svg_freeze: freeze.freeze_id,
      states: rendered.map((r) => ({
        screen: r.screen, key: r.key, preview: path.relative(root, r.preview),
      })),
      board: 'design/qa/reference/core-loop-state-family-board.png',
      build_gate: 'unchanged — these are candidates, not approvals',
    }, null, 2)}\n`,
  );

  process.stdout.write(
    `Core loop rendered · ${rendered.length} states across 3 screens\n` +
    `${path.join(referenceRoot, 'core-loop-state-family-board.png')}\n`,
  );
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
