---
title: "Compiling a Functional Language to Turing Machines - Part 2"
date: 2022-04-25T00:00:00-00:00
categories:
  - compilers
tags:
  - rust
---

The first step I took on the compiler was to write the Extended Backus-Naur
Form (EBNF) grammar for the language. You can check it out
[here](https://github.com/RiscadoA/tm-compiler/blob/main/docs/syntax.ebnf).

After that, I wrote a simple lexer which transforms the input source code into
a list of tokens, handling imports on the way. Tokens are represented with a
Rust union. The lexer also outputs a `TokenLoc` struct along with each token
which stores the location of the token in the source code, in order to be able
to output fancy error messages.

## Parsing

The next step was writing a parser which takes the list of tokens and builds an
Abstract Syntax Tree (AST). Each node in this tree represents an expression.
For example, a `function` node represents a `x: exp` expression, which contains
a argument ID and a child expression where the argument ID is bound. One of the
requisites I wanted to have was a way to easily annotate the AST. I did this by
adding a generic type parameter to the `Exp` struct (which represents a node),
and adding an annotation field to this struct.

So, the task of the parser is to produce an AST annotated with the `TokenLoc`
structs of the tokens consumed to parse the expressions. The following is an
example of the outputs of the lexer & parser, from a simple two files input: 

```
# flip_lib.tmc
let
    flip = x: match x {
        '0' > '1',
        '1' > '0',
    },
in
```

```
# flip_single.tmc
import 'flip_lib.tmc'
t: set (flip (get t)) t
```

This program flips a single bit at the head of the tape. The output of the
lexer is:

```
----------- Tokens -----------
let flip = x : match x { '0' > '1' , '1' > '0' , } , in t : set ( flip ( get t ) ) t
```

This list of tokens is then fed to the parser which outputs the following AST
(the $ represent function applications, and annotations are ommited for simplicity):

```
------------ AST -------------
let
. flip =
. . x:
. . . match
. . . . x
. . . . _ @
. . . . . '0'
. . . . . '1'
. . . . _ @
. . . . . '1'
. . . . . '0'
in
. t:
. . $
. . . $
. . . . set
. . . . $
. . . . . flip
. . . . . $
. . . . . . get
. . . . . . t
. . . t
```

## Types

The next step for the compiler was to define the types of the expressions, or,
in other words, annotate the AST with the types of the expressions. The
difficult part of this is that the types of the expressions are not explicitly
given in the grammar, but are inferred from the context. This is done in the
following steps:
- traverse the AST and annotate each expression with a placeholder 'unresolved'
type.
- for each expression, store the casts needed to make sure the program is
type-correct (e.g.: `get t` causes `t` to be casted to `&tape`).
- resolve the unresolved types by analyzing the type graph generated from the
casts.
- finally, replace the placeholder types with the actual resolved types.

The third step was the most difficult, because of tape ownership and choosing
whether to resolve to `union` or `symbol`. I did this by hard-coding some
simple cases. For example, if there is an unresolved type which, which is
casted to from `&tape`, then it is resolved to `&tape`, since if the tape isn't
owned it can't be magically owned again. However, if the type is casted to from
`tape`, it can't be resolved to `tape` since it could also be resolved to
`&tape`. However, if we know that this type is casted to `tape`, then since
`&tape` doesn't cast to `tape` we can resolve it to `tape`. A similar logic
follows for the `union` and `symbol` types.

For simplicity, the first step in the type graph analysis is removing every
`function` type cast and switching it to simpler 'atomic' casts. For example,
a cast from `tape -> unresolved1` to `unresolved2 -> tape` can be split into 4
casts: `tape` to `unresolved2`, `unresolved2` to `tape`, `unresolved1` to `tape`
and `tape` to `unresolved1`.

The final result of the whole process is the following annotated AST:

```
-------- Annotated AST--------
let ((tape -> tape))
. flip =
. . x: ((symbol -> symbol))
. . . match (symbol)
. . . . x (symbol)
. . . . _ @
. . . . . '0' (symbol)
. . . . . '1' (symbol)
. . . . _ @
. . . . . '1' (symbol)
. . . . . '0' (symbol)
in
. t: ((tape -> tape))
. . $ (tape)
. . . $ ((tape -> tape))
. . . . set ((symbol -> (tape -> tape)))
. . . . $ (symbol)
. . . . . flip ((symbol -> symbol))
. . . . . $ (symbol)
. . . . . . get ((&tape -> symbol))
. . . . . . t (&tape)
. . . t (tape)
```

## Borrow checking

The last validating step of the compiler is enforcing the tape ownership rules.
With the types resolved, this becomes easy: its enough to check if there is a
function application which should receive `&tape` and instead receives `tape`.
One example program which breaks this rule is `t: set (get (next t)) t`, which
produces the following AAST:

```
-------- Annotated AST--------
t: ((tape -> tape))
. $ (tape)
. . $ ((tape -> tape))
. . . set ((symbol -> (tape -> tape)))
. . . $ (symbol)
. . . . get ((&tape -> symbol))
. . . . $ (tape)
. . . . . next ((tape -> tape))
. . . . . t (tape)
. . t (tape)
```

The faulty expression is `get (next t)`. `get` receives `&tape`, but `next`
returns `tape`. With the borrow checker on, compiling this program will fail
with the error:
> annotator error: Application of &tape function at line 1, column 9 received owned tape which violates ownership rules

## Whats next?

Now that we have a type-annotated AST and know that the program is sound, the
next step is to simplify it as much as possible to make it easier to generate
turing machines. I will write about this process in the next
[post]({% post_url 2022-05-15-turing-machine-compiler-3 %}).