---
title: "HS Robot Controller - Part 1"
date: 2021-10-23T00:00:00-00:00
categories:
  - other
tags:
  - hs
  - opencv
---

I've been working on a controller for a robot I'm developing with other
students at [HackerSchool](https://hackerschool.io). HackerSchool is a
non-profit academic association where you can find other people with similar
interests to yours and develop projects in many areas. The goal of the project
I'm working on is to build a 6-wheeled robot with a robotic arm from the ground
up.

The robot can be controlled from an Android application. In the app you can
change the mode of the robot to:
- manual control, where you can control the robot through a virtual joystick
shown in the application.
- line following, where the robot follows a black line on the floor using its
camera.
- maze solving, where the robot has to enter a maze, find a target, grab the
target using its arm, and bring the target outside the maze.

I've been tasked with developing the robot controller code which will run in a
Raspberry PI. You can check the controller repository
[here](https://github.com/HackerSchool/HS-Robot-Controller).

## Structure

When I was structuring the controller, I had to guarantee that the robot
hardware and the application would be easily plugged in later in development,
since they were being developed by other teams. I needed to be able to test
my work independently of the progress already made in the other areas, so I
abstracted away the hardware and application, and implemented their interfaces
with 'simulated' versions.

### Simulation

So, how could I test the robot controller when there was no robot to test it
with? I did some searching and found [Webots](https://cyberbotics.com/), which
is an open source robotics simulator. My colleague built a very simplified
version of the real robot in Webots, and I have been using it to test the
controller since then.

I implemented the robot hardware wrapper using Webots, and this enabled me
to develop behaviour such as the line follower before we have a physical
robot.

### Application

At first, I implemented a simple `WebotsApp` which just read keyboard input
from Webots. Then, I implemented the `HSApp` which implements a simple
bluetooth communication protocol I designed with the app team. I was able to
test this bluetooth connection without the app and robot by using Webots and an
Android app which allows me to send arbitrary data by bluetooth.

This way I was able to control the simulated Webots robot using my phone,
through bluetooth.

### Behaviour

The robot behaviour is implemented through an abstract `Behaviour` class. I
defined a `Manager` class which is responsible for registering behaviours and
setting and updating the current behaviour. The behaviours are set by the
current `App` implementation, and those in turn also use the `App`.

For example, the `Manual` behaviour is used to control the robot manually. It
gets the current joystick value from the abstract `App` object and moves the
robot accordingly.

There's also a `LineFollower` behaviour which implements a line following
algorithm by processing the camera image using [OpenCV](https://opencv.org/).
You can see the line follower behaviour in action in this video:

<iframe width="560" height="315" src="https://www.youtube.com/embed/VOQR_DVcO7g"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Future plans

What comes next is adding the robotic arm model to the Webots simulation,
implementing the maze solver behaviour, and finally making the robot able to
grab objects with its arm. The robot still hasn't been built in real life,
but when it's finished I will need to fine tune the controller to the real
thing, which shouldn't be difficult.
