---
title: "P2P Graph Simulator - Part 2 - Simple P2P"
date: 2021-03-30T08:00:00-00:00
categories:
  - web-dev
tags:
  - js
  - p2p
---

I've continued working on the P2P graph simulator and I have added directed
connections and a random message delay. I've also finished implementing the
most basic protocol possible where each peer just connects to as many peers
as it can find. The algorithm is very simple. When a new peer connects to
the network, it sends a connection request to the node it knows. The
receiving node anwers with the list of peers it is connected to. The
connecting node in turn sends connection requests to every new peer it received.

Failures are handled by periodically checking each existing connection. If
a connection stops working for some reason, a node sends all its peers to
its peers and they themselves check if there is a peer to be added back.

![Simple P2P](/assets/images/posts/2021-03-30/simple-p2p.png "Simple P2P")

You can see the code in its
[public repo](https://github.com/RiscadoA/p2p-graph-simulator) or try the
simulator on its [page](https://riscadoa.github.io/p2p-graph-simulator/)
(hosted by GitHub Pages).

What I'm doing right now is implementing the _Ring Network_ protocol described 
in [this paper](https://ccl.northwestern.edu/2005/ShakerReevesP2P.pdf).[^1]

<iframe width="560" height="315" src="https://www.youtube.com/embed/xqPVVIhXUIA"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[^1]: (A. Shaker and D. S. Reeves, "Self-stabilizing structured ring topology P2P systems," _Fifth IEEE International Conference on Peer-to-Peer Computing (P2P'05)_, 2005)