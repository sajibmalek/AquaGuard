import 'package:flutter/material.dart';
import '../enums/app_enums.dart';

/// Returns the semantic color for a given [StatusLevel].
Color statusColor(BuildContext context, StatusLevel level) {
  final cs = Theme.of(context).colorScheme;
  switch (level) {
    case StatusLevel.normal:
      return AquaColors.statusGreen;
    case StatusLevel.warning:
      return AquaColors.statusAmber;
    case StatusLevel.critical:
      return AquaColors.statusRed;
    case StatusLevel.unknown:
      return cs.outline;
  }
}

/// Returns the icon for a given [StatusLevel].
IconData statusIcon(StatusLevel level) {
  switch (level) {
    case StatusLevel.normal:
      return Icons.check_circle_outline_rounded;
    case StatusLevel.warning:
      return Icons.warning_amber_rounded;
    case StatusLevel.critical:
      return Icons.error_outline_rounded;
    case StatusLevel.unknown:
      return Icons.help_outline_rounded;
  }
}

/// Semantic status color for DeviceStatus.
Color deviceStatusColor(DeviceStatus status) {
  switch (status) {
    case DeviceStatus.online:
      return AquaColors.statusGreen;
    case DeviceStatus.offline:
      return AquaColors.statusRed;
    case DeviceStatus.connecting:
      return AquaColors.statusAmber;
  }
}

/// App-wide semantic colors (status colors not tied to ColorScheme).
class AquaColors {
  AquaColors._();
  static const Color statusGreen = Color(0xFF2E7D32);
  static const Color statusAmber = Color(0xFFF57F17);
  static const Color statusRed = Color(0xFFC62828);
  static const Color statusGreenLight = Color(0xFFE8F5E9);
  static const Color statusAmberLight = Color(0xFFFFF8E1);
  static const Color statusRedLight = Color(0xFFFFEBEE);
}
