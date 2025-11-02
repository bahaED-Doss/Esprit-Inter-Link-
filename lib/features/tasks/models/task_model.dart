import 'package:flutter/foundation.dart';

/// Énumérations pour le statut et la priorité des tâches
enum TaskStatus { TO_DO, DOING, DONE }
enum TaskPriority { High, Medium, Low }

/// Modèle de données Task - Équivalent d'une entité Spring Boot
/// Représente une tâche dans le système de gestion de projet
class Task {
  final int? id;
  final String title;
  final String? description;
  final String? taskNumber;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? deadline;
  final int? sprintNumber;
  final int projectId; // Clé étrangère vers le projet
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pinned; // nouvelle propriété

  Task({
    this.id,
    required this.title,
    this.description,
    this.taskNumber,
    this.status = TaskStatus.TO_DO,
    this.priority = TaskPriority.Medium,
    this.deadline,
    this.sprintNumber,
    required this.projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pinned = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Méthode copyWith pour créer une copie modifiée (pattern immutable)
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? taskNumber,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? deadline,
    int? sprintNumber,
    int? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pinned,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskNumber: taskNumber ?? this.taskNumber,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      sprintNumber: sprintNumber ?? this.sprintNumber,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      pinned: pinned ?? this.pinned,
    );
  }

  /// Conversion vers Map pour SQLite (équivalent du @Entity en Spring)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'taskNumber': taskNumber,
      'status': describeEnum(status),
      'priority': describeEnum(priority),
      'deadline': deadline?.toIso8601String(),
      'sprintNumber': sprintNumber,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pinned': pinned ? 1 : 0,
    };
  }

  /// Conversion depuis Map SQLite vers objet Task
  factory Task.fromMap(Map<String, dynamic> map) {
    TaskPriority parsePriority(String? v) {
      if (v == null) return TaskPriority.Medium;
      return TaskPriority.values.firstWhere(
        (e) => describeEnum(e) == v,
        orElse: () => TaskPriority.Medium,
      );
    }

    TaskStatus parseStatus(String? v) {
      if (v == null) return TaskStatus.TO_DO;
      return TaskStatus.values.firstWhere(
        (e) => describeEnum(e) == v,
        orElse: () => TaskStatus.TO_DO,
      );
    }

    return Task(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      taskNumber: map['taskNumber'] as String?,
      status: parseStatus(map['status'] as String?),
      priority: parsePriority(map['priority'] as String?),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      sprintNumber: map['sprintNumber'] as int?,
      projectId: map['projectId'] as int,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      pinned: (map['pinned'] == null) ? false : ((map['pinned'] as int) == 1),
    );
  }
}
