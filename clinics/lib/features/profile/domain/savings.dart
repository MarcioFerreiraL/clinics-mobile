class Savings {
  final double total;
  final int contactsCount;

  const Savings({required this.total, required this.contactsCount});

  factory Savings.fromJson(Map<String, dynamic> json) => Savings(
    total: (json['total_savings'] as num).toDouble(),
    contactsCount: json['contacts_count'] as int,
  );
}
