#!/usr/bin/env python2

import time

from numpy import random

import rospy as ros

from RobotState import RobotState

def main():
    ros.init_node('exploring')
    ros.loginfo("Robotic explorer node running and initialized! Let's have some fun!")

    robot = RobotState()

    random.seed(int(time.time()))
    
    rate = ros.Rate(2)
    
    begin = ros.Time.now()
    
    current_time = ros.Time.now()
    last_time = ros.Time.now()

    while begin.to_sec() == 0:
        begin = ros.Time.now()

    ellapsed_time = 0

    while not ros.is_shutdown() and ellapsed_time < 60.0*5.0:
        
        
        current_time = ros.Time.now()
         # compute odometry in a typical way given the velocities of the robot
        dt = (current_time - last_time).to_sec();
        
        robot.moving_states(dt)

        rate.sleep()

        current = ros.Time().now()
        ellapsed_time = current.to_sec() - begin.to_sec()
        ros.loginfo('[robot_explorer] Ellpased time: {}'.format(ellapsed_time))
        last_time = current_time
        


if __name__ == "__main__":
    main()
