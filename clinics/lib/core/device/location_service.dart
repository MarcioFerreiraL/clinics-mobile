import 'package:geolocator/geolocator.dart';

enum LocationFailure { servicesOff, denied, deniedForever, unavailable }

class LocationException implements Exception {
  final LocationFailure failure;

  const LocationException(this.failure);

  String get message => switch (failure) {
    LocationFailure.servicesOff =>
      'Ative o GPS do aparelho para ordenar por proximidade.',
    LocationFailure.denied => 'Permissão de localização negada.',
    LocationFailure.deniedForever => 'Permissão de localização bloqueada. Libere nas configurações do aparelho.',
    LocationFailure.unavailable => 'Não foi possível obter sua localização.',
  };
}

/// Obtém a posição atual do aparelho (GPS). A posição não é armazenada (RN20).
class LocationService {
  Future<({double lat, double lng})> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.servicesOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationFailure.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.deniedForever);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (lat: p.latitude, lng: p.longitude);
    } catch (_) {
      throw const LocationException(LocationFailure.unavailable);
    }
  }
}
