import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../../../data/datasources/local/database_helper.dart';

/// Database Helper pour les tâches - Utilise la DB centralisée
/// Gère toutes les opérations CRUD sur la table tasks
class TaskDatabaseHelper {
  static final TaskDatabaseHelper _instance = TaskDatabaseHelper._internal();
  factory TaskDatabaseHelper() => _instance;
  TaskDatabaseHelper._internal();

  /// Récupère la base de données centralisée
  Future<Database> get db async {
    return await DatabaseHelper.database;
  }

  /// INSERT - Ajouter une nouvelle tâche
  Future<int> insertTask(Task task) async {
    try {
      final database = await db;
      return await database.insert('tasks', task.toMap());
    } catch (e) {
      print('Error inserting task: $e');
      rethrow;
    }
  }

  /// UPDATE - Modifier une tâche existante
  Future<int> updateTask(Task task) async {
    try {
      final database = await db;
      final updatedMap = task.copyWith(updatedAt: DateTime.now()).toMap();
      return await database.update(
        'tasks',
        updatedMap,
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  /// DELETE - Supprimer une tâche
  Future<int> deleteTask(int id) async {
    try {
      final database = await db;
      return await database.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  /// SELECT - Récupérer une tâche par ID
  Future<Task?> getTaskById(int id) async {
    final database = await db;
    final res = await database.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isNotEmpty) return Task.fromMap(res.first);
    return null;
  }

  /// SELECT - Récupérer toutes les tâches d'un projet (pour PM)
  Future<List<Task>> getTasksByProject(int projectId) async {
    final database = await db;
    final res = await database.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'sprintNumber ASC, createdAt DESC',
    );
    return res.map((m) => Task.fromMap(m)).toList();
  }

  /// SELECT - Récupérer les tâches d'un utilisateur dans un projet (pour Student)
  /// Maintenant, la relation d'affectation se fait dans `projects.assigned_to` (email),
  /// donc on vérifie que le projet demandé est bien assigné à l'utilisateur avant de renvoyer ses tâches.
  Future<List<Task>> getTasksByUserAndProject(int userId, int projectId) async {
    final database = await db;

    // 1) Récupérer l'email de l'utilisateur
    final userRows = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) return [];
    final String? email = userRows.first['email'] as String?;
    if (email == null) return [];

    // 2) Vérifier que le projet est assigné à cet email
    final projectRows = await database.query(
      'projects',
      where: 'id = ? AND assigned_to = ?',
      whereArgs: [projectId, email],
      limit: 1,
    );
    if (projectRows.isEmpty) {
      // L'utilisateur n'est pas assigné à ce projet -> aucune tâche
      return [];
    }

    // 3) Récupérer les tâches du projetn
    final res = await database.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'status ASC, deadline ASC',
    );
    return res.map((m) => Task.fromMap(m)).toList();
  }

  /// SELECT avec filtres avancés (status, priority, sprint)
  Future<List<Task>> filterTasks({
    int? projectId,
    TaskStatus? status,
    TaskPriority? priority,
    int? sprint,
  }) async {
    final database = await db;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (projectId != null) {
      whereClauses.add('projectId = ?');
      whereArgs.add(projectId);
    }
    if (status != null) {
      whereClauses.add('status = ?');
      whereArgs.add(status.toString().split('.').last);
    }
    if (priority != null) {
      whereClauses.add('priority = ?');
      whereArgs.add(priority.toString().split('.').last);
    }
    if (sprint != null) {
      whereClauses.add('sprintNumber = ?');
      whereArgs.add(sprint);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final res = await database.query(
      'tasks',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt DESC',
    );
    return res.map((m) => Task.fromMap(m)).toList();
  }

  /// Récupérer le nombre de tâches complétées par un utilisateur
  /// Utilisé pour débloquer le trophée "Task Warrior" (5 tâches)
  /// On compte maintenant les tâches dans le projet assigné à l'étudiant (projects.assigned_to)
  Future<int> getCompletedTaskCount(int userId) async {
    final database = await db;

    // Récupérer email utilisateur
    final userRows = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) return 0;
    final String? email = userRows.first['email'] as String?;
    if (email == null) return 0;

    // Récupérer le projet assigné à cet email
    final projectRows = await database.query(
      'projects',
      where: 'assigned_to = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (projectRows.isEmpty) return 0;
    final int projectId = projectRows.first['id'] as int;

    // Compter les tâches DONE pour ce projet
    final res = await database.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE projectId = ? AND status = ?',
      [projectId, 'DONE'],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  /// Récupérer le nombre de tâches créées par un PM
  /// Utilisé pour débloquer les trophées PM (Task Master: 1, Delegation Expert: 5)
  Future<int> getCreatedTaskCount(int pmId) async {
    final database = await db;
    // On compte les tâches dans les projets du PM
    final res = await database.rawQuery('''
      SELECT COUNT(*) as count FROM tasks t
      INNER JOIN projects p ON t.projectId = p.id
      WHERE p.pm_id = ?
    ''', [pmId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  /// Récupérer toutes les tâches (pour debug uniquement)
  Future<List<Task>> getAllTasks() async {
    final database = await db;
    final res = await database.query('tasks');
    return res.map((m) => Task.fromMap(m)).toList();
  }
}
