class CompanyProfile {
  final int? id;
  final int userId; // Clé étrangère vers l'utilisateur RH
  final String companyName;
  final String companyIdentifier; // Ex: SIREN, Matricule fiscale
  final String industrySector;
  final String companyAddress;
  final String city;
  final String country;
  final String companyDescription;
  final String? companyLogoPath; // Chemin vers le logo

  CompanyProfile({
    this.id,
    required this.userId,
    required this.companyName,
    required this.companyIdentifier,
    required this.industrySector,
    required this.companyAddress,
    required this.city,
    required this.country,
    required this.companyDescription,
    this.companyLogoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'companyIdentifier': companyIdentifier,
      'industrySector': industrySector,
      'companyAddress': companyAddress,
      'city': city,
      'country': country,
      'companyDescription': companyDescription,
      'companyLogoPath': companyLogoPath,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      id: map['id'],
      userId: map['userId'],
      companyName: map['companyName'] ?? '',
      companyIdentifier: map['companyIdentifier'] ?? '',
      industrySector: map['industrySector'] ?? '',
      companyAddress: map['companyAddress'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      companyDescription: map['companyDescription'] ?? '',
      companyLogoPath: map['companyLogoPath'],
    );
  }
  // 🚀 MÉTHODE copyWith - Version alternative
  CompanyProfile copyWith({
    int? id,
    int? userId,
    String? companyName,
    String? companyIdentifier,
    String? industrySector,
    String? companyAddress,
    String? city,
    String? country,
    String? companyDescription,
    String? companyLogoPath,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyIdentifier: companyIdentifier ?? this.companyIdentifier,
      industrySector: industrySector ?? this.industrySector,
      companyAddress: companyAddress ?? this.companyAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      companyDescription: companyDescription ?? this.companyDescription,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
    );
  }
}