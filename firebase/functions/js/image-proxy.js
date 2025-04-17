const functions = require('firebase-functions');
const cors = require('cors')({origin: true})
const fetch = require('node-fetch');

const imageProxy = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
     console.log('Requested URI:', req.originalUrl);
     const url = req.query.url;

     if (!url) {
       res.status(400).send('URL parameter is required');
       return;
     }

     try {
       const response = await fetch(url);
       const contentType = response.headers.get('content-type');

       res.setHeader('Content-Type', contentType);
       response.body.pipe(res);
     } catch (error) {
       console.error('Error fetching URL:', error);
       res.status(500).send('Error fetching URL');
     }
  });
});

module.exports = imageProxy;