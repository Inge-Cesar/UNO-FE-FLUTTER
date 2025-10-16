import 'package:flutter_test/flutter_test.dart';
import 'package:jueves/app.dart'; 

void main() {
  testWidgets('App renders LoginPage title', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
