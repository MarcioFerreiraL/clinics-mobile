class ExamTypeRef {
  final String id;
  final String name;
  final String category;
  final String? description;

  const ExamTypeRef({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  factory ExamTypeRef.fromJson(Map<String, dynamic> json) => ExamTypeRef(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    description: json['description'] as String?,
  );
}

class ClinicSummary {
  final String id;
  final String name;
  final String? neighborhood;
  final double rating;
  final bool isVerified;
  final String? whatsappNumber;
  final String? logoUrl;

  const ClinicSummary({
    required this.id,
    required this.name,
    this.neighborhood,
    required this.rating,
    required this.isVerified,
    this.whatsappNumber,
    this.logoUrl,
  });

  factory ClinicSummary.fromJson(Map<String, dynamic> json) => ClinicSummary(
    id: json['id'] as String,
    name: json['name'] as String,
    neighborhood: json['neighborhood'] as String?,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    isVerified: json['is_verified'] as bool? ?? false,
    whatsappNumber: json['whatsapp_number'] as String?,
    logoUrl: json['logo_url'] as String?,
  );
}

/// Oferta de um exame em uma clínica (item da busca).
class ExamOffer {
  final String id;
  final ExamTypeRef examType;
  final ClinicSummary clinic;
  final double price;
  final double averagePrice;
  final double savings;
  final bool bestPrice;
  final double? distanceKm;
  final String? preparation;
  final String? paymentMethods;

  const ExamOffer({
    required this.id,
    required this.examType,
    required this.clinic,
    required this.price,
    required this.averagePrice,
    required this.savings,
    required this.bestPrice,
    this.distanceKm,
    this.preparation,
    this.paymentMethods,
  });

  factory ExamOffer.fromJson(Map<String, dynamic> json) => ExamOffer(
    id: json['id'] as String,
    examType: ExamTypeRef.fromJson(json['exam_type'] as Map<String, dynamic>),
    clinic: ClinicSummary.fromJson(json['clinic'] as Map<String, dynamic>),
    price: (json['price'] as num).toDouble(),
    averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0,
    savings: (json['savings'] as num?)?.toDouble() ?? 0,
    bestPrice: json['best_price'] as bool? ?? false,
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
    preparation: json['preparation'] as String?,
    paymentMethods: json['payment_methods'] as String?,
  );
}

class Page<T> {
  final List<T> items;
  final int total;
  final int page;
  final int totalPages;

  const Page({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page + 1 < totalPages;

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) => Page(
    items: (json['data'] as List)
        .map((e) => parse(e as Map<String, dynamic>))
        .toList(),
    total: json['total'] as int,
    page: json['page'] as int,
    totalPages: json['total_pages'] as int,
  );
}

class TrendingExam {
  final String id;
  final String name;
  final String category;
  final double minPrice;
  final int offersCount;

  const TrendingExam({
    required this.id,
    required this.name,
    required this.category,
    required this.minPrice,
    required this.offersCount,
  });

  factory TrendingExam.fromJson(Map<String, dynamic> json) => TrendingExam(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    minPrice: (json['min_price'] as num).toDouble(),
    offersCount: json['offers_count'] as int,
  );
}
