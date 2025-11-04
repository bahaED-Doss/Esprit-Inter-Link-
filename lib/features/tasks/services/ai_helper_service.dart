
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service d'aide AI pour générer un court guide
/// Utilise l'API Google Generative Language (Gemini)
class AIHelperService {
  final String apiKey;
  final Duration timeout;

  AIHelperService({
    required this.apiKey,
    this.timeout = const Duration(seconds: 15),
  });

  /// Retourne un court paragraphe d'aide pour l'intern
  Future<String?> getQuickHelpForTask(String? title, String? description) async {
    final desc = (description ?? '').trim();
    final ttl = (title ?? '').trim();

    if (ttl.isEmpty && desc.isEmpty) return null;

    // Utiliser les deux si disponibles, sinon juste ce qui est présent
    final prompt = desc.isNotEmpty
        ? 'Provide a brief practical guide (2-3 sentences) for this task:\n\nTitle: $ttl\nDescription: $desc'
        : 'Provide a brief practical guide (2-3 sentences) for this task:\n\nTitle: $ttl';

    final uri = Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models/gemini-2.5-flash:generateContent',
        {'key': apiKey}
    );

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.5,
        'maxOutputTokens': 1000,
        'topP': 0.95,
        'topK': 40,
      },
    };

    try {
      if (kDebugMode) {
        print('[AIHelper] Sending request...');
        print('[AIHelper] Prompt: "$prompt"');
      }

      final resp = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(timeout);

      if (kDebugMode) {
        print('[AIHelper] HTTP ${resp.statusCode}');
        print('[AIHelper] Response: ${resp.body}');
      }

      if (resp.statusCode != 200) {
        if (kDebugMode) print('[AIHelper] Error: ${resp.body}');
        return 'Unable to get AI response. Please try again.';
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;

      // Extraire le texte de la réponse Gemini
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        if (kDebugMode) print('[AIHelper] No candidates in response');
        return 'No response from AI. Please try again.';
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;

      if (content == null) {
        if (kDebugMode) print('[AIHelper] No content in candidate');
        return 'AI response was empty. Please try again.';
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        if (kDebugMode) print('[AIHelper] No parts in content');
        return 'AI response was incomplete. Please try again.';
      }

      final textParts = <String>[];
      for (final part in parts) {
        if (part is Map<String, dynamic> && part['text'] is String) {
          textParts.add(part['text'] as String);
        }
      }

      if (textParts.isEmpty) {
        if (kDebugMode) print('[AIHelper] No text in parts');
        return 'AI could not generate a response. Please try again.';
      }

      final fullText = textParts.join('\n').trim();
      if (kDebugMode) print('[AIHelper] Success! Text length: ${fullText.length}');

      return fullText;

    } on TimeoutException {
      if (kDebugMode) print('[AIHelper] Timeout');
      return 'Request timed out. Please try again.';
    } catch (e) {
      if (kDebugMode) print('[AIHelper] Exception: $e');
      return 'An error occurred. Please try again.';
    }
  }
}