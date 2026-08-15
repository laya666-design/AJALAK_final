import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash', // plus stable que 2.5-lite pour l'instant
  );

  Future<String> analyserPiece(File imageFile) async {
    final prompt = TextPart(
      "Tu es expert pièces auto Algérie. Identifie la pièce sur la photo, donne la référence exacte, véhicules compatibles, et prix estimé en DA."
    );
    final image = InlineDataPart('image/jpeg', await imageFile.readAsBytes());
    final response = await _model.generateContent([Content.multi([prompt, image])]);
    return response.text ?? "Impossible d'analyser";
  }
}
