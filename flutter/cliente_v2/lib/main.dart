import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/routes/app_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/stripe_service.dart';
import 'core/services/notification_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: This uses explicit options from firebase_options.dart for more reliable initialization.
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('Firebase Initialized Successfully');
  } catch (e, stack) {
    debugPrint('Firebase Initialization Error: $e');
    debugPrint(stack.toString());
    debugPrint(
      'Push Notifications and Phone Auth will be disabled until Firebase is configured.',
    );
  }

  await StripeService.instance.initialize();
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  // Initialize notifications if Firebase is ready
  if (isFirebaseInitialized) {
    container.read(notificationProvider).initialize();
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
