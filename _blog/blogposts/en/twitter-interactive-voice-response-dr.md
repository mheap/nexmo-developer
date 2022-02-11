---
title: Building a Twitter IVR with text-to-speech and the Nexmo Voice API
description: Creating a simple Interactive Voice Response (IVR) system with
  text-to-speech using Python, Flask, Nexmo's Voice API and a virtual inbound
  number
thumbnail: /content/blog/twitter-interactive-voice-response-dr/tweet-to-talk.png
author: aaron
published: true
published_at: 2018-06-26T15:03:34.000Z
updated_at: 2021-05-13T11:20:12.853Z
category: tutorial
tags:
  - python
  - voice-api
  - twitter
comments: true
redirect: ""
canonical: ""
---
I'm a bit of a Twitter addict. Like many other techies, I joined when Twitter exploded in popularity at SXSW in 2007, and it still really shines as a way to keep track of what's going on at festivals or conferences.

But conference internet is usually not great. You could still Tweet via SMS, but without a data connection you can't follow the conference hashtag or search for tweets nearby to find out where to find the best after-party. But even if you don't have data, you can probably still make calls. Let's set up a Twitter bot we can control via a phone call and have it read out the tweets to us!

## Before we get started

There are a few things you'll need before we get started.

<sign-up number></sign-up>

* [Twitter account and a Twitter application](https://apps.twitter.com/); the Python Twitter library has some [good documentation on creating a Twitter application](https://python-twitter.readthedocs.io/en/latest/getting_started.html)
* If you're running this locally, you'll need a way of making your server public. [We suggest using ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

## Controlling our bot with DTMF

There might be several hashtags we want to follow, or perhaps we want to be able to check the latest tweets from a few different accounts. So we need some way of telling our bot which stream to read to us.

For this, we're going to use Dual-tone multi-frequency signalling (DTMF). When you dial a number on your phone that tone you hear is DTMF. With the Nexmo `input` action we ask the user to press a particular number and then vary the action we take based on the number entered. If you've ever had to call a customer support line before you've likely encountered an [interactive voice response (IVR) system](https://developer.nexmo.com/voice/voice-api/guides/interactive-voice-response), which is what we're about to create.

When a user calls, we'll read out a list of the available inputs, prompt them to make a selection, and then use the Twitter API and text-to-speech to read the relevant tweets to them.

## Creating an interactive voice response system with Python and Flask

When a user calls our virtual number, Nexmo will request our [Nexmo call control object (NCCO)](https://developer.nexmo.com/voice/voice-api/guides/ncco). The NCCO is a JSON file which contains a list of actions Nexmo should perform when someone calls our number. Let's look at an example.

```
[
  {
    "action": "talk", 
    "bargeIn": "true", 
    "text": "Welcome to Nexmo's talking Twitter. Please select from the following options. To hear the latest breaking news press 1. For showbiz gossip press 2. If you'd like to hear the latest #API tweets press 3. Or for tweets by Aaron Bassett press 4.", 
    "voice_name": "Amy"
  }, 
  {
    "action": "input", 
    "eventUrl": [
      "https://example.com/ivr/"
    ], 
    "maxDigits": 1
  }
]
```

The NCCO above has two actions: First, we use text-to-speech to let the caller know what their options are; we set `bargeIn` to true so that the caller can press the number at any time, without listening to the entire message, if they already know which option they want. The next action captures the number the user presses and POSTs it to our `eventUrl`. This `eventUrl` will return another NCCO, which will tell Nexmo what to do next.

## Converting tweets to speech

When our caller inputs a number it is sent as part of a POST request to our `/ivr/` endpoint. Using a few conditionals *(come on Guido just [let us have a switch statement already!](https://www.pydanny.com/why-doesnt-python-have-switch-case.html))* we can compare the user's input to our list of possible tweets and return each tweet as a `talk` action in our new NCCO. We'll use [text-to-speech to read the tweets out to the user](https://developer.nexmo.com/api/voice/ncco#talk).

If the user has entered a value we don't recognise, we play a short message telling them that their input was not understood, and then we start the process over again.

## Try it for yourself

[![view on Github](https://www.nexmo.com/wp-content/uploads/2017/06/view-on-github-button.png)](https://github.com/nexmo-community/nexmo-call-twitter)

The example code uses Python and Flask, so I recommend you create a new Python virtual environment and then you can clone the code and install the dependencies.

```
git clone git@github.com:nexmo-community/nexmo-call-twitter.git
cd nexmo-call-twitter/
pip install -r requirements.txt
```

There is a little configuration required; in the `app.py` [set the `event_url` to your ngrok URL followed by `/ivr/`](https://github.com/nexmo-community/nexmo-call-twitter/blob/b1058b9b9d5ea36ca98b37a2221760e73a5a6935/app.py#L13), and ensure to set the [required Twitter variables](https://github.com/nexmo-community/nexmo-call-twitter/blob/b1058b9b9d5ea36ca98b37a2221760e73a5a6935/app.py#L36-L41) in your environment. You can find details about how to [create a new Twitter application in the python-twitter documentation](https://python-twitter.readthedocs.io/en/latest/getting_started.html).

```
export TWITTER_CONSUMER_KEY=
export TWITTER_CONSUMER_SECRET=
export TWITTER_ACCESS_KEY=
export TWITTER_ACCESS_SECRET=
```

Once you have all the required variables set you can [run the Flask application](http://flask.pocoo.org/docs/0.12/quickstart/). Let's start it in development mode; this way we'll get some nice debug output if anything goes wrong. You'll need to create a couple more environmental variables for Flask.

```
export FLASK_APP=app.py
export FLASK_DEBUG=1
```

And once they are set we can run our application using:

```
flask run
```

Try visiting <http://127.0.0.1:5000> in your web browser. If everything is running correctly, you should see our NCCO. But to make this server reachable by the [Nexmo Voice API](https://developer.nexmo.com/voice/voice-api/overview), we'll need it to be public. So ensure ngrok is running and pointing at the correct port.

You will also need to configure your Nexmo voice application. The easiest way to do this is via our [Voice application management section of the Nexmo Dashboard](https://www.nexmo.com/blog/2017/06/29/voice-application-management-easier/). The Event URL does not matter in this example as we won't be working with any webhooks so set it and your Answer URL to your ngrok URL.

![screenshot of Nexmo voice application screen](/content/blog/building-a-twitter-ivr-with-text-to-speech-and-the-nexmo-voice-api/voice-your-applications-2017-07-24-13-41-10.png "screenshot of Nexmo voice application screen")

Once you have created/configured your voice application don't forget to link a telephone number to it!

## Give it a try

To try it out simply call the Nexmo virtual number you linked to your new voice application. You should hear the introductory message with your different options. Try entering different numbers or even a number which is not recognised and listen for the different messages you get back.

## Using your own data sources

Edit the example and change the Twitter accounts or hashtag you want to retrieve tweets from, but don't forget to update your introductory message to reflect your changes.

Of course, you don't have to pull your messages from Twitter. You can use any data source you like, find out [how your stocks are performing](https://www.programmableweb.com/news/96-stocks-apis-bloomberg-nasdaq-and-etrade/2013/05/22), always have a handy supply of [dad jokes](https://www.reddit.com/r/dadjokes), or even check what's at the top of [Hacker News](https://news.ycombinator.com/). 

```
ncco = []

topstories = requests.get('https://hacker-news.firebaseio.com/v0/topstories.json').json()
for x in range(0, 5):
    story = requests.get(
        'https://hacker-news.firebaseio.com/v0/item/{id}.json'.format(
            id=topstories[x]
        )
    ).json()

    ncco.append({
        'action': 'talk',
        'text': story['title']
    })
```

In fact, you can execute any code you like. We've all heard of ChatOps but what about IVROps?

### Press 1 to switch it off and back on again

![IT Crowd: Have you tried switching it off and back on again?](/content/blog/building-a-twitter-ivr-with-text-to-speech-and-the-nexmo-voice-api/giphy.gif "IT Crowd: Have you tried switching it off and back on again?")

Although you might want to build some authentication into that one…

```
[
    {
        "action": "talk",
        "text": "Please enter your PIN followed by the hash key"
    },
    {
        "action": "input",
        "submitOnHash": "true",
        "eventUrl": ["https://example.com/verifypin/"]
    }
]
```