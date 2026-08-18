import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/marketplace_models.dart';
import '../../services/store_service.dart';
import 'store_login_screen.dart';
import 'subscription_screen.dart';

class StoreDashboardScreen extends StatefulWidget {
  final AppConfig config;
  const StoreDashboardScreen({super.key, required this.config});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  StoreProfile? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await StoreService.myProfile();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loadingProfile = false;
    });
  }

  Future<void> _logout() async {
    await StoreService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StoreLoginScreen(config: widget.config),
      ),
    );
  }

  Future<void> _repondre(PartRequest r) async {
    final prixController = TextEditingController();
    final stockController = TextEditingController();
    final messageController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Répondre — ${r.pieceNom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix (DA)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                  labelText: 'Disponibilité (ex: En stock)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration:
                  const InputDecoration(labelText: 'Message (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final prix = num.tryParse(prixController.text.trim());
    if (prix == null) return;

    await StoreService.respondToRequest(
      requestId: r.id,
      prix: prix,
      stock: stockController.text.trim(),
      message: messageController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réponse envoyée au client.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.config.primaryColor,
        foregroundColor: Colors.white,
        title: Text(profile?.nom.isNotEmpty == true
            ? profile!.nom
            : 'Espace Pro'),
        actions: [
          if (profile != null && profile.actif)
            IconButton(
              tooltip: 'Mon abonnement',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionScreen(
                        config: widget.config, profile: profile),
                  ),
                );
                _loadProfile();
              },
              icon: const Icon(Icons.workspace_premium_outlined),
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Profil introuvable.'))
          : !profile.actif
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Ton compte est en attente de validation.\n'
                      'Tu recevras les demandes une fois activé.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : !profile.accesDemandesAutorise
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_clock,
                                size: 48, color: widget.config.primaryColor),
                            const SizedBox(height: 16),
                            Text(
                              profile.subscriptionStatus ==
                                      SubscriptionStatus.enAttente
                                  ? 'Ton paiement est en cours de vérification.'
                                  : 'Ton essai gratuit ou ton abonnement est '
                                      'terminé.\nAbonne-toi pour continuer à '
                                      'recevoir des demandes.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            if (profile.subscriptionStatus !=
                                SubscriptionStatus.enAttente)
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor:
                                        widget.config.primaryColor),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubscriptionScreen(
                                          config: widget.config,
                                          profile: profile),
                                    ),
                                  );
                                  _loadProfile();
                                },
                                child: const Text('Voir mon abonnement'),
                              ),
                          ],
                        ),
                      ),
                    )
                  : StreamBuilder<List<PartRequest>>(
                  stream: StoreService.openRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final requests = snapshot.data ?? [];
                    if (requests.isEmpty) {
                      return const Center(
                        child: Text('Aucune demande ouverte pour le moment.'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: requests.length,
                      itemBuilder: (context, i) {
                        final r = requests[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: r.photoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(r.photoUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.build),
                            title: Text(r.pieceNom.isEmpty
                                ? 'Pièce non nommée'
                                : r.pieceNom),
                            subtitle: Text(
                              r.reference.isNotEmpty
                                  ? 'Réf: ${r.reference}'
                                  : (r.compatibilite.isNotEmpty
                                      ? r.compatibilite.join(', ')
                                      : ''),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: FilledButton(
                              onPressed: () => _repondre(r),
                              child: const Text('Répondre'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
