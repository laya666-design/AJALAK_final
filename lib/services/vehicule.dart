import 'package:hive/hive.dart';

/// Un véhicule géré dans l'app : regroupe assurance/vignette (une seule
/// carte jaune couvre les deux en Algérie) et, à terme, le contrôle
/// technique (Phase 2).
class Vehicule extends HiveObject {
  String id;
  String nom; // ex: "Peugeot 208" ou "Voiture de Sarah"
  String marque;
  String immatriculation;

  // --- Assurance / Vignette (Phase 1) ---
  DateTime? assuranceExpiration;
  String assuranceCompagnie;
  String assuranceNumeroPolice;
  String assuranceNomAssure;

  // --- Contrôle technique (Phase 2 — champ prêt, pas encore utilisé) ---
  DateTime? controleTechniqueExpiration;

  final DateTime dateAjout;

  Vehicule({
    required this.id,
    required this.nom,
    this.marque = '',
    this.immatriculation = '',
    this.assuranceExpiration,
    this.assuranceCompagnie = '',
    this.assuranceNumeroPolice = '',
    this.assuranceNomAssure = '',
    this.controleTechniqueExpiration,
    DateTime? dateAjout,
  }) : dateAjout = dateAjout ?? DateTime.now();
}

/// Adapter Hive écrit à la main (évite la dépendance à build_runner).
/// typeId = 0, réservé pour Vehicule — ne pas réutiliser pour un autre type.
class VehiculeAdapter extends TypeAdapter<Vehicule> {
  @override
  final int typeId = 0;

  @override
  Vehicule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicule(
      id: fields[0] as String,
      nom: fields[1] as String,
      marque: fields[2] as String? ?? '',
      immatriculation: fields[3] as String? ?? '',
      assuranceExpiration: fields[4] as DateTime?,
      assuranceCompagnie: fields[5] as String? ?? '',
      assuranceNumeroPolice: fields[6] as String? ?? '',
      controleTechniqueExpiration: fields[7] as DateTime?,
      dateAjout: fields[8] as DateTime? ?? DateTime.now(),
      assuranceNomAssure: fields[9] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Vehicule obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.marque)
      ..writeByte(3)
      ..write(obj.immatriculation)
      ..writeByte(4)
      ..write(obj.assuranceExpiration)
      ..writeByte(5)
      ..write(obj.assuranceCompagnie)
      ..writeByte(6)
      ..write(obj.assuranceNumeroPolice)
      ..writeByte(7)
      ..write(obj.controleTechniqueExpiration)
      ..writeByte(8)
      ..write(obj.dateAjout)
      ..writeByte(9)
      ..write(obj.assuranceNomAssure);
  }
}
