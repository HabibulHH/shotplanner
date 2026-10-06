import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/shotkit_store.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(const ShotKitApp());
}

Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Archivo', 'OFL-Archivo.txt'),
    ('JetBrains Mono', 'OFL-JetBrainsMono.txt'),
  ]) {
    final text = await rootBundle.loadString('assets/fonts/$file');
    yield LicenseEntryWithLineBreaks([family], text);
  }
}

class ShotKitApp extends StatefulWidget {
  const ShotKitApp({super.key, this.store});
  final ShotKitStore? store;

  @override
  State<ShotKitApp> createState() => _ShotKitAppState();
}

class _ShotKitAppState extends State<ShotKitApp> {
  late final ShotKitStore store;
  late final bool ownsStore;

  @override
  void initState() {
    super.initState();
    ownsStore = widget.store == null;
    store = widget.store ?? ShotKitStore();
  }

  @override
  void dispose() {
    if (ownsStore) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShotKit',
      debugShowCheckedModeBanner: false,
      theme: buildShotKitTheme(),
      home: FutureBuilder<void>(
        future: store.ready,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StartupError(message: snapshot.error.toString());
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return DashboardScreen(store: store);
        },
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storage_rounded, size: 42),
              const SizedBox(height: 16),
              const Text('ShotKit could not open local storage.'),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
