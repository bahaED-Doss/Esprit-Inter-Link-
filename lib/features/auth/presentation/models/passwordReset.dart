class PasswordReset {
  final int? id;
  final String email;
  final String token;
  final DateTime expiresAt;
  final bool isUsed;
  final DateTime createdAt;

  PasswordReset({
    this.id,
    required this.email,
    required this.token,
    required this.expiresAt,
    this.isUsed = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isUsed': isUsed ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PasswordReset.fromMap(Map<String, dynamic> map) {
    return PasswordReset(
      id: map['id'],
      email: map['email'],
      token: map['token'],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt']),
      isUsed: map['isUsed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}