import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shotkit/core/theme/app_theme.dart';

/// Loads the app's bundled fonts (and the SDK's Material icons) so widget
/// tests lay text out with real glyph widths instead of the square test font.
Future<void> loadRealFonts() async {
  const families = {
    ShotKitFonts.sans: [
      'Archivo-Regular',
      'Archivo-Medium',
      'Archivo-SemiBold',
      'Archivo-Bold',
      'Archivo-ExtraBold',
    ],
    ShotKitFonts.semiCondensed: ['ArchivoSemiCondensed-ExtraBold'],
    ShotKitFonts.condensed: [
      'ArchivoCondensed-ExtraBold',
      'ArchivoCondensed-Black',
    ],
    ShotKitFonts.mono: [
      'JetBrainsMono-Regular',
      'JetBrainsMono-Medium',
      'JetBrainsMono-Bold',
    ],
  };
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(_fontBytes('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')..addFont(_fontBytes(_materialIcons())))
      .load();
}

Future<ByteData> _fontBytes(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

/// The Material icon font ships with the Flutter SDK.
String _materialIcons() {
  const relative =
      'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null && File(p.join(root, relative)).existsSync()) {
    return p.join(root, relative);
  }
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.parent.path != dir.path) {
    final candidate = File(p.join(dir.path, relative));
    if (candidate.existsSync()) return candidate.path;
    dir = dir.parent;
  }
  throw StateError('MaterialIcons font not found; set FLUTTER_ROOT.');
}
