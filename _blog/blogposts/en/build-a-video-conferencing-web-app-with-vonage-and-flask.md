---
title: Build a Video Conferencing Web App With Vonage and Flask
description: "This tutorial shows you how to add video conferencing to your website. "
thumbnail: /content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/add-video-conferencing.png
author: cory-althoff
published: true
published_at: 2021-12-10T12:37:21.739Z
updated_at: 2021-12-08T06:39:45.091Z
category: tutorial
tags:
  - python
  - video-api
  - flask
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
With the pandemic making remote work more prevalent than ever, video conferencing has become one of the primary ways we communicate with our friends, family, and coworkers. This change in how we communicate makes now an excellent time to learn how to build a video conferencing web app. This tutorial will show you how to quickly build a video conferencing web app using [Python](https://www.python.org/downloads/), [Flask](https://flask.palletsprojects.com/en/2.0.x/), JavaScript, and [Vonage’s Video API](https://www.vonage.com/communications-apis/video/). 

## Prerequisites

To follow along with this tutorial, you need to have a basic understanding of Python and web development.  

You also need to[ install Ngrok](https://ngrok.com/download). 

Finally, you will need to register for a free Vonage Video API account (formerly TokBox). 

## Initial Setup

To get started, we need to do some initial setup. 

First, [create your Video API account](https://tokbox.com/account/user/signup). 

Once you’ve created your account, you need to create a project.

Click on “Projects” and then “Create New Project.”

![Create new project](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/createnewproject.png)

Next, select “Create Custom Project.”

![](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/create-custom-project.png)

Now create a new project named “my_project.”

![My project](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/my_project.png)

\
Then click “Create.”

![Create](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/create.png)

Now click “View project.” 

![view project](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/api_key.png)

Make sure to save your project API key and secret; you will need them later.

Next, you need to [clone the GitHub repository](https://github.com/calthoff/vonageunlocked) containing this project’s code.

```
git clone https://github.com/calthoff/vonageunlocked.git
```

`cd` into your Github repository and open up the empty `.env` file that comes with it. 

```
cd vonageunlocked
vim .env
```

Add your Vonage Video API key and secret (that you saved earlier) to the `.env` file like this:

```
OPENTOK_API=your_api_key
OPENTOK_SECRET=your_secret
```

Next, create a virtual environment and activate it.

```
pip3 install virtualenv
virtualenv venv
source venv/bin/activate
```

Then, download the project’s dependencies:

```
pip3 install -r requirements.txt
```

Once you’ve done that, start up your Flask test server by running app.py:

```
python3 app.py
```

Finally, fire up ngrok on the same port as your Flask test server (you can [read Ngrok’s documentation](https://ngrok.com/docs) to better understand how ngrok works):

```
ngrok http 5000  
```

Now, head to the URL Ngrok gives you to see the video conferencing web app in action (the URL should look like this: `http://d584-172-112-188-34.ngrok.io`). 

You can now video conference with yourself using your phone and your computer or share the link with a friend to video conference with someone else. 

Go to `https://your_ngrok_link/admin` to stream video, and then `https://your_ngrok_link/join` to view it from another browser or device (make sure to log into the admin page first). 

You should see a website that looks like this:

![Web app working](/content/blog/build-a-video-conferencing-web-app-with-vonage-and-flask/web_app_working.png)

This web app also lets you chat!

## How It Works 

Let’s take a look at how it works. 

First, it imports the Flask, Decouple, and Opentok (the Vonage Video API) libraries. Flask is a popular Python web development framework.

```python
from flask import Flask, render_template, request
from decouple import config
from opentok import Client
```

Next, it loads your Vonage Video API key and secret from environmental variables. 

```python
opentok_api = config('OPENTOK_API')
opentok_secret = config('OPENTOK_SECRET')
```

Then it creates a Vonage Video API client and passes it your API key and secret, which it then uses to create a new Vonage Video API session. 

```python
client = Client(opentok_api, opentok_secret)
session_id = client.create_session().session_id
```

When you use the Vonage Video API, everything happens in a session. You can publish a video to a session and consume video from a session. Each session has a unique ID. In this case, you create a new session and save the session’s ID in `session_id`. 

Next, this code creates a Flask app:

```python
app = Flask(__name__, static_url_path='')
```

With Flask, you can easily map a URL to a function like this:

```python
@app.route('/test', methods=['POST', 'GET'])
def index():
    return "Hello, World!"
```

If you add this code to app.py and visit `/test` on your local server, you should see `“Hello, World!”`

This project maps three URLs to HTML templates using Flask’s `render_template` method. One function maps `/admin` to `admin.html`, and the other maps `/join` to `join.html`. 

```python
@app.route('/admin')
def admin():
   return render_template('admin.html')


@app.route('/join')
def join():
   return render_template('join.html')
```

\
These two HTML templates let you log in either as an admin or a regular viewer. 
You see them when you go to `/join` or `/admin` in the web app. 

You can find the complete HTML for each template in the templates folder of your repository. 

Let’s take a look at how the index function in app.py works.

```python
@app.route('/', methods=['POST', 'GET'])
def index():
   if request.method == 'POST':
       token = client.generate_token(session_id)
       admin = False
       if 'admin' in request.form:
           admin = True
       name = request.form['name']
       return render_template('index.html', session_id=session_id, token=token, is_admin=admin, name=name,
                              api_key=opentok_api)
   return 'please log in'
```

Every user that joins a Vonage Video API session needs a unique token. 

So when a  post request comes in, the code generates a new token using the Vonage Video API.
Next, the code checks to see if the user is an admin or not by checking if ‘admin’ is in `request.form` (of course, you wouldn’t want to do this in a production application). 

```python
if 'admin' in request.form:
    admin = True
```

Then, this code grabs the user’s name from `request.form`. 

```python
 name = request.form['name']
```

Finally, this code uses `render_template` to render `index.html` and pass in the session ID you created earlier, the token you created earlier, whether the user is an admin, and their name to the `index.html` template. 

```python
return render_template('index.html', session_id=session_id, token=token, is_admin=admin, name=name,
```

The `index.html` template then uses those variables to display the video to whoever joins. 

Let’s quickly take a look at what happens on the front-end. 

First, the `index.html` template loads this script:

```javascript
<script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
```

If the user isn’t an admin, a JavasScript file with the following code from `viewer_video.js` runs:

```javascript
const sessionId = document.querySelector('#session_id').dataset.name;
const apiKey = document.querySelector('#api_key').dataset.name;
const token = document.querySelector('#token').dataset.name;

// Initialize session
const session = OT.initSession(apiKey, sessionId)

session.on("streamCreated", function (event) {
  session.subscribe(event.stream);
});

session.connect(token);
```

This JavaScript code gets the session ID, API key, and token from the backend.

```javascript
const sessionId = document.querySelector('#session_id').dataset.name;
const apiKey = document.querySelector('#api_key').dataset.name;
const token = document.querySelector('#token').dataset.name;
```

Then, it creates a session object (note that it does not create a new session).

```javascript
const session = OT.initSession(apiKey, sessionId)
```

Next, your front-end code subscribes to the session. 

```javascript
session.on("streamCreated", function (event) {
  session.subscribe(event.stream);
}); 
```

Finally, you connect to the session by calling `session.connect` and pass the token you generated on the back-end. 

```javascript
session.connect(token);
```

If the user is an admin, the code from `admin_video.js` runs instead.
The way it works is similar to `viewer_video.js`.

Your code creates a session object.

```javascript
const session = OT.initSession(apiKey, sessionId)
```

Next, it creates a publisher so that the admin can stream the video to the viewers. 

```javascript
const publisher = OT.initPublisher("opentok-publishers", {
 videoSource: c1.captureStream().getVideoTracks()[0],
 width: 320,
 height: 240
})
```

Once your code connects to the session, it publishes the publisher. 

```javascript
session.connect(token, () => {
 session.publish(publisher)
})
```

And finally, it subscribes the user to the stream, so the admin can see their video while streaming. 

```javascript
session.on('streamCreated', event => {
 session.subscribe(event.stream, "opentok-subscribers")
})
```

## Final Thoughts

You now know how to quickly add video conferencing to a web app using Vonage’s Video API and Flask. 
There is some extra code in the project on the front-end I didn’t cover, which overlays your name onto the video. You can [learn more about how that works in this article](<>). 

[Let us know on Twitter](https://twitter.com/VonageDev) what projects you build using the Vonage Video API!

Also, make sure to [join our community on Slack](https://app.slack.com/client/T24SLSN21/C24QZH6E7). 

Thanks for reading!