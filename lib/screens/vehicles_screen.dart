import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/ocr_service.dart';
import '../services/vehicule.dart';
import '../services/vehicule_service.dart';
import 'insurance_screen.dart';

class VehiclesScreen extends StatefulWidget {
  final AppConfig config;
  const VehiclesScreen({super.key, required this.config});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicule> _vehicules = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _vehicules = VehiculeService.getAll());
  }

  Future<void> _openAddDialog() async {
    final isPremium = SettingsService.isPremium;
    final canAddFree = VehiculeService.canAddFree;

    if (!isPremium && !canAddFree) {
      _showPremiumSheet();
      return;
    }

    final nomController = TextEditingController();
    final marqueController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un véhicule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du véhicule',
                  hintText: 'ex: Peugeot 208',
                ),
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: marqueController,
                decoration: const InputDecoration(
                  labelText: 'Marque / modèle (optionnel)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: nomController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || nomController.text.trim().isEmpty) return;

    final v = Vehicule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nomController.text.trim(),
      marque: marqueController.text.trim(),
    );
    await VehiculeService.add(v);
    _refresh();
  }

  void _showPremiumSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium,
                    color: widget.config.primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text('Passe en Premium',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'La version gratuite permet de gérer 1 véhicule. '
              'Passe en Premium pour ajouter des véhicules illimités.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: widget.config.primaryColor,
                ),
                onPressed: () {
                  // Mock Phase 1 : pas de vrai paiement, juste le flag local.
                  // À remplacer par une vraie logique d'achat in-app.
                  Navigator.pop(ctx);
                },
                child: const Text('Bientôt disponible'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVehicle(Vehicule v) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: widget.config.primaryColor,
            foregroundColor: Colors.white,
            title: Text(v.nom),
          ),
          body: InsuranceScreen(config: widget.config, vehicule: v),
        ),
      ),
    );
    _refresh();
  }

  Widget _statusChip(Vehicule v) {
    if (v.assuranceExpiration == null) {
      return const Chip(
        label: Text('Assurance non renseignée', style: TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact,
      );
    }
    final status = ExpiryStatus(expirationDate: v.assuranceExpiration!);
    Color bg;
    Color fg;
    switch (status.level) {
      case StatusLevel.ok:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case StatusLevel.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case StatusLevel.expired:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isExpired
            ? 'Expiré depuis ${status.daysRemaining.abs()}j'
            : '${status.daysRemaining}j restants',
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = SettingsService.isPremium;
    final showLockedCard = !isPremium && _vehicules.length >= VehiculeService.freeLimit;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Mes véhicules', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text(
              'Assurance, vignette et bientôt le contrôle technique, par véhicule.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (_vehicules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('Aucun véhicule pour le moment',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ..._vehicules.map((v) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: widget.config.primaryColor.withOpacity(0.1),
                      foregroundColor: widget.config.primaryColor,
                      child: const Icon(Icons.directions_car),
                    ),
                    title: Text(v.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _statusChip(v),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openVehicle(v),
                  ),
                )),
            if (showLockedCard)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey.shade100,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.lock_outline, color: Colors.black45),
                  title: const Text('2e véhicule et plus',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Réservé aux comptes Premium'),
                  trailing: Chip(
                    label: const Text('Premium', style: TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: widget.config.primaryColor,
                  ),
                  onTap: _showPremiumSheet,
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un véhicule'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
