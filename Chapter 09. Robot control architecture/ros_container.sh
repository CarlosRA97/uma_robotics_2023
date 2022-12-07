#!/bin/bash
export containerId=ros
export imageName="docker.io/carlosra97/ros_uma_robotics:latest"

function run_init_ros {
    sudo podman run -itd \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --env="DISPLAY" \
        --privileged \
        --name="$containerId" \
        $imageName \
        bash

    xhost +local:`sudo sudo podman inspect --format='{{ .Config.Hostname }}' $containerId`
}

sudo podman inspect $containerId &> /dev/null

if [ $? -ne 0 ]; then
    run_init_ros
fi

function create_ros_image {
    sudo podman build . -t $imageName
#     containerId=$(sudo podman run -itd \
#     --workdir="/root" \
#     docker.io/osrf/ros:melodic-desktop-full \
#     sh)
#
#     sudo podman cp catkin_ws/ $containerId:/catkin_ws
#
#     sudo podman start $containerId && sudo podman exec $containerId bash -c "source /ros_entrypoint.sh && cd /catkin_ws/src && catkin_init_workspace && cd .. && catkin_make && echo '[ -f /catkin_ws/devel/setup.bash ] && source /catkin_ws/devel/setup.bash' >> /root/.bashrc && exit"
#
#     sudo podman commit $containerId $imageName
#     sudo podman stop $containerId && sudo podman rm $containerId
    sudo podman push $imageName
}

sudo podman start $containerId && sudo podman exec -it $containerId bash
