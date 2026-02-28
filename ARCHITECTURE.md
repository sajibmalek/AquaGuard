# AquaGuard – Architecture & Best Practices

## App Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── status_color_helper.dart
│   └── widgets/
│       ├── animated_status_card.dart
│       └── safety_lock_indicator.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── aquarium_model.dart
│   │   ├── dashboard_model.dart
│   │   ├── auth_response_model.dart
│   │   ├── alert_model.dart
│   │   └── history_point_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── aquarium_repository.dart
│   │   ├── dashboard_repository.dart
│   │   ├── temperature_repository.dart
│   │   ├── water_quality_repository.dart
│   │   ├── lighting_repository.dart
│   │   ├── pump_repository.dart
│   │   ├── alert_repository.dart
│   │   └── history_repository.dart
│   └── services/
│       ├── api_service.dart
│       └── token_storage_service.dart
└── features/
    ├── auth/
    │   ├── cubit/
    │   │   └── auth_cubit.dart
    │   └── screens/
    │       └── login_screen.dart
    ├── aquarium/
    │   ├── cubit/
    │   │   └── aquarium_cubit.dart
    │   └── screens/
    │       └── aquarium_selection_screen.dart
    ├── dashboard/
    │   ├── cubit/
    │   │   └── dashboard_cubit.dart
    │   └── screens/
    │       └── dashboard_screen.dart
    ├── temperature/
    ├── water_quality/
    ├── health/
    ├── lighting/
    ├── pump/
    ├── alerts/
    ├── history/
    └── settings/
```

---

## Cubit Pattern (Mandatory Style)

### 1. Status Enum

```dart
enum FeatureStatus { initial, loading, success, error }
```

### 2. State Class

- **Immutable** (use `copyWith`)
- Contains `status` and optional `error`
- Exposes getters: `isLoading`, `isSuccess`, `isError`

```dart
class FeatureState extends Equatable {
  const FeatureState({
    this.status = FeatureStatus.initial,
    this.data,
    this.error,
  });

  final FeatureStatus status;
  final DataType? data;
  final String? error;

  bool get isLoading => status == FeatureStatus.loading;
  bool get isSuccess => status == FeatureStatus.success;
  bool get isError => status == FeatureStatus.error;

  FeatureState copyWith({...});

  @override
  List<Object?> get props => [status, data, error];
}
```

### 3. Cubit Behavior

- Emit **loading** first
- Call **repository** method (no API logic in Cubit)
- Handle success / failure explicitly
- Catch exceptions and emit **error** state

```dart
Future<void> loadData() async {
  emit(state.copyWith(status: FeatureStatus.loading, error: null));

  try {
    final data = await _repo.getData();
    emit(state.copyWith(status: FeatureStatus.success, data: data, error: null));
  } catch (e) {
    emit(state.copyWith(status: FeatureStatus.error, error: e.toString()));
  }
}
```

---

## Data Flow

```
UI (BlocBuilder/BlocConsumer)
    ↓ events
Cubit (emit states)
    ↓ calls
Repository (business logic)
    ↓ calls
ApiService (HTTP)
```

- **UI** never calls ApiService directly
- **Cubit** never contains API logic
- **Repository** is the single source of data access

---

## Authentication

- **JWT** stored in `flutter_secure_storage`
- **Refresh token** stored securely
- **Token expiry**: 401 responses trigger `onTokenExpired` → logout
- **Logout flow**: backend logout → clear token → clear prefs → emit initial

---

## Role-Aware UI

- `UserModel.role`: `admin`, `operator`, `viewer`
- Use `user.isAdmin`, `user.isOperator`, `user.isViewer` for conditional UI
- Disable unsafe actions for `viewer` role

---

## REST API Integration

- **Base URL**: `AppConstants.apiBaseUrl` (configurable via `--dart-define`)
- **Auth**: `Authorization: Bearer <token>` via Dio interceptor
- **Endpoints** (examples):
  - `POST /auth/login`
  - `POST /auth/logout`
  - `GET /aquariums`
  - `GET /aquariums/:id/dashboard`
  - `GET /aquariums/:id/temperature`
  - `PUT /aquariums/:id/lighting`
  - etc.

---

## Design Guidelines

- **Material Design 3** with `useMaterial3: true`
- **Status colors**: Green (normal), Amber (warning), Red (critical), Grey (offline)
- **Loading**: `CircularProgressIndicator` or skeleton
- **Empty**: Icon + message
- **Error**: Message + Retry button
- **Offline**: Disable unsafe actions, greyed UI

---

## Charts (fl_chart)

- Line charts for temperature, pH, ORP, TDS, turbidity, health scores
- Support 24h / 7d / 30d filters
- Animate on load, use gradients, avoid clutter

---

## Best Practices Summary

1. **Single responsibility**: One Cubit per feature
2. **Dependency injection**: Pass repositories/services via constructors
3. **Error handling**: Always catch in Cubit, emit error state
4. **Token management**: Centralize in ApiService + TokenStorageService
5. **Offline awareness**: Check `deviceOnline` before control actions
6. **Safety lock**: Disable controls when `safetyLockStatus` is true
