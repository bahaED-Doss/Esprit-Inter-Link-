import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/profile_models.dart';

class EditSkillsPage extends StatefulWidget {
  const EditSkillsPage({super.key});

  @override
  State<EditSkillsPage> createState() => _EditSkillsPageState();
}

class _EditSkillsPageState extends State<EditSkillsPage> {
  final _searchController = TextEditingController();
  List<Skill> _selectedSkills = [];
  bool _isLoading = false;

  // Simulation d'une base de données de compétences suggérées
  final List<String> _suggestedSkills = [
    'Leadership', 'Teamwork', 'Visioner', 'Target oriented', 'Consistent',
    'Graphic Design', 'UI/UX Design', 'Adobe Indesign', 'Web Design', 'Product Design'
  ];

  @override
  void initState() {
    super.initState();
    // Charger les compétences de l'utilisateur au démarrage
    _selectedSkills = List.from(context.read<AuthProvider>().skills);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addSkill(String name) {
    name = name.trim();
    if (name.isNotEmpty && !_selectedSkills.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      setState(() {
        _selectedSkills.add(Skill(userId: 0, name: name));
      });
      _searchController.clear();
    }
  }

  void _removeSkill(Skill skill) {
    setState(() {
      _selectedSkills.removeWhere((s) => s.name == skill.name);
    });
  }

  void _saveSkills() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      // 1. Déterminer les compétences à ajouter (nouvelles) et à supprimer (anciennes qui ne sont plus là)
      final existingSkills = authProvider.skills;

      // Compétences à supprimer (dans DB mais pas dans la nouvelle liste)
      final skillsToDelete = existingSkills.where(
              (e) => !_selectedSkills.any((s) => s.name == e.name)
      ).toList();

      // Compétences à ajouter (dans la nouvelle liste mais pas dans DB)
      final skillsToAdd = _selectedSkills.where(
              (s) => !existingSkills.any((e) => e.name == s.name)
      ).toList();

      // 2. Exécuter les suppressions
      for (var skill in skillsToDelete) {
        if (skill.id != null) {
          await authProvider.deleteSkill(skill.id!);
        }
      }

      // 3. Exécuter les ajouts
      for (var skill in skillsToAdd) {
        await authProvider.addSkill(skill.name);
      }

      // Recharger les données fraîches depuis la base
      await authProvider.loadProfileData();

      // Retourner true pour indiquer que les modifications ont été sauvegardées
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Échec de la sauvegarde des compétences')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Skill'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Champ de recherche et ajout
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search skills or type a new one',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onFieldSubmitted: (value) => _addSkill(value),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),

            // Compétences sélectionnées (Chips)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedSkills.map((skill) => Chip(
                  label: Text(skill.name, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF8B1C1C),
                  deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onDeleted: () => _removeSkill(skill),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Suggestions filtrées
            Expanded(
              child: ListView.builder(
                itemCount: _suggestedSkills.length,
                itemBuilder: (context, index) {
                  final skillName = _suggestedSkills[index];
                  if (_searchController.text.isNotEmpty &&
                      !skillName.toLowerCase().contains(_searchController.text.toLowerCase())) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text(skillName),
                    onTap: () => _addSkill(skillName),
                  );
                },
              ),
            ),

            // Bouton Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSkills,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}