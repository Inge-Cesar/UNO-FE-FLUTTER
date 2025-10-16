import 'package:flutter/material.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'core/theme/theme_manager.dart';

class App extends StatelessWidget {
  final ThemeManager themeManager;
  const App({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Jueves App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1), // Azul oscuro profesional
              secondary: const Color(0xFFFFC107), // Acento ámbar/dorado
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1), // Mismo azul para consistencia
              secondary: const Color(0xFFFFC107), // Mismo acento
              brightness: Brightness.dark,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          themeMode: currentMode,
          home: const LoginPage(),
        );
      },
    );
  }
}