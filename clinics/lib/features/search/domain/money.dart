/// Formata reais no padrão brasileiro: 1234.5 -> "R$ 1.234,50".
String formatPrice(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $intPart,${parts[1]}';
}
