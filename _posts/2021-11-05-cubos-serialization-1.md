---
title: "Implementing Serialization for a C++ Game Engine - Part 1"
date: 2021-11-05T00:00:00-00:00
categories:
  - gamedev
tags:
  - cpp
  - serialization
  - cubos
---

Lately I've been designing and writting a serialization system for the
[CUBOS.](https://github.com/GameDevTecnico/cubos) game engine. I had the
following goals in mind:
- keep it simple: the goal isn't to implement deep serialization, but to
have a 'predictable' (de)serializer which would be easy to use but not too hard
to develop.
- make it as generic as possible: serializing to raw binary data, to JSON or to
YAML should be the same and require as little extra effort as possible.
- make it flexible: objects may require extra context to be (de)serialized, and
providing this context should be easy.
- stream agnostic: the (de)serializer shouldn't care about where the data is
coming from/going to.

# Streams

Making the (de)serializer stream agnostic meant that I needed an abstract stream
class, which provided the interface required for reading and writing data. I
considered using the C++ STL streams, but I wanted to implement my own streams
later on (compressed streams for example) and the STL is too hard/obscure to
extend. This plus the fact that implementing a tiny streams library seemed fun
pushed me down the *I'll do it myself* route.

So, I studied some stream libraries (including STL) and decided that the `Stream`
class should provide the following abstract methods:

- `read(data, size)`: reads data from the stream, and returns the number of
bytes actually read.
- `write(data, size)`: writes data to the stream, and returns the number of
bytes actually written.
- `tell()`: returns the current position in the stream.
- `seek(offset, origin)`: seeks to a position in the stream.
- `eof()`: used to check if there's no more data to read from the stream.
- `peek()`: used to read the next byte of the stream without removing it.

Although these methods are technically sufficient and you can perfectly
implement a binary serializer with them, any kind of text processing required
in, for example, a JSON serializer, would be very painful to implement. To solve
this, I wrote some utility methods in the `Stream` class such as `print`, `printf`,
`parse` and `readUntil`, which called the other abstract methods.

I also wrote two implementations of this `Stream` class: `StdStream` and
`BufferStream`. The `StdStream` is just a wrapper around a `FILE*` from
`stdio.h`, which allows me to write to files and, for example, `stdout`, with my
streams. The `BufferStream` is used to write data to/read data from a buffer.

# Serialization

Now that I had streams ready to be used, delving into actual serialization was
next. I decided to split the serialization functionality into two classes:
`Serializer` and `Deserializer`. It doesn't make sense to serialize and
deserialize from the same stream at the same time, and the classes would become
too large. Both the `Serializer` and the `Deserializer` are associated to a
stream when constructed, and write to/read from that stream exclusively.

The `Serializer` class contains abstract methods for writing trivial types (eg:
`uint8_t`, `double`), and also strings. The same goes for the `Deserializer`
but for reading instead of writting.

This seems okay, but there's one problem: this would be sufficient for
sequential binary data serialization, but, how would the values be serialized
to, for example, JSON?

In order to solve this, I added a `name` argument to every `write` function on
the `Serializer` class. This way, I could set names for the fields while
serializing. How would you differentiate between diffent objects then? I decided
to add a `beginObject(name)` and a `endObject()`, both abstract methods. This
way, the `Serializer` knows how to group the values being written into objects.
I also added a `beginObject()` and `endObject()` to the `Deserializer`, for
consistency.

Still, this approach wasn't perfect: what if I didn't know the number of values
I would be serializing/deserializing? This would be a problem while trying to
deserialize arrays and dictionaries. My solution was to add the
`beginArray(length, name)`, `endArray()`, `beginDictionary(length, name)` and
`endDictionary()` abstract methods to the `Serializer`. I added the equivalent
methods to the `Deserializer`, but, instead of passing the length, the length
of current array/dictionary is returned. The dictionary 'mode' assumes that
values will be written in 'key value' order.

These new methods allowed me to implement methods such as `write(array, length)`,
`write(vector)`, `write(map)` and the equivalent deserialization methods. Here
is an example of how you could use the serializer and deserializer as it is:

```cpp
Serializer* s = ...;

s->beginObject("npc1");

s->write("John", "name");
s->write(43, "age");
s->write(75.6, "weight");

s->beginDictionary(2, "inventory");
s->write("apple");
s->write(3);
s->write("sword");
s->write(1);
s->endDictionary();

// If you have a std::unordered_map, you also just
// write it directly:
// s->write(map, "inventory");

s->endObject();
```

```cpp
Deserializer* s = ...;

std::string name;
int age;
double weight;
std::unordered_map<std::string, int> inventory;

s->beginObject();
s->read(name);
s->read(age);
s->read(weight);
s->read(inventory);
s->endObject();
```

# Whats next?

In the next post I will write about how I implemented the serialization methods
on serializable/deserializable types, and how context is passed to them. We
still need to provide an actual Serializer/Deserializer implementation, since
right now we have only still defined abstract classes.
