---
title: Run your application
description: In this step you learn how to run your app to phone application.
---

# Run your application

Open `client_js.html` in a browser.

A text field and a `Call` button are displayed on the page.

Enter the number of your mobile phone into the text field in [E.164](/concepts/guides/glossary#e-164-format) format (for example, `447700900000`) and then click the button.

You can also open up the web browser console and view logging messages there for your web app and the Client SDK. You will see the application attempting to connect to the target number you provided.

Once the call comes through you can answer it and hear the in-app voice call.


## Webhooks

As you proceed with placing the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

``` bash
NCCO request:
  - caller: undefined
  - callee: 447700900000
```

Also, as the call progresses through various stages, `/voice/event` is being sent events:

``` bash
...
---
VOICE EVENT:
{
  from: null,
  to: 'Alice',
  uuid: '2da93da3-bcac-47ee-b48e-4a18fae7db08',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-10T10:36:21.285Z'
}
---
VOICE EVENT:
{
  headers: {},
  from: 'Alice',
  to: '447700900000',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-10T10:36:27.080Z'
}
---
...
---
VOICE EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Alice',
  to: '447700900000',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-10T10:36:31.604Z'
}
---
VOICE EVENT:
{
  headers: {},
  end_time: '2021-03-10T10:36:36.000Z',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  network: '23433',
  duration: '5',
  start_time: '2021-03-10T10:36:31.000Z',
  rate: '0.10000000',
  price: '0.00833333',
  from: 'Unknown',
  to: '447700900000',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-10T10:36:35.585Z'
}
---
VOICE EVENT:
{
  headers: {},
  end_time: '2021-03-10T10:36:35.000Z',
  uuid: '2da93da3-bcac-47ee-b48e-4a18fae7db08',
  network: null,
  duration: '15',
  start_time: '2021-03-10T10:36:20.000Z',
  rate: '0.00',
  price: '0',
  from: null,
  to: 'Alice',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-10T10:36:36.187Z'
}
```

> **NOTE:** As the call is completed, events will also contain duration and  pricing information.