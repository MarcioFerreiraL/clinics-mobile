import 'package:clinics/core/utils/input_masks.dart';
import 'package:flutter_test/flutter_test.dart';

String _type(MaskFormatter f, String text) => f
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
    .text;

void main() {
  test('telefone é formatado enquanto digita', () {
    expect(_type(MaskFormatter.phone, '8'), '(8');
    expect(_type(MaskFormatter.phone, '81998765432'), '(81) 99876-5432');
    expect(_type(MaskFormatter.phone, '819987654329999'), '(81) 99876-5432');
  });

  test('cpf e data são formatados', () {
    expect(_type(MaskFormatter.cpf, '52998224725'), '529.982.247-25');
    expect(_type(MaskFormatter.date, '20051990'), '20/05/1990');
  });

  test('onlyDigits guarda só os números', () {
    expect(onlyDigits('(81) 99876-5432'), '81998765432');
    expect(onlyDigits('529.982.247-25'), '52998224725');
  });

  test('datas dd/MM/aaaa viram ISO e datas inexistentes são rejeitadas', () {
    expect(toIsoDate(parseBrDate('20/05/1990')!), '1990-05-20');
    expect(parseBrDate('31/02/2020'), isNull);
    expect(parseBrDate('20/05'), isNull);
    expect(formatBrDate(DateTime(1990, 5, 2)), '02/05/1990');
  });
}
