---
title: Release Notes
description: Release notes. A list of most important fixes and new features for Client SDK.
navigation_weight: 0
---

# Release Notes

## Version 9.0.0 - June 30, 2022

### Breaking changes

- Rename `login()` function to `createSession()`

```javascript
rtc.createSession(token).then((application) => {
  console.log(application);
}).catch((error) => {
  console.log(error);
});
```

- Rename `logout()` function to `deleteSession()`

```javascript
rtc.deleteSession().then((response) => {
  console.log(response);
}).catch((error) => {
  console.log(error);
});
```

### Changes

- Move websocket connection creation to the `createSession()` function

## Version 8.7.3 - June 14, 2022

### Changes

- Added token authentication to `connectivityReport()`

```javascript
rtc.connectivityReport(token, {
  dcListCallback: (dcList) => {...dcList, additionalDc}
}).then((report) => {
  console.log(report);
}).catch((error) => {
  console.log(error);
});
```

- Added token authentication to `checkMediaServers()`

```javascript
rtc.checkMediaServers('token', 'nexmo-api-url','dc').then((responseArray) => {
 console.log(responseArray);
}).catch((error) => {
  console.log(error);
});
```

## Version 8.7.2 - May 27, 2022

### Fix

- Removed unused npm dependencies.

## Version 8.7.1 - May 11, 2022

### New

- Added new `checkMediaServers()` method to return a list with the connection health of the media servers for a specific datacenter.

```javascript
rtc.checkMediaServers('nexmo-api-url','dc').then((responseArray) => {
	console.log(responseArray);
}).catch((error) => {
  console.log(error);
});
```

- Added new `checkMediaConnectivity()` method to return the connection health of a single media server.

```javascript
rtc.checkMediaConnectivity('ip-address','1').then((response) => {
  console.log(response);
}).catch((error) => {
	console.log(error);
});
```
### Changes

- Update `connectivityReport()` to return connection time in ms for connection to https, wss, and media servers

## Version 8.6.0 - April 21, 2022

### New

- Added an optional object argument to the `connectivityReport()`, with optional field `dcListCallback` which accepts a callback function to update data center list

```javascript
rtc.connectivityReport({
  dcListCallback: (dcList) => {...dcList, additionalDc}
}).then((report) => {
  console.log(report);
}).catch((error) => {
  console.log(error);
});
```

## Version 8.5.0 - April 20, 2022

### New

- Expose `seen()` and `delivered()` functions for message events

```javascript
messageEvent.seen().then(() => {
  console.log(`Seen message with id ${messageEvent.id}`);
}).catch((error) => {
  console.log(error);
});
```

- Support new message status events
  - `message:seen`
  - `message:delivered`
  - `message:submitted`
  - `message:rejected`
  - `message:undeliverable`

```javascript
conversation.on("message:delivered", (member, event) => {
  console.log(`Message with id ${event.id} delivered to ${member.name}`);
});
```

- Added new state objects for message events supporting the new statuses
  - `seen_by`
  - `delivered_to`
  - `submitted_to`
  - `rejected_by`
  - `undeliverable_to`

### Changes

- Update `connectivityReport()` to use proper endpoints per region

## Version 8.4.1 - February 14, 2022

### Fix

- Fix events ordering when gap in inbound events

## Version 8.4.0 - January 21, 2022

### New

- Added new `connectivityReport()` function to get a connectivity report for all Vonage data centers and media servers

```javascript
rtc.connectivityReport().then((report) => {
  console.log(report);
}).catch((error) => {
  console.log(error);
});
```

## Version 8.3.1 - December 09, 2021

### New

- Set the default sync level for the login process from `lite` to `none`

## Version 8.3.0 - November 01, 2021

### New

- Added new `uploadImage()` function to upload an image to the Vonage Media Service

```javascript
const params = {
  quality_ratio : "90",
  medium_size_ratio: "40",
  thumbnail_size_ratio: "20"
};

conversation.uploadImage(fileInput.files[0], params).then((uploadImageRequest) => {
  uploadImageRequest.onprogress = (e) => {
    console.log("Image request progress: ", e);
    console.log("Image progress: " + e.loaded + "/" + e.total);
  };
  uploadImageRequest.onabort = (e) => {
    console.log("Image request aborted: ", e);
    console.log("Image: " + e.type);
  };
  uploadImageRequest.onloadend = (e) => {
    console.log("Image request successful: ", e);
    console.log("Image: " + e.type);
  };
  uploadImageRequest.onreadystatechange = () => {
    if (uploadImageRequest.readyState === 4 && uploadImageRequest.status === 200) {
      const representations = JSON.parse(uploadImageRequest.responseText);
      console.log("Original image url: ", representations.original.url);
      console.log("Medium image url: ", representations.medium.url);
      console.log("Thumbnail image url: ", representations.thumbnail.url);
    }
  };
}).catch((error) => {
  console.error("error uploading the image ", error);
});
```

- Added new `sendMessage()` function to send a new `message` to the conversation (supported types are `text`, `image`, `audio`, `video` and `file`)

```javascript
conversation.sendMessage({
  "message_type": "text",
  "text": "Hi Vonage!"
}).then((event) => {
  console.log("message was sent", event);
}).catch((error)=>{
  console.error("error sending the message ", error);
});
```

```javascript
conversation.sendMessage({
  "message_type": "image",
  "image": {
    "url": "https://example.com/image.jpg"
  }
})
.then((event) => {
  console.log("message was sent", event);
}).catch((error)=>{
  console.error("error sending the message ", error);
});
```

- Added new `MessageEvent` type of event

```javascript
conversation.on("message", (member, messageEvent) => {
  console.log(messageEvent);
});
```

### Changes

- Deprecate `sendText()` function (use `sendMessage()` with a type of `text` instead)

```javascript
conversation.sendMessage({ "message_type": "text", "text": "Hi Vonage!" }).then((event) => {
  console.log("message was sent", event);
}).catch((error)=>{
  console.error("error sending the message ", error);
});
```

- Deprecate `sendImage()` function (use `uploadImage()` and `sendMessage()` with a type of `image` instead)

```javascript
conversation.uploadImage(imageFile).then((imageRequest) => {
  imageRequest.onreadystatechange = () => {
    if (imageRequest.readyState === 4 && imageRequest.status === 200) {
      try {
        const { original, medium, thumbnail } = JSON.parse(imageRequest.responseText);
        const message = {
          message_type: 'image',
          image: {
            url: original.url ?? medium.url ?? thumbnail.url
          }
        }
        return conversation.sendMessage(message);
      } catch (error) {
        console.error("error sending the message ", error);
      }
    }
    if (imageRequest.status !== 200) {
      console.error("error uploading the image");
    }
  };
  return imageRequest;
})
.catch((error) => {
  console.error("error uploading the image ", error);
});
```

## Version 8.2.5 - October 12, 2021

### Fix

- Fix error handling for audio permissions

## Version 8.2.2 - October 08, 2021

### Fix

- Enhance debug logs

## Version 8.2.0 - September 28, 2021

### New

- Add new `getUserSessions()` function to fetch the sessions of the logged in user

```javascript
application.getUserSessions({ user_id: "USR-id", page_size: 20 }).then((user_sessions_page) => {
  user_sessions_page.items.forEach(user_session => {
    render(user_session)
  })
}).catch((error) => {
  console.error(error);
});
```

## Version 8.1.1 - September 08, 2021

### New

- Add new optional `mediaParams` parameter in `reconnectCall` function, in order to modify the `MediaStream` object

```javascript
application.reconnectCall(
  "conversation_id",
  "rtc_id",
  { audioConstraints: { deviceId: "device_id" } }
).then((nxmCall) => {
  console.log(nxmCall);
}).catch((error) => {
  console.error(error);
});
```

- Update `media.enable()` docs to include audio constraints

### Fixes

- Assign the correct `NXMCall` status when reconnecting to a call (`STARTED`, `RINGING` or `ANSWERED`)

### Changes

- Update `npm` dependencies

## Version 8.1.0 - September 02, 2021

### New

- Add `reconnectCall` function allowing users to reconnect to a call within 20 seconds if browser tab closed

```javascript
application.reconnectCall("conversation_id", "rtc_id").then((nxmCall) => {
  console.log(nxmCall);
}).catch((error) => {
  console.error(error);
});
```

- Add optional parameter `reconnectRtcId` to media `enable()` function to reconnect media to call

```javascript
conversation.media.enable({ reconnectRtcId: "UUID" }).then((stream) => {
  console.log(stream)
}).catch((error) => {
  console.error("error renabling media", error);
});
```

- Add `custom_data` object in `callServer` function

```javascript
application.callServer("<phone_number>", "phone", { field1: "test" }).then((nxmCall) => {
  console.log(nxmCall);
}).catch((error) => {
  console.error(error);
});
```

- Add `apiKey`, `applicationId`, `conversationId` and `conversationName` when available in `rtcstats` analytics reports

### Fixes

- Fix bug in call transfer where `transferred_from` was undefined

## Version 8.0.5 - July 15, 2021

### Fixes

- Fix the `from` for member events
- Update `npm` dependencies including `socket-io`

## Version 8.0.4 - June 16, 2021

### Fixes

- Fix bug on `DTMF` dispatch of callback to `event_url`

## Version 8.0.3 - May 18, 2021

### Fixes

- Fix out of order internal events processing in the events queue
- Fix deprecation warning message for `rtcstats:report`

## Version 8.0.1 - April 29, 2021

### Fixes

- Update Typescript definitions
- Fix bug on IP-IP call scenario involving Native SDKs (not populating properly the `Conversation.members` Map)

## Version 8.0.0 - April 27, 2021

### Breaking changes

- Deprecate `Conversation.members` Map (it will be populated only on a call scenario)
- Conversation events will be emitted with a subset information of the Member

```javascript
conversation.on("any:event", ({memberId, userId, userName, displayName, imageUrl, customData}, event) => {});
```

### Changes

- Add paginated `getMembers()` function to retrieve the members of a conversation

```javascript
conversation.getMembers().then((members_page) => {
  members_page.items.forEach(member => {
    render(member);
  })
}).catch((error) => {
  console.error("error getting the members ", error);
});
```

- Add `getMyMember()` function to retrieve our own member in a conversation

```javascript
conversation.getMyMember().then((member) => {
  render(member);
}).catch((error) => {
  console.error("error getting my member", error);
});
```

- Add `getMember()` function to fetch a conversation member by `member_id`

```javascript
conversation.getMember("MEM-id").then((member) => {
  render(member);
}).catch((error) => {
  console.error("error getting member", error);
});
```

## Version 7.1.0 - April 07, 2021

### Changes

- `rtcstats:report` is deprecated. Please use `rtcstats:analytics`instead

```ts
application.on('rtcstats:analytics', ({
  type: 'mos' || 'mos_report',
  mos: string,
  rtc_id: string,
  mos_report?: {
    average: string,
    last: string,
    max: string,
    min: string
  },
  report?: RTCStatsReport
}) => {}
```

- Add logs reporter for remote logging
- Add custom `getStats` parser
- Remove `callstats` library and implementation

## Version 7.0.2 - March 30, 2021

### Fixes

- Emit 'call:status:update' event when application offline and call disconnected

## Version 7.0.1 - February 04, 2021

### Fixes

- Remove unnecessary warning message for call status transitions

## Version 7.0.0 - February 02, 2021

### Breaking changes

- `legs` endpoint should be included in `acl` paths on `JWT` token creation

```json
"acl": {
  "paths": {
    ...
    "/*/legs/**": {}
  }
}
```

### Changes

- Improve `callServer` setup time by pre-warming leg
- Add the `rtcObject` and remote `stream` to the `NxmCall` object

### Fixes

- Return `ClientDisconnected` reason when client logouts from SDK

## Version 6.2.1 - December 24, 2020

### Fixes

- Revert back to 6.1.1 from 6.2.0-alpha

## Version 6.1.2 - December 24, 2020

### Fixes

- Update Typescript definitions

## Version 6.1.1 - December 09, 2020

### Fixes

- Update Typescript definitions

## Version 6.1.0 - December 01, 2020

### Changes

- Add `enableEventsQueue` flag to client configuration (default to true)
- Add internal `eventsQueue` mechanism to guarantee order of events received during a session

## Version 6.0.19 - November 26, 2020

### Changes

- Update `reconnectionDelay` to `2000` in `socket.io`
- Add `randomizationFactor` to `0.55` in `socket.io`

## Version 6.0.18 - November 19, 2020

### Changes

- Update documentation

### Fixes

- Add `reconnectionDelay` to 3000 and `reconnectionDelayMax` to 15000 in `socket.io`

## Version 6.0.17 - November 12, 2020

### Fixes

- Update Session id after reconnection

## Version 6.0.16 - October 12, 2020

### Fixes

- Dispatch `system:error:expired-token` event in application level

```javascript
  application.on('system:error:expired-token', 'NXM-errors', () => {
    console.log('Token Expired');
  });
```

- Handle uncaught exception of `conversation:error:invalid-member-state` event

## Version 6.0.15 - September 21, 2020

### Fixes

- Set SDK default to single preset ICE candidate
- Remove `iceGatherOnlyOneCandidate` flag from client configuration

## Version 6.0.13 - September 14, 2020

### Fixes

- Update websocket reconnection logic for token expiry

## Version 6.0.12 - September 01, 2020

### Fixes

- Update resolved stream on media enabling

## Version 6.0.11 - September 01, 2020

### Changes

- Update websocket reconnection logic
- Fix delay in establishing media connection with one ice candidate sent

## Version 6.0.10 - May 04, 2020

### Fixes

- Filter IPv6 Candidates from `iceGatherOnlyOneCandidate` SDP offer

## Version 6.0.9 - March 24, 2020

### Fixes

- Fix handler of `rtc:transfer` event to refresh conversation

## Version 6.0.8 - February 28, 2020

### Fixes

- Fix duplicated webrtc offer sent during IP calling
- Fix Safari `WebRTC` dependency

## Version 6.0.7 - January 16, 2020

### Fixes

- Fix ANSWERED call status in IP - IP calling
- Fix docs issues

### Changes

- Improve TypeScript definitions

## Version 6.0.6 - November 19, 2019

### Fixes

- Add `iceGatherOnlyOneCandidate` configuration option and use to define path in `ICE gathering` process

## Version 6.0.5 - November 19, 2019

### Fixes

- Update styling of `JSDocs` to `Docstrap` template
- Change `RTCPeerConnection ICE candidates` gathering process to send the Session Description Protocol (`SDP`) offer on first `ICE` candidate gathered

## Version 6.0.4 - November 14, 2019

### Fixes

- Remove remaining audio elements after transferring a call to a new conversation
- Update `conversation.invite()` to not include empty `user_id` or `user_name` fields within the requests

## Version 6.0.3 - October 22, 2019

### New

- Added TypeScript definition files

### Changes

- Added options for customized logging levels in the console of `debug`, `info`, `warn`, or `error`.

```javascript
new NexmoClient({
  debug: 'info'
})
```

- Moved storage of JWT token from `localStorage` to `NexmoClient` configuration object
- Removed unnecessary files from the NPM release package

### Fixes

- Fixed call statuses order in case of a transfer

## Version 6.0.1 - September 27, 2019

### Changes

- Removed `media.record()` function
- Removed cache option from SDK, used for storing conversations and events
- Removed automatic syncing of all individual `conversations` in login, when `sync` is `lite` or `full`

## Version 6.0.0 - September 13, 2019

### Breaking Changes

- Change return value of `application.getConversations()` to new `ConversationsPage` object

```javascript
// iterate through conversations
application
  .getConversations({ page_size: 20 })
  .then((conversations_page) => {
    conversations_page.items.forEach(conversation => {
      render(conversation);
    })
  });
```

- Change return value of `conversation.getEvents()` to new `EventsPage` object

```javascript
// iterate through events
conversation
  .getEvents({ event_type: `member:*` })
  .then((events_page) => {
    events_page.items.forEach(event => {
      render(event);
    })
  });
```

- Rename method `application.callPhone` to `application.callServer`
- Rename method `application.call` to `application.inAppCall`
- Rename method `call.createPhoneCall` to `call.createServerCall`
- Rename class `Call` to `NXMCall`
- Rename class `ConversationClient` to `NexmoClient`
- Rename class `ConversationClientError` to `NexmoClientError`
- Rename files `conversationClient.js` and `conversationClient.min.js` to `nexmoClient.js` and `nexmoClient.min.js`
- Deprecate `member:call:state` event (use instead `member:call:status`)
- Remove automatic login in case of a websocket reconnection and emit the event

### New

- Send and listen for custom event types in a conversation.

```javascript
//sending a custom event type to a conversation
conversation
  .sendCustomEvent({type: `my_custom_event`, body: { enabled: true }})
  .then((custom_event) => {
    console.log(event.body);
  });
```

```javascript
//listening for a custom event type
conversation.on(`my_custom_event`, (from, event) => {
  console.log(event.body);
});
```

- Add new `PageConfig` class for configuring settings for paginated requests
- Add new `Page` class to wrap results of paginated requests
- Add setup of default pagination configuration for conversations and events in ConversationClient initialization
- Add wild card supported for filtering by event types using `:*` (for example `event_type`: `member:*`)

```javascript
new NexmoClient({
  conversations_page_config: {
    page_size: 25,
    order: 'asc'
    cursor: 'abc'
  },
  events_page_config: {
    page_size: 50,
    event_type: `member:*`
  }
})
```

- Add new `ConversationsPage` and `EventsPage` which extend `Page` class to wrap results of paginated requests for conversations and events
- Add `getNext()` and `getPrev()` methods to `ConversationsPage` and `EventsPage` objects to fetch previous and next pages of conversations and events
- Add `conversations_page_last` parameter to `application` object and `events_page_last` parameter to `conversation` object for reference to last page retrieved

```javascript
application.conversations_page_last
  .getNext((conversations_page) => {
    conversations_page.items.forEach(conversation => {
      render(conversation)
    })
  })
```

```javascript
conversation.events_page_last
  .getPrev((events_page) => {
    events_page.items.forEach(event => {
      render(event)
    })
  })
```

- Add the ability to make an IP-IP call through `callServer` function

```javascript
// IP-IP call scenario
application
  .callServer('username', 'app')
  .then((nxmCall) => {
    // console.log(nxmCall);
  });

// IP-PSTN call scenario
application
  .callServer('07400000000')
  .then((nxmCall) => {
    // console.log(nxmCall);
  });
```

### Changes

- Update `reason` object to receive `reason.reason_text` and `reason.reason_code` fields

### Internal changes

- Rename `Event` class to `NXMEvent`
- Update CAPI requests to REST calls for these events
  - `event:delivered`
  - `text:delivered`
  - `image:delivered`
  - `event:seen`
  - `text:seen`
  - `image:seen`
  - `conversation:events`
  - `audio:play`
  - `conversation:delete`
  - `conversation:invite`
  - `text`
  - `text:typing:on`
  - `text:typing:off`
  - `new:conversation`
  - `conversation:get`
  - `user:conversations`
  - `user:get`
  - `conversation:join`
  - `audio:say`
  - `audio:earmuff:on`
  - `audio:earmuff:off`
  - `audio:dtmf`
  - `audio:record`
  - `audio:play`
  - `conversation:member:delete`
  - `event:delete`
  - `audio:ringing:start`
  - `audio:ringing:stop`
  - `audio:mute:on`
  - `audio:mute:off`
  - `image`
  - `rtc:new`
  - `rtc:answer`
  - `rtc:terminate`
  - `knocking:new`
  - `knocking:delete`

## Version 5.3.4 - July 18, 2019

### Fixes

- Custom SDK config object does a deep merge with default config object

## Version 5.3.3 - June 29, 2019

### Fixes

- Change digits to digit in the `sendDTMF()` request method payload.
- Stream is not being terminated on a call transfer.
- `member:call` is not being emitted if `media.audio_settings.enabled` is false or doesn't exist.

### New

- Set `member.callStatus` to `started` when initializing an IP - IP call.
- Set `member.callStatus` to `ringing` when enabling the ringing with `media.startRinging()`.

### Internal changes

- Move stream cleanup from `member:left` to `rtc:hangup` in Media module.

## Version 5.2.1 - June 12, 2019

### New

- Add the new `nexmoGetRequest` utility method to make a GET network request directly to CS:

``` javascript
/**
 * Perform a GET network request directly to CS
 *
 * @param {string} url the request url to CS
 * @param {string} data_type the type of data expected back from the request (events, conversations, users)
 * @param {object} [params] network request params
 * @param {string} [params.cursor] cursor parameter to access the next or previous page of a data set
 * @param {number} [params.page_size] the number of resources returned in a single request list
 * @param {string} [params.order] 'asc' or 'desc' ordering of resources (usually based on creation time)
 * @param {string} [params.event_type] the type of event used to filter event requests ('member:joined', 'audio:dtmf', etc)
 *
 * @returns {Promise<XMLHttpRequest.response>} the XMLHttpRequest.response
 * @static
 * @example <caption>Sending a nexmo GET request</caption>
 */
  nexmoGetRequest(url, data_type, params).then((response) => {
    response.body: {},
    response.cursor: {
        prev: '',
        next: '',
        self: ''
    },
    response.page_size: 10
 });
```

- Support `reason` for `member:delete`, `conversation.leave`, `member.kick`, `call.hangup` and `call.reject`.
- Listen for the `member:left` event with `reason`:

``` javascript
//listening for member:left with reason
conversation.on('member:left', (member, event) => {
  console.log(event.body.reason);
});

/**
* Reason object format
*
* @param {object} [reason] the reason for kicking out a member
* @param {string} [reason.code] the code of the reason
* @param {string} [reason.text] the description of the reason
*/
```

- Add `callStatus` field in the `Member` object, defining the status of a call.
- Emit `member:call:status` event each time the `member.callStatus` changes:

``` javascript
conversation.on("member:call:status", (member) => {
   console.log(member.callStatus);
});
```

## Version 5.2.0 - May 30, 2019

### New

- Add the `call` instance in `application.calls` map in `createCall()` function (IP -IP call)

- Update caller parameter in call object in a PSTN - IP call from `unknown` to `channel.from.number` or `channel.from.uri` if exists

- Emit the new `leg:status:update` event each time a member leg status change

```javascript
/**
  * Conversation listening for leg:status:update events.
  *
  * @event Conversation#leg:status:update
  *
  * @property {Member} member - the member whose leg status changed
  * @property {Event} event - leg:status:update event
  * @param {string} event.cid - the conversation id
  * @param {string} event.body.leg_id - the conversation leg id
  * @param {string} event.body.type - the conversation leg type (phone or app)
  * @param {string} event.body.status - the conversation member leg status
  * @param {Array} event.body.statusHistory - array of previous leg statuses
*/
conversation.on("leg:status:update", (member, event) {
  console.log(member, event);
});
```

- Add the the `channel.legs` field in member events offered by CS

```text
conversation.on(<member_event>, (member, event) {
  console.log(event);
  // member_id: <member_id>,
  // conversation_id: <conversation_id>,
  // ...
  // channel: {
  //  to: {
  //    type: app
  //  },
  //  type: app,
  //  leg_ids: [<leg_id>]
  //  legs : [{ leg_id: <leg_id>, status: <leg_status>}],
  //  leg_settings: {},
  // },
  // state: <state>,
  // leg_ids: []
});
```

---

## Version 5.1.0 - May 29, 2019

### New

- Send DTMF event to a conversation

 ```text
  * Send DTMF in a conversation
  *
  * @param {string} digits - the DTMF digit(s) to send
  * @returns {Promise<Event>}
 ```

```javascript
 conversation.media.sendDTMF('digits')
```

- Emit new event `audio:dtmf`

```javascript
conversation.on("audio:dtmf",(from, event)=>{
  event.digit // the dtmf digit(s) received
  event.from //id of the user who sent the dtmf
  event.timestamp //timestamp of the event
  event.cid // conversation id the event was sent to
  event.body // additional context about the dtmf
});
```

- Set customized audio constraints for IP calls when enabling audio

```javascript
 conversation.media.enable({
    'audioConstraints': audioConstraints
 })
```

```text
  * Replaces the stream's audio tracks currently being used as the sender's sources with a new one with new audio constraints
  * @param {object} constraints - audio constraints
  * @returns {Promise<MediaStream>} - Returns the new stream with the updated audio constraints.
  * @example
  * conversation.media.updateAudioConstraints({'autoGainControl': true})
  **/
```

- Update audio constraints for existing audio tracks

```javascript
  conversation.media.updateAudioConstraints(audioConstraints)
 })
```

### Fixes

- Remove 'this' passed to cache worker event handler

### Internal breaking changes

- Change the media audio parameter from `media.audio` to `media.audio_settings` in `inviteWithAudio` function

---

## Version 5.0.3 - May 23, 2019

### Changes

- Change default behavior of `autoPlayAudio` in `media.enable()` from false to true
- Pass an `autoPlayAudio` parameter to `call.createCall()` and `call.answer()` functions (default is true)

---

## Version 5.0.2 - May 30, 2019

### New

- Delete the image files before sending the `image:delete` request
- Attach of audio stream can now be chosen if it will be automatically on or off through `media.enable()`

```javascript
media.enable({
  autoPlayAudio: true | false
})
```

### Changes (internally)

- Combine the network GET, POST and DELETE requests in one generic function

---

## Version 5.0.1 - April 30, 2019

### Fixes

- Clean up user's media before leaving from an ongoing conversation

### Breaking changes

- Change `application.conversations` type from `Object` to `Map`

---

## Version 4.1.0 - April 26, 2019

### Fixes

- Fixed the bug where the audio stream resolved in media.enable() is causing echo and was not the remote stream
- Resolve the remote stream `pc.ontrack()` and not the `localStream` from getUserMedia

### Changes

- Rename `localStream` to `stream` in `media.rtcObjects` object.

---

## Version 4.0.2 - April 17, 2019

### Changes

- Removed `media.rtcNewPromises`

### New

- Internal lib dependencies update
- Added support for Bugsnag error monitoring and reporting tool

```text
 * @class ConversationClient
 *
 * @param {object} param.log_reporter configure log reports for bugsnag tool
 * @param {Boolean} param.log_reporter.enabled=false
 * @param {string} param.log_reporter.bugsnag_key your bugsnag api key / defaults to Vonage api key
 ```

- Updated vscode settings to add empty line (if none) at end of every file upon save
- Disable the ice candidates trickling in ice connection
- Wait until most of the candidates to be gathered both for the local and remote side
- Added new private function `editSDPOrder(offer, answer)` in `rtc_helper.js` to reorder the answer SDP when it's needed
- For rtc connection fail state
  - Disable leg
  - emit new event `media:connection:fail`

```javascript
member.on("media:connection:fail",(connection_details)=>{
  connection_details.rtc_id // my member's call id / leg id
  connection_details.remote_member_id // the id of the Member the stream belongs to
  connection_details.connection_event: // the connection fail event
  connection_details.type // the type of the connection (video or screenshare)
  connection_details.streamIndex // the streamIndex of the specific stream
});
```

```text
* @event Member#media:connection:fail
*
* @property {number} payload.rtc_id the rtc_id / leg_id
* @property {string} payload.remote_member_id the id of the Member the stream belongs to
* @property {event} payload.connection_event the connection fail event
 ```

- Add new LICENCE file

### Breaking changes (internally)

- Deprecating ice trickling logic with `onicecandidate` event handler
- Change the format of `member:media` event to the new one offered by CS

```text
type: 'member:media',
  from: member.member_id,
  conversation_id: member.conversation_id,
  body: {
    media: member.media,
    channel: member.channel
  }
```

- Change the format of `member:invited` event to the new offered by CS

```text
type: 'member:invited',
  body: {
    media: {
      audio_settings: {
        enabled: false,
        earmuffed: false,
        muted: false
      }
    }
  }
```

---

## Version 4.0.1 - March 4, 2019

### New

- Select the sync level for the login process
  - `full`: trigger full sync to include conversations and events
  - `lite`: trigger partial sync, only conversation objects (empty of events)
  - `none`: don't sync anything

  if the Cache module is enabled the manual fetch of a conversation will store them in internal storage

  usage:

  ```javascript
  new ConverationClient({'sync':'full'});
  ```

### Fixes

- `rtcstats:report` was duplicating instances in each call
- remove `screenshare` https restriction

### Breaking changes (internally)

- Deprecating `application.activeStream`, now it's part of `application.activeStreams`
- Removed the restriction to allow calling `media.enable()` while a stream is active

---

## Version 4.0.0 - February 1, 2019

### Breaking Changes

- rename SDK `stitch` to `client`
- listening for `media:stream:*` now gives `streamIndex` instead of `index` for consistency with the internal rtcObjects

```text
 * @event Member#media:stream:on
 *
 * @property {number} payload.streamIndex the index number of this stream
 * @property {number} [payload.rtc_id] the rtc_id / leg_id
 * @property {string} [payload.remote_member_id] the id of the Member the stream belongs to
 * @property {string} [payload.name] the stream's display name
 * @property {MediaStream} payload.stream the stream that is activated
 * @property {boolean} [payload.video_mute] if the video is hidden
 * @property {boolean} [payload.audio_mute] if the audio is muted
 ```

### New

- Screen Share Source ID can now be specified when invoking `media.enable()`
