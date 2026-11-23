import 'package:clinics/features/access/data/access_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paciente não é conta interna e não tem permissões', () {
    final a = Access.fromJson({
      'role': 'PATIENT',
      'position': null,
      'clinic_id': null,
      'permissions': <String>[],
    });
    expect(a.isInternal, isFalse);
    expect(a.can('clinica.ver'), isFalse);
  });

  test('gerente é conta interna e só pode o que o servidor concedeu', () {
    final a = Access.fromJson({
      'role': 'CLINIC_MANAGER',
      'position': 'Gestor da clínica',
      'clinic_id': 'abc',
      'permissions': ['clinica.ver', 'exame.editar'],
    });
    expect(a.isInternal, isTrue);
    expect(a.can('exame.editar'), isTrue);
    expect(a.can('conta.gerenciar'), isFalse);
    expect(a.clinicId, 'abc');
  });
}
