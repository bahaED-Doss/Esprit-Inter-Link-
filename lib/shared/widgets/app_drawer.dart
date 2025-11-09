import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            // main routes use '/offers' for the offers page
            onTap: () => Navigator.pushNamed(context, '/offers'),
          ),
          ListTile(
            title: const Text('Applications'),
            onTap: () => Navigator.pushNamed(context, '/applications'),
          ),
        ];
      } else if (session.isPM) {
        return [
          ListTile(
            title: const Text('Projects'),
            onTap: () => Navigator.pushNamed(context, '/projects'),
          ),
          ListTile(
            title: const Text('Tasks'),
            onTap: () => Navigator.pushNamed(context, '/tasks'),
          ),
        ];
      } else if (session.isStudent) {
        return [
          ListTile(
            title: const Text('Browse Offers'),
            onTap: () => Navigator.pushNamed(context, '/offers'),
          ),
          ListTile(
            title: const Text('My Applications'),
            onTap: () => Navigator.pushNamed(context, '/myApplications'),
          ),
          ListTile(
            title: const Text('My Project'),
            onTap: () => Navigator.pushNamed(context, '/student/project'),
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
