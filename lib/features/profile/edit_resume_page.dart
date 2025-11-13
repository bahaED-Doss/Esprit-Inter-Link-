import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';

class EditResumePage extends StatelessWidget {
  const EditResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser watch pour que l'UI se mette à jour si le CV est supprimé
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final bool hasResume = (user?.resumePath != null && user!.resumePath!.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Resume'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.isLoading)
              const Center(child: CircularProgressIndicator()),

            // Afficher le CV actuel s'il existe
            if (hasResume)
              Card(
                elevation: 0,
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
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
                      // Appeler la suppression
                      authProvider.deleteUserResume();
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Bouton pour Uploader (ou remplacer)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.updateUserResume();
                },
                icon: Icon(hasResume ? Icons.edit : Icons.cloud_upload_outlined, color: Colors.white),
                label: Text(hasResume ? 'REPLACE RESUME' : 'UPLOAD RESUME', style: const TextStyle(color: Colors.white)),
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
    );
  }
}