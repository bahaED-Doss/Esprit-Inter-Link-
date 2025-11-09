import 'package:flutter/material.dart';
import '../data/project_database_helper.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectDatabaseHelper _db;
  ProjectProvider([ProjectDatabaseHelper? db]) : _db = db ?? ProjectDatabaseHelper();

  List<Project> _all = [];
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _sortBy = 'date';
  String _statusFilter = 'all'; // new field

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  String get sortBy => _sortBy;
  String get statusFilter => _statusFilter;

  /// 🧠 Load all projects (optionally filtered by PM)
  Future<void> loadProjects({int? pmId}) async {
    _setLoading(true);
    try {
      _all = pmId != null
          ? await _db.getProjectsByPM(pmId)
          : await _db.getAllProjects();
      _applyFilters();
    } catch (e) {
      _error = 'Erreur de chargement: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// 🔍 Get one project by ID
  Future<Project?> getProjectById(int id) async {
    try {
      return await _db.getProjectById(id);
    } catch (e) {
      _error = 'Erreur récupération projet: $e';
      return null;
    }
  }

  /// 💾 Save or update a project
  Future<bool> saveProject(Project p) async {
    if (p.id == null) {
      return addProject(p);
    } else {
      return editProject(p);
    }
  }

  Future<bool> addProject(Project p) async {
    _setLoading(true);
    try {
      final id = await _db.insertProject(p);
      _all.insert(0, p.copyWith(id: id));
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Erreur ajout projet: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> editProject(Project p) async {
    _setLoading(true);
    try {
      final rows = await _db.updateProject(p);
      if (rows > 0) {
        final idx = _all.indexWhere((x) => x.id == p.id);
        if (idx != -1) _all[idx] = p;
        _applyFilters();
        return true;
      }
      _error = 'Aucune mise à jour effectuée';
      return false;
    } catch (e) {
      _error = 'Erreur modification projet: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProject(int id) async {
    _setLoading(true);
    try {
      await _db.deleteProject(id);
      _all.removeWhere((p) => p.id == id);
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Erreur suppression projet: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔎 Apply text search filter
  void setSearch(String q) {
    _search = q;
    _applyFilters();
    notifyListeners();
  }

  /// 🧭 Filter projects by status (ex: all, pending, in progress, completed)
  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// 🔢 Sort projects by chosen criteria
  void sortProjects(String criteria) {
    _sortBy = criteria;
    _applyFilters();
    notifyListeners();
  }

  /// ⚙️ Central filter + sort logic
  void _applyFilters() {
    final query = _search.toLowerCase();

    // Filter by text and status
    _projects = _all.where((p) {
      final matchSearch = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          (p.description ?? '').toLowerCase().contains(query);
      final matchStatus = _statusFilter == 'all' ||
          (p.status ?? '').toLowerCase() == _statusFilter.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();

    // Sort the filtered list
    switch (_sortBy) {
      case 'title':
        _projects.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'status':
        _projects.sort((a, b) => (a.status ?? '').compareTo(b.status ?? ''));
        break;
      default: // date
        _projects.sort((a, b) {
          final da = a.startDate ?? DateTime.now();
          final db = b.endDate ?? DateTime.now();
          return db.compareTo(da);
        });
    }
  }

  /// 📊 Quick stats for dashboard UI
  Map<String, int> get statusCounts {
    final Map<String, int> counts = {'pending': 0, 'in progress': 0, 'completed': 0};
    for (var p in _all) {
      final st = (p.status ?? '').toLowerCase();
      if (counts.containsKey(st)) counts[st] = counts[st]! + 1;
    }
    return counts;
  }
  List<Project> get filteredProjects => _projects;
  void filterProjects(String q) => setSearch(q);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
