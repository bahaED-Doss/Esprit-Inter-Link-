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
    String dbPath;

    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      dbPath = join(userProfile!, 'Documents', 'EspritInterlink', dbName);

      final directory = Directory(dirname(dbPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } else {
      final dbFolder = await getDatabasesPath();
      dbPath = join(dbFolder, dbName);
    }

    print('Database path: $dbPath');

    return openDatabase(
      dbPath,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 6,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');

    // Table: users
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

    // Table: projects (enhanced schema)
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
      );
    ''');

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
      );
    ''');

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
      );
    ''');

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
      );
    ''');

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
      );
    ''');

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
      );
    ''');

    // Insert mock data
    await _insertMockUsers(db);
    await _insertAllTrophies(db);

    print('Database tables created successfully!');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 3) {
      try { await db.execute("ALTER TABLE projects ADD COLUMN assigned_to TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN assignedTo TEXT;"); } catch (_) {}
    }

    if (oldVersion < 4) {
      try { await db.execute("ALTER TABLE tasks ADD COLUMN pinned INTEGER DEFAULT 0;"); } catch (_) {}
    }

    if (oldVersion < 5) {
      try { await db.execute("ALTER TABLE projects ADD COLUMN technologies_used TEXT;"); } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS internships (
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
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS applications (
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
          );
        ''');
      } catch (e) {
        print('Error adding internships/applications: $e');
      }
    }

    if (oldVersion < 6) {
      try {
        await db.execute('DROP TABLE IF EXISTS notifications;');
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
          );
        ''');

        // Migrate projects table
        final tbl = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='projects'");
        if (tbl.isNotEmpty) {
          await db.execute('ALTER TABLE projects RENAME TO projects_old;');
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

          final oldCols = (await db.rawQuery("PRAGMA table_info('projects_old')"))
              .map((r) => r['name'] as String)
              .toList();
          final colsToCopy = ['id', 'name', 'technologies_used', 'description', 'pm_id', 'assigned_to', 'status',
            'start_date', 'end_date', 'company_id', 'student_id', 'milestones', 'created_at', 'completed_at']
              .where((c) => oldCols.contains(c))
              .join(', ');

          if (colsToCopy.isNotEmpty) {
            await db.execute('INSERT INTO projects ($colsToCopy) SELECT $colsToCopy FROM projects_old;');
          }
          await db.execute('DROP TABLE IF EXISTS projects_old;');
        }
      } catch (e) {
        print('Migration v6 failed: $e');
      }
    }

    // Ensure notifications table exists with correct schema
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT DEFAULT 'SYSTEM',
          reference_id INTEGER,
          is_read INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
    } catch (_) {}
  }

  // === MOCK DATA ===
  static Future<void> _insertMockUsers(Database db) async {
    await db.insert('users', {'id': 1, 'email': 'student@esprit.tn', 'name': 'Student User', 'role': 'STUDENT', 'internship_status': 'CANDIDATE'});
    await db.insert('users', {'id': 2, 'email': 'pm@esprit.tn', 'name': 'Project Manager', 'role': 'PM'});
    await db.insert('users', {'id': 3, 'email': 'hr@esprit.tn', 'name': 'HR Manager', 'role': 'HR'});
    await db.insert('users', {'id': 4, 'email': 'student2@esprit.tn', 'name': 'Test Student', 'role': 'STUDENT', 'internship_status': 'CANDIDATE'});
    print('Mock users inserted');
  }

  static Future<void> _insertAllTrophies(Database db) async {
    final trophies = [
      // Student
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'STUDENT', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Welcome Aboard', 'description': 'You\'re Officially an Intern', 'role': 'STUDENT', 'xp': 100, 'trigger_type': 'BECOME_INTERN', 'trigger_value': 1},
      {'name': 'Task Warrior', 'description': 'Completed 5 Tasks', 'role': 'STUDENT', 'xp': 200, 'trigger_type': 'TASKS_COMPLETED', 'trigger_value': 5},
      {'name': 'Rising Star', 'description': 'Received Outstanding Feedback', 'role': 'STUDENT', 'xp': 250, 'trigger_type': 'OUTSTANDING_FEEDBACK', 'trigger_value': 1},
      {'name': 'Quiz Master', 'description': 'Completed 3 Quizzes', 'role': 'STUDENT', 'xp': 150, 'trigger_type': 'QUIZZES_COMPLETED', 'trigger_value': 3},
      {'name': 'First Week Champion', 'description': 'Survived Your First Week', 'role': 'STUDENT', 'xp': 175, 'trigger_type': 'FIRST_WEEK_COMPLETE', 'trigger_value': 1},
      {'name': 'Internship Legend', 'description': 'Perfect Internship Completion', 'role': 'STUDENT', 'xp': 500, 'trigger_type': 'INTERNSHIP_COMPLETE', 'trigger_value': 1},
      // PM
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'PM', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Project Initiator', 'description': 'Created Your First Project', 'role': 'PM', 'xp': 200, 'trigger_type': 'PROJECTS_CREATED', 'trigger_value': 1},
      {'name': 'Project Architect', 'description': 'Created 3 Projects', 'role': 'PM', 'xp': 300, 'trigger_type': 'PROJECTS_CREATED', 'trigger_value': 3},
      {'name': 'Task Master', 'description': 'Created Your First Task', 'role': 'PM', 'xp': 150, 'trigger_type': 'TASKS_CREATED', 'trigger_value': 1},
      {'name': 'Delegation Expert', 'description': 'Created 5 Tasks', 'role': 'PM', 'xp': 250, 'trigger_type': 'TASKS_CREATED', 'trigger_value': 5},
      {'name': 'Project Finisher', 'description': 'Completed Your First Project', 'role': 'PM', 'xp': 350, 'trigger_type': 'PROJECTS_COMPLETED', 'trigger_value': 1},
      {'name': 'Project Legend', 'description': 'Completed 3 Projects', 'role': 'PM', 'xp': 500, 'trigger_type': 'PROJECTS_COMPLETED', 'trigger_value': 3},
      // HR
      {'name': 'Profile Pioneer', 'description': 'Profile Completed', 'role': 'HR', 'xp': 100, 'trigger_type': 'PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'Company Champion', 'description': 'Company Profile Complete', 'role': 'HR', 'xp': 150, 'trigger_type': 'COMPANY_PROFILE_COMPLETE', 'trigger_value': 1},
      {'name': 'First Opportunity', 'description': 'Posted Your First Offer', 'role': 'HR', 'xp': 200, 'trigger_type': 'OFFERS_POSTED', 'trigger_value': 1},
      {'name': 'Opportunity Maker', 'description': 'Posted 3 Offers', 'role': 'HR', 'xp': 300, 'trigger_type': 'OFFERS_POSTED', 'trigger_value': 3},
      {'name': 'Talent Scout', 'description': 'Accepted Your First Intern', 'role': 'HR', 'xp': 250, 'trigger_type': 'STUDENTS_ACCEPTED', 'trigger_value': 1},
      {'name': 'Team Builder', 'description': 'Built a Team of 5', 'role': 'HR', 'xp': 400, 'trigger_type': 'STUDENTS_ACCEPTED', 'trigger_value': 5},
    ];

    for (var t in trophies) {
      await db.insert('trophies', t);
    }
    print('All trophies inserted');
  }

  // === MOCK PROJECTS ===
  static Future<void> initializeMockProjectsIfNeeded() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM projects')) ?? 0;
    if (count == 0) {
      await db.insert('projects', {'id': 1, 'name': 'Mobile Application', 'description': 'Flutter internship app', 'pm_id': 2, 'assigned_to': 'student@esprit.tn', 'status': 'ACTIVE'});
      await db.insert('projects', {'id': 2, 'name': 'Web Dashboard', 'description': 'React admin panel', 'pm_id': 2, 'assigned_to': 'student@esprit.tn', 'status': 'ACTIVE'});
      await db.insert('projects', {'id': 3, 'name': 'Backend API', 'description': 'Spring Boot API', 'pm_id': 2, 'assigned_to': 'student@esprit.tn', 'status': 'ACTIVE'});
      print('Mock projects inserted');
    }
  }

  // === UTILS ===
  static Future<void> updateStudentInternshipStatus(String email, String status) async {
    final db = await database;
    await db.update('users', {'internship_status': status}, where: 'email = ?', whereArgs: [email]);
  }

  static Future<int?> assignFirstAvailableProjectToStudent(String email, {int pmId = 2}) async {
    final db = await database;
    final candidates = await db.query('projects', where: '(assigned_to IS NULL OR assigned_to = ?) AND pm_id = ?', whereArgs: ['', pmId], limit: 1);
    final row = candidates.isNotEmpty ? candidates.first : (await db.query('projects', where: 'pm_id = ?', whereArgs: [pmId], limit: 1)).firstOrNull;
    if (row == null) return null;
    final id = row['id'] as int;
    await db.update('projects', {'assigned_to': email}, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  static Future<int> unassignProjectsFromStudent(String email) async {
    final db = await database;
    return await db.update('projects', {'assigned_to': ''}, where: 'assigned_to = ?', whereArgs: [email]);
  }

  static Future<Map<String, dynamic>?> getProjectAssignedToStudent(String email) async {
    final db = await database;
    final rows = await db.query('projects', where: 'assigned_to = ?', whereArgs: [email], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, dynamic>>> getTasksByProjectId(int projectId) async {
    final db = await database;
    return await db.query('tasks', where: 'projectId = ?', whereArgs: [projectId], orderBy: 'status ASC, deadline ASC');
  }

  static Future<List<Map<String, dynamic>>> getTasksForStudentByEmail(String email) async {
    final project = await getProjectAssignedToStudent(email);
    return project == null ? [] : await getTasksByProjectId(project['id'] as int);
  }

  // === NOTIFICATIONS ===
  static Future<int> insertNotification({required int userId, required String title, required String message, String type = 'SYSTEM', int? referenceId}) async {
    final db = await database;
    return await db.insert('notifications', {
      'user_id': userId, 'title': title, 'message': message, 'type': type, 'reference_id': referenceId, 'is_read': 0, 'created_at': DateTime.now().toIso8601String()
    });
  }

  static Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId, {bool unreadOnly = false}) async {
    final db = await database;
    final where = unreadOnly ? 'user_id = ? AND is_read = 0' : 'user_id = ?';
    return await db.query('notifications', where: where, whereArgs: [userId], orderBy: 'created_at DESC');
  }

  static Future<int> getUnreadNotificationCount(int userId) async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0', [userId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> markAllNotificationsRead(int userId) async {
    final db = await database;
    return await db.update('notifications', {'is_read': 1}, where: 'user_id = ? AND is_read = 0', whereArgs: [userId]);
  }

  // Mark a single notification as read by id
  static Future<int> markNotificationRead(int notificationId) async {
    final db = await database;
    return await db.update('notifications', {'is_read': 1}, where: 'id = ?', whereArgs: [notificationId]);
  }

  // === PROJECT UTILS ===
  static Future<Map<String, dynamic>?> getProjectById(int id) async {
    final db = await database;
    final rows = await db.query('projects', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<int?> findUserIdByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    return rows.isEmpty ? null : rows.first['id'] as int?;
  }

  static Future<int?> getPMUserIdForProject(int projectId) async {
    final project = await getProjectById(projectId);
    return project?['pm_id'] as int?;
  }

  static Future<int> countOpenTasksForProject(int projectId) async {
    final db = await database;
    final res = await db.rawQuery("SELECT COUNT(*) FROM tasks WHERE projectId = ? AND status IN ('TO_DO','DOING')", [projectId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<bool> hasUnreadEmptyProjectNotification(int pmId, int projectId) async {
    final db = await database;
    final res = await db.query('notifications', where: 'user_id = ? AND type = ? AND reference_id = ? AND is_read = 0', whereArgs: [pmId, 'PROJECT', projectId], limit: 1);
    return res.isNotEmpty;
  }

  // === DEBUG ===
  static Future<void> resetDatabase() async {
    final db = await database;
    await deleteDatabase(db.path);
    _database = null;
    await database;
  }

  static Future<String> getDatabasePath() async => (await database).path;

  static Future<List<Map<String, dynamic>>> getTables() async {
    return await (await database).rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
  }

  static Future<void> printDatabaseInfo() async {
    final path = await getDatabasePath();
    final tables = await getTables();
    print('\nDATABASE INFO\nLocation: $path\nTables:');
    for (var t in tables) {
      final name = t['name'];
      final count = Sqflite.firstIntValue(await (await database).rawQuery('SELECT COUNT(*) FROM $name')) ?? 0;
      print('  • $name ($count rows)');
    }
    print('');
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final rows = await (await database).query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }
}