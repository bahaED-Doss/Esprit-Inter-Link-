import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_session_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionProvider>();

    List<Widget> getMenuItems() {
      if (session.isHR) {
        return [
          ListTile(
            title: const Text('Offers'),
            onTap: () => context.push('/applications'),
          ),
          ListTile(
            title: const Text('Applications'),
            onTap: () => context.push('/applications'),
          ),
        ];
      } else if (session.isPM) {
        return [
          ListTile(
            title: const Text('Projects'),
            onTap: () => context.push('/projects'),
          ),
          ListTile(
            title: const Text('Tasks'),
            onTap: () => context.push('/tasks'),
          ),
        ];
      } else if (session.isStudent) {
        return [
          ListTile(
            title: const Text('Browse Offers'),
            onTap: () => context.push('/student_offers' /* path fallback */),
          ),
          ListTile(
            title: const Text('My Applications'),
            onTap: () => context.push('/myApplications'),
          ),
        ];
      } else {
        return [const ListTile(title: Text('No role selected'))];
      }
    }

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Esprit-InterLink')),
          ...getMenuItems(),
        ],
      ),
    );
  }
}
