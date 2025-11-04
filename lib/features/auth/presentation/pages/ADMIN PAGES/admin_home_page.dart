import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

// Assurez-vous que ces imports pointent vers les bons fichiers
import 'admin_stats_view.dart';
import 'admin_user_list_view.dart';


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _sortColumn = 'fullName';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charger les données initiales
      _loadData();
    });
  }

  // 🚀 NOUVELLE MÉTHODE DE RECHARGEMENT
  Future<void> _loadData() async {
    // Utiliser context.read dans une méthode
    await context.read<AuthProvider>().fetchAllUsersAndStats();
  }

  void _logOut() {
    context.read<AuthProvider>().logout();
    context.goNamed('login');
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  // 🚀 NOUVELLE MÉTHODE POUR NAVIGUER ET ATTENDRE LE RÉSULTAT
  void _navigateAndRefresh(User? user) async {
    // Naviguer vers la page de formulaire et attendre un résultat (bool)
    final result = await context.pushNamed<bool>(
        'admin_user_form',
        extra: user
    );

    // Si la page de formulaire est revenue avec 'true' (succès), rafraîchir les données
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF8B1C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logOut,
          ),
          // 🚀 AJOUT D'UN BOUTON REFRESH MANUEL
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading && auth.allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tri des utilisateurs
          final users = List<User>.from(auth.allUsers);
          users.sort((a, b) {
            int comparison;
            switch (_sortColumn) {
              case 'email':
                comparison = a.email.compareTo(b.email);
                break;
              case 'role':
                comparison = a.role.compareTo(b.role);
                break;
              case 'fullName':
              default:
                comparison = (a.fullName ?? '').compareTo(b.fullName ?? '');
            }
            return _sortAscending ? comparison : -comparison;
          });

          return RefreshIndicator(
            onRefresh: _loadData, // Utiliser la méthode locale
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Statistiques
                Text(
                  'User Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                AdminStatsView(stats: auth.userStats),

                const SizedBox(height: 24),

                // 2. Liste des utilisateurs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Manage Users (${users.length})',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortColumn,
                      icon: const Icon(Icons.sort),
                      items: const [
                        DropdownMenuItem(value: 'fullName', child: Text('Sort by Name')),
                        DropdownMenuItem(value: 'email', child: Text('Sort by Email')),
                        DropdownMenuItem(value: 'role', child: Text('Sort by Role')),
                      ],
                      onChanged: (value) {
                        if (value != null) _onSort(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 🚀 Passer la fonction de navigation à la liste
                AdminUserListView(
                  users: users,
                  onEditUser: (user) => _navigateAndRefresh(user),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 🚀 Appeler la nouvelle fonction de navigation
          _navigateAndRefresh(null);
        },
        backgroundColor: const Color(0xFF8B1C1C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}