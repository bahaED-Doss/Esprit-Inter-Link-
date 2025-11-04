import 'dart:io';

import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';
import 'package:esprit_interlink/features/auth/presentation/repositories/auth_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../presentation/models/hr_profile_models.dart';
import '../presentation/models/pm_profile_models.dart';
import '../presentation/models/profile_models.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // Variables d'état
  List<User> _allUsers = [];
  Map<String, double> _userStats = {};
  // Getters Admin
  List<User> get allUsers => _allUsers;
  Map<String, double> get userStats => _userStats;

  List<WorkExperience> _workExperiences = [];
  List<Education> _educations = [];
  List<Skill> _skills = [];
  List<Appreciation> _appreciations = [];
  List<Language> _languages = [];
  CompanyProfile? _companyProfile;
  ProjectManagerProfile? _pmProfile;
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _currentUserRole;
  bool _isAuthenticated = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserRole => _currentUserRole;
  List<WorkExperience> get workExperiences => _workExperiences;
  List<Education> get educations => _educations;
  List<Skill> get skills => _skills;
  List<Appreciation> get appreciations => _appreciations;
  List<Language> get languages => _languages;
  CompanyProfile? get companyProfile => _companyProfile;
  ProjectManagerProfile? get pmProfile => _pmProfile;
  bool get isLoggedIn => _user != null;

  // 🚀 CORRECTION : Méthode de chargement améliorée
  Future<void> loadProfileData({bool forceRefresh = false}) async {
    if (_user?.id == null) return;

    print('🔄 Loading profile data for user: ${_user!.id} (forceRefresh: $forceRefresh)');

    if (forceRefresh) {
      _isLoading = true;
      notifyListeners();
    }
    final userId = _user!.id!;

    try {
      print('🔄 Loading profile data for user: $userId (forceRefresh: $forceRefresh)');
      // 1. Recharger l'utilisateur
      _user = await _authRepository.getUserById(userId);
      print('✅ User loaded: ${_user?.fullName}');
      // 2. Recharger les listes basées sur le rôle
      if (_user!.role.toLowerCase() == 'student') {
        await _loadStudentData(userId);
      } else if (user!.role.toLowerCase() == 'hr') {
        _companyProfile = await _authRepository.loadCompanyProfile(userId);
      } else if (_user!.role.toLowerCase() == 'pm') {
        _pmProfile = await _authRepository.loadPMProfile(userId);
      }else if (_user!.role.toLowerCase() == 'admin') {
        // 🚀 Charger les données admin
        await fetchAllUsersAndStats();
      }

      print('✅ All profile data loaded successfully');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile data: $e';
      notifyListeners();
    }
  }
// 🚀 NOUVELLES MÉTHODES ADMIN
  Future<void> fetchAllUsersAndStats() async {
    if (_user?.role.toLowerCase() != 'admin') return;
    try {
      final results = await Future.wait([
        _authRepository.fetchAllUsers(),
        _authRepository.getRoleStats(),
      ]);
      _allUsers = results[0] as List<User>;
      _userStats = results[1] as Map<String, double>;
      notifyListeners();
    } catch (e) {
      _error = "Failed to fetch admin data: $e";
      notifyListeners();
    }
  }

  Future<bool> adminDeleteUser(int id) async {
    if (_user?.role.toLowerCase() != 'admin') return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.adminDeleteUser(id);
      await fetchAllUsersAndStats(); // Recharger
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adminCreateUser({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    if (_user?.role.toLowerCase() != 'admin') return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.adminCreateUser(
          email: email, password: password, role: role, fullName: fullName, phone: phone
      );
      await fetchAllUsersAndStats(); // Recharger
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adminUpdateUser(User user) async {
    if (_user?.role.toLowerCase() != 'admin') return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.adminUpdateUser(user);
      await fetchAllUsersAndStats(); // Recharger
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // 🚀 NOUVEAU : Chargement séparé des données étudiant
  Future<void> _loadStudentData(int userId) async {
    try {
      print('📚 Loading student data...');
      final results = await Future.wait([
        _authRepository.loadWorkExperiences(userId),
        _authRepository.loadEducations(userId),
        _authRepository.loadSkills(userId),
        _authRepository.loadAppreciations(userId),
        _authRepository.loadLanguages(userId),
      ],eagerError: true);

      _workExperiences = results[0] as List<WorkExperience>;
      _educations = results[1] as List<Education>;
      _skills = results[2] as List<Skill>;
      _appreciations = results[3] as List<Appreciation>;
      _languages = results[4] as List<Language>;
      print('✅ Student data loaded:');
      print('   - Work experiences: ${_workExperiences.length}');
      print('   - Educations: ${_educations.length}');
      print('   - Skills: ${_skills.length}');
      print('   - Appreciations: ${_appreciations.length}');
      print('   - Languages: ${_languages.length}');
    } catch (e) {
      print('❌ Error loading student data: $e');
      throw Exception('Failed to load student data: $e');
    }
  }

  // 🚀 CORRECTION : Méthode de mise à jour du CV améliorée
  Future<bool> updateUserResume() async {
    if (_user == null || _user!.id == null) return false;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      _isLoading = true;
      notifyListeners();

      try {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileSize = '${(await file.length() / 1024).toStringAsFixed(1)} KB';

        // Stocker le fichier
        final appDir = await getApplicationDocumentsDirectory();
        final resumeDir = Directory(p.join(appDir.path, 'resumes'));
        if (!await resumeDir.exists()) await resumeDir.create(recursive: true);

        final newPath = p.join(resumeDir.path, 'cv_user_${_user!.id}.pdf');
        await file.copy(newPath);

        await _authRepository.updateUserResume(
          userId: _user!.id!,
          path: newPath,
          fileName: fileName,
          size: fileSize,
        );

        // Recharger les données
        await loadProfileData();
        return true;
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
    return false;
  }

  // 🚀 CORRECTION : Méthode de suppression du CV améliorée
  Future<bool> deleteUserResume() async {
    if (_user == null || _user!.id == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.deleteUserResume(_user!.id!);

      // Supprimer le fichier local
      if (_user!.resumePath != null && File(_user!.resumePath!).existsSync()) {
        await File(_user!.resumePath!).delete();
      }

      // Recharger les données
      await loadProfileData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Profil RH CRUD ---
  Future<bool> updateCompanyProfile({
    required String companyName,
    required String companyIdentifier,
    required String industrySector,
    required String companyAddress,
    required String city,
    required String country,
    required String companyDescription,
  }) async {
    if (_user?.id == null || _user!.role != 'hr') return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileToSave = CompanyProfile(
        id: _companyProfile?.id,
        userId: _user!.id!,
        companyName: companyName,
        companyIdentifier: companyIdentifier,
        industrySector: industrySector,
        companyAddress: companyAddress,
        city: city,
        country: country,
        companyDescription: companyDescription,
        companyLogoPath: _companyProfile?.companyLogoPath,
      );

      final updatedProfile = await _authRepository.saveOrUpdateCompanyProfile(profileToSave);
      _companyProfile = updatedProfile;

      // Recharger les données
      await loadProfileData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Mise à jour du profil général ---
  Future<bool> updateGeneralProfile({
    String? fullName,
    String? phone,
    String? aboutMe,
  }) async {
    if (_user?.id == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.updateUserProfile(
        id: _user!.id!,
        fullName: fullName ?? _user!.fullName,
        phone: phone ?? _user!.phone,
        aboutMe: aboutMe ?? _user!.aboutMe,
      );

      // Recharger les données
      await loadProfileData();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Photo de profil ---
  Future<bool> updateProfilePicture() async {
    if (_user == null || _user!.id == null) return false;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70
    );

    if (pickedFile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(p.join(appDir.path, 'avatars'));
      if (!await avatarDir.exists()) await avatarDir.create(recursive: true);


      final newPath = p.join(avatarDir.path, 'user_${_user!.id}.png');
      final newFile = await File(pickedFile.path).copy(newPath);

      await _authRepository.updateUserAvatarPath(
        id: _user!.id!,
        avatarPath: newFile.path,
      );

      // Recharger les données
      await loadProfileData(forceRefresh: true);
      return true;
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Work Experience CRUD ---
  Future<bool> addWorkExperience({
    required String title,
    required String company,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
  }) async {
    if (_user?.id == null) return false;

    try {
      final newExp = WorkExperience(
          userId: _user!.id!,
          title: title,
          company: company,
          startDate: startDate,
          endDate: endDate,
          description: description
      );
      await _authRepository.saveWorkExperience(newExp);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to save work experience: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWorkExperience({
    required int id,
    required String title,
    required String company,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
  }) async {
    if (_user?.id == null) return false;

    try {
      final updatedExp = WorkExperience(
          id: id,
          userId: _user!.id!,
          title: title,
          company: company,
          startDate: startDate,
          endDate: endDate,
          description: description
      );
      await _authRepository.updateWorkExperience(updatedExp);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to update work experience: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkExperience(int id) async {
    try {
      final success = await _authRepository.deleteWorkExperience(id);
      if (success) await loadProfileData();
      return success;
    } catch (e) {
      _error = 'Failed to delete work experience: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Education CRUD ---
  Future<bool> addEducation({
    required String degree,
    required String institution,
    required DateTime startDate,
    DateTime? endDate,
    String? fieldOfStudy,
    String? description,
  }) async {
    if (_user?.id == null) return false;

    try {
      final newEdu = Education(
        userId: _user!.id!,
        degree: degree,
        institution: institution,
        startDate: startDate,
        endDate: endDate,
        fieldOfStudy: fieldOfStudy,
        description: description,
      );
      await _authRepository.saveEducation(newEdu);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to save education: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEducation({
    required int id,
    required String degree,
    required String institution,
    required DateTime startDate,
    DateTime? endDate,
    String? fieldOfStudy,
    String? description,
  }) async {
    if (_user?.id == null) return false;

    try {
      final updatedEdu = Education(
        id: id,
        userId: _user!.id!,
        degree: degree,
        institution: institution,
        startDate: startDate,
        endDate: endDate,
        fieldOfStudy: fieldOfStudy,
        description: description,
      );
      await _authRepository.updateEducation(updatedEdu);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to update education: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEducation(int id) async {
    try {
      final success = await _authRepository.deleteEducation(id);
      if (success) await loadProfileData();
      return success;
    } catch (e) {
      _error = 'Failed to delete education: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Skill CRUD ---
  Future<bool> addSkill(String skillName) async {
    if (_user?.id == null || skillName.isEmpty) return false;

    try {
      final newSkill = Skill(userId: _user!.id!, name: skillName.trim());
      await _authRepository.saveSkill(newSkill);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to add skill: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(int id) async {
    try {
      final success = await _authRepository.deleteSkill(id);
      if (success) await loadProfileData();
      return success;
    } catch (e) {
      _error = 'Failed to delete skill: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Appreciation CRUD ---
  Future<bool> addAppreciation({
    required String title,
    required String context,
    required String year,
  }) async {
    if (_user?.id == null) return false;

    try {
      final newApp = Appreciation(
          userId: _user!.id!,
          title: title,
          context: context,
          year: year
      );
      await _authRepository.saveAppreciation(newApp);
      await loadProfileData();
      return true;
    } catch (e) {
      _error = 'Failed to save appreciation: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppreciation({
    required int id,
    required String title,
    required String context,
    required String year,
  }) async {
    if (_user?.id == null) return false;

    try {
      final updatedApp = Appreciation(
          id: id,
          userId: _user!.id!,
          title: title,
          context: context,
          year: year
      );
      await _authRepository.updateAppreciation(updatedApp);
      await loadProfileData(forceRefresh: true);
      return true;
    } catch (e) {
      _error = 'Failed to update appreciation: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppreciation(int id) async {
    try {
      final success = await _authRepository.deleteAppreciation(id);
      if (success) await loadProfileData(forceRefresh: true);
      return success;
    } catch (e) {
      _error = 'Failed to delete appreciation: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Languages CRUD ---
  Future<bool> addLanguage(String languageName) async {
    if (_user?.id == null || languageName.isEmpty) return false;

    try {
      final newLang = Language(userId: _user!.id!, name: languageName.trim());
      await _authRepository.saveLanguage(newLang);
      await loadProfileData(forceRefresh: true);
      return true;
    } catch (e) {
      _error = 'Failed to add language: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLanguage(int id) async {
    try {
      final success = await _authRepository.deleteLanguage(id);
      if (success) await loadProfileData();
      return success;
    } catch (e) {
      _error = 'Failed to delete language: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Connexion ---
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _isAuthenticated = false;
    notifyListeners();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _currentUserRole = user.role;
        _error = null;

        // Charger les données du profil après connexion
        await loadProfileData();
      } else {
        _isAuthenticated = false;
        _error = 'Invalid email or password';
      }
    } catch (e) {
      _isAuthenticated = false;
      _error = 'Login failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _isAuthenticated;
  }

  // --- Inscription ---
  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final user = await _authRepository.signUp(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
      );

      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Déconnexion ---
  Future<void> logout() async {
    _user = null;
    _workExperiences = [];
    _educations = [];
    _skills = [];
    _appreciations = [];
    _languages = [];
    _companyProfile = null;
    _pmProfile = null;
    _currentUserRole = null;
    _error = null;
    _isAuthenticated = false;
    await _authRepository.logout();
    notifyListeners();
  }

  // --- Autres méthodes ---
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authRepository.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyResetToken(String token) async {
    return await _authRepository.verifyResetToken(token);
  }

  // --- PM Profile CRUD ---
  Future<bool> updatePMProfile({
    required String jobTitle,
    required String department,
    required String phone,
    required String city,
    required String country,
  }) async {
    if (_user?.id == null || _user!.role != 'pm') return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileToSave = ProjectManagerProfile(
        id: _pmProfile?.id,
        userId: _user!.id!,
        jobTitle: jobTitle,
        department: department,
        phone: phone,
        city: city,
        country: country,
      );

      final updatedProfile = await _authRepository.saveOrUpdatePMProfile(profileToSave);
      _pmProfile = updatedProfile;

      await loadProfileData(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProjectManager({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String jobTitle,
    required String department,
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user?.role == null || _user!.role.toLowerCase() != 'hr') {
        throw Exception('Access deniedd. Only HR can create PM accounts.');
      }

      await _authRepository.createPMUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        jobTitle: jobTitle,
        department: department,
        city: city,
        country: country,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}