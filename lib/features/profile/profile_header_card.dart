import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
// NOTE: Assurez-vous que ce chemin est le bon pour votre simulation
import 'package:esprit_interlink/data/datasources/local/profile_data.dart';
import 'dart:io'; // Pour gérer le chemin du fichier local

class ProfileHeaderCard extends StatelessWidget {
  final bool hasData;
  final VoidCallback onEditProfilePicture; // NOUVEAU

  const ProfileHeaderCard({
    super.key,
    required this.hasData,
    required this.onEditProfilePicture, // NOUVEAU
  });

  @override
  Widget build(BuildContext context) {
    // Écouter l'AuthProvider pour obtenir l'utilisateur actuel et son avatarPath
    final user = context.watch<AuthProvider>().user;
    final avatarPath = user?.avatarPath;

    // Déterminer la source de l'image
    ImageProvider imageProvider;
    if (avatarPath != null && File(avatarPath).existsSync()) {
      imageProvider = FileImage(File(avatarPath));
    } else {
      // Image par défaut si non défini ou non trouvé
      imageProvider = const AssetImage('assets/images/avatar.png');
    }

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF8B1C1C),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Stack(
        children: [
          // Arrière-plan stylisé
          // ... (code de l'arrière-plan stylisé)

          // Contenu du Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icones de partage et paramètres
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 24),
                    SizedBox(width: 16),
                    Icon(Icons.settings, color: Colors.white, size: 24),
                  ],
                ),

                // Informations de l'utilisateur (Simplifié pour utiliser User? user)
                if (user != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo de profil + icône d'édition
                      GestureDetector(
                        onTap: onEditProfilePicture, // 👈 Action d'édition
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: imageProvider,
                              backgroundColor: Colors.white,
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white70,
                                child: Icon(Icons.camera_alt, size: 12, color: Color(0xFF8B1C1C)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        user.fullName ?? 'Student',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text( // Simulation de la localisation statique
                        StudentProfileData.location,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                // Bouton Edit Profile (pour le About Me/Global Profile)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    // ... (code du bouton Edit profile existant)
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}