---
title: "Implementing Serialization for a C++ Game Engine - Part 2"
date: 2021-11-07T00:00:00-00:00
categories:
  - gamedev
tags:
  - cpp
  - serialization
  - cubos
---

After my previous
[post]({% post_url 2021-11-05-cubos-serialization-1 %}),
what remained to be done regarding the serialization system was:
- finding a way for the serializer to known if an object type has a
'(de)serialize' method.
- finding a solution to send optional context to objects which need it to be
(de)serialized.
- providing easy to use solutions for serializing sets of objects with
references to one another (eg.: scene graphs).

Since some objects required context to serialize, and others not, I decided to
classify them into two categories:
- Trivially serializable objects.
- Context serializable objects.

# Trivially Serializable

Trivially serializable objects don't need context to be serialized or
deserialized.

```cpp
struct Fruit {
    std::string name;
    float weight;

    void serialize(Serializer& s) const {
        s.write(name, "name");
        s.write(weight, "weight");
    }

    void deserialize(Deserializer& s) {
        s.read(name);
        s.read(weight);
    }
};
```

The struct `Fruit` is an example of trivially (de)serializable type: its
`serialize` and `deserialize` methods only take a `Serializer`/`Deserializer` as
argument. Serializing it and then deserializing it back should look like:

```cpp
Fruit apple = { "Apple", 0.5 };
serializer.write(apple, "apple");

// ...

Fruit fruit;
deserializer.read(fruit);

// Both objects should be equal
assert(apple.name == fruit.name);
assert(apple.weight == fruit.weight);
```

Writing a dictionary which maps prices to fruits should also be straightforward:

```cpp
std::unordered_map<float, Fruit> fruitsByPrice = {
    { 1.0, { "Apple", 0.5 }},
    { 1.5, { "Banana", 0.6 }},
};

serializer.write(fruitsByPrice, "fruitsByPrice");

// ...

deserializer.read(fruitsByPrice);
```

And the same goes for arrays. But what about types that do require context to
be serialized?

# Context Serializable

Lets say we want to serialize a family tree, where each person
points to its parents. We could define the type `Human`:

```cpp
struct Human {
    Human* father;
    Human* mother;
    std::string name;
    int age;
};
```

We now have a problem: if we just serialized the pointer addresses, when we
deserialized them back they wouldn't mean anything: they wouldn't be pointing
to the new deserialized values, but to the old values which were serialized
previously (which could have possibly been already destroyed).

One way to solve this is, instead of writing the pointers directly, we could
use the indices in the array where the family members are stored. Since this
issue happens so frequently, I decided to implement a `SerializationMap<R, I>`
class which maps `References` to `Identifiers`, and vice-versa. In this case,
a `SerializationMap<Human*, int>` could be used to map addresses to indices.
But using this meant that the serialization methods must receive the map as
context.

```cpp
struct Human {
    ...

    void serialize(Serializer& s, SerializationMap<Human*, int>* map) const {
        s.write(map->getId(this->father), "father");
        s.write(map->getId(this->mother), "mother");
        s.write(this->name, "name");
        s.write(this->age, "age");
    }

    void deserialize(Deserializer& s, SerializationMap<Human*, int> map) {
        int fatherId, motherId;
        s.read(fatherId);
        s.read(motherId);
        s.read(this->name);
        s.read(this->age);
        this->father = map->getRef(fatherId);
        this->father = map->getRef(motherId);
    } 
};
```

This could work, but now just calling `Serializer.write(human);` won't be
enough since it requires context: in this case, a pointer to a 
`SerializationMap<Human*, int>` is required. I solved this by defining two
[concepts](https://en.cppreference.com/w/cpp/language/constraints):
- `TriviallySerializable<T>`: specifies that the type `T` is serializable, without
the need of a context. It requires that `T` has a method
`void serialize(Serializer&) const`.
- `ContextSerializable<T, TCtx>`: specifies that the type `T` is serializable, but
requires a context of type `TCtx`. It requires that `T` has a method
`void serialize(Serializer&, TCtx) const`.

This way, I could define function overloads in the `Serializer` for
`TriviallySerializable` types, and for `ContextSerializable` types.
I did the same for deserialization: I also defined the concepts
`TriviallyDeserializable` and `ContextDeserializable`.

With this done, serializing a `Human` becomes as simple as passing the map to
the write method:

```cpp
SerializationMap<Human*, int> sMap;
Human human;

// ...

serializer->write(human, &sMap, "human");
```

Here is how serializing and deserializing a whole family tree would look like:

```cpp
Human family[4]; 
// ... init family members

// Add reference <-> id mappings
SerializationMap<Human*, int> sMap;
sMap.add(nullptr, -1); // Map nullptr to index -1
for (int i = 0; i < 4; ++i)
    sMap.add(&family[i], i);

// Serialize entire family
serializer.write(family, 4, &sMap, "family");
```

```cpp
Human family[4];

// Add reference <-> id mappings
SerializationMap<Human*, int> sMap;
sMap.add(nullptr, -1); // Map nullptr to index -1
for (int i = 0; i < 4; ++i)
    sMap.add(&family[i], i);

// Deserialize entire family
deserializer.read(family, 4, &sMap);
```

The same technique could be applied to serializing and deserializing a scene
graph, for example. With this done, we now have a system which is easy to
extend, not overcomplicated and which allows us to serialize to multiple formats
with minimal effort. Concrete (de)serializer types (eg: `JSONSerializer`)
haven't been implemented yet, but that task isn't assigned to me. This system
will be used to (de)serialize engine and game settings, components, scene graphs
and other types. 
