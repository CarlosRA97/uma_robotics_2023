FROM docker.io/osrf/ros:melodic-desktop-full

COPY ./catkin_ws/ /catkin_ws

RUN bash -c "source /ros_entrypoint.sh && \
    cd /catkin_ws/src && \
    catkin_init_workspace && \
    cd .. && \
    catkin_make"

RUN apt update && apt install -y kdevelop kdevelop-python

WORKDIR /root

RUN echo '[ -f /catkin_ws/devel/setup.bash ] && source /catkin_ws/devel/setup.bash' >> /root/.bashrc
