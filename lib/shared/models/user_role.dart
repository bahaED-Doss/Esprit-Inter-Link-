enum UserRole {
  hr,
  projectManager,
  student,
  admin,
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
}
