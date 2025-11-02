/// Modèle mock pour les projets
/// En production, ce modèle sera remplacé par celui du module projects
class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final int pmId; // ID du Project Manager

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.pmId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pmId': pmId,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      pmId: map['pmId'] as int,
    );
  }
}

