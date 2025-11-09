import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/shared/providers/user_session_provider.dart';
import '/shared/widgets/app_drawer.dart';
import '/core/theme/app_colors.dart';
import '/shared/models/user_role.dart';
import '/shared/widgets/role_switcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSessionProvider>();

    // If user not logged in yet
    if (!userSession.isLoggedIn || userSession.userName == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = userSession.userName ?? 'User';
    final userRole = userSession.userRole ?? UserRole.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Esprit-InterLink'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          // 🔹 Role switcher button (for testing only)
          const RoleSwitcher(),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName, userRole),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (userSession.isHR) _buildHRQuickActions(context),
                  if (userSession.isPM) _buildPMQuickActions(context),
                  if (userSession.isStudent) _buildStudentQuickActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, UserRole userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              userRole.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHRQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'Create Offer',
                subtitle: 'Post new internship',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/hr/create-offer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.description_outlined,
                title: 'Applications',
                subtitle: 'Review submissions',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/hr/applications'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPMQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.folder_outlined,
                title: 'Projects',
                subtitle: 'Manage projects',
                color: AppColors.primary,
                // route available in main.dart is '/projects'
                onTap: () => Navigator.pushNamed(context, '/projects'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.add_task,
                title: 'Create Task',
                subtitle: 'Add new task',
                color: Colors.orange,
                // main.dart exposes '/tasks' which opens the PM tasks page
                onTap: () => Navigator.pushNamed(context, '/tasks'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.search,
                title: 'Browse Offers',
                subtitle: 'Find internships',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/student/offers'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.description_outlined,
                title: 'Applications',
                subtitle: 'Track status',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/student/applications'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
