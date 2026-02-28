import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/token_storage_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/aquarium/cubit/aquarium_cubit.dart';
import 'features/aquarium/screens/aquarium_selection_screen.dart';

class AquaGuardApp extends StatelessWidget {
  const AquaGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final api = ApiService();
            final tokenStorage = TokenStorageService();
            final authRepo = AuthRepository(
              apiService: api,
              tokenStorage: tokenStorage,
            );
            final cubit = AuthCubit(
              authRepository: authRepo,
              apiService: api,
              tokenStorage: tokenStorage,
            );
            cubit.dummyLogin();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => AquariumCubit()),
      ],
      child: MaterialApp(
        title: 'AquaGuard',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.isAuthenticated) {
          return const AquariumSelectionScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
