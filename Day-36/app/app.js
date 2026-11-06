const http = require('http');
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'UP', timestamp: new Date().toISOString() }));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>DevOps Winter Arc Integration App</h1><p>Status: Running</p>');
  }
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
