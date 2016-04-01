# Composure App Platform

### Architecture

```
Hypriot Raspberry Pi image
  Raspbian
    * SSH daemon
    * Docker daemon
      > Caddy server
        - Intercepts all https://{appid}.composure requests, proxies them to apps.
        - Serves the static files that've been cached during a lite app install.
        - Proxies requests for heavy apps to the app's main service.
      > Main system docker container (privileged container) [https://system.composure] (API has accompanying app toolkit)
        * Docker client
        * SSH client
        * Nodejs, system API service (exposes OS and app-related actions to the client)
          - Uses docker client, docker-compose, ssh client
      > Inter-app pubsub system [https://transfer.composure] (API has accompanying app toolkit)
        - For one-way data flow to any number of apps.
        - Apps can subscribe to messages through webhooks and/or websockets.
        - User clipboard
        - Data import/exports
        - App notifications
      > Home screen [https://composure]
        - List of installed apps (both lite and heavy apps, run, uninstall apps)
        - List of running apps (quit apps)
        - System control (sleep, restart, shut down, log out)
        - Notification panel
      > OAuth2 service (token and session management API) [https://lock.composure] (API has accompanying app toolkit)
        - Lock screen (Log in)
      > Personal App store (install both lite and heavy apps) [https://apps.composure]
        - Everyone hosts their own personal app store.
        - They can add apps to their store from another person's app store,
            or by registering an app themselves.
        - Adding an app means posting metadata to the app store:
            - Heavy apps: JSON file containing app name, description, url to control package with docker compose 
              config files, etc. Docker compose projects are registered as heavy apps by their maintainers.
            - Lite apps: JSON file containing url to site, which contains an HTML5 manifest (icons, list of files 
              to cache, etc. Web sites are registered as lite apps by users when they're known to work from a web archive.
      > Settings [https://settings.composure]
        - Mapping apps to app ids
        - Scoping notifications
      > { User-installed apps, both lite and heavy } [https://{appid}.composure]
```

[A Beginner's Guide to Using the Application Cache](http://www.html5rocks.com/en/tutorials/appcache/beginner/)

[Download a site's manifest files](https://www.npmjs.com/package/manifest)

[Inspect docker status](https://www.npmjs.com/package/dockerode)

[Execute a unix command with Node.js](https://dzone.com/articles/execute-unix-command-nodejs)

[Portable unix shell commands for Node.js](https://github.com/shelljs/shelljs)

[Run a remote command via SSH](http://www.cyberciti.biz/faq/unix-linux-execute-command-using-ssh/)

### Raspberry Pi image

[http://blog.hypriot.com/getting-started-with-docker-on-your-arm-device/](http://blog.hypriot.com/getting-started-with-docker-on-your-arm-device/)

### Get the Debian install package for Docker

##### Manually build debian pkg

```
  # Build debian package for ARM Docker
  git clone https://github.com/hypriot/rpi-docker-builder.git
  cd rpi-docker-builder
  ./build.sh
  ./run-builder.sh
```

##### Alternative: Download debian pkg

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
docker run --name system --privileged -p 8000:8000 -v /root/pkg/:/root/pkg/ -ti 286e53bda778 bash
```

### Install docker inside main system container

```
apt-get update && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    nano

dpkg -i /root/pkg/docker-hypriot_1.10.3-1_armhf.deb
```

```
cd /root
git clone https://github.com/jpetazzo/dind.git
cd dind
sudo ./wrapdocker
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

## Roadmap

  * Build and host (Github) a control package for the main system container.
    - Dockerfile
    - docker-hypriot_1.10.3-1_armhf.deb
    - server.js
    - docker-compose.yml
  
  * Build and host (Docker hub) a Docker image from the control package.
  
  * Build and host (CDN) a Raspberry Pi micro SD card image that comes loaded with everything running.
    
  

