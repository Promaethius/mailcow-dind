# mailcow-dind
Implementation of a DinD container that can host mailcow-dockerized in a situation where splitting the services is counter intuitive e.g. kubernetes.

## Roadmap
* Install a process monitor to keep track of dockerd, crond, and docker-compose up
* Use aforementioned process monitor to allow https://github.com/mailcow/mailcow-dockerized/blob/master/update.sh to gracefully perform an update.

## Caveats
* No support for IPV6
* Apart from the backups, the filesystems are not directly accessible. All docker-compose volumes are stored in /var/lib/docker
* Because volumes are stored this way internally, it is possible for this image to consume a fair deal of network traffic assuming an NFS of some sort mounted on /var/lib/docker.
