#!/bin/bash
export containerId=ros
export imageName="docker.io/carlosra97/ros_uma_robotics:latest"

function run_ros {
    docker run -itd \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume="$(pwd)/catkin_ws/src/robotic_explorer:/catkin_ws/src/robotic_explorer" \
        --env="DISPLAY" \
        --privileged \
        --name="$containerId" \
        $imageName \
        bash
}

function run_rootless_ros {
    # --user=$(id -u $USER):$(id -g $USER) \
    docker run -itd \
        --userns=keep-id \
        --volume="/etc/group:/etc/group:ro" \
        --volume="/etc/passwd:/etc/passwd:ro" \
        --volume="/etc/shadow:/etc/shadow:ro" \
        --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
        --volume="/home/$USER:/home/$USER" \
        --workdir="/catkin_ws/src/robotic_explorer" \
        -e DISPLAY \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume="$(pwd)/catkin_ws/src/robotic_explorer:/catkin_ws/src/robotic_explorer" \
        --privileged \
        --name="$containerId" \
        $imageName \
        bash
}

function play_ros {
    sudo podman kube play $containerId-pod.yml
}

function create_ros_image {
    sudo podman build . -t $imageName
    sudo podman push $imageName
}

#sudo podman pod exists $containerId-pod
docker inspect $containerId &> /dev/null

if [ $? -ne 0 ]; then
    run_rootless_ros
fi

#xhost +local:`sudo podman pod inspect --format='{{ .Hostname }}' $containerId-pod`
#sudo podman pod start $containerId-pod && sudo podman exec -it $containerId-pod-$containerId bash
docker start $containerId
xhost +local:`docker inspect $containerId --format="{{ .Config.Hostname }}"`
alias kdevelop='docker exec -it $containerId kdevelop'
alias ros='docker exec -it $containerId bash'
