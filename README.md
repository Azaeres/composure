# Composure App Platform

### Architecture

```
Hypriot Raspberry Pi image
  Raspbian
    * Docker daemon
    * Main system docker container
      > Nodejs, system API service (exposes OS and app-related actions to the client)
        - docker client
        - docker-compose
      > OAuth2 service (token and session management)
      > Notification system
      > Caddy static proxy server [https://composure]
      > Lock screen (Log in) [https://lock.composure]
      > Home screen (run, uninstall apps) [https://home.composure]
        - List of installed apps (both lite and heavy apps)
        - List of running apps (quit apps)
        - System control (sleep, restart, shut down, log out)
        - Notification panel
      > Personal App store (install heavy apps) [https://apps.composure]
      > Web Browser-within-a-browser (install static apps) [https://browse.composure]
      > Settings [https://settings.composure]
        - Mapping apps to app ids
        - Scoping notifications
      > { ...User-installed heavy app containers... } [https://{appid}.composure]
```

### Docker install package

#### Manually build debian pkg

```
  # Build debian package for ARM Docker
  git clone https://github.com/hypriot/rpi-docker-builder.git
  cd rpi-docker-builder
  ./build.sh
  ./run-builder.sh
```

#### Alternative: Download debian pkg

[https://packagecloud.io/Hypriot/Schatzkiste/packages/debian/wheezy/docker-hypriot_1.10.3-1_armhf.deb](https://packagecloud.io/Hypriot/Schatzkiste/packages/debian/wheezy/docker-hypriot_1.10.3-1_armhf.deb)

```
# Copy file over to Raspbian
scp /Users/ryancbarry/Downloads/docker-hypriot_1.10.3-1_armhf.deb root@192.168.1.103:/root/pkg/docker-hypriot_1.10.3-1_armhf.deb
```

### Create main system container

```
docker pull hypriot/rpi-node
  -> (Image: 286e53bda778)
```

```
docker run --name api-server --privileged -p 8000:8000 -v /var/run/docker.sock:/var/run/docker.sock -v /root/pkg/:/root/pkg/ -ti 286e53bda778 bash
```

### Install docker inside main system container

```
apt-get update && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

dpkg -i /root/pkg/docker-hypriot_1.10.3-1_armhf.deb
```

### Set up and start the API server

```
cat << EOF >> server.js
```

```
// Load the http module to create an http server.
var http = require('http');

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function (request, response) {
  console.info("Received request");
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.end("Hello World\n");
});

// Listen on port 8000, IP defaults to 127.0.0.1
server.listen(8000);

// Put a friendly message on the terminal
console.log("Server running at http://127.0.0.1:8000/");
EOF
```

```
node server.js
```


### Protoype Dockerfile

```
FROM hypriot/rpi-node:latest
MAINTAINER Ryan Barry <azaeres@gmail.com>

COPY /root/pkg/docker-hypriot_1.10.3-1_armhf.deb
dpkg -i /root/pkg/docker-hypriot_1.10.3-1_armhf.deb

```

### Static proxy server

```
https://github.com/armhf-docker-library/caddy
```
