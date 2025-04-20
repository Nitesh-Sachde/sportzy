const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendMatchCreatedNotification = onDocumentCreated(
  'matches/{matchId}', // Path to your Firestore collection
  async (snap, context) => {
    const matchData = snap.data();
    const teamPlayerUIDs = [...matchData.team1Players, ...matchData.team2Players];

    // Fetch FCM tokens of players
    const tokenFetches = await Promise.all(
      teamPlayerUIDs.map(uid =>
        admin.firestore().collection('users').doc(uid).get()
      )
    );

    const tokens = tokenFetches
      .map(doc => (doc.data() && doc.data().fcmToken))
      .filter(token => !!token);

    const payload = {
      notification: {
        title: 'New Match Created!',
        body: `${matchData.team1Name} vs ${matchData.team2Name}`,
      },
      data: {
        matchId: matchData.matchId || '',
      },
    };

    // Send notification to involved players
    if (tokens.length > 0) {
      await admin.messaging().sendToDevice(tokens, payload);
    }

    // Notify all other users (optional)
    const allUsers = await admin.firestore().collection('users').get();
    const allTokens = allUsers.docs
      .map(doc => doc.data().fcmToken)
      .filter(token => !!token && !tokens.includes(token));

    if (allTokens.length > 0) {
      await admin.messaging().sendToDevice(allTokens, {
        notification: {
          title: 'Check out the latest match!',
          body: `${matchData.team1Name} vs ${matchData.team2Name}`,
        },
      });
    }

    return null;
  }
);
