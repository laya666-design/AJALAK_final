import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../services/marketplace_models.dart';
import '../../services/store_service.dart';

/// Espace abonnement du magasin : statut de l'essai/abonnement en cours,
/// et envoi d'une preuve de paiement (virement / CCP / Baridimob) pour
/// activer ou renouveler l'accès aux demandes de pièces.
class SubscriptionScreen extends StatefulWidget {
  final AppConfig config;
  final StoreProfile profile;
  const SubscriptionScreen(
      {super.key, required this.config, required this.profile});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  File? _recu;
  String _methode = 'Baridimob';
  bool _sending = false;

  Future<void> _choisirRecu() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    setState(() => _recu = File(img.path));
  }

  Future<void> _envoyer() async {
    if (_recu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute une photo du reçu.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await StoreService.submitPaymentProof(
        recu: _recu!,
        montant: kAbonnementPrixMensuelDA,
        methode: _methode,
      );
      if (!mounted) return;
      setState(() => _recu = null);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Preuve envoyée'),
          content: const Text(
            'Ton paiement est en cours de vérification. Ton abonnement '
            'sera activé dès validation (généralement sous 24h).',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _statutCard() {
    final p = widget.profile;
    late final String titre;
    late final String sousTitre;
    late final Color couleur;
    late final IconData icone;

    switch (p.subscriptionStatus) {
      case SubscriptionStatus.essai:
        final j = p.joursRestants;
        titre = j > 0 ? 'Essai gratuit — $j jour(s) restant(s)' : 'Essai terminé';
        sousTitre = j > 0
            ? 'Profite de l\'essai gratuit, aucun paiement requis.'
            : 'Ton essai gratuit est terminé. Abonne-toi pour continuer '
                'à recevoir des demandes.';
        couleur = j > 0 ? Colors.green : Colors.red;
        icone = j > 0 ? Icons.card_giftcard : Icons.lock_clock;
        break;
      case SubscriptionStatus.actif:
        final j = p.joursRestants;
        titre = j > 0
            ? 'Abonnement actif — $j jour(s) restant(s)'
            : 'Abonnement expiré';
        sousTitre = j > 0
            ? 'Merci ! Tu reçois toutes les demandes de pièces.'
            : 'Ton abonnement est terminé. Renouvelle pour continuer.';
        couleur = j > 0 ? Colors.green : Colors.red;
        icone = j > 0 ? Icons.verified : Icons.lock_clock;
        break;
      case SubscriptionStatus.enAttente:
        titre = 'Paiement en cours de vérification';
        sousTitre = 'On valide généralement sous 24h. Reviens un peu plus '
            'tard.';
        couleur = Colors.orange;
        icone = Icons.hourglass_top;
        break;
      default:
        titre = 'Abonnement expiré';
        sousTitre = 'Abonne-toi pour recevoir les demandes de pièces.';
        couleur = Colors.red;
        icone = Icons.lock_clock;
    }

    return Card(
      color: couleur.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icone, color: couleur, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: couleur)),
                  const SizedBox(height: 4),
                  Text(sousTitre, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final peutPayer = p.subscriptionStatus != SubscriptionStatus.enAttente;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.config.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Mon abonnement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _statutCard(),
            if (peutPayer) ...[
              const SizedBox(height: 20),
              Text('Renouveler / activer l\'abonnement',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '$kAbonnementPrixMensuelDA DA / mois — paiement par '
                'virement, CCP ou Baridimob, puis envoie la photo du reçu '
                'ci-dessous.',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _methode,
                decoration: const InputDecoration(
                  labelText: 'Méthode de paiement',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Baridimob', child: Text('Baridimob')),
                  DropdownMenuItem(value: 'CCP', child: Text('CCP')),
                  DropdownMenuItem(value: 'Virement', child: Text('Virement bancaire')),
                ],
                onChanged: (v) => setState(() => _methode = v ?? 'Baridimob'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _choisirRecu,
                icon: const Icon(Icons.photo_camera),
                label: Text(_recu == null
                    ? 'Ajouter la photo du reçu'
                    : 'Reçu sélectionné ✓'),
              ),
              if (_recu != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_recu!, height: 160, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _sending ? null : _envoyer,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: widget.config.primaryColor,
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Envoyer la preuve de paiement'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
