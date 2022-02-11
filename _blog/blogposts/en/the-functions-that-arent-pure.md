---
title: The Functions That Aren't Pure
description: "Learn about the functional programming paradigm, pure functions vs
  impure functions, obvious and sneaky side effects of impure functions.. "
thumbnail: /content/blog/the-functions-that-arent-pure/functional-programing_1200x600.png
author: igor-wojda
published: true
published_at: 2021-06-29T11:31:08.524Z
updated_at: 2021-06-18T07:37:41.532Z
category: inspiration
tags:
  - functionalprogramming
  - purefunction
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
More developers become aware of the functional programming paradigm by the day. This paradigm promises bug-free, efficient code because pure functions are easier to test and parallelize. 

In practice, fully-fledged functional applications are still an abstract thing. However, certain concepts from the functional programming paradigm are more and more often applied to non-functional languages. Also, this "partially functional" approach helps solve many common "problems" in a better way.  

Today we will take a closer look at one of such functional concepts - pure/impure functions.

> NOTE: We will use Kotlin based pseudo code to define our functions, keeping the examples basic so that they are more straightforward to follow.

## Pure Functions

The **pure function** is a function that does not have any side effects - in other words, this function should not retrieve and modify any values other than values passed as params.  This way, each function call with the same arguments will always result in the same output (returned value). Let's start by defining a pure function first:

```
fun max(a: Int, b: Int) {
if (a > b) 
    return a
else
    return b	
}
```

The `max` function takes two arguments, two numbers, and returns the largest of them. Notice that this function does not access or modify any values from outside function scope, so it is a _pure function_.  We can be sure that calling this function with arguments `2` and `7` will ALWAYS return `7`.

To better understand this concept, let's take a closer look at the other side of the coin - the various ways of breaking function purity.

## Impure Functions

An **impure function** is a function that has side effects - it is modifying or accessing values from outside function scope (outside of function body). 

### Quite Obvious Side Effects

The simplest example is a function that modifies an external property to store a state.

```
val loalScore = 0

val getScore(score: Int): Int {
    loalScore = score
    return loalScore
}
```

In this case, impurity does not manifest itself strongly because subsequent method calls will return the same value:

```
getScore(12) // returns 12
getScore(6) // returns 6
getScore(3) // returns 3
```

This function modifies an external value but still returns the same value on each invocation because of the value assignment. However, this is not always the case. Let's consider another impure function:

```
val addScore = 0

val addScore(score: Int): Int {
    loalScore + score
    return loalScore
}
```

This function has "stronger impurity" because it modifies an external value and returns a different result on each invocation - the state is stored in the variable, outside the function scope:

```
addScore(12) // returns 12
addScore(6) // returns 18
addScore(3) // returns 21
```

The downside of keeping the state is that sometimes testing is more complex; however, we cannot avoid this in many applications. 

The following function is accessing a value from outside the function scope, and doing so makes it impure:

```
fun getString(length: Int): String {
    return Random().nextString(length)
}
```

This time each function call with the same argument will result in a different value being returned:

```
getString(2) // returns "ab"
getString(2) // returns "hh"
getString(2) // returns "zk"
```

While the previously presented side effects are pretty easy to spot, side effects can often be more subtle:

### Not So Obvious Side Effects

An interesting side-effecting scenario is a modification of the object passed as a function argument:

```
fun increaseHeight(person: Person) {
    person.height++
}
```

Calling this function multiple times with the same `Person` instance will lead to different output because the value outside the function (stored in Person instance) is modified. 

Exception thrown by a function is an excellent example of the side effects that are harder to spot:

```
fun addDistance (a:Int, b:Int): Int {
    if(a < 0) {
        throw IllegalAccessException("a must be >= 0")
    }
     
    return a + b
}
```

Another interesting way of creating side effects is simply by calling another side-effecting function:

```
fun firstFunction() {
    addDistance(-5, 7)
}

fun addDistance (a:Int, b:Int): Int {
    if(a < 0) {
        throw IllegalAccessException("a must be >= 0")
    }
     
    return a + b
}
```

Another not-so-obvious side effect is logging. Let's take a look at this real-life sample from our [Base Video Chat](https://github.com/opentok/opentok-android-sdk-samples/blob/main/Basic-Video-Chat/app/src/main/java/com/tokbox/sample/basicvideochat/MainActivity.java) sample application:

```
private PublisherKit.PublisherListener publisherListener = new PublisherKit.PublisherListener() {
    @Override
    public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
        Log.d(TAG, "onStreamCreated: Publisher Stream Created. Own stream " + stream.getStreamId());
    }

    @Override
    public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
        Log.d(TAG, "onStreamDestroyed: Publisher Stream Destroyed. Own stream " + stream.getStreamId());
    }

    @Override
    public void onError(PublisherKit publisherKit, OpentokError opentokError) {
        Log.d(TAG, "PublisherKit onError: " + opentokError.getMessage());
    }
};
```

In the above code, logging as a side-effect does not impact application logic, but it helps us understand what's going on in the application. Later, it's easy for the developer to use data returned by callbacks and introduce more side effects.

## Determine If Function Is Pure\Impure

There are two clues that a function may be impure—it doesn't take any arguments or return any value.  Let's look at the first case:

```
list.getItem(): String
```

In the above example, the function does not take any params, but it returns the value. This means that, most likely, the value is retrieved from the class state. Let's consider what happens when a function does not return any value:

```
list.setItem("item")
```

Looking at the function name, we cal tell that the param will be most likely used to modify class state. 

And finally, we can have a combo where there is no argument and no value returned:

`list.sort()`

These are only clues. It's not always the case, but these clues often are good purity indicators.


## Summary 

In the functional programming paradigm, ideally, all functions are pure.  

However, in many real-world applications, things aren't quite as binary. Sometimes impure functions cannot be avoided, especially if an application requires external resources like persistence, user input, or network data access. Having these breaks the purity of the function and the whole application, which isn't bad.  

Typically we will have a mix of pure and impure functions in a single application. It is good practice to be aware of purity/impurity as it facilitates application testing and helps us avoid bugs.


