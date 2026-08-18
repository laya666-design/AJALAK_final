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

/**
 * Fait passer automatiquement à "expire" tout magasin dont l'essai
 * gratuit ou l'abonnement payé est terminé. Tourne une fois par jour.
 *
 * C'est nécessaire côté serveur (Admin SDK, donc au-delà des Firestore
 * Rules) : un client ne peut jamais modifier son propre
 * `subscriptionStatus` (voir firestore.rules), donc rien côté app ne
 * peut faire cette bascule — sinon un essai resterait "essai" pour
 * toujours une fois sa date dépassée.
 */
exports.checkExpiredSubscriptions = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const db = admin.firestore();

    const essaisExpires = await db
      .collection('stores')
      .where('subscriptionStatus', '==', 'essai')
      .where('trialEndDate', '<=', now)
      .get();

    const abonnementsExpires = await db
      .collection('stores')
      .where('subscriptionStatus', '==', 'actif')
      .where('subscriptionEndDate', '<=', now)
      .get();

    const batch = db.batch();
    [...essaisExpires.docs, ...abonnementsExpires.docs].forEach((doc) => {
      batch.update(doc.ref, { subscriptionStatus: 'expire' });
    });

    const total = essaisExpires.size + abonnementsExpires.size;
    if (total === 0) {
      console.log('Aucun essai/abonnement à expirer aujourd\'hui.');
      return null;
    }
    await batch.commit();
    console.log(`${total} magasin(s) passé(s) en "expire".`);
    return null;
  });

/**
 * Valide une preuve de paiement reçue et active/renouvelle l'abonnement
 * du magasin pour 30 jours. À appeler manuellement (ex: HTTPS callable
 * réservé à un compte admin, ou directement depuis la console Firebase
 * en modifiant le document — cette fonction est le point d'entrée propre
 * une fois que tu veux automatiser la validation).
 */
exports.validatePayment = functions.https.onCall(async (data, context) => {
  // TODO : restreindre cet appel à un compte admin identifié
  // (context.auth.token.admin === true) avant mise en prod.
  const { storeId, paymentId } = data;
  if (!storeId || !paymentId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'storeId et paymentId sont requis.'
    );
  }

  const db = admin.firestore();
  const storeRef = db.collection('stores').doc(storeId);
  const paymentRef = storeRef.collection('payment_requests').doc(paymentId);

  const subscriptionEndDate = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
  );

  await db.runTransaction(async (tx) => {
    tx.update(paymentRef, { statut: 'valide' });
    tx.update(storeRef, {
      subscriptionStatus: 'actif',
      subscriptionEndDate,
    });
  });

  return { success: true, subscriptionEndDate: subscriptionEndDate.toDate() };
});
