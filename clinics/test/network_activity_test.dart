import 'package:clinics/core/network/network_activity.dart';
import 'package:clinics/core/widgets/network_activity_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conta leituras e envios em andamento sem ficar negativo', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(networkActivityProvider.notifier);

    n.start(write: false);
    n.start(write: true);
    expect(container.read(networkActivityProvider).busy, isTrue);
    expect(container.read(networkActivityProvider).sending, isTrue);

    n.finish(write: true);
    expect(container.read(networkActivityProvider).sending, isFalse);
    n.finish(write: false);
    n.finish(write: false); // fim extra não deixa o contador negativo
    expect(container.read(networkActivityProvider).busy, isFalse);
  });

  testWidgets('avisa que está carregando só quando a requisição demora', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: NetworkActivityOverlay(child: Scaffold(body: Text('tela'))),
        ),
      ),
    );

    container.read(networkActivityProvider.notifier).start(write: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Carregando…'), findsNothing); // rápida: sem indicador

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Carregando…'), findsOneWidget); // demorou: aparece

    container.read(networkActivityProvider.notifier).finish(write: false);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('tela'), findsOneWidget);
  });

  testWidgets('mostra "Enviando…" para POST, PUT e DELETE', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: NetworkActivityOverlay(child: Scaffold(body: Text('tela'))),
        ),
      ),
    );

    container.read(networkActivityProvider.notifier).start(write: true);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Enviando…'), findsOneWidget);
  });
}
