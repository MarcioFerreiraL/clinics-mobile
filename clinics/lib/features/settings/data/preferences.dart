import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sobrescrito em `main()` com a instância já carregada.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider não foi inicializado',
  ),
);

/// Bairro escolhido na tela inicial; `null` significa "todos os bairros".
class NeighborhoodNotifier extends Notifier<String?> {
  static const _key = 'neighborhood';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> select(String? neighborhood) async {
    final prefs = ref.read(sharedPreferencesProvider);
    neighborhood == null
        ? await prefs.remove(_key)
        : await prefs.setString(_key, neighborhood);
    state = neighborhood;
  }
}

final selectedNeighborhoodProvider =
    NotifierProvider<NeighborhoodNotifier, String?>(NeighborhoodNotifier.new);

/// Liga/desliga os alertas de queda de preço dos favoritos.
class PriceAlertsNotifier extends Notifier<bool> {
  static const _key = 'price_alerts';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    state = enabled;
  }
}

final priceAlertsProvider = NotifierProvider<PriceAlertsNotifier, bool>(
  PriceAlertsNotifier.new,
);
