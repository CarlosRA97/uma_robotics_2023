import numpy as np
import rospy as ros

from geometry_msgs.msg import Twist, TransformStamped
from sensor_msgs.msg import LaserScan
from nav_msgs.msg import Odometry
from tf import TransformBroadcaster
from tf.transformations import euler_from_quaternion, quaternion_from_euler

class RobotState:
    def __init__(self):
        self.ranges = []
        self.left_range = []
        self.center_range = []
        self.right_range = []
        
        self.n_state = 0
        
        self.pose = np.array([0.0, 0.0, 0.0])
        self.move_command = []
        
        self.scan_sub = ros.Subscriber("/laser_scan", LaserScan, self._scan, buff_size=1000)
        self.odom_sub = ros.Subscriber("/odom", Odometry, self._odom, buff_size=1000)
        self.move_pub = ros.Publisher("/cmd_vel", Twist, queue_size=1000)
        
        
    def _odom(self, msg):
        orientation = msg.pose.pose.orientation
        eu_orientation = euler_from_quaternion([orientation.x, orientation.y, orientation.z, orientation.w])
        position = msg.pose.pose.position
        x = position.x
        y = position.y
        ros.loginfo("Odometry: Position ({},{}), Orientation {}".format(x, y, np.rad2deg(eu_orientation[2])))
        
        
    def _scan(self, msg):
        self.ranges = msg.ranges
        n_ranges = len(self.ranges)
        views_3 = n_ranges/3
        
        self.right_ranges = self.ranges[0:int(views_3)]
        self.center_ranges = self.ranges[int(views_3):int(views_3)*2]
        self.left_ranges = self.ranges[int(views_3)*2+1:n_ranges]
        
        ros.loginfo("Left Ranges: min {}, max {}".format(min(self.left_ranges),max(self.left_ranges)))
        ros.loginfo("Center Ranges: min {}, max {}".format(min(self.center_ranges),max(self.center_ranges)))
        ros.loginfo("Right Ranges: min {}, max {}".format(min(self.right_ranges),max(self.right_ranges)))
        
    def move(self, u):
        tw = Twist()
        tw.linear.x = u[0]
        tw.linear.y = u[1]
        tw.angular.z = u[2]
                
        self.move_pub.publish(tw)
        
    def moving_states(self, dt):
        if self.n_state == 0:
            vx = 0.5
            vy = 0.0
            vth = 0.0
            
            deltas = self.deltas([vx, vy, vth], dt)
            
            self.pose += deltas
            
            self.move_command = self.pose
            self.n_state = 1
        elif self.n_state == 1:
            self.n_state = 0
        else:
            self.n_state = 0
        self.move(self.move_command)
            
    
    def deltas(self, v, dt):
        vx, vy, vth = v[0], v[1], v[2]
        delta_x = (vx * np.cos(vth) - vy * np.sin(vth)) * dt;
        delta_y = (vx * np.sin(vth) + vy * np.cos(vth)) * dt;
        delta_th = vth * dt;
        return np.array([delta_x, delta_y, delta_th])
