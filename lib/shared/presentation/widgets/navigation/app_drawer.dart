import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../providers/user_session_provider.dart';
import '../../../models/user_role.dart';
import '../../../../routes/route_names.dart';

/// App Drawer - Shows different menu items based on user role
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSessionProvider>();

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildHeader(context, userSession),

          // Menu Items (Role-based)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context, userSession),
            ),
          ),

          // Logout Button
          _buildLogoutButton(context, userSession),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserSessionProvider userSession) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              userSession.userName?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // User Name
          Text(
            userSession.userName ?? 'Guest User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // User Role
          Text(
            userSession.userRole?.displayName ?? 'Not logged in',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, UserSessionProvider userSession) {
    final role = userSession.userRole;

    if (role == null) {
      // Not logged in
      return [
        _buildMenuItem(
          icon: Icons.login,
          title: 'Login',
          onTap: () {
            context.pop();
            // TODO: Navigate to login
          },
        ),
      ];
    }

    // Common menu items for all roles
    List<Widget> items = [
      _buildMenuItem(
        icon: Icons.home_outlined,
        title: 'Home',
        onTap: () {
          context.pop();
          context.go('/home');
        },
      ),
      const Divider(),
    ];

    // Role-specific menu items
    if (role == UserRole.hr) {
      items.addAll(_buildHRMenu(context));
    } else if (role == UserRole.projectManager) {
      items.addAll(_buildPMMenu(context));
    } else if (role == UserRole.student) {
      items.addAll(_buildStudentMenu(context));
    }

    // Common bottom items
    items.addAll([
      const Divider(),
      _buildMenuItem(
        icon: Icons.person_outline,
        title: 'Profile',
        onTap: () {
          context.pop();
          context.go(RouteNames.profile);
        },
      ),
      _buildMenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        onTap: () {
          context.pop();
          context.go(RouteNames.settings);
        },
      ),
    ]);

    return items;
  }

  List<Widget> _buildHRMenu(BuildContext context) {
    return [
      _buildMenuItem(
        icon: Icons.business_outlined,
        title: 'Company Profile',
        onTap: () {
          context.pop();
          context.go(RouteNames.companySetup);
        },
      ),
      _buildMenuItem(
        icon: Icons.work_outline,
        title: 'Manage Offers',
        onTap: () {
          context.pop();
          context.go(RouteNames.home + '/offers');
        },
      ),
      _buildMenuItem(
        icon: Icons.assignment_outlined,
        title: 'Applications',
        onTap: () {
          context.pop();
          context.go(RouteNames.home + '/applications');
        },
      ),
      _buildMenuItem(
        icon: Icons.person_add_outlined,
        title: 'Create PM Account',
        onTap: () {
          context.pop();
          // TODO: add create PM route
        },
      ),
    ];
  }

  List<Widget> _buildPMMenu(BuildContext context) {
    return [
      _buildMenuItem(
        icon: Icons.folder_outlined,
        title: 'Projects',
        onTap: () {
          context.pop();
          context.go(RouteNames.pmProjects);
        },
      ),
      _buildMenuItem(
        icon: Icons.task_outlined,
        title: 'Tasks Overview',
        onTap: () {
          context.pop();
          context.go(RouteNames.tasks);
        },
      ),
      _buildMenuItem(
        icon: Icons.feedback_outlined,
        title: 'Feedback',
        onTap: () {
          context.pop();
          // no route yet - keep drawer closed
        },
      ),
    ];
  }

  List<Widget> _buildStudentMenu(BuildContext context) {
    return [
      _buildMenuItem(
        icon: Icons.search,
        title: 'Browse Offers',
        onTap: () {
          context.pop();
          context.go(RouteNames.offers);
        },
      ),
      _buildMenuItem(
        icon: Icons.assignment_turned_in_outlined,
        title: 'My Applications',
        onTap: () {
          context.pop();
          context.go(RouteNames.home + RouteNames.offers); // fallback - route not defined separately
        },
      ),
      _buildMenuItem(
        icon: Icons.folder_special_outlined,
        title: 'My Project',
        onTap: () {
          context.pop();
          context.go(RouteNames.myProject);
        },
      ),
      _buildMenuItem(
        icon: Icons.view_kanban_outlined,
        title: 'My Tasks',
        onTap: () {
          context.pop();
          context.go(RouteNames.tasks);
        },
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserSessionProvider userSession) {
    if (!userSession.isLoggedIn) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () async {
          await userSession.logout();
          if (context.mounted) {
            context.pop();
            context.go('/');
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}