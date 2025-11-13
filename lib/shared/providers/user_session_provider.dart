import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';

/// Manages the current user session across the app
/// Your team uses this to check user role and permissions
class UserSessionProvider with ChangeNotifier {
  String? _userId;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;
  String? _companyId;
  bool _isLoggedIn = false;

  // Getters
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;
  String? get companyId => _companyId;
  bool get isLoggedIn => _isLoggedIn;

  // Check user permissions
  bool get isHR => _userRole == UserRole.hr;
  bool get isPM => _userRole == UserRole.projectManager;
  bool get isStudent => _userRole == UserRole.student;
  bool get isAdmin => _userRole?.isAdmin ?? false;
  bool get canCreateTasks => _userRole?.canCreateTasks ?? false;
  bool get canUpdateTaskStatus => _userRole?.canUpdateTaskStatus ?? false;

  /// Initialize session from persistent storage. Call this on app startup.
  Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('user_id');
    final storedEmail = prefs.getString('user_email');
    final storedName = prefs.getString('user_name');
    final storedRole = prefs.getString('user_role');
    final storedCompanyId = prefs.getString('company_id');

    if (storedUserId != null && storedRole != null) {
      _userId = storedUserId;
      _userEmail = storedEmail;
      _userName = storedName;
      _companyId = storedCompanyId;
      _userRole = userRoleFromString(storedRole);
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isLoggedIn && _userId != null && _userRole != null) {
      await prefs.setString('user_id', _userId!);
      if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
      if (_userName != null) await prefs.setString('user_name', _userName!);
      await prefs.setString('user_role', _userRole!.toShortString());
      if (_companyId != null) await prefs.setString('company_id', _companyId!);
    } else {
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.remove('company_id');
    }
  }

  /// Login user
  Future<void> login({
    required String userId,
    required String email,
    required String name,
    required UserRole role,
    String? companyId,
  }) async {
    _userId = userId;
    _userEmail = email;
    _userName = name;
    _userRole = role;
    _companyId = companyId;
    _isLoggedIn = true;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Logout user
  Future<void> logout() async {
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _companyId = null;
    _isLoggedIn = false;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Check if user has access to a specific feature
  bool hasAccess(String feature) {
    if (!_isLoggedIn || _userRole == null) return false;

    switch (feature) {
      case 'create_offers':
        return isHR;
      case 'view_applications':
        return isHR;
      case 'create_tasks':
        return isPM;
      case 'update_task_status':
        return isStudent;
      case 'apply_to_offers':
        return isStudent;
      default:
        return false;
    }
  }
}