const http = require('http'),
    os = require('os');

const port = process.env.PORT || 8080;

const server = http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`Hello world from (${os.hostname()})\n`);
})

server.listen(port);

console.log(`Server running at port: ${port}\n`);