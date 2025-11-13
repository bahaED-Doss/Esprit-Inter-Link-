import 'package:flutter/material.dart';
import '../data/task_database_helper.dart';
import '../models/task_model.dart';
import 'package:esprit_interlink/data/datasources/local/database_helper.dart' as CoreDB;
import '../../projects/data/project_database_helper.dart' as ProjectDB;

/// Provider pour la gestion d'état des tâches - Équivalent d'un Service Angular/Spring
/// Utilise le pattern ChangeNotifier pour notifier les widgets des changements
/// Pattern Observable/Observer pour la réactivité
class TaskProvider extends ChangeNotifier {
  final TaskDatabaseHelper _db = TaskDatabaseHelper();
  final CoreDB.DatabaseService _coreDb = CoreDB.DatabaseService();
  final ProjectDB.ProjectDatabaseHelper _projectDb = ProjectDB.ProjectDatabaseHelper();

  // Liste complète telle que récupérée depuis la DB
  List<Task> _allTasks = [];
  // Liste filtrée utilisée par l'UI
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  // Track last load params so we can reload after edits
  int? _lastProjectId;
  int? _lastUserId;

  // Filtres actifs
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  int? _filterSprint;
  bool _showPinnedOnly = false; // nouveau filtre

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get showPinnedOnly => _showPinnedOnly;

  /// Charger les tâches depuis la DB
  Future<void> loadTasks({int? projectId, int? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // store params
      _lastProjectId = projectId;
      _lastUserId = userId;

      if (userId != null && projectId != null) {
        // Student: tâches assignées à l'utilisateur dans le projet
        _allTasks = await _db.getTasksByUserAndProject(userId, projectId);
      } else if (projectId != null) {
        // PM: toutes les tâches du projet
        _allTasks = await _db.getTasksByProject(projectId);
      } else {
        // Fallback: toutes les tâches
        _allTasks = await _db.getAllTasks();
      }

      _applyFilters();
    } catch (e) {
      _error = 'Erreur lors du chargement des tâches: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une nouvelle tâche
  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();

      final id = await _db.insertTask(task);
      final inserted = task.copyWith(id: id);

      // Mettre à jour la liste complète puis réappliquer les filtres
      _allTasks.insert(0, inserted);
      _applyFilters();

      _error = null;

      // Notification: informer l'étudiant assigné au projet
      try {
        // Utilise ProjectDatabaseHelper pour obtenir les détails du projet
        final project = await _projectDb.getProjectById(inserted.projectId);
        final projectName = project?.title ?? 'Project';
        final assignedEmail = project?.assignedToEmail;
        if (assignedEmail != null && assignedEmail.trim().isNotEmpty) {
          final user = await _coreDb.getUserByEmail(assignedEmail.trim());
          final userId = user?.id;
          if (userId != null) {
            final title = 'New task added';
            final message = '"${inserted.title}" added to "${projectName}"';
            // Insert notification via DatabaseService instance
            await _coreDb.insertNotification(
              userId: userId,
              title: title,
              message: message,
              type: 'TASK',
              referenceId: inserted.projectId,
            );
          }
        }
      } catch (e) {
        print('Warn: failed to enqueue student notification: $e');
      }
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la tâche: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Modifier une tâche existante
  Future<void> editTask(Task updated) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('TaskProvider.editTask: updating id=${updated.id} status=${updated.status}');

      await _db.updateTask(updated);

      // Mettre à jour la tâche dans la liste complète
      final idxAll = _allTasks.indexWhere((t) => t.id == updated.id);
      if (idxAll != -1) {
        _allTasks[idxAll] = updated;
      } else {
        _allTasks.insert(0, updated);
      }

      // Réappliquer les filtres pour que la tâche change de section immédiatement
      _applyFilters();

      _error = null;

      // Reload from DB to ensure consistency, using last params
      try {
        await loadTasks(projectId: _lastProjectId, userId: _lastUserId);
      } catch (e) {
        print('Warning: reload after editTask failed: $e');
      }

      // Notification: si plus aucune tâche ouverte pour ce projet, notifier le PM
      try {
        final openCount = await _coreDb.countOpenTasksForProject(updated.projectId);
        if (openCount == 0) {
          final pmUserId = await _coreDb.getPMUserIdForProject(updated.projectId);
          if (pmUserId != null) {
            final hasUnread = await _coreDb.hasUnreadEmptyProjectNotification(pmUserId, updated.projectId);
            if (!hasUnread) {
              final project = await _projectDb.getProjectById(updated.projectId);
              final projectName = project?.title ?? 'Project';
              final title = 'No tasks left';
              final message = '"$projectName" has no tasks to do. Add new tasks or finish the project?';
              await _coreDb.insertNotification(
                userId: pmUserId,
                title: title,
                message: message,
                type: 'PROJECT',
                referenceId: updated.projectId,
              );
            }
          }
        }
      } catch (e) {
        print('Warn: failed to enqueue PM empty-project notification: $e');
      }
    } catch (e) {
      _error = 'Erreur lors de la modification de la tâche: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer une tâche
  Future<void> removeTask(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.deleteTask(id);
      _allTasks.removeWhere((t) => t.id == id);

      // Réappliquer les filtres afin que l'UI reflète la suppression
      _applyFilters();

      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression de la tâche: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Définir la requête de recherche
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Définir le filtre de pinned
  void setShowPinnedOnly(bool value) {
    _showPinnedOnly = value;
    _applyFilters();
    notifyListeners();
  }

  /// Appliquer les filtres (recherche, status, priority, sprint)
  void _applyFilters() {
    // Appliquer les filtres sur la liste complète _allTasks
    List<Task> filtered = List.from(_allTasks);

    // Filtre de recherche
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
      t.title.toLowerCase().contains(q) || (t.description ?? '').toLowerCase().contains(q)).toList();
    }

    // Filtre par status
    if (_filterStatus != null) {
      filtered = filtered.where((t) => t.status == _filterStatus).toList();
    }

    // Filtre par priority
    if (_filterPriority != null) {
      filtered = filtered.where((t) => t.priority == _filterPriority).toList();
    }

    // Filtre par sprint
    if (_filterSprint != null) {
      filtered = filtered.where((t) => t.sprintNumber == _filterSprint).toList();
    }

    // Filtre pinned
    if (_showPinnedOnly) {
      filtered = filtered.where((t) => t.pinned).toList();
    }

    _tasks = filtered;
  }

  /// Récupérer les tâches par status (pour l'affichage en colonnes)
  List<Task> tasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Définir le filtre de status
  void setStatusFilter(TaskStatus? status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  /// Définir le filtre de priorité
  void setPriorityFilter(TaskPriority? priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  /// Définir le filtre de sprint
  void setSprintFilter(int? sprint) {
    _filterSprint = sprint;
    _applyFilters();
    notifyListeners();
  }

  /// Réinitialiser tous les filtres
  void resetFilters() {
    _filterStatus = null;
    _filterPriority = null;
    _filterSprint = null;
    _searchQuery = '';
    _showPinnedOnly = false;
    _applyFilters();
    notifyListeners();
  }

  /// Vérifier si l'utilisateur a débloqué le trophée Task Warrior (5 tâches complétées)
  Future<bool> checkTaskWarriorAchievement(int userId) async {
    final count = await _db.getCompletedTaskCount(userId);
    return count >= 5;
  }
}