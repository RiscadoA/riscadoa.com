---
title: "P2P Graph Simulator - Part 1"
date: 2021-03-29T08:00:00-00:00
categories:
  - web-dev
tags:
  - js
  - p2p
---

For some time I've been wanting to start a project related to web development
or networking, so I decided to create a chat application. The premise of this
chat application is it being completely descentralized (P2P) and secure, with
GPG signing and end-to-end encryption. Each client would need to store the
whole message history locally, in a blockchain fashion. I'm also designing it
with the goal of being able to  support at least 50 users in the same chat
room.

For this, I need to first develop a protocol for the application, and later
implement it in various platforms (a Rust TUI, a web application, an android
application, etc). I have been looking into many ways of organizing the peer to
peer network, but I found it hard to visualize and thought that it would be
nice to be able to see how the many protocols behaved in some kind of
simulator. So, I started working on a P2P graph simulator. Right now the nodes
have no behaviour other than simply connecting to the only node they now (which
the user specifies).

![P2P Graph Simulator](/assets/images/posts/2021-03-29/p2p-graph-simulator.png "P2P Graph Simulator")

You can see the code in its
[public repo](https://github.com/RiscadoA/p2p-graph-simulator) or try the
simulator on its [page](https://riscadoa.github.io/p2p-graph-simulator/)
(hosted by GitHub Pages). To add a node you must change to creation node
(click the plus button), and then either click on a node to connect the
new one to the already existing one or click somewhere else to create a
free node. You can also change to deletion mode, which allows you to
kill nodes or individual connections. This will be useful to check how
the different algorithms deal with failures.

The next step is implementing different protocols (like Chord, Gossip, etc) and
see the advantages and disadvantages of each one.

<iframe width="560" height="315" src="https://www.youtube.com/embed/2Btg4ow0uno"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>