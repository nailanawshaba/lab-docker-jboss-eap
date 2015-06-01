#!/bin/bash

regex='^([^\/]*)/(.*):(.*)$'
repo="${REGISTRY_SERVICE_HOST}:${REGISTRY_SERVICE_PORT}"

PULL_IMAGES='registry.access.redhat.com/rhel7.1:latest ce-registry.usersys.redhat.com/jboss-eap-6/eap:6.4 ce-registry.usersys.redhat.com/jboss-webserver-3/httpd:3.0 docker.io/postgres:9.4'

export DOCKER_HOST=${DOCKER_PORT} 
unset DOCKER_CERT_PATH 
unset DOCKER_TLS_VERIFY

# Pull all the images first
for IMAGE in ${PULL_IMAGES}; do
    if [[ $IMAGE =~ $regex ]]; then
        server=${BASH_REMATCH[1]}
        name=${BASH_REMATCH[2]}
        tag=${BASH_REMATCH[3]}
    fi

    #Only pull if the images doesn't exists locally
    if [ $(docker images | grep $server/$name | grep $tag | wc -l) -lt 1 ]; then
        docker pull $IMAGE
    fi
done

# Wait for the registry to be available

echo "Checking for registry on http://$repo/v1/_ping. Press Ctrl-C twice to abort at any time."
until $(curl --output /dev/null --silent --head --fail http://$repo/v1/_ping); do printf '.'; sleep 5; done
echo "Registry is available."

# Then push the images 
for IMAGE in ${PULL_IMAGES}; do
    if [[ $IMAGE =~ $regex ]]; then
        server=${BASH_REMATCH[1]}
        name=${BASH_REMATCH[2]}
        tag=${BASH_REMATCH[3]}
    fi

    id_str=`docker inspect $IMAGE | grep Id`
    id=${id_str:11:-2}

    docker tag -f $id $repo/$name:$tag
    docker push $repo/$name:$tag
done

