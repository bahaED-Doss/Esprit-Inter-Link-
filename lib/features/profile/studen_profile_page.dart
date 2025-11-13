// ❌ IMPORTATION STATIQUE SUPPRIMÉE (Source du bug de non-rafraîchissement)
// import 'package:esprit_interlink/data/datasources/local/profile_data.dart' hide WorkExperience, Education, Appreciation;

// ✅ IMPORTATION CORRIGÉE
import 'package:esprit_interlink/features/profile/profile_section_title.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Import pour FileImage
import '../../../features/profile/studen_profile_page.dart';

// Import des pages d'édition
import '../auth/presentation/models/profile_models.dart';
import 'edit_education_page.dart';
import 'edit_work_experience_page.dart';
import 'edit_about_me_page.dart';
import 'edit_skills_page.dart';
import 'edit_languages_page.dart';
import 'edit_appreciation_page.dart';
import 'edit_resume_page.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(force: true); // Forcer le rechargement lors du premier chargement
    });
  }

  // Méthode dédiée pour charger les données via le Provider
  Future<void> _loadData({bool force = false}) async {
    // Éviter les rechargements multiples si déjà en cours
    if (_isRefreshing && !force) return;

    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      await authProvider.loadProfileData();
    }

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // Méthode de déconnexion
  void _logOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    context.goNamed('login');
  }

  // Méthode de navigation mise à jour (async/await)
  void _openEditPage(BuildContext context, {required String title, dynamic data}) async {
    Widget page;
    final user = context.read<AuthProvider>().user;

    switch (title) {
      case 'About me':
        page = EditAboutMePage(initialText: user?.aboutMe ?? 'Tell me about you...');
        break;
      case 'Work experience':
        page = EditWorkExperiencePage(experience: data as WorkExperience?);
        break;
      case 'Education':
        page = EditEducationPage(education: data as Education?);
        break;
      case 'Skill':
        page = const EditSkillsPage();
        break;
      case 'Language':
        page = const EditLanguagesPage();
        break;
      case 'Appreciation':
        page = EditAppreciationPage(appreciation: data as Appreciation?);
        break;
      case 'Resume':
        page = const EditResumePage();
        break;
      default:
        return;
    }

    // Attendre le retour de la page d'édition
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    // Recharger les données quand l'utilisateur revient
    _loadData();
  }

  // Méthode de mise à jour de l'image de profil
  void _updateProfilePicture(AuthProvider authProvider) async {
    await authProvider.updateProfilePicture();
    // Le AuthProvider appelle déjà loadProfileData() après la mise à jour
  }


  @override
  Widget build(BuildContext context) {
    // Utiliser context.watch() pour écouter les changements
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Lire les listes directement depuis le Provider
    final workExperiences = authProvider.workExperiences;
    final educationList = authProvider.educations;
    final skills = authProvider.skills;
    final languages = authProvider.languages;
    final appreciations = authProvider.appreciations;

    final bool hasResume = (user?.resumePath != null && user!.resumePath!.isNotEmpty);

    // Logique de l'image de profil (corrigée)
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
            backgroundColor: const Color(0xFFF5F5FF),
            title: const Text('Profile', style: TextStyle(color: Colors.black)),
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

                    // 2. INFORMATIONS DE L'UTILISATEUR (Positionnées en bas à gauche)
                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (authProvider.isLoggedIn) ...[
                            GestureDetector(
                              onTap: () => _updateProfilePicture(authProvider),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: profileImage,
                                backgroundColor: Colors.white,
                                child: user?.avatarPath == null
                                    ? const Icon(Icons.person, color: Color(0xFF8B1C1C), size: 30)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.fullName ?? 'Student User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Sousse, Tunisia',
                              style: TextStyle(
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
                        onTap: () => _openEditPage(context, title: 'About me'),
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

          // Le contenu principal de la page
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- 1. ABOUT ME ---
                      ProfileSectionTile(
                        icon: Icons.person_outline,
                        title: 'About me',
                        hasData: user?.aboutMe != null && user!.aboutMe!.isNotEmpty,
                        content: user?.aboutMe != null && user!.aboutMe!.isNotEmpty
                            ? Text(user.aboutMe!, style: const TextStyle(color: Colors.black87, height: 1.5))
                            : null,
                        onAdd: () => _openEditPage(context, title: 'About me'),
                        onEdit: () => _openEditPage(context, title: 'About me'),
                      ),

                      // --- 2. WORK EXPERIENCE ---
                      ProfileSectionTile(
                        icon: Icons.work_outline,
                        title: 'Work experience',
                        hasData: workExperiences.isNotEmpty,
                        content: workExperiences.isNotEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: workExperiences.map((exp) {
                            return GestureDetector(
                              onTap: () => _openEditPage(context, title: 'Work experience', data: exp),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(exp.company, style: const TextStyle(color: Colors.grey)),
                                    Text(exp.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                            : null,
                        onAdd: () => _openEditPage(context, title: 'Work experience'),
                        onEdit: workExperiences.isNotEmpty
                            ? () => _openEditPage(context, title: 'Work experience', data: workExperiences.first)
                            : null,
                      ),

                      // --- 3. EDUCATION ---
                      ProfileSectionTile(
                        icon: Icons.school_outlined,
                        title: 'Education',
                        hasData: educationList.isNotEmpty,
                        content: educationList.isNotEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: educationList.map((edu) {
                            return GestureDetector(
                              onTap: () => _openEditPage(context, title: 'Education', data: edu),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(edu.institution, style: const TextStyle(color: Colors.grey)),
                                    Text('${DateFormat('MMM yyyy').format(edu.startDate)} - ${edu.endDate != null ? DateFormat('MMM yyyy').format(edu.endDate!) : 'Present'}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                            : null,
                        onAdd: () => _openEditPage(context, title: 'Education'),
                        onEdit: educationList.isNotEmpty
                            ? () => _openEditPage(context, title: 'Education', data: educationList.first)
                            : null,
                      ),

                      // --- 4. SKILL ---
                      ProfileSectionTile(
                        icon: Icons.ac_unit_outlined, // ⚠️ Remplacer par une icône de compétence (ex: Icons.star_outline)
                        title: 'Skill',
                        hasData: skills.isNotEmpty,
                        content: skills.isNotEmpty
                            ? Wrap( spacing: 8.0, runSpacing: 8.0,
                          children: skills.map((skill) => Chip(
                            label: Text(skill.name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            backgroundColor: const Color(0xFFF0F0F0),
                          )).toList(),
                        ) : null,
                        onAdd: () => _openEditPage(context, title: 'Skill'),
                        onEdit: () => _openEditPage(context, title: 'Skill'),
                      ),

                      // --- 5. LANGUAGE ---
                      ProfileSectionTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        hasData: languages.isNotEmpty,
                        content: languages.isNotEmpty
                            ? Wrap( spacing: 8.0, runSpacing: 8.0,
                          children: languages.map((lang) => Chip(
                            label: Text(lang.name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            backgroundColor: const Color(0xFFF0F0F0),
                          )).toList(),
                        ) : null,
                        onAdd: () => _openEditPage(context, title: 'Language'),
                        onEdit: () => _openEditPage(context, title: 'Language'),
                      ),


                      // --- 6. APPRECIATION ---
                      ProfileSectionTile(
                        icon: Icons.military_tech_outlined,
                        title: 'Appreciation',
                        hasData: appreciations.isNotEmpty,
                        content: appreciations.isNotEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: appreciations.map((app) {
                            return GestureDetector(
                              onTap: () => _openEditPage(context, title: 'Appreciation', data: app),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(app.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${app.context} - ${app.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                            : null,
                        onAdd: () => _openEditPage(context, title: 'Appreciation'),
                        onEdit: () => _openEditPage(context, title: 'Appreciation', data: appreciations.first),
                      ),


                      // --- 7. RESUME ---
                      ProfileSectionTile(
                        icon: Icons.description_outlined,
                        title: 'Resume',
                        hasData: hasResume,
                        content: hasResume
                            ? ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF8B1C1C), size: 36),
                          title: Text(
                              user?.resumeFileName ?? 'Resume.pdf',
                              style: const TextStyle(fontWeight: FontWeight.w500)
                          ),
                          subtitle: Text(
                              user?.resumeSize ?? 'N/A KB',
                              style: const TextStyle(color: Colors.grey, fontSize: 12)
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              authProvider.deleteUserResume();
                            },
                          ),
                        )
                            : null,
                        onAdd: () => _openEditPage(context, title: 'Resume'),
                        onEdit: () => _openEditPage(context, title: 'Resume'),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(height: 80, decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),),
    );
  }
}