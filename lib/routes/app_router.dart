import 'package:esprit_interlink/features/auth/presentation/pages/change_password.dart';
import 'package:esprit_interlink/features/auth/presentation/pages/check_email_page.dart';
import 'package:esprit_interlink/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:esprit_interlink/features/auth/presentation/pages/login_page.dart';

import 'package:esprit_interlink/features/auth/presentation/pages/signup_page.dart';
import 'package:esprit_interlink/features/auth/presentation/pages/success_page.dart';

import 'package:esprit_interlink/shared/presentation/pages/role_select_screen.dart';
import 'package:esprit_interlink/shared/presentation/pages/student_home_page.dart';
import 'package:esprit_interlink/shared/presentation/pages/hr_home_page.dart';
import 'package:esprit_interlink/shared/presentation/pages/pm_home_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/student_profile_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/student_offers_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/student_applications_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/hr_applications_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/hr_candidates_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/hr_profile_company_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/pm_profile_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/pm_projects_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/pm_interns_page.dart';
import 'package:esprit_interlink/shared/presentation/todo/pm_tasks_page.dart';
import 'package:esprit_interlink/features/trophies/presentation/pages/student_trophies_page.dart';
import 'package:esprit_interlink/features/trophies/presentation/pages/trophies_pm_page.dart';
import 'package:esprit_interlink/features/trophies/presentation/pages/trophies_hr_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/models/user_model.dart';
import '../features/auth/presentation/pages/ADMIN PAGES/admin_home_page.dart';
import '../features/auth/presentation/pages/ADMIN PAGES/admin_user_form_page.dart';
import '../features/auth/presentation/pages/error_page.dart';
import '../shared/presentation/pages/LoadingScreen.dart';
import '../shared/presentation/pages/SplashScreen.dart';
import 'route_names.dart';

/// App-wide routing configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => SplashScreen(
          onNext: () {
            context.goNamed('login');
          },
        ),
      ),

      // Loading Screen
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),

      // Role Select Screen
      GoRoute(
        path: '/role_select',
        name: 'roleSelect',
        builder: (context, state) => const RoleSelectScreen(),
      ),

      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Route pour la réinitialisation avec token
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          if (token == null) {
            return const ErrorPage(message: 'Lien de réinitialisation invalide');
          }
          return ChangePasswordPage(resetToken: token); // Utilisez ChangePasswordPage avec token
        },
      ),


      GoRoute(
        path: RouteNames.checkEmail,
        name: 'checkEmail',
        builder: (context, state) => const CheckMailPage(),
      ),

      GoRoute(
        path: RouteNames.changePass,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // ============================================
      // HOME PAGES
      // ============================================
      GoRoute(
        path: '/student_home',
        name: 'student_home',
        builder: (context, state) => const StudentHomePage(),
      ),

      GoRoute(
        path: '/hr_home',
        name: 'hr_home',
        builder: (context, state) => const HRHomePage(),
      ),

      GoRoute(
        path: '/pm_home',
        name: 'pm_home',
        builder: (context, state) => const PMHomePage(),
      ),
// 🚀 NOUVELLE ROUTE ADMIN
      GoRoute(
        path: '/admin_home',
        name: 'admin_home',
        builder: (context, state) => const AdminHomePage(),
      ),

      // 🚀 NOUVELLE ROUTE ADMIN EDIT/CREATE
      GoRoute(
        path: '/admin_user_form',
        name: 'admin_user_form',
        builder: (context, state) {
          // Passer l'utilisateur en 'extra' lors de la navigation pour l'édition
          final user = state.extra as User?;
          return AdminUserFormPage(userToEdit: user);
        },
      ),
      GoRoute(
        path: RouteNames.success,
        name: 'success',
        builder: (context, state) => const SuccessPage(),
      ),

      // ============================================
      // STUDENT ROUTES
      // ============================================
      GoRoute(
        path: '/studentProfile',
        name: 'studentProfile',
        builder: (context, state) => const StudentProfilePage(),
      ),

      GoRoute(
        path: RouteNames.offers,
        name: 'offers',
        builder: (context, state) => const StudentOffersPage(),
      ),

      GoRoute(
        path: '/myApplications',
        name: 'myApplications',
        builder: (context, state) => const StudentApplicationsPage(),
      ),

      // ============================================
      // HR ROUTES
      // ============================================
      GoRoute(
        path: '/applications',
        name: 'applications',
        builder: (context, state) => const HRApplicationsPage(),
      ),

      GoRoute(
        path: '/candidates',
        name: 'candidates',
        builder: (context, state) => const HRCandidatesPage(),
      ),

      GoRoute(
        path: '/companyProfile',
        name: 'companyProfile',
        builder: (context, state) => const HRProfileCompanyPage(),
      ),

      // ============================================
      // PM ROUTES
      // ============================================
      GoRoute(
        path: '/pmProfile',
        name: 'pmProfile',
        builder: (context, state) => const PMProfilePage(),
      ),

      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const PMProjectsPage(),
      ),

      GoRoute(
        path: '/interns',
        name: 'interns',
        builder: (context, state) => const PMInternsPage(),
      ),

      GoRoute(
        path: RouteNames.tasks,
        name: 'tasks',
        builder: (context, state) => const PMTasksPage(),
      ),

      // ============================================
      // TROPHIES ROUTES
      // ============================================
      GoRoute(
        path: '/trophies',
        name: 'trophies',
        builder: (context, state) => const StudentTrophiesPage(),
      ),

      GoRoute(
        path: '/trophies_hr',
        name: 'trophiesHr',
        builder: (context, state) => const TrophiesHRPage(),
      ),

      GoRoute(
        path: '/trophies_pm',
        name: 'trophiesPm',
        builder: (context, state) => const TrophiesPMPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed('splash'),
              child: const Text('Go to Splash'),
            ),
          ],
        ),
      ),
    ),
  );
}