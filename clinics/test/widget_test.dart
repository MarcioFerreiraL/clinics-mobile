import 'package:clinics/features/auth/domain/entities/user_profile.dart';
import 'package:clinics/features/auth/presentation/providers/auth_provider.dart';
import 'package:clinics/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinics/features/settings/data/preferences.dart';

class _GuestAuth extends AuthNotifier {
  @override
  Future<UserProfile?> build() async => null;
}

void main() {
  testWidgets('visitante cai na tela de login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_GuestAuth.new),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ClinicsApp(),
      ),
    );
    // Avança a abertura (animação do logo) quadro a quadro.
    for (var i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
