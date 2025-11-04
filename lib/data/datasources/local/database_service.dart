import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

import '../../../features/auth/presentation/models/hr_profile_models.dart';
import '../../../features/auth/presentation/models/passwordReset.dart';
import '../../../features/auth/presentation/models/pm_profile_models.dart';
import '../../../features/auth/presentation/models/profile_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'esprit_interlink.db');
    // Augmenter la version si le problème persiste, sinon garder la version 2.
    // L'option 1 (désinstaller l'app) reste la plus sûre si vous changez souvent la structure.
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // La stratégie de DROP/CREATE est correcte pour le développement avec version: 2
    if (oldVersion < newVersion) {
      // Pour les cas où les tables existaient sans les nouveaux champs
      await db.execute('DROP TABLE IF EXISTS work_experiences');
      await db.execute('DROP TABLE IF EXISTS educations');
      await db.execute('DROP TABLE IF EXISTS skills');
      await db.execute('DROP TABLE IF EXISTS appreciations');
      await db.execute('DROP TABLE IF EXISTS languages');
      await db.execute('DROP TABLE IF EXISTS company_profiles'); // Ajout de la table company_profiles
      await db.execute('DROP TABLE IF EXISTS users'); // Pour garantir l'ajout de avatarPath/aboutMe
      await db.execute('DROP TABLE IF EXISTS password_resets');

      await _createTables(db, newVersion);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // 🚀 TABLE USERS (CORRIGÉE: Ajout de avatarPath et aboutMe)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT,
        phone TEXT,
        role TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        avatarPath TEXT, 
        aboutMe TEXT ,
        resumePath TEXT,
        resumeFileName TEXT,
        resumeSize TEXT
      )
    ''');

    // Nouvelle table pour les réinitialisations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS password_resets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        token TEXT UNIQUE NOT NULL,
        expiresAt INTEGER NOT NULL,
        isUsed INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (email) REFERENCES users (email)
      )
    ''');

    // Work Experience
    await db.execute('''
      CREATE TABLE IF NOT EXISTS work_experiences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        description TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Education
    await db.execute('''
      CREATE TABLE IF NOT EXISTS educations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        degree TEXT NOT NULL,
        institution TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        fieldOfStudy TEXT,
        description TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Skills
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT UNIQUE NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Appreciations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appreciations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        context TEXT,
        year TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Languages
    await db.execute('''
      CREATE TABLE IF NOT EXISTS languages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT UNIQUE NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

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
  }

  // 🚀 NOUVELLE MÉTHODE : Mettre à jour spécifiquement le CV
  Future<int> updateUserResume({
    required int userId,
    required String path,
    required String fileName,
    required String size
  }) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'resumePath': path,
        'resumeFileName': fileName,
        'resumeSize': size,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 🚀 NOUVELLE MÉTHODE : Supprimer le CV (mettre à NULL)
  Future<int> deleteUserResume(int userId) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'resumePath': null,
        'resumeFileName': null,
        'resumeSize': null,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

// --- Project Manager Profile CRUD ---

  // 🚀 Insert ou Update PM Profile
  Future<int> savePMProfile(ProjectManagerProfile profile) async {
    final db = await database;
    if (profile.id != null) {
      final rows = await db.update('pm_profiles', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
      if (rows > 0) return rows;
    }
    return await db.insert('pm_profiles', profile.toMap());
  }

  // 🚀 Récupérer PM Profile par UserId
  Future<ProjectManagerProfile?> getPMProfileByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pm_profiles',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return ProjectManagerProfile.fromMap(maps.first);
  }

  // ADD THIS METHOD - Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  // 🚀 NOUVELLE MÉTHODE: Get user by ID (Implémentée)
  Future<User?> getUserById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return User.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  // 🚀 NOUVELLE MÉTHODE DANS DB SERVICE (à ajouter)
  Future<int> updateUserAvatarPath({required int id, required String avatarPath}) async {
    final db = await database;
    return await db.update(
      'users',
      {'avatarPath': avatarPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
// --- Company Profile CRUD (RH) ---

  // 🚀 Insert ou Update (Upsert) Company Profile
  Future<int> saveCompanyProfile(CompanyProfile profile) async {
    final db = await database;
    // On essaie d'abord de faire une mise à jour. Si l'ID est null, on insère.
    if (profile.id != null) {
      final rows = await db.update(
        'company_profiles',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      if (rows > 0) return rows;
    }
    // Si l'ID est null ou la mise à jour a échoué (car non existant), on insère
    return await db.insert('company_profiles', profile.toMap());
  }

  // 🚀 Récupérer Company Profile par UserId
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

  // --- Work Experience CRUD ---
  Future<int> insertWorkExperience(WorkExperience exp) async {
    final db = await database; return await db.insert('work_experiences', exp.toMap());
  }
  Future<List<WorkExperience>> getWorkExperiencesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('work_experiences', where: 'userId = ?', whereArgs: [userId], orderBy: 'startDate DESC');
    return maps.map((map) => WorkExperience.fromMap(map)).toList();
  }
  Future<int> updateWorkExperience(WorkExperience exp) async {
    final db = await database;
    return await db.update('work_experiences', exp.toMap(), where: 'id = ? AND userId = ?', whereArgs: [exp.id, exp.userId], conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<int> deleteWorkExperience(int id) async {
    final db = await database; return await db.delete('work_experiences', where: 'id = ?', whereArgs: [id]);
  }

  // --- Education CRUD ---
  Future<int> insertEducation(Education edu) async {
    final db = await database; return await db.insert('educations', edu.toMap());
  }
  Future<List<Education>> getEducationsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('educations', where: 'userId = ?', whereArgs: [userId], orderBy: 'startDate DESC');
    return maps.map((map) => Education.fromMap(map)).toList();
  }
  Future<int> updateEducation(Education edu) async {
    final db = await database; return await db.update('educations', edu.toMap(), where: 'id = ? AND userId = ?', whereArgs: [edu.id, edu.userId], conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<int> deleteEducation(int id) async {
    final db = await database; return await db.delete('educations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Skills CRUD ---
  Future<int> insertSkill(Skill skill) async {
    final db = await database; return await db.insert('skills', skill.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<List<Skill>> getSkillsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('skills', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => Skill.fromMap(map)).toList();
  }
  Future<int> deleteSkill(int id) async {
    final db = await database; return await db.delete('skills', where: 'id = ?', whereArgs: [id]);
  }

  // --- Appreciations CRUD ---
  Future<int> insertAppreciation(Appreciation app) async {
    final db = await database; return await db.insert('appreciations', app.toMap());
  }
  Future<List<Appreciation>> getAppreciationsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appreciations', where: 'userId = ?', whereArgs: [userId], orderBy: 'year DESC');
    return maps.map((map) => Appreciation.fromMap(map)).toList();
  }
  Future<int> updateAppreciation(Appreciation app) async {
    final db = await database;
    return await db.update('appreciations', app.toMap(), where: 'id = ? AND userId = ?', whereArgs: [app.id, app.userId], conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<int> deleteAppreciation(int id) async {
    final db = await database; return await db.delete('appreciations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Languages CRUD ---
  Future<int> insertLanguage(Language lang) async {
    final db = await database; return await db.insert('languages', lang.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<List<Language>> getLanguagesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('languages', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => Language.fromMap(map)).toList();
  }
  Future<int> deleteLanguage(int id) async {
    final db = await database; return await db.delete('languages', where: 'id = ?', whereArgs: [id]);
  }

  // 🚀 UPDATE USER PROFILE (CORRIGÉE: Ajout de avatarPath et aboutMe)
  Future<int> updateUserProfile(User user) async {
    final db = await database;
    final updatedMap = {
      'fullName': user.fullName,
      'phone': user.phone,
      'avatarPath': user.avatarPath, // Assurez-vous que cette ligne est là
      'aboutMe': user.aboutMe,
      'resumePath': user.resumePath,
      'resumeFileName': user.resumeFileName,
      'resumeSize': user.resumeSize,// Assurez-vous que cette ligne est là
    };
    return await db.update(
      'users',
      updatedMap,
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ADD THIS METHOD - Get all users for debugging
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

  // (updateUserProfile existait, mais celle-ci inclut le 'role')
  Future<int> adminUpdateUser(User user) async {
    final db = await database;
    final updatedMap = {
      'fullName': user.fullName,
      'phone': user.phone,
      'email': user.email,
      'role': user.role,
      // L'admin ne doit pas changer le mot de passe ici
    };
    return await db.update(
      'users',
      updatedMap,
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  // 🚀 NOUVELLE MÉTHODE : Supprimer un utilisateur (par l'Admin)
  Future<int> deleteUser(int id) async {
    final db = await database;
    // La suppression en cascade (ON DELETE CASCADE) dans _createTables
    // devrait supprimer les profils (étudiant, RH, PM) associés.
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
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

  // ADD THIS METHOD - Insert user
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      // Remarque: user.toMap() doit inclure avatarPath et aboutMe, ce qui est géré
      // par la mise à jour du modèle User effectuée précédemment.
      return await db.insert('users', user.toMap());
    } catch (e) {
      print('❌ Error inserting user: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }

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
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'password_resets',
      where: 'token = ?',
      whereArgs: [token],
    );

    if (maps.isEmpty) return null;

    return PasswordReset.fromMap(maps.first);
  }


  Future<void> markResetTokenAsUsed(String token) async {
    final db = await database;
    await db.update(
      'password_resets',
      {'isUsed': 1},
      where: 'token = ?',
      whereArgs: [token],
    );
  }

  Future<void> updateUserPassword({
    required String email,
    required String newPassword,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

}