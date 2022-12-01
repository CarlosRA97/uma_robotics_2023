sudo podman run -it \
    --user=$(id -u $USER):$(id -g $USER)  \
    --name="ros" \
    --env="DISPLAY" \
    --workdir="/home/$USER" \
    --volume="/home/$USER:/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/usr/lib/dri:/usr/lib/dri:ro" \
    docker.io/osrf/ros:melodic-desktop-full \
    exit

export containerId=$(sudo podman ps -l -q)
xhost +local:`sudo podman inspect --format='{{ .Config.Hostname }}' $containerId`
sudo podman start $containerId

echo "call on source catkin_ws/devel/setup.bash to setup env variables once in the container"
sudo podman exec -it $containerId sh

