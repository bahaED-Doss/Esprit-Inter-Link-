import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../../../data/datasources/local/database_helper.dart';
import '../models/project_model.dart';

class ProjectDatabaseHelper {
  static final ProjectDatabaseHelper _instance = ProjectDatabaseHelper._internal();
  factory ProjectDatabaseHelper() => _instance;
  ProjectDatabaseHelper._internal();

  Future<Database> get db async => await DatabaseHelper.database;

  // 🔹 Debug utility to check project table columns
  Future<List<String>> getProjectColumns() async {
    final database = await db;
    final rows = await database.rawQuery("PRAGMA table_info('projects')");
    return rows.map((r) => r['name'] as String).toList();
  }

  // 🔹 Migration helper to ensure ON_HOLD support
  Future<void> _ensureProjectsTableSupportsOnHold(Database database) async {
    try {
      final rows = await database.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='projects'",
      );
      final createSql = rows.isNotEmpty ? (rows.first['sql'] as String? ?? '') : '';
      if (createSql.toUpperCase().contains('ON_HOLD')) return;

      await database.execute('ALTER TABLE projects RENAME TO projects_old;');

      await database.execute('''
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

      final oldCols = (await database.rawQuery("PRAGMA table_info('projects_old')"))
          .map((r) => r['name'] as String)
          .toList();

      const newCols = [
        'id', 'name', 'technologies_used', 'description', 'pm_id', 'assigned_to',
        'status', 'start_date', 'end_date', 'company_id', 'student_id', 'milestones',
        'created_at', 'completed_at'
      ];

      final commonCols = newCols.where((c) => oldCols.contains(c)).toList();
      if (commonCols.isNotEmpty) {
        final cols = commonCols.join(',');
        await database.execute('INSERT INTO projects ($cols) SELECT $cols FROM projects_old;');
      }

      await database.execute('DROP TABLE IF EXISTS projects_old;');
    } catch (e) {
      print('Migration failed: $e');
    }
  }

  // 🔹 Insert
  Future<int> insertProject(Project project) async {
    final database = await db;
    final map = await _filterToExistingColumns(database, _toDbMap(project)); // ✅ await added
    try {
      return await database.insert('projects', map);
    } on DatabaseException catch (e) {
      if (e.toString().contains('CHECK constraint failed') ||
          e.toString().contains('no such column')) {
        await _ensureProjectsTableSupportsOnHold(database);
        final newMap = await _filterToExistingColumns(database, _toDbMap(project)); // ✅ await added
        return await database.insert('projects', newMap);
      }
      rethrow;
    }
  }

// 🔹 Update
  Future<int> updateProject(Project project) async {
    final database = await db;
    final filtered = await _filterToExistingColumns(database, _toDbMap(project)); // ✅ await added
    filtered.remove('id');

    if (filtered.isEmpty) return 0;

    try {
      return await database.update(
        'projects',
        filtered,
        where: 'id = ?',
        whereArgs: [project.id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('CHECK constraint failed') ||
          e.toString().contains('no such column')) {
        await _ensureProjectsTableSupportsOnHold(database);
        final filtered2 = await _filterToExistingColumns(database, _toDbMap(project)); // ✅ await added
        filtered2.remove('id');
        return await database.update(
          'projects',
          filtered2,
          where: 'id = ?',
          whereArgs: [project.id],
        );
      }
      rethrow;
    }
  }


  // 🔹 Delete
  Future<int> deleteProject(int id) async {
    final database = await db;
    return await database.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // 🔹 Queries
  Future<Project?> getProjectById(int id) async {
    final database = await db;
    final rows = await database.query('projects', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isNotEmpty ? _fromDbMap(rows.first) : null;
  }

  Future<List<Project>> getAllProjects() async {
    final database = await db;
    final rows = await database.query('projects', orderBy: 'created_at DESC');
    return rows.map(_fromDbMap).toList();
  }

  Future<List<Project>> getProjectsByPM(int pmId) async {
    final database = await db;
    final rows = await database.query('projects', where: 'pm_id = ?', whereArgs: [pmId]);
    return rows.map(_fromDbMap).toList();
  }

  // 🔹 Utility helpers
  Map<String, dynamic> _toDbMap(Project p) {
    final map = p.toMap()..removeWhere((_, v) => v == null);
    if (p.id != null) map['id'] = p.id;
    return map;
  }

  Future<Map<String, dynamic>> _filterToExistingColumns(
      Database db, Map<String, dynamic> map) async {
    final cols = (await db.rawQuery("PRAGMA table_info('projects')"))
        .map((r) => r['name'] as String)
        .toList();
    return Map.fromEntries(map.entries.where((e) => cols.contains(e.key)));
  }

  Project _fromDbMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> milestones = [];
    if (map['milestones'] != null) {
      try {
        final raw = jsonDecode(map['milestones']);
        if (raw is List) {
          milestones = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (_) {}
    }

    return Project(
      id: map['id'] as int?,
      title: map['name'] ?? '',
      description: map['description'],
      status: map['status'] ?? 'ACTIVE',
      technologiesUsed: map['technologies_used'],
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
      companyId: map['company_id'],
      pmId: map['pm_id'] ?? 0,
      studentId: map['student_id'],
      assignedToEmail: map['assigned_to'],
      milestones: milestones,
    );
  }
}