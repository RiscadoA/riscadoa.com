---
title: "Turing Machine Compiler"
excerpt: "A compiler which turns a functional language into turing machines."
header:
  image: /assets/images/turing-machine-compiler.png
  teaser: /assets/images/turing-machine-compiler.png
sidebar:
  - title: "Date"
    text: "2022"
  - title: "Role"
    text: "Author"
  - title: "Language"
    text: "Rust"
---

In this project I wrote a compiler in Rust which turns a functional language
inspired by [Nix](https://nixos.org/) into turing machines. I started this
project because I wanted to learn Rust properly and also because I had been
studying Computer Theory for my degree. You can read more about the project
and the development process on the articles I posted about it here:
- Introduction and language design: [post]({% post_url 2022-04-08-turing-machine-compiler-1 %})
- Lexer, parser and annotater: [post]({% post_url 2022-04-25-turing-machine-compiler-2 %})
- Simplifier: [post]({% post_url 2022-05-15-turing-machine-compiler-3 %})
- Generator and showcase: [post]({% post_url 2022-05-16-turing-machine-compiler-4 %})

You can also see the source code and build the compiler in the project's
github [repository](https://github.com/RiscadoA/tm-compiler).
