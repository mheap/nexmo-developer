---
title: Build a Breakout Room Application in JavaScript with Vonage Video API
description: "This tutorial explains how to use the separate sessions to build
  the Breakout Room feature into our Demo Application, which "
thumbnail: /content/blog/build-a-breakout-room-application-in-javascript-with-vonage-video-api/breakoutroom.jpg
author: iu_jie_lim
published: true
published_at: 2022-05-24T11:04:44.847Z
updated_at: 2022-05-24T12:51:48.481Z
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

*This article was written in collaboration with* [Yinping Ge](https://developer.vonage.com/blog/authors/yinping-ge)

Breakout Room is a common feature required by many customers, especially those in education. It often allows "splitting the main meeting room into separate ones", "splitting participants into these breakout rooms", and "participants to send messages to the host no matter which room they are in", etc.

With Vonage [Video API](https://www.vonage.com/communications-apis/video/), there is more than one way to implement such a Breakout Room feature for your application.

One way is to create a big [Video Session](https://tokbox.com/developer/guides/basics/#sessions) with logic controlling which streams to subscribe to for each user. Another one is "implement breakout rooms as separate sessions", then "connect participants to these different sessions created for each breakout room".

This tutorial explains how to use the **separate sessions** to build the Breakout Room feature into our Demo Application, which uses signaling API to implement breakout room management re-uses the Publisher object when switching back and forth among rooms

Hope the following graphs can give you a general idea first. Initially, all participants connect to the main-room’s session:

![Graph showing all participants connect to the main-room’s session](/content/blog/build-a-breakout-room-application-in-javascript-with-vonage-video-api/screenshot-2022-05-18-at-14.53.42.png)

After the host clicks the button to create breakout rooms, the application server calls Vonage Video API to create a session for each breakout room and returns these session IDs to each participant.

![Graph showing application connects participants to breakout rooms](/content/blog/build-a-breakout-room-application-in-javascript-with-vonage-video-api/screenshot-2022-05-18-at-15.15.15.png)

Then the application connects participants to these breakout rooms' sessions by letting participants choose a room to join or splitting participants into different rooms automatically, depending on what option the host has selected when creating the breakout rooms. (Host can choose between "Assign automatically" and "Let participants choose a room").

## Prerequisites

A Vonage Video API account. Click [Sign Up](https://www.tokbox.com/account/user/signup) to create one if you don't have one already.
ReactJS version >= 16.8
Node.js version >= 16.13
PostgreSQL 14 as the Database, you can choose any storage you prefer

You should be able to see all the dependencies in the [GitHub repo](https://github.com/nexmo-se/video-breakout-room) and we’d suggest you always use the latest version of Vonage SDK. The versions listed here were the ones used when we were working on this demo app.

## Application’s Server and Database Design

The application server creates rooms, creates sessions, generates tokens, maintains the rooms and participants, and sends signaling messages to rooms.

The application server acts as a "relay" by utilizing the [Signaling-REST API](https://tokbox.com/developer/guides/signaling/rest/) for passing messages between different rooms/sessions for scenarios like one participant needs to raise-hand to the host who’s in a different room (i.e. connected to another session), and for the main feature: breakout rooms management. We will explain in detail later how we use the signaling messages in managing breakout rooms.

When running the application server, the room table will be created if non-exist. I understand that the room table might be a bit more complex in real life. Here we just list the basic data we need. The script to create the room table is as below:

```sql
CREATE TABLE IF NOT EXISTS rooms(
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) DEFAULT NULL,
    session_id VARCHAR(255) DEFAULT NULL,
    main_room_id VARCHAR(255) DEFAULT NULL,
    max_participants SMALLINT DEFAULT 0
)
```

The `session_id` stores the id of a session associated with the room. The `max_participants` defines the maximum number of participants the room allows. The `main_room_id` differentiates whether this is a breakout room that belongs to the main room or just a main room that can have breakout rooms: when it is set to `NULL`, it is a main room; otherwise, it is a breakout room and its value should be set to the room id of its main room.

Initially, on the log-in page, all users choose to join one room, aka the main room. Upon receiving the front-end request, the application server calls Video API to create a session for this main room and adds a record to the room table with `session_id` set to the id of the session created and `main_room_id` set to `NULL`. Then it returns the `session_id` to all logged-in users for them to connect to the session.

When the meeting is on-going and a host user decides to create breakout rooms, after they submits options listed in "Breakout Room Control", such as how many breakout rooms to be created", "Let participants choose room", or "Assign automatically", etc. Front-end sends a `createSession` request with the parameter `breakoutRooms` carrying the above selections to the application server, which will then create a session for each breakout-room accordingly and store the session id and other information to the room table, one record for each breakout room with `main_room_id` set to the main room id.

## Use Signaling API to Implement Breakout Room Management

The Room object holds the references to the session, message(breakoutRoomSignal) and participants and provides the entries for creating breakout rooms and managing participants.

The application uses [Signaling-REST API](https://tokbox.com/developer/guides/signaling/rest/) to send messages to clients connected to all sessions related to a main-room/breakout-room, informing of room changes, timer and raise-hand requests, etc.

For example, signaling message with below type and data is to inform application users of new breakout rooms being created and they can choose one to join:

```json
{
   "type": "signal:breakout-room",
   "data": {
       "message": "roomCreated (chooseroom)",
       "breakoutRooms": \[], //array of available rooms
   }
}
```

* signaling message to inform "all rooms have been removed":

```json
{
     "type": "signal:breakout-room",
     "data": {
         "message": "allRoomRemoved",
         "breakoutRooms": \[...],
     }
 }
```

* inform a participant that is moved from one (breakout) room to another:

```json
{
   "type": "signal:breakout-room",
   "data": {
       "message": "'participantMoved'",
       "breakoutRooms": \[...],
   }
}
```

* while, a signaling message with type set to `signal:count-down-timer` is to inform of a timer:

```json
{
   "type": "signal:count-down-timer",
   "data": {
       "period": 1,
   }
}
```

For these `breakoutRoomSignal` messages, the app takes actions accordingly, for example for `participantMoved`, it moves the participant to the assigned room.

```javascript
if (mMessage.breakoutRoomSignal.message === 'participantMoved' && roomAssigned && (!currentRoomAssigned || currentRoomAssigned.id !== roomAssigned.id)) {
    setCurrentRoomAssigned(roomAssigned);
    mNotification.openNotification("Room assigned by Host/Co-host", `You will be redirected to Room: ${roomAssigned.name} in 5 seconds.`, () => handleChangeRoom(roomAssigned.name))
}
```

Within `handleChangeRoom`, the application will leave the current room (by disconnecting from its associated session) and join to the assigned room (by connecting to its associated session).

```javascript
async function handleChangeRoom(publisher, roomName) {
    const newRooms = \ [...mMessage.breakoutRooms];
    let targetRoom = newRooms.find((room) => room.name === roomName);

    await mSession.session.unpublish(publisher);
    await mSession.session.disconnect();

    const connectionSuccess = await connect(mSession.user, targetRoom ? targetRoom.id : '');

    if (!connectionSuccess) {
        // Force connect to main room;
        targetRoom = null;
        roomName = '';
        await connect(mSession.user);
    }

    let data = {
        fromRoom: currentRoom.name,
        toRoom: roomName ? roomName : mainRoom.name,
        participant: mSession.user.name
    }

    setInBreakoutRoom(targetRoom && targetRoom.name !== mainRoom.name ? targetRoom : null);
}
```

## Re-Use the Publisher Object When Switching Back and Forth Among Rooms

When a participant leaves the main room and joins a breakout room (or otherwise),  **it is recommended to re-use the Publisher object** to save resources.

For each `type": "signal:breakout-room` message that can lead a client to leave a room and join another room, eg. `roomCreated (automatic)`, what the application does is to disconnect from a session and then connect to another session. Within the process, the stream published to the previous session will be destroyed and the event [streamDestroyed](https://tokbox.com/developer/sdks/js/reference/StreamEvent.html) will be dispatched to the publisher client. In order to retain the Publisher object for reuse, the method preventDefault of the streamDestroyed event should be called.

```javascript
function handleStreamDestroyed(e) {
    if (e.stream.name !== "sharescreen") e.preventDefault();
    if (e.reason === 'forceUnpublished') {
        console.log('You are forceUnpublished');
        setStream({
            ...e.stream
        })
        setPublisher({
            ...e.stream.publisher
        })
    }
}
```

The demo application re-uses this Publisher object to publish to the session associated with the breakout room.

```javascript
async function publish(
    user,
    extraData
) {
    try {
        if (!mSession.session) throw new Error("You are not connected to session");
        if (!publisher || publisherOptions.publishVideo !== hasVideo || publisherOptions.publishAudio !== hasAudio) {


            if (publisher) resetPublisher();
            const isScreenShare = extraData && extraData.videoSource === 'screen' ? true : false;
            const options = {
                insertMode: "append",
                name: user.name,
                publishAudio: isScreenShare ? true : hasVideo,
                publishVideo: isScreenShare ? true : hasAudio,
                style: {
                    buttonDisplayMode: "off",
                    nameDisplayMode: displayName ? "on" : "off"
                }
            };
            const finalOptions = Object.assign({}, options, extraData);
            setPublisherOptions(finalOptions);
            const newPublisher = OT.initPublisher(containerId, finalOptions);
            publishAttempt(newPublisher, 1, isScreenShare);
        } else {
            publishAttempt(publisher);
        }
    } catch (err) {
        console.log(err.stack);
    }
}
```

## Conclusion

Using the way of creating separate sessions for the breakout room feature, you only need to worry about connecting participants to the right session.
Take a look at [the code](https://github.com/nexmo-se/video-breakout-room) for more details and hopefully, you find this insightful for your breakout room application.
