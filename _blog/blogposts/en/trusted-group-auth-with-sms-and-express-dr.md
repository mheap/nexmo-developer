---
title: Trusted Group Authentication with SMS and Express
description: How to use Node.js and Express in combination with the Nexmo Verify
  API to build an app that allows trusted groups of friends to easily
  authenticate and collaborate online.
thumbnail: /content/blog/trusted-group-auth-with-sms-and-express-dr/Group-Authentication_1200x675-1.jpg
author: garann-means
published: true
published_at: 2019-06-18T08:00:22.000Z
updated_at: 2021-05-13T21:25:09.065Z
category: tutorial
tags:
  - javascript
  - sms-api
  - verify-api
comments: true
redirect: ""
canonical: ""
---
Is there anything better than working on a project with your friends? Maybe so! How about not having to arrange times and places you can all meet up, and instead being able to collaborate online? 

Of course, in moving online you trade the overhead of conflicting real world schedules for that of having to find and admin a collaboration tool. If you're coding your own tool, at least you can skip the product research. But you still need a way to manage authentication so that random people don't show up in your careful work uninvited and make a mess of it. And *then* you have to worry about protecting all your friends' private data. After all, who knows what kind of identifying information might be required by an authentication solution designed for large numbers of strangers?

If you know all your friends' phone numbers, though, you can use the [Nexmo Verify API](https://developer.nexmo.com/verify/overview) to create a simple way of authenticating people, storing only a username that can be as anonymous as they want. Instead of dealing with password policies, password encryption, and password forgetfulness you can keep your users logged in by saving their session, using their devices as their passwords.

## Setting Up Your Project on Glitch

<sign-up number></sign-up>

For this example, let's assume your project is hosted on [Glitch](https://glitch.com/). Glitch makes it easy to start a new project with a SQLite data store, which will be handy for keeping track of your logged-in users' sessions. You can create a brand new project using the `hello-sqlite` template from the New Project button in Glitch, or skip to the end and [remix the code for the final project](https://glitch.com/edit/#!/trusted-group-auth). 

Since your application will be built on [Express](https://expressjs.com/), you'll need to install some middleware to get all the functionality it will require. Open the Glitch console and install several additional packages: 

* [`connect-sqlite3`](https://www.npmjs.com/package/connect-sqlite3) to enable easy session storage in your SQLite database
* [`cookie-parser`](https://www.npmjs.com/package/cookie-parser) so you can manage session cookies
* [`express-session`](https://www.npmjs.com/package/express-session) to access Express' session management tools
* [`nexmo`](https://www.npmjs.com/package/nexmo) to perform your user verification and SMS communications

You can add them all at once:

```sh
pnpm install connect-sqlite3 cookie-parser express-session nexmo -s
```

## Configuring Your Server

Your server will already have the setup code necessary to serve static files and connect to your database. Below the setup code it comes with, add a few more blocks to parse client requests and perform your session management and storage.

```javascript
// parse client requests in JSON
app.use(bodyParser.json());

// install packages to do session management
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);

// configure automatic session storage in SQLite db
app.use(require('cookie-parser')());
app.use(session({
  store: new SQLiteStore,
  secret: process.env.SESH_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 7 * 24 * 60 * 60 * 1000 } // 1 week
}));
```

After setting up Express, you should also instantiate a Nexmo object that will provide your Verify and SMS functionality:

```javascript
const Nexmo = require('nexmo');
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET
});
```

There are a few environment variables used in the setup code which you'll need to supply in `.env`. While you're at it, you can set up the environment variables you'll need in your endpoint logic, as well:

```env
SESH_SECRET="a complex secret only you know"
API_KEY="12ab3456"
API_SECRET="123AbcdefghIJklM"
APP_NUM="441234567890"
ADMINS="kelly,michelle,beyonce"
INVITE_CODE="code123"
```

You can find your Nexmo API key and secret in your [Nexmo Dashboard](https://dashboard.nexmo.com). The phone number associated with the application can be any Nexmo virtual number you own not already associated with another SMS endpoint. `SESH_SECRET` and `INVITE_CODE` can be anything you like. Your `ADMINS` can be just your own username, or a comma-delimited list of usernames of friends you want to help you manage users in the app.

Currently, this application has one database table, created in a call to `db.serialize()`. Though we want to keep the serialization and the existence check, everything else in there is safe to delete. The minimum functionality you'll need to replace it will create three new tables for your application: 

* temporary session information for users who are mid-login
* a whitelist of users allowed to sign up
* a list of authorized usernames

These are all small, simple tables with a lot of the same data:

```javascript
db.serialize(function(){
  if (!exists) {
    db.run('CREATE TABLE Sessions (phone NUMERIC, id TEXT)');
    db.run('CREATE TABLE Whitelist (phone NUMERIC, username TEXT)');
    db.run('CREATE TABLE Authors (username TEXT)');
  }
});
```

> Sometime before you first try to use your application, don't forget to change `exists` to equal `false` so SQLite will create your tables. And don't forget to change it back so you don't lose all your data any time the application restarts!

## Routes for your Views

Your server already has a route for the main page at `/`. Below it, you can add two more routes for a signup or login page for your users and an admin page for you:

```javascript
// VIEW ROUTES
app.get('/', function(request, response) {
  response.sendFile(__dirname + '/views/index.html');
});

app.get('/signup', function(request, response) {
  response.sendFile(__dirname + '/views/signup.html');
});

app.get('/admin', function(request, response) {
  if (isAdmin(request.session)) {
    response.sendFile(__dirname + '/views/admin.html');
  } else {
    response.sendFile(__dirname + '/views/index.html');
  }
});
```

To begin managing access to your admin functionality, you'll also need to declare the `isAdmin` function referenced in your `/admin` route. It'll split your list of admins from `.env` out into an array and look for an exact match with the username in the current session:

```javascript
function isAdmin(sesh) {
  let admins = process.env.ADMINS.split(',');
  return admins.includes(sesh.username);
}
```

Don't worry about providing any of the client-side code right now, but it's a good time to create the static pages used by your routes, `views/signup.html` and `views/admin.html`. You can also delete the code in `public/client.js` if you like, since we're about to get rid of the server-side logic it relies upon.

## The Admin Endpoint

The first step in the workflow of adding a user is for an admin to add their phone number to a whitelist. Because the same person may want to log in from different devices (thus requiring additional session cookies), or their session may expire, the admin can can optionally associate the phone number with an existing username.

To start, declare the endpoint at `/invite` and add a security check to make sure this person is *still* an admin:

```javascript
app.post('/invite', function(request, response) {
  if (!isAdmin(request.session)) {
    response.status(500).send({message: "Sorry, you're not an admin"});
    return;
  }
  
});
```

If the person attempting to add an invitation isn't an admin, the request should just fail. 

The next thing the function will do is get the phone number from the request. After a light validity check, it's added to the whitelist. If the admin has specified a username, that will get added too:

```javascript
app.post('/invite', function(request, response) {
  if (!isAdmin(request.session)) {
    ...
  }
  let phone = request.body.phone;
  if (!isNaN(phone)) {
    if (request.body.username) {
      db.run('INSERT INTO Whitelist (phone, username) VALUES ($phone, $user)', {
        $phone: phone,
        $user: request.body.username
      });
    } else {
      db.run('INSERT INTO Whitelist (phone) VALUES ($phone)', {
        $phone: phone
      });
    }
    
  }
});
```

Once the new phone number is added to the whitelist, the last thing to do is text an invite to the new user. The text will be sent by the phone number you've saved in `.env`, and the user will receive the current invite code to text back in reply. 

You could skip this step entirely and just send the verification PIN. However, this way gives you the opportunity to provide any contextual information, such as the signup URL, that the user may benefit from. Since Nexmo Verify PINs are only good for five minutes, it also helps ensure the recipient's PIN doesn't expire before they see it:

```javascript
app.post('/invite', function(request, response) {
  if (!isAdmin(request.session)) {
    ...
  }
  let phone = request.body.phone;
  if (!isNaN(phone)) {
    if (request.body.username) {
      ...
    } else {
      ...
    }
    nexmo.message.sendSms(
      process.env.APP_NUM, 
      phone, 
      `Please reply to this message with "${process.env.INVITE_CODE}" 
        to get your PIN for 
        https://${process.env.PROJECT_DOMAIN}.glitch.me/signup.`);
  }
});
```

## The Webhook Endpoint

Before you create an endpoint to allow your server to receive texts, you should instruct Nexmo that incoming texts to your virtual number will be handled by your application. You can do that directly from the [Numbers](https://dashboard.nexmo.com/your-numbers) menu in your dashboard, by clicking the settings icon under Manage. For the Inbound Webhook URL, provide the URL of your app and the endpoint `/answer`. On Glitch, it should look something like `https://trusted-group-auth.glitch.me/answer`. You should also check your [Settings](https://dashboard.nexmo.com/settings) and make sure that your default HTTP Method for SMS is POST.

With your phone number configured, you can add the logic for the webhook endpoint. You'll check that the text contains the current invite code, and that the phone number it came from is in the whitelist. If those conditions are met, you'll send a request for verification and save the phone number and ID you get in response in your `Sessions` database:

```javascript
app.post('/answer', function(request, response) {
  let from = request.body.msisdn;
  if (request.body.text === process.env.INVITE_CODE) {
    db.all('SELECT * from Whitelist WHERE phone = $from', 
      {$from: from}, 
      function(err, rows) {
      if (rows.length) {
        nexmo.verify.request({
          number: from,
          brand: process.env.PROJECT_DOMAIN
        }, (err, result) => {
          db.run('INSERT INTO Sessions (phone, id) VALUES ($phone, $id)', {
            $phone: from,
            $id: result.request_id
          });
          response.status(204).end();
        });
      }
    });
  }
});
```

This time, the new user will receive a text generated automatically by Nexmo Verify containing their PIN. You've supplied your application's phone number and the domain on Glitch to identify, but other than that the text is boilerplate. There's nothing for the user to respond to in this message. With a record of it stored, we'll wait for them to complete the final step through the web app.

## The Signup or Login Endpoint

From the web client, the new user will send their phone number, username, and PIN. Of these, only the username will actually get stored. The other values are for the authentication process, and if this login succeeds we'll remove them from the data store. 

Add a new `/login` endpoint to your server, and as its first step, do some quick validation of the username. The example here only allows very basic characters, which might be fine for your purposes, or you might want a more robust set of options. With that validated, you'll find the session for the phone number supplied:

```javascript
app.post('/login', function(request, response) {
  let allowed = RegExp('[A-Za-z0-9_-]+');
  let username = request.body.username;
  if (!allowed.test(username)) {
    return;
  }
  db.each('SELECT * FROM Sessions WHERE phone = $phone', {
    $phone: request.body.phone
  }, function(error, sesh) {
     
  }); 
});
```

Within the callback providing the session row, you'll do another check on the username: this time seeing whether it's already in use and, if so, if this phone number is authorized to log in with it:

```javascript
app.post('/login', function(request, response) {
  ...
  db.each('SELECT * FROM Sessions WHERE phone = $phone',{
    $phone: request.body.phone
  }, function(error, sesh) {
    
    let broken = false;
    db.all('SELECT * FROM Authors WHERE username = $user', {
      $user: username
    }, function(err, rows) {
      
      if (rows.length) {
        db.all('SELECT * FROM Whitelist WHERE username = $user AND phone = $phone', {
          $user: username,
          $phone: sesh.phone
        }, function(e, r) {
          if (e || !r.length) broken = true; 
        });
      }   
    });
    
    if (!broken) {
      
    }
  }); 
});
```

If the checks on the username all pass, you'll use a flag to confirm it's OK to continue and confirm the PIN received from the client is correct for this verification request. If it is, you'll get a status of `0` in the response, and can then safely delete the session and whitelist records you used during this process. The last step is to put the username in the session:

```javascript
app.post('/login', function(request, response) {
  ...
  db.each('SELECT * FROM Sessions WHERE phone = $phone',{
    $phone: request.body.phone
  }, function(error, sesh) {
    
    let broken = false;
    db.all('SELECT * FROM Authors WHERE username = $user', {
      $user: username
    }, function(err, rows) {
      ...
    });
    
    if (!broken) {
      nexmo.verify.check({
        request_id: sesh.id,
        code: request.body.pin
      }, (err, result) => {
        if (result.status === '0') {
          db.serialize(function() {
            db.run('INSERT INTO Authors (username) VALUES ($user)', {
              $user: username
            });
            db.run('DELETE FROM Whitelist WHERE phone = $phone', {
              $phone: sesh.phone
            });
            db.run('DELETE FROM Sessions WHERE phone = $phone', {
              $phone: sesh.phone
            });
          });
          request.session.username = username;
          response.status(204).end();
        }
      });
    }
  }); 
});
```

## Add Some Markup

You'll need two similar forms to collect data on the client-side: an admin form and a signup form. The admin form will trigger invitations to new users, and the signup form will create new sessions. Your `index.html` page will just be a landing page for your project, and you can use it to supply whatever information or functionality you want. However, it may be useful to copy its contents to both `admin.html` and `signup.html` so you have your scaffolding in place. 

Within the `<main>` tag in `admin.html`, replace the HTML with a simple form to collect a phone number and username:

```html
    <main>
      <h2>
        Invite people to your application
      </h2>
      
      <form action="/invite" method="post">
        <label>Phone number:
          <input type="phone" id="phone" name="phone" />
        </label>
        
        <label>Username (optional):
          <input type="text" id="username" name="username" />
        </label>
        
        <input type="submit" value="Invite" id="invite_btn" />
        <h3 id="feedback"></h3>
      </form>
    </main>
```

The contents of `<main>` in `signup.html` should be very similar, except that there you'll also collect a PIN:

```html
   <main>
      <h2>
        Sign up or log in
      </h2>
      
      <form action="/login" method="post">
        <label>Phone number:
          <input type="phone" id="phone" name="phone" />
        </label>
        
        <label>Username:
          <input type="text" id="username" name="username" />
        </label>
        
        <label>PIN:
          <input type="text" id="pin" name="pin" />
        </label>
        
        <input type="submit" value="Sign up" id="signup_btn" />
        <h3 id="feedback"></h3>
      </form>
    </main>
```

If you hung onto the default markup surrounding that tag, you'll still be importing `client.js` on both pages, and since your forms are nearly identical you can also use the same script to handle them. Having already cleared out the contents of `client.js`, you can write your own code there.

In your client-side JavaScript you'll gather references to the form elements you need to access, then look for the presence of your two submit buttons and wire up a click handler to any that you find. You'll use a shared function to actually submit your form data to the server, making sure to prevent the default form submission in your click handlers. You could just do all this with HTML, but as your application becomes more complex you may want a JavaScript handler for the functionality already in place to perform additional tasks:

```javascript
let phone = document.querySelector('#phone');
let username = document.querySelector('#username');
let feedback = document.querySelector('#feedback');

// INVITE FORM
let invite_btn = document.querySelector('#invite_btn');
if (invite_btn) {
  invite_btn.onclick = function(e) {
    e.preventDefault();
    let body = JSON.stringify({
      phone: phone.value,
      username: username.value
    });
    goFetch('/invite', body, e.target);
    return false;
  };
}

// SIGNUP FORM
let signup_btn = document.querySelector('#signup_btn');
if (signup_btn) {
  signup_btn.onclick = function(e) {
    e.preventDefault();
    let body = JSON.stringify({
      phone: phone.value,
      username: username.value,
      pin: document.querySelector('#pin').value
    });
    goFetch('/login', body, e.target);
    return false;
  };
}

function goFetch(url, body, btn) {
  fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: body
  })
  .then(response => response.json())
  .then(data => {
    feedback.innerText = data.message || 'Thank you!';
    btn.style.display = 'none';
  });
}
```

## Getting Started

Though your application is set up to work now, you have a bit of a chicken and egg problem. To begin inviting people, you yourself will first need to be invited and logged in to a session so that you can be recognized as an admin. How you address that is up to you. It may be a good permanent solution to add a backdoor only people with full access to the application code (i.e., you, its author) can use. To get going quickly, however, you can very briefly comment out the code in the `isAdmin` function and replace it with `return true`.

## Next Steps

To continue with this code, the first thing you'll probably want are error checks. You can provide useful feedback to users in cases where they're trying to take an existing username, use more exotic characters than the example regular expression allows, or verify with an expired PIN. 

For long term user management, you'll want to add endpoints to remove people from the whitelist and the `Authors` database. You could add those to your admin page or create separate pages for all admin functions. 

Of course, the big thing to do here is figure out how you want to deal with expiring sessions. Since your users rely on their session cookies for access to your app now, you may not want to ask them to text back and forth with the verification system every week. Approaches to consider might be adding time to their session every time it's active, or showing a button letting them renew their session prior to its expiration.

If you're curious what else you can do with Nexmo Verify, you can find all the documentation on the [Nexmo Developer Portal](https://developer.nexmo.com/verify/overview).

The [code for this tutorial](https://glitch.com/edit/#!/trusted-group-auth) is available as a project on Glitch. You can take a look there, change things around, and remix it to use as part of your own projects:

<div class="glitch-embed-wrap" style="height: 420px; width: 100%;">
  <iframe
    allow="geolocation; microphone; camera; midi; vr; encrypted-media"
    src="https://glitch.com/embed/#!/embed/trusted-group-auth?path=server.js&previewSize=0"
    alt="trusted-group-auth on Glitch"
    style="height: 100%; width: 100%; border: 0;">
  </iframe>
</div>