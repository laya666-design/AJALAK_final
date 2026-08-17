import 'package:hive_flutter/hive_flutter.dart';
import 'vehicule.dart';

/// Stockage 100% local (Hive) — pas de backend, cohérent avec l'OCR qui
/// fonctionne déjà hors-ligne. Un seul véhicule gratuit ; au-delà, il faut
/// être Premium (voir [SettingsService]).
class VehiculeService {
  static const String boxName = 'vehicules';
  static const int freeLimit = 1;

  /// À appeler une seule fois, avant runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VehiculeAdapter());
    }
    await Hive.openBox<Vehicule>(boxName);
  }

  static Box<Vehicule> get _box => Hive.box<Vehicule>(boxName);

  static List<Vehicule> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => a.dateAjout.compareTo(b.dateAjout));
    return list;
  }

  static Vehicule? getById(String id) => _box.get(id);

  static Future<Vehicule> add(Vehicule v) async {
    await _box.put(v.id, v);
    return v;
  }

  static Future<void> update(Vehicule v) async {
    await v.save();
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static bool get canAddFree => _box.length < freeLimit;
}

/// Petit flag Premium local. Mock pour l'instant (Phase 1) : pas de vrai
/// paiement, juste un interrupteur pour débloquer les véhicules 2+.
/// À remplacer par une vraie logique d'achat in-app plus tard.
class SettingsService {
  static const String boxName = 'settings';
  static const String _premiumKey = 'isPremium';

  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  static bool get isPremium =>
      _box.get(_premiumKey, defaultValue: false) as bool;

  static Future<void> setPremium(bool value) async {
    await _box.put(_premiumKey, value);
  }
}
