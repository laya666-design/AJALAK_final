import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Version finale - Rouge only
/// 1. JSON pur force via responseMimeType: application/json
/// 2. Securite produit: Gemini ne doit JAMAIS inventer de magasins/tels

class GeminiService {
  final String apiKey;
  GeminiService({String? apiKey}) 
      : apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  GenerativeModel _getJsonModel() {
    return GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey.isEmpty ? 'dummy' : apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
      // Consigne systeme globale
      systemInstruction: Content.system(
        'Tu es un expert pieces auto et assurance pour l Algerie. '
        'REGLE CRITIQUE: Tu ne dois JAMAIS inventer de nom de magasin, adresse ou numero de telephone. '
        'Si on te demande des magasins, reponds toujours avec "magasins": []. '
        'La liste des vrais magasins est geree localement dans l app, pas par toi. '
        'Reponds toujours en JSON pur, sans markdown, sans ```json.'
      ),
    );
  }

  // 1. Assurance - JSON garanti
  Future<Map<String, dynamic>> analyzeInsuranceCard(File file) async {
    if (apiKey.isEmpty) return {'error': 'CLE MANQUANTE', 'text': 'Ajoute GEMINI_API_KEY en secret GitHub'};

    try {
      final bytes = await file.readAsBytes();
      final model = _getJsonModel();

      final prompt = '''
Analyse cette image de carte jaune assurance auto algerienne.
Retourne UNIQUEMENT ce JSON (aucun texte avant/apres):

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

      final res = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)])
      ]);

      final raw = res.text ?? '{}';
      // Parsing securise grace au responseMimeType
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        // Force securite produit: on ecrase si Gemini a quand meme invente
        json['magasins'] = [];
        return json;
      } catch (_) {
        // Si Gemini a quand meme mis du markdown malgre le mimeType
        final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned) as Map<String, dynamic>;
        json['magasins'] = [];
        return json;
      }
    } catch (e) {
      return {'error': e.toString(), 'magasins': []};
    }
  }

  // 2. Piece auto - JSON garanti + pas d invention de magasins
  Future<Map<String, dynamic>> analyzeCarPart(File file) async {
    if (apiKey.isEmpty) return {'error': 'CLE MANQUANTE', 'text': 'Secret manquant'};

    try {
      final bytes = await file.readAsBytes();
      final model = _getJsonModel();

      final prompt = '''
Identifie la piece auto sur la photo pour le marche Algerien (Annaba).
Retourne UNIQUEMENT ce JSON:

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

      final res = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)])
      ]);

      final raw = res.text ?? '{}';
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        json['magasins'] = []; // Securite produit
        return json;
      } catch (_) {
        final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleaned) as Map<String, dynamic>;
        json['magasins'] = [];
        return json;
      }
    } catch (e) {
      return {'error': e.toString(), 'magasins': []};
    }
  }
}
