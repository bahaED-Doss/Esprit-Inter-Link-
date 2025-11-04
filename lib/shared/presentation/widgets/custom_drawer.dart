import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String role;
  const CustomDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerItems = [];
    if (role == 'student') {
      drawerItems = [
        _drawerItem('Profil', 'assets/icons/userIcon.png', () {
          Navigator.pushNamed(context, '/studentProfile');
        }),
        _drawerItem('Offres', 'assets/icons/offers.png', () {
          Navigator.pushNamed(context, '/offers');
        }),
        _drawerItem('Mes candidatures', 'assets/icons/applications.png', () {
          Navigator.pushNamed(context, '/myApplications');
        }),
        _drawerItem('Test', 'assets/icons/test.png', () {
          Navigator.pushNamed(context, '/test');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          Navigator.pushNamed(context, '/');
        }),
      ];
    } else if (role == 'hr') {
      drawerItems = [
        _drawerItem('Candidatures', 'assets/icons/applications.png', () {
          Navigator.pushNamed(context, '/applications');
        }),
        _drawerItem('Candidats', 'assets/icons/candidates.png', () {
          Navigator.pushNamed(context, '/candidates');
        }),
        _drawerItem('Profil & Société', 'assets/icons/company.png', () {
          Navigator.pushNamed(context, '/companyProfile');
        }),
        _drawerItem('Test', 'assets/icons/test.png', () {
          Navigator.pushNamed(context, '/test');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          Navigator.pushNamed(context, '/');
        }),
      ];
    } else if (role == 'pm') {
      drawerItems = [
        _drawerItem('Profil', 'assets/icons/userIcon.png', () {
          Navigator.pushNamed(context, '/pmProfile');
        }),
        _drawerItem('Projets', 'assets/icons/projects.png', () {
          Navigator.pushNamed(context, '/projects');
        }),
        _drawerItem('Stagiaires', 'assets/icons/interns.png', () {
          Navigator.pushNamed(context, '/interns');
        }),
        _drawerItem('Tâches', 'assets/icons/tasks.png', () {
          Navigator.pushNamed(context, '/tasks');
        }),
        _drawerItem('Déconnexion', 'assets/icons/logout.png', () {
          Navigator.pushNamed(context, '/');
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
