import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/screens/login_screen.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit()..loadSettings(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.palette),
                  title: const Text('Theme'),
                  subtitle: Text(state.themeMode),
                ),
                ListTile(
                  leading: const Icon(LucideIcons.refreshCw),
                  title: const Text('Refresh interval'),
                  subtitle: Text('${state.refreshIntervalSeconds} seconds'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(LucideIcons.logOut),
                  title: const Text('Sign out'),
                  onTap: () async {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
