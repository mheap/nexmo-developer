---
title: "How to Build a Nexmo Notifier with Nexmo Messages and Python: Part One"
description: Monitor Nightscout, an open source dashboard for type 1 diabetics
  with Python, firebase, Google auth, and Nexmo Messages API
thumbnail: /content/blog/nightscout-notification-nexmo-dr/E_Nightscout-Notifier_1200x600-1.png
author: diana-rodriguez
published: true
published_at: 2020-02-24T18:09:04.000Z
updated_at: 2021-05-24T13:21:39.429Z
category: tutorial
tags:
  - python
  - messages-api
  - firebase
comments: true
redirect: ""
canonical: ""
---
In this tutorial, we'll be building **Scout**, an application created using [Python](https://www.python.org/) with [Flask](https://palletsprojects.com/p/flask/). On the client side, we'll use JavaScript for certain dynamic functionalities required for our app. This tutorial is split into two parts—in the first, we'll set up Google auth, build a user interface, and implement a Firebase Firestore.

The final version of the code can be found <a href="https://github.com/alphacentauri82/nexmo-scout">here</a>, if you're curious to see it all put together!

## Services Involved

Scout relies on four services for its operation:

* **[Nightscout](https://nightscout.info)**, an open-source project that supports cloud access to data from a variety of CGM (continuous glucose monitoring) devices.

![The Nightscout user interface](/content/blog/how-to-build-a-nexmo-notifier-with-nexmo-messages-and-python-part-one/nightscout1.png "The Nightscout user interface")

* **[Nexmo](https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=github&utm_campaign=https://github.com/alphacentauri82/nexmo-scout)** for sending and receiving SMS messages.
* **[Google auth](https://developers.google.com/identity/protocols/OAuth2):** The API that allows us to use the Google authentication service for our web application.
* **[Firebase/Firestore](https://firebase.google.com/docs/firestore)**, to store our data in the cloud.

## Application Features

Scout allows us to ping the Nightscout data of a user obtaining the last blood glucose level recorded. If levels are below 70mg/dL(3.9 mmol/L) or above 240mg/dL(13.3 mmol/L), the application will execute a call to the user's mobile phone number, and the user will hear their current blood glucose level. If the user does not respond, a text message will be sent to the user's preferred emergency contact and up to 5 additional numbers.

The ping frequency to Nightscout is set to one minute. To be exact, it will be done 30 seconds after each minute using the system clock. If a user's glucose level remains out of the standard range during that time, the call will be made again.

If the Nightscout service does not respond for 1 hour, an SMS will be sent alerting the user that their service is offline.

The user can sign up/login using their Google account and configure the following information:

* Nightscout API URL
* Personal number
* Preferred emergency contact and up to 5 additional phone numbers

![Scout dashboard](/content/blog/how-to-build-a-nexmo-notifier-with-nexmo-messages-and-python-part-one/dashboard1.png "Scout dashboard")

## Application Structure

Our application can be divided into two parts:

* A Flask app that allows the user to log in and configure the application data
* A Python Thread with a scheduler that runs with a given frequency, consulting the Nightscout dashboard of each user and sending alerts when necessary. A second scheduler that runs less frequently can be assigned to obtain fresh data.

## Prerequisites

* Python 3.x.x
* An application directory:

  ```
  mkdir Scout
  cd Scout
  ```
* Flask:

  ```
  pip install Flask
  ```
* `dotenv`,`requests`, and `google-auth` Python libraries:

```
pip install requests python-dotenv google-auth`
```

* A unique key to store our session variables. It's a binary that we have to handle discreetly. Generate with the following:

```
python -c 'import os; print (os.urandom (16)) '`
```

## User Interface Development and Google Auth

In this section, we will start configuring Google auth. We will also create a simple interface for calling the Google auth API, a login view, and a persistent server-side session to keep us logged in until the user decides to log out.

### Google Auth

To use Google auth, we have to obtain a `client ID`, which we will use to call the Google API sign in. Head to the [Google Cloud dashboard](https://console.cloud.google.com/home/dashboard), and create a new project.

* Once the project has been created, click on the navigation menu `(≡)` and select *APIs & Services> Credentials*.
* Click on *Create Credentials> OAuth client ID*.
* Select *Web*.
* In *Authorized JavaScript sources* and *Authorized redirection URIs* write the domain name to be used for this app, e.g. `https://domain.ext/`. In our case we will assume that `/` will be the endpoint that will consume our authentication service.
* Click on *Create* and our client ID will be generated. It should be listed on *OAuth 2.0 client IDs*. Keep the client ID at hand, as we will use it later.

### Diving into the Source Code

Once we are done with all our preparations, let's open our favorite editor (for example, pyCharm or Visual Studio Code). Create a new file. You can name it whatever you want, in my case I chose `notifier.py`.

At the very beginning of the file we will import the following modules:

```python
import json, os
from flask import Flask, request, render_template, session
```

In the same way, we import some functions that will allow us to read the environment variables. A secure way to handle credentials is to make them available only in the scope of the operating system that runs the application.

```python
from os.path import join, dirname
from dotenv import load_dotenv
```

Let's include the modules for Google auth that will allow us to reconfirm the identity of the user from the backend. This will allow us to create a persistent session if the identity is valid.

```python
from google.oauth2 import id_token
import google.auth.transport.requests
```

And the requests module that allows us to request using the POST or GET methods. It's similar to Axios.

```python
import requests
```

Create a new file and name it `.env` (In the tutorial repo I named it `.example-env`. If using my repo, make sure you rename it!) Add the following lines:

```
GOOGLE_CLIENT_ID="YOUR_GOOGLE_AUTH_CLIENT_ID"
SITE_URL="YOUR_SITE_URL"
```

**Note:** Replace`YOUR_GOOGLE_AUTH_CLIENT_ID` with the `clientID` generated by google, and `YOUR_SITE_URL` with the domain name you registered previously (`https://domain.ext`). Save the file!

- - -

Let's go back to `notifier.py` and add the following lines:

```python
app = Flask(__name__)
app.secret_key = [THE KEY YOU PREVIOUSLY GENERATED]
```

We assigned the variable `app` to represent. our Flask application.`app` will create its own context to make only operations related to the requests made to the Flask application

Then we assign the secret_key attribute. Paste the value previously generated with `python -c 'import os; print(os.urandom(16))'`.

To access the environment variables defined in the `.env` file, we add the following:

```python
envpath = join(dirname(__file__),"./.env")
load_dotenv(envpath)
```

Now, let's define the `get_session` function that evaluates whether there is a specific key within the session variable, returning `None` in case it doesn't exist, and the value of the key otherwise. It can be reused in different sections of the program:

```python
def get_session(key):
    value = None
    if key in session:
        value = session[key]
    return value
```

In the following section we begin to define our Flask application with the controller for the endpoint `/`, which will be our landing page and will show us the Google login button:

```python
@app.route('/',methods=['GET','POST'])
def home():
    if get_session("user") != None:
        return render_template("home.html", user = get_session("user"))
    else:
        return render_template("login.html", client_id=os.getenv("GOOGLE_CLIENT_ID"), site_url=os.getenv("SITE_URL"))
```

The line `@app.route('/,methods=['GET','POST'])` indicates that every request, either `GET` or `POST`, will be directed to the `home()` handler. The `home` function evaluates whether the user session exists, then loads the `home.html` template if the user is authenticated. If the user is not authenticated, we load the `login.html` template, where the Google authentication interface will be displayed (we pass the value of `GOOGLE_CLIENT_ID` and `SITE_URL` previously defined in our `.env` file. The second parameter will be used for redirection).

Following the workflow, when the user first enters the site the user session variable will not exist, therefore `login.html` will be loaded. The next logical step would be to develop the `home.html` jinja template. But before doing that we need to do the following:

* Create a new `static` directory within your main application directory:

```
mkdir static
```

* Download [Materialize](https://materializecss.com/getting-started.html), a framework for front-end development based on material design. Unzip the file and move the `css` and`js` directories into the previously created `static` directory. Ideally, keep only the minified versions of the `css` and `js` files.
* Download the [Materialize icons](https://fonts.googleapis.com/icon?family=Material+Icons). Once downloaded, create a new `fonts` directory within `static`, and move the font file there.
* Create `style.css` in the `static/css/` directory. Usually Materialize is more than enough to style an app, but sometimes an additional style file is necessary to control certain details not covered by Materialize. Let's add some extra style:

```css
@font-face {
  font-family: 'Material Icons';
  font-style: normal;
  font-weight: 400;
  src: url(/static/fonts/google-icons.woff2) format('woff2');
}

.material-icons {
  font-family: 'Material Icons';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
  -moz-font-feature-settings: 'liga';
  -moz-osx-font-smoothing: grayscale;
}

.logo {
  font-size: 30px !important;
  padding-top: 5px;
}

div.g-signin2 {
  margin-top: 10px;
}

div.g-signin2 div {
  margin: auto;
}
div#user {
  margin-top: 10px;
  margin-bottom: 10px;
}
div#user.guest {
  text-align: center;
  font-size: 20px;
  font-weight: bold;
}
div#user.logged {
  text-align: right;
}
div#user.logged a {
  margin-left: 10px;
}
body {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}
main {
  flex: 1 0 auto;
}
div.add_contact {
  height: 20px;
}
div.add-contacts-container {
  padding-bottom: 40px !important;
}
.input-field .sufix {
  right: 0;
}
i.delete {
  cursor: pointer;
}
```

Now, we are ready to create our app's layout. We start by creating a parent template that defines blocks of content that are used by other child files. Officially, this will be our first jinja template 🎉. In order for this file to be recognized by Flask as a template, let's create a `templates` directory inside `static`, and create `layout.html`. Let's add the following code:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <link
      rel="stylesheet"
      href="{{ url_for('static', filename='css/materialize.min.css') }}"
    />
    <link
      rel="stylesheet"
      href="{{ url_for('static', filename='css/style.css') }}"
    />
    {% block head %}{% endblock %}
  </head>
  <body>
    <header class="container-fluid">
      <nav class="teal">
        <div class="container">
          <div class="row">
            <div class="col">
              <a href="#" class="brand-logo"
                ><i class="material-icons logo">record_voice_over</i> Scout =
                Nexmo + Nightscout</a
              >
            </div>
          </div>
        </div>
      </nav>
    </header>
    <main class="container">
      {% block content %}{% endblock %}
    </main>
    <footer class="page-footer teal">
      <div class="footer-copyright">
        <div class="container">
          <!--This is the hashtag used by the nightscout project :) -->
          Scout <a class="brown-text text-lighten-3">#WeAreNotWaiting</a>
        </div>
      </div>
    </footer>
    <script
      language="javascript"
      src="{{ url_for('static', filename='js/materialize.min.js') }}"
    ></script>
    {% block script %}{% endblock %}
  </body>
</html>
```

There are a couple of interesting details to highlight: **The use of blocks** and **the use of the `url_for` function**. Blocks are reserved sections for inserting code with jinja from child templates. The `url_for` function generates the URLs to the JavaScript and CSS resources in `static`.

The file structure that we have up to this point should be:

```
    - static/
      - css/
        - materialize.min.css
      - fonts/
        - google-icons.woff2
      - js/
        - materialize.min.js
    - templates/
    - layout.html
    .env
    - notifier.py
```

If everything looks proper, create `login.html` in the same `templates` directory. This file will be loaded when the `user` session variable does not exist (that is, the user is not logged in).

```html
{% extends "layout.html" %} {% block head %}
<script src="https://apis.google.com/js/platform.js" async defer></script>
<meta name="google-signin-client_id" content="{{ client_id }}" />
{% endblock %} {% block content %}
<div id="user" class="guest">Welcome guest, You need to authenticate</div>
<div class="row">
  <div class="col s6 offset-s3">
    <div class="card blue-grey darken-1">
      <div class="card-content white-text">
        <span class="card-title">Login To Enter Scout</span>
        <p>
          This application will help you configure alerts to your mobile phone,
          a preferred emergency contact and up to 5 other contacts. If you have
          a nightscout dashboard and you have your api available for external
          queries, You can use this server and when your glucose levels are out
          of range, you will receive a call to alert you and your preferred
          contact(s) of such. If you do not answer the call then a sms is sent
          to your emergency contact(s).
        </p>
        <div class="g-signin2" data-onsuccess="onSignIn"></div>
      </div>
    </div>
  </div>
</div>
<script language="javascript">
  function onSignIn(googleUser) {
    var profile = googleUser.getBasicProfile()
    if (profile.getId() !== null && profile.getId() !== undefined) {
      var xhr = new XMLHttpRequest()
      xhr.open('POST', '{{ site_url|safe }}/login')
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
      xhr.onload = function() {
        console.log('Signed in as: ' + xhr.responseText)
        //Authenticated so redirect to index
        window.location = '{{ site_url|safe }}/'
      }
      xhr.send(
        'idtoken=' +
          googleUser.getAuthResponse().id_token +
          '&username=' +
          profile.getName() +
          '&email=' +
          profile.getEmail()
      )
    }
  }
</script>
{% endblock %}
```

Notice that the first line for `login.html` is `{% extends "layout.html"%}`. This indicates that `login.html` inherits from `layout.html`. In other words, it is a child of `layout.html`. This means that the renderer will load `layout.html` with the code variants that we added in `login.html`. These variants are defined within the blocks allowed in layout. Within `login.html` we use the `head` and `content` blocks.

In the `head` block, we have:

```html
<script src="https://apis.google.com/js/platform.js" async defer></script>
<meta name="google-signin-client_id" content="{{ client_id }}" />
```

The first line indicates that we will be using the Google API for the authentication process and the second is metadata used by Google to know our app's `clientID`. Note that within the `content` attribute we have written `{{client_id}}`. When the jinja compiler evaluates this expression, it will print the value of the `client_id` variable that we pass to the template using the `render_template` function.

The next block is `content`, and in there, we present a message to the user indicating how the application works. Then we have a few lines of JavaScript. Basically, it is a function connected to the `onSignIn` event, which is used by Google to return the data of the user that was logged in using Google auth.

We obtain the user profile with `googleUser.getBasicProfile()`. If there is an ID, the authentication process was successful, and we can proceed to send some data to our server to make an identity reconfirmation with Google and create the session.

```javascript
var xhr = new XMLHttpRequest()
xhr.open('POST', '{{ site_url|safe }}/login')
xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
xhr.onload = function() {
  console.log('Signed in as: ' + xhr.responseText)
  //Authenticated so redirect to index
  window.location = '{{ site_url|safe }}/'
}
xhr.send(
  'idtoken=' +
    googleUser.getAuthResponse().id_token +
    '&username=' +
    profile.getName() +
    '&email=' +
    profile.getEmail()
)
```

The previous lines connect us to our server using an AJAX request. Pay attention to the line `xhr.open ('POST', '{{site_url|safe}}/login');`. It indicates the method that the request will use. The URL `{{site_url|safe}}` will be replaced by the value of the `site_url` variable that we pass to the template. To do the reconfirmation, our Flask application only needs the `id_token`. However, we also pass the username and email since we will use them later for other operations.

Once the reconfirmation is done, our server will redirect us to `/`. If the reconfirmation was not successful, the user will have to try to log in again. Now, if we look carefully, we haven't defined the `/login` endpoint yet. this endpoint will be responsible for reconfirming.

To create it, let's go back to `notifier.py` and add the following lines:

```python
@app.route('/login',methods=["POST"])
def login():
    try:
        token = request.form.get("idtoken")
        client_id = os.getenv("GOOGLE_CLIENT_ID")
        infoid = id_token.verify_oauth2_token(token, google.auth.transport.requests.Request(), client_id)
        if infoid['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            raise ValueError('Wrong issuer.')
        userid = infoid['sub']
        #Here is a good place to create the session
        session["user"] = {"userid": userid, "username": request.form.get("username"), "email": request.form.get("email")}
        return userid
    except ValueError:
        return "Error"
        pass
```

As mentioned above, to reconfirm the identity of the user on the server, we only need the `id_token` obtained from Google auth and passed to `/login` using an AJAX POST request. Then we get `client_id` using `os.getenv("GOOGLE_CLIENT_ID")`.

When we make the reconfirmation, we place our code within a `try/except` block for exception handling in case an error occurs at the time of making the request.

This verification is done using the `verify_oauth2_token` method and returns an `infoid` that must have a key `iss`, which is a reference to the`issuer`. If the value of the issuer does not match the domain we configured, we assume the verification returns an error and an exception will be generated. If, on the other hand, the response is valid, we proceed to create the persistent session on the server side, assigning `user` to the session object. Within this session, we store the `userid`, `username`, and `email` of the user.

Once this is done, our server returns the response and the `xhr.onload` event of our ajax request is triggered. Its function is to redirect us to `/`. In `/` our application evaluates if the `user` session exists, and if so, it will load the `home.html` template by passing the `session['user']`.

Following the logic of our application, the next step is to create `home.html` in the`templates` directory:

```html
{% extends "layout.html" %} {% block content %}
<div id="user" class="logged">
  you are logged in as <b>{{ user.username }}</b> -
  <a id="logout" class="teal-text" href="/logout">Logout</a>
</div>
{% endblock %}
```

This template inherits from layout, and in our `content` block we will show the logged user and a`logout` link to close the session. The latter is not programmed—to complete the login experience we will define the endpoint `logout` in `notifier.py`. Let's add:

```python
    @app.route('/logout')
    def logout():
        session.pop("user",None)
        return redirect(url_for('home'))
```

Our `logout` endpoint deletes the user session and redirects us to `home`. Back at `home` it will evaluate the session, and if it doesn't find any, it will render `login.html`.

**Note:** `url_for` uses the handler name `def home()` for redirection, not the endpoint (although it is also valid to use endpoints for redirects). In the case of `url_for` needing to generate a url in `https`, the line should be: `url_for ('home', _external = True, _scheme = 'https')`. The external parameter indicates the generation of an absolute URL and scheme defines the protocol we want to use.

At this point, we can test if Google auth works. To test locally, let's run the following command in our terminal:

```sh
    export FLASK_APP=notifier
    flask run
```

We are telling Flask to run `notifier.py`. However, it's best to use a more robust server that allows for more efficient handling of our requests, thus improving the app performance. Therefore, we will use Gunicorn, an HTTP WSGI server written in Python and compatible with multiple frameworks (Flask included).

To install, let's execute the following command in our terminal:

```sh
    pip install gunicorn
```

After installing, from the same terminal window and from our app's root directory, type:

```sh
    gunicorn -b 0.0.0.0:80 notifier:app
```

This command deploys our application to our local server and listens for requests using port 80. With this, we should be able to access our app and test if we can log in and log out.

**Note:** To stop the application, hit *ctrl+c* in the same terminal window where gunicorn is running.

## Storing Nightscout Settings with Firebase/Firestore

In this section, we will build a simple interface where our user can add the following data:

* **nightscout_api**: a valid Nightscout URL to obtain the glucose level data, (for example, `https://domain.ext/api/v1/entries.json`).
* **phone**: the mobile number where alerts will be sent.
* **emerg_contact**: preferred emergency contact (relative or close friend who can receive alerts).
* **extra_contacts**: an optional array with up to 5 additional phone numbers.
* **email**: The Google account email address to log in (we will use it as an external key to obtain the logs of a logged-in user).
* **username**: Also obtained from the user's Google account, we will use it for data presentation.

[Firestore](https://firebase.google.com/docs/firestore) allows us to handle *collections* and *documents* in a similar fashion to [mongodb](https://www.mongodb.com/). For this application, our collection will be called *scouts*. A document from our collection should look like this:

```json
{
  "email": "",
  "username": "",
  "phone": "",
  "emerg_contact": "",
  "nightscout_api": "",
  "extra_contacts": []
}
```

## Adding Firebase Firestore to Our Project

* Go to <https://firebase.google.com/>
* Log in with your Google or GSuite account
* Click on *Go to Console*
* Click on *Add project*. If your previously created project used for Google auth does not appear on the list, click on *Add project* . We should see our project name listed on *Enter the name of your project* . Select it and click on *Continue*, Provide additional information for the next steps, and when finished click on *Create project*
* On the Firebase console page, click on *authentication* and in the *sign in method* tab, enable *Google*.
* Click on *Database*, and select *FIRESTORE*. Then *Database > Tab Rules*. Modify the existing rule as follows:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

This is to make sure only logged in users have access to our application.

### Connecting the Project with Firebase

Once our project is set up on the Firebase console, we have to generate a Firebase key:

* Login to <https://console.firebase.google.com/>
* Click on *Project Overview> Project settings* and select the *Service account* tab
* Click on the generate new private key option
* Save the JSON file in our application's root directory. You can rename that file to whatever you want. I used: `super_private_key.json`

The next step is to add the name of your private key file to `.env` with the following line:

```
FIREBASE_PRIVATE_KEY="./super_private_key.json"
```

With these initial preparations in order, we are ready to connect our application to Firebase/Firestore. In the case of data queries for Firestore, the ideal scenario in Python would be to have a class that we can reuse in our application that allows us to add, modify, or query records (CRUD). This way we keep our code simple, organized, and much easier to understand.

Before we write that code, we need to install the Python modules that will allow us to perform these operations (back to our terminal!):

```sh
pip install firebase-admin
```

Let's create the `models.py` file and add the following lines:

```python
    import firebase_admin, os
    from firebase_admin import credentials
    from firebase_admin import firestore
    from os.path import join, dirname
    from dotenv import load_dotenv
```

The previous lines indicate which modules we will be using in our `models.py` file. Among these, we can see `firebase_admin`, which we will use to connect to our Firebase project and perform operations (CRUD) on our *scouts* data collection. We will use `dotenv` to get the `FIREBASE_PRIVATE_KEY` variable from our `.env` file.

In the same file, add the following lines:

```python
    envpath = join(dirname(__file__),"./.env")
    load_dotenv(envpath)

    credits = credentials.Certificate(os.getenv("FIREBASE_PRIVATE_KEY"))
    firebase_admin.initialize_app(credits)
```

The first two lines are well known since we have previously used them in `notifier.py` to load our **environment** to extract the value of the `FIREBASE_PRIVATE_KEY` variable. The next two lines connect our application with Firebase using the private key we generated earlier. `credits = credentials.Certificate (os.getenv (" FIREBASE_PRIVATE_KEY "))` extracts the private key from the file as well as other additional data, and `firebase_admin.initialize_app (credits)` authenticates our application to use Firebase and initializes it to perform operations.

Once the connection with Firebase is defined, we will proceed to define the case model. Normally, when we use technologies such as `SQLAlchemy` to work with`flask` ​​and `sqlite`, the models are classes where we define different attributes that are the fields of the database and use a set of native functions of the model to perform operations on the database.

In our case, we will create the `model` class as a "bridge" class that will allow us to use the firestore methods to perform database operations. In other words, `model` will function as a parent class from which other classes will inherit to return their methods. Then we add the code to the end of the `models.py` file:

```python
    class model:
        def __init__(self,key):
            self.key = key
            self.db = firestore.client()
            self.collection = self.db.collection(self.key)
        def get_by(self, field, value):
            docs = list(self.collection.where(field,u'==',u'{0}'.format(value)).stream())
            item = None
            if docs != None:
                if len(docs) > 0:
                    item = docs[0].to_dict()
                    item['id'] = docs[0].id
            return item
        def get_all(self):
            docs = self.collection.stream()
            items = []
            for doc in docs:
                item = None
                item = doc.to_dict()
                item['id'] = doc.id
                items.append(item)
            if len(items) > 0:
                return items
            else:
                return None
        def add(self, data, id=None):
            if id == None:
                self.collection.add(data)
            else:
                self.collection.document(u'{0}'.format(id)).set(data)
            return True
        def update(self, data, id):
            if id != None:
                if data != None:
                    doc = self.collection.document(u'{id}'.format(id=id))
                    doc.update(data)
            return False
```

Within the `model` class, we start defining our constructor. It will accept the `key` parameter representing the name of the collection inside Firestore. The builder also initializes the firestore client, `self.db= firestore.client()`, and the collection, `self.db.collection(self.key)`.

The `get_by` method receives the name of the field and the value by which we want to filter data from our collection. The line `docs= list(self.collection.where (field,u'==',u'{0}.format(value)).stream())` runs a query to our Firebase collection, `self.collection`, and is a reference to this collection defined in the constructor. In our collection, we use the `where` method to filter by field and value.

Pay special attention to the character `u`—this indicates that Python will send the field name and the value in `unicode` format. By using the code fragment `u'{0}.format(value)` we are telling Python that any value, regardless of type, should be formatted as `unicode`. The `stream` method, in turn, returns the flow of documents as a special type of data, so the `list` function is used to convert it into an array that can be traversed with Python.

Normally, when making a query to Firestore to obtain data from a collection, for each record in the collection we would obtain an object with two attributes: the document id and the `to_dict()` method that formats the document to the Python dictionary type of data (a format that has a structure similar to JSON and that makes it easy for us to access each field).

The `get_by` function evaluates whether the document exists. If it exists, it creates a consolidated item with `item= docs[0].to_dict()` to store the document in a variable. With `item['id']= docs[0].id`, we add the id to the document to have all the information at our disposal. Another important detail is that `get_by` returns the first document found. We leave this as it is in our case. Once our user logs in with Google, they will only have access to a document that will contain their data (one and only one).

We define the `get_all` method, which does not receive any parameters. Its function is to obtain all the documents in a collection, consolidate them by creating a dictionary for each item, and fill out an array with each consolidated document. This function returns an array of all the documents in the collection, or `none` in case there are no documents.

The `add` method receives the `data` and `id` parameters. `id` is optional, but if it exists it allows us to add a new document with a defined id. If the parameter `id` does not exist, the new document will be created with an id automatically generated by Firestore. The parameter `data` must be of type `dictionary` and will contain the data that we want to add to our collection.

Finally, we define the `update` method, which receives the parameters `data` and `id`, both of which are required. While `data` contains a `dict` indicating which fields will be altered with what values, `id` defines which document in the collection we will be modifying.

Next, we will add the `scout` class. The purpose of this class is to act as an interface that allows us to pass the data of our scout collection more directly without thinking of unnecessary formatting when adding new documents. Let's add the following code to `models.py`:

```python
    class scout:
        def __init__(self, email = '', username = '', nightscout_api = '', phone = '', emerg_contact = '', extra_contacts = []):
            self.email = email
            self.username = username
            self.nightscout_api = nightscout_api
            self.phone = phone
            self.emerg_contact = emerg_contact
            self.extra_contacts = extra_contacts
```

**Note:** We will go into more detail on how this class will be used later.

Finally, let's add the `scouts` class that inherits from the`model` class to reuse its methods and in turn has its own methods to interact with the scout collection. Let's add the code at the end of the `models.py` file:

```python
    class scouts(model):
        def __init__(self):
            super().__init__(u'scouts')
        def get_by_email(self, email):
            docs = list(self.collection.where(u'email',u'==',u'{0}'.format(email)).stream())
            item = None
            if docs != None:
                if len(docs) > 0:
                    item = docs[0].to_dict()
                    item['id'] = docs[0].id
            return item
        def getby_personal_phone(self,phone):
            return self.get_by(u'phone',phone)
        def add(self, data, id = None):
            if type(data) is scout:
                super().add(data.__dict__,id)
            else:
                super().add(data,id)
```

The scouts class inherits from the model. In its constructor we call the parent constructor and pass it `scouts`, which is nothing more than the key that the `model` constructor expects to reference a collection in Firebase.

Then we find the `get_by_email` method, which obtains the first document from the `scouts` collection that matches the email provided. This method will be used to obtain the Nightscout data of each user connected using a Google account.

The method `getby_personal_phone` receives a phone parameter (the user's personal telephone) and will return the document associated with that data. This method calls the `get_by` method of the`model` class and it will be very useful to obtain user data when we are running the `nexmo` events webhook.

Finally, we have the `add` method.  IF `data` is an instance of the`scout` class, we will convert its attributes to dictionary with `data.__dict__`. The `id` attribute is optional for this method. Pay attention that this method, in turn, calls the `add` method of the model class for reuse.

Don't forget to send the file!!⭐️

### Playing with the Python Console

A very practical (and maybe fun?) way to test what we have done is with the Python console. Before the fun begins, open the Firebase console in your browser and click on the *Database* option. Make sure to select *Cloud Firestore* in the upper left corner next to *Database*.

Let's go to our terminal. From our project folder, execute the `python` command. This will take us to the Python console where we can run Python code. In the python console, we execute the following commands:

* Import our previously created python module:

```
>>> import models 
>>> from models import model, scouts, scout
```

* Create an instance of the scouts class called `scout_firebase` and add a document to Firebase. Review the Firebase console after executing the `add` method. In Firestore, a new document will be added with the data provided. Pay special attention to the add method—we pass an instance of the `scout` class with all the corresponding data. Internally the `add` method converts the instance of the class to dictionary:

```
>>> scouts_firebase= scouts()
>>> scouts_firebase.add(scout(email='email@gmail.com ',nightscout_api ='someurl', phone ='12345678', emerg_contact='23456789', extra_contacts=['34567890']))
```

* Get all the documents from our scouts collection:

```
>>> docs = scouts_firebase.get_all()
>>> print(docs)
```

* Update the document we added (in this case we only update the `nightscout_api` field). We can check the update in the Firebase console. Later, we obtain the document using the `get_by_email` method and print item to confirm that the field value was in effect updated:

```
>>> scouts_firebase.update({u'nightscout_api':'some_testing_url'},docs[0]['id'])
>>> item = scouts_firebase.get_by_email('email@gmail.com')
>>> print(item)
```

To close the Python console just type `quit()` to go back to the terminal.

### Create the User Data Configuration Interface

With the defined data models, the next step is to create the interface that will receive the data of the connected user, with Google auth. Our application will be in charge of using the model to store this information.

In `notifier.py`, just under the last `import` add the following lines:

```python
import models
from models import model, scouts, scout
```

This adds the `models` module to the `notifier.py` script and imports the `models`, `scouts`, and `scout` classes from the module to be able to use them. Later, before the lines that define the `get_session` function, add the code that initializes the `scouts` class:

```python
nightscouts = scouts()
```

Next, edit the `home` function, which controls the endpoint `/`. The function should be modified with the following workflow in mind: A user authenticates with Google auth to our application; If they are authenticating for the first time when `/` is loaded, an empty form will be presented with a `new` flag to indicate to the application that the user will insert a new document to Firebase. If the user who is connecting already exists before loading `/`, a query will be made to Firebase to bring the data related to that email, and the information will be shown on the form with the `edit` flag to indicate to the application that by submitting the form you will be modifying the document of an existing user.

Currently our `home` function is defined as follows:

```python
@app.route('/',methods=['GET','POST'])
    def home():
        if get_session("user") != None:
            return render_template("home.html", user = get_session("user"))
        else:
            return render_template("login.html", client_id=os.getenv("GOOGLE_CLIENT_ID"), site_url=os.getenv("SITE_URL"))
```

With the additional code, it should look like this:

```python
@app.route('/',methods=['GET','POST'])
    def home():
        global scouts
        if get_session("user") != None:
            if request.method == "POST":
                extra_contacts = request.form.getlist('extra_contacts[]')
                if request.form.get("cmd") == "new":
                    nightscouts.add(scout(email=get_session("user")["email"], username=get_session("user")["username"], nightscout_api=request.form.get('nightscout_api'), phone=request.form.get('phone'), emerg_contact=request.form.get('emerg_contact'), extra_contacts=extra_contacts))
                else:
                    nightscouts.update({u'nightscout_api':request.form.get('nightscout_api'), u'phone':request.form.get('phone'), u'emerg_contact':request.form.get('emerg_contact'),u'extra_contacts':extra_contacts},request.form.get('id'))
            return render_template("home.html", user = get_session("user"), scout = nightscouts.get_by_email(get_session("user")["email"]))
        else:
            return render_template("login.html", client_id=os.getenv("GOOGLE_CLIENT_ID"), site_url=os.getenv("SITE_URL"))
```

Basically, we've added a conditional that assesses if the method used to access `/` is `POST`. If so, we can assume that the request has been made from a form.

In this case, we would be talking about the user configuration form. If the method used is `POST`, we ask if the flag (in this case `cmd`) is`new`. If so, the `add` method will be executed by adding the user's new document.

**Note:** We get `email` and `username` directly from the session, as this is data obtained from Google auth.

If the flag detected is `edit`, the new values ​​of the form are received and the `update` method of the `scouts` class is executed to update the document of the connected user.

**Note:** `email` and `username` are not modified as they are exclusive data from Google.

Regardless of the method used, in `render_template` we pass all the data of the connected user using the variable `scout = nightscouts.get_by_email(get_session("user")["email"])`, to fill the form with the configuration information in if the user exists. The form fields will be empty.

Now let's edit the `home.html` file. This jinja template is loaded only if the user has previously logged in. Currently, we only have one line of code within the block `content` indicating the connected user and the link for logout. Just below this, we will add the code that will receive the application data for the user.

The block should look like this:

```html
{% block content %}
<div id="user" class="logged">
  you are logged in as <b>{{ user.username }}</b> -
  <a id="logout" class="teal-text" href="/logout">Logout</a>
</div>
<div class="row">
  <div class="col s8 offset-s2">
    <div class="card blue-grey darken-1">
      <div class="card-content white-text">
        <h1 class="card-title">Your Scout Profile</h1>
        <div class="row">
          <form id="scout-form" class="col s12" method="POST" action="/">
            <input
              type="hidden"
              name="cmd"
              value="{{ 'new' if scout == None else 'edit' }}"
            />
            {% if scout!=None %}
            <input type="hidden" name="id" value="{{ scout.id }}" />
            {% endif %}
            <div class="row">
              <div class="col s12 input-field">
                <input
                  placeholder="E.g. https://domain.ext/api/v1/entries.json"
                  value="{{ scout.nightscout_api }}"
                  id="nightscout_api"
                  name="nightscout_api"
                  type="text"
                  class="validate"
                  required
                />
                <label for="nightscout_api" class="white-text"
                  >Enter NightScout Api Entries Url (Entries url finish with
                  <b>entries.json</b>)</label
                >
              </div>
            </div>
            <div class="row">
              <div class="col s12 input-field">
                <i class="material-icons prefix">phone</i>
                <input
                  placeholder="E.g. 50588888888"
                  id="phone"
                  name="phone"
                  value="{{ scout.phone }}"
                  type="tel"
                  class="validate"
                  pattern="[0-9]+"
                  required
                />
                <label for="phone" class="white-text"
                  >Enter your mobile number</label
                >
              </div>
            </div>
            <div class="row">
              <div class="col s12 input-field">
                <i class="material-icons prefix">phone</i>
                <input
                  placeholder="E.g. 50588888888"
                  id="emerg_contact"
                  name="emerg_contact"
                  value="{{ scout.emerg_contact }}"
                  type="tel"
                  class="validate"
                  pattern="[0-9]+"
                  required
                />
                <label for="emerg_contact" class="white-text"
                  >Enter emergency contact</label
                >
              </div>
            </div>
            <div class="row">
              <div class="col s12 add-contacts-container">
                <div class="row">
                  <div class="col s6">
                    <label class="white-text"
                      >Add 5 additional contact numbers:</label
                    >
                  </div>
                  <div class="col s6 add_contact">
                    <div class="right-align">
                      <a
                        onclick="add_contact()"
                        class="btn waves-effect waves-light red"
                        ><i class="material-icons">group_add</i></a
                      >
                    </div>
                    <br />
                  </div>
                </div>
                <div class="divider"></div>
                <div class="contact_numbers" id="contact_numbers"></div>
              </div>
            </div>
            <div class="row">
              <div class="col s12 right-align">
                <button
                  class="waves-effect waves-light btn-small"
                  type="submit"
                >
                  <i class="material-icons left">save</i> Save
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
{% endblock %}
```

If the `scout` variable has a value of `None`, the flag `cmd` will have the value `new`—otherwise the value will be `edit`. The values of the text fields receive `{{scout.phone}}`, so when `scout` is `None` jinja will print empty. When `scout` exists the id is received in a hidden type field. This field should not be modified since it is the unique identifier of the document in Firebase. The `add_contact()` JavaScript function is undefined.

Let's add some more code in `home.html`, just after`{% endblock %}`. In this case, we will use the `script` block that we define in `layout.html` to define the necessary JavaScript functions:

```javascript
{% block script %}
 <script language="javascript">
 var contacts_numbers = null;
 var container = null;
 var incremental = 0;
 window.addEventListener('load', function(event){

   container = document.getElementById("contact_numbers");
   contact_numbers = container.getElementsByClassName("contact_number");

   var extra_contacts = validate({{ scout.extra_contacts|safe }});
   //var extra_contacts = {{ scout.extra_contacts|safe if scout else "Array()" }};
   for(var p=0;p<extra_contacts.length;p++){
    add_contact(extra_contacts[0]);
   }

 });
 function validate(value){
  if(value!==null & value!==undefined)
   return value;
  else
   return Array();
 }

 function add_contact(value){
  if(contact_numbers.length < 5){
   incremental += 1;
   var div = document.createElement("div");
   div.className = 'row contact_number';
   div.setAttribute('id','id_'+incremental);
   if(!(value!=null && value!==undefined)){
    value = "";
   }
   div.innerHTML += '<div class="col s12 input-field"><i class="material-icons prefix">contact_phone</i><input placeholder="E.g. 50588888888" name="extra_contacts[]" value="'+value+'" type="tel" class="validate" pattern="[0-9]+"><i class="material-icons prefix sufix delete" onclick="delete_contact(\'id_'+incremental+'\')">delete</i></div>';
   container.appendChild(div);
   contact_numbers = container.getElementsByClassName("contact_number");
  }else{
   M.toast({html: 'Sorry, You can just add a maximun of 5 contact numbers'});
  }
 }

 function delete_contact(id){
  contact_number = document.getElementById(id);
  container.removeChild(contact_number);
 }

 </script>
{% endblock %}
```

In the `script` block we define three functions and the event listener of `onload` page. The `validate` function evaluates whether the value of `{{scout.extra_contacts|safe}}` passed by jinja is empty. If that's the case, then `validate` returns an empty `Array()`, otherwise jinja returns the `extra_contacts` array.

If, when loading the page, `extra_contacts` contains information, the function `add_contact` is executed for each position of the `extra_contacts` array, passing the value of the phone number to the value attribute of the input.

The function `add_contact()` dynamically adds a text field where the user can type an additional telephone number, up to the five allowed. Each input will have an icon to be clicked on to eliminate the record. This same function evaluates whether the number of allowed contacts has been reached. In that case, `M.toast` of materialize is used to display an alert to the user indicating that they cannot add more than five contact numbers. This function is triggered when loading `/` and when clicking on the button to add telephone numbers.

The `delete_contact()` function removes the record created by `add_contact()`. The function is triggered from the `onclick` event of the delete icon added by `add_contact` for each input.

With these last details, we have concluded configuring Google auth login and Firebase/Firestore for storage and reading data.

At this point, we should be able to log in with Google, add our Nightscout configuration from the form, save our data in Firestore, modify our configuration, and properly log out.

## To Be Continued!

The next step will be to set up/configure the app in Nexmo and to create a scheduler in Python for the Nightscout alerts. Check back in next week to read Part Two of this tutorial.