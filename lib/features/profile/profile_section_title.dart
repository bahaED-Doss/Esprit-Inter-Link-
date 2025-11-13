import 'package:flutter/material.dart';

class ProfileSectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? content; // Contenu à afficher sous le titre
  final bool hasData; // Indique si la section a des données
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;

  const ProfileSectionTile({
    super.key,
    required this.icon,
    required this.title,
    this.content,
    required this.hasData,
    this.onEdit,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Si la section n'a pas de données, afficher uniquement la tuile de base
    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: ListTile(
            leading: Icon(icon, color: Colors.black54),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF8B1C1C)),
              onPressed: onAdd, // Bouton + pour ajouter
            ),
          ),
        ),
      );
    }

    // Si la section a des données, afficher la tuile détaillée
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(hasData ? Icons.edit : Icons.add, color: hasData ? Colors.black54 : const Color(0xFF8B1C1C)),
                    onPressed: hasData ? onEdit : onAdd,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (content != null) content!,
            ],
          ),
        ),
      ),
    );
  }
}