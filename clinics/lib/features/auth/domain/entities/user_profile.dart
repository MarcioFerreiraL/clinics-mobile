class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String? cpf;
  final String? email;
  final DateTime? birthDate;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.cpf,
    this.email,
    this.birthDate,
    this.avatarUrl,
  });

  String get firstName => fullName.split(' ').first;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    email: json['email'] as String?,
    birthDate: json['birth_date'] == null
        ? null
        : DateTime.parse(json['birth_date'] as String),
    avatarUrl: json['avatar_url'] as String?,
  );
}
