const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Notifie tous les magasins actifs (avec token FCM enregistré) dès
 * qu'une nouvelle demande de pièce est diffusée.
 *
 * C'est LE morceau qui nécessite un vrai backend : la diffusion "push"
 * ne peut pas se faire depuis l'app cliente elle-même (elle n'a pas les
 * droits d'envoyer des notifications à d'autres utilisateurs). D'où
 * Cloud Functions ici.
 */
exports.notifyStoresOnNewRequest = functions.firestore
  .document('part_requests/{requestId}')
  .onCreate(async (snap) => {
    const requestData = snap.data();

    const storesSnap = await admin
      .firestore()
      .collection('stores')
      .where('actif', '==', true)
      .get();

    const tokens = storesSnap.docs
      .map((doc) => doc.data().fcmToken)
      .filter((t) => !!t);

    if (tokens.length === 0) {
      console.log('Aucun magasin actif avec token FCM — rien à notifier.');
      return null;
    }

    const message = {
      notification: {
        title: 'Nouvelle demande de pièce',
        body: requestData.pieceNom
          ? `Pièce recherchée : ${requestData.pieceNom}`
          : 'Un client recherche une pièce.',
      },
      data: {
        requestId: snap.id,
      },
      tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `Notifications envoyées : ${response.successCount} succès, ${response.failureCount} échecs.`
    );
    return response;
  });
