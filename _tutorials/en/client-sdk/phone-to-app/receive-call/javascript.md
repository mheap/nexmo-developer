---
title: Run your application
description: In this step you learn how to run your phone to app application.
---

# Run your application

Open `client_js.html` in a browser.

The call’s current status and an Answer button are displayed on the page.

You can now call the Vonage number associated with your Client SDK application.

You will hear a message saying to wait while you are connected through to an agent.

In your web app, you will see the call status updated. Click the `Answer` button to answer the inbound call.

A conversation can now take place between the web app (agent) and the inbound caller.

Hang up when you're done and the call status will be updated again.

## Webhooks

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO and the `/voice/event` endpoint receiving the events:

```bash
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
NCCO request:
  - from: 447000000000
---
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-23T13:21:57.846Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  network: '23409',
  duration: '11',
  start_time: '2021-03-23T13:21:57.000Z',
  rate: '0.00720000',
  price: '0.00132000',
  from: '447000000000',
  to: '447441444905',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-23T13:22:08.706Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  network: null,
  duration: '3',
  start_time: '2021-03-23T13:22:05.000Z',
  rate: '0.00',
  price: '0',
  from: 'Unknown',
  to: 'Alice',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:09.292Z'
}
---
```
