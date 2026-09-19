import 'clinic.dart';

class Exam {
  final String id;
  final String clinicId;
  final Clinic? clinic;
  final String title;
  final String category; // Sangue, Raio-X, Consultas, Cardio, Ultrassom
  final String description;
  final String preparation;
  final double price;
  final String paymentMethods;
  final bool available;

  const Exam({
    required this.id,
    required this.clinicId,
    this.clinic,
    required this.title,
    required this.category,
    required this.description,
    required this.preparation,
    required this.price,
    this.paymentMethods = 'À vista ou Cartão',
    this.available = true,
  });

  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
}
