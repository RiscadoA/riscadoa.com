---
title: "Gravity Simulator"
excerpt: "A 2D gravity simulator that runs on the browser, used to visualize attraction between multiple bodies."
header:
  image: /assets/images/gravity-simulator.png
  teaser: /assets/images/gravity-simulator.png
sidebar:
  - title: "Role"
    text: "Author"
---

On a break between university terms, I decided to start a toy project in
TypeScript, WebGL, HTML and CSS. I had already played around with gravity
simulations when I was younger, but it was a long time ago and I felt like
revisiting that topic, so I started working on this project.

You can see the code in its
[public repo](https://github.com/RiscadoA/gravity-simulator) or try the
simulator on its [page](https://riscadoa.github.io/gravity-simulator/)
(hosted by GitHub Pages).

<iframe width="560" height="315" src="https://www.youtube.com/embed/Qj-lEw_BN10"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## How to use

### Presets

In the top left portion of the screen, you can find the 'reset' and 'presets'
buttons. The reset button resets the world to its original state. The presets
button opens a form which allows you to choose from multiple initial world
states. There is, for example, a 'Simple star system' preset which generates
a star orbited by a large amount of small bodies. There are also more complex
presets such as 'Custom star system', which allow you to configure the
distributions of the bodies, the mass of the star and other parameters.

### Tools

You can add new bodies by activating the placement mode (click the plus sign).
In this mode you can place bodies by clicking on the background. The mass of
the new body is set through the slider that appears next to the buttons. If you
keep the mouse button pressed and drag the mouse, you will see an arrow. This
arrow represents the initial velocity of the body.

Bodies may also be removed by activating the removal mode (click the minus
sign) and clicking on them. There's also a body mover mode (hand button), which
allows bodies to be moved by dragging them.

The view can be moved through the camera mover mode (click the arrows button).
You can also zoom in/out through the buttons on the top right section of the
screen or by simply scrolling the mouse wheel. Bodies can be followed
automatically through the follow tool (eye button). If you click on a body with
this tool activated, it will be followed by the view.

Body trails can be shown by activating the pen toggle button on the top right 
of the screen.

## Development

Since one of the goals of this project was to learn a bit of WebGL and apply
some of the linear algebra knowledge I got from my university courses, I
implemented a simple 2D renderer with my own vector and matrix
classes/functions.

One other goal was to improve my CSS skills, so I played a lot with designing
the UI. I used [Less](https://lesscss.org/) to reduce code duplication. The
GitHub page was generated with [Parcel](https://parceljs.org/).
