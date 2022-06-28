---
title: Track Users Connections Using Video API and Session Monitoring
description: Session Monitoring offers reliable and secure connection monitoring
  in Vonage Video API. Developers can monitor server-side activity and verify
  each connection.
thumbnail: /content/blog/track-users-connections-using-video-api-and-session-monitoring/session-monitoring.png
author: enrico-portolan
published: true
published_at: 2022-06-28T09:14:01.363Z
updated_at: 2022-06-28T09:14:03.020Z
category: tutorial
tags:
  - video-api
  - javascript
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introduction

In the last few years, we have seen an incredible rise in online event platforms where a user buys a ticket and joins an event, concert, or private lesson with a teacher from their browser.
These platforms need to ensure that only authorized users can join the event or lesson and need fine-grained control of the time in which users are connected to a specific session. The best way to implement this is to have a mechanism that notifies the application server about connections and streams published into a session in the form of a real-time webhook.

[Session Monitoring](https://tokbox.com/developer/guides/session-monitoring/) offers a reliable and secure way to monitor connections in a Vonage Video API Application. Adding Session Monitoring provides an extra layer of security for developers to monitor client activity from the server-side, verify each connection to a video session, and log each action for compliance reasons.

## Main Concepts

Using the Session Monitoring webhooks, developers can receive real-time session event callbacks and monitor their session activity from their app server. OpenTok infrastructure can send HTTP requests for all connections made (and destroyed) and streams created (and destroyed).

Let’s breakdown the available events:

* `connectionCreated`: fired when a client connects to a session
* `connectionDestroyed`: fired when a client disconnects from a session
* `streamCreated`: fired when a client publishes a stream to a session
* `streamDestroyed`: fired when a client unpublishes a stream from a session


Each event has a payload. Let’s analyze the `connectionCreated` event as an example: 

```
{
    "sessionId": "2_MX4xMzExMjU3MX5-MTQ3MDI1NzY3OTkxOH45QXRr",
    "projectId": "123456",
    "event": "connectionCreated",
    "timestamp": 1470257688309,
    "connection": {
        "id": "c053fcc8-c681-41d5-8ec2-7a9e1434a21e",
        "createdAt": 1470257688143,
        "data": "TOKENDATA"
    }
}
```

The event payload has data that can be used to create the business logic that the platform needs. For example, we can use the `connectionId` and `timestamp` to compute the connection time of a specific user. In the next sections, we will dig into more detailed examples.

## Limit the connection time of users in a session

Let’s assume we have an education website where students pay for one-hour lessons with a teacher. After the hour expires, the user needs to be disconnected from the session. How can we implement this using Session Monitoring?


For this use case, we need to listen to the `connectionCreated` and `connectionDestroyed` events. The logic is going to be the following: 

* Start the session timer only if the connections are greater or equal to two
* Check every 5 seconds for the elapsed time
* When the time is expired, force disconnect the users

Let’s see the code:

```js
app.post('/session-monitoring', async (req, res) => {
   const { sessionId, projectId, event, timestamp, connection } = req.body;
   const roomName = sessions[sessionId];
    switch (event) {
            case "connectionCreated":
                // There are at least 2 users
if (session.connections && session.connections.length > 1) {
            session.interval = setInterval(() => {
                const now = new Date().getTime();
                session.connections.sort((x, y) => { return y.timestamp - x.timestamp }) // Make sure they are ordered by latest connections;
                if ((now - session.connections[0].timestamp) > limitedTimeRoomMinutes * 60 * 1000) { 
                    // time has expired, let's disconnect them
                    for (let i = 0; i < session.connections.length; i += 1) {
                        opentok.forceDisconnect(sessionId, session.connections[i].connection.id);
                    }
                    clearInterval(session.interval)
                }
            }, roomInterval.intervalValue)
        }
                break;
       case "connectionDestroyed":
                break;
            case "streamCreated":
                break;
            case "streamDestroyed":
                break;
            default:
                console.warn("Not handled case, this should not happen");
})
```

## Limit the size of a session

Let’s suppose that we want to limit the size of a session, for example to a one-to-one. If someone else connects, the code is going to kick them out. Let’s see the code: 

```js
switch (event) {
            case "connectionCreated":
session.connections = [...session.connections, { connection, timestamp }];
             break;
            case "connectionDestroyed":
               if (session && session.connections) {
        for (let i = 0; i < session.connections.length; i += 1) {
            if (session.connections[i].connection.id === connection.id) {
                session.connections.splice(i, 1);
                break;
            }
        }
    	  }
              break;
}

if (session.connections && session.connections.length > 2) {
      opentok.forceDisconnect(sessionId, connection.id);
 }
```

In this case, the code is tracking how many connections are inside a session. If the connection number is greater than 2, it is going to disconnect the user who has tried to connect.
Following this approach, the third connection would be able to connect for a few seconds and once the server receives the `connectionCreated` hook, the user will be kicked out. It’s possible to improve this behaviour by not even letting the third user connect to the session. 
When the third user requests the credentials to join, the server can check the number of connections in the session. If there are already two connections, the server will not send the credentials to the third user and show an error message:

```js
app.get('/room/:room', (req, res) => {
    const roomName = req.params.room;
    if (sessions[roomName]) {
       if (sessions[roomName].connections.length >= 2) {
       renderRoom(res, null,null,null, roomName);	
} else {
  const sessionId = sessions[roomName].sessionId;
        const dataToken = opentok.generateToken(sessionId);
        renderRoom(res, dataToken.apiKey, sessionId, dataToken.token, roomName);
}
        
    } else {
        setSessionDataAndRenderRoom(res, roomName);
    }
});
```

## Additional Use Cases

We have seen the two main use cases for session monitoring but there are many more, such as allowing only authorized users to join the session or limiting the type of stream a user can publish.

## Allow only authorized users to join the session

In the online events vertical it’s important to allow only authorised users to join events. For example, only ticket holders can join a specific conference. We have a list of users that have paid for the event and are allowed to join, how can you interpolate this data with Session Monitoring? 

When you create a token to join a session, you can add [metadata](https://tokbox.com/developer/guides/create-token/). 
The metadata will be available on the connection events webhook. When you receive the `connectionCreated` event, you can check who the connection is and verify the data with your allowed users in the database. If the user is not authorised to join the session, the server will force disconnect him.

## Allow only specific streams to publish screen share

We have only seen how to use the connection created and destroyed events so far, so let’s make an example of how to leverage the stream created or destroyed event. Streams events have additional data such as `name` and `videoType` of the stream. 
Using the latter, we can implement a use case where only allowed users can share their screens. Think about a financial consultancy company, where we want only the financial advisor to be able to share the screen and not the customer (avoid sharing sensitive information). When the server receives the `streamCreated` event, it can check if `videoType` is screen and if the user is allowed to share the screen. If not, it can unpublish the stream from the session.

## How to register the webhooks?

Session events and archive status update information can all be registered to HTTP endpoints within your server. Whenever registered activity occurs, an HTTP request is issued from OpenTok infrastructure to your endpoint.

To register a callback:

1. Visit your Vonage Video API account page
2. Select the OpenTok project for which you want to register a callback
3. Set the callback URL in the Session Monitoring section

A very important thing to note is that if within 30 minutes there are more than 50 event delivery failures (in which we don't receive a 200 success response when sending an HTTP request to your callback URL), we will disable session monitoring event forwarding. We will send an email if this occurs

## Sample Application

The [Video API Session Monitoring](https://github.com/nexmo-se/video-api-session-monitoring) sample app shows two of the examples mentioned above:

1. Limit the connection time of users in a session on the page locahost:5000/room/limited-time-room, the server will start a timer when there are at least 2 connections (2 users). The timer will check every 5 seconds the time remaining for the session. When the time has expired, the server will force disconnect the users from the session using the [forceDisconnect](https://tokbox.com/developer/rest/#forceDisconnect) function


2. Limit the size of a session: on the page `locahost:5000/room/one-to-one`, the server will allow only two users (connections) connected to the room. If there is a third connection, the server will immediately disconnect it

# Conclusion

Session monitoring is a swiss knife feature to add security and implement server-side checks to your video application. To see some of the examples described in this blog post in action have a look at the Github repo: <https://github.com/nexmo-se/video-api-session-monitoring>.
This blog post shows a couple of use cases implemented with the session monitoring webhooks. Having the data about connections and streams on the server-side gives the flexibility to developers to monitor, store and react to events in real-time.

If you have tried this feature and have questions about it, come join our [Vonage Community Slack](https://developer.vonage.com/community/slack) or send us a message on [Twitter](https://twitter.com/VonageDev).
