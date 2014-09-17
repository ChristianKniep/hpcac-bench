#!/bin/bash

# To get all the /dev/* devices needed for sshd and alike:
DEV_MOUNTS="-v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
DEV_MOUNTS="${DEV_MOUNTS} -v /dev/null:/dev/null -v /dev/zero:/dev/zero"

case $1 in 
    monster)
        # if you want to store data outside of the CoW-FS
        NO_COW="-v /data/whisper/:/var/lib/carbon/whisper -v /data/elasticsearch:/var/lib/elasticsearch"

        docker run -d -h monster --name monster --privileged \
            --privileged  ${DEV_MOUNTS} ${NO_COW} \
            -p 9200:9200 -p 8888:8888 -p 5514:5514 -p 8080:8080 -p 2003:2003 \
            qnib/monster:latest
    ;;
    registry)
        docker run -d -h registry --name registry -e STORAGE_PATH=/registry \
            -p 5000:5000 -v /var/lib/docker-registry:/registry registry
    ;;
    *)
        echo "No known container given"
    ;;
esac
