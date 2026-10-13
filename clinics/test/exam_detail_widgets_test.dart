import 'dart:io';

import 'package:clinics/features/clinic/domain/operating_hours.dart';
import 'package:clinics/features/exam/domain/exam_detail.dart';
import 'package:clinics/features/exam/presentation/exam_art.dart';
import 'package:clinics/features/exam/presentation/widgets/clinic_location_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ExamClinic _clinic({
  bool open = true,
  String? phone = '(81) 3634-1122',
  int reviews = 5,
}) => ExamClinic(
  id: 'c1',
  name: 'Clínica Santa Mariazinha',
  address: 'Rua João Alfredinho, 142',
  neighborhood: 'Centro',
  phoneNumber: phone,
  rating: 4.8,
  reviewCount: reviews,
  isVerified: true,
  openNow: open,
  operatingHours: const [
    OperatingHours(dayOfWeek: 1, opensAt: '06:30', closesAt: '18:00'),
    OperatingHours(dayOfWeek: 2, opensAt: '06:30', closesAt: '18:00'),
    OperatingHours(dayOfWeek: 6, opensAt: '06:30', closesAt: '12:00'),
  ],
);

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets(
    'card de local mostra clínica, status, avaliação, endereço, horários e ações',
    (tester) async {
      await tester.pumpWidget(_wrap(ClinicLocationCard(clinic: _clinic())));

      expect(find.text('LOCAL DE ATENDIMENTO'), findsOneWidget);
      expect(find.text('Clínica Santa Mariazinha'), findsOneWidget);
      expect(find.text('Aberto agora'), findsOneWidget);
      expect(find.text('4,8 · 5 avaliações'), findsOneWidget);
      expect(find.text('Rua João Alfredinho, 142 • Centro'), findsOneWidget);
      expect(find.text('Seg a Ter 06:30–18:00'), findsOneWidget);
      expect(find.text('Sáb 06:30–12:00'), findsOneWidget);
      expect(find.text('(81) 3634-1122'), findsOneWidget);
      expect(find.text('Como chegar'), findsOneWidget);
      expect(find.text('Ligar'), findsOneWidget);
    },
  );

  testWidgets(
    'clínica fechada e sem telefone: mostra "Fechado agora" e esconde "Ligar"',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClinicLocationCard(
            clinic: _clinic(open: false, phone: null, reviews: 1),
          ),
        ),
      );

      expect(find.text('Fechado agora'), findsOneWidget);
      expect(find.text('4,8 · 1 avaliação'), findsOneWidget);
      expect(find.text('Ligar'), findsNothing);
      expect(find.text('Como chegar'), findsOneWidget);
    },
  );

  test('cada categoria tem uma ilustração e o arquivo existe', () {
    for (final category in [
      'Sangue',
      'Raio-X',
      'Consultas',
      'Cardio',
      'Ultrassom',
      'Outra',
    ]) {
      final path = examArtAsset(category);
      expect(File(path).existsSync(), isTrue, reason: 'falta $path');
    }
    expect(examArtAsset('Sangue'), 'assets/exams/sangue.png');
    expect(examArtAsset('Outra'), 'assets/exams/padrao.png');
  });
}
