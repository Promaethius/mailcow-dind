# mailcow-dind
Implementation of a DinD container that can host mailcow-dockerized in a situation where splitting the services is counter intuitive e.g. kubernetes.

## Roadmap
* Install a process monitor to keep track of dockerd, crond, and docker-compose up
* Use aforementioned process monitor to allow https://github.com/mailcow/mailcow-dockerized/blob/master/update.sh to gracefully perform an update.
