import 'package:flutter/material.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;
  final List<Map<String, dynamic>> _roles = [
    {'label': 'Student', 'icon': Icons.school, 'color': const Color(0xFF8B1C1C)},
    {'label': 'HR', 'icon': Icons.business_center, 'color': const Color(0xFF8B1C1C)},
    {'label': 'PM', 'icon': Icons.engineering, 'color': const Color(0xFF8B1C1C)},
  ];

  void _navigateToHome() {
    if (_selectedRole == 'Student') {
      Navigator.pushReplacementNamed(context, '/student_home');
    } else if (_selectedRole == 'HR') {
      Navigator.pushReplacementNamed(context, '/hr_home');
    } else if (_selectedRole == 'PM') {
      Navigator.pushReplacementNamed(context, '/pm_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C1C),
        title: const Text('Select User Role', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Text(
                'This page is only for development purposes to make navigation easier.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your role to continue:',
              style: TextStyle(fontSize: 18, color: Color(0xFF8B1C1C), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ..._roles.map((role) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = role['label'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedRole == role['label'] ? const Color(0xFF8B1C1C).withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: _selectedRole == role['label'] ? const Color(0xFF8B1C1C) : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(role['icon'], color: const Color(0xFF8B1C1C)),
                    title: Text(
                      role['label'],
                      style: const TextStyle(
                        color: Color(0xFF8B1C1C),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    trailing: _selectedRole == role['label']
                        ? const Icon(Icons.check_circle, color: Color(0xFF8B1C1C))
                        : null,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedRole == null ? null : _navigateToHome,
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
