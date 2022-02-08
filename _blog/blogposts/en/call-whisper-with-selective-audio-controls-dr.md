---
title: Call Whisper with Selective Audio Controls
description: Nexmo's new selective audio controls solve a common use case – a
  supervisor listening to a call but only being heard by their employee and not
  the customer.
thumbnail: /content/blog/call-whisper-with-selective-audio-controls-dr/Selective-Audio-Controls_1200x675.jpg
author: mheap
published: true
published_at: 2018-12-13T17:01:23.000Z
updated_at: 2021-05-11T09:10:19.860Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---

Nexmo's been a popular choice for contact centre solutions for a long time, but with today's release of Selective Audio Controls we're taking it to the next level. Selective audio controls solve a common use case - a supervisor listening to a call but only being heard by their employee and not the customer - in an intuitive way.

Each participant in a conversation on the Nexmo platform is assigned an ID. Using these IDs and the [conversation action](https://developer.nexmo.com/voice/voice-api/ncco-reference#conversation)  you can build an application that controls which participants someone new to the conversation can hear. In this post, we're going to build the supervisor listening to an employee use case.

> The code for this application is available [on Github](https://github.com/nexmo-community/selective-audio-controls-demo/blob/master/index.js)

## Bootstrapping an Application
To build this call flow we need to write a small node.js application. Let's create a new project and install `express` to serve our `answer_url`.

```bash
mkdir selective-audio
cd selective-audio
npm init -y
npm install express body-parser --save
```

Once you've done this, you'll need to create an instance of `express`, register an `answer_url` and listen on a port. To do this, create `index.js` with the following contents:

```javascript
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({"extended": true}));
app.use(bodyParser.json());

app.get('/webhooks/answer', (req, res) => {
    return res.json([]);
});

app.listen(3000, () => {
    console.log('Listening');
});
```

## Creating Your Answer URL
Now that we have an application bootstrapped, it's time to start adding our business logic. There are three participants in our call:

* Alice, the contact centre supervisor
* Bob, the contact centre agent
* Charlie, the customer

In the real world we'd use a database to store all of the information needed to make this happen, but for this post let's just use an object in memory. The key is the participant's phone number, and that maps to an object containing information about them. For now, it's just their role. Add the following code after `app.use(bodyParser.json());`, making sure to update the code below, replacing the keys with your real phone numbers.

```javascript
const conversationName = 'selective-audio-demo';
const participants = {
  "<supervisor_phone_number>": {
    "role": "supervisor",
  },
  "<agent_phone_number>": {
    "role": "agent",
  },
  "<customer_phone_number>": {
    "role": "customer",
  }
};
```

Once you've done that, you need to update your `/webhooks/answer` URL so that it returns a valid NCCO. As we'll need a different NCCO for each type of caller, let's add a `switch` statement and call a method which returns an NCCO for each caller type:

```javascript
app.get('/webhooks/answer', (req, res) => {
    const caller = participants[req.query.from];

    if (!caller) {
        return res.status(400).json("Unknown caller type: " + req.query.from);
    }

    // Generate an NCCO based on role
    let ncco;
    switch (caller.role) {
        case 'supervisor':
            ncco = createSupervisorNcco(caller);
            break;
        case 'agent':
            ncco = createAgentNcco(caller);
            break;
        case 'customer':
            ncco = createCustomerNcco(caller);
            break;
        default:
            return res.status(400).json("Unknown caller type: " + caller.type);

    }
    return res.json(ncco);
});
```

This code calls `createSupervisorNcco`, `createAgentNcco` or `createCustomerNcco` depending on the caller type provided. We need to go ahead and create those functions and return NCCO.

## The Customer NCCO
Let's start with the customer NCCO. When the customer joins, we want them to be able to hear the agent but not the supervisor, and to be able to speak to both the agent and the supervisor. In addition, when the customer calls we want them to be placed on hold until an agent joins the conversation.

Add the following to the bottom of your file to generate the customer NCCO.  We use the `conversation` action, give the conversation a `name`, specify that the call should not start automatically and that the user should be placed on hold. These are all existing parameters for the Nexmo Voice API. 

What makes this NCCO interesting, are the `canSpeak` and `canHear` parameters. These two parameters accept a list of UUIDs that identify other participants, and controls who the person connecting to the call can speak to and hear from. If the UUID of a participant is not provided, the connecting user will not be able to speak to or hear that participant.

In this example, our customer can speak to the agent and their supervisor, but can only hear the audio from the agent. Add the following to the bottom of your file:

```javascript
function createCustomerNcco(caller){
    // Customer can hear agent, and speak to everyone
    return [
        {
            "action": "conversation",
            "name": conversationName,
            "startOnEnter": false,
            "musicOnHoldUrl": ["https://nexmo-community.github.io/ncco-examples/assets/voice_api_audio_streaming.mp3"],
            "canSpeak": findParticipants('agent').concat(findParticipants('supervisor')),
            "canHear": findParticipants('agent')
        }
    ]
}
```

## The Agent NCCO
Next up is the agent NCCO. Agents should be able to speak to all participants and be heard by all participants. They're the owner of this conference call, so we set `startOnEnter` to true to indicate that the conference becomes active when they join. In addition, we set `record` to `true` so that the call is recorded.

As the agent can speak to and hear everyone, we find all customers and all supervisors and supply their UUIDs to the `conversation` action.

> In this case we could omit `canSpeak` and `canHear` from the NCCO as the default values are to allow audio between all participants. In the interests of complete control over participants, I've chosen to supply them anyway


```javascript
function createAgentNcco(caller){
    // Agent can hear everyone, and speak to everyone
    return [
        {
            "action": "conversation",
            "name": conversationName,
            "startOnEnter": true,
            "record": true,
            "canSpeak": findParticipants('customer').concat(findParticipants('supervisor')),
            "canHear": findParticipants('customer').concat(findParticipants('supervisor'))
        }
    ]
}
```

## The Supervisor NCCO
Finally, we have the supervisor NCCO. The supervisor can hear everyone, but only speak to the agent (this is the opposite of the customer). As before, they don't own the call so `startOnEnter` is set to false.

We provide `canSpeak` and `canHear` with a list of UUIDs like our previous NCCOs, and this ensures that the supervisor can only speak to the agent, but will hear both the agent and the customer.

```javascript
function createSupervisorNcco(caller){
    // Supervisor can hear everyone, but only speak to agents
    return [
        {
            "action": "conversation",
            "name": conversationName,
            "startOnEnter": false,
            "musicOnHoldUrl": ["https://nexmo-community.github.io/ncco-examples/assets/voice_api_audio_streaming.mp3"],
            "canSpeak": findParticipants('agent'),
            "canHear": findParticipants('customer').concat(findParticipants('agent'))
        }
    ]
}
```

## Making it All Work

We're almost there! There are just two things left to do before our application will work. The first is to implement our `findParticipants` method. Add the following function to the bottom of your file:

```javascript
function findParticipants(callerType) {
    let legs = [];
    Object.entries(participants).forEach(([number, participant]) => {
        if (participant.role == callerType && participant.legId) {
            legs.push(participant.legId);
        }
    });

    return legs;
}
```

This searches through all participants for the provided role. If the role matches, the leg UUID is pushed in to an array and returned.

The second thing to do is to make sure we store the caller's leg UUID when a request is made to `/webhooks/answer`. Update your code to store the leg ID after we check if the current caller can be found:

```javascript
if (!caller) {
    return res.status(400).json("Unknown caller type: " + req.query.from);
}

// Add their leg ID to the caller
caller.legId = req.query.uuid;
```

At this point, your application should work. Make sure that your `answer_url` is accessible (perhaps using [ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) if it's on your local machine) and call a number that points to the application you just built. If you need to create a Nexmo application and rent a number, take a look at our [application concepts](https://developer.nexmo.com/concepts/guides/applications) on our developer portal.
