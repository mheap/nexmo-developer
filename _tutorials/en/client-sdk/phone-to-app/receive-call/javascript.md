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

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

```bash
NCCO request:
  - caller: 447700900000
  - callee: 442038297050
```

Also, as the call progresses through various stages, `/voice/event` is being sent events:

```bash
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-29T21:20:06.182Z'
}
---
EVENT:
{
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:16.000Z',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  network: null,
  duration: '5',
  start_time: '2021-03-29T21:20:11.000Z',
  rate: '0.00',
  price: '0',
  from: '447700900000',
  to: 'Alice',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:17.574Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:18.000Z',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  network: 'GB-FIXED',
  duration: '12',
  start_time: '2021-03-29T21:20:06.000Z',
  rate: '0.00720000',
  price: '0.00144000',
  from: ' 447700900000',
  to: '442038297050',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:17.514Z'
}
---

```
