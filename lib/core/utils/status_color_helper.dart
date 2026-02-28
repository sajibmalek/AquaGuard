import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Maps status levels to Material 3 status colors
Color getStatusColor(String level) {
  switch (level.toLowerCase()) {
    case 'normal':
    case 'good':
    case 'healthy':
    case 'low':
      return AppTheme.statusNormal;
    case 'warning':
    case 'moderate':
      return AppTheme.statusWarning;
    case 'critical':
    case 'danger':
    case 'unhealthy':
      return AppTheme.statusCritical;
    case 'offline':
    default:
      return AppTheme.statusOffline;
  }
}
