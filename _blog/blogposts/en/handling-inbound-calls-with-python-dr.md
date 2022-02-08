---
title: Handle an Inbound Phone Call with Python
description: Learn how to handle inbound phone calls with Python.
thumbnail: /content/blog/handling-inbound-calls-with-python-dr/handle-inbound-phone-call.png
author: abedford
published: true
published_at: 2019-03-28T16:41:32.000Z
updated_at: 2021-05-12T23:03:46.674Z
category: tutorial
tags:
  - voice-api
  - python
  - inbound-calls
comments: true
redirect: ""
canonical: ""
---
This blog post shows you, step-by-step, how to create a Vonage application that can handle an inbound phone call using Python.

If you are new to Vonage, your account will be given some initial free credit to help get you started.

## Prerequisites

Assumes you have:

* Python 3 installed
* Access to two phones

<sign-up number></sign-up>

## Source Code Repository

The source code for this project is available on the [Vonage Community GitHub](https://github.com/nexmo-community/handling-inbound-call-python).

## Overview

In a Vonage application an inbound call can be handled in various ways depending on the requirement. Here are three simple scenarios:

1. Message - call is out of hours so you simply play a text-to-speech message.
2. Forward call - in this case the call is forwarded to an agent so that the customer can be helped.
3. Call waiting - the caller is put on hold, with a message and then soothing music, and then forwarded to an agent when one is available.

You will see how to implement all three of these scenarios in this article. The key is understanding Nexmo Call Control Objects, or NCCOs. NCCOs are discussed in more detail later.

## NCCOs

Nexmo Call Control Objects (NCCOs) provide a convenient way to control an inbound call. NCCOs essentially consist of some JSON configuration that describes how to handle the call. There is a detailed [reference guide on NCCOs](https://developer.nexmo.com/voice/voice-api/ncco-reference) where the many actions that can be carried out are described. There are three actions required here:

1. Scenario 1 - action is `talk`.
2. Scenario 2 - action is `connect`.
3. Scenario 3 - actions are: `talk`, then `stream`. Then when the agent can take the call `transfer` (via REST call) then `connect` to connect the caller to his phone.

NCCO actions can be linked together to meet the needs of more complex use cases.

It is possible to do many other things when you handle an inbound call, including record the call, and then later download the recording. Recording calls is not covered in this article, but will be covered in a future blog post.

## The Steps

A summary of the procedure you will carry out in this article is as follows:

1. Create a Vonage account
2. Install Ngrok
3. Run Ngrok
4. Install Flask
5. Install the CLI
6. Install the Python client library
7. Create a Vonage voice application
8. Purchase a number (if you do not have a spare one)
9. Assign your number to your application
10. Write your Python code to implement the scenario
11. Run your application
12. Phone your Vonage number
13. Listen to the Text to Speech message

## Install Ngrok

Go to [Ngrok](https://ngrok.com) and follow the instructions on getting set up.

## Run Ngrok

Run Ngrok:

```sh
ngrok http 9000
```

Make a note of the URL that Ngrok is running on. Such as `https://1234abcd.ngrok.io`. I am running on port 9000 in my example, but you can use any suitable port.

## Install Flask

The example code uses the Flask framework to create a web app that can handle inbound requests.

```sh
pip install flask
```

## Install the Vonage CLI

```sh
npm install -g @vonage/cli
vonage config:set --apiKey=XXXXXX --apiSecret=XXXXXX
```

## Install the Python Client Library

The client library is a useful tool to have installed if you are working with Vonage and Python. The client library simplifies the job of making Vonage API calls.

In this article it is used to make a single REST API call - "Update Call".

You can learn how to install the Python Client [in its repo](https://github.com/Nexmo/nexmo-python). The simple process is to use PIP:

```sh
pip install vonage
```

Please [read the documentation](https://github.com/Nexmo/nexmo-python#installation) for more details.

## Create a Vonage Voice Application

Create a directory for your project and change into that new directory.

Although you can create a Vonage application in the Dashboard, you can also create one on the command line if you have Vonage CLI installed. After running the below command, follow to prompts:

```sh
vonage apps:create
```

Make a note of the generated `APPLICATION_ID`, as you will need this later.

A private key is also created in your current directory.

The Answer URL is the URL that Vonage will call back on when a call to a Vonage number is answered. 

Nexmo posts event information that helps you monitor your call to the Event URL. In this article the sample code shown just acknowledges the POST, but the event data is not used.

## Purchase a Number

If you do not already have a Vonage Number you will need to purchase one.

First search for a suitable number:

```sh
vonage numbers:search [COUNTRYCODE]
```

> NOTE: You can change the country code to suit your requirements. For example if you are in the US you could replace `COUNTRYCODE` with `US` or for British numbers `GB`:

```sh
vonage numbers:search US
```

Choose a suitable number and then buy it using a command similar to:

```sh
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

> NOTE: You will need to confirm your purchase.

## Assign Your Number To Your Application

You now need to associate your Vonage Number with your Vonage Application:

```sh
vonage apps:link [APPLICATION_ID] --number=number
```

## Write Your Python Code

The Python code is more or less the same in each scenario, it is mainly the NCCO that provides the different functionality.

The code for scenario 3 is a little different in that the inbound call is handled in the usual way, but the agent being busy and then becoming available is simulated with a simple time delay. The code then transfers the waiting call to a new NCCO. The new NCCO connects the inbound caller to the now free agent.

### Scenario 1

Add the following to a new file and save it as `scenario-1.py`:

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

ncco = [
    {
        "action": "talk",
        "text": "Hello, our office hours are Monday to Friday nine until five thirty. Please call back then."
    }
]

@app.route("/webhooks/answer")
def answer_call():
    return jsonify(ncco)

@app.route("/webhooks/event", methods=['POST'])
def events():
    return ("200")

if __name__ == '__main__':
    app.run(host="localhost", port=9000)
```

You can also find the latest version of this code on the [GitHub repo](https://github.com/nexmo-community/handling-inbound-call-python/blob/master/scenario-1.py).

You can run your code locally using:

```
python3 scenario-1.py
```

Here's the outline of what happens:

1. You will dial your Vonage Number.
2. Nexmo receives the call.
3. A callback is generated on the Answer webhook URL you specified.
4. Your application receives the callback and responds with an NCCO.
5. At the end of the message the call is terminated by Vonage.
6. The NCCO controls the call, in this the action plays a text-to-speech message into the call.

#### Try It Out

Try it out by calling your Vonage number - you should hear the message!

### Scenario 2

The code to implement scenario 2 is similar to the first. The main
difference is the addition of a new NCCO action, `connect` to forward
the call to the agent. Create a new file `scenario-2.py` and add the
following code:

```python
from flask import Flask, request, jsonify

NEXMO_NUMBER = "44700000002"
YOUR_SECOND_NUMBER = "447700900001"

app = Flask(__name__)

ncco = [
    {
        "action": "talk",
        "text": "Hello, one moment please, your call is being forwarded to our agent."
    },
    {
        "action": "connect",
        "from": NEXMO_NUMBER,
        "endpoint": [{
           "type": 'phone',
           "number": YOUR_SECOND_NUMBER
         }]
    }
]

@app.route("/webhooks/answer")
def answer_call():
    return jsonify(ncco)

@app.route("/webhooks/event", methods=['POST'])
def events():
    return ("200")

if __name__ == '__main__':
    app.run(host="localhost", port=9000)
```

You can also find the latest version of this code on the [GitHub repo](https://github.com/nexmo-community/handling-inbound-call-python/blob/master/scenario-2.py).

> NOTE: Make sure you replace `NEXMO_NUMBER` and `YOUR_SECOND_NUMBER` with your own values.

You can run your code locally using:

```
python3 scenario-2.py
```

Here's the outline of what happens:

1. You will dial the Vonage Number.
2. Vonage receives the call.
3. A callback is generated on the Answer webhook URL you specified.
4. Your application receives the callback and responds with an NCCO.
5. The NCCO controls the call. This first action here plays a text-to-speech message into the call.
6. When the `talk` action in the NCCO completes, the `connect` action is then invoked, forwarding the call.
7. At this point the customer who called in is connected to the agent in a call, until one of them hangs up.

#### Try It Out

Try it out by calling your Vonage number - you should hear the message - then your call will be transferred to the second phone you specified (a spare mobile is always handy for testing when working with Vonage)!

### Scenario 3

In this scenario a caller is put on hold (listening to music) until an agent becomes available. The waiting call is then forwarded to the agent.

To make things a bit simpler the code simulates the agent being busy using a timer. After 40 seconds (configurable) the agent "becomes available", and then the inbound call is transferred to the agent.

Here's a summary of what the code does:

1. When the call comes in a suitable message is played.
2. Then as an agent is not available the caller is played soothing audio.
3. When an agent becomes free (after a time delay) the current call will be transferred to a new NCCO.
4. When the call is transferred to the new NCCO, which is `ncco2` in the server code, an message is played, and then the call is transferred to the agent in the same way you saw in scenario 2.

Add the following code to a new file `scenario-3.py`:

```python
from flask import Flask, request, jsonify
from threading import Timer
import nexmo

UUID = ""
APPLICATION_ID = "YOUR_APP_ID"
PRIVATE_KEY = "private.key"
TIMEOUT = 40 # Agent becomes available after this period of time
NEXMO_NUMBER = "447009000002" # Your Nexmo number
YOUR_SECOND_NUMBER = "447009000001" # Your second phone (agent)

audio_url = "https://your_domain.com/your_music.mp3"
ncco_url = "https://1234abcd.ngrok.io/ncco"

ncco = [
    {
        "action": "talk",
        "text": "Hello, I'm sorry, but all our agents are helping customers right now. Please hold, and we will put you through as soon as possible."
    },
    {
        "action": "stream",
        "streamUrl": [audio_url],
        "loop": 0
    }
]

ncco2 = [
    {
        "action": "talk",
        "text": "Now connecting you. Thanks for waiting."
    },
    {
        "action": "connect",
        "from": NEXMO_NUMBER,
        "endpoint": [{"type": 'phone',"number": YOUR_SECOND_NUMBER}]
    }
]

def transfer_call ():
    print ("Transferring call...")
    client = nexmo.Client(application_id = APPLICATION_ID, private_key=PRIVATE_KEY)
    dest = {"type": "ncco", "url": [ncco_url]}
    response = client.update_call(UUID, action="transfer", destination=dest)

def register_timer_callback():
    t = Timer(TIMEOUT, transfer_call)
    t.start()

register_timer_callback()

app = Flask(__name__)

@app.route("/webhooks/answer")
def answer_call():
    global UUID
    UUID = request.args['uuid']
    print("UUID:====> %s" % UUID)
    return (jsonify(ncco))

@app.route("/webhooks/event", methods=['POST'])
def events():
    return ("200")

@app.route("/ncco")
def build_ncco():
    return jsonify(ncco2)

if __name__ == '__main__':
    app.run(host="localhost", port=9000)
```

You can also find the latest version of this code on the [GitHub repo](https://github.com/nexmo-community/handling-inbound-call-python/blob/master/scenario-3.py).

There is also a [version of this code](https://github.com/nexmo-community/handling-inbound-call-python/blob/master/agent-free-api.py) that uses a `GET` request on the `/agentfree` path to transfer the call. This version requires a little manual intervention in that you need to navigate your browser to `localhost:9000/agentfree` in order to transfer the call.

> NOTE: Make sure you replace `NEXMO_NUMBER` and `YOUR_SECOND_NUMBER` with your own values. Also make sure you have a link to some suitable music for `audio_url`. Your `ncco_url` value will also depend on Ngrok or your method of deployment.

The transfer of an in-progress call to another NCCO is achieved with the "Update Call" REST API call. This REST API call, with an action of `transfer` will transfer the control call identified by the `UUID` to a specified NCCO.

The "Update Call" API call is made most conveniently using the Python client library, which you will need to have installed.

You can specify a static NCCO via a URL here, but in this case a more flexible approach is used, which is to call the server code on the `/ncco` URL. This method builds the NCCO and then responds with JSON for the new controlling NCCO. This new NCCO, `ncco2` in the server code, performs a `connect` action as you saw in scenario 2, connecting the caller, who is currently listening to music, to the agent.

You can now run your application locally with the following command:

```
python3 scenario-3.py
```

#### Try It Out

To test it out:

1. Call your Vonage number.
2. You will hear a message and then music.
3. After a short delay you will hear a message saying you will be connected to the agent. You are then connected to the agent in a call.

## Summary

We have covered quite a lot of ground in this article, but you should now have a good understanding of how you might control inbound phone calls. We looked at playing a text-to-speech message, playing audio into a call, and forwarding an inbound call to a second number. You also saw how to update a call in progress, and specifically transfer control to a new NCCO.

## Next Steps

* An interesting project would be to look into recording inbound calls. You can [see an example](https://developer.nexmo.com/voice/voice-api/code-snippets/record-a-call) to get started quickly.
* You could look into providing a keypad interface to allow the caller to control the call. You can [see an example](https://developer.nexmo.com/voice/voice-api/code-snippets/handle-user-input-with-dtmf) to get started quickly.

## Resources

* You can check out the full [documentation for NCCOs](https://developer.nexmo.com/voice/voice-api/ncco-reference) to learn many ways to control your call.
* You can learn about the [REST API for Voice](https://developer.nexmo.com/api/voice), known as VAPI.