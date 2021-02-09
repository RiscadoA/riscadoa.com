---
title: "Voxel Engine - Part 3 - Ambient Occlusion & Colors"
date: 2020-02-09T10:51:00-00:00
categories:
  - game-dev
tags:
  - voxels
  - cpp
  - opengl
---

I have finished implementing screen space ambient occlusion which enhanced the
look of the final rendering result:

![SSAO](/assets/images/posts/2020-02-09/ssao.png "SSAO")

I've also been playing with adding colors to the voxels:

![Colors 1](/assets/images/posts/2020-02-09/colors_1.png "Colors 1")
![Colors 2](/assets/images/posts/2020-02-09/colors_2.png "Colors 2")
![Colors 3](/assets/images/posts/2020-02-09/colors_3.png "Colors 3")

Right now the engine is very CPU intensive and I'm trying to move the workload
to the GPU. One of my main concerns with the current system is that adding
voxels that emit light seems impossible. I'm trying to implement a basic voxel
raytracer/pathtracer which should make this easier and simplify and the whole
rendering process. I'll also start moving the code from OpenGL to Vulkan so that
I can do better multithreading.