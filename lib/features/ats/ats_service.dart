import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiAtsService {
  final String apiKey;
  final Duration timeout;

  GeminiAtsService(this.apiKey, {this.timeout = const Duration(seconds: 20)});

  /// Analyse le CV à partir du texte fourni et prend en option une description d'internship.
  Future<Map<String, dynamic>> analyzeCVText(String cvText, {String? internshipDescription}) async {
    if (cvText.trim().isEmpty) {
      throw Exception('Le texte du CV est vide.');
    }

    final descPart = (internshipDescription != null && internshipDescription.trim().isNotEmpty)
        ? ' for this internship: "${internshipDescription.trim()}"'
        : '';

    final prompt =
        'I\'m a student searching for an internship$descPart. Please analyze my CV and help me enhance it.\n\n'
        'Provide your response ONLY as a valid JSON object with these exact keys:\n'
        '- "score": a number between 0 and 10\n'
        '- "highlights": an array of 3-4 short strings describing the CV\'s strengths\n'
        '- "suggestions": an array of exactly 5 short, actionable suggestions to improve the CV\n\n'
        'CV Content:\n${_truncate(cvText, 15000)}\n\n'
        'Return ONLY the JSON object, no other text.';

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
        'temperature': 0.3,
        'maxOutputTokens': 1500,
        'topP': 0.95,
        'topK': 40,
      },
    };

    try {
      if (kDebugMode) {
        print('[GeminiATS] Sending request...');
      }

      final resp = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(timeout);

      if (kDebugMode) {
        print('[GeminiATS] HTTP ${resp.statusCode}');
      }

      if (resp.statusCode != 200) {
        if (kDebugMode) print('[GeminiATS] Error: ${resp.body}');
        throw Exception('Erreur API Gemini: ${resp.statusCode}');
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;

      // Extraire le texte de la réponse Gemini
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Aucune réponse de l\'API Gemini');
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;

      if (content == null) {
        throw Exception('Réponse Gemini vide');
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Réponse Gemini incomplète');
      }

      final textParts = <String>[];
      for (final part in parts) {
        if (part is Map<String, dynamic> && part['text'] is String) {
          textParts.add(part['text'] as String);
        }
      }

      if (textParts.isEmpty) {
        throw Exception('Pas de texte dans la réponse Gemini');
      }

      final fullText = textParts.join('\n').trim();

      if (kDebugMode) {
        print('[GeminiATS] Response text: $fullText');
      }

      final extractedJson = _extractJsonFromText(fullText);
      if (extractedJson == null) {
        throw Exception('Réponse Gemini non parsable en JSON');
      }

      // Normaliser le format
      final normalized = Map<String, dynamic>.from(extractedJson);

      // S'assurer que le score est un nombre
      if (normalized['score'] is String) {
        normalized['score'] = double.tryParse(normalized['score']) ?? 0;
      }

      // Limiter les suggestions à 5
      if (normalized['suggestions'] is List) {
        normalized['suggestions'] = (normalized['suggestions'] as List)
            .map((e) => e.toString())
            .take(5)
            .toList();
      }

      // S'assurer que highlights existe
      if (normalized['highlights'] is List) {
        normalized['highlights'] = (normalized['highlights'] as List)
            .map((e) => e.toString())
            .toList();
      } else {
        normalized['highlights'] = [];
      }

      return normalized;

    } on TimeoutException {
      if (kDebugMode) print('[GeminiATS] Timeout');
      throw Exception('La requête a expiré. Veuillez réessayer.');
    } catch (e) {
      if (kDebugMode) print('[GeminiATS] Exception: $e');
      rethrow;
    }
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return s.substring(0, max);
  }

  Map<String, dynamic>? _extractJsonFromText(String text) {
    // Chercher un objet JSON dans le texte
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');

    if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) return null;

    final candidate = text.substring(jsonStart, jsonEnd + 1);
    try {
      final decoded = json.decode(candidate);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}