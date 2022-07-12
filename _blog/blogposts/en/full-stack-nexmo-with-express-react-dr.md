---
title: Build a Full Stack Nexmo App with Express and React
description: The Nexmo Node and JS Client SDKs along with Express and React can
  create a full-stack app as a basis for most things you may want from Nexmo in
  the browser
thumbnail: /content/blog/full-stack-nexmo-with-express-react-dr/Full-Stack-Nexmo-App-with-Express-and-React.png
author: garann-means
published: true
published_at: 2019-03-15T12:04:59.000Z
updated_at: 2021-05-12T03:32:59.597Z
category: tutorial
tags:
  - java
  - react
comments: true
redirect: ""
canonical: ""
---

With the JavaScript Nexmo Client SDK, you can provide a front-end application that allows users to control the conversations they're part of. A [Nexmo Conversation](https://developer.nexmo.com/conversation/concepts/conversation) can include two [users](https://developer.nexmo.com/conversation/concepts/user) or many, and use multiple different media. Letting participants control elements of the conversation only opens up more options for what your app can provide. 

[React](https://reactjs.org/) is a very popular choice for building apps for the front-end, and concepts like Conversations and Users within the Nexmo Client SDK map nicely to React components with their own stateful controls. However, there are some things the Nexmo Client SDK can't do, and so the full picture of your application doesn't emerge until we also consider the back-end. Using Express, you can add a few simple routes to support your front-end in managing users and do any other work you feel is best kept on the server.

Unlike a traditional server-provided application, your React front-end is an application in its own right, which means your "full stack" app is really two applications. Each will listen on its own port and respond to requests without checking in with the other side. What this looks like from a file structure perspective is an app within an app. You'll set up your Express server in the root of your directory, then add the React app—complete with its own separate `package.json`—in a subdirectory.

## Application Setup

At the root of the project directory, you'll start by creating a `package.json` for your Express app and a `server.js` that will contain it. You'll also want to create a `.env` file that will store your sensitive application and account credentials. You'll need to install a few packages from [npm](https://www.npmjs.com/): [Express](https://expressjs.com/), [body-parser](https://www.npmjs.com/package/body-parser), [dotenv](https://www.npmjs.com/package/dotenv), and of course the [Nexmo Node SDK](https://github.com/nexmo/nexmo-node):

```bash
npm install -s express body-parser dotenv nexmo@beta
```

For starting both your applications at once, you'll also want [`concurrently`](https://www.npmjs.com/package/concurrently) installed as a dev dependency:

```bash
npm install --save-dev concurrently
```

Next you'll provide the keys, IDs, and secrets needed to identify your [Nexmo application](https://developer.nexmo.com/conversation/concepts/application), which you can store in your `.env` file:

```bash
API_KEY=""
API_SECRET=""
APP_ID=""
PRIVATE_KEY="/private.key"
```

You can find your API key and secret on the [Getting Started](https://dashboard.nexmo.com/getting-started-guide) page of your Nexmo dashboard. You can get an Application ID and a generated private key to download from the [Create an application page](https://dashboard.nexmo.com/voice/create-application) (if your application will is for messaging, you can use the [Create a Messages application](https://dashboard.nexmo.com/messages/create-application) page instead). In the example, the private key is saved in the root of your directory, so be sure to update the path in `.env` if you move it elsewhere.

After completing that setup, you can move on to creating the client app.

## Create a React App

You can quickly create some scaffolding for your client using the very handy [create-react-app](https://github.com/facebook/create-react-app). Since this React app will live in a subdirectory of your project, you can specify the subdirectory name you prefer when you run the command (though you may want to change the application name to something more descriptive once it generates its `package.json`). In our example, we've called the subdirectory "client":

```bash
npx create-react-app client
```

This will give you most of what you need on the client, including React's dependencies and a set of scripts to do things like start and build your app. The only additional package you'll need from npm is the [Nexmo Client SDK](https://www.npmjs.com/package/nexmo-client):

```bash
npm install -s nexmo-client@beta
```

In your client `package.json` you'll also want to add a proxy, which will refer to your Express server and the port it's running on:

```javascript
"proxy": "http://localhost:3001",
```

## Express Server 

Initializing your Express server should seem familiar if you've worked with Express before. You'll also want to require `dotenv` and `body-parser`, the latter of which you'll attach to your app as middleware:

```javascript
require('dotenv').config();

// init server
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
```

Next you'll want to create a new Nexmo client, supplying it the variables you saved in your `.env` file, which `dotenv` will make accessible as members of `process.env`:

```javascript
// create a Nexmo client
const Nexmo = require('nexmo');
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: __dirname + process.env.PRIVATE_KEY 
}, {debug: true});
```

For this simple example, we'll only create endpoints for getting a JWT and creating a new user. You can define the signatures of your endpoints now, and we'll supply the logic for both apps together in a later step. Finally, of course, you'll want your Express server to listen on the port you specified in React's `package.json`:

```javascript
app.post('/getJWT', function(req, res) {});
app.post('/createUser', function(req, res) {});

app.listen(3001);

```

## React App Component

When you ran `create-react-app`, it should have created an entrypoint to your application at `src/index.js` in your client subdirectory. This loads the component defined in `src/App.js` and renders it as the body of your landing page. This component is an ideal place to do administrative tasks like obtaining a JWT and logging in to your Nexmo application. It's also a good container for two child components: `User` and `Conversation`. To begin with, import two components you'll create in a moment:

```javascript
import React from 'react';
import User from './User';
import Conversation from './Conversation';

import nexmoClient from 'nexmo-client';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    
    this.login = this.login.bind(this);
    this.getJWT = this.getJWT.bind(this);
    this.userUpdated = this.userUpdated.bind(this);
  }
    
  login() {}  
  getJWT() {}  
  userUpdated() {}
  render() {}
    
};

export default App;
```

While we're at it, you can see we've also imported the Nexmo Client SDK and cleaned up the created class so it's ready to populate with our logic. We've also added placeholders for the functions we'll need. 

Now that you have references to the two child components (even though we've yet to create them), you can update your render function to load them on your page:

```javascript
render() {
  return (
    <div className="nexmo">
      <User onUpdate={this.userUpdated} />
      <Conversation app={this.state.app} loggedIn={!!this.state.token} />
    </div>
  );
}
```

### Logging in the Nexmo Application

The `User` component is going to call `userUpdated` when it wants to report changes to its state, so that function becomes the first link in your chain of execution. You'll look for a `username` property on the state object you receive and, if it exists, continue on to get a JWT for that user:

```javascript
userUpdated(user) {
  if (user.username) {
    this.getJWT(user.username);
  }
}
```

Your `getJWT` function will mostly consist of a `fetch` and the handling of its response. You'll need to `POST` the username the function receives to the Express server as JSON, then parse the data and save your new JWT as the state property `token`. With that done, you can call the `login` function to finish initializing your application:

```javascript
getJWT(username) {
  fetch('/getJWT', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({name: username})
  })
  .then(results => results.json())
  .then(data => {
    this.setState({
      token: data.jwt
    });
    this.login();
  });
}
```

### Getting a JWT from the Server

Let's very quickly jump back over to your Express app in `server.js` and provide the endpoint the client-side `getJWT` function will call. Using the [Nexmo Node SDK](https://github.com/Nexmo/nexmo-node), we can generate a JWT by providing our application ID once again; the `sub`, or username, we're sending from the client; an expiration in seconds; and the [permissions](https://developer.nexmo.com/client-sdk/concepts/jwt-acl) we want this token to have. In the code below, the user can do things involving user, conversations, sessions, and applications, which is enough for our very simple app:

```javascript
app.post('/getJWT', function(req, res) {
  const jwt = nexmo.generateJwt({
    application_id: process.env.APP_ID,
    sub: req.body.name,
    exp: Math.round(new Date().getTime()/1000)+3600,
    acl: {
      "paths": {
        "/v1/users/**":{},
        "/v1/conversations/**":{},
        "/v1/sessions/**":{},
        "/v1/applications/**":{}
      }
    }
  });
  res.send({jwt: jwt});
});
```

Now that your server is sending a token to the React app, you can return to `App.js` and provide the logic for your final function, `login`. There really isn't much to do. Using the new token saved in the App component's state, you log in the Nexmo client and receive a reference to your logged-in Nexmo app. You can save that to the component's state, and that's this component done!

```javascript
login() {
  let nexmo = new nexmoClient();
  nexmo.createSession(this.state.token).then(app => {
    this.setState({
      app: app
    });
  });
}
```

## React User Component

Since your App component is waiting on the User component to trigger the login flow, let's create that component now. In a new `User.js` file in the same directory as `App.js`, you can provide an outline of the component:

```javascript
import React from 'react';

class User extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    
    this.createUser = this.createUser.bind(this);
    this.setUsername = this.setUsername.bind(this);
  };
  
  createUser() {}
  setUsername() {}
  render() {}
    
};

export default User;
```

In a real-world application, you'd want to use a system for managing and storing your users, as well as authenticating them. For this minimal example, however, you're just going to create a new user each time you access this page. In your `render` function you can check whether the component's state contains a `userId` property. If so, you can post a message confirming the user is logged in. If not, you can show a text field and button to create the new user:

```javascript
render() {
  if (this.state.userId) {
    return (
      <div className="userinfo userconnected">
        Connected as <span className="username">{this.state.username}</span>
      </div>
    );
  } else {
    return (
      <div className="userinfo">
        <input type="text" onChange={evt => this.setUsername(evt)} />
        <button onClick={this.createUser}>Create user</button>
      </div>
    );
  }
}
```

### Creating New Users

Creating the user is actually a two-part process that begins with listening for changes to the text in your text field and storing the updated value. If you wanted to begin making this app more robust, you could choose to start by checking that value against your username rules and list of existing users and messaging validity or duplication problems to the user via a styling change. But for this example, we'll just naively store whatever text the user has typed:

```javascript
setUsername(evt) {
  this.setState({
    username: evt.target.value
  });
}
```

Once the user clicks the "Create user" button, you can fire off another request to your Express server. You'll send the username as stored in the state by `setUsername`, and when the server responds, trigger the `onUpdate` function provided by the `App` component when this component was instantiated:

```javascript
createUser() {
  fetch('/createUser', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({name: this.state.username})
  })
  .then(results => results.json())
  .then(data => { 
    this.setState({
      userId: data.id
    }, () => this.props.onUpdate(this.state));
  });
}
```

The `createUser` endpoint is the last bit of your Express server we've yet to provide, so let's go back to `server.js` and fill in that logic. You can call `users.create` on your Nexmo object, passing in the username from the client and an optional display name (which we haven't included in the client code for this app, but you could choose to provide later). If that succeeds, you'll pass the new user's ID back to the client:

```javascript
app.post('/createUser', function(req, res) {
  nexmo.users.create({
    name: req.body.name,
    display_name: req.body.display_name || req.body.name
  },(err, response) => {
    if (err) {
      res.sendStatus(500);
    } else {
      res.send({id: response.id});
    }
  });
});
```

Now all the logic you need for creating a user in both your React and Express apps is available, and so your React app will be able to log in and do things like creating a conversation.

## React Conversation Component

The last file you need to create is `Conversation.js`, in the same directory as `App.js` and `User.js`. The outline of the component is even smaller than the two you've already created, but in a real-world application it would probably be the component containing the most logic and probably even several child components:

```javascript
import React from 'react';

class Conversation extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    
    this.createConversation = this.createConversation.bind(this);
  }
  
  createConversation() {}
  render() {}
    
};

export default Conversation;
```

This component's `render` function really only needs to provide a button, but you can make it a little nicer by disabling the button until the `App` component notifies this `Conversation` it's done its initialization work. You can then hide the button once the conversation is joined and a reference to it stored in the component state:

```javascript
render() {
  if (this.state.conversation) {
    return (
      <div className="conversation">Joined conversation!</div>
    );
  } else {
    return (
      <div className="conversation">
        <button 
          onClick={this.createConversation} 
          disabled={!this.props.loggedIn}>Start conversation</button>
      </div>
    );
  }
}
```

Most of the logic the `createConversation` function relies upon comes from the Nexmo Application and Conversation objects. When the user clicks the button, you can create a new conversation with a call to the `app` property passed to this component. That will return a conversation, which you can join, and then save as a state property:

```javascript
createConversation() {
  this.props.app.newConversation().then(conv => {
    conv.join().then(member => {
      this.setState({
        conversation: conv
      });
    });
  });
}
```

From here, you could invite other users to the conversation, begin providing handlers for conversation events, or open an audio stream to let participants speak to each other. 

## Starting the Apps

You want to be able to start your Express and React apps as though they were one, and so the last thing you need to do is provide the mechanism for them to start up together. You've already edited React's `package.json` to be aware of the Express app; now it's time to add some scripts to Express's `package.json` so that `npm start` actually starts everything. 

In the `package.json` at the root of your project, add or modify three scripts: `start`, `client`, and `server`:

```json
"scripts": {
    "client": "cd client && npm start",
    "server": "node server.js",
    "start": "concurrently --kill-others-on-fail \"npm run server\" \"npm run client\""
  },
```

The `concurrently` package you installed at the beginning of this tutorial will start the Express server at the same time as it navigates to the client directory (note that you must change "client" to the name of your React subdirectory if you called it something else) and runs the `start` script provided by `create-react-app`. If you run `npm start` now, you should be able to open a browser to the React app at `http://localhost:3000` and see your application running.

Want to see a slightly more complex version of this app in action? You can [view the extended code on Glitch](https://glitch.com/edit/#!/nexmo-express-react) and remix it to experiment further with Nexmo Conversations. And now that you have the fundamentals, you can continue on to [build a chat app with React and Nexmo](https://www.nexmo.com/blog/2019/08/30/chat-app-with-react-and-nexmo-dr).
