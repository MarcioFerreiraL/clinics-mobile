import '../../clinic/domain/operating_hours.dart';
import '../../search/domain/exam_offer.dart';

class ExamClinic {
  final String id;
  final String name;
  final String? address;
  final String? neighborhood;
  final String? phoneNumber;
  final String? whatsappNumber;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool openNow;
  final List<OperatingHours> operatingHours;

  const ExamClinic({
    required this.id,
    required this.name,
    this.address,
    this.neighborhood,
    this.phoneNumber,
    this.whatsappNumber,
    this.latitude,
    this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.openNow,
    required this.operatingHours,
  });

  factory ExamClinic.fromJson(Map<String, dynamic> json) => ExamClinic(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    neighborhood: json['neighborhood'] as String?,
    phoneNumber: json['phone_number'] as String?,
    whatsappNumber: json['whatsapp_number'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['review_count'] as int? ?? 0,
    isVerified: json['is_verified'] as bool? ?? false,
    openNow: json['open_now'] as bool? ?? false,
    operatingHours: OperatingHours.listFromJson(json['operating_hours']),
  );
}

class ExamDetail {
  final String id;
  final ExamTypeRef examType;
  final double price;
  final double averagePrice;
  final double savings;
  final bool bestPrice;
  final String? preparation;
  final String? paymentMethods;
  final ExamClinic clinic;

  const ExamDetail({
    required this.id,
    required this.examType,
    required this.price,
    required this.averagePrice,
    required this.savings,
    required this.bestPrice,
    this.preparation,
    this.paymentMethods,
    required this.clinic,
  });

  factory ExamDetail.fromJson(Map<String, dynamic> json) => ExamDetail(
    id: json['id'] as String,
    examType: ExamTypeRef.fromJson(json['exam_type'] as Map<String, dynamic>),
    price: (json['price'] as num).toDouble(),
    averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0,
    savings: (json['savings'] as num?)?.toDouble() ?? 0,
    bestPrice: json['best_price'] as bool? ?? false,
    preparation: json['preparation'] as String?,
    paymentMethods: json['payment_methods'] as String?,
    clinic: ExamClinic.fromJson(json['clinic'] as Map<String, dynamic>),
  );
}

class ContactResult {
  final String whatsappUrl;
  final double estimatedSavings;

  const ContactResult({
    required this.whatsappUrl,
    required this.estimatedSavings,
  });

  factory ContactResult.fromJson(Map<String, dynamic> json) => ContactResult(
    whatsappUrl: json['whatsapp_url'] as String,
    estimatedSavings: (json['estimated_savings'] as num?)?.toDouble() ?? 0,
  );
}
