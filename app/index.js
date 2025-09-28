// app/index.js
const express = require('express');
const app = express();

// Use environment variables or default to 0.0.0.0 and 3000
const HOST = process.env.HOST || '0.0.0.0'; 
const PORT = process.env.PORT || 3000;

// Simple route handler
app.get('/', (req, res) => {
  res.send('<h1>Node.js CI/CD App is Running!</h1>');
});

// Start the server, listening on all interfaces (HOST: 0.0.0.0)
app.listen(PORT, HOST, () => {
  console.log(`Server is listening on http://${HOST}:${PORT}`);
});
