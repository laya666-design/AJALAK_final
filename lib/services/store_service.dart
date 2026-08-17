import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'marketplace_models.dart';

/// Marketplace pièces — côté magasin ("Espace Pro").
///
/// Compte email/mot de passe (Firebase Auth). Un magasin créé via
/// [signUp] est enregistré avec `actif: false` : il ne reçoit ni ne voit
/// aucune demande tant qu'il n'a pas été validé manuellement (passage à
/// `actif: true` dans la console Firestore). C'est volontaire pour la
/// Phase 4 — pas de vraie modération automatisée pour l'instant, juste un
/// verrou pour éviter les faux comptes actifs par défaut.
class StoreService {
  static const _storesCollection = 'stores';

  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String tel,
    required String adresse,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = StoreProfile(
      uid: cred.user!.uid,
      nom: nom,
      tel: tel,
      adresse: adresse,
      actif: false,
    );
    await FirebaseFirestore.instance
        .collection(_storesCollection)
        .doc(cred.user!.uid)
        .set(profile.toMap());
    await _registerFcmToken(cred.user!.uid);
  }

  static Future<void> signIn(
      {required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = currentUser?.uid;
    if (uid != null) await _registerFcmToken(uid);
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> _registerFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance
          .collection(_storesCollection)
          .doc(uid)
          .update({'fcmToken': token});
    } catch (_) {
      // Permission notifications refusée ou token indisponible : le
      // magasin reste utilisable, juste sans push (il peut toujours
      // ouvrir l'app pour voir les demandes).
    }
  }

  static Future<StoreProfile?> myProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection(_storesCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return StoreProfile.fromDoc(doc);
  }

  /// Demandes ouvertes, les plus récentes d'abord.
  /// MVP : tous les magasins actifs voient toutes les demandes ouvertes
  /// (pas de filtre par catégorie/proximité pour l'instant).
  static Stream<List<PartRequest>> openRequests() {
    return FirebaseFirestore.instance
        .collection('part_requests')
        .where('statut', isEqualTo: 'open')
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PartRequest.fromDoc).toList());
  }

  /// Le magasin répond à une demande avec un prix.
  static Future<void> respondToRequest({
    required String requestId,
    required num prix,
    required String stock,
    required String message,
  }) async {
    final profile = await myProfile();
    if (profile == null) {
      throw Exception('Profil magasin introuvable.');
    }
    final offer = PartOffer(
      id: '',
      storeId: profile.uid,
      storeNom: profile.nom,
      storeTel: profile.tel,
      prix: prix,
      stock: stock,
      message: message,
      dateReponse: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('part_requests')
        .doc(requestId)
        .collection('offers')
        .doc(profile.uid) // un seul prix par magasin, ré-écrasable
        .set(offer.toMap());
  }
}
