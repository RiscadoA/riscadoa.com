---
title: "P2P Graph Simulator - Part 3 - Ring Network"
date: 2021-03-31T07:00:00-00:00
categories:
  - web-dev
tags:
  - js
  - p2p
---

I've added the _Ring Network_ protocol described  in
[this paper](https://ccl.northwestern.edu/2005/ShakerReevesP2P.pdf)[^1]
to the P2P graph simulator. I've also set a limit on the number of
neigbours purely because the ring becomes really hard to visualize when there
are a lot of neighbours. The neighbour limit can be set by clicking the buttons
numbered from 1 to 4 on the top left. 

The result of limiting the neighbour count to 1:

![Ring with 1 neighbour limit](/assets/images/posts/2021-03-31/ring-1.png "Ring with 1 neighbour limit")

The result of limiting the neighbour count to 2:

![Ring with 2 neighbour limit](/assets/images/posts/2021-03-31/ring-2.png "Ring with 2 neighbour limit")

The result of limiting the neighbour count to 3:

![Ring with 3 neighbour limit](/assets/images/posts/2021-03-31/ring-3.png "Ring with 3 neighbour limit")

The result of limiting the neighbour count to 4:

![Ring with 4 neighbour limit](/assets/images/posts/2021-03-31/ring-4.png "Ring with 4 neighbour limit")

I've also added a tool to connect two separate networks.

You can see the code in its
[public repo](https://github.com/RiscadoA/p2p-graph-simulator) or try the
simulator on its [page](https://riscadoa.github.io/p2p-graph-simulator/)
(hosted by GitHub Pages).

What I'm planning on doing next is adding more protocols (maybe Chord) and a
counter to see how many messages were sent in average by each node. 

<iframe width="560" height="315" src="https://www.youtube.com/embed/_n00B8bed4Y"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[^1]: (A. Shaker and D. S. Reeves, "Self-stabilizing structured ring topology P2P systems," _Fifth IEEE International Conference on Peer-to-Peer Computing (P2P'05)_, 2005)