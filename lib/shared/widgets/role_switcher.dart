import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/shared/providers/user_session_provider.dart';
import '/shared/models/user_role.dart';

class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionProvider>();

    return PopupMenuButton<UserRole>(
      icon: const Icon(Icons.person_outline),
      onSelected: (role) {
        session.login(
          userId: session.userId ?? 'test-id',
          email: session.userEmail ?? 'test@example.com',
          name: session.userName ?? 'Tester',
          role: role,
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: UserRole.hr,
          child: Text('Switch to HR'),
        ),
        const PopupMenuItem(
          value: UserRole.projectManager,
          child: Text('Switch to PM'),
        ),
        const PopupMenuItem(
          value: UserRole.student,
          child: Text('Switch to Student'),
        ),
      ],
    );
  }
}
