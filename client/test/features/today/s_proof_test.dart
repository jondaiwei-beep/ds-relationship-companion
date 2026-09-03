import 'dart:typed_data';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/media_repository.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:dsapp/platform/media/proof_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

class _FakePicker implements ProofPicker {
  _FakePicker(this.bytes);
  final Uint8List? bytes;
  final sources = <ProofSource>[];

  @override
  Future<Uint8List?> pick(ProofSource source) async {
    sources.add(source);
    return bytes;
  }
}

class _FakeMedia implements MediaRepository {
  final uploads = <(String, int)>[];

  @override
  Future<MediaUpload> upload(String dynamicId, Uint8List jpeg) async {
    uploads.add((dynamicId, jpeg.length));
    return const MediaUpload(id: 'media-1', url: '/v1/media/media-1');
  }

  @override
  String urlFor(String mediaId) => 'http://x/v1/media/$mediaId';

  @override
  Map<String, String> get authHeaders => const {};
}

Future<void> _pump(
  WidgetTester tester,
  FakeTodayRepository repo, {
  required _FakePicker picker,
  required _FakeMedia media,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(repo),
        dynamicRepositoryProvider.overrideWithValue(FakeDynamicRepository()),
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
        proofPickerProvider.overrideWithValue(picker),
        mediaRepositoryProvider.overrideWithValue(media),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: TodayScreen(dynamicId: 'dyn-1', onSelectTab: (_) {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('photo proof: 拍照/相册, upload first, then deliver with the media id', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [occ(id: 'o1', title: '拍张厨房', proof: 'photo')]),
    );
    final picker = _FakePicker(Uint8List.fromList(List.filled(32, 7)));
    final media = _FakeMedia();
    await _pump(tester, repo, picker: picker, media: media);

    await tester.tap(find.text('拍张厨房'));
    await tester.pumpAndSettle();
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('从相册选'), findsOneWidget);
    expect(find.text('写一句'), findsNothing, reason: 'photo means photo');

    await tester.tap(find.text('拍照'));
    await tester.pumpAndSettle();

    expect(picker.sources, [ProofSource.camera]);
    expect(media.uploads, [('dyn-1', 32)]);
    final change = repo.outcomes.single.$2;
    expect(change.outcome, Outcome.delivered);
    expect(change.proofKind, 'photo');
    expect(change.proofRef, 'media-1');
  });

  testWidgets('backing out of the picker delivers nothing', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [occ(id: 'o1', title: '拍张厨房', proof: 'photo')]),
    );
    final media = _FakeMedia();
    await _pump(tester, repo, picker: _FakePicker(null), media: media);

    await tester.tap(find.text('拍张厨房'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('从相册选'));
    await tester.pumpAndSettle();

    expect(media.uploads, isEmpty);
    expect(repo.outcomes, isEmpty);
  });

  testWidgets('any: 写一句 is offered alongside the photo sources', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [occ(id: 'o1', title: '汇报', proof: 'any')]),
    );
    await _pump(tester, repo, picker: _FakePicker(null), media: _FakeMedia());

    await tester.tap(find.text('汇报'));
    await tester.pumpAndSettle();
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('写一句'), findsOneWidget);
  });

  testWidgets('text proof requires the line; it travels as the note', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [occ(id: 'o1', title: '写日记', proof: 'text')]),
    );
    await _pump(tester, repo, picker: _FakePicker(null), media: _FakeMedia());

    await tester.tap(find.text('写日记'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    // Nothing typed: 送出 does nothing.
    await tester.tap(find.text('送出'));
    await tester.pumpAndSettle();
    expect(repo.outcomes, isEmpty);

    await tester.enterText(find.byType(TextField), '今天写了三页');
    await tester.pump();
    await tester.tap(find.text('送出'));
    await tester.pumpAndSettle();

    final change = repo.outcomes.single.$2;
    expect(change.outcome, Outcome.delivered);
    expect(change.proofKind, 'text');
    expect(change.note, '今天写了三页');
  });

  testWidgets('a delivered photo shows as a thumbnail on the row', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [
        occ(
          id: 'o1',
          title: '拍张厨房',
          proof: 'photo',
          outcome: Outcome.delivered,
        ).copyWith(proofKind: 'photo', proofRef: 'media-9'),
      ]),
    );
    await _pump(tester, repo, picker: _FakePicker(null), media: _FakeMedia());
    expect(find.byType(Image), findsOneWidget);
  });
}
