---
title: "Compiling a Functional Language to Turing Machines - Part 4"
date: 2022-05-16T00:00:00-00:00
categories:
  - compilers
tags:
  - rust
---

With the AAST simplified, the only step remaining is generating the actual
turing machine. The first step was to create a new data structure for holding
the information about the machine. I decided to just store an array of
transitions and represent states with integers, where:
- the initial state is 0;
- the accepting state is 1;
- the rejecting state is 2;

## Generating the machine

For generating the machine itself, I split the program into the following
parts:
- `generate_function(exp, in, out)`: takes an in and out state and generates
the necessary transitions and states for computing the `tape -> tape` function
`exp`.
- `generate_from_tape(exp, in, out, tape_id)`: same as above but `exp` is an
expression which evaluates to `tape`, where the variable `tape_id` is a `tape`.
- `generate_application(exp, in, out, tape_id)`: a special case of the previous
function for applications which return `tape`s.
- `generate_match(exp, in, out, tape_id)`: a special case for `match`
expressions.
- `generate_set(...)`, `generate_move(...)`, `generate_halt(...)`: special
cases of the `generate_function` function for handling the builtin functions
`set`, `next`, `prev`, `accept` and `reject`.
- `generate_y(...)`: a special case of the `generate_function` which handles
the `Y` combinator builtin function and thus allows recursion, creating loops
in the machine.

Since the simplified AST must evaluate to a `tape -> tape` function, we just
need to call `generate_function` on the root expression to generate the entire
machine.

## Simplifying the generated machine

Unfortunately, the generated machine contains lots of redundant states and
transitons. For example, the sample `flip_single.tmc`, which flips a single
bit in the input, which simplified becomes
`t: match t { 0 > set 1 t, 1 > set 0 t }`, outputs the machine:
```
0 * * * 1
1 0 0 * 2
1 _ _ * 4
1 1 1 * 5
2 * * * 3
3 * 1 * halt-accept
5 * * * 6
6 * 0 * halt-accept
```

Where `0` is the initial state, and the first line states that there is a
transition from `0` to `1`, for any (`*`) symbol, which doesn't write (`*`) and
doesn't move (`*`). If theres no change whatsoever when changing from the
state `0` to `1`, we should just merge them. Adding this step and some other
minor simplifications, we can get the following simplified machine:

```
0 0 1 * halt-accept
0 1 0 * halt-accept
```

Which is much smaller than the original machine and is easier to understand.
Once again, `0` is the initial state. If the current symbol is `0`, `1` is
written and the tape isn't moved, and the state changes to accept. Otherwise,
if it `1`, `0` is written, just like intended.

## Standard library

With the compiler finished, I decided to write a tiny standard library (which
can be imported using `import 'std/...`). The following standard library
imports are available:
- `std/bool.tmc`: defines the `true` and `false` values, boolean logic
operators such as `not` and `and`, and also the functions `is` and `isnt`,
which take a `union` pattern and a symbol, and return true if and only if the
symbol is in the pattern, or isn't in the pattern, respectively.
- `std/iter.tmc`: defines the `iter` function which simplifies the process of
iterating over the tape. It takes an end condition (`symbol -> symbol`, which
receives the current symbol and should return either `true` or `false`) and a
step function (`tape -> tape`) which is called for every iterating step. One
example usage would be for example the function `iter (is '0') next`, which
goes right until it finds a `0` symbol.
- `std/check.tmc`: defines the `check` function which standardizes the way to
do complex checks on the tape. It takes a `tape -> tape` function which is
called at the start of the check, a `symbol -> symbol` function which is used
to determine if the check is successful, and two `tape -> tape` functions which
are called, one if the check is successful, and another if it isn't. It also
defines `check_all` which allows us to do a simple check on all symbols in a
section of the tape.
- `std/math.tmc`: defines the `inc` and `dec` functions, which increment and
decrement a binary number in the tape.

## Sample programs

I also wrote a few sample programs. One of the simplest but still interesting
is the `flip.tmc` program, which takes a binary integer as input and flips
every bit. This program is split into two files, `flip.tmc` and `flip_lib.tmc`.

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
# flip.tmc
# Flips all bits in the given binary number.
# Alphabet used: '0' | '1'

import 'flip_lib.tmc'
Y f: t: match get t {
    x @ '0' | '1' > f (next (set (flip x) t)),
    any           > t,
}
```

This works the following way: while the current symbol is either `0` or `1`,
set the current symbol to the opposite, and move the tape to the right. Then,
repeat the process. If the current symbol is anything else, we just return the
tape as it is. Running `tmc ./samples/flip.tmc -a 0 1` will output the
following machine:

```
0 0 1 r 0
0 1 0 r 0
0 _ _ * halt-accept
```

Which does exactly what we wanted. The most complex sample is `add.tmc`. It
takes two binary integers separated by a `+` and adds them together. The
following is the sample program code:

```
# Adds two binary numbers from the input, separated by a +.
# Alphabet used: '0' | '1' | '+'

import 'std/check.tmc'
let
    # Increments the first number by one.
    inc = t:
        let t = prev (find '+' next t), in
        let t = iter (is ('0' | '')) (t: prev (set '0' t)) t, in
        let t = set '1' t, in
        next (find '' prev t),

    # Decrements the second number by one.
    dec = t:
        let t = prev (find '' next t), in
        let t = iter (is '1') (t: prev (set '1' t)) t, in
        let t = set '0' t, in
        next (find '' prev t),

    # Checks if the second number contains only 0.
    check_zero = e1: e2: t: check_all
        (is '0') next (is '')
        (t: e1 (next (find '' prev (prev t))))
        (t: e2 (next (find '' prev (prev t))))
        (next (find '+' next t)),

    # Removes the + and the second number, and then positions the cursor at the start of the first number.
    finish = t:
        let t = find '' next t, in
        let t = iter (is '+') (t: prev (set '' t)) t, in
        let t = prev (set '' t), in
        next (find '' prev t),
in
    Y f: check_zero
        finish
        (t: f (inc (dec t)))
```

The main logic behind the program, which you can see in the last three lines,
is:
- check if the second number is zero
  - if it is, delete the `+` and the second number, and position the cursor at
  the start of the first number.
  - otherwise, decrement the second number, and increment the first, and then
  repeat.

Running `tmc ./samples/add.tmc -a 0 1 +` will output a pretty large machine,
but when you run it in an emulator like
[this one](https://morphett.info/turing/turing.html), it will output the
correct answer.

Its also possible to create classifier machines with `tmc`. The sample
`is_binary.tmc` exemplifies this. It takes a string as input and checks if it
is a binary number.

```
# Checks if all symbols on the tape right until an empty symbol is found are binary digits.
# Alphabet used: '0' | '1'

import 'std/check.tmc'
check_all (is ('0' | '1')) next (is '')
    accept
    reject
```

This sample uses the `std/check.tmc` library. It checks if all symbols until
`is ''` evaluates to `true` (i.e. until an empty symbol is found) fulfill the
condition `is ('0' | '1')`. If it does, it calls `accept`, otherwise it calls
`reject`. This way, if any non-binary symbol is found, the machine rejects the
input, otherwise it accepts it. Running `tmc ./samples/is_binary.tmc -a 0 1 x`
will output the following machine:

```
0 a a * 1
0 _ _ * 1
0 0 0 * 2
0 1 1 * 2
1 _ _ * halt-accept
1 0 0 * 3
1 1 1 * 3
1 a a * 3
2 * * r 0
3 _ _ * halt-reject
3 0 0 * 4
3 1 1 * 4
3 a a * 4
4 * * r 3
```

This machine isn't easy to understand, but you can test it by running it in the
[emulator](https://morphett.info/turing/turing.html) I referenced above.

## Wrapping up

There is still room for improvement. The resulting machines could still be
simplified further, I could also add more functions to the library and create
more complex samples, but I think that the project has reached a state where
it is okay to leave it as it is. Since the compiler is finished and usable,
I'm going to move on to other projects.

It ended up being a great learning experience, since this was my first real
project in Rust and now I don't feel limited anymore by the language while
programming (I don't have to fight the borrow checker anymore!). I also learnt
a lot about compilers and lambda calculus, which is something I had interest in
for some time.