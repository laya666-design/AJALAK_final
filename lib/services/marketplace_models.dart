import 'package:cloud_firestore/cloud_firestore.dart';

/// Une demande de pièce diffusée aux magasins (Phase 4).
class PartRequest {
  final String id;
  final String clientId; // identifiant anonyme du demandeur (device/uid)
  final String pieceNom;
  final String reference;
  final List<String> compatibilite;
  final String photoUrl;
  final String statut; // 'open' | 'closed'
  final DateTime dateCreation;

  PartRequest({
    required this.id,
    required this.clientId,
    required this.pieceNom,
    required this.reference,
    required this.compatibilite,
    required this.photoUrl,
    required this.statut,
    required this.dateCreation,
  });

  factory PartRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PartRequest(
      id: doc.id,
      clientId: d['clientId']?.toString() ?? '',
      pieceNom: d['pieceNom']?.toString() ?? '',
      reference: d['reference']?.toString() ?? '',
      compatibilite: (d['compatibilite'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photoUrl: d['photoUrl']?.toString() ?? '',
      statut: d['statut']?.toString() ?? 'open',
      dateCreation: (d['dateCreation'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'pieceNom': pieceNom,
        'reference': reference,
        'compatibilite': compatibilite,
        'photoUrl': photoUrl,
        'statut': statut,
        'dateCreation': FieldValue.serverTimestamp(),
      };
}

/// La réponse d'un magasin à une demande (sous-collection de PartRequest).
class PartOffer {
  final String id;
  final String storeId;
  final String storeNom;
  final String storeTel;
  final num prix;
  final String stock; // ex: "En stock", "2-3 jours"
  final String message;
  final DateTime dateReponse;

  PartOffer({
    required this.id,
    required this.storeId,
    required this.storeNom,
    required this.storeTel,
    required this.prix,
    required this.stock,
    required this.message,
    required this.dateReponse,
  });

  factory PartOffer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PartOffer(
      id: doc.id,
      storeId: d['storeId']?.toString() ?? '',
      storeNom: d['storeNom']?.toString() ?? '',
      storeTel: d['storeTel']?.toString() ?? '',
      prix: (d['prix'] is num) ? d['prix'] as num : 0,
      stock: d['stock']?.toString() ?? '',
      message: d['message']?.toString() ?? '',
      dateReponse:
          (d['dateReponse'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'storeId': storeId,
        'storeNom': storeNom,
        'storeTel': storeTel,
        'prix': prix,
        'stock': stock,
        'message': message,
        'dateReponse': FieldValue.serverTimestamp(),
      };
}

/// Profil d'un magasin abonné (compte Pro).
class StoreProfile {
  final String uid;
  final String nom;
  final String tel;
  final String adresse;
  final bool actif; // validé manuellement avant de recevoir des demandes
  final String? fcmToken;

  StoreProfile({
    required this.uid,
    required this.nom,
    required this.tel,
    required this.adresse,
    required this.actif,
    this.fcmToken,
  });

  factory StoreProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StoreProfile(
      uid: doc.id,
      nom: d['nom']?.toString() ?? '',
      tel: d['tel']?.toString() ?? '',
      adresse: d['adresse']?.toString() ?? '',
      actif: d['actif'] as bool? ?? false,
      fcmToken: d['fcmToken']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'tel': tel,
        'adresse': adresse,
        'actif': actif,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}
