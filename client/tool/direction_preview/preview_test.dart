// Renders the three candidate directions as real screens so they can be
// judged side by side. Not part of the suite — a decision aid.
//
//   flutter test --update-goldens tool/direction_preview/preview_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = 'docs/screenshots/directions';

Future<void> loadFonts() async {
  for (final e in {
    'Lora': 'assets/fonts/Lora-Variable.ttf',
    'Inter': 'assets/fonts/Inter-Variable.ttf',
  }.entries) {
    final l = FontLoader(e.key)
      ..addFont(File(e.value).readAsBytes().then((b) => b.buffer.asByteData()));
    await l.load();
  }
}

void main() {
  setUpAll(loadFonts);

  Future<void> shoot(WidgetTester t, String name, Widget child) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3.0;
    addTearDown(() async {
      await t.binding.setSurfaceSize(null);
      t.view.reset();
    });
    await t.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: child),
    ));
    await t.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('../../$_out/$name.png'));
  }

  // ── 02 · Across — alignment encodes whose move it is ────────────
  testWidgets('across', (t) async {
    await shoot(t, '02-across', const _Across());
  });

  // ── 03 · Register — one continuous chronology ───────────────────
  testWidgets('register', (t) async {
    await shoot(t, '03-register', const _Register());
  });

  // ── 04 · Still — one moment on a stage ──────────────────────────
  testWidgets('still', (t) async {
    await shoot(t, '04-still', const _Still());
  });
}

// ═══════════════════════════════════════════════════════════════════
// 02 · ACROSS / TWO EDGES
// Content sits on the edge belonging to whoever must act. A received
// response is the only thing allowed to cross the quiet gutter.
class _Across extends StatelessWidget {
  const _Across();

  static const canvas = Color(0xFFF5F7F6);
  static const ink = Color(0xFF16201C);
  static const muted = Color(0xFF6E7974);
  static const line = Color(0xFFC9D0CD);
  static const leftField = Color(0xFFE4EBE7);
  static const accent = Color(0xFF008A63);
  static const humanInk = Color(0xFF005C48);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: canvas,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Today',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 22,
                        fontWeight: FontWeight.w700, color: ink)),
                const SizedBox(height: 32),

                // Crossing — begins at Alex's edge, ends at yours.
                const Text('ALEX · 8:06 PM',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        letterSpacing: 1.1, color: muted)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Text('I noticed the care\nyou put into this.',
                        style: const TextStyle(
                            fontFamily: 'Lora', fontSize: 27, height: 1.28,
                            color: humanInk)),
                  ),
                ]),
                const SizedBox(height: 8),
                // The one square that exists nowhere else.
                Row(children: [
                  const Spacer(),
                  Container(width: 12, height: 12, color: accent),
                  const SizedBox(width: 6),
                ]),

                const SizedBox(height: 40),
                // Yours to act on — right edge.
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 274,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('2 need your response',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 19,
                                fontWeight: FontWeight.w600, color: ink)),
                        const SizedBox(height: 6),
                        const Text('WAITING ON YOU',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                letterSpacing: 1.1, color: muted)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                // Asked of you — left edge, with its shallow band.
                Container(
                  width: 274,
                  color: leftField,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FROM ALEX · TODAY',
                          style: TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              letterSpacing: 1.1, color: muted)),
                      SizedBox(height: 6),
                      Text('Evening check-in message',
                          style: TextStyle(
                              fontFamily: 'Inter', fontSize: 19,
                              fontWeight: FontWeight.w600, color: ink)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 274,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Tidy the entryway',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 19,
                                fontWeight: FontWeight.w600, color: ink)),
                        const SizedBox(height: 6),
                        const Text('WAITING FOR ALEX',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                letterSpacing: 1.1, color: muted)),
                        const SizedBox(height: 12),
                        Container(height: 1, width: 274, color: line),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final (label, on)
                        in [('Today', true), ('Dynamic', false),
                            ('Explore', false), ('Us', false)])
                      Column(children: [
                        Text(label,
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12,
                                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                                color: on ? ink : muted)),
                        const SizedBox(height: 4),
                        Container(
                            height: 2, width: 20,
                            color: on ? accent : Colors.transparent),
                      ]),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// 03 · REGISTER / TIME CUTS
// One continuous chronology. Rules stop where a person's words begin.
class _Register extends StatelessWidget {
  const _Register();

  static const canvas = Color(0xFFEEF1F2);
  static const paper = Color(0xFFFAFBFB);
  static const ink = Color(0xFF15181A);
  static const muted = Color(0xFF70777B);
  static const rule = Color(0xFFBFC6C9);
  static const ruleStrong = Color(0xFF666F74);
  static const accent = Color(0xFFD6284F);
  static const humanInk = Color(0xFF8F1634);

  Widget _coord(String l, String r) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                letterSpacing: 1.0, color: muted)),
            Text(r, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                letterSpacing: 1.0, color: muted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: canvas,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Text('Friday 28 August',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 22,
                        fontWeight: FontWeight.w700, color: ink)),
              ),

              // Open Interval — the register stops for a person's words.
              Container(height: 1, color: ruleStrong),
              const SizedBox(height: 2),
              Container(height: 1, color: ruleStrong),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('20:06', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            letterSpacing: 1.0, color: muted)),
                        Text('ALEX', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            letterSpacing: 1.2, color: muted)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('I noticed the care you put into this.',
                        style: TextStyle(
                            fontFamily: 'Lora', fontSize: 26, height: 1.3,
                            color: humanInk)),
                    const SizedBox(height: 32),
                    const Text('PREPARE THE EVENING SPACE',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            letterSpacing: 1.1, color: muted)),
                  ],
                ),
              ),
              Container(height: 1, color: rule),

              // Actionable cut — paper fill and an edge notch.
              Stack(children: [
                Container(
                  color: paper,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _coord('NOW', 'YOU'),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
                        child: Text('2 need your response',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 19,
                                fontWeight: FontWeight.w600, color: ink)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    left: 0, top: 22,
                    child: Container(width: 3, height: 24, color: accent)),
              ]),
              Container(height: 1, color: rule),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _coord('TODAY', 'FROM ALEX'),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
                    child: Text('Evening check-in message',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 19,
                            fontWeight: FontWeight.w600, color: ink)),
                  ),
                ],
              ),
              Container(height: 1, color: rule),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _coord('WAITING', 'ALEX'),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
                    child: Text('Tidy the entryway',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 19,
                            fontWeight: FontWeight.w600, color: ink)),
                  ),
                ],
              ),
              Container(height: 1, color: rule),

              const Spacer(),
              Container(height: 1, color: rule),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final (label, on)
                        in [('TODAY', true), ('DYNAMIC', false),
                            ('EXPLORE', false), ('US', false)])
                      Text(label,
                          style: TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                              color: on ? ink : muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// 04 · STILL / THE STAGE
// One dominant moment; everything else is a compact cue.
class _Still extends StatelessWidget {
  const _Still();

  static const canvas = Color(0xFFF1F0EE);
  static const stage = Color(0xFFE7E6E3);
  static const ink = Color(0xFF101112);
  static const muted = Color(0xFF707477);
  static const line = Color(0xFFC5C5C2);
  static const accent = Color(0xFFE6005C);

  Widget _cue(String title, String state, {bool first = false}) => Column(
        children: [
          if (first) Container(height: 1, color: line),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 17,
                          fontWeight: FontWeight.w600, color: ink)),
                ),
                Text(state,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        letterSpacing: 0.8, color: muted)),
              ],
            ),
          ),
          Container(height: 1, color: line),
        ],
      );

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: canvas,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Today',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 22,
                            fontWeight: FontWeight.w800, color: ink)),
                    Text('FRI 28',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            letterSpacing: 1.0, color: muted)),
                  ],
                ),
              ),

              // The stage — one real moment, nothing else.
              Container(
                width: double.infinity,
                height: 358,
                color: stage,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 62, 64, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('I noticed the care you put into this.',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 33, height: 1.06,
                                fontWeight: FontWeight.w800, color: ink)),
                        const Spacer(),
                        const Text('Prepare the evening space',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12,
                                color: muted)),
                      ],
                    ),
                  ),
                  // The one rotated caption in the system.
                  Positioned(
                    right: 12, top: 100,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text('ALEX · 8:06 PM',
                          style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              letterSpacing: 1.4, color: muted)),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 28),
              _cue('2 need your response', 'RESPOND', first: true),
              _cue('Evening check-in message', 'TODAY'),
              _cue('Tidy the entryway', 'WAITING'),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final (label, on)
                      in [('Today', true), ('Dynamic', false),
                          ('Explore', false), ('Us', false)])
                    Column(children: [
                      Text(label,
                          style: TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                              color: on ? ink : muted)),
                      const SizedBox(height: 4),
                      Container(
                          height: 2, width: 18,
                          color: on ? accent : Colors.transparent),
                    ]),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      );
}
