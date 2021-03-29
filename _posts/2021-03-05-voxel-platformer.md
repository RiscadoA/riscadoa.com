---
title: "Voxel Platformer"
date: 2021-03-05T11:20:00-00:00
categories:
  - game-dev
tags:
  - voxels
  - cpp
  - opengl
---

This past week I challenged myself to make a simple 3D voxel platformer from
scratch in C++. I reused a small amount of code from my previous voxel
experiments (the meshing algorithm and the Qubicle file parser).
I made all of the assets myself (programmer art (;). The external dependencies
I used were [GLEW](https://github.com/nigels-com/glew), for loading OpenGL
extensions, [GLFW](https://github.com/glfw/glfw) for cross-platform windows and
input and [GLM](https://github.com/g-truc/glm) for math.

You can see the source code or download a release in the game's github
[repository](https://github.com/RiscadoA/voxel-platformer).

## Physics

This was the first time I implemented a 'physics engine': I don't think its fair
to call it a physics engine since the only object which has physics calculations
is the player character. The only two types of colliders supported are Axis
Aligned Bounding Boxes (AABBs) and spheres.

## Entity Component System

I followed an entity component system architecture inspired by the Unity game
engine and wrote a format to store scenes in files. It ended up becoming a big
mess since I made some bad design decisions right at the beginning and didn't
have time to fix it (in the next engine I make I'll take this into account). I
had the following component types:
- Transform - stores the transformation of an entity and it's parent entity
(used to create hierarchies).
- Collider - represents a collider in the physics engine.
- Camera - represents a camera used to render the scene.
- Light - represents a light (can either be a point light or a directional
light).
- Renderable - represents a renderable voxel model.
- Behaviour - a flexible component with virtual methods that can overrided to
implement game logic.

I had to write each scene manually using their configuration files since I
didn't have time to add an editor, which made the whole process tedious. 

## Graphics

I wrote a tiny deferred renderer with support for multiple lights (each bullet
acts as a light source too) and reused the greedy meshing algorithm I previously
implemented in my LOD voxel terrain system.

I didn't make a GUI because I didn't really have time to make one, so I ended up
writing 'messages' using voxel art instead. This way I avoided having to write
a font loader and a text renderer, which saved me a lot of time.

## Walkthrough

You can see the game's walkthrough here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/xQUHqsscRw8"
frameborder="0" allow="accelerometer; autoplay; clipboard-write;
encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

