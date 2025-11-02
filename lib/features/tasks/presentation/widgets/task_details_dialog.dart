import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import '../../models/task_model.dart';
import '../../services/ai_helper_service.dart';

/// Dialogue d'affichage des détails d'une tâche.
/// Inclut un panneau "AI Quick Help" qui utilise `AIHelperService`.
class TaskDetailsDialog {
  static Future<void> show(BuildContext context, Task task, {bool showAI = true}) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Task details',
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: curved.value,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, (1 - curved.value) * 40),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(ctx).size.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 20, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: _DetailsContent(task: task, showAI: showAI),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Ouvre la feuille bottom sheet pour l'aide AI
  static Future<void> _openAIHelpBottomSheet(BuildContext context, String? title, String? description) async {
    if (kDebugMode) {
      print('[TaskDetailsDialog] Opening AI help for: $title');
    }

    // Récupérer la clé API
    final apiKey = await _getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      _showNoApiKeyDialog(context);
      return;
    }

    if (kDebugMode) {
      print('[TaskDetailsDialog] API key found (length: ${apiKey.length})');
    }

    final service = AIHelperService(apiKey: apiKey);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (sheetCtx, controller) {
            return Column(
              children: [
                // Header with drag handle
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B1C1C),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'AI Quick Help',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content area
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: FutureBuilder<String?>(
                      future: service.getQuickHelpForTask(title, description),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF8B1C1C),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Analyzing your task...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          if (kDebugMode) {
                            print('[TaskDetailsDialog] Error: ${snapshot.error}');
                          }
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Oops! Something went wrong',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final text = snapshot.data;
                        if (text == null || text.trim().isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No response received',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please try again',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          controller: controller,
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B1C1C).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.tips_and_updates,
                                        color: Color(0xFF8B1C1C),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Suggestion',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.grey[800],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Récupère la clé API depuis dotenv ou fichier .env
  static Future<String?> _getApiKey() async {
    // Essayer dotenv d'abord
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['GEMINI_API_KEY'];
        if (key != null && key.isNotEmpty) {
          return key.trim();
        }
      }
    } catch (e) {
      if (kDebugMode) print('[TaskDetailsDialog] dotenv error: $e');
    }

    // Essayer de charger dotenv
    try {
      await dotenv.load(fileName: '.env');
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key != null && key.isNotEmpty) {
        return key.trim();
      }
    } catch (e) {
      if (kDebugMode) print('[TaskDetailsDialog] Could not load .env: $e');
    }

    // Lire manuellement le fichier .env
    final envPaths = [
      '.env',
      '../.env',
      '../../.env',
    ];

    for (final path in envPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final lines = await file.readAsLines();
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('GEMINI_API_KEY=')) {
              var key = trimmed.substring('GEMINI_API_KEY='.length).trim();
              // Enlever les guillemets si présents
              if ((key.startsWith('"') && key.endsWith('"')) ||
                  (key.startsWith("'") && key.endsWith("'"))) {
                key = key.substring(1, key.length - 1);
              }
              if (key.isNotEmpty) {
                if (kDebugMode) print('[TaskDetailsDialog] Found key in $path');
                return key;
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('[TaskDetailsDialog] Error reading $path: $e');
      }
    }

    return null;
  }

  /// Affiche un dialogue indiquant que la clé API n'est pas configurée
  static void _showNoApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Not Configured'),
        content: const Text(
          'Please add GEMINI_API_KEY to your .env file at the project root.\n\n'
              'Example:\nGEMINI_API_KEY=your_key_here',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final Task task;
  final bool showAI;
  const _DetailsContent({required this.task, required this.showAI});

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final labelStyle = TextStyle(color: Colors.grey[600]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: titleStyle),
                  const SizedBox(height: 8),
                  if ((task.description ?? '').isNotEmpty)
                    Text(task.description!, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            if (showAI)
              IconButton(
                tooltip: 'Ask AI',
                onPressed: () {
                  if (kDebugMode) print('[TaskDetailsDialog] Ask AI pressed');
                  TaskDetailsDialog._openAIHelpBottomSheet(
                    context,
                    task.title,
                    task.description,
                  );
                },
                icon: const Icon(Icons.lightbulb_outline, color: Color(0xFF8B1C1C)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: [
            Chip(label: Text('Status: ${task.status.name}')),
            Chip(label: Text('Priority: ${task.priority.name}')),
            if (task.sprintNumber != null) Chip(label: Text('Sprint ${task.sprintNumber}')),
            Chip(label: Text(task.deadline != null ? 'Deadline: ${task.deadline!.toLocal().toString().split(' ')[0]}' : 'No deadline')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Project #${task.projectId}', style: labelStyle),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ],
    );
  }
}