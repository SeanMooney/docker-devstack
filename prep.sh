#!/bin/bash
pip install -U -r requirements.txt
# this will only remove the  container if the container exists
unset DOCKER_HOST
docker logs docker-http > /dev/null  && docker stop docker-http && docker rm docker-http
docker run -d -p 127.0.0.1:2375:2375 --volume=/var/run/docker.sock:/var/run/docker.sock --name=docker-http sequenceiq/socat
export DOCKER_HOST="tcp://127.0.0.1:2375"
docker ps


patch=$(git diff -- DockerMake | grep b0b6e877d80c2ae5ed4973bf160fd7ad7deb6427-dirty >/dev/null; echo $?)
if [ "$patch"="1" ]; then
git submodule update --init
pushd DockerMake
    patch -p1 < ../dockermake.patch
popd
fi

