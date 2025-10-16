import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(App(
    themeManager: di.sl<ThemeManager>(),
  ));
}
