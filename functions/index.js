/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

/* const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger"); */

const functions = require("firebase-functions");
const cors = require("cors")({origin: true});
const axios = require("axios");
const express = require("express");
const app = express();

const PORT = process.env.PORT || 8081; // Asegúrate de usar process.env.PORT
app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en el puerto ${PORT}`);
});

exports.getDirections = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const {origin, destination, apiKey} = req.query;
      const response = await axios.get(
          `https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=driving&key=${apiKey}`,
      );
      res.json(response.data);
    } catch (error) {
      res.status(500).json({error: "Error fetching directions"});
    }
  });
});
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
