const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

console.log('Ruta de credenciales:', process.env.FIREBASE_CREDENTIALS);
const serviceAccount = require(process.env.FIREBASE_CREDENTIALS); // Asegúrate de que solo se declare aquí

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

module.exports = db;
