import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Requisições em andamento: [reads] são consultas (GET) e [writes] são envios (POST, PUT, DELETE).
class NetworkActivity {
  final int reads;
  final int writes;

  const NetworkActivity({this.reads = 0, this.writes = 0});

  bool get busy => reads + writes > 0;
  bool get sending => writes > 0;
}

class NetworkActivityNotifier extends Notifier<NetworkActivity> {
  @override
  NetworkActivity build() => const NetworkActivity();

  void start({required bool write}) => state = NetworkActivity(
    reads: state.reads + (write ? 0 : 1),
    writes: state.writes + (write ? 1 : 0),
  );

  void finish({required bool write}) => state = NetworkActivity(
    reads: (state.reads - (write ? 0 : 1)).clamp(0, 1 << 20),
    writes: (state.writes - (write ? 1 : 0)).clamp(0, 1 << 20),
  );
}

final networkActivityProvider =
    NotifierProvider<NetworkActivityNotifier, NetworkActivity>(
      NetworkActivityNotifier.new,
    );
