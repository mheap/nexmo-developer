---
title: Real-time SMS Demo with React, Node, and Google Translate
description: Learn more about building an application using WebSockets, Node and
  Google Translate to display real-time translations of incoming SMS text
  messages.
thumbnail: /content/blog/real-time-sms-demo-with-react-node-and-google-translate-dr/E_SMS-Translations_1200x600.png
author: kellyjandrews
published: true
published_at: 2020-03-11T13:02:01.000Z
updated_at: 2021-05-24T21:57:34.596Z
category: tutorial
tags:
  - node
  - sms-api
  - websockets
comments: true
redirect: ""
canonical: ""
---
Last year I worked with the [Google Translate API](https://www.nexmo.com/blog/2019/10/24/extending-nexmo-google-cloud-translation-api-dr) to translate SMS messages. After showing the rest of the team, they wanted a demo they could show off to other developers at conferences we attended. Based on that, I set out to create a frontend with React that could display the translations in real-time.

## Building the WebSocket

### What's a WebSocket?

For this demo, I decided that using a WebSocket would be a great solution. If you haven't used a WebSocket before, it's a protocol that allows a client and server to communicate in real-time. WebSockets are bi-directional, meaning the client and server can both send and receive messages. When you first connect to a WebSocket, the connection is made by upgrading an HTTP protocol to the WebSocket protocol and is kept alive as long as it goes uninterrupted. Once established, it provides a continuous stream of content. Exactly what we need to receive incoming, translated SMS messages.

### Create the WebSocket Server in Node

As an initial step to creating the WebSockets, the server requires a path to allow for client connections. Starting with the original server file from my [previous post](https://github.com/nexmo-community/sms-google-translate-js), we can make a few minor changes to create the WebSocket server and the events and listeners required by the client.

Using the [`ws`](https://github.com/websockets/ws) package on NPM, we can quickly create what we need to get this working.  

```bash
npm install ws
```

Once installed, include the package in your server file, and create the WebSocket server. `WS` allows a `path` option to set the route the client uses to connect.

```javascript
const express = require('express');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: "/socket" });
```

With this bit of code, the client now has a place to connect to the WebSocket route `/socket`. With the server ready to go, you need to now listen for a `connection` event. When the client connects, the server uses the following to set up the other listeners we need:

```javascript
wss.on('connection', (ws) => {
  ws.isAlive = true;
  ws.translateTo = 'en';

  ws.on('pong', () => {
    ws.isAlive = true;
  });

  ws.on('message', (message) => {
    translateTo = message;
  });

});
```

There are two main points to call out:

1. On connection, we set the property `isAlive` to `true`, and listen for the `pong` event. This event is for the server to check and maintain a connection with the client. The server sends a `ping` and responds with `pong` to verify it's still a live connection.
2. Here I set up `translateTo` as a property to store. `translateTo` is set through each client using a dropdown. When someone using our booth demo app selects a different language, that action sets this to translate the SMS texts into the requested language.

### Keeping the Connection Alive

One essential item to be concerned with is checking for clients that disconnect. It's possible that during the disconnection process, the server may not be aware, and problems may occur. With a good friend `setInterval()`, we can check if our clients are still there and reconnect them if needed.

```javascript
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (!ws.isAlive) return ws.terminate();
    ws.isAlive = false;
    ws.ping(null, false, true);
  });
}, 10000);
```

### Sending Messages to the Client

Now that the WebSocket is connected and monitored, we can handle the inbound messages from Nexmo, the translation, and the response to the client. The method `handleRoute` needs to be updated from its original state to add the response for each client.

```javascript
const handleRoute = (req, res) => {

  let params = req.body;

  if (req.method === "GET") {
    params = req.query
  }

  if (!params.to || !params.msisdn) {
    res.status(400).send({ 'error': 'This is not a valid inbound SMS message!' });
  } else {
    wss.clients.forEach(async (client) => {
      let translation = await translateText(params, client.translateTo);
      let response = {
        from: obfuscateNumber(req.body.msisdn),
        translation: translation.translatedText,
        originalLanguage: translation.detectedSourceLanguage,
        originalMessage: params.text,
        translatedTo: client.translateTo
      }

      client.send(JSON.stringify(response));
    });

    res.status(200).end();
  }

};
```

The `wss.clients.forEach` method iterates through each connection, and sends off the SMS parameters from Nexmo to the Google Translate API. Once the translation comes back, we can decide what data the front-end should have, and pass it back as a string as I've done here with `client.send(JSON.stringify(response))`.

To recap what has happened here: Each client connects to the WebSocket server by calling the `/socket` route and establishing a connection. An SMS message goes from the sender's phone to Nexmo, which then calls the `/inboundSMS` route. The app passes the text message to Google Translate API for each connected client, and then finally sends it back to the client UI.

![Diagram of WebSocket Flow](/content/blog/real-time-sms-demo-with-react-node-and-google-translate/flow-diagram.png "Diagram of WebSocket Flow")

Next, let's build the UI parts to display it on the screen.

## WebSockets with React

With the WebSocket server running, we can move on to the display of the messages on screen. Since I enjoy using [React](https://reactjs.org/), and more importantly, [React Hooks](https://reactjs.org/docs/hooks-intro.html), I set out to locate something to help with connecting to WebSockets. Sure enough, I found one that fit my exact need.

The demo app UI is built with [`create-react-app`](https://github.com/facebook/create-react-app), and I used the [Grommet](https://v2.grommet.io/) framework. These topics are out of scope for this post, but you can grab my [source code](https://github.com/nexmo-community/sms-translation-demo-app) and follow along.

### Connecting to the WebSocket

The first step here is to establish a connection and begin two-way communication. The module I found is [`react-use-websocket`](https://github.com/robtaussig/react-use-websocket), and it made setting this up super simple.

```bash
npm install react-use-websocket
```

There are tons of these React hook libraries out there that help you create some impressive functionality in a short amount of time. In this instance, importing the module and setting up a couple of items for the configuration is all it took to get a connection.

```javascript
import useWebSocket from 'react-use-websocket';

const App = () => {
  const STATIC_OPTIONS = useMemo(() => ({
    shouldReconnect: (closeEvent) => true,
  }), []);

  const protocolPrefix = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  let { host } = window.location;
  const [sendMessage, lastMessage, readyState] = useWebSocket(`${protocolPrefix}//${host}/socket`, STATIC_OPTIONS);

  //...
}
```

In the component, we import the `useWebSocket` method to pass the WebSocket URL and the object `STATIC_OPTIONS` as the second argument. The `useWebSocket` method is a custom hook that returns the `sendMessage` method, `lastMessage` object from the server (which is our translated messages), and the `readyState` which is an integer to give us the status of the connection.

### Receiving Incoming Messages

Once `react-use-websocket` makes the connection to the server, we can now start listening for messages from the `lastMessage` property. When receiving incoming messages from the server, they populate here and update the component. If your server has multiple message types, you discern that information here. Since we only have one, it's an easier implementation.

```javascript
const [messageHistory, setMessageHistory] = useState([]);

useEffect(() => {
  if (lastMessage !== null) {
    setMessageHistory(prev => prev.concat(lastMessage))
  }
}, [lastMessage]);

return (
  <Main>
    {messageHistory.map((message, idx) => {
      let msg = JSON.parse(message.data);
      return (
        <Box>
          <Text>From: {msg.from}</Text>
          <Heading level={2}>{msg.translation}</Heading>
        </Box>
      )
    })}
  </Main>
)
```

The built-in hook `useEffect` runs every time the state is updated. When `lastMessage` is not null, it adds the new message to the end of the previous message state array, and the UI updates using the `map` function to render all of the messages. It is in the `messageHistory` where all of the JSON strings we passed from the server are stored. The main functionality of our WebSocket is complete, but I still want to add a few more items.

### Sending Messages to the Server

Since this is a translation demo, having more than one language is an excellent way to show the power of the Google Translate API in conjunction with Nexmo SMS messages. I created a dropdown with languages to pick. This dropdown is where bi-directional communication happens with the server, and the app sends the selected language from the client.

```javascript
const languages = [
  { label: "English", value: "en"},
  { label: "French", value: "fr"},
  { label: "German", value: "de"},
  { label: "Spanish", value: "es"}
];

<Select
  labelKey="label"
  onChange={({ option }) => {
    sendMessage(option.value)
    setTranslateValue(option.label)
  }}
  options={languages}
  value={translateValue}
  valueKey="value"
/>
```

Here, the `sendMessage` function from `react-use-websocket` is how we can send information back to our server and consume it. This process is where the event handler we set up comes in handy from earlier. It is this dropdown that determines what language the Google Translate API translates the message into and displays on the screen.

### Connection Status Display

Since this is a demo in a conference environment, I thought having a connectivity indicator would be a good idea. As long as the front-end remains connected to the WebSocket, the light displays green.  

```javascript
const CONNECTION_STATUS_CONNECTING = 0;
const CONNECTION_STATUS_OPEN = 1;
const CONNECTION_STATUS_CLOSING = 2;

function Status({ status }) {
  switch (status) {
    case CONNECTION_STATUS_OPEN:
      return <>Connected<div className="led green"></div></>;
    case CONNECTION_STATUS_CONNECTING:
      return <>Connecting<div className="led yellow"></div></>;
    case CONNECTION_STATUS_CLOSING:
      return <>Closing<div className="led yellow"></div></>;
    default:
      return <>Disconnected<div className="led grey"></div></>;;
  }
}

//....
<Status status={readyState} />
//...
```

The `Status` component uses the `readyState` to switch between the various statuses and indicates that to the user. If it turns red, you know something is wrong with the WebSocket server, and you should check into it.  

Once everything is up and running, it looks something like this:

![Animation of Working Demo App](/content/blog/real-time-sms-demo-with-react-node-and-google-translate/using_translation_app.gif "Animation of Working Demo App")

## Try It Out

The [demo application code](https://github.com/nexmo-community/sms-translation-demo-app) is on our community GitHub organization, and you can try it out for yourself as well. I've created a README that should help you get through the setup and run it locally on your server or deploy it to Heroku. I've also provided a Dockerfile, if you'd prefer to go that route. Let me know what you think of it, and if you have any trouble, feel free to reach out and submit an issue on the repo.