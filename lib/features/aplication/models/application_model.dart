import 'package:flutter/foundation.dart';

/// Énumérations pour le statut de candidature
enum ApplicationStatus {
  PENDING,    // En attente
  ACCEPTED,   // Acceptée
  REJECTED,   // Rejetée
  WITHDRAWN   // Retirée par l'étudiant
}

/// Modèle de données Application - Équivalent d'une entité Spring Boot
/// Représente une candidature d'un étudiant à un stage
class Application {
  final int? id;
  final int internshipId; // Clé étrangère vers l'offre de stage
  final int studentId; // Clé étrangère vers l'étudiant
  final String fullName;
  final String email;
  final DateTime startDate;
  final DateTime endDate;
  final String motivation;
  final String? resumePath; // Chemin vers le CV
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    this.id,
    required this.internshipId,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.startDate,
    required this.endDate,
    required this.motivation,
    this.resumePath,
    this.status = ApplicationStatus.PENDING,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Méthode copyWith pour créer une copie modifiée (pattern immutable)
  Application copyWith({
    int? id,
    int? internshipId,
    int? studentId,
    String? fullName,
    String? email,
    DateTime? startDate,
    DateTime? endDate,
    String? motivation,
    String? resumePath,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Application(
      id: id ?? this.id,
      internshipId: internshipId ?? this.internshipId,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      motivation: motivation ?? this.motivation,
      resumePath: resumePath ?? this.resumePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'internshipId': internshipId,
      'studentId': studentId,
      'fullName': fullName,
      'email': email,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'motivation': motivation,
      'resumePath': resumePath,
      'status': describeEnum(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Conversion depuis Map SQLite vers objet Application
  factory Application.fromMap(Map<String, dynamic> map) {
    ApplicationStatus parseStatus(String? v) {
      if (v == null) return ApplicationStatus.PENDING;
      return ApplicationStatus.values.firstWhere(
        (e) => describeEnum(e) == v,
        orElse: () => ApplicationStatus.PENDING,
      );
    }

    return Application(
      id: map['id'] as int?,
      internshipId: map['internshipId'] as int? ?? 0,
      studentId: map['studentId'] as int? ?? 0,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now(),
      motivation: map['motivation'] as String? ?? '',
      resumePath: map['resumePath'] as String?,
      status: parseStatus(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Helper pour obtenir le statut en format lisible
  String get statusDisplay {
    switch (status) {
      case ApplicationStatus.PENDING:
        return 'Pending';
      case ApplicationStatus.ACCEPTED:
        return 'Accepted';
      case ApplicationStatus.REJECTED:
        return 'Rejected';
      case ApplicationStatus.WITHDRAWN:
        return 'Withdrawn';
    }
  }

  /// Helper pour obtenir la couleur du statut
  int get statusColor {
    switch (status) {
      case ApplicationStatus.PENDING:
        return 0xFFFFA726; // Orange
      case ApplicationStatus.ACCEPTED:
        return 0xFF66BB6A; // Green
      case ApplicationStatus.REJECTED:
        return 0xFFEF5350; // Red
      case ApplicationStatus.WITHDRAWN:
        return 0xFF9E9E9E; // Grey
    }
  }
}
