import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import 'package:esprit_interlink/data/datasources/local/database_service.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

import '../models/hr_profile_models.dart';
import '../models/pm_profile_models.dart';
import '../models/profile_models.dart';
import '../services/email_service.dart';

class AuthRepository {
  final DatabaseService _databaseService = DatabaseService();

  // 🚀 CORRECTION : Méthode améliorée pour récupérer l'utilisateur par ID
  Future<User?> getUserById(int id) async {
    try {
      return await _databaseService.getUserById(id);
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      throw Exception('Failed to get user: $e');
    }
  }
  //ADMIN
// 🚀 NOUVEAU : Wrapper pour 'getAllUsers'
  Future<List<User>> fetchAllUsers() async {
    return await _databaseService.getAllUsers();
  }

  // 🚀 NOUVEAU : Wrapper pour 'getRoleStatistics'
  Future<Map<String, double>> getRoleStats() async {
    return await _databaseService.getRoleStatistics();
  }

  // 🚀 NOUVEAU : Wrapper pour 'adminUpdateUser'
  Future<User> adminUpdateUser(User user) async {
    await _databaseService.adminUpdateUser(user);
    // Retourner l'utilisateur mis à jour
    return await _databaseService.getUserById(user.id!) ?? user;
  }

  // 🚀 NOUVEAU : Wrapper pour 'deleteUser'
  Future<bool> adminDeleteUser(int id) async {
    final count = await _databaseService.deleteUser(id);
    return count > 0;
  }

  // 🚀 NOUVEAU : L'admin crée un utilisateur (similaire à signUp mais avec un rôle)
  Future<User> adminCreateUser({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    if (await _databaseService.getUserByEmail(email) != null) {
      throw Exception('Email already exists');
    }
    final hashedPassword = _hashPassword(password);
    final user = User(
      email: email,
      password: hashedPassword,
      fullName: fullName,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );
    final id = await _databaseService.insertUser(user);
    return user.copyWith(id: id);
  }

  // 🚀 CORRECTION : Méthode de mise à jour du profil utilisateur
  Future<User> updateUserProfile({
    required int id,
    String? fullName,
    String? phone,
    String? aboutMe,
  }) async {
    try {
      final currentUser = await _databaseService.getUserById(id);
      if (currentUser == null) throw Exception('User not found');

      final updatedUser = currentUser.copyWith(
        fullName: fullName ?? currentUser.fullName,
        phone: phone ?? currentUser.phone,
        aboutMe: aboutMe ?? currentUser.aboutMe,
      );

      final rowsAffected = await _databaseService.updateUserProfile(updatedUser);

      if (rowsAffected == 0) throw Exception('User not updated in database');

      // Retourner l'utilisateur fraîchement chargé depuis la base
      return await _databaseService.getUserById(id) ?? updatedUser;
    } catch (e) {
      print('❌ Update user profile error: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // 🚀 CORRECTION : Méthode de mise à jour de l'avatar
  Future<int> updateUserAvatarPath({required int id, required String avatarPath}) async {
    try {
      return await _databaseService.updateUserAvatarPath(
          id: id,
          avatarPath: avatarPath
      );
    } catch (e) {
      print('❌ Update avatar path error: $e');
      throw Exception('Failed to update avatar: $e');
    }
  }

  // 🚀 CORRECTION : Méthodes de CV
  Future<int> updateUserResume({
    required int userId,
    required String path,
    required String fileName,
    required String size
  }) async {
    try {
      return await _databaseService.updateUserResume(
          userId: userId,
          path: path,
          fileName: fileName,
          size: size
      );
    } catch (e) {
      print('❌ Update resume error: $e');
      throw Exception('Failed to update resume: $e');
    }
  }

  Future<int> deleteUserResume(int userId) async {
    try {
      return await _databaseService.deleteUserResume(userId);
    } catch (e) {
      print('❌ Delete resume error: $e');
      throw Exception('Failed to delete resume: $e');
    }
  }

  // --- Work Experience CRUD ---
  Future<int> saveWorkExperience(WorkExperience exp) async {
    try {
      return await _databaseService.insertWorkExperience(exp);
    } catch (e) {
      print('❌ Save work experience error: $e');
      throw Exception('Failed to save work experience: $e');
    }
  }

  Future<int> updateWorkExperience(WorkExperience exp) async {
    try {
      return await _databaseService.updateWorkExperience(exp);
    } catch (e) {
      print('❌ Update work experience error: $e');
      throw Exception('Failed to update work experience: $e');
    }
  }

  Future<List<WorkExperience>> loadWorkExperiences(int userId) async {
    try {
      return await _databaseService.getWorkExperiencesByUserId(userId);
    } catch (e) {
      print('❌ Load work experiences error: $e');
      throw Exception('Failed to load work experiences: $e');
    }
  }

  Future<bool> deleteWorkExperience(int id) async {
    try {
      final count = await _databaseService.deleteWorkExperience(id);
      return count > 0;
    } catch (e) {
      print('❌ Delete work experience error: $e');
      throw Exception('Failed to delete work experience: $e');
    }
  }

  // --- Education CRUD ---
  Future<int> saveEducation(Education edu) async {
    try {
      return await _databaseService.insertEducation(edu);
    } catch (e) {
      print('❌ Save education error: $e');
      throw Exception('Failed to save education: $e');
    }
  }

  Future<int> updateEducation(Education edu) async {
    try {
      return await _databaseService.updateEducation(edu);
    } catch (e) {
      print('❌ Update education error: $e');
      throw Exception('Failed to update education: $e');
    }
  }

  Future<List<Education>> loadEducations(int userId) async {
    try {
      return await _databaseService.getEducationsByUserId(userId);
    } catch (e) {
      print('❌ Load educations error: $e');
      throw Exception('Failed to load educations: $e');
    }
  }

  Future<bool> deleteEducation(int id) async {
    try {
      final count = await _databaseService.deleteEducation(id);
      return count > 0;
    } catch (e) {
      print('❌ Delete education error: $e');
      throw Exception('Failed to delete education: $e');
    }
  }

  // --- Skill CRUD ---
  Future<int> saveSkill(Skill skill) async {
    try {
      return await _databaseService.insertSkill(skill);
    } catch (e) {
      print('❌ Save skill error: $e');
      throw Exception('Failed to save skill: $e');
    }
  }

  Future<List<Skill>> loadSkills(int userId) async {
    try {
      return await _databaseService.getSkillsByUserId(userId);
    } catch (e) {
      print('❌ Load skills error: $e');
      throw Exception('Failed to load skills: $e');
    }
  }

  Future<bool> deleteSkill(int id) async {
    try {
      final count = await _databaseService.deleteSkill(id);
      return count > 0;
    } catch (e) {
      print('❌ Delete skill error: $e');
      throw Exception('Failed to delete skill: $e');
    }
  }

  // --- Appreciation CRUD ---
  Future<int> saveAppreciation(Appreciation app) async {
    try {
      return await _databaseService.insertAppreciation(app);
    } catch (e) {
      print('❌ Save appreciation error: $e');
      throw Exception('Failed to save appreciation: $e');
    }
  }

  Future<List<Appreciation>> loadAppreciations(int userId) async {
    try {
      return await _databaseService.getAppreciationsByUserId(userId);
    } catch (e) {
      print('❌ Load appreciations error: $e');
      throw Exception('Failed to load appreciations: $e');
    }
  }

  Future<int> updateAppreciation(Appreciation app) async {
    try {
      return await _databaseService.updateAppreciation(app);
    } catch (e) {
      print('❌ Update appreciation error: $e');
      throw Exception('Failed to update appreciation: $e');
    }
  }

  Future<bool> deleteAppreciation(int id) async {
    try {
      final count = await _databaseService.deleteAppreciation(id);
      return count > 0;
    } catch (e) {
      print('❌ Delete appreciation error: $e');
      throw Exception('Failed to delete appreciation: $e');
    }
  }

  // --- Language CRUD ---
  Future<int> saveLanguage(Language lang) async {
    try {
      return await _databaseService.insertLanguage(lang);
    } catch (e) {
      print('❌ Save language error: $e');
      throw Exception('Failed to save language: $e');
    }
  }

  Future<List<Language>> loadLanguages(int userId) async {
    try {
      return await _databaseService.getLanguagesByUserId(userId);
    } catch (e) {
      print('❌ Load languages error: $e');
      throw Exception('Failed to load languages: $e');
    }
  }

  Future<bool> deleteLanguage(int id) async {
    try {
      final count = await _databaseService.deleteLanguage(id);
      return count > 0;
    } catch (e) {
      print('❌ Delete language error: $e');
      throw Exception('Failed to delete language: $e');
    }
  }

  // --- Company Profile CRUD ---
  Future<CompanyProfile> saveOrUpdateCompanyProfile(CompanyProfile profile) async {
    try {
      final id = await _databaseService.saveCompanyProfile(profile);

      if (profile.id == null) {
        final savedProfile = await _databaseService.getCompanyProfileByUserId(profile.userId);
        if (savedProfile != null) return savedProfile;
      }
      return profile.copyWith(id: id);
    } catch (e) {
      print('❌ Save company profile error: $e');
      throw Exception('Failed to save company profile: $e');
    }
  }

  Future<CompanyProfile?> loadCompanyProfile(int userId) async {
    try {
      return await _databaseService.getCompanyProfileByUserId(userId);
    } catch (e) {
      print('❌ Load company profile error: $e');
      throw Exception('Failed to load company profile: $e');
    }
  }

  // --- PM Profile CRUD ---
  Future<ProjectManagerProfile?> loadPMProfile(int userId) async {
    try {
      return await _databaseService.getPMProfileByUserId(userId);
    } catch (e) {
      print('❌ Load PM profile error: $e');
      throw Exception('Failed to load PM profile: $e');
    }
  }

  Future<ProjectManagerProfile> saveOrUpdatePMProfile(ProjectManagerProfile profile) async {
    try {
      final id = await _databaseService.savePMProfile(profile);

      if (profile.id == null) {
        final savedProfile = await _databaseService.getPMProfileByUserId(profile.userId);
        if (savedProfile != null) return savedProfile;
      }
      return profile.copyWith(id: profile.id ?? id);
    } catch (e) {
      print('❌ Save PM profile error: $e');
      throw Exception('Failed to save PM profile: $e');
    }
  }

  // --- Méthodes d'authentification (inchangées) ---
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String _generateResetToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        _generateRandomString(32);
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    try {
      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email already exists');
      }

      final hashedPassword = _hashPassword(password);
      final user = User(
        email: email,
        password: hashedPassword,
        fullName: fullName,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      final id = await _databaseService.insertUser(user);
      return user.copyWith(id: id);
    } catch (e) {
      print('❌ Sign up error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      final user = await _databaseService.getUserByEmail(email);
      if (user == null) return null;

      final hashedInputPassword = _hashPassword(password);
      final isPasswordValid = user.password == hashedInputPassword;

      if (!isPasswordValid) return null;
      return user;
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final user = await _databaseService.getUserByEmail(email);
      if (user == null) return true;

      final resetToken = _generateResetToken();
      final expiresAt = DateTime.now().add(Duration(hours: 1));

      await _databaseService.savePasswordReset(
        email: email,
        token: resetToken,
        expiresAt: expiresAt,
      );

      await EmailService().sendPasswordResetEmail(
        email: email,
        resetToken: resetToken,
      );

      return true;
    } catch (e) {
      print('❌ Forgot password error: $e');
      throw Exception('Failed to process password reset: $e');
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      print('🔐 Reset password with token: $token');

      // 1. Vérifier le token
      final resetRequest = await _databaseService.getPasswordReset(token);
      if (resetRequest == null) {
        throw Exception('Invalid reset token');
      }
      if (resetRequest.isUsed) {
        throw Exception('Reset token already used');
      }
      if (resetRequest.expiresAt.isBefore(DateTime.now())) {
        throw Exception('Reset token expired');
      }

      print('✅ Token is valid for email: ${resetRequest.email}');

      // 2. Hasher le nouveau mot de passe
      final hashedPassword = _hashPassword(newPassword);

      // 3. Mettre à jour le mot de passe (ET VÉRIFIER LE RÉSULTAT)
      final rowsAffected = await _databaseService.updateUserPassword(
        email: resetRequest.email,
        newPassword: hashedPassword,
      );

      // 🚀 CORRECTION : Vérifier si la mise à jour a réellement eu lieu
      if (rowsAffected == 0) {
        throw Exception('Failed to update password in database (user not found or password unchanged)');
      }

      // 4. Marquer le token comme utilisé
      await _databaseService.markResetTokenAsUsed(token);

      print('✅ Password updated successfully for: ${resetRequest.email}');
      return true; //
    } catch (e) {
      print('❌ Reset password error: $e');
      // Propage l'erreur au AuthProvider, qui la renverra à l'UI
      throw Exception('Password reset failed: $e');
    }
  }

  Future<bool> verifyResetToken(String token) async {
    try {
      final resetRequest = await _databaseService.getPasswordReset(token);
      if (resetRequest == null ||
          resetRequest.isUsed ||
          resetRequest.expiresAt.isBefore(DateTime.now())) {
        return false;
      }
      return true;
    } catch (e) {
      print('❌ Verify token error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    return Future.value();
  }

  Future<User?> getCurrentUser() async {
    return null;
  }

  Future<User> createPMUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String jobTitle,
    required String department,
    required String city,
    required String country,
  }) async {
    if (await _databaseService.getUserByEmail(email) != null) {
      throw Exception('Email already exists');
    }

    final hashedPassword = _hashPassword(password);
    final user = User(
      email: email,
      password: hashedPassword,
      fullName: fullName,
      phone: phone,
      role: 'pm',
      createdAt: DateTime.now(),
    );
    final userId = await _databaseService.insertUser(user);

    if (userId == 0) throw Exception('Failed to create user entry.');

    final createdUser = user.copyWith(id: userId);

    final pmProfile = ProjectManagerProfile(
      userId: userId,
      jobTitle: jobTitle,
      department: department,
      phone: phone,
      city: city,
      country: country,
    );
    await _databaseService.savePMProfile(pmProfile);

    return createdUser;
  }
}