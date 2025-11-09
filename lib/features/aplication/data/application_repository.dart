import 'package:sqflite/sqflite.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import '../../../data/datasources/local/database_helper.dart';

/// Repository pour les opérations sur les stages et candidatures
class ApplicationRepository {
  // Suppression du paramètre dbHelper
  ApplicationRepository();

  Future<Database> get db async => await DatabaseHelper.database;

  // ===========================
  // INTERNSHIPS CRUD OPERATIONS
  // ===========================

  Future<int> insertInternship(Internship internship) async {
    final database = await db;
    return await database.insert('internships', internship.toMap());
  }

  Future<int> updateInternship(Internship internship) async {
    final database = await db;
    final updatedMap = internship.copyWith(updatedAt: DateTime.now()).toMap();
    return await database.update(
      'internships',
      updatedMap,
      where: 'id = ?',
      whereArgs: [internship.id],
    );
  }

  Future<int> deleteInternship(int id) async {
    final database = await db;
    return await database.delete(
      'internships',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================
  // APPLICATIONS CRUD OPERATIONS
  // ===========================

  Future<int> insertApplication(Application application) async {
    final database = await db;
    return await database.insert('applications', application.toMap());
  }

  Future<int> updateApplication(Application application) async {
    final database = await db;
    final updatedMap = application.copyWith(updatedAt: DateTime.now()).toMap();
    return await database.update(
      'applications',
      updatedMap,
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  Future<int> deleteApplication(int id) async {
    final database = await db;
    return await database.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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

// Ajoute ici les autres méthodes de recherche et de récupération si besoin
      }
  }

