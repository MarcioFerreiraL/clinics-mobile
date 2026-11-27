import 'package:clinics/features/admin/data/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conta interna lê o JSON snake_case da API', () {
    final a = AdminAccount.fromJson({
      'id': '1',
      'full_name': 'Ana Gestora',
      'phone': '(81) 99999-0000',
      'role': 'CLINIC_MANAGER',
      'position': 'Gestor da clínica',
      'clinic_id': 'c1',
      'clinic_name': 'Clínica Santa Maria',
    });
    expect(a.fullName, 'Ana Gestora');
    expect(a.clinicName, 'Clínica Santa Maria');
  });

  test('matriz traz cargos com permissões e o escopo de visibilidade', () {
    final m = AdminMatrix.fromJson({
      'positions': [
        {
          'id': 'p1',
          'name': 'Administrador',
          'visibility_scope': 'all',
          'permissions': ['conta.listar'],
        },
        {
          'id': 'p2',
          'name': 'Gestor da clínica',
          'visibility_scope': 'own_clinic',
          'permissions': <String>[],
        },
      ],
      'permissions': [
        {'id': 'x1', 'key': 'conta.listar', 'label': 'Listar contas'},
      ],
    });
    expect(m.positions.first.seesAllClinics, isTrue);
    expect(m.positions.last.seesAllClinics, isFalse);
    expect(m.permissions.single.label, 'Listar contas');
  });

  test('conta sem cargo nem clínica é aceita', () {
    final a = AdminAccount.fromJson({
      'id': '2',
      'full_name': 'Sem Cargo',
      'phone': null,
      'role': 'PATIENT',
    });
    expect(a.position, isNull);
    expect(a.phone, '');
  });
}
