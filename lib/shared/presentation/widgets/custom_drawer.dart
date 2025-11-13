import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  final String role;
  const CustomDrawer({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerItems = [];
    if (role == 'student') {
      drawerItems = [
        _drawerItem('Profil', 'assets/icons/userIcon.png', () {
          context.pushNamed('studentProfile');
        }),
        _drawerItem('Offres', 'assets/icons/offers.png', () {
          context.pushNamed('offers');
        }),
        _drawerItem('Mes candidatures', 'assets/icons/applications.png', () {
          context.pushNamed('myApplications');
        }),
        _drawerItem('Test', 'assets/icons/test.png', () {
          context.push('/test');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          context.goNamed('login');
        }),
      ];
    } else if (role == 'hr') {
      drawerItems = [
        _drawerItem('Candidatures', 'assets/icons/applications.png', () {
          context.push('/applications');
        }),
        _drawerItem('Candidats', 'assets/icons/candidates.png', () {
          context.push('/candidates');
        }),
        _drawerItem('Profil & Société', 'assets/icons/company.png', () {
          context.push('/companyProfile');
        }),
        _drawerItem('Test', 'assets/icons/test.png', () {
          context.push('/test');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          context.goNamed('login');
        }),
      ];
    } else if (role == 'pm') {
      drawerItems = [
        _drawerItem('Profil', 'assets/icons/userIcon.png', () {
          context.push('/pmProfile');
        }),
        _drawerItem('Projets', 'assets/icons/projects.png', () {
          context.push('/projects');
        }),
        _drawerItem('Stagiaires', 'assets/icons/interns.png', () {
          context.push('/interns');
        }),
        _drawerItem('Tâches', 'assets/icons/tasks.png', () {
          context.push('/tasks');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          context.goNamed('login');
        }),
      ];
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Center(child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Poppins'))),
          ),
          ...drawerItems,
        ],
      ),
    );
  }

  Widget _drawerItem(String title, String iconPath, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(iconPath, width: 24, height: 24),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
      onTap: onTap,
    );
  }
}