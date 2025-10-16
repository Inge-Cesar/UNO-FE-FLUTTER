import 'package:flutter/material.dart';
import 'features/login/presentation/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'Jueves App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFF733068), // Púrpura
              onPrimary: Color(0xFFFFFFFF), // Texto claro sobre primario
              secondary: Color(0xFFF2B33D), // Dorado
              onSecondary: Color(0xFF000000), // Texto oscuro sobre dorado
              error: Color(0xFFF29A2E),
              onError: Color(0xFF000000),
              background: Color(0xFF000000), // Fondo negro solicitado
              onBackground: Color(0xFFEDE7F6), // Texto claro sobre negro
              surface: Color(0xFF121212), // Superficie base oscura
              onSurface: Color(0xFFEDE7F6), // Texto claro sobre superficies
              surfaceVariant: Color(0xFF1A1A1A),
              onSurfaceVariant: Color(0xB3FFFFFF), // 70% blanco
              surfaceContainerLow: Color(0xFF151515),
              surfaceContainer: Color(0xFF1E1E1E), // Tarjetas y contenedores oscuros
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0x1AFFFFFF), // Blanco 10% sobre fondo oscuro
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0x59FFFFFF), width: 2), // Blanco 35%
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0x59FFFFFF), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFF2B33D), width: 2), // Dorado para foco
              ),
            ),
          ),
          home: const LoginPage(),
        );
  }
}