import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/shotkit_store.dart';
import 'features/projects/projects_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShotKitApp());
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
          return ProjectsScreen(store: store);
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
