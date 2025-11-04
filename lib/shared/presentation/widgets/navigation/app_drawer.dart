import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../providers/user_session_provider.dart';
import '../../../models/user_role.dart';

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
          // TODO: Navigate to profile
        },
      ),
      _buildMenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        onTap: () {
          context.pop();
          // TODO: Navigate to settings
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
          // TODO: Navigate to company setup
        },
      ),
      _buildMenuItem(
        icon: Icons.work_outline,
        title: 'Manage Offers',
        onTap: () {
          context.pop();
          // TODO: Navigate to offers management
        },
      ),
      _buildMenuItem(
        icon: Icons.assignment_outlined,
        title: 'Applications',
        onTap: () {
          context.pop();
          // TODO: Navigate to applications
        },
      ),
      _buildMenuItem(
        icon: Icons.person_add_outlined,
        title: 'Create PM Account',
        onTap: () {
          context.pop();
          // TODO: Navigate to create PM
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
          // TODO: Navigate to projects list
        },
      ),
      _buildMenuItem(
        icon: Icons.task_outlined,
        title: 'Tasks Overview',
        onTap: () {
          context.pop();
          // TODO: Navigate to tasks overview
        },
      ),
      _buildMenuItem(
        icon: Icons.feedback_outlined,
        title: 'Feedback',
        onTap: () {
          context.pop();
          // TODO: Navigate to feedback
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
          // TODO: Navigate to offers list
        },
      ),
      _buildMenuItem(
        icon: Icons.assignment_turned_in_outlined,
        title: 'My Applications',
        onTap: () {
          context.pop();
          // TODO: Navigate to my applications
        },
      ),
      _buildMenuItem(
        icon: Icons.folder_special_outlined,
        title: 'My Project',
        onTap: () {
          context.pop();
          // TODO: Navigate to my project
        },
      ),
      _buildMenuItem(
        icon: Icons.view_kanban_outlined,
        title: 'My Tasks',
        onTap: () {
          context.pop();
          // TODO: Navigate to tasks kanban
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