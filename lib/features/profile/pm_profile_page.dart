import 'package:esprit_interlink/features/profile/profile_section_title.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'dart:io'; // Import pour FileImage

// 🚀 PAGE D'AFFICHAGE DU PROFIL PM (Convertie en StatefulWidget)
class PMProfilePage extends StatefulWidget {
  const PMProfilePage({super.key});

  @override
  State<PMProfilePage> createState() => _PMProfilePageState();
}

class _PMProfilePageState extends State<PMProfilePage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(force: true);
    });
  }

  Future<void> _loadData({bool force = false}) async {
    if (_isRefreshing && !force) return;
    if (mounted) setState(() => _isRefreshing = true);

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      await authProvider.loadProfileData();
    }

    if (mounted) setState(() => _isRefreshing = false);
  }

  void _logOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    context.goNamed('login');
  }

  // Méthode de navigation mise à jour (async/await)
  void _openEditPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditPMInfoPage()),
    );
    _loadData(); // Rafraîchir au retour
  }

  void _updateProfilePicture(AuthProvider authProvider) async {
    await authProvider.updateProfilePicture();
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.pmProfile;
    final isProfileComplete = profile != null;

    // Logique de l'image
    ImageProvider profileImage;
    final avatarPath = user?.avatarPath;
    if (avatarPath != null && avatarPath.isNotEmpty && File(avatarPath).existsSync()) {
      profileImage = FileImage(File(avatarPath));
    } else {
      profileImage = const AssetImage('assets/images/avatar.png');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            automaticallyImplyLeading: false,
            title: const Text('PM Profile', style: TextStyle(color: Colors.black)),
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF8B1C1C),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                ),
                // Utilisation d'un Stack pour corriger l'overflow (comme sur les autres profils)
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.share, color: Colors.white, size: 24),
                          const SizedBox(width: 16),
                          const Icon(Icons.settings, color: Colors.white, size: 24),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _logOut(context),
                            child: const Icon(Icons.logout, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user != null)
                            ...[
                              GestureDetector(
                                onTap: () => _updateProfilePicture(authProvider),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: profileImage,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.fullName ?? 'Project Manager',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                profile != null ? '${profile.city}, ${profile.country}' : 'PM Location',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 16,
                      right: 24,
                      child: GestureDetector(
                        onTap: () => _openEditPage(context), // Appel correct
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Edit profile', style: TextStyle(color: Color(0xFF8B1C1C), fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(width: 8),
                              Icon(Icons.edit, color: Color(0xFF8B1C1C), size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- PM Info (Section Principale) ---
                      ProfileSectionTile(
                        icon: Icons.assignment_ind_outlined,
                        title: 'Manager Details',
                        hasData: isProfileComplete,
                        content: isProfileComplete
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Job Title:', profile!.jobTitle),
                            _infoRow('Department:', profile.department),
                            _infoRow('Phone:', profile.phone),
                            _infoRow('Location:', '${profile.city}, ${profile.country}'),
                          ],
                        )
                            : null,
                        onAdd: () => _openEditPage(context),
                        onEdit: () => _openEditPage(context),
                      ),
                      // ... Autres sections PM (Tasks, Projects, Interns) peuvent être ajoutées ici
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(height: 80, decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),),
    );
  }
}

// 🚀 PAGE D'ÉDITION DU PROFIL PM (StatefulWidget)
class EditPMInfoPage extends StatefulWidget {
  const EditPMInfoPage({super.key});

  @override
  State<EditPMInfoPage> createState() => _EditPMInfoPageState();
}

class _EditPMInfoPageState extends State<EditPMInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().pmProfile;
    if (profile != null) {
      _jobTitleController.text = profile.jobTitle;
      _departmentController.text = profile.department;
      _phoneController.text = profile.phone;
      _cityController.text = profile.city;
      _countryController.text = profile.country;
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    bool success = false;
    String? error;
    try {
      success = await authProvider.updatePMProfile(
        jobTitle: _jobTitleController.text,
        department: _departmentController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        country: _countryController.text,
      );
      if (!success) error = authProvider.error;
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Erreur de sauvegarde')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Manager Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Job Title', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _jobTitleController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      const SizedBox(height: 20),

                      const Text('Department', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _departmentController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      const SizedBox(height: 20),

                      const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _phoneController, decoration: _inputDecoration, keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('City', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            TextFormField(controller: _cityController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Country', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            TextFormField(controller: _countryController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SAVE PROFILE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}