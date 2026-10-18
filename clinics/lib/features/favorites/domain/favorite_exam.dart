class FavoriteExam {
  final String examTypeId;
  final String name;
  final String category;
  final double minPrice;
  final int offersCount;

  const FavoriteExam({
    required this.examTypeId,
    required this.name,
    required this.category,
    required this.minPrice,
    required this.offersCount,
  });

  factory FavoriteExam.fromJson(Map<String, dynamic> json) => FavoriteExam(
    examTypeId: json['exam_type_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    minPrice: (json['min_price'] as num).toDouble(),
    offersCount: json['offers_count'] as int,
  );
}
