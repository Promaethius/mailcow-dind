[![Build Status](https://travis-ci.org/Promaethius/mailcow-dind.svg?branch=master)](https://travis-ci.org/Promaethius/mailcow-dind) [![Docker Repository on Quay](https://quay.io/repository/promaethius/mailcow-dind/status "Docker Repository on Quay")](https://quay.io/repository/promaethius/mailcow-dind)
# mailcow-dind
Implementation of a DinD container that can host mailcow-dockerized in a situation where splitting the services is counter intuitive e.g. kubernetes.

## Roadmap
* Make IPV6 optional. Requires a host mount of /lib/modules and isn't as self-contained.

## Caveats
* No support for IPV6

## Quick Start

```
docker pull quay.io/promaethius/mailcow-dind:latest
docker run -e HOSTNAME='mailplace.com' -e CRON_BACKUP='* * * 0 0 *' -e CRON_UPDATE='0 0 * * 0 *' -e TIMEZONE='PDT' -v /docker/persist:/mnt -v /mailcow/persist:/mailcow -v /mailcow/backup/persist:/mailcow-backup -v /lib/modules:/lib/modules:ro --name mailcow-dind --privileged --net=host -d mailcow-dind

#Follow the logs and installation with this command:
docker logs mailcow-dind -f
```

When everything looks like it setup correctly, refer to official mailcow documentation: https://mailcow.github.io/mailcow-dockerized-docs/

## API

It is possible to start this image with a declared API key and a comma separated list of IPs can access the API.
Use the environment variables API_KEY and API_IPS. While stock Mailcow crash-loops when initialized with API keys, this system initializes the database with some clever PHP magic and then injects the API keys which circumvents the issue.

## Volumes

All mailcow volumes are exposed as folders within the `mailcow-dind` container as sub-mounts within `/mnt`. It is left to the administrator to either mount a single volume at `/mnt` or to mount separate volumes for each service. The names of each volume are subject to change but follow the simple naming convention of `/mnt/volume` where "volume" is interchangable with any seen here: https://github.com/mailcow/mailcow-dockerized/blob/94c865b8a1b354c392a1e19d68e77a5bb81e8d3e/docker-compose.yml#L411

## Disclaimer
In no way is this repository or its author affiliated with mailcow or its constituents. Neither is the author responsible for any loss or mutilation of data in the usage of this software.
