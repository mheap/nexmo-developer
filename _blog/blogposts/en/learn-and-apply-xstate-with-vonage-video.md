---
title: Learn and Apply XState with Vonage Video
description: XState is a new way of representing state in front-end JavaScript
  applications. In this post, we introduce the concepts behind it to help you
  learn more.
thumbnail: /content/blog/learn-and-apply-xstate-with-vonage-video/Blog_XState_VideoAPI_1200x600.png
author: kellyjandrews
published: true
published_at: 2020-07-01T13:55:12.000Z
updated_at: 2021-05-04T17:10:43.943Z
category: inspiration
tags:
  - javascript
  - xstate
  - state-machines
comments: true
redirect: ""
canonical: ""
---
Over the last few months, I have heard more about [state machines](https://en.wikipedia.org/wiki/Finite-state_machine) used for front-end development. The idea of a state machine is that it has only a finite number of states and can only be in one state at any given time. Conceptually this makes perfect sense for app development -  there are only a certain number of states available.

The concept of state machines and statecharts is not new, and it isn't rooted in front-end development, either.  It's a mathematical model, and one used in many things around us. As an example, a light can be `OFF` or `ON`. You can describe anything with a state machine, even though this is a simple example.

![On and off states of lightbulb](/content/blog/learn-and-apply-xstate-with-vonage-video/lightbulb.png "On and off states of lightbulb")

## Introduction to XState

Using a state machine in front-end development has become much less complicated with the creation of the package [XState](https://xstate.js.org/docs/). XState helps us define state machines, create events and effects, and control the entire application flow. XState uses JavaScript methods and objects to describe the state machine.

The light bulb example from above would be written out like the following:

```js
const lightBulb = Machine({
  id: 'lightBulb',
  initial: 'off',
  states: {
    off: {
      on: {
        TURN_ON: 'on'
      }
    },
    on: {
      on: {
        TURN_OFF: 'off',
      }
    }
  }
});
```

The state machine defined here shows the two states for the light bulb, `OFF` and `ON`, and the transitions from the events `TURN_ON` and `TURN_OFF`.

The object itself isn't very complex to read, but as the state machine grows in complexity, it can be harder to understand.  XState has create a tool to help out with this - the [XState visualizer](https://xstate.js.org/viz/).

<iframe src="https://xstate.js.org/viz/?gist=a8a33932a88951692a8c94de647db40b&embed=1" width="100%" height="150px"></iframe>

Using the XState visualizer helps to see how the state machines work and are interactive, so playing with them is fun. If you want to check out the code for the machine, you can also click the code button to take a peek.

## Building a Vonage Video State Chart

When I set out to learn state machines, and XState, my overall goal was to build an application similar to Google Meet using [Vonage Video](https://tokbox.com/developer/). The app would allow a user to create a meeting room, share the URL, and have a meeting with multiple streams. To get to that point, I had to learn some of the various concepts for state charts and how to represent those in XState.

Thinking through the possible application states is not an easy task, I found. There are many possibilities to explore, and ultimately finding the right solution takes some trial and error.  

The rest of this article will cover some basic concepts and build a state chart visualization that will mimic the eventual state machine. I will also provide some additional links and resources throughout so you can explore on your own.

## States and State Nodes

A [state](https://xstate.js.org/docs/guides/states.html) is a representation of a machine at any given time. This moment can be defined and then made into a [state node](https://xstate.js.org/docs/guides/statenodes.html) in XState, captured as a configuration.

In my Vonage Video app, there are a couple of different possible solutions to this, but I've found that describing the states in as simple of terms as possible is the best way to get to a useful result.

Creating a [machine](https://xstate.js.org/docs/guides/machines.html) uses the following pattern:

```js
const machine = Machine(state_nodes, options)
```

With a video state machine in mind, there are two compound states - `connected` and `disconnected`.

<iframe src="https://xstate.js.org/viz/?gist=2d260c1f9c7b51ed47c4cf7bbc61b4df&embed=1" width="100%" height="200px"></iframe>

Two state nodes may seem overly simplified, but there are only two states after some trial and error. Each of these states, however, are more complex than an atomic (no children) node. Instead of creating every possible state at the top level, XState helps us organize with hierarchical and parallel state nodes.

### Hierarchical State Nodes

XState provides the option to create nested states called [`hierarchical` state nodes](https://xstate.js.org/docs/guides/hierarchical.html).  When we first start the machine, we can set it to `idle` first, as the machine will be ready but doing nothing. Why not just make another top-level atomic state node?

Adding states to the top level is called "state explosion" and is a typical side-effect of finite state machines. Since Vonage Video is still technically `disconnected`, nesting `idle` makes sense as the video is both disconnected and idle.  Another `disconnected` substate should be `ready`. The `disconnected.ready` state would happen just before moving to the `connected` state. The state machine also has a state node in-between `idle` and `ready` to get everything set up. This middle state can be called the `init` phase.

The state machine now would look like this:

<iframe src="https://xstate.js.org/viz/?gist=da00b68575ceb12f88b1ad7ad0219020&embed=1" width="100%" height="400px"></iframe>

You should notice that we don't currently have a way to move in between the two nodes. We will cover events and actions in a moment.

### Parallel State Nodes

A [`parallel` state node](https://xstate.js.org/docs/guides/parallel.html) allows the application to be in all of its substates at the same time. The Vonage Video state machine is highly event-driven, so we need to manage multiple states at once.

To specify that a state node is parallel, we use `type:parallel` in the configuration. After the transition to `connected`, three parallel states will occur - `session`, `publisher`, and `subscribers`. Each of these states will set up events and event listeners to control the Vonage Video service's responses.  

The resulting visualization looks like this:

<iframe src="https://xstate.js.org/viz/?gist=bf9c3dd275206505c12bb0bb88df5d58&embed=1" width="100%" height="400px"></iframe>

With these primary states, we can control what our application shows at particular times.  Currently, however, we are unable to move between states. Let's have a look at events and transitions.

## Events and Transitions

Since a state node is just the configuration of an individual state, their inherently is not a way to move from state to state without declaring that in the state node.

Each node listens for a sent [event](https://xstate.js.org/docs/guides/events.html) to [transition](https://xstate.js.org/docs/guides/transitions.html) to the next state. In the light bulb example, the `TURN_ON` event sent tells the machine to transition to `on`.

Transitions only occur between top-level nodes and within hierarchical nodes. Parallel nodes are not allowed to transition between each other.  For our Vonage Video app, this means the following:

1. When the page is ready, we can send a `START` event. This event will transition the state to `disconnected.init`.
2. The `disconnected.init` state will transition out once the `VIDEO_ELEMENT_CREATED` event has fired.
3. Once we reach `disconnected.ready`, we can allow the user to connect, sending the `CONNECT` event, and transition to `connected`.
4. If the application passed the `DISCONNECT` event, the state machine would disconnect.

<iframe src="https://xstate.js.org/viz/?gist=53c4772dc742ce1b84c40e3fa6669c6e&embed=1" width="100%" height="400px"></iframe>

Declaring an event and transition in XState uses the following pattern:

```js
on: {
  EVENT_DESCRIPTOR: 'nextState'
}
```

You can add specific actions to the transition as well. I would recommend you read the sections on [internal and external transitions](https://xstate.js.org/docs/guides/transitions.html#internal-transitions) in the documentation.  They cover in great detail the various types of transitions possible.

### Guarded Transitions

You may have noticed that one of the transitions has a `cond` node in the transition.  This conditional is what's called a [`guarded` transition](https://xstate.js.org/docs/guides/guards.html#guards-condition-functions). Guarded transitions help protect the machine from moving to a state that is not allowed based on certain conditions.  In this case, I don't want to transition to `ready` until the token and video element are both created.

```js
on: {
  'VIDEO_ELEMENT_CREATED': {
    target: 'ready',
    cond: 'checkToken'
  }
}
```

The guard condition `checkToken` is a named reference to the guards object in the options paramater sent to machine:

```js
const video = Machine(
  state_nodes,{
  guards: {
    checkToken: () => true
  }
});
```

## Context

In order to be more useful to an application, our state machine will need a longer living state, called an [`extended state`, or `context`](https://xstate.js.org/docs/guides/context.html#initial-context). The context object updates using various effects with the [`assign()` method](https://xstate.js.org/docs/guides/context.html#assign-action).

Speaking of actions, let's get to these now and finish out the rest of the skeleton.

### Actions and Services

There are what's known as "side-effects" in state machines that XState puts into one of two categories:

1. "Fire-and-forget" - where the effect doesn't send events
2. Invoked - where sending events are required

### Actions

[Actions](https://xstate.js.org/docs/guides/actions.html) are single effects and tend to be one of the more common effects in the video state machine. You can use actions when you enter or exit a node, or during a transition. Understanding the order of actions is incredibly important.

An excellent resource for learning the action order (and all of the topics on XState) is a video published by [@kyleshvlin](https://twitter.com/kyleshevlin) over at [Egghead.io](https://egghead.io/lessons/xstate-how-action-order-affects-assigns-to-context-in-a-xstate-machine). It helped me understand how actions fired.

The bulk of the actions for this machine revolve around updating the context as a transition. When events are called, we can use the action to run the `assign()` method:

```js
on: {
  'SOME_EVENT': {
      actions: assign({'someContext': (ctx, e) => e.someValue})
  } 
}
```

### Services

[Invoked Services](https://xstate.js.org/docs/guides/communication.html#the-invoke-property) are the other main effect in the video state machine. To use promises and event listeners, you need to invoke a service.  This concept was, by far, the hardest for me to grasp. The main difficulty I had to work through was understanding that an invoked service stops when the state exits.  If you transition too quickly, your promise or callback will disappear.

There are two primary services that I'm using in the video state machine, promises, and callbacks. The [`invoke promises` service](https://xstate.js.org/docs/guides/communication.html#invoking-promises) allows the state machine to use a promise to either resolve or reject and then act accordingly. I used this to interact with the server asynchronously and then update the context when complete.

The function signature of invoked promises looks like this:

```js
src: (context, event) => new Promise((resolve, reject) => {
  if (event.error) reject('Rejected')
  resolve('Resolved')
}),
onDone: {/*success transition*/}
onError: {/*error transition*/}
```

The second, and probably the most important part of this machine, is the [`invoked callbacks`](https://xstate.js.org/docs/guides/communication.html#invoking-callbacks). The Vonage Video architecture relies heavily on events and event listeners.  In a state machine, those are set up through a callback. Let me show you an example:

```js
invoke: {
  id: 'initPublisher',
  src: (ctx) => (cb) => {
    let publisher = initPublisher(pubOptions);
    publisher.on('videoElementCreated', (e) => {
      cb({ type: 'VIDEO_ELEMENT_CREATED', publisher: publisher })
    })
    return () => publisher.off('videoElementCreated');
  }
}
```

The function signature of an invoked callback looks like this:

```js
src: (context, event) => (callback, onReceive) => {
  
  callback('EVENT');
  onReceive(event) => { callback('OTHER_EVENT') };

  return () => cleanup()
};
```

Using actions and services, our Vonage Video state machine now looks like the following:

<iframe src="https://xstate.js.org/viz/?gist=826cd253fd9eac80c2daa6bfa0924f50&embed=1" width="100%" height="400px"></iframe>

Don't forget to click around, and click the `code` tab to see what the state machine looks like as a configuration. 

## Resources and Wrap-up

Ok - so you've made it this far.

![I'm proud of you!](/content/blog/learn-and-apply-xstate-with-vonage-video/proudofyou.gif "I'm proud of you!")

If this is your first time looking at XState, it's a lot to take in all at once.  I'm still exploring and learning new ways to do things. This post is just a small portion of what's out there. As you are learning - here are a few great resources you will want to check out

* [Kyle Shevlin's Intro to State Machines Using XState videos](https://egghead.io/courses/introduction-to-state-machines-using-xstate)
* [XState Docs](https://xstate.js.org/docs/guides/start.html)
* [Introduction to XState at flaviocopes.com](https://flaviocopes.com/xstate/)
* [The Rist of State Machines - Smashing Magazine](https://www.smashingmagazine.com/2018/01/rise-state-machines/)

Feel free to reach out if you have questions about XState, and we can learn something new together!