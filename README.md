## Installation

```
# Generate ssl certificates using mkcert and start traefik, dns
make

# Configure system to resolve all .docker domains using the spun up dns server
sudo mkdir -p /etc/resolver
sudo tee /etc/resolver/test > /dev/null <<EOF
domain test
port 10053
nameserver 127.0.0.1
EOF
```

## Containers configuration

### docker-compose

```yaml
version: '3'

networks:
    traefik-docker:
        external: true

services:
    webserver:
        # image, volumes, etc 
        networks:
            - traefik-docker
        labels:
            traefik.enable: true
            traefik.http.routers.webserver.rule: 'Host(`my-webserver.docker.test`)'
```
