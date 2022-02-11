---
title: Create a Code of Conduct Incident Line with Node.js
description: Learn how to build your own incident line complete with a dashboard
  to download call recordings and log incoming messages using Node.js and the
  Vonage APIs.
thumbnail: /content/blog/create-a-code-of-conduct-incident-line-with-node-js/Blog_Code-of-Conduct-Incident-Line_1200x600.png
author: kevinlewis
published: true
published_at: 2020-07-21T13:29:30.000Z
updated_at: 2021-05-05T10:23:30.596Z
category: tutorial
tags:
  - voice-api
  - nodejs
  - conference-call
comments: true
redirect: ""
canonical: ""
---
Having a Code of Conduct as a community organizer is only one part of the story—having well-thought-out ways to report and respond to bad behavior is also vital. At events I've run in the past, a phone number has been one way provided to attendees—they can either call or text the number and it forwards on to several organizers who have the responsibility to be available to deal with any issues. 

Today I'll show you how to build your own with the Vonage [Voice](https://developer.nexmo.com/voice/voice-api/overview) and [Messages](https://developer.nexmo.com/messages/overview) APIs, complete with a simple dashboard to download call recordings and log incoming messages.

You can find the final project code at <https://github.com/nexmo-community/node-code-of-conduct-conference-call>

## Prerequisites

* [Node.js](https://nodejs.org/en/) installed on your machine
* `node-cli`, which you can install by running `npm install nexmo-cli@beta -g`

Create a new directory and open it in a terminal. Run `npm init -y` to create a `package.json` file and install dependencies with `npm install express body-parser nunjucks uuid nedb-promises nexmo@beta`.

<sign-up number></sign-up>

## Set up Dependencies

Create an `index.js` file and set up the dependencies:

index.js

```js
const uuid = require('uuid')
const app = require('express')()
const bodyParser = require('body-parser')
const nedb = require('nedb-promises')
const Nexmo = require('nexmo')
const nunjucks = require('nunjucks')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

// Future code goes here

app.listen(3000)
```

Once you've done this, run `npx ngrok http 3000` in a new terminal, and take note of the temporary ngrok URL. This is used to make `localhost:3000` available to the public web.

## Buy a Virtual Number & Set up the Nexmo Client

Open another terminal in your project directory and create a new application with the command line interface (CLI):

```
nexmo app:create
  -> Select Capabilities: voice, messages
  -> Use the default HTTP methods? Y
  -> Voice Answer URL: https://NGROK_URL/answer
  -> Voice Event URL: https://NGROK_URL/event
  -> Messages Inbound URL: https://NGROK_URL/inbound
  -> Messages Status URL: https://NGROK_URL/event
  -> Private Key path: private.key
```

Take note of the Application ID shown in your terminal, then search for a number (you can replace GB with your country code):

```
nexmo number:search GB --sms --voice
```

Copy one of the numbers to your clipboard, buy it and link it to your application:

```
nexmo number:buy NUMBER
nexmo link:app NUMBER APP_ID
nexmo numbers:update NUMBER --mo_http_url https://NGROK_URL/sms
```

In `index.js`, initialize the Nexmo client:

```js
const nexmo = new Nexmo({ 
  apiKey: 'API_KEY', 
  apiSecret: 'API_SECRET',
  applicationId: 'APPLICATION_ID',
  privateKey: './private.key'
})
```

## Respond to an Incoming Call With Speech

Create the `GET /answer` endpoint and return a [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) with a single `talk` action:

```js
app.get('/answer', async (req, res) => {
  res.json([
    { action: 'talk', voiceName: 'Amy', text: 'This is the Code of Conduct Incident Response Line' }
  ])
})

app.post('/event', (req, res) => {
  res.status(200).end()
})
```

The `POST /event` endpoint will later have call data sent to it, and for now, should just respond with a `HTTP 200 OK` status.

**Checkpoint: Start your server by running `node index.js` and then call the number you bought with the CLI - you should have the message read aloud, and then the call should hang up. If there are issues, you can always check the number and application settings in the [dashboard](https://dashboard.nexmo.com).**

## Respond to an Incoming Call by Dialling In Organizers

Instead of just reading out the message, add the caller to a brand new conversation. We can control conversations with code, including adding multiple participants into the call - you only need to know the conversation name to do this. Replace the content of the `/answer` endpoint with:

```js
const conferenceId = uuid.v4()

res.json([
  { action: 'talk', voiceName: 'Amy', text: 'This is the Code of Conduct Incident Response Line' },
  { action: 'conversation', name: conferenceId, record: true }
])
```

This code generates a new unique ID and then adds the caller to a conversation which uses a name as an identifer (conversations are calls with one more more participants in this context). However, one-person conference calls are sad. Before `res.json()`, call each organizer and add them to the conference call:

```js
for(let organizerNumber of ['NUMBER ONE', 'NUMBER TWO']) {
  nexmo.calls.create({
    to: [{ type: 'phone', number: organizerNumber }],
    from: { type: 'phone', number: 'NEXMO NUMBER' },
    ncco: [
      { action: 'conversation', name: conferenceId }
    ]
  })
}
```

Each number must be in [E.164 format](https://developer.nexmo.com/voice/voice-api/guides/numbers#formatting), and you should replace `NEXMO NUMBER` with the number linked to your application. While testing, make sure the numbers in the array are not the same as the one you'll use to call.

**Checkpoint: Restart your server and call your Nexmo number. The application should ring in any numbers provided in the for() loop array.**

## Record the Call

When adding the caller to the conference call, `record: true` was passed as an option, and, as a result, the entire call was recorded. Once the call is completed, the `POST /event` endpoint is sent a payload containing the conversation ID and a recording URL. 

Before the existing endpoints create a new nedb database:

```js
const recordingsDb = nedb.create({ filename: 'data/recordings.db', autoload: true })
```

Once you restart your server, a file will be created inside of a `data` directory. Update the event endpoint to look like this:

```js
app.post('/event', async (req, res) => { 
  if(req.body.recording_url) {
    await recordingsDb.insert(req.body)
  }
  res.status(200).end()
})
```

**Checkpoint: Restart your server and call your Nexmo number. Once all participants hang up, you should see a new entry in the *data/recordings.db* file.**

## Create a Recordings Dashboard

Now the recording data is saved in a database; it's time to create a dashboard. Configure nunjucks before the first endpoint:

```js
nunjucks.configure('views', { express: app })
```

This sets up nunjucks to render any file in the `views` directory and links to the express application stored in the `app` variable. Create a `views` directory and an `index.html` file inside of it:

```html
<h1>Recordings</h1>

{% for recording in recordings %}
  <p>
    <a href="/details/{{recording.conversation_uuid}}">{{recording.start_time}}</a>
  </p>
{% endfor %}
```

Also create a `details.html` file in the `views` directory:

```html
<ul>
  <li>{{caller}}</li>
  <li>{{recording.timestamp}}</li>
  <li><a href="/details/{{recording.conversation_uuid}}/download">Download</a></li>
</ul>
```

Three endpoints are required in `index.js` to get these views working. The first one loads all of the recordings from the database and renders the index page:

```js
app.get('/', async (req, res) => {
  const recordings = await recordingsDb.find().sort({ timestamp: -1 })
  res.render('index.html', { recordings })
})
```

The page now looks like this, with latest recordings first:

![Web page showing one recording timestamp with a blue underline](/content/blog/create-a-code-of-conduct-incident-line-with-node-js/recordings-only.png "Web page showing one recording timestamp with a blue underline")

The next endpoint loads the details page after getting details from the Conversations API, including the phone number of the caller:

```js
app.get('/details/:conversation', (req, res) => {
  nexmo.conversations.get(req.params.conversation, async (error, result) => {
    const caller = result.members.find(member => member.channel.from != process.env.NEXMO_NUMBER)
    const number = caller.channel.from.number
    const recording = await recordingsDb.findOne({ conversation_uuid: req.params.conversation })
    res.render('detail.html', { caller: number, recording })
  })
})
```

Finally, an endpoint which gets the raw audio file from the API and sends it as a downloadable MP3:

```js
app.get('/details/:conversation/download', async (req, res) => {
  const recording = await recordingsDb.findOne({ conversation_uuid: req.params.conversation })
  nexmo.files.get(recording.recording_url, (error, result) => {
    res.writeHead(200, {
      'Content-Disposition': 'attachment; filename="recording.mp3"',
      'Content-Type': 'audio/mpeg',
    })
    res.end(Buffer.from(result, 'base64'))
  })
})
```

![A page showing a phone number, timestamp, and download link](/content/blog/create-a-code-of-conduct-incident-line-with-node-js/details.png "A page showing a phone number, timestamp, and download link")

**Checkpoint: Restart your server and call your Nexmo number. Once a call has completed, you should see the new entry on the dashboard. Go to the details page and download it.**

## Accept & Save SMS

Being a phone number, some people using this service may also send an SMS message to it. Using a similar pattern these messages will be stored and shown on the dashboard. Underneath the existing database creation, add a new one for messages:

```js
const messagesDb = nedb.create({ filename: 'data/messages.db', autoload: true })
```

Save new messages as they are received by creating an endpoint which we previously pointed to when setting up our virtual number:

```js
app.post('/sms', async (req, res) => {
  await messagesDb.insert(req.body)
  res.status(200).end()
})
```

Update the dashboard endpoint to also retrieve and display messages: 

```js
app.get('/', async (req, res) => {
  const recordings = await recordingsDb.find().sort({ timestamp: -1 })
  const messages = await messagesDb.find().sort({ 'message-timestamp': -1 })
  res.render('index.html', { recordings, messages })
})
```

Add this section to the bottom of `index.html`:

```html
{% for message in messages %}
  <p>{{message.msisdn}} ({{message['message-timestamp']}}): {{message.text}}</p>
{% endfor %}
```

![Web page showing both recordings and two example messages](/content/blog/create-a-code-of-conduct-incident-line-with-node-js/recordings-and-messages.png "Web page showing both recordings and two example messages")

**Checkpoint: Restart your server and send an SMS to your Nexmo number. You should see it appear on your dashboard once you refresh.**

## Forward SMS and Send a Response

Finally, update the SMS endpoint to both forward the message to organizers and respond to the sender:

```js
app.post('/sms', async (req, res) => {
  await messagesDb.insert(req.body)

  for(let organizerNumber of ['NUMBER ONE', 'NUMBER TWO']) {
    nexmo.channel.send(
      { type: 'sms', number: organizerNumber },
      { type: 'sms', number: 'NEXMO NUMBER' },
      { content: { type: 'text', text: `From ${req.body.msisdn}\n\n${req.body.text}` } }
    )
  }

  nexmo.channel.send(
    { type: 'sms', number: req.body.msisdn },
    { type: 'sms', number: 'NEXMO NUMBER' },
    { content: { type: 'text', text: 'Thank you for sending us a message. Organizers have been made aware and may be in touch for more information.' } }
  )

  res.status(200).end()
})
```

**Checkpoint: Restart your server and send an SMS to your Nexmo number. You should receive a response, and all listed organizers should also receive the message.**

## Next Steps

Congratulations! You now have a functional Code of Conduct Incident Response Line that works for both phone calls and SMS messages. If you have more time, you may want to explore:

* Implementing error handling
* [Detection of answering machines](https://developer.nexmo.com/api/voice#createCall)
* Using our new [Speech Recognition](https://developer.nexmo.com/voice/voice-api/guides/asr) to transcribe calls

You can find the final project code at <https://github.com/nexmo-community/node-code-of-conduct-conference-call>

As ever, if you need any support feel free to reach out in the [Vonage Developer Community Slack](https://developer.nexmo.com/community/slack). We hope to see you there.