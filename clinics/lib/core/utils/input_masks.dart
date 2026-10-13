import 'package:flutter/services.dart';

/// Máscara por padrão: `#` é um dígito; os demais caracteres são literais.
/// Mostra o texto formatado, mas o valor "de verdade" sai por [onlyDigits].
class MaskFormatter extends TextInputFormatter {
  final String mask;

  const MaskFormatter(this.mask);

  static const phone = MaskFormatter('(##) #####-####');
  static const cpf = MaskFormatter('###.###.###-##');
  static const date = MaskFormatter('##/##/####');

  int get _maxDigits => '#'.allMatches(mask).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = onlyDigits(newValue.text);
    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);

    final out = StringBuffer();
    var di = 0;
    for (var i = 0; i < mask.length && di < digits.length; i++) {
      if (mask[i] == '#') {
        out.write(digits[di++]);
      } else {
        out.write(mask[i]);
      }
    }
    final text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Converte "dd/MM/aaaa" em data; devolve null se incompleta ou inexistente.
DateTime? parseBrDate(String text) {
  final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
  if (m == null) return null;
  final day = int.parse(m[1]!),
      month = int.parse(m[2]!),
      year = int.parse(m[3]!);
  final date = DateTime(year, month, day);
  // DateTime "rola" datas inexistentes (31/02 vira 03/03); rejeita.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

String formatBrDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String toIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
