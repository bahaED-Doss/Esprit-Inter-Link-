class WorkExperience {
  final int? id;
  final int userId;
  final String title;
  final String company;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String duration; // Pour l'affichage UI, pas pour la DB

  WorkExperience({
    this.id,
    required this.userId,
    required this.title,
    required this.company,
    required this.startDate,
    this.endDate,
    this.description,
    this.duration = 'N/A',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'company': company,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    // Calcul de la durée ici (simplifié)
    String durationString = map['endDate'] == null ? 'Present' : 'Ended';

    return WorkExperience(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      company: map['company'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      description: map['description'],
      duration: durationString,
    );
  }
}

class Education {
  final int? id;
  final int userId;
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime? endDate;
  final String? fieldOfStudy; // Ajouté pour être complet
  final String? description; // Ajouté pour être complet

  Education({
    this.id,
    required this.userId,
    required this.degree,
    required this.institution,
    required this.startDate,
    this.endDate,
    this.fieldOfStudy,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'degree': degree,
      'institution': institution,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'fieldOfStudy': fieldOfStudy,
      'description': description,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'],
      userId: map['userId'],
      degree: map['degree'],
      institution: map['institution'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      fieldOfStudy: map['fieldOfStudy'],
      description: map['description'],
    );
  }
}

class Skill {
  final int? id;
  final int userId;
  final String name;

  Skill({this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, 'name': name};
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(id: map['id'], userId: map['userId'], name: map['name']);
  }
}

class Appreciation {
  final int? id;
  final int userId;
  final String title;
  final String context;
  final String year;

  Appreciation({this.id, required this.userId, required this.title, required this.context, required this.year});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'context': context,
      'year': year,
    };
  }

  factory Appreciation.fromMap(Map<String, dynamic> map) {
    return Appreciation(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      context: map['context'],
      year: map['year'],
    );
  }
}

// NOTE: Languages et Resume peuvent être stockés comme des listes dans le modèle User ou en tables séparées.
// Pour la simplicité de l'édition atomique, nous utiliserons une table simple pour les langues.

class Language {
  final int? id;
  final int userId;
  final String name;

  Language({this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, 'name': name};
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(id: map['id'], userId: map['userId'], name: map['name']);
  }
}