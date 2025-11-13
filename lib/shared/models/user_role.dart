enum UserRole {
  hr,
  projectManager,
  student,
  admin,
}

String userRoleToShortString(UserRole role) {
  switch (role) {
    case UserRole.hr:
      return 'hr';
    case UserRole.projectManager:
      return 'pm';
    case UserRole.student:
      return 'student';
    case UserRole.admin:
      return 'admin';
  }
}

UserRole userRoleFromString(String value) {
  final v = value.toLowerCase();
  if (v == 'hr' || v == 'human_resources') return UserRole.hr;
  if (v == 'pm' || v == 'projectmanager' || v == 'project_manager' || v == 'project manager') return UserRole.projectManager;
  if (v == 'student') return UserRole.student;
  if (v == 'admin' || v == 'administrator') return UserRole.admin;
  return UserRole.student;
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.hr:
        return 'HR';
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.student:
        return 'Student';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get canCreateTasks => this == UserRole.projectManager;
  bool get canUpdateTaskStatus => this == UserRole.student;

  /// Return a short identifier for persistence (e.g. 'hr', 'student')
  String toShortString() => userRoleToShortString(this);
}
