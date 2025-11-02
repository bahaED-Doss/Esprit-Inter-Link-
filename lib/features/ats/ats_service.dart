import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AtsService {
  final String apiKey;
  final String baseUrl = 'https://api.affinda.com/v3';
  final String workspaceId;

  /// Exemple d'instanciation :
  /// final atsService = AtsService('aff_857f431e2a9e34093d85101e993fd3e7016bdc6d', workspaceId: 'XSTrTbKH');
  AtsService(this.apiKey, {required this.workspaceId});

  /// 📤 Upload du fichier CV vers Affinda
  Future<String> uploadCV(File file) async {
    final allowedExtensions = ['pdf', 'docx'];
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw Exception('Format de fichier non supporté. Veuillez choisir un PDF ou DOCX.');
    }

    final uri = Uri.parse('$baseUrl/documents');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['workflow'] = 'resume'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      );

    if (workspaceId.isNotEmpty) {
      request.fields['workspace'] = workspaceId;
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(respStr);
      // Essayer de trouver l'identifiant dans plusieurs endroits
      String? identifier;
      if (data['identifier'] != null) {
        identifier = data['identifier'];
      } else if (data['meta'] != null && data['meta']['identifier'] != null) {
        identifier = data['meta']['identifier'];
      } else if (data['data'] != null && data['data']['meta'] != null && data['data']['meta']['identifier'] != null) {
        identifier = data['data']['meta']['identifier'];
      }
      if (identifier != null) {
        return identifier;
      } else {
        throw Exception('Réponse API inattendue: identifiant non trouvé.\n${respStr}');
      }
    } else {
      String errorMsg = 'Erreur upload CV: ${response.statusCode}';
      try {
        final data = json.decode(respStr);
        errorMsg += '\n${data['error'] ?? data['detail'] ?? respStr}';
      } catch (_) {
        errorMsg += '\n$respStr';
      }
      throw Exception(errorMsg);
    }
  }

  /// 📥 Récupère les données structurées du CV via l'identifiant
  Future<Map<String, dynamic>> fetchParsedCV(String identifier) async {
    final uri = Uri.parse('$baseUrl/documents/$identifier');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $apiKey',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Erreur récupération CV: ${response.statusCode}');
    }
  }
}
