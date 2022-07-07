---
title: Create a Chat App with React and Nexmo
description: Add a chat application to your website using React and Nexmo's
  client-side JavaScript tooling, building on our Full-Stack App with React and
  Express code
thumbnail: /content/blog/chat-app-with-react-and-nexmo-dr/React_Nexmo.png
author: garann-means
published: true
published_at: 2019-08-30T19:29:59.000Z
updated_at: 2021-05-10T14:05:39.458Z
category: tutorial
tags:
  - javascript
  - conversation-api
  - react
comments: true
redirect: ""
canonical: ""
---
One of the simplest ways to communicate online is also among the simplest to add to your website, using [React](https://reactjs.org/) and [Nexmo's client-side JavaScript tooling](https://developer.vonage.com/client-sdk/overview). A chat application can provide customer service, facilitate collaboration on a project, or let you catch up with friends. And good news: if you've followed our previous [full-stack React and Express tutorial](https://www.nexmo.com/blog/2019/03/15/full-stack-nexmo-with-express-react-dr), you already have most of the pieces you need to build one.

## Prerequisites

To keep things short, let's assume you _have_ followed the [React and Express tutorial](https://www.nexmo.com/blog/2019/03/15/full-stack-nexmo-with-express-react-dr). 

As in the full-stack example code, the [example code](https://glitch.com/edit/#!/nexmo-react-chat-app) for this tutorial will satisfy the latter requirement by using Glitch. 

If you use the Nexmo Application you created for your full-stack app, you can generate one or two Conversation IDs and copy those to a text file for use in the next step. If you prefer to create a new application for this project, you can [create the conversations from the command line](https://developer.vonage.com/client-sdk/in-app-messaging/guides/simple-conversation#1-2-create-a-conversation).

<sign-up></sign-up>



## Adding Chat Rooms to NexmoApp

To keep functionality separate, add a new component to your React application at `client/src/Chatroom.js`. For now, you can leave it mostly empty:

```javascript
import React from 'react';
import styles from './Chatroom.css';

class Chatroom extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }
};

export default Chatroom;
```

You can also add its CSS file, and populate that with whatever styling you like at any stage.

If you open `NexmoApp.js` you'll see a couple of references to the `Conversation` component. The `Chatroom` component will be used similarly, so you can just replace those with references to `Chatroom`. They should be in the `import`s and the `render` function.

Within `render`, change the `Chatroom` component tag just slightly so that instead of passing `invites`, you're passing `chats`:

```react
  render() {
    return (
      <div className="nexmo">
        <User onUpdate={this.userUpdated}/>
        <Chatroom app={this.state.app} loggedIn={!!this.state.token} chats={this.state.chats} />
      </div>
    );
  }
```

The other properties passed to `Chatroom` already exist as part of user authentication and logging in, but `chats` isn't currently part of the state. For this simple app, hard-code the Conversations you created above into the component's initial state. You can give them any names you like to differentiate them for end users:

```javascript
constructor(props) {
    super(props);
    this.state = {
      chats: [
        {
          id: 'CON-123e456c-5ff0-789c-8a11-e4a56a7b8c90',
          name: 'nice chat'
        },
        {
          id: 'CON-2c34ecec-f567-8e90-bf1d-23e4567e890a',
          name: 'serious business'
        }
      ]
    };
    
    this.login = this.login.bind(this);
    this.getJWT = this.getJWT.bind(this);
    this.userUpdated = this.userUpdated.bind(this);
  }
```

Because this app won't manage conversations or invitations, you can also delete the code in `login` to get Conversations. This leaves that function only logging in and storing a reference to the Nexmo application:

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

## A Simple Chatroom

You can leave all the `User` component code alone. It will continue to do the same thing, creating a new user or offering a list of existing users. Once the user is logged in, they can continue on to chat.

The `Chatroom` component will contain two states: choosing a chat room and the chat room itself. Behind the scenes, a chat room is just a [Nexmo Conversation](https://developer.vonage.com/conversation/overview), so some of this component code will look similar to what's in the `Conversation` component. You can stub out the functions and conditionals needed for both states to get started:

```react
import React from 'react';
import styles from './Chatroom.css';

class Chatroom extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: []
    };
    
    this.joinConversation = this.joinConversation.bind(this);
    this.onMessage = this.onMessage.bind(this);
    this.setInput = this.setInput.bind(this);
    this.sendInput = this.sendInput.bind(this);
  }
  
  joinConversation(evt) {}
  
  onMessage(sender, message) {}
  
  setInput(evt) {}
  
  sendInput() {}
  
  render() {
    if (this.state.conversation) {
      
    } else {
     
    }
  }
};

export default Chatroom;
```

## Joining a Chat

Since the user has a finite set of predefined chat rooms to choose from a dropdown will allow them to easily select one. If you only had a single chat, you could do away with this interface entirely. To produce a dropdown for the two chat rooms hard-coded in `NexmoApp`, loop over the array to build a set of `option`s, then add them as children of a `select`:

```react
  render() {
    if (this.state.conversation) {
    } else {
      let opts = [<option key="0">-</option>];
      this.props.chats.forEach(chat => {
        opts.push(<option key={chat.id} value={chat.id}>{chat.name}</option>);
      });
      
      return (
        <div className="conversation">
          <label>Choose a chat to join: 
            <select onChange={evt => this.joinConversation(evt)}>
              {opts}
            </select>
          </label>
        </div>
      );
    }
  }
```

When the dropdown value changes, `joinConversation` gets triggered. The `joinConversation` handler will get the chosen conversation by its ID from the Nexmo app and then join it. It also stores a reference to it and assigns it another event handler for incoming messages:

```javascript
  joinConversation(evt) {
    let select = evt.target;
    this.props.app.getConversation(select.value).then(conv => {
      conv.on('text', this.onMessage);
      conv.join();
      this.setState({
        conversation: conv
      });
    });
  }
```

The `onMessage` handler gets triggered whenever there's a new `text` event in the active Conversation. It receives information about the Conversation Member who triggered the event, and the event object itself. For a simple chat you can discard most of that information and save only the ID, user display name, and message text. This information can be concatenated onto a list of messages stored in the state:

```javascript
  onMessage(sender, message) {
    let newMessages = this.state.messages.concat({
      key: message.id,
      sender: sender.display_name,
      text: message.body.text
    });
    this.setState({
      messages: newMessages
    });
  }
```

> If you were designing even a simple chat like this for production use, you'd want to plan to move older messages into a different storage object after some time. With any significant amount of traffic, a single array to hold all messages will inevitably cause problems.

## Sending Messages

Once the user is logged in and has joined a chat, they'll want to send and receive messages. This means you want to render a UI with, at minimum, an area for viewing messages and an input field for text. The JSX for this fills out the other branch of the main conditional in `render`. It iterates over your array of messages and renders anything received since the user joined the chat. Below that, it provides a textarea and button that set newly inputted text and send it, respectively:

```react
  render() {
    if (this.state.conversation) {
      let messagePane = [];
      
      if (this.state.messages.length) {
        this.state.messages.forEach(msg => {
          messagePane.push(<p key={msg.key} className="message"><b>{msg.sender}:</b>{msg.text}</p>);
        });
      }
      
      return (
        <div className="conversation">
          <div className="messages">
            {messagePane}
          </div>
          <div className="input">
            <textarea onBlur={evt => this.setInput(evt)} />
            <button onClick={evt => this.sendInput(evt)}>Chat</button>
          </div>
        </div>
      );
    } else {
      ...
    }
  }
```

The events raised by the message input are handled in `setInput` and `sendInput`. `setInput` very simply stores the inputted text in the component state:

```javascript
  setInput(evt) {
    this.setState({
      input: evt.target.value
    });
  }
```

The button handler, `sendInput`, takes the text stored in the state and passes it to the Conversation using `sendText`. It then clears the text in the state and in the textarea preceding it:

```javascript
  sendInput(evt) {
    this.state.conversation.sendText(this.state.input).then(() => {
      this.setState({
        input: null
      });
    });
    evt.target.previousSibling.value = '';
  }
```

## Chat Away!

Though it's missing error handling and pays no attention to performance, now you have a very basic chat application. Stripping away the features of a production app reveals how little you need to provide core chat functionality:

1. A User logged in to a Nexmo Application
2. A Conversation for the User to join
3. An event handler for received messages
4. The `sendText` function to enable chatting

Whether you want to create an old school chat room, a pop-up conversation to help confused customers, or anything else, you can build it starting with these elements. You don't need to handle any sockets or polling. And with React, you don't need to do anything to trigger DOM updates. Now you can turn your attention to your UI and the app's robustness. 
