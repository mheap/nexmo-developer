---
title: Implement a Video API Application With React Hooks
description: How to use React Hooks to implement the Vonage Video API into your application.
thumbnail: /content/blog/implement-a-video-api-application-with-react-hooks/videoapi_reacthook.png
author: enrico-portolan
published: true
published_at: 2022-04-13T08:03:30.499Z
updated_at: 2022-04-13T08:03:32.947Z
category: tutorial
tags:
  - video-api
  - javascript
  - react
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
If you have been a ReactJS developer for a couple of years, you probably had to refactor your code to use React Hooks. React Hooks has been introduced since the 16.8 version (February 2019, [documentation](https://reactjs.org/docs/hooks-intro.html)) and lets you use state and other React features without writing a class.

This blog post will explain how to integrate Vonage Video API JS into your React application using Hooks.

## Prerequisites

1. A Vonage Video API account. If you don't have one already, you can create an account in the [Video Dashboard](https://tokbox.com/account/#/)
2. ReactJS version >= 16.8

The entry point of the project is the `src/index.js` file. The index file imports the App file which contains the Routes and Component definition.

### Pages

The routes are defined in the App.js file. The code uses the `react-router-dom` module to declare the routes. There are two main routes:

- **Waiting room**: on this page, the user can set their microphone and camera settings, as well as run a pre-call [Opentok Network Test](https://github.com/opentok/opentok-network-test-js). Then, they can join the video call.
- **VideoRoom**: on this page, the user connects to the session, publishes their stream, and subscribes to each of the streams inside the room.

Please notice that the user can **directly** navigate to the VideoRoom page. There is no authentication implemented in the sample code.

#### Waiting Room

The waiting room page creates a publisher (using **UsePublisher** Hook) to display the video feed. Using the AudioSettings and VideoSettings components, the user can mute and unmute the microphone and camera.

It's also possible to set the username using the query parameter, `user-name`, in the URL of the page. So if the user navigates to `waiting-room?user-name=JohnDoe`, the waiting room page will set the username to `John Doe`.

Lastly, there is a React effect that runs the network test when the page is loaded. The network test is handled by a custom Hook, `useNetworkTest`. The network test runs two different tests: **testConnectivity** and **testQuality**. If the user joins the call before the tests have been completed, the `useNetworkTest` Hook will abort them.

For more information please check the [Network Test GitHub repo](https://github.com/opentok/opentok-network-test-js)

#### Video Room

The video room components use the `useSession` and `usePublisher` Hooks to handle the Video API’s logic. The `useEffect` Hook at component mount gets the credentials to connect to the room (**getCredentials** function). Once the credentials are set by the Hook, another effect is fired which will create a new session, calling `OT.initSession` and `session.connect` sequentially.

After the session creation, the next effect will trigger the publish function from the `usePublisher` Hook.

In addition, the video room includes the `Chat` component which uses the [Video API Signal](https://tokbox.com/developer/sdks/js/reference/SignalEvent.html) to send and receive messages.

Lastly, the `ControlToolBar` components include the buttons used during the video call: mute/unmute microphone and camera, screen-sharing, and chat.

### React Context

The only context used in this App is the `UserContext` which stores the username, localAudio, and localVideo preferences.

### React Hooks

The Hooks used by the app are in the hooks directory:

#### useSession

The `src/hooks/useSession.js` Hook handles the Session object of the Video API library. The main functions are:

- **createSession**: given the credentials, the function connects to the Vonage Video servers and adds the event listeners (`onStreamCreated` and `onStreamDestroyed`).
- **destroySession**: disconnects the current session.
- **subscribe**: given a stream and subscriber options, it subscribes to the stream.

```javascript
const createSession = useCallback(
    ({ apikey, sessionId, token }) => {
      if (!apikey) {
        throw new Error("Missing apiKey");
      }

      if (!sessionId) {
        throw new Error("Missing sessionId");
      }

      if (!token) {
        throw new Error("Missing token");
      }

      sessionRef.current = OT.initSession(apikey, sessionId);
      const eventHandlers = {
        streamCreated: onStreamCreated,
        streamDestroyed: onStreamDestroyed,
      };
      sessionRef.current.on(eventHandlers);
      return new Promise((resolve, reject) => {
        sessionRef.current.connect(token, (err) => {
          if (!sessionRef.current) {
            // Either this session has been disconnected or OTSession
            // has been unmounted so don't invoke any callbacks
            return;
          }
          if (err) {
            reject(err);
          } else if (!err) {
            console.log("Session Connected!");
            setConnected(true);
            resolve(sessionRef.current);
          }
        });
      });
    },
    [onStreamCreated, onStreamDestroyed]
  );
```

#### onAudioLevel

In the useSession Hook, there is the `onAudioLevel` function which listens to the [audioLevelUpdated](https://tokbox.com/developer/sdks/js/reference/AudioLevelUpdatedEvent.html) event. The function checks if there is an audio level greater than 0.2 for more than a given threshold (speakingThreshold).

If so, it assumes that the subscriber is speaking and adds a class to the element.

If there is an audio level lower than 0.2 for a given threshold (notSpeakingThreshold), it means the subscriber is not speaking.

#### usePublisher

The `src/hooks/usePublisher.js` file defines the Publisher object.
The main functions are:

- `initPublisher`: requests access to the mic and camera in addition to  initializing the publisher object. This function creates the local publisher in the page.
- `publish`: publishes the stream into the session.
- `unpublish`: unpublishes the local stream from the Session and stops the mediaTracks (microphone and camera).

```javascript
const initPublisher = useCallback(
    (containerId, publisherOptions) => {
      console.log('UsePublisher - initPublisher');
      if (publisherRef.current) {
        console.log('UsePublisher - Already initiated');
        return;
      }
      if (!containerId) {
        console.log('UsePublisher - Container not available');
      }
      const finalPublisherOptions = Object.assign({}, publisherOptions, {
        insertMode: 'append',
        width: '100%',
        height: '100%',
        style: {
          buttonDisplayMode: 'off',
          nameDisplayMode: 'on'
        },
        showControls: false
      });
      publisherRef.current = OT.initPublisher(
        containerId,
        finalPublisherOptions,
        (err) => {
          if (err) {
            console.log('[usePublisher]', err);
            publisherRef.current = null;
          }
          console.log('Publisher Created');
        }
      );
      publisherRef.current.on('accessAllowed', accessAllowedListener);
      publisherRef.current.on('accessDenied', accessDeniedListener);
      publisherRef.current.on('streamCreated', streamCreatedListener);
      publisherRef.current.on('streamDestroyed', streamDestroyedListener);
      publisherRef.current.on(
        'videoElementCreated',
        videoElementCreatedListener
      );
    },
    [
      streamCreatedListener,
      streamDestroyedListener,
      accessAllowedListener,
      accessDeniedListener
    ]
  );
```

#### useNetworkTest

The `src/hooks/useNetworkTest.js` Hook handles the `opentok-network-js` module. The main functions are:

- `initNetworkTest`: initiates the `NetworkTest` object
- `runNetworkTest`: runs the `testConnectivity` and `testQuality` functions, then sets the state’s variables according to the result
- `stopNetworkTest`: stop the current network test.

#### useChat

The `src/hooks/useChat.js` Hook handles the Vonage Video API signal functionality.
The main functions are:

- `sendMessages`: send a signal of type `type:message`
- `messageListener`: listener for the `type:message` event. The listener will add the message to the `messages` array.




## Conclusion

In this blog post, I explained how to integrate React Hooks with Vonage Video API. The repository is publicly available at [Video API Hooks](​​https://github.com/Vonage-Community/video-express-react-app). You can use it as a reference for integrating or refactoring your application using React Hooks.

Also, Vonage has recently released a new product called Vonage Video Express to create a multiparty video conference web application. We have written a [blog post](https://developer.vonage.com/blog/2021/09/27/create-a-multiparty-video-app-with-the-new-video-express/) about it.
