---
title: "Compiling a Functional Language to Turing Machines - Part 1"
date: 2022-04-08T00:00:00-00:00
categories:
  - compilers
tags:
  - rust
---

This semester I have been studying Computer Theory, and I had the idea of
writing a compiler which generates Turing Machines. I started by designing the
language. At first I explored compiling from an imperative language similar to
Rust or C, but then I realized that doing it in a functional language similar
to Nix would be much easier (and cooler).

# Language Design

The language aims to be as simple as possible. The entire program consists of a
single anonymous function.

## Types

I decided that a strongly typed language with only 4 types would be a good
starting point:
- `symbol`: represents a possible symbol of a cell in the turing
machine's tape.
- `union`: represents a union of symbols.
- `tape`: represents the tape and head of the turing machine. Tapes are
restricted to ownership rules.
- `function { arg, ret }`: represents a function which takes the type `arg` and
returns the type `ret`.

## Expressions

There are seven possible types of expressions:
- `id`: a variable, bound by a function argument or by a let expression.
- `'A'`: a symbol.
- `exp1 | exp2`: a union of symbols, which can be used in match patterns.
Assumes that both `exp1` and `exp2` are symbols or unions.
- `any`: a special union which matches any symbol.
- `match exp { pat > exp, ... }`: matches a symbol against a list of patterns,
and returns the first expression found.
- `let id1 = exp1, ..., id2 = exp2, in body`: binds multiple expressions to
identifiers which will then be replaced
by the expressions in the main expression, which is then returned.
Let expressions were only added to the language to make it more readable, and
recursive definitions are not supported.
- `id: exp`: a lambda expression function which returns `exp`, with the
variable `id` bound to it.
- `f exp`: applies the function `f` to the expression `exp` (left-associative).

The root expression of the program must evaluate to a `tape -> tape` function,
which represents the operation the machine will perform on the tape.

### Match Patterns

Match patterns are unions of symbols, and may optionally capture the variable
matched by prepending the pattern with `id @`. For example, the following match
expression would produce `'A'`:

```
match 'A' {
  id @ 'A' | 'B' > id,
  'C' > 'D',
}
```

## Built-in Functions

I added five built-in functions which are essential to the language:
- `set s t`: writes the symbol `s` to the cell at the head of the tape `t`,
consuming the tape and returning a new one. (`symbol -> tape -> tape`)
- `get t`: returns the symbol at the cell at the head of the tape `t`. (`&tape -> symbol`)
- `next t`: moves the head of the tape `t` to the right, consuming the tape and
returning a new one. (`tape -> tape`)
- `prev t`: moves the head of the tape `t` to the left, consuming the tape and
returning a new one. (`tape -> tape`)
- `Y f`: applies the Y-combinator to the function `f`, with the signature
`(tape -> tape) -> tape -> tape`, and returns a function with the the signature
`tape -> tape`. This function is essential to implement recursion in this
language.

### Recursion

Since let expressions forbid recursive definitions, the built-in Y-combinator
function `Y` is used to implement recursion. The following example should
produce a turing machine which moves the head of the tape to the right forever.

```
Y f: t: f (next t)
```

If recursive let bindings were allowed, the resulting function would be
equivalent to the following:

```
let loop = t: loop (next t), in loop
```

## Tape Ownership

I had to add an ownership rule to the language to ensure that, for example the
following code is disallowed:

```
t: match get (next (set 'A' t)) {
  'A' > set 'A' t,
  'B' > set 'B' t,
}
```

If there were no ownership rules, the above code would be legal. Generating a
turing machine from this code would be very difficult, because the tape `t`
used in the `match` arm expressions refers to the old tape, which was edited
in the `get` expression argument. What this means is that the argument of a
`get` application must not consume the tape. An alternative, correct version of
the program above would be:

```
t: (t: match get t {
  'A' > set 'A' t,
  'B' > set 'B' t,
}) (next (set 'A' t))
```

The rule is that a tape must only be consumed once. Since the root function of
any program receives a tape and must return a tape, this rule means that you
can't consume a tape and then forget the new tape (e.g.: `t: get (next t)`, the
tape is consumed by the `next` function).

## Imports

A programming language without the ability to split code between files would be
very cumbersome to work with, so I added the `import` keyword to the language.
The functionality is very simple: it just replaces the import expression with
the contents of the file specified by the import expression:

```
# defs.tmc (in case you're wondering, .tmc stands for turing machine compiler)
let
  zero = '0',
  one = '1',
in
```

```
# main.tmc
import 'defs.tmc'
let
  flip = s: match s {
    zero > one,
    one > zero,
  },
in
  t: set (flip (get t)) t,
```

## Example Programs

```
# Prints the symbol 'A' at the head of the tape, and moves the head to the
# right.
t: next (set 'A' t)
```

```
# Until an empty cell is found, moves the head to the right.
Y f: t: match get t {
  '0' | '1' > f (next t),
  ' ' > t,
}
```

```
let
  # A function which moves the head right until it finds the symbol passed as
  # argument.
  find = s: Y f: t: match get t {
    s   > t,
    any > f (next t),
  },
in
  # Moves the head right until it finds the symbol 'A'.
  t: find 'A' t
```

# What's next?

After I had a more or less stable language, I started working on the compiler
itself. I chose Rust to write it in, because I've been wanting to work on a
Rust project for a while, and also because Rust enums and match expressions
make it very pleasant to write compilers in.

In the next [post]({% post_url 2022-04-25-turing-machine-compiler-2 %}) I'll talk the issues I faced and how I implemented the
compiler.
