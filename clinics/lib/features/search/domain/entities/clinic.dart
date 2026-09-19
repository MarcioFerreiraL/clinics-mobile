class Clinic {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String whatsappNumber;
  final String phoneNumber;
  final String logoUrl;
  final double rating;
  final int patientCount;
  final bool isVerified;
  final String operatingHours;
  final List<String> photos;

  const Clinic({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.city = 'Surubim',
    this.state = 'PE',
    required this.whatsappNumber,
    required this.phoneNumber,
    required this.logoUrl,
    this.rating = 4.9,
    this.patientCount = 1200,
    this.isVerified = true,
    required this.operatingHours,
    this.photos = const [],
  });
}
