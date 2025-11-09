import 'package:flutter/material.dart';
import '../data/application_repository.dart';
import '../models/internship_model.dart';
import '../models/application_model.dart';
import '../../../shared/data/notification_service.dart';

/// Provider pour la gestion d'état des candidatures et stages
/// Équivalent d'un Service Angular/Spring
/// Utilise le pattern ChangeNotifier pour notifier les widgets des changements
class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository _db = ApplicationRepository();

  // Internships
  List<Internship> _internships = [];
  List<Internship> _filteredInternships = [];
  
  // Applications
  List<Application> _applications = [];
  
  // Loading states
  bool _isLoadingInternships = false;
  bool _isLoadingApplications = false;
  
  // Errors
  String? _internshipError;
  String? _applicationError;
  
  // Search and filters
  String _searchQuery = '';
  InternshipType? _filterType;
  InternshipStatus? _filterStatus;

  // Getters
  List<Internship> get internships => _filteredInternships;
  List<Application> get applications => _applications;
  bool get isLoadingInternships => _isLoadingInternships;
  bool get isLoadingApplications => _isLoadingApplications;
  String? get internshipError => _internshipError;
  String? get applicationError => _applicationError;
  String get searchQuery => _searchQuery;

  set internshipError(String? value) {
    _internshipError = value;
    notifyListeners();
  }

  /// ===========================
  /// INTERNSHIP METHODS
  /// ===========================

  /// Charger toutes les offres de stage ouvertes
  Future<void> loadOpenInternships() async {
    try {
      _isLoadingInternships = true;
      _internshipError = null;
      notifyListeners();

      _internships = await _db.getOpenInternships();
      _applyFilters();
    } catch (e) {
      _internshipError = 'Error loading internships: $e';
      print(_internshipError);
    } finally {
      _isLoadingInternships = false;
      notifyListeners();
    }
  }

  /// Charger les offres de stage créées par un HR
  Future<void> loadInternshipsByHR(int hrId) async {
    try {
      _isLoadingInternships = true;
      _internshipError = null;
      notifyListeners();

      _internships = await _db.getInternshipsByHR(hrId);
      _applyFilters();
    } catch (e) {
      _internshipError = 'Error loading HR internships: $e';
      print(_internshipError);
    } finally {
      _isLoadingInternships = false;
      notifyListeners();
    }
  }

  /// Récupérer une offre de stage par ID
  Future<Internship?> getInternshipById(int id) async {
    try {
      return await _db.getInternshipById(id);
    } catch (e) {
      print('Error getting internship: $e');
      return null;
    }
  }

  /// Ajouter une nouvelle offre de stage
  Future<void> addInternship(Internship internship) async {
    try {
      _isLoadingInternships = true;
      notifyListeners();

      final id = await _db.insertInternship(internship);
      final inserted = internship.copyWith(id: id);

      _internships.insert(0, inserted);
      _applyFilters();

      _internshipError = null;
    } catch (e) {
      _internshipError = 'Error adding internship: $e';
      print(_internshipError);
    } finally {
      _isLoadingInternships = false;
      notifyListeners();
    }
  }

  /// Modifier une offre de stage
  Future<void> updateInternship(Internship internship) async {
    try {
      _isLoadingInternships = true;
      notifyListeners();

      await _db.updateInternship(internship);

      final index = _internships.indexWhere((i) => i.id == internship.id);
      if (index != -1) {
        _internships[index] = internship;
      }

      _applyFilters();
      _internshipError = null;
    } catch (e) {
      _internshipError = 'Error updating internship: $e';
      print(_internshipError);
    } finally {
      _isLoadingInternships = false;
      notifyListeners();
    }
  }

  /// Supprimer une offre de stage
  Future<void> deleteInternship(int id) async {
    try {
      _isLoadingInternships = true;
      notifyListeners();

      await _db.deleteInternship(id);
      _internships.removeWhere((i) => i.id == id);

      _applyFilters();
      _internshipError = null;
    } catch (e) {
      _internshipError = 'Error deleting internship: $e';
      print(_internshipError);
    } finally {
      _isLoadingInternships = false;
      notifyListeners();
    }
  }

  /// Rechercher des offres de stage
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Définir le filtre de type
  void setTypeFilter(InternshipType? type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  /// Définir le filtre de statut
  void setStatusFilter(InternshipStatus? status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  /// Réinitialiser tous les filtres
  void resetFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterStatus = null;
    _applyFilters();
    notifyListeners();
  }

  /// Appliquer les filtres sur la liste des stages
  void _applyFilters() {
    List<Internship> filtered = List.from(_internships);

    // Filtre de recherche
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) =>
          i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.companyName.toLowerCase().contains(q)).toList();
    }

    // Filtre par type
    if (_filterType != null) {
      filtered = filtered.where((i) => i.type == _filterType).toList();
    }

    // Filtre par statut
    if (_filterStatus != null) {
      filtered = filtered.where((i) => i.status == _filterStatus).toList();
    }

    _filteredInternships = filtered;
  }

  /// ===========================
  /// APPLICATION METHODS
  /// ===========================

  /// Charger les candidatures d'un étudiant
  Future<void> loadApplicationsByStudent(int studentId) async {
    try {
      _isLoadingApplications = true;
      _applicationError = null;
      notifyListeners();

      _applications = await _db.getApplicationsByStudent(studentId);
    } catch (e) {
      _applicationError = 'Error loading applications: $e';
      print(_applicationError);
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  /// Charger les candidatures pour une offre de stage
  Future<void> loadApplicationsByInternship(int internshipId) async {
    try {
      _isLoadingApplications = true;
      _applicationError = null;
      notifyListeners();

      _applications = await _db.getApplicationsByInternship(internshipId);
    } catch (e) {
      _applicationError = 'Error loading internship applications: $e';
      print(_applicationError);
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  /// Vérifier si un étudiant a déjà postulé
  Future<bool> hasApplied(int studentId, int internshipId) async {
    try {
      return await _db.hasApplied(studentId, internshipId);
    } catch (e) {
      print('Error checking application: $e');
      return false;
    }
  }

  /// Récupérer l'application d'un étudiant pour un stage
  Future<Application?> getApplicationByStudentAndInternship(int studentId, int internshipId) async {
    try {
      return await _db.getApplicationByStudentAndInternship(studentId, internshipId);
    } catch (e) {
      print('Error getting application: $e');
      return null;
    }
  }

  /// Ajouter une nouvelle candidature
  Future<bool> addApplication(Application application) async {
    try {
      _isLoadingApplications = true;
      notifyListeners();

      final id = await _db.insertApplication(application);
      final inserted = application.copyWith(id: id);

      _applications.insert(0, inserted);
      _applicationError = null;
      
      // Notify the HR who posted the internship about the new application
      try {
        final internship = await _db.getInternshipById(application.internshipId);
        final hrId = internship?.hrId;
        if (hrId != null) {
          await NotificationService.addNotificationForUser(
            hrId,
            '${application.fullName} applied to "${internship?.title ?? 'your internship'}"',
            title: 'New application',
            type: 'APPLICATION',
            referenceId: application.internshipId,
          );
         }
      } catch (e) {
        print('⚠️ Failed to create HR notification for application: $e');
      }

      _isLoadingApplications = false;
      notifyListeners();
      return true;
    } catch (e) {
      _applicationError = 'Error adding application: $e';
      print(_applicationError);
      _isLoadingApplications = false;
      notifyListeners();
      return false;
    }
  }

  /// Modifier une candidature
  Future<bool> updateApplication(Application application) async {
    try {
      _isLoadingApplications = true;
      notifyListeners();

      await _db.updateApplication(application);

      final index = _applications.indexWhere((a) => a.id == application.id);
      if (index != -1) {
        _applications[index] = application;
      }

      _applicationError = null;
      _isLoadingApplications = false;
      notifyListeners();
      return true;
    } catch (e) {
      _applicationError = 'Error updating application: $e';
      print(_applicationError);
      _isLoadingApplications = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprimer une candidature
  Future<void> deleteApplication(int id) async {
    try {
      _isLoadingApplications = true;
      notifyListeners();

      await _db.deleteApplication(id);
      _applications.removeWhere((a) => a.id == id);

      _applicationError = null;
    } catch (e) {
      _applicationError = 'Error deleting application: $e';
      print(_applicationError);
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  /// Récupérer les candidatures avec détails des stages
  Future<List<Map<String, dynamic>>> getApplicationsWithDetails(int studentId) async {
    try {
      return await _db.getApplicationsWithInternshipDetails(studentId);
    } catch (e) {
      print('Error getting applications with details: $e');
      return [];
    }
  }

  /// Initialiser les données mock si nécessaire
  Future<void> initializeMockData() async {
    try {
      await _db.initializeMockInternshipsIfNeeded();
    } catch (e) {
      print('Error initializing mock data: $e');
    }
  }
}
