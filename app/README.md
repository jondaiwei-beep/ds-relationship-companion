# Flutter foundation package

This directory is the portable application foundation for Android and Flutter Web. It intentionally contains no product screen while every screen gate remains blocked.

## Ready for use

- bundled Cormorant Garamond and Inter fonts;
- the eight frozen type roles;
- generated B-2 semantic tokens and geometry;
- generated semantic SVG registry backed by the 33 approved masters;
- deterministic B-4 ritual grain;
- Ritual and Living base themes.

Canonical inputs remain under `design/` and `manifests/`. Generated app files and copied assets must be refreshed from repository root:

```bash
npm install
npm run foundation:check
```

Run Flutter validation when an environment with the Flutter SDK is available:

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

Do not add `lib/main.dart` or implement a product screen until its active manifest gate is `ready_for_build`.
