import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import '../../../data/datasources/local/database_helper.dart';

/// Database Helper pour les candidatures et stages
/// Gère toutes les opérations CRUD sur les tables internships et applications
class ApplicationDatabaseHelper {
  static final ApplicationDatabaseHelper _instance = ApplicationDatabaseHelper._internal();
  factory ApplicationDatabaseHelper() => _instance;
  ApplicationDatabaseHelper._internal();

  /// Récupère la base de données centralisée
  Future<Database> get db async {
    return await DatabaseHelper.database;
  }

  /// ===========================
  /// INTERNSHIPS CRUD OPERATIONS
  /// ===========================

  /// INSERT - Ajouter une nouvelle offre de stage
  Future<int> insertInternship(Internship internship) async {
    try {
      final database = await db;
      return await database.insert('internships', internship.toMap());
    } catch (e) {
      print('Error inserting internship: $e');
      rethrow;
    }
  }

  /// UPDATE - Modifier une offre de stage existante
  Future<int> updateInternship(Internship internship) async {
    try {
      final database = await db;
      final updatedMap = internship.copyWith(updatedAt: DateTime.now()).toMap();
      return await database.update(
        'internships',
        updatedMap,
        where: 'id = ?',
        whereArgs: [internship.id],
      );
    } catch (e) {
      print('Error updating internship: $e');
      rethrow;
    }
  }

  /// DELETE - Supprimer une offre de stage
  Future<int> deleteInternship(int id) async {
    try {
      final database = await db;
      return await database.delete(
        'internships',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting internship: $e');
      rethrow;
    }
  }

  /// SELECT - Récupérer une offre de stage par ID
  Future<Internship?> getInternshipById(int id) async {
    final database = await db;
    final res = await database.query(
      'internships',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isNotEmpty) return Internship.fromMap(res.first);
    return null;
  }

  /// SELECT - Récupérer toutes les offres de stage ouvertes
  Future<List<Internship>> getOpenInternships() async {
    final database = await db;
    final res = await database.query(
      'internships',
      where: 'status = ?',
      whereArgs: ['OPEN'],
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Internship.fromMap(m)).toList();
  }

  /// SELECT - Récupérer les offres de stage créées par un HR
  Future<List<Internship>> getInternshipsByHR(int hrId) async {
    final database = await db;
    final res = await database.query(
      'internships',
      where: 'hrId = ?',
      whereArgs: [hrId],
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Internship.fromMap(m)).toList();
  }

  /// SELECT - Rechercher des offres de stage par mot-clé
  Future<List<Internship>> searchInternships(String query) async {
    final database = await db;
    final q = '%$query%';
    final res = await database.query(
      'internships',
      where: 'title LIKE ? OR description LIKE ? OR companyName LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Internship.fromMap(m)).toList();
  }

  /// SELECT - Récupérer toutes les offres de stage (pour debug)
  Future<List<Internship>> getAllInternships() async {
    final database = await db;
    final res = await database.query('internships', orderBy: 'createdAt DESC');
    return res.map((m) => Internship.fromMap(m)).toList();
  }

  /// ===========================
  /// APPLICATIONS CRUD OPERATIONS
  /// ===========================

  /// INSERT - Ajouter une nouvelle candidature
  Future<int> insertApplication(Application application) async {
    try {
      final database = await db;
      return await database.insert('applications', application.toMap());
    } catch (e) {
      print('Error inserting application: $e');
      rethrow;
    }
  }

  /// UPDATE - Modifier une candidature existante
  Future<int> updateApplication(Application application) async {
    try {
      final database = await db;
      final updatedMap = application.copyWith(updatedAt: DateTime.now()).toMap();
      return await database.update(
        'applications',
        updatedMap,
        where: 'id = ?',
        whereArgs: [application.id],
      );
    } catch (e) {
      print('Error updating application: $e');
      rethrow;
    }
  }

  /// DELETE - Supprimer une candidature
  Future<int> deleteApplication(int id) async {
    try {
      final database = await db;
      return await database.delete(
        'applications',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting application: $e');
      rethrow;
    }
  }

  /// SELECT - Récupérer une candidature par ID
  Future<Application?> getApplicationById(int id) async {
    final database = await db;
    final res = await database.query(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isNotEmpty) return Application.fromMap(res.first);
    return null;
  }

  /// SELECT - Récupérer les candidatures d'un étudiant
  Future<List<Application>> getApplicationsByStudent(int studentId) async {
    final database = await db;
    final res = await database.query(
      'applications',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Application.fromMap(m)).toList();
  }

  /// SELECT - Récupérer les candidatures pour une offre de stage
  Future<List<Application>> getApplicationsByInternship(int internshipId) async {
    final database = await db;
    final res = await database.query(
      'applications',
      where: 'internshipId = ?',
      whereArgs: [internshipId],
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Application.fromMap(m)).toList();
  }

  /// SELECT - Vérifier si un étudiant a déjà postulé à un stage
  Future<bool> hasApplied(int studentId, int internshipId) async {
    final database = await db;
    final res = await database.query(
      'applications',
      where: 'studentId = ? AND internshipId = ?',
      whereArgs: [studentId, internshipId],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  /// SELECT - Récupérer l'application d'un étudiant pour un stage spécifique
  Future<Application?> getApplicationByStudentAndInternship(int studentId, int internshipId) async {
    final database = await db;
    final res = await database.query(
      'applications',
      where: 'studentId = ? AND internshipId = ?',
      whereArgs: [studentId, internshipId],
      limit: 1,
    );
    if (res.isNotEmpty) return Application.fromMap(res.first);
    return null;
  }

  /// SELECT - Récupérer les candidatures avec les détails du stage
  Future<List<Map<String, dynamic>>> getApplicationsWithInternshipDetails(int studentId) async {
    final database = await db;
    final res = await database.rawQuery('''
      SELECT 
        a.*,
        i.title as internshipTitle,
        i.companyName as companyName,
        i.location as location,
        i.type as internshipType
      FROM applications a
      INNER JOIN internships i ON a.internshipId = i.id
      WHERE a.studentId = ?
      ORDER BY a.createdAt DESC
    ''', [studentId]);
    return res;
  }

  /// SELECT - Compter le nombre de candidatures acceptées pour un étudiant
  Future<int> getAcceptedApplicationCount(int studentId) async {
    final database = await db;
    final res = await database.rawQuery(
      'SELECT COUNT(*) as count FROM applications WHERE studentId = ? AND status = ?',
      [studentId, 'ACCEPTED'],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  /// SELECT - Récupérer toutes les candidatures (pour debug)
  Future<List<Application>> getAllApplications() async {
    final database = await db;
    final res = await database.query('applications', orderBy: 'createdAt DESC');
    return res.map((m) => Application.fromMap(m)).toList();
  }

  /// ===========================
  /// HELPER METHODS
  /// ===========================

  /// Initialiser les données mock pour les stages (optionnel)
  Future<void> initializeMockInternshipsIfNeeded() async {
    final database = await db;
    
    // Vérifier si des stages existent déjà
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM internships')
    ) ?? 0;

    if (count > 0) {
      print('✅ Mock internships already exist');
      return;
    }

    print('🔨 Inserting mock internships...');
    
    // Créer quelques stages mock
    final mockInternships = [
      Internship(
        title: 'Web Developer Intern',
        description: 'Join our dynamic development team and gain hands-on experience with modern web technologies. You\'ll work on real projects and learn from experienced developers.',
        companyName: 'TechCorp',
        location: 'Tunis',
        type: InternshipType.SUMMER,
        status: InternshipStatus.OPEN,
        duration: 3,
        requirements: [
          'Basic knowledge of HTML, CSS and JavaScript',
          'Understanding of modern web frameworks',
          'Good communication skills',
          'Ability to work in a team environment'
        ],
        skills: ['HTML', 'CSS', 'JavaScript', 'React', 'Node.js'],
        startDate: DateTime.now().add(Duration(days: 30)),
        hrId: 3, // Assuming HR user with id 3
      ),
      Internship(
        title: 'Data Analysis Internship – Deloitte',
        description: 'Work with our data science team to analyze large datasets and create meaningful insights. Perfect opportunity to learn data analysis and visualization techniques.',
        companyName: 'Deloitte',
        location: 'Tunis',
        type: InternshipType.PFE,
        status: InternshipStatus.OPEN,
        duration: 6,
        requirements: [
          'Strong analytical skills',
          'Knowledge of statistics',
          'Experience with data analysis tools',
          'Problem-solving mindset'
        ],
        skills: ['Python', 'SQL', 'Data Visualization', 'Statistics'],
        startDate: DateTime.now().add(Duration(days: 45)),
        hrId: 3,
      ),
      Internship(
        title: 'Digital Marketing Internship – Orange',
        description: 'Join our marketing team to learn about digital marketing strategies, social media management, and content creation.',
        companyName: 'Orange',
        location: 'Sfax',
        type: InternshipType.SUMMER,
        status: InternshipStatus.OPEN,
        duration: 2,
        requirements: [
          'Creative mindset',
          'Good writing skills',
          'Social media knowledge',
          'Interest in digital marketing'
        ],
        skills: ['Social Media', 'Content Creation', 'SEO', 'Analytics'],
        startDate: DateTime.now().add(Duration(days: 20)),
        hrId: 3,
      ),
      Internship(
        title: 'Mechanical Engineering Internship – Airbus',
        description: 'Gain practical experience in mechanical engineering and aerospace industry. Work on real projects with our engineering team.',
        companyName: 'Airbus',
        location: 'Tunis',
        type: InternshipType.PFE,
        status: InternshipStatus.OPEN,
        duration: 6,
        requirements: [
          'Engineering student',
          'CAD software knowledge',
          'Understanding of mechanical principles',
          'Attention to detail'
        ],
        skills: ['CAD', 'SolidWorks', 'Mechanical Design', 'AutoCAD'],
        startDate: DateTime.now().add(Duration(days: 60)),
        hrId: 3,
      ),
      Internship(
        title: 'UI/UX Design Internship – Figma',
        description: 'Learn user interface and user experience design from industry experts. Create beautiful and functional designs.',
        companyName: 'Figma',
        location: 'Remote',
        type: InternshipType.SUMMER,
        status: InternshipStatus.OPEN,
        duration: 4,
        requirements: [
          'Design portfolio',
          'Basic Figma knowledge',
          'Creative thinking',
          'User-centered design mindset'
        ],
        skills: ['Figma', 'UI Design', 'UX Research', 'Prototyping'],
        startDate: DateTime.now().add(Duration(days: 15)),
        hrId: 3,
      ),
    ];

    for (final internship in mockInternships) {
      await database.insert('internships', internship.toMap());
    }

    print('✅ Mock internships inserted successfully!');
  }
}
