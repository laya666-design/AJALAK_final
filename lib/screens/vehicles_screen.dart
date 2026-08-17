import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/ocr_service.dart';
import '../services/vehicule.dart';
import '../services/vehicule_service.dart';
import 'controle_technique_screen.dart';
import 'insurance_screen.dart';

class VehiclesScreen extends StatefulWidget {
  final AppConfig config;

  /// Catégories affichées dans cette rubrique. ex: [TypeVehicule.voiture]
  /// pour la rubrique "Véhicules", ou [TypeVehicule.moto,
  /// TypeVehicule.scooter] pour la rubrique "Motos & scooters".
  final List<String> types;

  final String titre;
  final String sousTitre;
  final IconData iconePrincipale;
  final String labelAjout;
  final String labelVide;

  const VehiclesScreen({
    super.key,
    required this.config,
    this.types = const [TypeVehicule.voiture],
    this.titre = 'Mes véhicules',
    this.sousTitre =
        'Assurance, vignette et contrôle technique, par véhicule.',
    this.iconePrincipale = Icons.directions_car,
    this.labelAjout = 'Ajouter un véhicule',
    this.labelVide = 'Aucun véhicule pour le moment',
  });

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
    setState(() => _vehicules = VehiculeService.getByTypes(widget.types));
  }

  IconData _iconForType(String type) {
    switch (type) {
      case TypeVehicule.moto:
        return Icons.two_wheeler;
      case TypeVehicule.scooter:
        return Icons.moped;
      default:
        return Icons.directions_car;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case TypeVehicule.moto:
        return 'Moto';
      case TypeVehicule.scooter:
        return 'Scooter';
      default:
        return 'Voiture';
    }
  }

  Future<void> _openAddDialog() async {
    final isPremium = SettingsService.isPremium;
    final canAddFree = VehiculeService.canAddFreeForTypes(widget.types);

    if (!isPremium && !canAddFree) {
      _showPremiumSheet();
      return;
    }

    final nomController = TextEditingController();
    final marqueController = TextEditingController();
    String selectedType = widget.types.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(widget.labelAjout),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélecteur de catégorie : uniquement si la rubrique regroupe
              // plusieurs types (ex: Motos & scooters).
              if (widget.types.length > 1) ...[
                SegmentedButton<String>(
                  segments: widget.types
                      .map((t) => ButtonSegment<String>(
                            value: t,
                            label: Text(_labelForType(t)),
                            icon: Icon(_iconForType(t)),
                          ))
                      .toList(),
                  selected: {selectedType},
                  onSelectionChanged: (s) =>
                      setDialogState(() => selectedType = s.first),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: widget.types.contains(TypeVehicule.voiture)
                      ? 'ex: Peugeot 208'
                      : 'ex: Yamaha 125',
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
      type: selectedType,
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
              'La version gratuite permet de gérer 1 élément dans cette '
              'rubrique. Passe en Premium pour en ajouter sans limite.',
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
        builder: (_) => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: widget.config.primaryColor,
              foregroundColor: Colors.white,
              title: Text(v.nom),
              bottom: const TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(icon: Icon(Icons.security), text: 'Assurance'),
                  Tab(icon: Icon(Icons.fact_check), text: 'Contrôle technique'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                InsuranceScreen(config: widget.config, vehicule: v),
                ControleTechniqueScreen(config: widget.config, vehicule: v),
              ],
            ),
          ),
        ),
      ),
    );
    _refresh();
  }

  Widget _statusChip(DateTime? expiration, String labelVide) {
    if (expiration == null) {
      return Chip(
        label: Text(labelVide, style: const TextStyle(fontSize: 11)),
        visualDensity: VisualDensity.compact,
      );
    }
    final status = ExpiryStatus(expirationDate: expiration);
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
    final showLockedCard = !isPremium &&
        _vehicules.length >= VehiculeService.freeLimit;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.titre, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(widget.sousTitre, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            if (_vehicules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(widget.iconePrincipale,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(widget.labelVide,
                          style: const TextStyle(color: Colors.black54)),
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
                      child: Icon(_iconForType(v.type)),
                    ),
                    title: Text(v.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (widget.types.length > 1)
                            Chip(
                              label: Text(_labelForType(v.type),
                                  style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  widget.config.primaryColor.withOpacity(0.08),
                            ),
                          _statusChip(v.assuranceExpiration, 'Assurance non renseignée'),
                          _statusChip(v.controleTechniqueExpiration, 'CT non renseigné'),
                        ],
                      ),
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
                  title: const Text('Élément suivant',
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
                  label: Text(widget.labelAjout),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
