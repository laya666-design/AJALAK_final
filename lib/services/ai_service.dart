import 'package:google_generative_ai/google_generative_ai.dart';

/// Service IA stable pour Ajalaks - ne fait jamais planter l'app
/// 1. Va sur aistudio.google.com/app/apikey pour créer ta clé gratuite
/// 2. Colle ta clé ci-dessous
class AiService {
  // COLLE TA CLE ICI - elle commence par AIzaSy...
  static const String _apiKey = "AQ.Ab8RN6L6e6x4ICtPAMpB_TjdHmPZ6-sPXrl85VAVU8q5k8E7VQ";

  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Méthode principale anti-plantage
  Future<String> demander(String question) async {
    // Si la clé n'est pas encore mise
    if (_apiKey.contains("TA_CLE_ICI") || _apiKey.isEmpty) {
      return "⚠️ Ajoute ta clé Gemini dans lib/services/ai_service.dart";
    }

    try {
      final prompt = [Content.text(question)];
      final response = await _model.generateContent(prompt);
      
      final text = response.text;
      if (text == null || text.isEmpty) {
        return "Pas de réponse, réessaie.";
      }
      return text;
      
    } catch (e) {
      // Ici ton app ne plante PAS, elle affiche juste l'erreur
      print("Erreur IA Ajalaks: $e");
      
      if (e.toString().contains("API_KEY")) {
        return "Clé API invalide. Vérifie ta clé dans ai_service.dart";
      }
      if (e.toString().contains("429") || e.toString().contains("quota")) {
        return "Trop de demandes, attends 1 minute.";
      }
      if (e.toString().contains("network") || e.toString().contains("Socket")) {
        return "Pas de connexion internet.";
      }
      
      return "L'IA est occupée. Erreur: ${e.toString().substring(0, 100)}";
    }
  }

  /// Pour le chat avec historique
  Future<String> chatAvecHistorique(List<String> historique, String nouvelleQuestion) async {
    try {
      final history = <Content>[];
      for (int i = 0; i < historique.length; i++) {
        if (i % 2 == 0) {
          history.add(Content.text(historique[i])); // user
        } else {
          history.add(Content.model([TextPart(historique[i])])); // model
        }
      }

      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(nouvelleQuestion));
      return response.text ?? "Pas de réponse";
    } catch (e) {
      return await demander(nouvelleQuestion);
    }
  }
}
