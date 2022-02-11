---
title: "Improve Your Automatic Speech Recognition: Best Practices for IVRs"
description: Automatic Speech Recognition is powerful, but tricky. Learn a few
  ways to increase your chances of success when creating IVRs with the Vonage
  Voice API.
thumbnail: /content/blog/improve-your-automatic-speech-recognition-best-practices-for-ivrs/ivr_asr-1.png
author: garann-means
published: true
published_at: 2021-12-14T12:09:51.159Z
updated_at: 2021-12-11T22:09:55.712Z
category: tutorial
tags:
  - voice-api
  - ivr
  - node
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
If you want to make your call center menu more usable, replacing DTMF (numbered options punched in using the keypad) with IVR (Interactive Voice Response) can be a good place to start. But if you've ever felt conspicuous yelling something like "Pay my bill" into your phone with increasing frustration, you'll also know IVR isn't perfect. When you're doing IVR with the Vonage Voice API, there are a few things you can do to improve the experience.

## Give Context

You capture user input with ASR (Automatic Speech Recognition) with Vonage by creating an input action in a Call Control Object (NCCO). A basic NCCO with a voice prompt looks like this:

```javascript
  const ncco = [{
      action: 'talk',
      text: 'Thank you for calling the North Pole. Have you been naughty or nice?'
    }
  ];
```

You can collect answers to your prompt with ASR. To use ASR, you'll add `speech` as one value in the `type` array, and also supply a `speech` property with configuration. In `speech.context`, you can provide an array of likely responses. 

```javascript
  const ncco = [{
      action: 'talk',
      text: 'Thank you for calling the North Pole. Have you been naughty or nice?',
    },
    {
      action: 'input',
      type: ['speech'],
      eventUrl: [`https://${process.env.PROJECT_DOMAIN}.glitch.me/nice`],
      speech: {
        context: ['naughty','nice'],
        endOnSilence: 1,
        language: "en-US"
      }
    }
  ];
```

When the caller responds to a prompt, ASR will return an array of guesses. Each possible response will have a confidence rating, and the guesses will be ranked by confidence:

```javascript
[ { confidence: '0.5399828', text: 'naughty' },
  { confidence: '0.51581204', text: 'Eddie' },
  { confidence: '0.51581204', text: 'honey' },
  { confidence: '0.51581204', text: 'buddy' },
  { confidence: '0.51581204', text: 'Eddy' } ]
```

You can test the effect by replying with a homonym of one of the words in your `context` array. What you actually said should still appear with higher confidence, but you'll notice that homonyms often have the same confidence rating and providing words in the context helps guarantee the ones you're interested in are included in the list:

```javascript
[ { confidence: '0.5402811', text: 'howdy' },
  { confidence: '0.51581204', text: 'naughty' } ]
```

## Anticipate Errors

Artificial intelligence is really still in its infancy, and is prone to getting frustrated and throwing tantrums. You can very easily dump your caller off a call by assuming you'll get usable ASR results. 

When you're using Vonage to do ASR, your results will come back to you in `request.body.speech.results`. The way the `results` array behaves if there's an error may not be what you expect, however. Rather than having a length of 0, `results` is just undefined. So the check you'll need to do is for a separate property, `request.body.speech.error`. Its existence serves as a flag for your code that you don't have information about what to do next:

```javascript
  if (req.body.speech.error) {
    res.json([{
      action: 'talk',
      text: 'We could not understand your request. Santa will bring you socks.'
    }]);
  }
```

## Note Repeated Errors

Once you start down the ASR path, you're not committed to remain on it. If a caller is asked to repeat themselves, they may get frustrated. Worse, in a complex system every error is a new possibility that something isn't being handled and your caller is about to get dumped after spending five minutes yelling at a robot. 

Vonage gives you the tools to track which conversation a response belongs to. In the body of requests to your endpoints you'll find a UUID to uniquely identify a caller and call. However, because the endpoints are stateless, you'd have to store information about the conversation and the level of success the caller was having to use the UUID. 

Compared to managing a data store, NCCOs are very simple, and can be made even lighter by abstracting out repeated properties:

```javascript
function sendNCCO(res, prompt, endpoint, context) {
  const ncco = [{
    action: 'talk',
      text: prompt,
    },
    {
      action: 'input',
      type: ['speech'],
      eventUrl: [`https://${process.env.PROJECT_DOMAIN}.glitch.me/${endpoint}`],
      speech: {
        context: context,
        endOnSilence: 1,
        language: "en-US"
      }
  }];

  res.json(ncco);
}
```

You can create as many endpoints as you want, to handle whatever error counts you think callers can tolerate. They only need to contain data specific to that scenario:

```javascript
app.post('/nice_error', function(req, res) {
  if (req.body.speech.error) {
    sendNCCO(
      res,
      `We still couldn't understand you. Please say "naughty" or "nice".`,
      'nice_repeat_error',
      ['naughty','nice']
    );
  } else {
    // branches for naughty or nice
  }
});
```

Within endpoints where you feel it's time to give up, you can switch to DTMF or a live operator. 

## Learn More

To start creating IVR menus, you can check out our [documentation on ASR](https://developer.vonage.com/voice/voice-api/code-snippets/handle-user-input-with-asr) and the [detailed speech recognition settings](https://developer.vonage.com/voice/voice-api/ncco-reference#speech-recognition-settings). You can view and remix an [example IVR project on Glitch](https://glitch.com/edit/#!/vonage-ivr-menu).

We're always happy to talk through your use case and help troubleshoot in our [Community Slack channel](https://developer.vonage.com/slack).