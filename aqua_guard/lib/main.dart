import 'package:flutter/material.dart';
import 'core/models/app_state.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_shell.dart';

void main() {
  runApp(const AquaGuardApp());
}

class AquaGuardApp extends StatefulWidget {
  const AquaGuardApp({super.key});

  @override
  State<AquaGuardApp> createState() => _AquaGuardAppState();
}

class _AquaGuardAppState extends State<AquaGuardApp> {
  final AppStateNotifier _notifier = AppStateNotifier();

  @override
  void initState() {
    super.initState();
    // Listen for theme changes to rebuild the MaterialApp.
    _notifier.addListener(_onStateChange);
  }

  void _onStateChange() => setState(() {});

  @override
  void dispose() {
    _notifier.removeListener(_onStateChange);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _notifier,
      child: MaterialApp(
        title: 'AquaGuard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode:
            _notifier.state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const AppShell(),
      ),
    );
  }
}
