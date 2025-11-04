import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'ats_service.dart';

class AtsPage extends StatefulWidget {
  const AtsPage({Key? key}) : super(key: key);

  @override
  State<AtsPage> createState() => _AtsPageState();
}

class _AtsPageState extends State<AtsPage> {
  final AtsService atsService = AtsService(
    'aff_857f431e2a9e34093d85101e993fd3e7016bdc6d',
    workspaceId: 'XSTrTbKH',
  );

  bool isLoading = false;
  String? error;
  Map<String, dynamic>? parsedData;

  /// 📂 Sélection et upload du fichier CV
  Future<void> pickAndUploadCV() async {
    setState(() {
      isLoading = true;
      error = null;
      parsedData = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() {
          isLoading = false;
          error = 'Aucun fichier sélectionné.';
        });
        return;
      }

      final file = File(result.files.single.path!);

      // ⬆️ Upload du fichier CV
      final identifier = await atsService.uploadCV(file);

      // 🕒 Affinda prend quelques secondes pour parser
      await Future.delayed(const Duration(seconds: 5));

      // 📥 Récupération des données structurées
      final data = await atsService.fetchParsedCV(identifier);

      setState(() {
        isLoading = false;
        parsedData = data;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  /// 🧾 Affichage des données extraites
  Widget buildParsedData(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Non trouvé';
    final emails = data['emails'] as List<dynamic>? ?? [];
    final phones = data['phoneNumbers'] as List<dynamic>? ?? [];
    final educations = data['education'] as List<dynamic>? ?? [];
    final skills = data['skills'] as List<dynamic>? ?? [];
    final experience = data['workExperience'] as List<dynamic>? ?? [];
    final languages = data['languages'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nom : $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Email : ${emails.isNotEmpty ? emails.first : 'Non trouvé'}'),
              Text('Téléphone : ${phones.isNotEmpty ? phones.first : 'Non trouvé'}'),
              const SizedBox(height: 12),
              Text('Éducation : ${educations.map((e) => e['organization'] ?? '').join(', ')}'),
              Text('Compétences : ${skills.map((s) => s['name'] ?? '').join(', ')}'),
              Text('Expérience : ${experience.map((e) => e['position'] ?? '').join(', ')}'),
              Text('Langues : ${languages.map((l) => l['name'] ?? '').join(', ')}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    parsedData = null;
                    error = null;
                  });
                },
                child: const Text('Essayer un autre CV'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyseur de CV (Affinda)')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : parsedData != null
            ? buildParsedData(parsedData!)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Uploader un CV (PDF ou DOCX)'),
              onPressed: pickAndUploadCV,
            ),
          ],
        ),
      ),
    );
  }
}
