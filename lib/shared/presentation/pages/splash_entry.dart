import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/shared/providers/user_session_provider.dart';
import 'package:esprit_interlink/shared/models/user_role.dart';
import 'package:go_router/go_router.dart';

/// Entry point splash that initializes user session and navigates accordingly.
class SplashEntry extends StatefulWidget {
  const SplashEntry({super.key});

  @override
  State<SplashEntry> createState() => _SplashEntryState();
}

class _SplashEntryState extends State<SplashEntry> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = Provider.of<UserSessionProvider>(context, listen: false);
    await session.initFromPrefs();

    // Small delay to show splash
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (session.isLoggedIn && session.userRole != null) {
      final role = session.userRole!;
      if (role == UserRole.student) {
        context.goNamed('student_home');
        return;
      }
      if (role == UserRole.hr) {
        context.goNamed('hr_home');
        return;
      }
      if (role == UserRole.projectManager) {
        context.goNamed('pm_home');
        return;
      }
      if (role == UserRole.admin) {
        context.goNamed('admin_home');
        return;
      }
    }

    // Not logged in -> go to login
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
