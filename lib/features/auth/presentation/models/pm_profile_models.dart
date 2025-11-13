class ProjectManagerProfile {
  final int? id;
  final int userId; // Clé étrangère vers l'utilisateur PM
  final String jobTitle;
  final String department;
  final String phone;
  final String city;
  final String country;

  ProjectManagerProfile({
    this.id,
    required this.userId,
    required this.jobTitle,
    required this.department,
    required this.phone,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jobTitle': jobTitle,
      'department': department,
      'phone': phone,
      'city': city,
      'country': country,
    };
  }

  factory ProjectManagerProfile.fromMap(Map<String, dynamic> map) {
    return ProjectManagerProfile(
      id: map['id'],
      userId: map['userId'],
      jobTitle: map['jobTitle'] ?? '',
      department: map['department'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
    );
  }

  ProjectManagerProfile copyWith({
    int? id,
    int? userId,
    String? jobTitle,
    String? department,
    String? phone,
    String? city,
    String? country,
  }) {
    return ProjectManagerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}