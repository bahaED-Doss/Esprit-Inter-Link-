import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'esprit_interlink.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table utilisateur
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            role TEXT
          )
        ''');
        // Table des trophées
        await db.execute('''
          CREATE TABLE trophies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT,
            type TEXT,
            title TEXT,
            subtitle TEXT,
            message TEXT,
            icon TEXT,
            xp INTEGER
          )
        ''');
        // Table des trophées débloqués par utilisateur
        await db.execute('''
          CREATE TABLE user_trophies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            trophy_id INTEGER,
            date_unlocked TEXT
          )
        ''');
        // Insertion des trophées HR
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'profile_pioneer',
          'title': 'Profile Pioneer',
          'subtitle': 'Profile Completed',
          'message': 'Great start! Your profile is ready to attract talent.',
          'icon': 'user_check',
          'xp': 100
        });
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'company_champion',
          'title': 'Company Champion',
          'subtitle': 'Company Profile Complete',
          'message': 'Your company shines! Students will love learning about you.',
          'icon': 'building',
          'xp': 150
        });
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'first_opportunity',
          'title': 'First Opportunity',
          'subtitle': 'Posted Your First Offer',
          'message': 'The journey begins! Your first opportunity is live.',
          'icon': 'megaphone',
          'xp': 200
        });
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'opportunity_maker',
          'title': 'Opportunity Maker',
          'subtitle': 'Posted 3 Offers',
          'message': "You're creating opportunities! Keep opening doors.",
          'icon': 'documents',
          'xp': 300
        });
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'talent_scout',
          'title': 'Talent Scout',
          'subtitle': 'Accepted Your First Intern',
          'message': 'Welcome to mentorship! A new journey begins.',
          'icon': 'handshake',
          'xp': 250
        });
        await db.insert('trophies', {
          'role': 'HR',
          'type': 'team_builder',
          'title': 'Team Builder',
          'subtitle': 'Built a Team of 5',
          'message': ",You're building the future! Your team is growing strong.",
          'icon': 'group',
          'xp': 400
        });
        // Insertion des trophées PM
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'profile_pioneer',
          'title': 'Profile Pioneer',
          'subtitle': 'Profile Completed',
          'message': 'Ready to lead! Your profile is set.',
          'icon': 'user_check',
          'xp': 100
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'project_initiator',
          'title': 'Project Initiator',
          'subtitle': 'Created Your First Project',
          'message': "Every great journey starts with one project. Let's build!",
          'icon': 'folder_plus',
          'xp': 200
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'project_architect',
          'title': 'Project Architect',
          'subtitle': 'Created 3 Projects',
          'message': "You're building an empire! Your vision is taking shape.",
          'icon': 'folders',
          'xp': 300
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'task_master',
          'title': 'Task Master',
          'subtitle': 'Created Your First Task',
          'message': 'Breaking it down! Great projects start with clear tasks.',
          'icon': 'clipboard_check',
          'xp': 150
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'delegation_expert',
          'title': 'Delegation Expert',
          'subtitle': 'Created 5 Tasks',
          'message': "You're organizing like a pro! Your team knows what to do.",
          'icon': 'clipboards',
          'xp': 250
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'project_finisher',
          'title': 'Project Finisher',
          'subtitle': 'Completed Your First Project',
          'message': "Victory! You've proven you can deliver excellence.",
          'icon': 'flag',
          'xp': 350
        });
        await db.insert('trophies', {
          'role': 'PM',
          'type': 'project_legend',
          'title': 'Project Legend',
          'subtitle': 'Completed 3 Projects',
          'message': "Legendary! You're a master of execution and delivery.",
          'icon': 'trophy_star',
          'xp': 500
        });
        // Insertion des trophées Student
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'profile_pioneer',
          'title': 'Profile Pioneer',
          'subtitle': 'Profile Completed',
          'message': "Looking good! You're ready to impress employers.",
          'icon': 'user_check',
          'xp': 100
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'welcome_aboard',
          'title': 'Welcome Aboard',
          'subtitle': "You're Officially an Intern",
          'message': 'Your journey begins here. Time to make an impact!',
          'icon': 'briefcase',
          'xp': 100
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'task_warrior',
          'title': 'Task Warrior',
          'subtitle': 'Completed 5 Tasks',
          'message': "You're crushing it! Your dedication shows.",
          'icon': 'checklist',
          'xp': 200
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'rising_star',
          'title': 'Rising Star',
          'subtitle': 'Received Outstanding Feedback',
          'message': 'Your supervisor is impressed. Shine bright!',
          'icon': 'star',
          'xp': 250
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'quiz_master',
          'title': 'Quiz Master',
          'subtitle': 'Completed 3 Quizzes',
          'message': 'Your knowledge is growing. Keep up the great work!',
          'icon': 'book_check',
          'xp': 150
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'first_week_champion',
          'title': 'First Week Champion',
          'subtitle': 'Survived Your First Week',
          'message': "One week down, many more to go. You've got this!",
          'icon': 'calendar',
          'xp': 175
        });
        await db.insert('trophies', {
          'role': 'Student',
          'type': 'internship_legend',
          'title': 'Internship Legend',
          'subtitle': 'Perfect Internship Completion',
          'message': "You've mastered every challenge. Congratulations!",
          'icon': 'trophy',
          'xp': 500
        });
      },
    );
  }

  // Exemple d'insertion
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Exemple de récupération
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }
}
