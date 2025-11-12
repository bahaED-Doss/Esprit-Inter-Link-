// Updated Project model to better reflect backend entity used in the Spring Boot example.
import 'dart:convert';

class Project {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final String? technologiesUsed;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? companyId;
  final int pmId;
  final int? studentId;
  final String? assignedToEmail;
  final List<Map<String, dynamic>> milestones;
  final int progress; // <-- new field

  Project({
    this.id,
    required this.title,
    this.description,
    this.status = 'ACTIVE',
    this.technologiesUsed,
    this.startDate,
    this.endDate,
    this.companyId,
    required this.pmId,
    this.studentId,
    this.assignedToEmail,
    List<Map<String, dynamic>>? milestones,
    this.progress = 0, // default to 0
  }) : milestones = milestones ?? [];

  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? technologiesUsed,
    DateTime? startDate,
    DateTime? endDate,
    int? companyId,
    int? pmId,
    int? studentId,
    String? assignedToEmail,
    List<Map<String, dynamic>>? milestones,
    int? progress, // <-- add here
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      technologiesUsed: technologiesUsed ?? this.technologiesUsed,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      companyId: companyId ?? this.companyId,
      pmId: pmId ?? this.pmId,
      studentId: studentId ?? this.studentId,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
      milestones: milestones ?? this.milestones,
      progress: progress ?? this.progress, // <-- add here
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'name': title,
      'description': description,
      'status': status,
      'technologies_used': technologiesUsed,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'company_id': companyId,
      'pm_id': pmId,
      'student_id': studentId,
      'assigned_to': assignedToEmail,
      'milestones': jsonEncode(milestones),
      'progress': progress, // <-- add here
    };
    if (id != null) map['id'] = id;
    return map..removeWhere((k, v) => v == null);
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> parsedMilestones = [];
    if (map['milestones'] != null) {
      try {
        final raw = map['milestones'] is String ? map['milestones'] as String : jsonEncode(map['milestones']);
        final dec = jsonDecode(raw);
        if (dec is List) {
          parsedMilestones = dec.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {
        parsedMilestones = [];
      }
    }

    return Project(
      id: map['id'] as int?,
      title: map['title'] as String? ?? map['name'] as String? ?? '',
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'ACTIVE',
      technologiesUsed: map['technologies_used'] as String?,
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date'] as String) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'] as String) : null,
      companyId: map['company_id'] as int?,
      pmId: map['pm_id'] as int? ?? 0,
      studentId: map['student_id'] as int?,
      assignedToEmail: map['assigned_to'] as String?,
      milestones: parsedMilestones,
      progress: map['progress'] as int? ?? 0, // <-- add here
    );
  }
}