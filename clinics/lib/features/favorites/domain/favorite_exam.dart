class FavoriteExam {
  final String examTypeId;
  final String name;
  final String category;

  const FavoriteExam({
    required this.examTypeId,
    required this.name,
    required this.category,
  });

  factory FavoriteExam.fromJson(Map<String, dynamic> json) => FavoriteExam(
    examTypeId: json['exam_type_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
  );
}
