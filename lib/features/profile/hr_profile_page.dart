import 'package:esprit_interlink/features/profile/profile_section_title.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'dart:io'; // Import pour FileImage

// Import de la page de création de PM
import 'create_pm_page.dart';

// 🚀 PAGE D'ÉDITION DES INFORMATIONS DE L'ENTREPRISE (Convertie en StatefulWidget)
class EditCompanyInfoPage extends StatefulWidget {
  const EditCompanyInfoPage({super.key});

  @override
  State<EditCompanyInfoPage> createState() => _EditCompanyInfoPageState();
}

class _EditCompanyInfoPageState extends State<EditCompanyInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _sectorController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Utiliser context.read dans initState
    final profile = context.read<AuthProvider>().companyProfile;
    if (profile != null) {
      _nameController.text = profile.companyName;
      _identifierController.text = profile.companyIdentifier;
      _sectorController.text = profile.industrySector;
      _addressController.text = profile.companyAddress;
      _cityController.text = profile.city;
      _countryController.text = profile.country;
      _descriptionController.text = profile.companyDescription;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _sectorController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // 🚀 CORRECTION : Gestion asynchrone sécurisée de la sauvegarde
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    bool success = false;
    String? error;
    try {
      success = await authProvider.updateCompanyProfile(
        companyName: _nameController.text,
        companyIdentifier: _identifierController.text,
        industrySector: _sectorController.text,
        companyAddress: _addressController.text,
        city: _cityController.text,
        country: _countryController.text,
        companyDescription: _descriptionController.text,
      );
      if (!success) error = authProvider.error;
    } catch (e) {
      error = e.toString();
    }

    // Vérifier si le widget est toujours monté avant de naviguer ou de setState
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
    final authProvider = context.watch<AuthProvider>();

    // 🚀 DÉBOGAGE : Imprimer le rôle actuel
    print('DEBUG: Current user role in HRProfilePage: ${authProvider.user?.role}');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
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
                      // ... (Tous les TextFormFields)
                      const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _nameController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      const SizedBox(height: 20),
                      const Text('Company Identifier', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _identifierController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      const SizedBox(height: 20),
                      const Text('Industry Sector', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _sectorController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      const SizedBox(height: 20),
                      const Text('Company Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _addressController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Requis' : null),
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
                      const Text('Company Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _descriptionController, maxLines: 5, minLines: 3, decoration: _inputDecoration),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

// 🚀 PAGE D'AFFICHAGE DU PROFIL RH (Convertie en StatefulWidget)
class HRProfilePage extends StatefulWidget {
  const HRProfilePage({super.key});

  @override
  State<HRProfilePage> createState() => _HRProfilePageState();
}

class _HRProfilePageState extends State<HRProfilePage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Charger les données lorsque la page s'affiche
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
  void _openEditPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditCompanyInfoPage()),
    );
    // Rafraîchir les données au retour
    _loadData();
  }

  void _openCreatePMPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePMPage()),
    );
    // (Pas besoin de recharger les données HR ici, mais on pourrait)
  }

  void _updateProfilePicture(AuthProvider authProvider) async {
    await authProvider.updateProfilePicture();
    // Le Provider appelle loadProfileData, donc l'UI (qui watch) se mettra à jour.
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser context.watch() pour écouter les changements
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.companyProfile;
    final isProfileComplete = profile?.companyName.isNotEmpty ?? false;

    // Logique de l'image (Logo de l'entreprise ou avatar)
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
            backgroundColor: const Color(0xFFF5F5F5),
            title: const Text('Company Profile', style: TextStyle(color: Colors.black)),
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF8B1C1C),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                ),
                // 🚀 CORRECTION OVERFLOW : Utilisation d'un Stack
                child: Stack(
                  children: [
                    // 1. LIGNE DES ICÔNES (En haut à droite)
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

                    // 2. INFORMATIONS DE L'ENTREPRISE (Positionnées en bas à gauche)
                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (authProvider.isLoggedIn)
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
                                profile?.companyName ?? user?.fullName ?? 'HR User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profile != null ? '${profile.city}, ${profile.country}' : 'Location Unknown',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                        ],
                      ),
                    ),

                    // 3. Bouton Edit Profile (Positionné en bas à droite)
                    Positioned(
                      bottom: 16,
                      right: 24,
                      child: GestureDetector(
                        onTap: _openEditPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit profile',
                                style: TextStyle(
                                  color: Color(0xFF8B1C1C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                color: Color(0xFF8B1C1C),
                                size: 16,
                              ),
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
                      // --- Company Info (Section Principale) ---
                      ProfileSectionTile(
                        icon: Icons.business_center_outlined,
                        title: 'Company Information',
                        hasData: isProfileComplete,
                        content: isProfileComplete
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Name:', profile!.companyName),
                            _infoRow('Identifier:', profile.companyIdentifier),
                            _infoRow('Sector:', profile.industrySector),
                            _infoRow('Address:', profile.companyAddress),
                            _infoRow('Location:', '${profile.city}, ${profile.country}'),
                            const SizedBox(height: 10),
                            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(profile.companyDescription, style: const TextStyle(color: Colors.black87, height: 1.5)),
                          ],
                        )
                            : null,
                        onAdd: _openEditPage,
                        onEdit: _openEditPage,
                      ),

                      // 🚀 BOUTON D'ADMINISTRATION POUR CRÉER UN PM
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openCreatePMPage,
                          icon: const Icon(Icons.person_add, color: Colors.white),
                          label: const Text('CREATE PROJECT MANAGER ACCOUNT', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B1C1C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
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
}