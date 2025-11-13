/// Route name constants for navigation
/// Similar to Angular `app-routing.module.ts`
/// or Spring controller endpoint constants
class RouteNames {
  static const String splash = '/splash';
  static const home = '/home';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String checkEmail = '/check-email';
  static const String success = '/success';
  static const String welcomeBack = '/welcome-back';
  static const String changePass = '/change-password';

  // HR
  static const hrDashboard = '/hr/dashboard';
  static const companySetup = '/hr/company';

  // PM
  static const pmDashboard = '/pm/dashboard';
  static const tasks = '/pm/tasks';
  static const pmProjects = '/pm/projects';

  // Student
  static const offers = '/student/offers';
  static const myProject = '/student/project';

  // Shared
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
}
