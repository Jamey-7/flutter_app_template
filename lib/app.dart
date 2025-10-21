import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_themes.dart';
import 'core/providers/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeType = ref.watch(themeTypeProvider);
    final themeData = themeType.data;

    return MaterialApp.router(
      title: 'App Template',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromThemeData(themeData),
      themeMode: themeData.mode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: router,
    );
  }
}
