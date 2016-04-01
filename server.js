// Load the http module to create an http server.
var http = require('http');
const spawn = require('child_process').spawn;

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function (request, response) {
  console.info("Received request");
  response.writeHead(200, {"Content-Type": "text/plain"});
  // response.end("Hello World\n");

  var ls = spawn('docker', ['ps']);
  var buffer = '';

  ls.stdout.on('data', (data) => {
    // console.log(`stdout: ${data}`);
    buffer = buffer + data;
  });

  ls.stderr.on('data', (data) => {
    console.error(`stderr: ${data}`);
    response.end(buffer);
    //buffer = buffer + data;
  });

  ls.on('close', (code) => {
    console.log(`child process exited with code ${code}`);
    // console.info(buffer);
    response.end(buffer);
  });
  
});

// Listen on port 8000, IP defaults to 127.0.0.1
server.listen(8000);

// Put a friendly message on the terminal
console.log("Server running at http://127.0.0.1:8000/");
