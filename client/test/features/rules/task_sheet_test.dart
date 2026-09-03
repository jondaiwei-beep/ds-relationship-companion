import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/features/rules/presentation/widgets/rules_sheets.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

/// The task editor sheet, driven directly: every `Task` field goes in, the
/// body that comes out matches the backend's `CreateTaskBody`.
Future<Future<NewTask?> Function()> _open(
  WidgetTester tester, {
  TaskView? existing,
  NewTask? draft,
}) async {
  NewTask? result;
  var done = false;
  tester.view.physicalSize = const Size(390, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: DsTheme.ritual(),
      locale: const Locale('zh'),
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await showTaskSheet(
                context,
                title: '加一条任务',
                dName: '你',
                timezone: 'Asia/Shanghai',
                today: '2026-09-03',
                existing: existing,
                draft: draft,
              );
              done = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  // Called after 记下: waits for the sheet to close and hands back its result.
  return () async {
    await tester.pumpAndSettle();
    expect(done, isTrue, reason: 'sheet did not close');
    return result;
  };
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('记下'));
  await tester.tap(find.text('记下'));
  await tester.pumpAndSettle();
}

Future<void> _tapWord(WidgetTester tester, String word) async {
  await tester.ensureVisible(find.text(word).last);
  await tester.tap(find.text(word).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  testWidgets('weekdays schedule serialises {type:weekdays, days:[1,3,5]}', (tester) async {
    final read = await _open(tester);
    await tester.enterText(find.byType(TextField).first, '周一三五整理');
    await _tapWord(tester, '每周');
    // Default Mon–Fri; drop Tue and Thu.
    await _tapWord(tester, '二');
    await _tapWord(tester, '四');
    await _save(tester);
    final t = await read();
    expect(t, isNotNull);
    expect(t!.kind, 'recurring');
    expect(t.schedule, {'type': 'weekdays', 'days': [1, 3, 5]});
    expect(t.timesPerDay, 1);
    expect(t.dueTime, isNull);
    expect(t.proof, 'check');
    expect(t.pointsEarn, 0);
  });

  testWidgets('every N days carries n and from; bad n is named', (tester) async {
    final read = await _open(tester);
    await tester.enterText(find.byType(TextField).first, '每三天称重');
    await _tapWord(tester, '每几天');
    await tester.enterText(find.byType(TextField).at(2), '1');
    await _save(tester);
    expect(find.text('填 2 到 365'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(2), '3');
    await _save(tester);
    final t = await read();
    expect(t!.schedule, {'type': 'every_n_days', 'n': 3, 'from': '2026-09-03'});
  });

  testWidgets('one_off needs a day; default is today at the day\'s end in the zone', (tester) async {
    final read = await _open(tester);
    await _tapWord(tester, '一次');
    await _save(tester);
    // Title missing is named, in zh.
    expect(find.text('先写做什么'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '今晚交作业');
    await _save(tester);
    final t = await read();
    expect(t!.kind, 'one_off');
    expect(t.schedule, isNull);
    // 2026-09-03 relationship day ends at 04:00 the next day, Asia/Shanghai
    // (+08:00) → 2026-09-03T20:00Z minus a second.
    expect(t.dueAt, DateTime.utc(2026, 9, 3, 19, 59, 59));
  });

  testWidgets('measure requires a unit', (tester) async {
    final read = await _open(tester);
    await tester.enterText(find.byType(TextField).first, '体重');
    await _tapWord(tester, '记数值');
    await _save(tester);
    expect(find.text('记数值要有单位'), findsOneWidget);
    // Unit field is the third text field: title, detail, unit.
    await tester.enterText(find.byType(TextField).at(2), 'kg');
    await _save(tester);
    final t = await read();
    expect(t!.kind, 'measure');
    expect(t.unit, 'kg');
  });

  testWidgets('checkin locks proof to text and keeps times per day', (tester) async {
    final read = await _open(tester);
    await tester.enterText(find.byType(TextField).first, '早晚请安');
    await _tapWord(tester, '问安');
    expect(find.text('问安只收文字'), findsOneWidget);
    await _tapWord(tester, '+');
    await _save(tester);
    final t = await read();
    expect(t!.kind, 'checkin');
    expect(t.proof, 'text');
    expect(t.timesPerDay, 2);
  });

  testWidgets('points outside 0–1000 and a long detail are named', (tester) async {
    await _open(tester);
    await tester.enterText(find.byType(TextField).first, 'x');
    await tester.enterText(find.byType(TextField).at(1), 'a' * 1001);
    await tester.enterText(find.byType(TextField).at(2), '1001');
    await _save(tester);
    expect(find.text('最多 1000 字'), findsOneWidget);
    expect(find.text('0 到 1000'), findsOneWidget);
  });

  testWidgets('editing pre-fills every field and round-trips unchanged', (tester) async {
    final existing = TaskView(
      id: 't-1',
      title: '晚安汇报',
      detail: '三句话',
      kind: 'recurring',
      schedule: const {'type': 'weekdays', 'days': [6, 7]},
      timesPerDay: 2,
      dueTime: '22:30',
      proof: 'photo',
      pointsEarn: 5,
      requiresDPresent: true,
      createdBy: 'u-d',
      status: 'active',
    );
    final read = await _open(tester, existing: existing);
    expect(find.text('晚安汇报'), findsOneWidget);
    expect(find.text('三句话'), findsOneWidget);
    expect(find.text('22:30'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    await _save(tester);
    final t = await read();
    expect(t!.title, '晚安汇报');
    expect(t.detail, '三句话');
    expect(t.schedule, {'type': 'weekdays', 'days': [6, 7]});
    expect(t.timesPerDay, 2);
    expect(t.dueTime, '22:30');
    expect(t.proof, 'photo');
    expect(t.pointsEarn, 5);
    expect(t.requiresDPresent, isTrue);
  });

  testWidgets('a one-off being edited shows its day and clock in the zone', (tester) async {
    final existing = TaskView(
      id: 't-2',
      title: '交作业',
      kind: 'one_off',
      dueAt: DateTime.utc(2026, 9, 5, 13, 0), // 21:00 in Asia/Shanghai
      proof: 'check',
      createdBy: 'u-d',
      status: 'active',
    );
    final read = await _open(tester, existing: existing);
    expect(find.text('21:00'), findsOneWidget);
    await _save(tester);
    final t = await read();
    expect(t!.dueAt, DateTime.utc(2026, 9, 5, 13, 0));
  });

  testWidgets('a quick-add draft seeds the sheet', (tester) async {
    final read = await _open(
      tester,
      draft: const NewTask(title: '拖地', kind: 'one_off', pointsEarn: 3),
    );
    expect(find.text('拖地'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await _save(tester);
    final t = await read();
    expect(t!.kind, 'one_off');
    expect(t.pointsEarn, 3);
    expect(t.dueAt, isNotNull);
  });
}
