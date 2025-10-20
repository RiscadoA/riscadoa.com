---
title: "P2P Graph Simulator"
excerpt: "A P2P graph simulator that runs on the browser used to visualize various protocols."
header:
  image: /assets/images/p2p-graph-simulator.png
  teaser: /assets/images/p2p-graph-simulator.png
sidebar:
  - title: "Date"
    text: "2021"
  - title: "Role"
    text: "Author"
---

I was working on a P2P chat application and I was investigating multiple
protocols and trying to choose one that would fit my needs. I found it
hard to visualize and thought that it would be nice to be able to see how each protocol behaved in some kind of simulation. So, I started working on a
P2P graph simulator. It supports both simple P2P networks where every
peer knows every other peer and _Ring Networks_.

You can see the code in its
[public repo](https://github.com/RiscadoA/p2p-graph-simulator) or try the
simulator on its [page](https://riscadoa.github.io/p2p-graph-simulator/)
(hosted by GitHub Pages).

<iframe width="560" height="315" src="https://www.youtube.com/embed/_n00B8bed4Y"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Tools

To add new peers you must activate the placement mode (click the plus sign).
In this mode you can place isolated peers by clicking on the background or
add a peer to a network by clicking on an already existing peer.

You can also kill peers which makes them disappear without warning other
peers. This allows us to see how well each protocol can handle failures.
For this you need to activate the deletion mode (click the minus sign).
In this mode you can also kill individual connections.

There is also a line tool which allows you to connect two already existing
peers. This may cause different networks to merge. As with the placement and
deletion nodes, you need to activate the line mode by clicking on its button.

## Protocols

To choose the protocol you want to simulate, you just need to click the
respective button (simple or ring). This resets the simulation. When the ring
protocol is selected buttons numbered from 1 to 4 appear which allows us to set
the neighbor limit.
