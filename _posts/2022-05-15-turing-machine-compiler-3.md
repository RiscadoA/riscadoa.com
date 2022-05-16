---
title: "Compiling a Functional Language to Turing Machines - Part 3"
date: 2022-05-15T00:00:00-00:00
categories:
  - compilers
tags:
  - rust
---

Since the last post I ended up simplifying the type and ownership checking
greatly. One of the changed was to make the following transformations to the
AST before running the type annotator (more on this later):
- replace let bindings with applications.
- remove unused variables.
- deduplicate variable ids.

After annotating AST with the types for each expression, the next step is to
make it as easy as posible to generate Turing machines from the AAST.

## The goal

First, we need to determine how exactly the resulting AST should look like.
We can think of a `tape -> tape` function as a Turing machine. Simplifying the
AST so that only `tape -> tape` function applications are left (and builtin
functions like `set`) should make the generating process a lot
easier.

The one other type of expression we need to worry about are `match`
expressions. Ideally, the resulting `match` expressions should all be of the
form `match get t { pat > exp, ... }` where `t` is a tape, all `exp`s are tapes
and all `pat`s are constant: that is, they should be comprised of only `union`
and `symbol` expressions (no function applications, ids, etc). There shouldn't
be any captured variables in the patterns too. Since all matches end up taking
the form `match get t ...`, we can simplify them to `match t ...`.

This way, a `match` expression represents the possible transitions from a
state, which, once again, should make it straightforward to generating
machines.

## How to get there

Since some of the simplifications can be done without type annotations, while
others require them, we will do this in two stages: one before annotation and
one after annotation.

### Applying transformations

In order to simplify transforming the AST, I added the `transform` method to
the data structure which takes a function, `f`, recurses into the
subexpressions and then calls `f` on the resulting expression. This way, if `f`
is a function which simplifies the AST, we can implement it assuming that
subexpressions are already simplified.

### Before annotation

#### Let bindings

The first step we will do is to get rid of let bindings. How exactly? Well, let
expressions are just syntactic sugar for function applications. For example,
the program `let x = a, y = b, in y` is equivalent to `(x: (y: y) b) a`.
Applying this simplification is trivial and can be done in a single pass. It
also frees us from having to deal with let expressions in later operations,
such as the type checking.

#### Removing `any` patterns

Removing `any` patterns early means that all of the following transformations
don't need to handle them anymore. First, we collect every symbol used in the
program, and then, we just replace every `any` pattern with a `union` pattern
with all of those symbols. To exemplify, `match s { '0' > '1', any > s, }`
becomes `match s { '0' > '1', '0' | '1' > s,}`. The second pattern repeats
`'0'`, but it isn't a problem since we can remove duplicate patterns later on.
We can't remove the function applications right now because the patterns may
contain function applications which haven't been removed yet.

#### Trivial applications

There are three functions which are trivial to apply - identity functions,
application functions and unused argument functions:
- the identity function application `(x: x) y` should be replaced with `y`;
- the application function application `(x: f x) y` should be replaced with `f y`;
- the unused argument function application `(x: f) y` should be replaced with `f`;
Since these functions can come up again later, we may need to rerun this
transformation.

#### Combining the transformations

With the transformations defined, we just need to apply them in the correct
order, using the `transform` method. Removing the let bindings, becomes, for
example:
```rust
  let ast = ast.transform(&simplifier::let_remover::remove_lets);
```
Where the `remove_lets` function is a function which receives an expression and
returns it, with its let bindings removed, if it was a let expression.

### After annotation

#### Removing gets

Since `match get t` and `match t` should become the same thing, we can just
replace every `get t` with a match expression of the form
`match t { '0' > '0', ... }`. This way, `set (get t) t` would become, for
example: `set (match t { '0' > '0', ... } t)`. In a later
transformation, we should move the `match` expression to the right place.

#### Moving matches

Matches should always be at the root of `tape -> tape` function expressions.
The previous example, `set (match t { '0' > '0', ... } t)`, should then become
`match t { '0' > set '0' t, ... }`. The transformation itself is:
- if the current expression is an application of the form
`(match e { p > f, ... }) arg`, it should be replaced with `match e { p > f arg, ... }`;
- if the current expression is an application of the form
`f (match e { p > arg, ... })`, it should be replaced with `match e { p > f arg, ... }`;

#### Applications

As I mentioned earlier, one of the goals is to have an AST with only
`tape -> tape` function applications. To get there, we need to apply every
non-`tape -> tape` function application in the AST. Exemplifying,
`(s: t: set s t) '0'` becomes `t: set '0' t`. Since after applying the function
the whole expression changes (`s` is replaced by `'0'`, in this case), we need
to call transform again on the subexpressions.

#### Removing captured variables

Match arms may capture the variables which match their patterns. This is done
by using the `@` operator, for example: `match s { x @ '0' | '1' > f x, }`. We
can simplify this by replacing the arm with multiple arms, one for each symbol
which may be captured, and adding a function application to each expression.
Then, the previous example becomes
`match s { '0' > (x: f x) '0', '1' > (x: f x) '1', }`.

Since the patterns may contain function applications, we can only apply this
transformation after simplifying each pattern into `union` and `symbol`
expressions. Since `transform` recurses first, we have the guarantee that the
patterns are already simplified, and are just `union` and `symbol` expressions.

#### Removing constant matches

Match expressions which take a `symbol` expression as input (therefore constant
and already known at compile time) can be evaluated at compile time:
`match 'x' { 'x' > a, 'y' > b,}` becomes `a`. T

#### Merging matches which match another match

Match expressions which take another match expression as input can be merged.
For example,
`match match x { '0' > '1', '1' > '0', } { '1' > 'a', '0' > 'b', }`
is equivalent to `match x { '0' > 'a', '1' > 'b', }`, so we just need to find
for each arm in the outer match an arm in the inner match whose expression
matches the outer arm's pattern.

#### Merging arms with the same expression

If there are two match arms with the same expression, we can merge them into
a new arm whose pattern is the union of the two patterns. For example,
`match x { '0' > 'a', '1' > 'a', }` becomes `match x { '0' | '1' > 'a', }`.

#### Deduplicating match patterns

If there are multiple arms which match the same pattern, we can remove the
extra symbols from the patterns, or if the patterns become empty, remove the
arms entirely. For example,
`match x { '0' > 'a', '0' | '1' > 'b', '1' > 'c', }` becomes
`match x { '0' > 'a', '1' > 'b', }`.

#### Combining the transformations

Once again, its just a matter of applying the transformations in the correct
order, and we get the final AAST.

## Whats next?

With the AST simplified, the only remaining task is to write the turing machine
generator. I will write about it in the next
[post]({% post_url 2022-05-16-turing-machine-compiler-4 %})..