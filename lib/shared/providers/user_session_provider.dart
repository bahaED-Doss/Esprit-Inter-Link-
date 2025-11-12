import 'package:flutter/foundation.dart';
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
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
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