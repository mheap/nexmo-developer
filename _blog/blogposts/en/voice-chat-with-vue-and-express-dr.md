---
title: Creating a Voice Chat Application with Vue.js and Express
description: Components in Vue.js make it easier to organize a UI for a Nexmo
  API Voice Chat Application by providing a pattern for templates and scripting
  Node Express
thumbnail: /content/blog/voice-chat-with-vue-and-express-dr/Elevate_ConversationVueJS-1.png
author: garann-means
published: true
published_at: 2019-08-05T22:14:01.000Z
updated_at: 2021-04-30T09:47:06.511Z
category: tutorial
tags:
  - javascript
  - messages-api
comments: true
redirect: ""
canonical: ""
---
Adding a service to a complex web application can be tricky to do in a maintainable way. This is even more true when the service has a user interface component. With Nexmo's API you can create an in-browser voice chat that becomes the basis for a variety of communications applications. But even organizing the pieces of that basic UI can be difficult. Components like those used in [Vue.js](https://vuejs.org/) make this easier by providing a pattern for the templates, styling, and UI scripting an individual UI component may require. An Express server connecting to Nexmo's tools gives you a lightweight full-stack solution that can be adapted to whatever real-world architecture you end up with, thanks to separation of concerns.

There are many ways you can structure an application with Vue. For this tutorial I'll remix a [Glitch project](https://glitch.com/edit/#!/vue-starter-express) that provides relatively little scaffolding, but you could choose a starter project provided by the [Vue CLI](https://cli.vuejs.org/) or a [third-party library](https://vuesion.herokuapp.com/) offering specific features like Server-Side Rendering. Because your code will rely on both Vue and Express, the only requirement is that your setup includes both.

<sign-up></sign-up>



## Adding Nexmo To Your Project

To create a conversation from the browser you'll need to install both the Nexmo [client](https://www.npmjs.com/package/nexmo-client) and [server](https://github.com/Nexmo/nexmo-node) packages. Because the user will send data from the client you'll also need `body-parser` to use in Express. In your project's root directory, install those packages with `npm`, or from the console in Glitch use `pnpm`:

```text
pnpm install nexmo@beta nexmo-client body-parser -s
```

To use Nexmo's tools, you'll also need to provide your API credentials in the `.env` file. The file should look something like this:

```bash
API_KEY="12ab3456"
API_SECRET="123AbcdefghIJklM"
APP_ID="a0b23456-c789-012d-3456-e789012f34a5"
PRIVATE_KEY="/.data/private.key"
```

> Depending on your environment, you may also need to install the `dotenv` package from npm. To import your environment variables from `.env`, you just need to add a single line at the top of your `server.js` file: `require('dotenv').config();`

You can find your API key and secret on the [Getting Started](https://dashboard.nexmo.com/getting-started-guide) page of your [Nexmo dashboard](https://dashboard.nexmo.com/). Under the Voice menu, go to [Create an Application](https://dashboard.nexmo.com/voice/create-application) and click "Generate public/private key pair" to download your `private.key` file. Then fill in the fields and click "Create application" to get your Application ID. 

Be sure to copy your `private.key` file into your project and update the path in `.env` to the location you've saved it to. It's possible to paste the contents directly into `.env`, but the formatting may cause issues. It's generally more robust to keep it in a separate file.

## A Server For API Calls

The role of [Express.js]([https://expressjs.com](https://expressjs.com/)) in your project will be to provide a simple server that calls the Nexmo API to perform a few admin tasks. This will require some setup of the server itself, a Nexmo instance, and route definitions for your server endpoints. 

In `server.js`, create the server and direct it to parse JSON in request bodies and serve static pages from the `public` directory. Next, create a Nexmo object, passing it the values from `.env`. Finally, create placeholders for your routes and tell the server to begin listening for events:

```javascript
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(express.static('public'));

// create a Nexmo client
const Nexmo = require('nexmo');
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: __dirname + process.env.PRIVATE_KEY 
}, {debug: true});

// the client calls this endpoint to request a JWT, passing it a username
app.post('/getJWT', function(req, res) {});

// the client calls this endpoint to get a list of all users in the Nexmo application
app.get('/getUsers', function(req, res) {});

// the client calls this endpoint to create a new user in the Nexmo application,
// passing it a username and optional display name
app.post('/createUser', function(req, res) {});

app.listen(process.env.PORT);
```

### Server Routes

The three routes defined on the server will allow the application to list and create users who can join a conversation, and to authenticate them. In an application for real world use, you'd probably connect this to your own user management instead of a web interface. 

The route `/getJWT` provides a token the client can use to authenticate the current user. Producing the [JWT](https://developer.nexmo.com/conversation/guides/jwt-acl) is done with a single function, but it requires several pieces of data. You need to supply your application ID again, as well as `sub`, which is the username you want to authenticate. You'll also set the expiration and allowed paths for the token. You can send the newly created token on to the client:

```javascript
// the client calls this endpoint to request a JWT, passing it a username
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
        "/v1/devices/**":{},
        "/v1/image/**":{},
        "/v3/media/**":{},
        "/v1/applications/**":{},
        "/v1/push/**":{},
        "/v1/knocking/**":{}
      }
    }
  });
  res.send({jwt: jwt});
});
```

The `/getUsers` path also makes a single call and returns its result, but let's tidy it up a bit for use in a web interface. Before returning the list of all users in this application, you can filter out system users whose IDs begin with the prefix `NAM-`. In a real world application where user IDs were mapped to accounts within your larger app, you probably wouldn't bother with this step and could return the list as-is:

```javascript
// the client calls this endpoint to get a list of all users in the Nexmo application
app.get('/getUsers', function(req, res) {
  const users = nexmo.users.get({}, (err, response) => {
    if (err) {
      res.sendStatus(500);
    } else {
      let realUsers = response.filter(user => user.name.substring(0,4) !== 'NAM-');
      res.send({users: realUsers});
    }
  });
});
```

The last route, `/createUser`, will take some user input and add a user to the application. Because the `create` function takes both a user name and a display name as input there's the option in this code to set a separate display name, however we won't include that in the UI. Therefore, the endpoint only looks for a `name` from the client, and once it creates a user with it, returns their ID:

```javascript
// the client calls this endpoint to create a new user in the Nexmo application,
// passing it a username and optional display name
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

## The Vue App Component

All the Vue components for this project will live in the `src` directory. The project I'm remixing already includes a `main.js` file there that creates a Vue instance, as well as a container component in `app.vue`. `main.js` does nothing more than render the App component:

```javascript
var Vue = require('vue');
var App = require('./app.vue');

var vm = new Vue({
  el: '#app',
  render: createElement => {
    return createElement(App)
  }
});
```

This works in concert with `public/index.html`, where a div with the ID `app` is the only element on the page:

```html
<!DOCTYPE html>
<html>
<head>
  <title>VueJS + Express Template</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
  <div id="app"></div>
  <script src="build.js"></script>
</body>
</html>
```

In case we want to add more to it later, we'll leave the `App` component in place and load a `Nexmo` component within it, rather than replace `App` with `Nexmo`. If you already have an `app.vue` file, you can replace its contents with a simple template and script that just loads the `Nexmo` component:

```vue
template>
  <div class="app">
    <Nexmo/>
  </div>
</template>

<script>
import Nexmo from './nexmo.vue';

export default {
  name: 'App',
  components: {
    Nexmo
  }
}
</script>
```

## The Nexmo Component

The `Nexmo` component is where things begin to get interesting. You can create it at `nexmo.vue` and add a template at the start of the file that will render `User` and `Conversation` components. For `User`, an update hook will call a function `getJWT` in the script you'll add next. You can also add a reference to the component to access it later on:

```vue
<template>
  <div class="nexmo">
    <User @hook:updated="userUpdated" ref="user" />
    <Conversation/>
  </div>
</template>
```

Below the template you'll add a script tag containing the component's logic. After importing the two subcomponents and the Nexmo Client SDK, you'll export a Vue component named `Nexmo`. It will contain some empty `data` properties that will be part of its state, as well as its subcomponents and some methods you'll define next:

```vue
<script>
  import User from './user.vue';
  import Conversation from './conversation.vue';
  import nexmoClient from 'nexmo-client';
  
  export default {
    name: 'Nexmo',
    data: () => ({
      app: null,
      token: null,
      invites: [],
      loggedIn: false
    }),
    components: {
      User,
      Conversation
    },
    methods: {}
  };
</script>
```

The `methods` property will define two functions, one to get a JWT from the server and one to handle logging in. The `getJWT` function is called by the update hook on your `User` component, so it should first check whether that component contains a `username` property. If it does, it can call the server-side `/getJWT` endpoint using `fetch`. It passes the stringified `username` value, and if everything works smoothly, gets a JWT in return. It stores the JWT as a property of the instance and calls the `login` function.

The `login` function is where you'll instantiate an actual Nexmo client. You'll log in your user with their JWT, then set a flag if that succeeds and save a reference to the Nexmo application. Once you have the application you can get the conversations the current user is invited to:

```javascript
    methods: {
      getJWT: function() {
        var username = this.$refs.user.username;
        if (!username) {
          return;
        }
        var vm = this;
        fetch('/getJWT', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            name: username
          })
        })
        .then(results => results.json())
        .then(data => {
          vm.token = data.jwt;
          vm.login();
        });
      },
      login: function() {
        let nexmo = new nexmoClient();
        nexmo.login(this.token).then(app => {
          this.loggedIn = true;
          this.app = app;
          app.getConversations().then(convos => {
            this.invites = Array.from(convos.entries());
          });
        });
      }
    }
```

## The User Component

The `User` component at `src/user.vue` is the first place you'll have a template that does something besides render a subcomponent. This is another bit you could skip in a production app, but in this case the user login interface is part of your Nexmo app. The template will show the connected user if one exists. If not, it shows a form with two paths. The first lets someone select an existing user from a dropdown. If a selection is made, the user is immediately updated by the `setExistingUser` function. 

A user can also supply a new username and click the submit button. This calls the `createUser` function:

```vue
<template>
  <div v-if="userId" class="userinfo userconnected">
    Connected as <span class="username">{{username}}</span>
  </div>
  <div v-else class="userinfo">
    <label>User name: 
      <select v-on:change="setExistingUser">
        <option value=""></option>
        <option v-for="item in currentUsers" v-bind:value="item.id">
          {{item.name}}
        </option>
      </select>
    </label>
    <input type="text" v-on:change="setUsername" />
    <button v-on:click="createUser">Create user</button>
  </div>
</template>
```

### User Component Script

The `script` for the component has a few different things going on, but no complex logic. Most of what it's doing is loading and saving properties. The complex stuff happens within the Vue framework itself, in functionality like the update hook in your `Nexmo` component.

There's nothing to import, so you can immediately export a `User` component. The only `data` it will need are properties for the user's ID and name, and a list of current users in the application.

The component has four methods to support the form in the template. The `getUsers` function calls `/getUsers` on the server to fetch the list of users. You'll remember that you've handled any necessary filtering logic server-side, so if there's no error you can just set that property on the component.

`setExistingUser` is called by an `onchange` event on the users dropdown. It saves the username and user ID of the selection made. For new users, `setUsername` is also called by an `onchange`, this time on the text field. Updating the new username on the component each time it changes saves you having to get a reference to the text field element. If a user clicks the "Create user" button, `createUser` is called, sending the username in state to the server and saving the user ID that gets returned. 

After `methods`, this component also calls `beforeMount` to make sure the list of users gets loaded when it's first initialized:

```vue
<template>
  ...
</template>

<script>  
export default {
  name: 'User',
  data: () => ({
    userId: undefined,
    username: null,
    currentUsers: []
  }),
  methods: {
    getUsers: function() {
      var vm = this;
      fetch('/getUsers', {
        method: 'GET'
      }).then(results => results.json())
      .then(data => {
        vm.currentUsers = data.users;
      });
    },

    setExistingUser: function(evt) {
      this.username = evt.target[evt.target.selectedIndex].text;
      this.userId = evt.target.value;
    },

    setUsername: function(evt) {
      this.username = evt.target.value;
    },

    createUser: function() {
      var vm = this;
      fetch('/createUser', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: vm.username
        })
      }).then(results => results.json())
        .then(data => { 
          vm.userId = data.id;
        });
    }
  },
  beforeMount() {
    this.getUsers()
  }
};
</script>
```

## The Conversation Component

Up to now, the code you've written has been to create your Nexmo app, set a user, and log in. It should be just separate enough that you can make changes to support the needs of your individual project while still exposing the essential pieces of information to your larger Vue app. Now you can use those pieces to join a conversation. The conversation is the jumping off point for a variety of types of communication you might wish to do using Nexmo's API on the client.

The component would be more manageable with a few subcomponents split out (e.g. the audio controls). However, to make things more obvious for now you can put all the code together in `conversation.vue`.

### The Template

At the top level of the template is a conditional to determine whether an ongoing conversation exists. If it does, you'll render an audio element to supply the sound, and two buttons to enable and disable audio. When clicked they'll call `enableAudio` and `disableAudio`, respectively. 

If there's no current conversation the user will need to join or start one. If the user has been invited to a conversation or has previously started one, it will appear in the `invites` array on the parent `Nexmo` component. The values in `invites` will populate a dropdown of conversations, and selecting one will call the `joinConversation` function. Whether or not the user has existing `invites`, they'll see a button to start a new conversation:

```vue
<template>
  <div v-if="current_conv" class="conversation">
    <audio ref="audio">
      <source/>
    </audio>
    <button v-on:click="enableAudio" v-bind:disabled="audioOn">
      Enable audio
    </button>
    <button v-on:click="disableAudio" v-bind:disabled="!audioOn">
      Disable audio
    </button>
  </div>
  <div v-else class="conversation">
    <label v-if="$parent.invites.length">Choose an active conversation: 
      <select v-on:change="joinConversation">
        <option value="0">-</option>
        <option v-for="invite in $parent.invites" v-bind:value="invite[0]">
          {{invite[1].name}}
        </option>
      </select> or
    </label>
    <button v-on:click="createConversation" :disabled="!$parent.loggedIn">
      Start conversation
    </button>
  </div>
</template>
```

### The Script

Again in this component, the only thing happening at the top level of the `script` tag is exporting a `Conversation` component. Its only `data` are the current conversation and a flag keeping track of whether audio is enabled.

The `methods` the component contains are all quite straightforward. `createConversation` calls the `newConversation` function of the app stored on the parent `Nexmo` component, then stores the created conversation. `joinConversation` does the same thing except that it calls the app's `getConversation` function, passing it the ID of the conversation selected in the dropdown.

In `enableAudio`, you first need to enable media on the current conversation. That will give you a stream which you can set as the `srcObject` or `src` of the `audio` element in your template. Once the metadata has loaded, you can play the stream and set the component's `audioOn` flag to `true`. The `disableAudio` function called when the "Disable audio" button is clicked is simpler. It just needs to disable media in `current_conv` and then set the `audioOn` flag back to `false`:

```vue
<template>
  ...
</template>

<script>
  export default {
    name: 'Conversation',
    data: () => ({
      current_conv: undefined,
      audioOn: false
    }),
    methods: {
      createConversation: function() {
        var vm = this;
        this.$parent.app.newConversation().then(conv => {
          conv.join();
          vm.current_conv = conv;
        });
      },
  
      joinConversation: function(evt) {
        var vm = this;
        this.$parent.app.getConversation(evt.target.value).then(conv => {
          conv.join();
          vm.current_conv = conv;
        });
      },

      enableAudio: function() {
        var vm = this;
        this.current_conv.media.enable().then(stream => {
          // Older browsers may not have srcObject
          if ('srcObject' in vm.$refs.audio) {
            vm.$refs.audio.srcObject = stream;
          } else {
            // Avoid using this in new browsers, as it is going away.
            vm.$refs.audio.src = window.URL.createObjectURL(stream);
          }
          vm.$refs.audio.onloadedmetadata = () => {
            vm.$refs.audio.play();
            vm.audioOn = true;
          }
        });
      },

      disableAudio: function() {
        var vm = this;
        this.current_conv.media.disable().then(() => {
          vm.audioOn = false;
        });
      }
    }
  };
</script>
```

## The Rest

There are a few things we haven't covered, which are hopefully supplied by the Vue boilerplate you've chosen or don't necessarily have to affect the logic of your application. For example, in my own code I'm relying on [Browserify](http://browserify.org/) and [Vueify](https://github.com/vuejs/vueify), as well as a bit of CSS that was part of the project I remixed. The build step that makes the Vue side of the application work is defined in "scripts" in `package.json`:

```json
  "compile": "browserify -t vueify -e src/main.js -o public/build.js"
```

## Next Steps

The code you've written is very much a starting point for your real-world work. As mentioned, you'll probably want to replace the test user management system with something that ties conversation members to your own authenticated users. With your conversation created you can send and receive messages, receive calls, and set up audio conferencing. 

Read more about the Nexmo Client SDK to find out what you can do next:

- [Client SDK Overview](https://developer.nexmo.com/client-sdk/overview)
- [Send and receive `text` events](https://developer.nexmo.com/client-sdk/in-app-messaging/guides/simple-conversation)
- [Invite users to the conversation](https://developer.nexmo.com/client-sdk/in-app-messaging/guides/inviting-members)
- [Contact Center Use Case](https://developer.nexmo.com/client-sdk/in-app-voice/contact-center-overview)