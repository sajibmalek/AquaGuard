import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import '../../core/enums/app_enums.dart';
import '../../core/theme/app_colors.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/control/presentation/screens/control_screen.dart';
import '../../features/health/presentation/screens/health_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

// ─────────────────────────────────────────────
// App Shell – master layout with NavigationBar/Rail
// ─────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavDestination(
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
      label: 'Control',
    ),
    _NavDestination(
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart_rounded,
      label: 'Health',
    ),
    _NavDestination(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history_rounded,
      label: 'History',
    ),
    _NavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const _screenTitles = [
    'Dashboard',
    'Control',
    'Health',
    'History',
    'Settings',
  ];

  static const _screens = [
    DashboardScreen(),
    ControlScreen(),
    HealthScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final state = notifier.state;
    final aquarium = state.aquarium;
    final unreadCount = aquarium.unreadAlerts;
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (isWide) {
      return _WideLayout(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        screens: _screens,
        screenTitles: _screenTitles,
        unreadCount: unreadCount,
        aquariumName: aquarium.name,
        role: state.currentRole,
        notifier: notifier,
      );
    }

    return _NarrowLayout(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: _destinations,
      screens: _screens,
      screenTitles: _screenTitles,
      unreadCount: unreadCount,
      aquariumName: aquarium.name,
      role: state.currentRole,
      notifier: notifier,
    );
  }
}

// ─────────────────────────────────────────────
// Narrow Layout (Mobile – NavigationBar)
// ─────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavDestination> destinations;
  final List<Widget> screens;
  final List<String> screenTitles;
  final int unreadCount;
  final String aquariumName;
  final UserRole role;
  final AppStateNotifier notifier;

  const _NarrowLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.screens,
    required this.screenTitles,
    required this.unreadCount,
    required this.aquariumName,
    required this.role,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AquaAppBar(
        title: selectedIndex == 0 ? aquariumName : screenTitles[selectedIndex],
        showBackButton: false,
        unreadCount: unreadCount,
        role: role,
        notifier: notifier,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Wide Layout (Tablet/Desktop – NavigationRail)
// ─────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavDestination> destinations;
  final List<Widget> screens;
  final List<String> screenTitles;
  final int unreadCount;
  final String aquariumName;
  final UserRole role;
  final AppStateNotifier notifier;

  const _WideLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.screens,
    required this.screenTitles,
    required this.unreadCount,
    required this.aquariumName,
    required this.role,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _AquaAppBar(
        title: selectedIndex == 0 ? aquariumName : screenTitles[selectedIndex],
        showBackButton: false,
        unreadCount: unreadCount,
        role: role,
        notifier: notifier,
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1024,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: MediaQuery.of(context).size.width >= 1024
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AquaGuard AppBar
// ─────────────────────────────────────────────
class _AquaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final int unreadCount;
  final UserRole role;
  final AppStateNotifier notifier;

  const _AquaAppBar({
    required this.title,
    required this.showBackButton,
    required this.unreadCount,
    required this.role,
    required this.notifier,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
          Text(
            role.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        // ── Alert Bell ──────────────────────────
        _AlertBell(
          unreadCount: unreadCount,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppStateProvider(
                notifier: notifier,
                child: const AlertsScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // ── Overflow Menu ───────────────────────
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'switch_role',
              child: Row(
                children: [
                  Icon(Icons.manage_accounts_outlined,
                      size: 18, color: cs.onSurface),
                  const SizedBox(width: 10),
                  const Text('Switch Role'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'dark_mode',
              child: Row(
                children: [
                  Icon(Icons.dark_mode_outlined, size: 18, color: cs.onSurface),
                  const SizedBox(width: 10),
                  const Text('Toggle Dark Mode'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'switch_role') {
              _showRoleSwitcher(context, notifier);
            } else if (value == 'dark_mode') {
              notifier.toggleDarkMode();
            }
          },
        ),
        const SizedBox(width: 4),
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
      builder: (_) => AppStateProvider(
        notifier: notifier,
        child: Builder(
          builder: (ctx) => _RoleSwitcherSheetInline(
            currentRole: notifier.state.currentRole,
            onRoleSelected: (role) {
              notifier.switchRole(role);
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Alert Bell with Badge
// ─────────────────────────────────────────────
class _AlertBell extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _AlertBell({required this.unreadCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Alerts',
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount > 9 ? '9+' : '$unreadCount',
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: AquaColors.statusRed,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Role Switcher (inline – used from AppBar)
// ─────────────────────────────────────────────
class _RoleSwitcherSheetInline extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleSelected;

  const _RoleSwitcherSheetInline({
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
// Nav Destination Data Model
// ─────────────────────────────────────────────
class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
