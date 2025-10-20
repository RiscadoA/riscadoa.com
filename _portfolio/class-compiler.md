---
title: "CLASS Compiler"
excerpt: "My master thesis, where we developed the first compilation scheme for a session-based linear language."
header:
  image: /assets/images/class.png
  teaser: /assets/images/class.png
sidebar:
  - title: "Role"
    text: "Author"
---

In my master thesis we performed a comprehensive study of compilation techniques for high-level linear-typed (multiparadigm) languages, focusing on CLASS, a proof-of-concept general purpose programming language based on linear/session types that supports many realistic concurrent programming idioms, while guaranteeing memory safety and absence of deadlocks by typing.

While the principles and meta-theory behind linear logic based session languages are well known, associated implementation techniques for such languages, in particular compilation to native code, are still poorly understood. In this work, we leveraged the sequential execution strategy of the Linear Session Abstract Machine (SAM) to propose a novel multi-stage compilation scheme from CLASS to IR to C for a specially designed intermediate language IR, implemented a prototype compiler based on it, and validated it in terms of coverage, correctness and performance.

Moreover, the developed compiler covers all of CLASS linear logic primitives, including affine sessions and shared state. The performance of the compiled programs was compared with the original CLASS interpreter, the SAM interpreter, and with equivalent programs written in Haskell. The results showed that the compiled programs were orders of magnitude faster than the interpreted ones, and, in some cases, outperformed equivalent Haskell programs compiled with GHC. To the best of our knowledge this is the first work demonstrating the efficient compilation of linear session basic languages to machine code.

The final version of the thesis still hasn't been officially published but you can read the current version [here]({{ "/assets/thesis.pdf" | relative_url }}). The source code of the compiler is hosted on a [GitHub repository](https://github.com/RiscadoA/class).
