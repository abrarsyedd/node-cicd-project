const express = require('express');
const app = express();
// Use the HOST environment variable set in the Dockerfile
const HOST = process.env.HOST || '0.0.0.0'; 
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from Node CI/CD!');
});

app.listen(PORT, HOST, () => {
  console.log(`Application listening at http://${HOST}:${PORT}`);
});
