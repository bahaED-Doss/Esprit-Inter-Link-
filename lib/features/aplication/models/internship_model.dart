import 'package:flutter/foundation.dart';

/// Énumérations pour le type et le statut des stages
enum InternshipType { 
  PFE,           // Projet Fin d'Etudes
  SUMMER,        // Stage d'été
  INITIATION     // Stage d'initiation
}

enum InternshipStatus { 
  OPEN,          // Ouvert aux candidatures
  CLOSED,        // Fermé
  IN_PROGRESS    // En cours
}

/// Modèle de données Internship - Équivalent d'une entité Spring Boot
/// Représente une offre de stage dans le système
class Internship {
  final int? id;
  final String title;
  final String description;
  final String companyName;
  final String location;
  final InternshipType type;
  final InternshipStatus status;
  final int duration; // en mois
  final List<String> requirements;
  final List<String> skills;
  final DateTime startDate;
  final DateTime? endDate;
  final int hrId; // Clé étrangère vers le HR qui a créé l'offre
  final DateTime createdAt;
  final DateTime updatedAt;

  Internship({
    this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.location,
    this.type = InternshipType.SUMMER,
    this.status = InternshipStatus.OPEN,
    required this.duration,
    required this.requirements,
    required this.skills,
    required this.startDate,
    this.endDate,
    required this.hrId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Méthode copyWith pour créer une copie modifiée (pattern immutable)
  Internship copyWith({
    int? id,
    String? title,
    String? description,
    String? companyName,
    String? location,
    InternshipType? type,
    InternshipStatus? status,
    int? duration,
    List<String>? requirements,
    List<String>? skills,
    DateTime? startDate,
    DateTime? endDate,
    int? hrId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Internship(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hrId: hrId ?? this.hrId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'companyName': companyName,
      'location': location,
      'type': describeEnum(type),
      'status': describeEnum(status),
      'duration': duration,
      'requirements': requirements.join('|'), // Stocker comme string séparée par |
      'skills': skills.join('|'),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'hrId': hrId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Conversion depuis Map SQLite vers objet Internship
  factory Internship.fromMap(Map<String, dynamic> map) {
    InternshipType parseType(String? v) {
      if (v == null) return InternshipType.SUMMER;
      return InternshipType.values.firstWhere(
        (e) => describeEnum(e) == v,
        orElse: () => InternshipType.SUMMER,
      );
    }

    InternshipStatus parseStatus(String? v) {
      if (v == null) return InternshipStatus.OPEN;
      return InternshipStatus.values.firstWhere(
        (e) => describeEnum(e) == v,
        orElse: () => InternshipStatus.OPEN,
      );
    }

    List<String> parseList(String? v) {
      if (v == null || v.isEmpty) return [];
      return v.split('|').where((s) => s.isNotEmpty).toList();
    }

    return Internship(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      location: map['location'] as String? ?? '',
      type: parseType(map['type'] as String?),
      status: parseStatus(map['status'] as String?),
      duration: map['duration'] as int? ?? 3,
      requirements: parseList(map['requirements'] as String?),
      skills: parseList(map['skills'] as String?),
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate']) 
          : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      hrId: map['hrId'] as int? ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  /// Helper pour obtenir le type en format lisible
  String get typeDisplay {
    switch (type) {
      case InternshipType.PFE:
        return 'PFE';
      case InternshipType.SUMMER:
        return 'Summer Internship';
      case InternshipType.INITIATION:
        return 'Initiation';
    }
  }

  /// Helper pour obtenir le statut en format lisible
  String get statusDisplay {
    switch (status) {
      case InternshipStatus.OPEN:
        return 'Open';
      case InternshipStatus.CLOSED:
        return 'Closed';
      case InternshipStatus.IN_PROGRESS:
        return 'In Progress';
    }
  }
}
