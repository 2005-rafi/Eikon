import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import 'router.dart';

class EikonApp extends ConsumerWidget {
  const EikonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Eikon',
      theme: AppTheme.getLightTheme(themeState.seedColor),
      darkTheme: AppTheme.getDarkTheme(themeState.seedColor),
      themeMode: themeState.mode,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
