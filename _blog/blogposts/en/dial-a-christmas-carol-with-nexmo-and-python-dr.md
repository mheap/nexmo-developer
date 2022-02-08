---
title: Dial a Christmas Carol with Nexmo and Python
description: Find out how to build your own 'Dial a Christmas Carol' hotline
  using Nexmo's Voice API, Python and a handful of festive sing-a-long classics.
thumbnail: /content/blog/dial-a-christmas-carol-with-nexmo-and-python-dr/Dial-a-Christmas-Carol.png
author: abedford
published: true
published_at: 2018-12-03T21:27:21.000Z
updated_at: 2021-05-04T15:56:38.453Z
category: tutorial
tags:
  - python
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*Note from the editor:* Want to give [Tony's](https://twitter.com/tonytechwriter) Dial-a-Carol service a try? We'll be hosting it throughout December for you to call! Just dial **[?? (44)-203-905-1327](tel:+442039051327)** or **[?? (1)-201-355-3236](tel:+12013553236)** and spread some Christmas cheer! 
--- 
It's nearly Christmas and another year has almost gone! 

I thought I would see out the year with a fun and easy piece of Python code to allow you to dial a Christmas carol to put a smile on your face - or make you cringe... 

Here's the main idea: 

1. You dial a Nexmo Number 
2. You hear a selection menu 
3. You make your choice 
4. You hear a cringeworthy carol! 

Awesome! 

## Getting Set Up 

<sign-up number></sign-up>

If you've not played with Nexmo to date I recommend our [documentation](https://developer.nexmo.com) as a first port of call. 

I am also going to assume you know how to configure your [webhooks](https://developer.nexmo.com/concepts/guides/webhooks). Also you can host your webhook server on a platform of your choice, or you can test locally using Ngrok. If you've not used Ngrok before I recommend you take a look at our [Ngrok tutorial](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) blog post and also read our [documentation](https://developer.nexmo.com/concepts/guides/webhooks#using-ngrok-for-local-development) on it. 

## Configuring Your Webhooks 
So, you are now ready to make sure you configure your webhooks. I will assume you are testing locally with Ngrok and you have them set along the following lines: 

Webhook | URL 

---- | ---- 

answer | https://abcdef1.ngrok.io:3000/webhooks/answer 

event | https://abcdef1.ngrok.io:3000/webhooks/event 

> **NOTE:** This assumes your webhook server is running on port 3000, but it can be any suitable port. 

There is one other webhook of interest in this tutorial, but you don't set it in the same way you set the Answer webhook or Event webhook URLs. It's the DTMF webhook that you will see in the next section. 

## The Answer Webhook 
When you dial into your Nexmo Number, you will hear an option menu. You can then select your carol by pressing a key on your phone keypad. This input is sent to your application via a `POST` on the DTMF webhook, which has the form `https://abcdef1.ngrok.io:3000/webhooks/dtmf`. 

So how does Nexmo know how to call back on this URL? You have to set the DTMF webhook in your Answer webhook code. 

Looking at the Answer webhook you see the following: 

``` python
@app.route("/webhooks/answer")
def answer_call():
    params = request.args
    input_webhook_url = request.url_root + "webhooks/dtmf"
    ncco = [
        {
            "action": "talk",
            "bargeIn": "true", 
            "text": menu
        },
        {
            "action": "input",
            "maxDigits": 1,
            "timeOut": 5,
            "eventUrl": [input_webhook_url]
        }
    ]
    return jsonify(ncco)
```

Looking at this code you can see that when your inbound call is answered, the [NCCO](https://developer.nexmo.com/voice/voice-api/ncco-reference) that controls the call sends you the option menu via Nexmo's Text-To-Speech capabilities, and also sets the DTMF webhook. This is how Nexmo knows where to call back on with input from the phone keypad. 

There's also a couple of parameters specified. The `timeOut` parameter in this case is set to slightly longer than the default of three seconds. In this case it gives you a five second period in which to respond with a key press before the system times out on waiting for input. `maxDigits` in this will make sure only one digit is accepted as input. 

The other parameter worth mentioning is `bargeIn` which is set to `true` in this case. This allows you to interrupt the option menu for those instances when you simply can't wait to hear your favourite carol! 

There is also more detailed [documentation on DTMF](https://developer.nexmo.com/voice/voice-api/guides/dtmf) you can read at your leisure. I just covered the basics here. 

## The DTMF Webhook 
You just saw how the Answer webhook works. Now you'll see how the DTMF webhook works. 

First here's the code: 

``` python
@app.route("/webhooks/dtmf", methods=['POST'])
def dtmf_webhook():
    data = request.get_json()
    selection = data['dtmf']
    if selection == "":
        selection = "1"
    index = int(selection)-1
    if index < 0 or index > len(tunes)-1:
        index = 0
    carol_url = base_url + tunes[index][1]
    print(tunes[index][1])
    msg = "Playing Christmas carol " + str(index+1)

    ncco = [
        {
            "action": "talk",
            "text": msg
        },
        {
            "action": "stream",
            "streamUrl": [carol_url]
        }
    ]
    return jsonify(ncco)
```


You can see we are only interested in a `POST` callback on this URL. Mostly this code is to make sure we handle the case where the user doesn't enter an option at all, or selects an option that's outside of the range presented in the option menu. The real action happens again in the NCCO. 

In the NCCO there is a little prompt message which announces which carol is going to be played. Then the `stream` action is used to play an MP3 file into the call. This feature is quite useful for things like on-hold music and so on, but we can use it in this case to get our festive fix. You only need to specify the URL and the music is, by amazing Nexmo magic, played into your call. 

## The Complete Code 
I've covered the most important parts of the code. Here's the complete code for your convenience: 

``` python
#!/usr/bin/env python3
from flask import Flask, request, jsonify
from pprint import pprint

app = Flask(__name__)

base_url = 'https://raw.githubusercontent.com/tbedford/git-testing-repo/master/tunes/xmas/'

# Tunes courtesy http://www.freexmasmp3.com/ 
tunes = [
    ["Little Town of Bethlehem", "bethlem-jazz.mp3"],
    ["Ding Dong Merrily", "ding-dong-merrily.mp3"],
    ["First Noel", "first-noel-r-and-b.mp3"],
    ["Jingle Bells", "jingle-bells-country.mp3"],
    ["Silent Night", "silent-night-piano.mp3"],
    ["Twelve Days of Christmas", "twelve-days-funk.mp3"]
]

# Build options menu 
menu = "Welcome to dial a Christmas carol. You can choose from the following cheesy carols."
i = 1
for t in tunes:
    menu = menu + " Option " + str(i) + " is " + t[0] +"."
    i = i + 1
menu = menu + " Please make your selection now."
    
@app.route("/webhooks/answer")
def answer_call():
    params = request.args
    input_webhook_url = request.url_root + "webhooks/dtmf"
    ncco = [
        {
            "action": "talk",
            "bargeIn": "true",
            "text": menu
        },
        {
            "action": "input",
            "maxDigits": 1,
            "timeOut": 5,
            "eventUrl": [input_webhook_url]
        }
    ]
    return jsonify(ncco)

@app.route("/webhooks/dtmf", methods=['POST'])
def dtmf_webhook():
    data = request.get_json()
    selection = data['dtmf']
    if selection == "":
        selection = "1"
    index = int(selection)-1
    if index < 0 or index > len(tunes)-1:
        index = 0
    carol_url = base_url + tunes[index][1]
    print(tunes[index][1])
    msg = "Playing Christmas carol " + str(index+1)
    
    ncco = [
        {
            "action": "talk",
            "text": msg
        },
        {
            "action": "stream",
            "streamUrl": [carol_url]
        }
    ]
    return jsonify(ncco)

@app.route("/webhooks/event", methods=['POST'])
def events():
    data = request.get_json()
    pprint(data)
    return ("OK")

if __name__ == '__main__':
    app.run(port=3000)
```

Once you have your application running, just dial into Nexmo using your Nexmo Number, make your selection from the options provided via your phone keypad, and listen to some festive fun. 

So, I hope you have enjoyed this Christmas code. 

I would like to take this opportunity to wish you all a very Merry Christmas and a Happy New Year! 

## Where next? 
The source code is available on GitHub: 
* [Dial a Carol source code](https://github.com/nexmo-community/dial-a-carol) 

Here are some resources that will be useful if you want to explore things further: 
* [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#input) - this describes the `input` action in detail. 
* [Ngrok tutorial](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) - a useful guide to testing your app locally. 
* [Webhooks](https://developer.nexmo.com/concepts/guides/webhooks) - everything you ever wanted to know about Webhooks but were afraid to ask.