const admin = require('firebase-admin');
const serviceAccount = require('../config/serviceAccountKey.json'); // Asegúrate de tener este archivo

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
module.exports = db;
