---
title: Creating a Complex IVR System with Ease with XState
description: In this post we’ll see how to create very complex and elaborate IVR
  systems while keeping the code simple and easy to maintain
thumbnail: /content/blog/creating-a-complex-ivr-system-with-ease-with-xstate-dr/unnamed.jpg
author: yonatan-mevorach
published: true
published_at: 2019-06-20T18:33:17.000Z
updated_at: 2021-05-13T21:18:42.196Z
category: tutorial
tags:
  - javascript
comments: true
spotlight: true
redirect: ""
canonical: ""
---
Even if you didn't know that's what they're called, you probably use IVR systems all the time. An [IVR system](https://developer.vonage.com/use-cases/interactive-voice-response/) lets you call a phone number, listen the audio-cues, and navigate your way through the call to get the info you need. Vonage makes creating a full-fledged IVR system as simple as spinning up a Web server. In this post we'll see how to create very complex and elaborate IVR systems while keeping the code simple and easy to maintain. In order to accomplish this, we'll use [XState](https://xstate.js.org/) which is a popular State Machine library for Javascript.

## An IVR System with Less Than 35 Lines of Code

The key to implementing an IVR System with Vonage is to create a Web server that will instruct Vonage how to handle each step of the call. Typically, this means that as soon as a user calls your virtual incoming number, Vonage will send an HTTP request to your `/answer` endpoint and expect you to respond with a JSON payload composed of [NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference) objects that specify what the user should hear. Similarly, when the user uses their keypad to choose what they want to listen to next, then Vonage makes a request to a different endpoint typically called `/dtmf`. The `/dtmf` endpoint will be called with a request payload that includes the number that the user has chosen, which your server should use to figure out what set of NCCO objects to respond with.

Let's see this what this looks like in code when using [express](https://expressjs.com/) to power our Web server.

```javascript
const express = require('express');
const bodyParser = require('body-parser');

const port = process.env.PORT || 3000;
const app = express();
app.use(bodyParser.json());

app.post('/answer', (req, res) =&gt; {
  const ncco = [
    { action: 'talk', text: "Hi. You've reached Joe's Restaurant! Springfield's top restaurant chain!" },
    { action: 'talk', text: 'Please select one of our locations.' },
    { action: 'talk', text: 'Press 1 for our Main Street location.' },
    { action: 'talk', text: 'Press 2 for our Broadway location.' },
    { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 },
  ];
  res.json(ncco);
});

app.post('/dtmf', (req, res) =&gt; {
  const { dtmf } = req.body;
  let ncco;
  switch (dtmf) {
    case '1':
      ncco = [ { action: 'talk', text: "Joe's Main Street is located at Main Street number 11, Springfield." } ];
      break;
    case '2':
      ncco = [ { action: 'talk', text: "Joe's Broadway is located at Broadway number 46, Springfield." } ];
      break;
  }
  res.json(ncco);
});

app.listen(port, () =&gt; console.log(`Example app listening on port ${port}!`));
```

## Trying It For Yourself

You can start writing your app code right away. But in order to be able to call in and test for yourself that everything is working, you'll need to complete the following:

<sign-up number></sign-up>

* Make sure your Web server is accessible on the Web. You can do this by exposing your local development machine [using Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/?utm_campaign=dev_spotlight&utm_content=IVR_XState_Mevorach) or by developing using [Glitch](https://glitch.com/).
* Create a Voice application. You can do this via the [Vonage Website](https://dashboard.nexmo.com/voice/create-application), or using the [Vonage CLI](https://developer.vonage.com/application/vonage-cli#creating-an-application). You'll need to enter the public url of your `/answer` endpoint when you set up your application.
* Obtain a virtual incoming number and connect it to your app using the [Website](https://dashboard.nexmo.com/buy-numbers?utm_campaign=dev_spotlight&utm_content=IVR_XState_Mevorach) or [CLI](https://developer.vonage.com/application/vonage-cli#creating-an-application).

When all this is in place you'll be able to call your number and you'll hear the audio response that's based on the data you return from your Web server.

## Going Beyond the "Hello World" of IVR Systems

The example shown above works as expected, but a real-world IVR System will yield to the user for input many times, and will interpret the user's numeric input based on the state of the user in the call. To illustrate this, let's assume that in our example the user will be asked to choose the restaurant location that they're interested in, and then to choose whether they want to listen to the open hours or make a reservation. In both of these cases, the user may press 1 on their keypad, but how we interpret this depends on the previous audio-cue and the state of the user in the call.

To support this use-case we'll need to change the code we just wrote. Ideally, we'll change it in a way so that as we add functionality and make our IVR System more complex over time, our code will stay simple and we won't have to rethink how to structure it. To achieve this, we'll model our call structure as a [Finite-State Machine](https://en.wikipedia.org/wiki/Finite-state_machine) using [XState](https://xstate.js.org/), a State Machine library for Javascript.

##A Primer on State Machines

A State Machine is simply a model for a "machine" that can be in only one state at any given time, and can only transition from one state to another given specific inputs. XState and other State Machine libraries let you model and instantiate a machine in code, in a way that the "rules" of the State Machine are guaranteed to be enforced.

## Modeling our Call Structure as a State Machine

To model our call structure as a State Machine, we'll use the `Machine` function that XState exposes:

```javascript
// machine.js
const { Machine } = require('xstate');

module.exports = Machine({
  id: 'call',
  initial: 'intro',
  states: {
    intro: {
      on: {
        'DTMF-1': 'mainStLocation',
        'DTMF-2': 'broadwayLocation'
      }
    },
    mainStLocation: {
    },
    broadwayLocation: {
    }
  }
});
```

As you can see in the code above, our call can only be in one of three states:

* The `intro` state where the user is listening to the introduction and is instructed to choose the location they're interested in.
* The `mainStLocation` state where they're listening to information about the Main St. location of our hypothetical restaurant chain</li>
* The `broadwayLocation` state when they're listening to information about the Broadway location.

You can also see that:

* The only way to transition to the `mainStLocation` state is be in the `intro` state and send the `DTMF-1` [event](https://xstate.js.org/docs/guides/events.html).
* The only way to transition to the `broadwayLocation` state is to be in the intro state and send the `DTMF-2` event.

We can choose to colocate the NCCO objects related to each state inside the event definition using XState's [metaproperty](https://xstate.js.org/docs/guides/states.html#state-meta-data)

```javascript
// machine.js
const { Machine } = require('xstate');

module.exports = Machine({
  id: 'call',
  initial: 'intro',
  states: {
    intro: {
      on: {
        'DTMF-1': 'mainStLocation',
        'DTMF-2': 'broadwayLocation'
      },
      meta: {
        ncco: [
          { action: 'talk', text: "Hi. You've reached Joe's Restaurant! Springfield's top restaurant chain!" },
          { action: 'talk', text: 'Please select one of our locations.' },
          { action: 'talk', text: 'Press 1 for our Main Street location.' },
          { action: 'talk', text: 'Press 2 for our Broadway location.' },
          { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 }
        ]
      }
    },
    mainStLocation: {
      meta: {
        ncco: [
          { action: 'talk', text: "Joe's Main Street is located at Main Street number 11, Springfield." }
        ]
      }
    },
    broadwayLocation: {
      meta: {
        ncco: [
          { action: 'talk', text: "Joe's Broadway is located at Broadway number 46, Springfield." }
        ]
      }
    }
  }
});
```

## Utilizing our Machine

The object that the `Machine` function returns should be treated as an immutable stateless object that defines the structure of our machine. To actually create an instance of our machine that we can use as a source-of-truth for the state of a call, we'll use XState `interpret` function. The `interpret` function returns an object which is referred to as a "[Service](https://xstate.js.org/docs/guides/interpretation.html)". You can access the current state of each machine instance using the `state` property of the service. And you can send an event to change the state of the machine instance using the service's `send()` method. We'll create a `callManager` module to be in charge of creating machine instances for every incoming call, sending the appropriate events as the call progresses, and removing each machine instance when the call ends.

```javascript
// callManager.js
const { interpret } = require('xstate');
const machine = require('./machine');

class CallManager {
  constructor() {
    this.calls = {};
  }

  createCall(uuid) {
    const service = interpret(machine).start();
    this.calls\[uuid] = service;
  }

  updateCall(uuid, event) {
    const call = this.calls\[uuid];
    if(call) {
      call.send(event);
    }
  }

  getNcco(uuid) {
    const call = this.calls\[uuid];
    if(!call) {
      return \[];
    }
    return call.state.meta[`${call.id}.${call.state.value}`].ncco;
  }

  endCall(uuid) {
    delete this.calls\[uuid];
  }
}

exports.callManager = new CallManager();
```

As you can see, each call is identified by its `uuid`  which 
Vonage takes care of assigning to each call.

## Putting It All Together

Now we can modify our Web server code to defer to the `callManager` whenever the Vonage backend calls our endpoints.

```javascript
/// server.js
const express = require('express');
const bodyParser = require('body-parser');
const { callManager} = require('./callManager');

const port = process.env.PORT || 3000;
const app = express();
app.use(bodyParser.json());

app.post('/answer', (req, res) =&gt; {
  callManager.createCall(req.body.uuid);
  const ncco = callManager.getNcco(req.body.uuid);
  res.json(ncco);
});

app.post('/dtmf', (req, res) =&gt; {
  callManager.updateCall(req.body.uuid, `DTMF-${req.body.dtmf}`);
  const ncco = callManager.getNcco(req.body.uuid);
  res.json(ncco);
});

app.post('/event', (req, res) =&gt; {
  if(req.body.status == 'completed') {
    callManager.endCall(req.body.uuid);
  }
  res.json({ status: 'OK' });
});

app.listen(port, () =&gt; console.log(`Example app listening on port ${port}!`));
```

As you can see, in order to know when the call has ended we added an /event endpoint. If you associate it with your Vonage Application as the "Event URL" webhook then Vonage will make a request to it asynchronously when the overall call state changes (e.g. the user hangs up). Unlike the `/answer` or `/dtmf` endpoint, you cannot respond with NCCO objects to this request and influence what the user hears.

## Changing the Call Structure with Ease

We just completed a refactor of our app code, but it behaves exactly the same as before. But in contrast to before, now modifying the call structure becomes as simple as changing the JSON object that we pass to the `Machine` function.

So if, as mentioned earlier, we want to let the user decide if they want to listen to the location's opening hours or make a reservation, we just have to add a few more states, transitions, and NCCO arrays to our Machine's definition.

```javascript
// machine.js
const { Machine } = require('xstate');

module.exports = Machine({
  id: 'call',
  initial: 'intro',
  states: {
    intro: {
      on: {
        'DTMF-1': 'mainStLocation',
        'DTMF-2': 'broadwayLocation'
      },
      meta: {
        ncco: [
          { action: 'talk', text: "Hi. You've reached Joe's Restaurant! Springfield's top restaurant chain!" },
          { action: 'talk', text: 'Please select one of our locations.' },
          { action: 'talk', text: 'Press 1 for our Main Street location.' },
          { action: 'talk', text: 'Press 2 for our Broadway location.' },
          { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 }
        ]
      }
    },
    mainStLocation: {
      on: {
        'DTMF-1': 'mainStReservation',
        'DTMF-2': 'mainStHours',
      },
      meta: {
        ncco: [
          { action: 'talk', text: "Joe's Main Street is located at Main Street number 11, Springfield." },
          { action: 'talk', text: 'Press 1 to make a reservation.' },
          { action: 'talk', text: 'Press 2 to hear our operating hours.' },
          { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 },
        ]
      }
    },
    broadwayLocation: {
      on: {
        'DTMF-1': 'broadwayReservation',
        'DTMF-2': 'broadwayHours',
      },
      meta: {
        ncco: [
          { action: 'talk', text: "Joe's Broadway is located at Broadway number 46, Springfield." },
          { action: 'talk', text: 'Press 1 to make a reservation.' },
          { action: 'talk', text: 'Press 2 to hear our operating hours.' },
          { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 },
        ]
      }
    },
    mainStReservation: { /* ... */ },
    mainStHours: { /* ... */ },
    broadwayReservation: { /* ... */ },
    broadwayHours: { /* ... */ }
  }
});
```

## More XState Goodness

XState has more useful features that can help us out as our call model becomes more intricate.

## XState Visualizer

The XState Visualizer is an online tool to generate Statechart diagrams based on your existing XState Machine definitions. All we have to do to generate a Statechart is to paste your call to the `Machine` function. This is particularly handy to share with non-developer stakeholders to have discussions about the call structure.

![chart](/content/blog/creating-a-complex-ivr-system-with-ease-with-xstate/image1.png)

## Self-Referencing Transitions

A state can transition into [itself](https://xstate.js.org/docs/guides/transitions.html#self-transitions). This can be useful for cases where you want to allow the user to playback the latest piece of information given.

```javascript
mainStHours: {
  on: {
    'DTMF-1': 'mainStHours',
    'DTMF-2': 'intro'  },
  meta: {
    ncco: [
      { action: 'talk', text: "Joe's Main Street is open Monday through Friday, 8am to 8pm." },
      { action: 'talk', text: 'Saturday and Sunday 9am to 7pm.' },
      { action: 'talk', text: 'Press 1 to hear this information again.' },
      { action: 'talk', text: 'Press 2 to go back to the opening menu.' },
      { action: 'input', eventUrl: [ 'https://example.com/dtmf' ], maxDigits: 1 }
    ]
  }
}
```

## Persistence

You can register a function to be called whenever the machine transitions from one state to another using the service's [`onTransition`](https://xstate.js.org/docs/guides/interpretation.html#transitions) method. This can be useful to log the steps the user is taking and sending them to a remote database for future reference/analysis.

In general, XState supports [serializing](https://xstate.js.org/docs/guides/states.html#persisting-state) a machine instance's data so you can persist it.

## Strict Mode

When prompting the user for keypad input at any point in the call it's possible for the user to enter an input value you don't expect. For example, the user may be in a state in the call where you expect them to choose 1 if they would like to make a reservation or press 2 to listen to the opening hours. But if the user presses 9 the event sent will be `DTMF-9` and that's not a possible transition given the current state. Ideally we'd like to find a generic way of detecting when the user has entered an invalid input and instruct them to make the selection again.

By defining our machine with [`strict: true`](https://xstate.js.org/docs/guides/machines.html#configuration) we can cause the `send()` method to throw an exception if it's passed an event that's not possible giving the current state. We can then catch that error further on up and reply with an appropriate NCCO response that will tell the user to make the selection again.

## Wrapping Up

In this post we introduced the XState library and how it can be used to control the progress of a call in an IVR System powered by Vonage, in a way that scales well for a real-world use-case. The complete code covered in this post can be found [here](https://github.com/cowchimp/ivr-xstate-demo). If you're looking for more info, both [Vonage](https://developer.vonage.com/voice/voice-api/overview?utm_campaign=dev_spotlight&utm_content=IVR_XState_Mevorach) and [XState](https://xstate.js.org/docs) have excellent documentation.