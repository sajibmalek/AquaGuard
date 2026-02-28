import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/models/app_state.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final state = notifier.state;

    return CustomScrollView(
      slivers: [
        // ── Current Role Banner ──────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _RoleBanner(role: state.currentRole),
          ),
        ),

        // ── Account ──────────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Account')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Switch Role',
                    subtitle: 'Currently: ${state.currentRole.label}',
                    onTap: () => _showRoleSwitcher(context, notifier),
                  ),
                  const Divider(indent: 56, height: 1),
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: 'View account details',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Aquarium ─────────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('Aquarium')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.water_rounded,
                    title: 'Tank Configuration',
                    subtitle: state.aquarium.name,
                    onTap: () {},
                    enabled: state.currentRole.canManageSettings,
                  ),
                  const Divider(indent: 56, height: 1),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Alert Thresholds',
                    subtitle: 'Configure parameter alerts',
                    onTap: () {},
                    enabled: state.currentRole.canManageSettings,
                  ),
                  const Divider(indent: 56, height: 1),
                  _SettingsTile(
                    icon: Icons.schedule_rounded,
                    title: 'Schedules',
                    subtitle: 'Light & feeding schedules',
                    onTap: () {},
                    enabled: state.currentRole.canControl,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── App ──────────────────────────────────────
        const SliverToBoxAdapter(child: SectionLabel('App')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Column(
                children: [
                  _SettingsTileSwitch(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: state.isDarkMode,
                    onChanged: (_) => notifier.toggleDarkMode(),
                  ),
                  const Divider(indent: 56, height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About AquaGuard',
                    subtitle: 'v1.0.0',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _showRoleSwitcher(BuildContext context, AppStateNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RoleSwitcherSheet(
        currentRole: notifier.state.currentRole,
        onRoleSelected: (role) {
          notifier.switchRole(role);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AquaGuard',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 AquaGuard Systems',
      children: [
        const SizedBox(height: 12),
        const Text(
          'Smart Aquarium Safety, Automation & Health Monitoring System.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Role Banner
// ─────────────────────────────────────────────
class _RoleBanner extends StatelessWidget {
  final UserRole role;
  const _RoleBanner({required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _roleIcon(role),
              color: cs.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.operator:
        return Icons.engineering_outlined;
      case UserRole.viewer:
        return Icons.visibility_outlined;
    }
  }
}

// ─────────────────────────────────────────────
// Settings Tile
// ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = enabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.4);

    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.4)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: effectiveColor,
        ),
      ),
      subtitle: Text(
        enabled ? subtitle : '$subtitle (requires ${_requiredRole()})',
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withValues(alpha: enabled ? 1 : 0.5)),
      ),
      trailing: enabled
          ? Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)
          : Icon(Icons.lock_outline_rounded, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
      onTap: enabled ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  String _requiredRole() => 'Admin';
}

// ─────────────────────────────────────────────
// Settings Tile with Switch
// ─────────────────────────────────────────────
class _SettingsTileSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTileSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// ─────────────────────────────────────────────
// Role Switcher Modal Bottom Sheet
// ─────────────────────────────────────────────
class RoleSwitcherSheet extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleSelected;

  const RoleSwitcherSheet({
    super.key,
    required this.currentRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Switch Role',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Changes are UI-only and reset on restart.',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ...UserRole.values.map((role) {
              final isSelected = role == currentRole;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RoleOption(
                  role: role,
                  isSelected: isSelected,
                  onTap: () => onRoleSelected(role),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? cs.primary.withValues(alpha: 0.15)
              : cs.onSurfaceVariant.withValues(alpha: 0.1),
          child: Icon(
            _roleIcon(role),
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          role.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
          ),
        ),
        subtitle: Text(
          role.description,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? cs.onPrimaryContainer.withValues(alpha: 0.75)
                : cs.onSurfaceVariant,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: cs.primary)
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.operator:
        return Icons.engineering_outlined;
      case UserRole.viewer:
        return Icons.visibility_outlined;
    }
  }
}
