import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/gemini_service.dart';
import '../services/models.dart';

class PartsScreen extends StatefulWidget {
  final AppConfig config;
  const PartsScreen({super.key, required this.config});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final _picker = ImagePicker();
  final _gemini = GeminiService();

  File? _image;
  bool _loading = false;
  String? _error;
  CarPartInfo? _part;

  Future<void> _pickImage(ImageSource source) async {
  

  Future<void> _call(String tel) async {
    if (tel.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: tel);
    await launchUrl(uri);
  }

  Future<void> _whatsapp(String tel) async {
    if (tel.isEmpty) return;
    final cleaned = tel.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/213$cleaned');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _itineraire(String nomMagasin) async {
    final query = Uri.encodeComponent('$nomMagasin El Bouni Annaba');
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final part = _part;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pièces détachées',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text(
              'Photographie la pièce cassée pour trouver référence et prix.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _loading ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Caméra Pièce'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: widget.config.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loading ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: Color(0xFF991B1B))),
              ),
            if (part != null) ...[
              // Nom + référence + état
              Row(
                children: [
                  Expanded(
                    child: Text(
                      part.nom.isEmpty ? 'Pièce non identifiée' : part.nom,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (part.etat.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        part.etat,
                        style: const TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                ],
              ),
              if (part.reference.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Réf: ${part.reference}',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.black54),
                ),
              ],
              if (part.compatibilite.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Compatibilité',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...part.compatibilite.map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(c)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Carte prix
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prix El Bouni',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          Text(
                            '${part.prixDa} DA',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ),
                    if (part.prixOrigine > 0) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${part.prixOrigine} DA',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            'Économie: ${part.prixOrigine - part.prixDa} DA',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (part.magasins.isNotEmpty) ...[
                const Text('Magasins',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ...part.magasins.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(m.nom,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                              Text('${m.prix} DA',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (m.stock.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(m.stock,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (m.tel.isNotEmpty) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _call(m.tel),
                                    icon: const Icon(Icons.call, size: 16),
                                    label: const Text('Appeler'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _whatsapp(m.tel),
                                    icon: const Icon(Icons.message, size: 16),
                                    label: const Text('WhatsApp'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _itineraire(m.nom),
                                  icon: const Icon(Icons.directions, size: 16),
                                  label: const Text('Itinéraire'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
              if (part.conseils.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('💡 ${part.conseils}',
                      style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Commande enregistrée.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Commander'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
