class OperatingHours {
  final int dayOfWeek; // 1 = segunda ... 7 = domingo
  final String opensAt;
  final String closesAt;

  const OperatingHours({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
  });

  static const _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  String get dayLabel => _days[dayOfWeek - 1];

  factory OperatingHours.fromJson(Map<String, dynamic> json) => OperatingHours(
        dayOfWeek: json['day_of_week'] as int,
        opensAt: json['opens_at'] as String,
        closesAt: json['closes_at'] as String,
      );

  static List<OperatingHours> listFromJson(dynamic json) => (json as List? ?? [])
      .map((e) => OperatingHours.fromJson(e as Map<String, dynamic>))
      .toList();

  /// Resume em uma linha: "Seg a Sex 06:30–18:00 • Sáb 07:00–12:00".
  static String summarize(List<OperatingHours> hours) {
    if (hours.isEmpty) return 'Horário não informado';
    final sorted = [...hours]..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    final groups = <List<OperatingHours>>[];
    for (final h in sorted) {
      final last = groups.isEmpty ? null : groups.last;
      if (last != null &&
          last.last.opensAt == h.opensAt &&
          last.last.closesAt == h.closesAt &&
          last.last.dayOfWeek + 1 == h.dayOfWeek) {
        last.add(h);
      } else {
        groups.add([h]);
      }
    }
    return groups.map((g) {
      final days = g.length == 1
          ? g.first.dayLabel
          : '${g.first.dayLabel} a ${g.last.dayLabel}';
      return '$days ${g.first.opensAt}–${g.first.closesAt}';
    }).join(' • ');
  }
}
