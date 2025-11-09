import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'route_names.dart';
import '../shared/presentation/pages/SplashScreen.dart';
import '../features/home/pages/home_page.dart';
import '../features/trophies/presentation/pages/trophies_page.dart';
import '../shared/presentation/todo/pm_projects_page.dart';

/// App-wide routing configuration
/// Your team can add their feature routes here
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
            context.go(RouteNames.home);
          },
        ),
      ),

      // Home (Main Dashboard - Role-based)
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // ============================================
      // AUTH ROUTES - Your team will add these
      // ============================================
      // TODO: Add login route
      // TODO: Add signup route
      // TODO: Add PM invitation route

      // ============================================
      // HR ROUTES - HR team member adds these
      // ============================================
      // TODO: Add HR dashboard
      // TODO: Add company setup
      // TODO: Add create PM
      // TODO: Add offers management
      // TODO: Add applications page

      // ============================================
      // STUDENT ROUTES - Student team member adds these
      // ============================================
      // TODO: Add browse offers
      // TODO: Add offer detail
      // TODO: Add apply page
      // TODO: Add my applications
      // TODO: Add my project
      // TODO: Add tasks page (Kanban)

      // ============================================
      // PM ROUTES - PM team member adds these
      // ============================================
      // TODO: Add PM dashboard
      // TODO: Add projects list
      // TODO: Add tasks overview
      // TODO: Add create/edit task
      // TODO: Add feedback page

      // ============================================
      // SHARED ROUTES - Profile, Settings, etc.
      // ============================================
      // TODO: Add profile page
      // TODO: Add edit profile
      // TODO: Add settings
      // TODO: Add notifications
      // Trophies Page
      GoRoute(
        path: '/trophies',
        name: 'trophies',
        builder: (context, state) => const TrophiesPage(),
      ),
      // PM Projects
      GoRoute(
        path: RouteNames.pmProjects,
        name: 'pm_projects',
        builder: (context, state) => const PMProjectsPage(),
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
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}