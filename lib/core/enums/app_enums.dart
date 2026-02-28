/// User role within the aquarium system.
enum UserRole {
  admin,
  operator,
  viewer;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.operator:
        return 'Operator';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Full control – manage devices, users, and settings';
      case UserRole.operator:
        return 'Control devices and view all data';
      case UserRole.viewer:
        return 'Read-only access – monitoring only';
    }
  }

  bool get canControl => this == UserRole.admin || this == UserRole.operator;
  bool get canManageSettings => this == UserRole.admin;
}

/// Health/parameter status level.
enum StatusLevel {
  normal,
  warning,
  critical,
  unknown;

  String get label {
    switch (this) {
      case StatusLevel.normal:
        return 'Normal';
      case StatusLevel.warning:
        return 'Warning';
      case StatusLevel.critical:
        return 'Critical';
      case StatusLevel.unknown:
        return 'Unknown';
    }
  }
}

/// Device connectivity state.
enum DeviceStatus { online, offline, connecting }

/// Alert severity.
enum AlertSeverity { info, warning, critical }
