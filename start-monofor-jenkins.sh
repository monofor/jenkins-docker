#!/bin/bash

imageName="monofor/jenkins"
latestImageVersion=""
latestJenkinsVersion=""
containerNamePrefix="monofor-jenkins-"
envItem="JENKINS_VERSION="

# get latest image and find image version
# ------------------------------------------------------------------------------------
docker pull "$imageName":latest
latestImageVersion=$(docker image ls -q --no-trunc "$imageName:latest")
echo "The latest image version is: $latestImageVersion"
# ------------------------------------------------------------------------------------

# find the image version of running container
# ------------------------------------------------------------------------------------
latestJenkinsVersion=$(docker image inspect -f '{{range $index, $value := .Config.Env}}{{println $value}}{{end}}' "$imageName" | grep $envItem | sed "s/$envItem/v/" | sed "s/\./\-/")
oldContainerName=$(docker ps --format '{{.Names}}' | grep $containerNamePrefix)
newContainerName="$containerNamePrefix$latestJenkinsVersion"

if [ "$oldContainerName" = "" ]; then
    echo "Running Container not found, starting..."

    docker run -d \
        --ulimit nofile=8192:8192 \
        -p 60220:8080 -p 60221:50000 \
        -v monofor-jenkins:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name "$newContainerName" \
        --restart=always \
        --ipc=host \
        "$imageName":latest
else

    runningImageVersion=$(docker container inspect -f '{{.Image}}' "$oldContainerName")

    if [ "$latestImageVersion" = "" ]; then
        echo "Latest image version could not found!"
    elif [ "$latestImageVersion" = "$runningImageVersion" ]; then
        echo "The running Version is up to date :) (Jenkins: $latestJenkinsVersion, Image: $runningImageVersion)"
    else
        echo "Stopping container"
        docker stop "$oldContainerName"
        docker rename "$oldContainerName" "tmp-$oldContainerName"

        echo "Running new Version: $newContainerName"
        docker run -d \
            --ulimit nofile=8192:8192 \
            -p 60220:8080 -p 60221:50000 \
            -v monofor-jenkins:/var/jenkins_home \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --name "$newContainerName" \
            --restart=always \
            --ipc=host \
            "$imageName":latest

        # wait a little to container run completely
        sleep 30

        # check if the new container is running
        isRunning=$(docker container inspect -f '{{.State.Running}}' "$newContainerName")
        if [ "$isRunning" = "true" ]; then
            echo "Deleting old container"
            docker rm "tmp-$oldContainerName"
        else
            sleep 60
            isRunning=$(docker container inspect -f '{{.State.Running}}' "$newContainerName")
            if [ "$isRunning" = "false" ]; then
                echo "Something went wrong, old container restarting..."

                docker rename "tmp-$oldContainerName" "$oldContainerName"
                docker start "$oldContainerName"
            fi
        fi
    fi
fi
