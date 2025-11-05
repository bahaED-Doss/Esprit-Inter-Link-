import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

// 🚀 NOUVEAUX IMPORTS
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; // Pour jsonEncode

// Imports des widgets locaux
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
      _loadData();
    });
  }

  Future<void> _loadData() async {
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

  void _navigateAndRefresh(User? user) async {
    final result = await context.pushNamed<bool>(
        'admin_user_form',
        extra: user
    );
    if (result == true) {
      _loadData();
    }
  }

  // 🚀 NOUVELLE MÉTHODE : Afficher le QR Code
  void _showUserQrCode(BuildContext context, List<User> users) {
    // 1. Sérialiser la liste d'utilisateurs en JSON (en utilisant la méthode sécurisée)
    final List<Map<String, dynamic>> userListForQr = users.map((user) => user.toJsonForQr()).toList();
    final String jsonData = jsonEncode(userListForQr);

    // 2. Afficher le dialogue
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('All Users QR Code'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: QrImageView(
            data: jsonData,
            version: QrVersions.auto, // Laisse le package décider de la taille
            size: 280.0,
            gapless: false, // Laisse un petit bord blanc
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF8B1C1C), // Couleur principale
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 Utiliser Consumer pour envelopper tout le Scaffold
    // Cela donne accès à 'auth' dans l'AppBar ET le body
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {

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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            backgroundColor: const Color(0xFF8B1C1C),
            foregroundColor: Colors.white,
            actions: [
              // 🚀 NOUVEAU BOUTON QR CODE
              IconButton(
                icon: const Icon(Icons.qr_code_2),
                tooltip: 'Show All Users QR Code',
                onPressed: () {
                  // Passer la liste des utilisateurs (non triée ou triée, peu importe)
                  _showUserQrCode(context, auth.allUsers);
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logOut,
              ),
            ],
          ),
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
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
                AdminUserListView(
                  users: users, // Utiliser la liste triée
                  onEditUser: (user) => _navigateAndRefresh(user),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _navigateAndRefresh(null);
            },
            backgroundColor: const Color(0xFF8B1C1C),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}