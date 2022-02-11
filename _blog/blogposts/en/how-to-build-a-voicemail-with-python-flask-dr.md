---
title: How to Build a Voicemail Dead-Drop with Python and Flask
description: In this tutorial we take inspiration from the greatest of spy
  thrillers and show you how to build a custom voicemail service using Python &
  Flask.
thumbnail: /content/blog/how-to-build-a-voicemail-with-python-flask-dr/python-dead-drop.png
author: judy2k
published: true
published_at: 2019-04-05T08:39:13.000Z
updated_at: 2021-05-13T00:01:04.291Z
category: tutorial
tags:
  - voice-api
  - python
  - flask
comments: true
redirect: ""
canonical: ""
---
*I picked up the grubby handset of the public payphone and dialled the number, like I had a hundred times before.*

"This is Oleg's Pizza. Leave a message after the beep."

That was all it ever said - there was never a real person at the other end of the line - just a robotic voice from an unlikely business.

**\[BEEP]** - *somewhere a tape started recording. I left my message.*

"Hi, this is Chuck. I'd like a pepperoni and mushroom pizza please."

I dropped the handset and walked away.

My name's not Chuck, and I don't like pepperoni, but this would get the message across:
my cover was blown, and by Monday I'd be gone, just a fading memory in the minds of those who knew me.

- - -

I love a good spy thriller, and it seems like one of the hardest parts of being a spy is finding a dead-drop to leave messages for your handler. Fortunately, in this post, I'm going to make life easier for all you spooks out there by showing you how to make a dead-drop phone number where you can leave messages for someone to pick up later on the Web.

## Prerequisites

I'm going to assume you've read Aaron's awesome post describing how to use [Ngrok for developing webooks](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/). If you haven't go read it now - it's worth it.

I'm also going to assume you have a basic knowledge of Python and Flask.

I recommend installing the [Vonage CLI tool](https://github.com/Vonage/vonage-cli) and reading the [short blog post](https://learn.vonage.com/blog/2021/09/21/vonage-cli-is-v1-0-0/) about how to install it- some of the instructions below will use it, although you can complete these actions in the [Nexmo Dashboard](https://dashboard.nexmo.com/) if you prefer.

<sign-up number></sign-up>

## What You're Going To Build

I'm going to show you how to build a basic voicemail service that allows people to call your Nexmo number and leave a message.

The recorded message will be copied to your server, and you'll build a simple web page that lists the recordings and allows you to play them in the browser.

## Starting Your Project

If you'd rather just follow along with my existing code, you can find that [here](https://github.com/nexmo-community/python-voicemail-dead-drop), but I recommend you follow along with this post and build it yourself!

The structure of our project folder looks like this:

![Initial project structure](/content/blog/how-to-build-a-voicemail-dead-drop-with-python-and-flask/initial_structure.png)

Because this is a small project, all your Python code will go in `answerphone/__init__.py`, but if it was larger, you could split it out into separate modules under the `answerphone` package.

You'll also put our static resources under `static` and your templates in `templates` and Flask will then know where to find them.

I've chosen to save my MP3 recordings into a project-level `recordings` folder, outside of the `answerphone` package, because it's a good idea to separate data (especially things being downloaded from the Internet!) from executable code.

You can't see it in the image above, but there's also a `.env` file in the project directory, which contains all my configuration.

## Install Dependencies

In my project, I've used [pip-tools](https://github.com/jazzband/pip-tools) to pin my dependencies, but if you haven't used pip-tools before, I recommend you paste the following straight into `requirements.txt` and then run `pip install -r requirements.txt`:

```bash
python-dotenv~=0.10
flask~=1.0
tinydb~=3.13
nexmo~=2.3
```

A quick rundown of our dependencies:

* *dotenv* will be used to load config from our `.env` configuration file.
* *flask* is our web framework and development web server.
* *tinydb* is a really simple database that stores all your data as json.
* *nexmo* is the Nexmo Python Client Library, and makes using Nexmo APIs simpler than doing it by hand.

Open up `__init__.py` in your `answerphone` package and type the following:

```python
from flask import Flask

@app.route("/answer", methods=["GET", "POST"])
def answer():
    """
    An NCCO webhook, providing actions that tell Nexmo to read a statement
    to the user and then record a message.
    """
    return jsonify(
        [
            {
                "action": "talk",
                "text": "<speak>You have reached <phoneme alphabet='ipa' ph='əʊlɛgz'>Oleg's</phoneme> pizza. Please leave a message after the beep.</speak>",
                "voiceName": "Brian",
            },
            {
                "action": "record",
                "beepStart": True,
                "eventUrl": [ "https://example.com/recording" ],
                "endOnSilence": 3,
            },
        ]
    )
```

Make sure you're running Ngrok and start your development server with:

```bash
FLASK_ENV=development FLASK_APP=answerphone flask run
```

Now if you visit `https://your-random-id.ngrok.io/answer` with your web browser you should see something like the following:

```json
[
    {
        "action": "talk",
        "text": "You have reached Oleg's pizza. Please leave a message after the beep.",
        "voiceName": "Brian"
    },
    {
        "action": "record",
        "beepStart": true,
        "eventUrl": [
            "https://example.com/recording"
        ],
        "endOnSilence": 3
    }
]
```

Now let's create a Voice app and link a number to this URL. In your console, run the Vonage CLI tool which will walk you step-by-step of creating your application:

```bash
# Create an app
vonage apps:create
```

It will print something like `Application created: 26aa5db4-546a-11e9-8f2d-0f348a273d3a`, and it will create a file called `private.key` in your current directory.

Take this ID and paste it into a new `.env` file like so:

```dotenv
NEXMO_PRIVATE_KEY="./private.key"
NEXMO_APPLICATION_ID=26aa5db4-546a-11e9-8f2d-0f348a273d3a
```

Leave this for now - I'll explain how to load the configuration in a moment.

If you need to buy a number, I'd recommend doing it in the [Nexmo Dashboard](https://dashboard.nexmo.com/buy-numbers).

Once you've bought a number (make sure it supports Voice!) go back to your command-line and use the `nexmo` command to link the number to your app:

```bash
# Replace the phone number with your own
# and the application ID with your application ID!
nexmo link:app 447700900606 26aa5db4-546a-11e9-8f2d-0f348a273d3a
```

Now, if you call your Nexmo number, you should hear the message in the `talk` action above: "You have reached Oleg's pizza. Please leave a message after the beep." Okay!

Check your Ngrok logs. You may notice some 404 errors to `/event`. Don't worry about this right now - you'll add an event webhook later in this tutorial.

Unfortunately, once Nexmo has finished recording your message, it is currently making a POST request to the URL in your `record` action, which is set to `https://example.com/recording`.

Let's fix that so you can receive the recording event and download the MP3, so your handler can pick up messages from their agents.

In your `__init__.py`, add the following:

```python
# Add to your imports:
from dotenv import load_dotenv
from flask import request, url_for
import nexmo

# After your imports:
load_dotenv()   # Loads .env config into `os.environ`

client = nexmo.Client(
    application_id=os.environ["NEXMO_APPLICATION_ID"],
    private_key=os.environ["NEXMO_PRIVATE_KEY"],
)

@app.route("/new-recording", methods=["POST"])
def new_recording():
    recording_bytes = client.get_recording(request.json['recording_url'])
    recording_id = request.json['recording_uuid']
    with open(f"recordings/{recording_id}.mp3", 'wb') as mp3_file:
        mp3_file.write(recording_bytes)
    return ""
```

and now modify your `answer` webhook.
The second action should look like this:

```python
{
    "action": "record",
    "beepStart": True,
    "eventUrl": [url_for("new_recording", _external=True)],
    "endOnSilence": 3,
},
```

You're now using Flask's `url_for` function to get a URL pointing to the `new_recording` webhook you just added to the file.

Make sure your `recording` folder exists, and then restart the Flask development server.

Now, when you call your Nexmo number and leave a message, you should find an MP3 file in the `recording` folder. Open it up in your favourite MP3 player to hear what it says!

If you wanted to, you could stop now - you've learned all the basics about how to get Nexmo to record a message,
and then how to download that message to your server (Nexmo only stores the recording for you for a few hours).

*But* it would be a good idea to store some metadata along with the audio, so you know who the caller was, and when they called. That way, you can add a page listing all the calls to your answerphone dead-drop.

I chose [TinyDB](https://tinydb.readthedocs.io/en/latest/) to do this - it's a really simple little data-store that dumps your data to a JSON file. It's not very fast, and it won't store lots of data very well, but it's fine for this project!

Add the following to your `.env` file: `DATABASE_PATH=answerphone.db`.

You tell TinyDB to store data in this file with the following near the top of your `__init__.py` file:

```python
from tinydb import TinyDB, Query

db = TinyDB(os.environ["DATABASE_PATH"])
```

Now add the following, to create two "tables" to store your caller data and your recording data:

```python
calls = db.table('calls')
recordings = db.table('recordings')
```

You need to do two things now: You need to respond to call events and record the call data when a call is answered;
and you need to add a couple of lines to your `recording` webhook so that it stores recording data in the database.

First, add the `event` webhook:

```python
@app.route("/event", methods=["POST"])
def event():
    if request.json.get('status') == 'answered':
        calls.insert(request.json)

    return ""
```

The line `calls.insert(request.json)` stores all of the request's JSON data in the `calls` table you
created above.

Now, add a similar line to your `recording` webhook, after the code to save the MP3 file to your `recordings` folder:

```python
...

with open(f"recordings/{recording_id}.mp3", 'wb') as mp3_file:
    mp3_file.write(recording_bytes)

recordings.insert(request.json)

return ""
```

Make a call to your Nexmo number again and leave a message. Check that it runs without any errors.

If you have a look inside `answerphone.db` you should see a load of stored JSON data. Now let's load that data into a nice web page!

First, add a view that will allow you to load an MP3 file into the browser:

```python
@app.route("/recordings/<uuid>")
def recording(uuid):
    response = make_response(open(f'recordings/{uuid}.mp3', 'rb').read())
    response.headers['Content-Type'] = 'audio/mpeg'
    return response
```

The code above opens the binary MP3 file, creates a response from the bytes, and then sets the content-type header to 'audio/mpeg' which is the correct type for MP3 data.

You can test this by going loading up the "/recordings/you-uuid-goes-here" URL using the id of one of the MP3 files in your recordings folder.

Now you should add a view that will list all of the recordings, along with some of the call data associated with each recording.

This can be made easier with a small helper class.

Put this code near the top of your `__init__.py` file:

```python
class Recording:
    def __init__(self, data):
        self.uuid = data['recording_uuid']
        related_calls = calls.search(Query().conversation_uuid == data['conversation_uuid'])
        if related_calls:
            self.related_call = related_calls[0]
        else:
            self.related_call = None
```

This class is designed to be initialized using the JSON data provided to the `recording` endpoint and stored in the `recordings` table in our database.

It automatically looks up the associated call data in the `calls` table and adds it on to the Recording object as the `related_call` attribute.

Now write the following view code, which passes a `Recording` instance to the view for every
recording stored in the database:

```python
@app.route("/")
def index():
    """
    A view which lists all stored recordings.
    """
    return render_template("index.html.j2", recordings=[Recording(r) for r in recordings])
```

This will fail at the moment, because you haven't created a template file!

Create a file at `answerphone/templates/index.html.j2` and put something like the following inside:

```html
<!doctype html>
<html>
    <head>
        <title>Oleg's Pizza</title>
    </head>
    <body>
        <h1><i>"Oleg's Pizza"</i><br>Dead Drop Recordings</h1>
        {% for recording in recordings -%}
            <h2>Call From: <em>{{ recording.related_call.from }}</em></h2>
            <p><strong>When:</strong> {{ recording.related_call.timestamp }}</p>
            <a href="/recordings/{{ recording.uuid }}">Listen</a>
        {% endfor -%}
    </body>
</html>
```

Now, if you visit your `https://localhost:5000/` you should see something like the following:

![Recording list](/content/blog/how-to-build-a-voicemail-dead-drop-with-python-and-flask/recording_list.png)

You're now a master spymaster!

I'll summarize what you've just done:

* You responded to an incoming phone call with some NCCO actions.
* You instructed Nexmo to record part of a phone call
* You handled the recording event to download the created MP3 file.
* You stored call data in a database and created a web-browsable playlist!

## Further Information

If you want to dig a bit deeper into what you just learned, the following may be useful:

* [Nexmo Voice Recording Guide](https://developer.nexmo.com/voice/voice-api/guides/recording)
* [TinyDB Documentation](https://tinydb.readthedocs.io/en/latest/)
* [Python-DotEnv Documentation](https://github.com/theskumar/python-dotenv)

Also, check out the [GitHub Repo](https://github.com/nexmo-community/python-voicemail-dead-drop) for this project, as I've documented the code and improved the list view.

## Next Steps

There are a few ways to take this project further. You could use a websocket to notify the browser when a new recording appears, so the handler doesn't have to reload the browser to get messages from their agent.

You could also use [Nexmo's SMS API](https://developer.nexmo.com/messaging/sms/overview) to send the handler an SMS message when a new recording is available!

If you make something cool, send us an email at [devrel@nexmo.com](mailto:devrel@nexmo.com) to let us know!