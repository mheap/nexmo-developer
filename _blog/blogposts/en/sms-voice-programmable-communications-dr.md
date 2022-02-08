---
title: Getting Started with SMS and Voice Programmable Communications
description: "SMS and Voice programmable communications: Sending SMS and
  Receiving SMS, Making Phone Calls and Receiving Phone Calls using Nexmo Voice
  and SMS APIs."
thumbnail: /content/blog/sms-voice-programmable-communications-dr/programmable-sms-and-voice.png
author: leggetter
published: true
published_at: 2017-03-03T14:04:35.000Z
updated_at: 2021-05-18T08:15:11.514Z
category: tutorial
tags:
  - sms-api
  - voice-api
comments: true
redirect: ""
canonical: ""
---
We recently ran a webinar with [David Leary](https://twitter.com/davidleary) from [Intuit Developer](https://developer.intuit.com/) to go over the basics of using the Nexmo SMS and Voice APIs. If you are planning to attend the upcoming Intuit [Small Business Hack](http://www.smallbizhack.com/) and want a heads-up of what's possible, or if you're just interested in getting a quick overview of SMS and Voice programmable communications with Nexmo, here are the sections of the webinar that directly address sending an SMS, receiving an SMS, making an outbound phone call and receiving an inbound phone call. All examples also come with code snippets and links to further in-depth reading.

<sign-up number></sign-up>

### How to Send an SMS

This section of the webinar covers how to send an outbound SMS. It covers using alphanumeric senders and using a number that has been purchased from Nexmo as the `from` number.

<youtube id="Z0DAXW_rHPM"></youtube>

```js
const Nexmo = require('nexmo');

const nexmo = new Nexmo({
apiKey: API_KEY,
apiSecret: API_SECRET,
}, {debug: true});

nexmo.message.sendSms(
FROM_NUMBER,
TO_NUMBER,
'Hello from @leggetter', (error, result) =&gt; {
if(error) {
console.error(error);
}
else {
console.log(result);
}
});
```

For more information on sending an SMS check out our post on [sending an SMS with Node.JS](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/), the [SMS API guide](https://docs.nexmo.com/messaging/sms-api) and [SMS API reference](https://docs.nexmo.com/messaging/sms-api/api-reference). When sending SMS you may also want to know if the message has been delivered. To achieve this you can register for an [SMS Delivery Receipt](https://docs.nexmo.com/messaging/sms-api/api-reference#delivery_receipt). There's also a blog post on [receiving an SMS delivery receipt with Node.JS](https://learn.vonage.com/blog/2016/11/23/getting-a-sms-delivery-receipt-from-a-mobile-carrier-with-node-js-dr/).

### How to Receive an SMS

In this part of the webinar we cover receiving an inbound webhook containing the inbound SMS information.

<youtube id="Z0DAXW_rHPM"></youtube>

```js
const Nexmo = require('nexmo');

const app = require('express')();
app.set('port', (process.env.PORT || 5000));
app.use(require('body-parser').urlencoded({ extended: false }));

app.listen(app.get('port'), () =&gt; {
console.log('Example app listening on port', app.get('port'));
});

app.post('/sms', (request, response) =&gt; {
console.log('Received message text "%s"', request.body.text);

response.sendStatus(200);
});
```

You can find more info on receiving an SMS in our post on [receiving an SMS with Node.JS](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/), the [SMS API guide](https://docs.nexmo.com/messaging/sms-api) and [SMS API reference](https://docs.nexmo.com/messaging/sms-api/api-reference).

### How to Make an Outbound Phone Call

Here's how to make an outbound phone call using the Nexmo Voice API.

<youtube id="Z0DAXW_rHPM"></youtube>

```js
const Nexmo = require('nexmo');

const nexmo = new Nexmo({
apiKey: API_KEY,
apiSecret: API_SECRET,
applicationId: APPLICATION_ID,
privateKey: PRIVATE_KEY
});

nexmo.calls.create({
to: [{
type: 'phone',
number: TO_NUMBER
}],
from: {
type: 'phone',
number: FROM_NUMBER
},
answer_url: ['https://nexmo-community.github.io/ncco-examples/conference.json']
}, (err, res) =&gt; {
if(err) { console.error(err); }
else { console.log(res); }
});
```

We have a blog post that covers [ making an outbound phone call with Node.JS](https://learn.vonage.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/), there's a [Voice outbound phone call API guide](https://docs.nexmo.com/voice/voice-api/calls) and of course a [Voice API reference](https://docs.nexmo.com/voice/voice-api/api-reference). Also, take a look at the [NCCO reference](https://docs.nexmo.com/voice/voice-api/ncco-reference) for information on controlling Nexmo conversations and calls as used in the `answer_url` in the above example.

### Receiving an Inbound Phone Call

Finally, here's how to receive and control an inbound phone call. This introduces the concept of [Nexmo Conversation Control Objects (NCCOs)](https://docs.nexmo.com/voice/voice-api/ncco-reference).

<youtube id="Z0DAXW_rHPM"></youtube>

```js
const Nexmo = require('nexmo');

const nexmo = new Nexmo({
apiKey: API_KEY,
apiSecret: API_SECRET,
applicationId: APPLICATION_ID,
privateKey: PRIVATE_KEY
});

const app = require('express')();
const bodyParser = require('body-parser');
app.set('port', (process.env.PORT || 5000));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.listen(app.get('port'), () =&gt; {
console.log('Example app listening on port', app.get('port'));
});

app.get('/answer', (request, response) =&gt; {
console.log('Incoming call from "%s"', request.query.from);

// record - All or part of a Call No
// conversation - A conference.
// connect - To a connectable endpoint such as a phone number
// talk - Send synthesized speech to a call
// stream - Send audio files to a call
var ncco = [
// {
// action: 'talk',
// text: 'hello from me',
// loop: 3,
// bargeIn: true
// },
{
action: 'stream',
streamUrl: ['http://www.ladyofthecake.com/rdmp3/theme.mp3'],
loop: 3,
bargeIn: true
},
{
action: 'input',
eventUrl: ['https://nexmo.ngrok.io/event']
}
];

response.json(ncco);
});

app.post('/event', (request, response) =&gt; {
console.log('Received event', request.body);

response.sendStatus(200);
});
```

More info on receiving an inbound phone call is covered in our post on [receiving an inbound phone call with Node.JS](https://learn.vonage.com/blog/2017/01/26/handle-inbound-text-speech-phone-call-node-js-dr/), in the [Voice inbound phone call API guide](https://docs.nexmo.com/voice/voice-api/inbound-calls) and the [Voice API reference](https://docs.nexmo.com/voice/voice-api/api-reference). The above example also mentions `record`, `talk`, `stream` and other NCCO actions. So, take a look at the [NCCO reference](https://docs.nexmo.com/voice/voice-api/ncco-reference) for information on controlling Nexmo conversations and calls.

### More Programmable Communications Goodness!

There's lots more information about Nexmo APIs in the docs that haven't been mentioned above. For example, the [Verify API](https://docs.nexmo.com/verify/api-reference) for 2FA and one-time passwords and [Number Insight](https://docs.nexmo.com/number-insight) for looking up information on phone numbers. We've also got a selection of [programmable communications tutorials](https://docs.nexmo.com/tutorials) that cover building specific communications use cases such as [private voice communications](https://docs.nexmo.com/tutorials/voice-api-proxy), [SMS customer support](https://docs.nexmo.com/tutorials/sms-customer-support), [interactive voice response](https://docs.nexmo.com/tutorials/voice-simple-ivr), and more using the Nexmo APIs.

If you're going to Small Business Hack, good luck, and we'll see you there. If you just dropped by to learn about programmable communications we hope you find this useful. Either way, feel free to join the [Nexmo Community Slack](https://nexmo-community-invite.herokuapp.com) if you have any questions.