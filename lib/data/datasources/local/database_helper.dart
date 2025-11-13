import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';
import 'dart:io'; // Import pour Platform

import '../../../features/auth/presentation/models/passwordReset.dart';
import '../../../features/auth/presentation/models/hr_profile_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;
  static const String dbName = 'esprit_interlink.db'; // Utilisation cohérente du nom

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 🚀 CORRECTION : Fusion de _initDatabase() en une seule version (d'instance)
  Future<Database> _initDatabase() async {
    String dbPath;

    if (Platform.isWindows) {
      // Logique Windows (si vous faites du dev Windows)
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null) {
        throw Exception("USERPROFILE environment variable not set.");
      }
      dbPath = join(userProfile, 'Documents', 'EspritInterlink', dbName);

      final directory = Directory(dirname(dbPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } else {
      // Logique Mobile (Android/iOS)
      final dbFolder = await getDatabasesPath();
      dbPath = join(dbFolder, dbName);
    }

    print('📁 Database path: $dbPath');

    return openDatabase(
      dbPath,
      onCreate: _createTables, // Utilise la méthode d'instance
      onUpgrade: _onUpgrade, // Utilise la méthode d'instance
      version: 6, // Utilisation de la version la plus élevée de votre fusion
    );
  }

  // 🚀 CORRECTION : Suppression de 'static'
  Future<void> _createTables(Database db, int version) async {
    print('🔄 Creating tables for version $version...');

    // Table: users (Utilisation de la version la plus complète)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT,
        phone TEXT,
        role TEXT NOT NULL CHECK(role IN ('student', 'pm', 'hr', 'admin')),
        createdAt INTEGER NOT NULL,
        avatarPath TEXT,
        aboutMe TEXT,
        resumePath TEXT,
        resumeFileName TEXT,
        resumeSize TEXT,
        internship_status TEXT DEFAULT 'CANDIDATE' CHECK(internship_status IN ('CANDIDATE', 'INTERN', 'COMPLETED'))
      )
    ''');
    print('✅ Table users created.');

    // Table: password_resets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS password_resets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        token TEXT UNIQUE NOT NULL,
        expiresAt INTEGER NOT NULL,
        isUsed INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (email) REFERENCES users (email) ON DELETE CASCADE
      )
    ''');
    print('✅ Table password_resets created.');

    // Table: projects
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        technologies_used TEXT,
        description TEXT,
        pm_id INTEGER NOT NULL,
        assigned_to TEXT,
        status TEXT DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE', 'COMPLETED', 'ARCHIVED', 'ON_HOLD')),
        start_date TEXT,
        end_date TEXT,
        company_id INTEGER,
        student_id INTEGER,
        milestones TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        completed_at TEXT,
        FOREIGN KEY(pm_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table projects created.');

    // Table: tasks
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        taskNumber TEXT,
        status TEXT CHECK(status IN ('TO_DO','DOING','DONE')) DEFAULT 'TO_DO',
        priority TEXT CHECK(priority IN ('High','Medium','Low')) DEFAULT 'Medium',
        deadline TEXT,
        sprintNumber INTEGER,
        projectId INTEGER NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        pinned INTEGER DEFAULT 0,
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table tasks created.');

    // Table: trophies
    await db.execute('''
      CREATE TABLE trophies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        role TEXT NOT NULL CHECK(role IN ('STUDENT', 'PM', 'HR')),
        xp INTEGER DEFAULT 0,
        trigger_type TEXT NOT NULL,
        trigger_value INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Table trophies created.');

    // Table: user_trophies
    await db.execute('''
      CREATE TABLE user_trophies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        trophy_id INTEGER NOT NULL,
        unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP,
        seen INTEGER DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(trophy_id) REFERENCES trophies(id) ON DELETE CASCADE,
        UNIQUE(user_id, trophy_id)
      )
    ''');
    print('✅ Table user_trophies created.');

    // Table: notifications
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT DEFAULT 'SYSTEM',
        reference_id INTEGER,
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table notifications created.');

    // Table: internships
    await db.execute('''
      CREATE TABLE internships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        companyName TEXT NOT NULL,
        location TEXT NOT NULL,
        type TEXT CHECK(type IN ('PFE', 'SUMMER', 'INITIATION')) DEFAULT 'SUMMER',
        status TEXT CHECK(status IN ('OPEN', 'CLOSED', 'IN_PROGRESS')) DEFAULT 'OPEN',
        duration INTEGER NOT NULL,
        requirements TEXT,
        skills TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        hrId INTEGER NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(hrId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table internships created.');

    // Table: applications
    await db.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        internshipId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        motivation TEXT,
        resumePath TEXT,
        status TEXT CHECK(status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')) DEFAULT 'PENDING',
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(internshipId) REFERENCES internships(id) ON DELETE CASCADE,
        FOREIGN KEY(studentId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table applications created.');

    // --- Tables de Profil (Student/HR/PM) ---
    // (Les tables Student (WorkExp, Edu, etc.) sont déjà créées ci-dessus,
    // mais elles s'appellent work_experiences, educations, etc.)

    // Company Profiles (RH)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS company_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER UNIQUE NOT NULL,
        companyName TEXT NOT NULL,
        companyIdentifier TEXT,
        industrySector TEXT,
        companyAddress TEXT,
        city TEXT,
        country TEXT,
        companyDescription TEXT,
        companyLogoPath TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table company_profiles created.');

    // PM Profiles
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pm_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER UNIQUE NOT NULL,
        jobTitle TEXT,
        department TEXT,
        phone TEXT,
        city TEXT,
        country TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table pm_profiles created.');

    // Insert mock data
    await _insertMockUsers(db);
    await _insertAllTrophies(db);

    print('✅ Database tables created successfully!');
  }

  // 🚀 CORRECTION : Suppression de 'static'
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Stratégie de suppression/recréation (dangereuse en production, ok en dev)
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS password_resets');
      await db.execute('DROP TABLE IF EXISTS projects');
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('DROP TABLE IF EXISTS trophies');
      await db.execute('DROP TABLE IF EXISTS user_trophies');
      await db.execute('DROP TABLE IF EXISTS notifications');
      await db.execute('DROP TABLE IF EXISTS internships');
      await db.execute('DROP TABLE IF EXISTS applications');
      await db.execute('DROP TABLE IF EXISTS company_profiles');
      await db.execute('DROP TABLE IF EXISTS pm_profiles');
      await db.execute('DROP TABLE IF EXISTS work_experiences');
      await db.execute('DROP TABLE IF EXISTS educations');
      await db.execute('DROP TABLE IF EXISTS skills');
      await db.execute('DROP TABLE IF EXISTS languages');
      await db.execute('DROP TABLE IF EXISTS appreciations');

      // Recréer toutes les tables
      await _createTables(db, newVersion);
    }
  }


  // === MOCK DATA (Suppression de 'static') ===
  Future<void> _insertMockUsers(Database db) async {
    // Note: Les rôles doivent correspondre (student, hr, pm, admin)
    await db.insert('users', {
      'id': 1,
      'email': 'student@esprit.tn',
      'fullName': 'Student User',
      'role': 'student',
      'internship_status': 'CANDIDATE',
      'password': 'hashed_password_placeholder'
    });
    await db.insert('users', {
      'id': 2,
      'email': 'pm@esprit.tn',
      'fullName': 'Project Manager',
      'role': 'pm',
      'password': 'hashed_password_placeholder'
    });
    await db.insert('users', {
      'id': 3,
      'email': 'hr@esprit.tn',
      'fullName': 'HR Manager',
      'role': 'hr',
      'password': 'hashed_password_placeholder'
    });
    await db.insert('users', {
      'id': 4,
      'email': 'student2@esprit.tn',
      'fullName': 'Test Student',
      'role': 'student',
      'internship_status': 'CANDIDATE',
      'password': 'hashed_password_placeholder'
    });
    print('Mock users inserted');
  }

  Future<void> _insertAllTrophies(Database db) async {
    // ... (Logique d'insertion des trophées inchangée)
  }

  // === Méthodes d'instance (Suppression de 'static') ===
  Future<void> initializeMockProjectsIfNeeded() async {
    // ...
  }

  Future<void> updateStudentInternshipStatus(String email,
      String status) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {'internship_status': status},
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e) {
      print('❌ Error updating internship status for $email: $e');
    }
  }

  // === Notifications helpers ===
  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    final db = await database;
    final rows = await db.query('notifications',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows;
  }

  Future<void> markAllNotificationsRead(int userId) async {
    final db = await database;
    await db.update('notifications', {'is_read': 1}, where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> markNotificationRead(int id) async {
    final db = await database;
    await db.update('notifications', {'is_read': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    final db = await database;
    final rows = await db.rawQuery('SELECT COUNT(*) as cnt FROM notifications WHERE user_id = ? AND is_read = 0', [userId]);
    if (rows.isEmpty) return 0;
    final cnt = rows.first['cnt'];
    if (cnt is int) return cnt;
    if (cnt is num) return cnt.toInt();
    return int.tryParse(cnt.toString()) ?? 0;
  }

  // === Project assignment helpers ===
  /// Assign first available ACTIVE project (student_id IS NULL) to the student with given email.
  /// Returns assigned project id or null if none.
  Future<int?> assignFirstAvailableProjectToStudent(String email) async {
    final db = await database;
    final user = await getUserByEmail(email);
    if (user == null || user.id == null) return null;
    final userId = user.id!;

    final rows = await db.query('projects',
        where: 'student_id IS NULL AND status = ?', whereArgs: ['ACTIVE'], limit: 1);
    if (rows.isEmpty) return null;
    final projectId = rows.first['id'];
    final id = projectId is int ? projectId : int.tryParse(projectId.toString());
    if (id == null) return null;

    await db.update('projects', {'student_id': userId, 'assigned_to': email}, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  /// Returns a project map assigned to the given student email (or null)
  Future<Map<String, dynamic>?> getProjectAssignedToStudent(String email) async {
    final db = await database;
    // Prefer direct assigned_to match
    final rows = await db.query('projects', where: 'assigned_to = ?', whereArgs: [email], limit: 1);
    if (rows.isNotEmpty) return rows.first;

    // Fallback: find by student_id if email corresponds to a user
    final user = await getUserByEmail(email);
    if (user != null && user.id != null) {
      final rows2 = await db.query('projects', where: 'student_id = ?', whereArgs: [user.id], limit: 1);
      if (rows2.isNotEmpty) return rows2.first;
    }

    return null;
  }

  // ... (Toutes les autres méthodes utilitaires (getProjectById, insertNotification, etc.)
  // doivent être des méthodes d'instance (SANS static))

  // ... (Toutes les méthodes CRUD de l'ancien DatabaseService.dart)
  // 🚀 Méthodes CRUD (d'instance)

  // (Get user by email)
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  // (Get user by ID)
  Future<User?> getUserById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  // (Update Avatar Path)
  Future<int> updateUserAvatarPath(
      {required int id, required String avatarPath}) async {
    final db = await database;
    return await db.update(
      'users',
      {'avatarPath': avatarPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // (Save Company Profile)
  Future<int> saveCompanyProfile(CompanyProfile profile) async {
    final db = await database;
    if (profile.id != null) {
      final rows = await db.update(
        'company_profiles',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      if (rows > 0) return rows;
    }
    return await db.insert('company_profiles', profile.toMap());
  }

  // (Get Company Profile)
  Future<CompanyProfile?> getCompanyProfileByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'company_profiles',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return CompanyProfile.fromMap(maps.first);
  }

  // ... (Insérez TOUTES les autres méthodes CRUD ici :
  // insertWorkExperience, getWorkExperiencesByUserId, updateWorkExperience, deleteWorkExperience,
  // insertEducation, getEducationsByUserId, updateEducation, deleteEducation,
  // insertSkill, getSkillsByUserId, deleteSkill,
  // insertAppreciation, getAppreciationsByUserId, updateAppreciation, deleteAppreciation,
  // insertLanguage, getLanguagesByUserId, deleteLanguage,
  // savePMProfile, getPMProfileByUserId,
  // updateUserResume, deleteUserResume) ...

  // (Update User Profile - Version complète)
  Future<int> updateUserProfile(User user) async {
    final db = await database;
    final updatedMap = {
      'fullName': user.fullName,
      'phone': user.phone,
      'avatarPath': user.avatarPath,
      'aboutMe': user.aboutMe,
      'resumePath': user.resumePath,
      'resumeFileName': user.resumeFileName,
      'resumeSize': user.resumeSize,
      'role': user.role, // Assurez-vous que l'admin peut mettre à jour le rôle
      'email': user.email,
    };
    return await db.update(
      'users',
      updatedMap,
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // (Admin update - méthode spécifique si nécessaire)
  Future<int> adminUpdateUser(User user) async {
    return updateUserProfile(user); // Réutilise la méthode principale
  }

  // (Admin delete)
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // (Get All Users)
  Future<List<User>> getAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return maps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  // (Insert User)
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap());
    } catch (e) {
      print('❌ Error inserting user: $e');
      rethrow;
    }
  }

  // === Notifications & utilitaires utilisés par TaskProvider ===
  /// Insert a notification row for a user
  Future<int> insertNotification({
    required int userId,
    required String title,
    required String message,
    String type = 'SYSTEM',
    int? referenceId,
  }) async {
    final db = await database;
    final map = {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    }..removeWhere((_, v) => v == null);

    return await db.insert('notifications', map);
  }

  /// Count open tasks (not DONE) for a given project
  Future<int> countOpenTasksForProject(int projectId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM tasks WHERE projectId = ? AND (status IS NULL OR status != ?)',
      [projectId, 'DONE'],
    );
    if (result.isEmpty) return 0;
    final cnt = result.first['cnt'];
    if (cnt is int) return cnt;
    if (cnt is int?) return cnt ?? 0;
    if (cnt is num) return cnt.toInt();
    return int.tryParse(cnt.toString()) ?? 0;
  }

  /// Get PM user id for a project (pm_id column in projects table)
  Future<int?> getPMUserIdForProject(int projectId) async {
    final db = await database;
    final rows = await db.query('projects', columns: ['pm_id'], where: 'id = ?', whereArgs: [projectId], limit: 1);
    if (rows.isEmpty) return null;
    final v = rows.first['pm_id'];
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Check if there's an unread 'PROJECT' notification for this PM about this project
  Future<bool> hasUnreadEmptyProjectNotification(int pmUserId, int projectId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM notifications WHERE user_id = ? AND type = ? AND reference_id = ? AND is_read = 0',
      [pmUserId, 'PROJECT', projectId],
    );
    if (rows.isEmpty) return false;
    final cnt = rows.first['cnt'];
    int n;
    if (cnt is int) n = cnt;
    else if (cnt is num) n = cnt.toInt();
    else n = int.tryParse(cnt.toString()) ?? 0;
    return n > 0;
  }

  // (Password Reset)
  Future<void> savePasswordReset({
    required String email,
    required String token,
    required DateTime expiresAt,
  }) async {
    final db = await database;
    await db.insert('password_resets', {
      'email': email,
      'token': token,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isUsed': 0,
      'createdAt': DateTime
          .now()
          .millisecondsSinceEpoch,
    });
  }

  Future<PasswordReset?> getPasswordReset(String token) async {
    try {
      final db = await database;
      final rows = await db.query('password_resets', where: 'token = ?', whereArgs: [token], limit: 1);
      if (rows.isEmpty) return null;
      return PasswordReset.fromMap(rows.first);
    } catch (e) {
      print('❌ Error getting password reset for token $token: $e');
      return null;
    }
  }

  Future<void> markResetTokenAsUsed(String token) async {
    try {
      final db = await database;
      await db.update('password_resets', {'isUsed': 1}, where: 'token = ?', whereArgs: [token]);
    } catch (e) {
      print('❌ Error marking reset token as used: $e');
    }
  }

  Future<int> updateUserPassword({
    required String email,
    required String newPassword,
  }) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // (Get Role Stats)
  Future<Map<String, double>> getRoleStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT role, COUNT(*) as count FROM users GROUP BY role'
    );
    Map<String, double> stats = {};
    for (var row in result) {
      stats[row['role'] as String] = (row['count'] as int).toDouble();
    }
    return stats;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}

// Compatibility wrapper to preserve older static-style API used across the codebase/tests
class DatabaseHelper {
  /// Access underlying database
  static Future<Database> get database => DatabaseService().database;

  /// Reset the database file (used by tests to ensure a fresh DB)
  static Future<void> resetDatabase() async {
    try {
      if (DatabaseService._database != null) {
        await DatabaseService._database!.close();
        DatabaseService._database = null;
      }
    } catch (_) {}

    String path;
    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        path = join(userProfile, 'Documents', 'EspritInterlink', DatabaseService.dbName);
      } else {
        final dbFolder = await getDatabasesPath();
        path = join(dbFolder, DatabaseService.dbName);
      }
      // deleteDatabase is provided by sqflite
      await deleteDatabase(path);
    } catch (_) {
      // ignore
    }
  }

  static Future<void> initializeMockProjectsIfNeeded() => DatabaseService().initializeMockProjectsIfNeeded();
  static Future<Map<String, dynamic>?> getProjectAssignedToStudent(String email) => DatabaseService().getProjectAssignedToStudent(email);
  static Future<int> getUnreadNotificationCount(int userId) => DatabaseService().getUnreadNotificationCount(userId);
  static Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) => DatabaseService().getNotificationsForUser(userId);
  static Future<void> markAllNotificationsRead(int userId) => DatabaseService().markAllNotificationsRead(userId);
  static Future<void> markNotificationRead(int id) => DatabaseService().markNotificationRead(id);
  static Future<void> updateStudentInternshipStatus(String email, String status) => DatabaseService().updateStudentInternshipStatus(email, status);
  static Future<int?> assignFirstAvailableProjectToStudent(String email) => DatabaseService().assignFirstAvailableProjectToStudent(email);
  static Future<int> insertNotification({required int userId, required String title, required String message, String type = 'SYSTEM', int? referenceId}) => DatabaseService().insertNotification(userId: userId, title: title, message: message, type: type, referenceId: referenceId);
  static Future<User?> getUserById(int id) => DatabaseService().getUserById(id);
  static Future<User?> getUserByEmail(String email) => DatabaseService().getUserByEmail(email);
  static Future<int> countOpenTasksForProject(int projectId) => DatabaseService().countOpenTasksForProject(projectId);
  static Future<int?> getPMUserIdForProject(int projectId) => DatabaseService().getPMUserIdForProject(projectId);
  static Future<bool> hasUnreadEmptyProjectNotification(int pmUserId, int projectId) => DatabaseService().hasUnreadEmptyProjectNotification(pmUserId, projectId);
}
