import '../../search/domain/exam_offer.dart';
import 'operating_hours.dart';

class ClinicExam {
  final String id;
  final ExamTypeRef examType;
  final double price;
  final bool bestPrice;
  final String? preparation;
  final String? paymentMethods;

  const ClinicExam({
    required this.id,
    required this.examType,
    required this.price,
    required this.bestPrice,
    this.preparation,
    this.paymentMethods,
  });

  factory ClinicExam.fromJson(Map<String, dynamic> json) => ClinicExam(
        id: json['id'] as String,
        examType: ExamTypeRef.fromJson(json['exam_type'] as Map<String, dynamic>),
        price: (json['price'] as num).toDouble(),
        bestPrice: json['best_price'] as bool? ?? false,
        preparation: json['preparation'] as String?,
        paymentMethods: json['payment_methods'] as String?,
      );
}

class ClinicDetail {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? neighborhood;
  final String city;
  final String state;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? logoUrl;
  final double rating;
  final int reviewCount;
  final int patientCount;
  final bool isVerified;
  final bool openNow;
  final List<OperatingHours> operatingHours;
  final List<ClinicExam> exams;

  const ClinicDetail({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.neighborhood,
    required this.city,
    required this.state,
    this.phoneNumber,
    this.whatsappNumber,
    this.logoUrl,
    required this.rating,
    required this.reviewCount,
    required this.patientCount,
    required this.isVerified,
    required this.openNow,
    required this.operatingHours,
    required this.exams,
  });

  factory ClinicDetail.fromJson(Map<String, dynamic> json) => ClinicDetail(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        address: json['address'] as String?,
        neighborhood: json['neighborhood'] as String?,
        city: json['city'] as String? ?? 'Surubim',
        state: json['state'] as String? ?? 'PE',
        phoneNumber: json['phone_number'] as String?,
        whatsappNumber: json['whatsapp_number'] as String?,
        logoUrl: json['logo_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: json['review_count'] as int? ?? 0,
        patientCount: json['patient_count'] as int? ?? 0,
        isVerified: json['is_verified'] as bool? ?? false,
        openNow: json['open_now'] as bool? ?? false,
        operatingHours: OperatingHours.listFromJson(json['operating_hours']),
        exams: (json['exams'] as List? ?? [])
            .map((e) => ClinicExam.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Review {
  final String id;
  final int rating;
  final String? comment;
  final String? authorName;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.rating,
    this.comment,
    this.authorName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        authorName: json['author_name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
