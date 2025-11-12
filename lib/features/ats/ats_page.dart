import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ats_service.dart';

class AtsPage extends StatefulWidget {
  const AtsPage({Key? key}) : super(key: key);

  @override
  State<AtsPage> createState() => _AtsPageState();
}

class _AtsPageState extends State<AtsPage> {
  late final GeminiAtsService atsService;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cvTextController = TextEditingController();

  bool isLoading = false;
  String? error;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    String apiKey = '';
    try {
      if (dotenv.isInitialized) {
        apiKey = dotenv.env['GEMINI_API_KEY2'] ?? '';
      }
    } catch (e) {
      print('Error accessing GEMINI_API_KEY2: $e');
    }

    if (apiKey.isEmpty) {
      print('Warning: GEMINI_API_KEY2 is empty or not found in .env file');
    }

    atsService = GeminiAtsService(apiKey);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    cvTextController.dispose();
    super.dispose();
  }

  Future<void> analyzeCV() async {
    if (cvTextController.text.trim().isEmpty) {
      setState(() {
        error = 'Veuillez coller le contenu de votre CV.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
      result = null;
    });

    try {
      final analysis = await atsService.analyzeCVText(
        cvTextController.text.trim(),
        internshipDescription: descriptionController.text.trim(),
      );

      setState(() {
        isLoading = false;
        result = analysis;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  Widget buildResult(Map<String, dynamic> data) {
    final score = data['score']?.toString() ?? 'N/A';
    final suggestions =
        (data['suggestions'] as List<dynamic>?)?.cast<String>() ?? [];
    final highlights =
        (data['highlights'] as List<dynamic>?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 3,
            child: ListTile(
              title: const Text('Score CV',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$score / 10',
                  style: const TextStyle(fontSize: 24, color: Colors.black)),
            ),
          ),
          const SizedBox(height: 12),
          if (highlights.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Points forts',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...highlights.map((h) => Text('• $h')),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Suggestions d\'amélioration',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (suggestions.isEmpty)
                    const Text('Aucune suggestion fournie.'),
                  ...suggestions.map((s) => Text('• $s')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                result = null;
                error = null;
                cvTextController.clear();
                descriptionController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1C1C),
            ),
            child: const Text('Analyser un autre CV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFF8B1C1C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: redColor,
        elevation: 6,
        shadowColor: redColor.withOpacity(0.6),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Analyseur de CV (LLM)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: redColor.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : result != null
              ? SingleChildScrollView(child: buildResult(result!))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Collez le contenu de votre CV ci-dessous:',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cvTextController,
                  decoration: InputDecoration(
                    hintText: 'Collez ici le texte de votre CV...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 10,
                  minLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description du stage recherché (optionnel):',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText:
                    'Décrivez le stage que vous recherchez...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyser mon CV'),
                  onPressed: analyzeCV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                    shadowColor: redColor.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}