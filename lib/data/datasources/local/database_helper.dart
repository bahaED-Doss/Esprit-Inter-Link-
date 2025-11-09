import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'esprit_interlink.db';

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Utiliser un chemin accessible (dossier du projet ou Desktop)
    String dbPath;

    if (Platform.isWindows) {
      // Utiliser le dossier Documents de l'utilisateur (plus accessible que Program Files)
      final userProfile = Platform.environment['USERPROFILE'];
      dbPath = join(userProfile!, 'Documents', 'EspritInterlink', dbName);

      // Créer le dossier s'il n'existe pas
      final directory = Directory(dirname(dbPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } else {
      // Pour mobile/autres plateformes
      final dbFolder = await getDatabasesPath();
      dbPath = join(dbFolder, dbName);
    }

    print('📊 Database path: $dbPath');

    return openDatabase(
      dbPath,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 6, // bumped to 6 to introduce ON_HOLD status and additional project columns
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    print('🔨 Creating database tables...');

    // Table users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT,
        role TEXT NOT NULL CHECK(role IN ('STUDENT', 'PM', 'HR')),
        internship_status TEXT DEFAULT 'CANDIDATE' CHECK(internship_status IN ('CANDIDATE', 'INTERN', 'COMPLETED')),
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Table projects (new schema includes ON_HOLD and extra columns)
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
        FOREIGN KEY(pm_id) REFERENCES users(id)
      );
    ''');

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
      );
    ''');

    // Table trophies (tous les trophies disponibles)
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
      );
    ''');

    // Table user_trophies (trophies débloqués par les utilisateurs)
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
      );
    ''');

    // Table notifications
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        message TEXT NOT NULL,
        read INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Insérer les utilisateurs mock
    await _insertMockUsers(db);

    // Ne plus insérer les projets mock automatiquement
    // await _insertMockProjects(db);

    // Insérer tous les trophies
    await _insertAllTrophies(db);

    print('✅ Database tables created successfully!');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
    // Migration safe: ajouter les colonnes manquantes sans faire échouer la db
    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE projects ADD COLUMN assigned_to TEXT;");
      } catch (_) {
        // ignore si existe déjà
      }

      // Ajouter la colonne assignedTo dans tasks pour compatibilité ascendante
      try {
        await db.execute("ALTER TABLE tasks ADD COLUMN assignedTo TEXT;");
      } catch (_) {
        // ignore si existe déjà
      }
    }

    // Ajouter la colonne pinned si on migre depuis <4
    if (oldVersion < 4) {
      try {
        await db.execute("ALTER TABLE tasks ADD COLUMN pinned INTEGER DEFAULT 0;");
      } catch (_) {
        // ignore si existe déjà
      }
    }

    // Ajouter la colonne technologies_used dans projects si on migre depuis <5
    if (oldVersion < 5) {
      try {
        await db.execute("ALTER TABLE projects ADD COLUMN technologies_used TEXT;");
      } catch (_) {
        // ignore si existe déjà
      }
    }

    // NEW: migrate to version 6 schema (adds ON_HOLD and extra columns)
    if (oldVersion < 6) {
      try {
        // Only perform a safe migration if a projects table exists
        final tbl = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='projects'");
        if (tbl.isNotEmpty) {
          // Rename old table
          try {
            await db.execute('ALTER TABLE projects RENAME TO projects_old;');
          } catch (_) {}

          // Create new projects table with updated schema
          await db.execute('''
            CREATE TABLE IF NOT EXISTS projects (
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
              FOREIGN KEY(pm_id) REFERENCES users(id)
            );
          ''');

          // Copy existing columns that match
          final oldInfo = await db.rawQuery("PRAGMA table_info('projects_old')");
          final oldCols = oldInfo.map((r) => r['name'] as String).toList();
          final newCols = [
            'id',
            'name',
            'technologies_used',
            'description',
            'pm_id',
            'assigned_to',
            'status',
            'start_date',
            'end_date',
            'company_id',
            'student_id',
            'milestones',
            'created_at',
            'completed_at'
          ];

          final colsToCopy = newCols.where((c) => oldCols.contains(c)).toList();
          if (colsToCopy.isNotEmpty) {
            final colsStr = colsToCopy.join(',');
            await db.execute('INSERT INTO projects ($colsStr) SELECT $colsStr FROM projects_old;');
          }

          // Drop old table
          try {
            await db.execute('DROP TABLE IF EXISTS projects_old;');
          } catch (_) {}
        } else {
          // No old projects table: ensure new exists
          await db.execute('''
            CREATE TABLE IF NOT EXISTS projects (
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
              FOREIGN KEY(pm_id) REFERENCES users(id)
            );
          ''');
        }
      } catch (e) {
        // ignore migration errors but log
        print('projects migration to v6 failed: $e');
      }
    }

    // S'assurer que la table notifications existe
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT CHECK(type IN ('TROPHY', 'TASK', 'PROJECT', 'SYSTEM')) DEFAULT 'SYSTEM',
          reference_id INTEGER,
          is_read INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
    } catch (_) {}
  }

  static Future<void> _insertMockUsers(Database db) async {
    await db.insert('users', {
      'id': 1,
      'email': 'student@esprit.tn',
      'name': 'Student User',
      'role': 'STUDENT',
      'internship_status': 'CANDIDATE' // Pas encore intern
    });
    await db.insert('users', {
      'id': 2,
      'email': 'pm@esprit.tn',
      'name': 'Project Manager',
      'role': 'PM',
      'internship_status': 'CANDIDATE' // Ignoré pour PM
    });
    await db.insert('users', {
      'id': 3,
      'email': 'hr@esprit.tn',
      'name': 'HR Manager',
      'role': 'HR',
      'internship_status': 'CANDIDATE' // Ignoré pour HR
    });
    print('👥 Mock users inserted: Student (1), PM (2), HR (3)');
  }

  static Future<void> _insertAllTrophies(Database db) async {
    // Student trophies
    final studentTrophies = [
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'STUDENT', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Welcome Aboard', 'description': 'You\'re Officially an Intern', 'role': 'STUDENT', 'xp': 100, 'trigger_type': 'BECOME_INTERN', 'trigger_value': 1},
      {'name': 'Task Warrior', 'description': 'Completed 5 Tasks', 'role': 'STUDENT', 'xp': 200, 'trigger_type': 'TASKS_COMPLETED', 'trigger_value': 5},
      {'name': 'Rising Star', 'description': 'Received Outstanding Feedback', 'role': 'STUDENT', 'xp': 250, 'trigger_type': 'OUTSTANDING_FEEDBACK', 'trigger_value': 1},
      {'name': 'Quiz Master', 'description': 'Completed 3 Quizzes', 'role': 'STUDENT', 'xp': 150, 'trigger_type': 'QUIZZES_COMPLETED', 'trigger_value': 3},
      {'name': 'First Week Champion', 'description': 'Survived Your First Week', 'role': 'STUDENT', 'xp': 175, 'trigger_type': 'FIRST_WEEK_COMPLETE', 'trigger_value': 1},
      {'name': 'Internship Legend', 'description': 'Perfect Internship Completion', 'role': 'STUDENT', 'xp': 500, 'trigger_type': 'INTERNSHIP_COMPLETE', 'trigger_value': 1},
    ];

    // PM trophies
    final pmTrophies = [
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'PM', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Project Initiator', 'description': 'Created Your First Project', 'role': 'PM', 'xp': 200, 'trigger_type': 'PROJECTS_CREATED', 'trigger_value': 1},
      {'name': 'Project Architect', 'description': 'Created 3 Projects', 'role': 'PM', 'xp': 300, 'trigger_type': 'PROJECTS_CREATED', 'trigger_value': 3},
      {'name': 'Task Master', 'description': 'Created Your First Task', 'role': 'PM', 'xp': 150, 'trigger_type': 'TASKS_CREATED', 'trigger_value': 1},
      {'name': 'Delegation Expert', 'description': 'Created 5 Tasks', 'role': 'PM', 'xp': 250, 'trigger_type': 'TASKS_CREATED', 'trigger_value': 5},
      {'name': 'Project Finisher', 'description': 'Completed Your First Project', 'role': 'PM', 'xp': 350, 'trigger_type': 'PROJECTS_COMPLETED', 'trigger_value': 1},
      {'name': 'Project Legend', 'description': 'Completed 3 Projects', 'role': 'PM', 'xp': 500, 'trigger_type': 'PROJECTS_COMPLETED', 'trigger_value': 3},
    ];

    // HR trophies
    final hrTrophies = [
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'HR', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Company Champion', 'description': 'Company Profile Complete', 'role': 'HR', 'xp': 150, 'trigger_type': 'COMPANY_PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'First Opportunity', 'description': 'Posted Your First Offer', 'role': 'HR', 'xp': 200, 'trigger_type': 'OFFERS_POSTED', 'trigger_value': 1},
      {'name': 'Opportunity Maker', 'description': 'Posted 3 Offers', 'role': 'HR', 'xp': 300, 'trigger_type': 'OFFERS_POSTED', 'trigger_value': 3},
      {'name': 'Talent Scout', 'description': 'Accepted Your First Intern', 'role': 'HR', 'xp': 250, 'trigger_type': 'STUDENTS_ACCEPTED', 'trigger_value': 1},
      {'name': 'Team Builder', 'description': 'Built a Team of 5', 'role': 'HR', 'xp': 400, 'trigger_type': 'STUDENTS_ACCEPTED', 'trigger_value': 5},
    ];

    for (var trophy in [...studentTrophies, ...pmTrophies, ...hrTrophies]) {
      await db.insert('trophies', trophy);
    }

    print('🏆 All trophies inserted successfully!');
  }

  // Ensure core tables exist; used to repair older DBs that may miss tables
  static Future<void> ensureSchemaExists(Database db) async {
    try {
      // users
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY,
          email TEXT NOT NULL UNIQUE,
          name TEXT,
          role TEXT NOT NULL CHECK(role IN ('STUDENT', 'PM', 'HR')),
          internship_status TEXT DEFAULT 'CANDIDATE' CHECK(internship_status IN ('CANDIDATE', 'INTERN', 'COMPLETED')),
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      // projects
      await db.execute('''
        CREATE TABLE IF NOT EXISTS projects (
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
          FOREIGN KEY(pm_id) REFERENCES users(id)
        );
      ''');

      // Ensure column exists (for older DBs that have the table but not the column)
      try {
        await db.execute("ALTER TABLE projects ADD COLUMN technologies_used TEXT;");
      } catch (_) {}

      // ensure other potential columns exist
      try { await db.execute("ALTER TABLE projects ADD COLUMN start_date TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE projects ADD COLUMN end_date TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE projects ADD COLUMN company_id INTEGER;"); } catch (_) {}
      try { await db.execute("ALTER TABLE projects ADD COLUMN student_id INTEGER;"); } catch (_) {}
      try { await db.execute("ALTER TABLE projects ADD COLUMN milestones TEXT;"); } catch (_) {}

      // tasks
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
        );
      ''');

      // trophies
      await db.execute('''
        CREATE TABLE IF NOT EXISTS trophies (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          role TEXT NOT NULL CHECK(role IN ('STUDENT', 'PM', 'HR')),
          xp INTEGER DEFAULT 0,
          trigger_type TEXT NOT NULL,
          trigger_value INTEGER,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      // user_trophies
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_trophies (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          trophy_id INTEGER NOT NULL,
          unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP,
          seen INTEGER DEFAULT 0,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY(trophy_id) REFERENCES trophies(id) ON DELETE CASCADE
        );
      ''');

      // notifications
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          message TEXT NOT NULL,
          read INTEGER DEFAULT 0,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP
        );
      ''');
    } catch (e) {
      // ignore: avoid_print
      print('ensureSchemaExists failed: $e');
    }
  }

  // À appeler au démarrage de l'app pour insérer les projets mock si la table est vide
  static Future<void> initializeMockProjectsIfNeeded() async {
    try {
      final db = await database;
      // Ensure core schema exists (in case we have a partial/old DB)
      await ensureSchemaExists(db);

      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM projects')
      );
      if (count == 0) {
        await db.insert('projects', {
          'id': 1,
          'name': 'Mobile Application',
          'description': 'Flutter internship management app',
          'pm_id': 2,
          'assigned_to': 'student@esprit.tn',
          'status': 'ACTIVE'
        });
        await db.insert('projects', {
          'id': 2,
          'name': 'Web Dashboard',
          'description': 'React admin panel for HR',
          'pm_id': 2,
          'assigned_to': 'student@esprit.tn',
          'status': 'ACTIVE'
        });
        await db.insert('projects', {
          'id': 3,
          'name': 'Backend API',
          'description': 'Spring Boot REST API',
          'pm_id': 2,
          'assigned_to': 'student@esprit.tn',
          'status': 'ACTIVE'
        });
        print('📁 Mock projects inserted at app startup');
      }
    } catch (e) {
      // ignore: avoid_print
      print('initializeMockProjectsIfNeeded error: $e');
    }
  }

  // Méthode pour mettre à jour le statut internship_status d'un étudiant
  static Future<void> updateStudentInternshipStatus(String email, String newStatus) async {
    final db = await database;
    await db.update(
      'users',
      {'internship_status': newStatus},
      where: 'email = ?',
      whereArgs: [email],
    );
    print('🔄 Student $email internship_status updated to $newStatus');
  }

  /// Assigne le premier projet disponible (du PM donné) à l'étudiant (par email).
  /// Retourne l'id du projet assigné ou null si aucun projet disponible.
  static Future<int?> assignFirstAvailableProjectToStudent(String studentEmail, {int pmId = 2}) async {
    final db = await database;

    // Chercher un projet non-assigné du PM
    final candidates = await db.query(
      'projects',
      where: '(assigned_to IS NULL OR assigned_to = ?) AND pm_id = ?',
      whereArgs: ['', pmId],
      orderBy: 'id ASC',
      limit: 1,
    );

    if (candidates.isEmpty) {
      // fallback: prendre premier projet du PM même s'il est assigné
      final fallback = await db.query('projects', where: 'pm_id = ?', whereArgs: [pmId], orderBy: 'id ASC', limit: 1);
      if (fallback.isEmpty) return null;
      final id = fallback.first['id'] as int?;
      if (id == null) return null;
      await db.update('projects', {'assigned_to': studentEmail}, where: 'id = ?', whereArgs: [id]);
      print('🔧 Assigned (fallback) project id $id to $studentEmail');
      return id;
    }

    final id = candidates.first['id'] as int?;
    if (id == null) return null;
    await db.update('projects', {'assigned_to': studentEmail}, where: 'id = ?', whereArgs: [id]);
    print('🔧 Assigned project id $id to $studentEmail');
    return id;
  }

  /// Désassigne tous les projets assignés à l'étudiant (utilisé lors du rollback ou du passage de intern -> candidate)
  static Future<int> unassignProjectsFromStudent(String studentEmail) async {
    final db = await database;
    final res = await db.update('projects', {'assigned_to': ''}, where: 'assigned_to = ?', whereArgs: [studentEmail]);
    print('🔄 Unassigned $res project(s) from $studentEmail');
    return res;
  }

  // Nouvelle méthode : récupérer le projet assigné à un étudiant via son email
  static Future<Map<String, dynamic>?> getProjectAssignedToStudent(String email) async {
    final db = await database;
    final rows = await db.query(
      'projects',
      where: 'assigned_to = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  // Nouvelle méthode : récupérer les tâches d'un projet par projectId
  static Future<List<Map<String, dynamic>>> getTasksByProjectId(int projectId) async {
    final db = await database;
    final tasks = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'status ASC, deadline ASC',
    );
    return tasks;
  }

  // Nouvelle méthode : récupérer directement les tâches d'un étudiant via son email
  // (cherche le projet assigné à l'email, puis récupère ses tâches)
  static Future<List<Map<String, dynamic>>> getTasksForStudentByEmail(String email) async {
    final project = await getProjectAssignedToStudent(email);
    if (project == null) return [];
    final projectId = project['id'] as int;
    return await getTasksByProjectId(projectId);
  }

  // =======================
  // Notification utilities
  // =======================

  static Future<int> insertNotification({
    required int userId,
    required String title,
    required String message,
    String type = 'SYSTEM',
    int? referenceId,
  }) async {
    final db = await database;
    return await db.insert('notifications', {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId, {bool unreadOnly = false}) async {
    final db = await database;
    final where = unreadOnly ? 'user_id = ? AND is_read = 0' : 'user_id = ?';
    final rows = await db.query(
      'notifications',
      where: where,
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows;
  }

  static Future<int> getUnreadNotificationCount(int userId) async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM notifications WHERE user_id = ? AND is_read = 0', [userId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> markAllNotificationsRead(int userId) async {
    final db = await database;
    return await db.update('notifications', {'is_read': 1}, where: 'user_id = ? AND is_read = 0', whereArgs: [userId]);
  }

  // ==================
  // Project/user utils
  // ==================

  static Future<Map<String, dynamic>?> getProjectById(int projectId) async {
    final db = await database;
    final rows = await db.query('projects', where: 'id = ?', whereArgs: [projectId], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static Future<int?> findUserIdByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  static Future<int?> getPMUserIdForProject(int projectId) async {
    final project = await getProjectById(projectId);
    if (project == null) return null;
    return project['pm_id'] as int?;
  }

  static Future<int> countOpenTasksForProject(int projectId) async {
    final db = await database;
    final res = await db.rawQuery(
      "SELECT COUNT(*) as c FROM tasks WHERE projectId = ? AND status IN ('TO_DO','DOING')",
      [projectId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<bool> hasUnreadEmptyProjectNotification(int pmUserId, int projectId) async {
    final db = await database;
    final res = await db.query(
      'notifications',
      where: 'user_id = ? AND type = ? AND reference_id = ? AND is_read = 0',
      whereArgs: [pmUserId, 'PROJECT', projectId],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  // Méthodes utilitaires
  static Future<void> resetDatabase() async {
    final dbPath = await _initDatabase();
    await deleteDatabase(dbPath.path);
    _database = null;
    await database; // Recréer
  }

  static Future<String> getDatabasePath() async {
    final db = await database;
    return db.path;
  }

  static Future<List<Map<String, dynamic>>> getTables() async {
    final db = await database;
    return await db.rawQuery(
      "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;"
    );
  }

  static Future<void> printDatabaseInfo() async {
    final path = await getDatabasePath();
    final tables = await getTables();

    print('\n' + '=' * 60);
    print('📊 DATABASE INFORMATION');
    print('=' * 60);
    print('📍 Location: $path');
    print('📋 Tables (${tables.length}):');
    for (var table in tables) {
      final name = table['name'];
      final db = await database;
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $name'));
      print('   - $name ($count rows)');
    }
    print('=' * 60 + '\n');
  }

  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
