const admin = require('firebase-admin');
const dotenv = require('dotenv');

// Cargar variables de entorno
dotenv.config();

admin.initializeApp({
  credential: admin.credential.cert(require(process.env.FIREBASE_CREDENTIALS)),
});

const db = admin.firestore();
module.exports = db;
