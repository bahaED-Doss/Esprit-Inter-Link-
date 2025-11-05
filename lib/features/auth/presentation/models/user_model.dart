class User {
  final int? id;
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final String? avatarPath;
  final String? aboutMe;

  // 🚀 AJOUTS POUR LE CV
  final String? resumePath;
  final String? resumeFileName;
  final String? resumeSize;

  User({
    this.id,
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    required this.role,
    required this.createdAt,
    this.avatarPath,
    this.aboutMe,
    this.resumePath,
    this.resumeFileName,
    this.resumeSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'avatarPath': avatarPath,
      'aboutMe': aboutMe,
      'resumePath': resumePath,
      'resumeFileName': resumeFileName,
      'resumeSize': resumeSize,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      fullName: map['fullName'],
      phone: map['phone'],
      role: map['role'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      avatarPath: map['avatarPath'],
      aboutMe: map['aboutMe'],
      resumePath: map['resumePath'],
      resumeFileName: map['resumeFileName'],
      resumeSize: map['resumeSize'],
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? avatarPath,
    String? aboutMe,
    String? resumePath,
    String? resumeFileName,
    String? resumeSize,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarPath: avatarPath ?? this.avatarPath,
      aboutMe: aboutMe ?? this.aboutMe,
      resumePath: resumePath ?? this.resumePath,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      resumeSize: resumeSize ?? this.resumeSize,
    );
  }
  Map<String, dynamic> toJsonForQr() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
    };
  }
}