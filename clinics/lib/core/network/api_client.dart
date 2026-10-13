import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'network_activity.dart';
import 'api_config.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

/// Avisa o app quando a API responde 401 a uma requisição com token (sessão expirada).
class SessionEvents {
  void Function()? onExpired;
}

final sessionEventsProvider = Provider((ref) => SessionEvents());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  // Conta as requisições em andamento para o indicador global de carregamento.
  // Atualiza fora do quadro atual (microtask) para não mexer em providers durante o build.
  void track(RequestOptions o, {required bool start}) {
    final write = o.method.toUpperCase() != 'GET';
    final activity = ref.read(networkActivityProvider.notifier);
    Future.microtask(
      () =>
          start ? activity.start(write: write) : activity.finish(write: write),
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        track(options, start: true);
        final token = await storage.read();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onResponse: (response, handler) {
        track(response.requestOptions, start: false);
        handler.next(response);
      },
      onError: (e, handler) async {
        track(e.requestOptions, start: false);
        final sentToken = e.requestOptions.headers.containsKey('Authorization');
        if (e.response?.statusCode == 401 && sentToken) {
          await storage.clear();
          ref.read(sessionEventsProvider).onExpired?.call();
        }
        handler.next(e);
      },
    ),
  );
  return dio;
});
