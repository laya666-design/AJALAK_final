import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Version Cloudflare Worker + Groq
/// La cle API Groq est protegee cote serveur (Worker), jamais exposee dans l app.

class GeminiService {
  static const String _workerUrl =
      'https://tight-smoke-4dfa.laya666.workers.dev';

  Future<String> _callGroq(String prompt, File file) async {
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = {
      "model": "llama-3.2-90b-vision-preview",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
            }
          ]
        }
      ],
      "temperature": 0.2,
    };

    final response = await http.post(
      Uri.parse(_workerUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (data['error'] != null) {
      throw Exception(data['error'].toString());
    }

    final content = data['choices']?[0]?['message']?['content'];
    if (content == null) {
      throw Exception('Reponse vide du serveur');
    }
    return content as String;
  }

  Map<String, dynamic> _parseJson(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json['magasins'] = [];
      return json;
    } catch (_) {
      final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      json['magasins'] = [];
      return json;
    }
  }

  Future<Map<String, dynamic>> analyzeInsuranceCard(File file) async {
    try {
      final prompt = '''
Tu es un expert assurance auto pour l Algerie.
REGLE CRITIQUE: Ne jamais inventer de nom de magasin, adresse ou telephone.
Analyse cette image de carte jaune assurance auto algerienne.
Retourne UNIQUEMENT ce JSON (aucun texte avant/apres, pas de markdown):

{
  "compagnie": "string ou null",
  "nom_assure": "string ou null",
  "marque_vehicule": "string ou null",
  "numero_police": "string ou null",
  "date_expiration": "dd/MM/yyyy ou null",
  "jours_restants": 0,
  "magasins": []
}

REGLE: magasins doit toujours etre un tableau vide [].
''';

      final raw = await _callGroq(prompt, file);
      return _parseJson(raw);
    } catch (e) {
      return {'error': e.toString(), 'magasins': []};
    }
  }

  Future<Map<String, dynamic>> analyzeCarPart(File file) async {
    try {
      final prompt = '''
Tu es un expert pieces auto pour l Algerie (Annaba).
REGLE CRITIQUE: Ne jamais inventer de nom de magasin, adresse ou telephone.
Identifie la piece auto sur la photo pour le marche Algerien.
Retourne UNIQUEMENT ce JSON (aucun texte avant/apres, pas de markdown):

{
  "nom": "nom exact piece",
  "reference": "reference possible ou null",
  "compatibilite": ["Clio 4", "Symbol", "etc"],
  "prix_dzd_min": 0,
  "prix_dzd_max": 0,
  "conseil": "conseil montage court",
  "magasins": []
}

REGLE CRITIQUE: magasins = [] toujours vide. Ne jamais inventer de telephone.
''';

      final raw = await _callGroq(prompt, file);
      return _parseJson(raw);
    } catch (e) {
      return {'error': e.toString(), 'magasins': []};
    }
  }
}
