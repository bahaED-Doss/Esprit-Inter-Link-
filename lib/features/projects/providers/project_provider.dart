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

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;

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

  Future<Project?> getProjectById(int id) async {
    try {
      return await _db.getProjectById(id);
    } catch (e) {
      _error = 'Erreur récupération projet: $e';
      return null;
    }
  }

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

  void setSearch(String q) {
    _search = q;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final query = _search.toLowerCase();
    _projects = _all.where((p) {
      return query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          (p.description ?? '').toLowerCase().contains(query) ||
          (p.assignedToEmail ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
