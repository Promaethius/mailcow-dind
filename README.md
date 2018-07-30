[![Build Status](https://travis-ci.org/Promaethius/mailcow-dind.svg?branch=master)](https://travis-ci.org/Promaethius/mailcow-dind) [![Docker Repository on Quay](https://quay.io/repository/promaethius/mailcow-dind/status "Docker Repository on Quay")](https://quay.io/repository/promaethius/mailcow-dind)
# mailcow-dind
Implementation of a DinD container that can host mailcow-dockerized in a situation where splitting the services is counter intuitive e.g. kubernetes.

## Roadmap
* Install a process monitor to keep track of dockerd, crond, and docker-compose up
* Use aforementioned process monitor to allow https://github.com/mailcow/mailcow-dockerized/blob/master/update.sh to gracefully perform an update.
* Make IPV6 optional. Requires a host mount of /lib/modules and isn't as self-contained.

## Caveats
* No support for IPV6
* Apart from the backups, the filesystems are not directly accessible. All docker-compose volumes are stored in /var/lib/docker
* Because volumes are stored this way internally, it is possible for this image to consume a fair deal of network traffic assuming an NFS of some sort mounted on /var/lib/docker.

## Quick Start

```
docker pull quay.io/promaethius/mailcow-dind:latest
docker run -e HOSTNAME='example.com' -e CRON_BACKUP='* * * 0 0 *' -e TIMEZONE='PDT' -v /docker/persist:/var/lib/docker -v /mailcow/persist:/mailcow -v /mailcow/backup/persist:/mailcow-backup -v /lib/modules:/lib/modules:ro --name mailcow-dind --privileged --net=host -d mailcow-dind

#Follow the logs and installation with this command:
docker logs mailcow-dind -f
```

When everything looks like it setup correctly, refer to official mailcow documentation: https://mailcow.github.io/mailcow-dockerized-docs/

## Disclaimer
In no way is this repository or its author affiliated with mailcow or its constituents. Neither is the author responsible for any loss or mutilation of data in the usage of this software.
