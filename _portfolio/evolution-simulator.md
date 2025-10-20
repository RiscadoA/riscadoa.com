---
title: "Evolution Simulator"
excerpt: "A genetic algorithm and neural networks implementation which runs on the browser."
header:
  image: /assets/images/evolution-simulator.png
  teaser: /assets/images/evolution-simulator.png
sidebar:
  - title: "Date"
    text: "2021"
  - title: "Role"
    text: "Author"
---

Immediately after finishing my gravity simulator project, I decided to start
another toy project in TypeScript, WebGL, HTML and CSS. I had already played
around with genetic algorithms when I was younger, but it was a long time ago
and I felt like revisiting that topic, so I started working on this project.

The goal of this project is to teach very simple creatures to swim to the
nearest food unit, the fastest they can. In each round, a generation of these
creatures is thrown into an arena with a certain amount of food. After some time
has passed, the round ends and the best half of the creatures (ranked by how
much food they ate) is allowed to reproduce. Over some generations the creatures
learn how to swim perfectly.

You can see the code in its
[public repo](https://github.com/RiscadoA/evolution-simulator) or try the
simulator on its [page](https://riscadoa.github.io/evolution-simulator/)
(hosted by GitHub Pages).

## How to use

All of the settings are explained on the introduction form. The camera can be
moved around my dragging the mouse with the left button pressed, and you can
also zoom in and out with the mouse wheel.

If you click on a creature, the camera starts following it, and its neural
network becomes visible. The neurons with a green outline represent the inputs
(in this case, the neural network only takes as input the distance to the
nearest food, measured by each eye). The ones with a blue outline represent the
outputs. One of the output neurons corresponds to 'turn left' and the other to
'turn right'. The creature turns to the side whose neuron has a higher value.
You can also follow the best creature by clicking the crown button on the top
left of the screen.

If you want to skip the current generation, you can press the fast forward
button on the top right of the screen. This will simulate the current round as
fast as possible.

## Development

On this project I improved upon the design of my gravity simulator, and wrote a
new renderer which works with command queues, and which allows interpolation
between physics updates to be done. I implemented a fixed time-step update loop.

I also improved upon the UI (at least in the implementation side of things) of
my gravity simulator.

I still had a lot of ideas to improve the simulator, like, for example, adding
a statistics menu. Unfortunately, with the end of the university break, I had
other priorities which didn't allow me to continue developing this project.
