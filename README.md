# Local load balancer for docker-compose projects

This project allows to access individual docker compose containers through `http://(.+\.)?<service>.<compose-project>.docker`.

This is how it works:
- A docker container runs a dns server that always returns 127.0.0.1 (exposed to localhost:10053)
- The system needs to be configured to resolve any .docker hostname with localhost:10053
- A docker container runs an nginx load balancer exposed on localhost:80 that proxies `*<service>.<compose-project>.docker`
  http requests to `<compose-project>_<service>_1`. This container is attached to all the docker networks.

The containers will start when docker starts since they are configured with `restart: always`.

## Installation

```
# Start load balancer and dns
docker-compose up -d

# Give load balancer access to all the compose networks
docker network ls --filter driver=bridge --filter scope=local -q \
    | xargs -I {} docker network connect {} "$(docker-compose ps -q lb)"

# Configure system to resolve all .docker domains using the spun up dns server
sudo mkdir -p /etc/resolver
sudo tee /etc/resolver/docker > /dev/null <<EOF
domain docker
port 10053
nameserver 127.0.0.1
EOF
```

## Adding networks

Whenever you've started a new docker compose project or added networks, run the same command that you ran during installation:

```
docker network ls --filter driver=bridge --filter scope=local -q \
    | xargs -I {} docker network connect {} "$(docker-compose ps -q lb)"
```

## Removing networks

If you need to disconnect the load balancer from a network, for example when running `docker-compose down` for that network/project:

```
docker network disconnect -f <compose-project>_default "$(docker-compose ps -q lb)"
```
