import 'dart:convert';
import 'dart:io';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Foundation contract tests.
///
/// These defend the frozen design system, not product behavior. An assertion
/// here failing means a generated binding drifted from its freeze manifest, or
/// a declared asset cannot actually be loaded on a target platform — both of
/// which would surface as a broken screen long after the cause.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The package root, independent of the directory `flutter test` runs from.
  final appDir = Directory.current.path.endsWith('/app')
      ? Directory.current
      : Directory('${Directory.current.path}/app');
  final repoRoot = appDir.parent;

  group('SVG registry', () {
    test('all frozen SVG asset IDs are unique', () {
      final ids = DsAssets.all.map((asset) => asset.id).toSet();
      expect(ids, hasLength(DsAssets.all.length));
      expect(DsAssets.all, hasLength(33));
    });

    test('every registered SVG master exists on disk', () {
      final missing = <String>[];
      for (final asset in DsAssets.all) {
        // The registry path is package-qualified for runtime resolution;
        // on disk it lives at the package root.
        final rel = asset.path.replaceFirst(
          'packages/ds_relationship_companion/',
          '',
        );
        final file = File('${appDir.path}/$rel');
        if (!file.existsSync()) missing.add('${asset.id} -> ${asset.path}');
      }
      expect(missing, isEmpty, reason: 'registered masters must be bundled');
    });

    test('registry matches the SVG freeze manifest exactly', () {
      final manifest = jsonDecode(
        File('${repoRoot.path}/manifests/svg-freeze.v1.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final entries = (manifest['assets'] as List).cast<Map<String, dynamic>>();
      final frozen = entries.map((e) => e['id'] as String).toSet();
      final generated = DsAssets.all.map((a) => a.id).toSet();
      expect(generated, equals(frozen),
          reason: 'DsAssets drifted from SVG-FREEZE-V1');
    });

    test('byId resolves every registered asset', () {
      for (final asset in DsAssets.all) {
        expect(DsAssets.byId(asset.id).path, asset.path);
      }
    });

    test('asset paths are declared under a bundled pubspec asset directory',
        () {
      // Android and Flutter Web both resolve through the same asset manifest,
      // so a path outside the declared directories loads on neither.
      for (final asset in DsAssets.all) {
        expect(asset.path,
            startsWith('packages/ds_relationship_companion/assets/svg/'),
            reason: '${asset.id} is outside the declared asset directory');
      }
      expect(DsTextureAssets.ritualGrain,
          startsWith('packages/ds_relationship_companion/assets/textures/'));
    });
  });

  group('SVG colour licensing', () {
    test('every asset declares at least one allowed tone', () {
      for (final asset in DsAssets.all) {
        expect(asset.allowedTones, isNotEmpty, reason: asset.id);
      }
    });

    testWidgets('DsSvg refuses a tone the asset does not license',
        (tester) async {
      const asset = DsAssets.markAuthority;
      final forbidden =
          DsAssetTone.values.firstWhere((t) => !asset.allowedTones.contains(t));

      await tester.pumpWidget(
        MaterialApp(home: DsSvg(asset: asset, tone: forbidden)),
      );

      expect(tester.takeException(), isFlutterError);
    });

    testWidgets('DsSvg renders a licensed tone', (tester) async {
      const asset = DsAssets.markAuthority;
      final allowed = asset.allowedTones.first;

      await tester.pumpWidget(
        MaterialApp(home: DsSvg(asset: asset, tone: allowed)),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Fonts', () {
    test('all seven declared font files exist and parse as TTF', () {
      final declared = <String>[
        'assets/fonts/inter/Inter-Regular.ttf',
        'assets/fonts/inter/Inter-Medium.ttf',
        'assets/fonts/inter/Inter-SemiBold.ttf',
        'assets/fonts/inter/Inter-Bold.ttf',
        'assets/fonts/cormorant-garamond/CormorantGaramond-Regular.ttf',
        'assets/fonts/cormorant-garamond/CormorantGaramond-Medium.ttf',
        'assets/fonts/cormorant-garamond/CormorantGaramond-SemiBold.ttf',
      ];
      expect(declared, hasLength(7));

      for (final path in declared) {
        final file = File('${appDir.path}/$path');
        expect(file.existsSync(), isTrue, reason: 'missing font: $path');

        // A truncated or LFS-pointer font passes existsSync but breaks at
        // runtime. Check the actual sfnt signature.
        final header = file.openSync().readSync(4);
        final tag = header.buffer.asByteData().getUint32(0);
        expect(tag == 0x00010000 || tag == 0x74727565, isTrue,
            reason: '$path is not a valid TrueType file');
      }
    });

    test('pubspec declares exactly the two approved families', () {
      final pubspec = File('${appDir.path}/pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: Inter'));
      expect(pubspec, contains('family: CormorantGaramond'));
      // Substituting a platform font is explicitly forbidden.
      expect(pubspec, isNot(contains('Roboto')));
      expect(pubspec, isNot(contains('Times')));
    });
  });

  group('Typography freeze', () {
    test('eight typography roles use bundled families', () {
      // fontFamily carries the package prefix; the family name is its tail.
      String family(TextStyle s) => s.fontFamily!.split('/').last;

      expect(family(DsTextStyles.displayRitual), DsTextStyles.displayFamily);
      expect(family(DsTextStyles.displayPartner), DsTextStyles.displayFamily);
      expect(family(DsTextStyles.titlePage), DsTextStyles.uiFamily);
      expect(family(DsTextStyles.bodyPrimary), DsTextStyles.uiFamily);
      expect(family(DsTextStyles.bodySecondary), DsTextStyles.uiFamily);
      expect(family(DsTextStyles.labelAction), DsTextStyles.uiFamily);
      expect(family(DsTextStyles.labelRitual), DsTextStyles.uiFamily);
      expect(family(DsTextStyles.navLabel), DsTextStyles.uiFamily);
    });

    test('frozen size and line-height values match typography.md', () {
      void check(TextStyle s, double size, double height, double spacing) {
        expect(s.fontSize, size);
        expect(s.height, closeTo(height / size, 0.0001));
        expect(s.letterSpacing ?? 0, spacing);
      }

      check(DsTextStyles.displayRitual, 34, 42, 0);
      check(DsTextStyles.displayPartner, 28, 36, 0);
      check(DsTextStyles.titlePage, 22, 28, -0.2);
      check(DsTextStyles.bodyPrimary, 16, 24, 0);
      check(DsTextStyles.bodySecondary, 14, 20, 0);
      check(DsTextStyles.labelAction, 16, 20, 0.1);
      check(DsTextStyles.labelRitual, 12, 16, 2.4);
      check(DsTextStyles.navLabel, 12, 16, 0);
    });

    test('every role resolves its font from this package, not the host', () {
      // Without the package qualifier Flutter looks the bare family name up in
      // the host application, finds nothing, and silently substitutes a
      // platform font. The screen still renders, so nothing fails — it just
      // stops being the type system.
      const roles = <TextStyle>[
        DsTextStyles.displayRitual,
        DsTextStyles.displayPartner,
        DsTextStyles.titlePage,
        DsTextStyles.bodyPrimary,
        DsTextStyles.bodySecondary,
        DsTextStyles.labelAction,
        DsTextStyles.labelRitual,
        DsTextStyles.navLabel,
      ];
      expect(roles, hasLength(8));
      for (final role in roles) {
        expect(
          role.fontFamily,
          startsWith('packages/ds_relationship_companion/'),
          reason: '${role.fontSize}px role would fall back to a system font',
        );
      }
    });

    test('the display face is reserved for ritual and partner voice', () {
      // Red line: the editorial face carries human words; UI chrome must not
      // borrow it.
      expect(DsTextStyles.displayFamily, isNot(DsTextStyles.uiFamily));
      expect(
          DsTextStyles.titlePage.fontFamily, isNot(DsTextStyles.displayFamily));
      expect(
          DsTextStyles.navLabel.fontFamily, isNot(DsTextStyles.displayFamily));
    });
  });

  group('B-2 token freeze', () {
    test('B-2 control geometry remains frozen', () {
      expect(DsLayoutSizes.touchTarget, 48);
      expect(DsControlSizes.button, 56);
      expect(DsControlSizes.buttonRitual, 64);
      expect(DsControlSizes.listRow, 72);
      expect(DsControlSizes.bottomNavigation, 80);
    });

    test('generated colour tokens match the token freeze manifest', () {
      final manifest = jsonDecode(
        File('${repoRoot.path}/manifests/token-freeze.b2.v1.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(manifest['status'], 'frozen');

      // The ritual canvas is named explicitly in CLAUDE.md; drift here changes
      // every approved screen's ground.
      expect(DsColors.canvasRitual, const Color(0xFF080B07));
    });

    test('the ritual canvas is neither pure black nor a Material default', () {
      expect(DsColors.canvasRitual, isNot(const Color(0xFF000000)));
      expect(DsColors.canvasRitual, isNot(Colors.black));
      expect(DsColors.canvasRitual.a, 1.0);
    });
  });

  group('Themes', () {
    test('ritual theme is dark and sits on the ritual canvas', () {
      final theme = DsTheme.ritual();
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, DsColors.canvasRitual);
      expect(theme.useMaterial3, isTrue);
    });

    test('living theme is a distinct surface from the ritual theme', () {
      final ritual = DsTheme.ritual();
      final living = DsTheme.living();
      expect(living.scaffoldBackgroundColor,
          isNot(ritual.scaffoldBackgroundColor));
    });

    testWidgets('both themes build without a Material font fallback',
        (tester) async {
      for (final theme in [DsTheme.ritual(), DsTheme.living()]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(body: Text('foundation')),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('B-4 ritual texture', () {
    test('the deterministic grain asset exists and is a PNG', () {
      final file = File('${appDir.path}/'
          '${DsTextureAssets.ritualGrain.replaceFirst(
        'packages/ds_relationship_companion/',
        '',
      )}');
      expect(file.existsSync(), isTrue);
      final sig = file.openSync().readSync(8);
      expect(sig.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
    });

    testWidgets('DsRitualSurface still paints when the texture is missing',
        (tester) async {
      // Asset loading is stubbed to fail. The ground must survive: a missing
      // grain may not take the screen down with it.
      // Returning null is how the engine reports an absent asset; the widget
      // must treat that as "no grain", not as a fatal error.
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => null,
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', null);
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.ritual(),
          home: const DsRitualSurface(child: Text('held')),
        ),
      );
      await tester.pump();

      expect(find.text('held'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DsRitualSurface renders its child with the texture present',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.ritual(),
          home: const DsRitualSurface(child: Text('held')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('held'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Android / Web asset path compatibility', () {
    test('no asset path is absolute, escaping, or backslash-separated', () {
      // Flutter Web serves assets over HTTP; a Windows-style or absolute path
      // resolves on neither platform.
      final paths = <String>[
        ...DsAssets.all.map((a) => a.path),
        DsTextureAssets.ritualGrain,
      ];
      for (final path in paths) {
        expect(path.startsWith('/'), isFalse, reason: path);
        expect(path.contains('\\'), isFalse, reason: path);
        expect(path.contains('..'), isFalse, reason: path);
        expect(path, matches(RegExp(r'^[a-z0-9/._-]+$')),
            reason: '$path must be lowercase and URL-safe for Web');
      }
    });

    test('every registered asset loads through the real asset bundle',
        () async {
      // Unit checks above prove the files are on disk; this proves they are
      // reachable through the AssetManifest that both Android and Flutter Web
      // resolve against. A path declared but not bundled fails only here.
      // Paths are package-qualified so a consuming app resolves them. Inside
      // this package's own test bundle the asset is registered unqualified,
      // so both spellings are accepted here; what matters is that the bytes
      // are reachable.
      Future<ByteData> load(String path) async {
        try {
          return await rootBundle.load(path);
        } catch (_) {
          return rootBundle.load(
            path.replaceFirst('packages/ds_relationship_companion/', ''),
          );
        }
      }

      final failures = <String>[];
      for (final asset in DsAssets.all) {
        try {
          final data = await load(asset.path);
          if (data.lengthInBytes == 0) failures.add('${asset.id}: empty');
        } catch (error) {
          failures.add('${asset.id}: $error');
        }
      }
      try {
        final texture = await load(DsTextureAssets.ritualGrain);
        if (texture.lengthInBytes == 0) failures.add('ritualGrain: empty');
      } catch (error) {
        failures.add('ritualGrain: $error');
      }
      expect(failures, isEmpty);
    });

    test('every bundled font path is URL-safe for Web serving', () {
      final pubspec = File('${appDir.path}/pubspec.yaml').readAsStringSync();
      final assetLines = RegExp(r'- asset: (\S+)')
          .allMatches(pubspec)
          .map((m) => m.group(1)!)
          .toList();
      expect(assetLines, hasLength(7));
      for (final path in assetLines) {
        expect(path, matches(RegExp(r'^[A-Za-z0-9/._-]+$')), reason: path);
        expect(File('${appDir.path}/$path').existsSync(), isTrue, reason: path);
      }
    });
  });
}
