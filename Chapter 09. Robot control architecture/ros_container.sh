export containerId=ros
sudo podman inspect $containerId 2>&1 > /dev/null
if [ $? -ne 0 ]; then

sudo podman run -it \
    --user=$(id -u $USER):$(id -g $USER)  \
    --env="DISPLAY" \
    --name="$containerId" \
    --workdir="/home/$USER" \
    --volume="/home/$USER:/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    docker.io/osrf/ros:melodic-desktop-full \
    sh

    sudo podman cp catkin_ws/ $containerId:/catkin_ws

    sudo podman start $containerId && sudo podman exec $containerId bash -c "source /ros_entrypoint.sh && cd /catkin_ws/src && catkin_init_workspace && cd .. && catkin_make && exit"

    echo '[ -f "/catkin_ws/devel/setup.bash" ] && source "/catkin_ws/devel/setup.bash"' >> $HOME/.bashrc

    xhost +local:`sudo sudo podman inspect --format='{{ .Config.Hostname }}' $containerId`
fi

sudo podman start $containerId
wait
echo "call on source /catkin_ws/devel/setup.bash to setup env variables once in the container"
sudo podman exec -it $containerId bash
