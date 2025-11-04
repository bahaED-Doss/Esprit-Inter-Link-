import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

class AdminUserListView extends StatelessWidget {
  final List<User> users;
  // 🚀 Accepter la fonction de navigation en paramètre
  final Function(User) onEditUser;

  const AdminUserListView({
    super.key,
    required this.users,
    required this.onEditUser
  });

  void _confirmDelete(BuildContext context, AuthProvider auth, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${user.fullName ?? user.email}? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.adminDeleteUser(user.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          IconData icon;
          switch (user.role.toLowerCase()) {
            case 'student': icon = Icons.school; break;
            case 'hr': icon = Icons.business_center; break;
            case 'pm': icon = Icons.assignment_ind; break;
            default: icon = Icons.person;
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B1C1C).withOpacity(0.1),
              child: Icon(icon, color: const Color(0xFF8B1C1C)),
            ),
            title: Text(user.fullName ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${user.email} (Role: ${user.role})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                  // 🚀 Appeler la fonction passée en paramètre
                  onPressed: () => onEditUser(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () => _confirmDelete(context, auth, user),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      ),
    );
  }
}