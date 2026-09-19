import 'package:flutter_test/flutter_test.dart';
import 'package:clinics/main.dart';

void main() {
  testWidgets('ClinicsApp smoke test and login screen render', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClinicsApp());
    await tester.pumpAndSettle();

    // Verify that Clinics brand and login screen text render.
    expect(find.text('Clinics'), findsWidgets);
    expect(find.text('Acesse sua conta'), findsOneWidget);
  });
}
