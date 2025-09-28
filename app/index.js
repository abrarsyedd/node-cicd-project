// app/index.js
const express = require('express');
const app = express();

// Use environment variables from Dockerfile
const HOST = process.env.HOST || '0.0.0.0'; 
const PORT = process.env.PORT || 3000;

// Simple route handler
app.get('/', (req, res) => {
  res.send('<h1>Node.js CI/CD App is Running! Thank you.</h1>');
});

// Start the server
app.listen(PORT, HOST, () => {
  console.log(`Server is listening on http://${HOST}:${PORT}`);
});
