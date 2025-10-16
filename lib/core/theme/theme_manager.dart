import 'package:flutter/material.dart';

/// Una clase simple para gestionar el estado del tema de la aplicación.
class ThemeManager {
  /// Un ValueNotifier que mantiene el ThemeMode actual.
  /// Widgets como MaterialApp pueden escucharlo para reconstruirse cuando cambie.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  /// Cambia entre el modo claro y oscuro.
  /// Si el tema actual es del sistema, por defecto cambia a claro.
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light || themeMode.value == ThemeMode.system) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }
}