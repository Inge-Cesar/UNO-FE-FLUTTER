import 'package:flutter_test/flutter_test.dart';
import 'package:jueves/app.dart'; 
import 'package:jueves/core/theme/theme_manager.dart';

void main() {
  testWidgets('App renders LoginPage title', (tester) async {
    final themeManager = ThemeManager();
    await tester.pumpWidget(App(themeManager: themeManager));

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
