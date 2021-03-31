---
title: "Voxel Engine - Part 2 - Procedural Generation"
date: 2021-02-05T15:43:00-00:00
categories:
  - game-dev
tags:
  - voxels
  - cpp
  - opengl
---

I have finished implementing the 'octree of grids' which I wrote about in the
last article and fed it with procedurally generated data from simple math
functions. Each node in the octree represents a 32x32x32 chunk of the map,
represented by a voxel grid, which can be further divided into 8 smaller nodes
when you get closer.

![Result 1](/assets/images/posts/2021-02-05/result_1.png "Result 1")

![Result 2](/assets/images/posts/2021-02-05/result_2.png "Result 2")

This was the result of applying the technique mentioned above. The function
below was used to generate the voxel data shown in the images:

```cpp
virtual unsigned char generate_material(glm::f64vec3 pos, int level) override {
    pos /= 50.0;
    return (glm::cos(float(pos.x)) +
            glm::tanh(float(pos.y)) +
            glm::cos(float(pos.z))) < 0 ? 1 : 0;
}
```

This function acts as a kind of shader used to choose which material each voxel
should be made of (0 represents no voxel). It receives the center of the voxel
and the level in the octree (0 = leaf, higher values mean larger nodes). Since
the voxels are generated independently from each other, I may try to parallelize
it further down the line (maybe even generate it in the GPU). The slowest part
in the process of loading a new node of the octree is generating the voxel data,
not meshing, so this would lead to a significant speed-up.

<iframe width="560" height="315" src="https://www.youtube.com/embed/MYL4C-qCP5o"
frameborder="0" allow="accelerometer; autoplay; clipboard-write;
encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<br>

As you can see, the LOD system allows me to have huge render distances. The
thing I ended up having the most trouble with was adding multithreading to the
equation. The leafs of the octree must not be generated in the main thread,
because that would cause noticeable frame drops when moving. In order to prevent
this I had to create another OpenGL context in a second thread, which shares the
resources with the main context. This way the vertex and index buffers are
filled in this secondary thread and later shared with the main thread, which is
responsible for requesting node loads/unloads and drawing them when they are
ready.

Each node which is in the process of dividing into smaller nodes updates every
frame a score based on the distance to the camera and on whether it is frustum
culled or not. The children of the node with the lowest score are loaded first
and then removed from the loading queue.

I also spent some time working on a debug renderer singleton which allows me to
issue debug draw commands easily from any part of the code. In the video you can
see a green outline appearing around the octree nodes. This was drawn using the
debug renderer and is toggleable at runtime.

The next feature I'm planning to add is screen space ambient occlusion and maybe
transparency. Adding transparency will be a challenge, because usually you need
to sort all the transparent faces and draw them back to front, which would be
really slow in this context. What I'm planning to do instead, is only draw the
closest transparent face and ignore the ones behind it. This doesn't produce
great results because transparent objects become invisible when seen through
other transparent objects, but it is better than no transparency at all. I'm
planning on using it to render glass, for example. 
