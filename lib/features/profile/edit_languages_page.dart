import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/profile_models.dart';

class EditLanguagesPage extends StatefulWidget {
  const EditLanguagesPage({super.key});

  @override
  State<EditLanguagesPage> createState() => _EditLanguagesPageState();
}

class _EditLanguagesPageState extends State<EditLanguagesPage> {
  final _searchController = TextEditingController();
  List<Language> _selectedLanguages = [];
  bool _isLoading = false;

  // Simulation de langues suggérées
  final List<String> _suggestedLanguages = [
    'English', 'French', 'German', 'Spanish', 'Mandarin', 'Arabic', 'Italian', 'Japanese', 'Russian'
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguages = List.from(context.read<AuthProvider>().languages);
  }

  // ... (dispose, _addLanguage, _removeLanguage, _saveLanguages, build)

  void _addLanguage(String name) {
    name = name.trim();
    if (name.isNotEmpty && !_selectedLanguages.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      setState(() {
        _selectedLanguages.add(Language(userId: 0, name: name));
      });
      _searchController.clear();
    }
  }

  void _removeLanguage(Language lang) {
    setState(() {
      _selectedLanguages.removeWhere((s) => s.name == lang.name);
    });
  }

  void _saveLanguages() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      final existingLanguages = authProvider.languages;

      final langsToDelete = existingLanguages.where(
              (e) => !_selectedLanguages.any((s) => s.name == e.name)
      ).toList();

      final langsToAdd = _selectedLanguages.where(
              (s) => !existingLanguages.any((e) => e.name == s.name)
      ).toList();

      // Suppression
      for (var lang in langsToDelete) {
        if (lang.id != null) {
          await authProvider.deleteLanguage(lang.id!);
        }
      }

      // Ajout
      for (var lang in langsToAdd) {
        await authProvider.addLanguage(lang.name);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Échec de la sauvegarde des langues')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Structure Scaffold, AppBar, Form, SingleChildScrollView)
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Languages'),
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
                hintText: 'Search languages or type a new one',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onFieldSubmitted: (value) => _addLanguage(value),
              onChanged: (value) { setState(() {}); },
            ),
            const SizedBox(height: 20),

            // Langues sélectionnées
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedLanguages.map((lang) => Chip(
                  label: Text(lang.name, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF8B1C1C),
                  deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onDeleted: () => _removeLanguage(lang),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Suggestions filtrées
            Expanded(
              child: ListView.builder(
                itemCount: _suggestedLanguages.length,
                itemBuilder: (context, index) {
                  final langName = _suggestedLanguages[index];
                  if (_searchController.text.isNotEmpty &&
                      !langName.toLowerCase().contains(_searchController.text.toLowerCase())) {
                    return Container();
                  }
                  return ListTile(
                    title: Text(langName),
                    onTap: () => _addLanguage(langName),
                  );
                },
              ),
            ),

            // Bouton Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLanguages,
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