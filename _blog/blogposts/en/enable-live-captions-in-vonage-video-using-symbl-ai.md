---
title: Enable Live Captions in Vonage Video Using Symbl.ai
description: Add transcription and closed captioning to your Vonage Video
  application using Symbl.ai
thumbnail: /content/blog/enable-live-captions-in-vonage-video-using-symbl-ai/live-captions_video-api-1.png
author: javier-molina-sanz
published: true
published_at: 2021-12-16T11:11:05.140Z
updated_at: 2021-12-13T16:50:48.032Z
category: tutorial
tags:
  - video-api
  - react
  - symblai
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In this blog post, I’d like to show you how you can add transcription/closed captioning to your Vonage Video application. We are going to leverage [Symbl.ai web SDK](https://www.npmjs.com/package/@symblai/symbl-web-sdk) to achieve this. Audio will be sent from the client-side to Symbl.ai, hence there are no changes required on the server-side.  [Symbl.ai](https://symbl.ai) allows you to easily add conversational intelligence into your voice and video applications with their suite of APIs and developer tools.

## Why Do You Need Captions?

Accessibility was one of the main requirements when communications moved online during the pandemic. Do you have customers with different accents you sometimes struggle to understand? Do you want to see what your users are concerned about, what they want, what they struggle with? Or are you simply looking to store transcriptions of a call so that you can later perform some analysis on it? We’ve got you covered. Stick around. If you prefer to watch a [video of the finished application](https://www.youtube.com/watch?v=TFoLBRNCt2k), feel free to check it out.

In this blog post, I am going to show you how to add closed captioning in a one-to-one call. Check out the [GitHub repository](https://github.com/nexmo-se/symblAI-demo) for the complete source code, which shows examples of sentiment analysis graphs. It also provides you with insights and a summary of your call, in addition to closed captions. 

I’m going to be building with ReactJS, but you can use vanilla JS or any framework/library of your choice.

## Requirements

In order to run this sample app, you’re going to need a few things: 
- I will assume that you know the basics of ReactJS.
- You have a Vonage Video API account. If not, you can [sign up for free here](https://id.tokbox.com/login?).
- A SymblAI account. If you don’t have one, you can [sign up for free here](https://symbl.ai/).

## Architecture

The following diagram shows what we’re going to build today. For the sake of simplicity, this blog post is going to cover the integration with Symbl.ai on the client-side. For a more in-depth explanation of the app architecture you can check the [Readme file of the application](https://github.com/nexmo-se/symblAI-demo/blob/main/README.md).

The Vonage Client SDK drives our video application. As you can see in the following diagram, the Client SDK will communicate with the Symbl.ai SDK by opening a bidirectional connection through a WebSocket. The audio from the participants will be fed to the Symbl.ai SDK and we will receive the transcript of the audio.

In order to authenticate the Vonage session and the Symbl.ai connection on the client-side we have created an [API in our Node.js server](https://github.com/nexmo-se/symblAI-demo/blob/main/server/index.js) to generate credentials. This API will rely on the Vonage Node.js SDK and Symbl.ai API.

![Diagram of Vonage Video application connecting to Symbl.ai](/content/blog/enable-live-captions-in-vonage-video-using-symbl-ai/blogpost.png)

## Creating Usernames

For a one-to-one call, the Symbl.ai SDK is going to open a connection with Symbl.ai infrastructure where two users will send audio. Once we receive the output of the transcription, we need to know which user the captions belong to. That is why our app will have the concept of users with usernames. 
This way, when we create the [`connectionConfig` in the `useSymblai` hook](https://github.com/nexmo-se/symblAI-demo/blob/main/src/hooks/useSymblai.js#L90), we can inform Symbl.ai who is speaking and when. The output from Symbl.ai includes the name of the speaker along with the transcript, so we can know who the transcript belongs to at all times.

To start with, I have created a [preferences context](https://github.com/nexmo-se/symblAI-demo/blob/main/src/context/PreferencesContext.js) to be able to access the username and `conversationId` anywhere in our application. The `conversationId` is a unique identifier for a given conversation that takes place within the Symbl.ai infrastructure. It may have one or more users. It is not necessary to enable captioning, but we will use the `conversationId` to make API calls to Symbl.ai to retrieve information about sentiment analysis and a conversation summary. We will cover these topics in the [Bonus section](#heading=h.4py6qegpvs6t).

```
import { createContext } from 'react';
 
export const PreferencesContext = createContext();
 
```

```
const [preferences, setPreferences] = useState({
   userName: null,
   conversationId: null,
 });
 
 const preferencesValue = useMemo(
   () => ({ preferences, setPreferences }),
   [preferences, setPreferences]
 );
```

Now, we only need to wrap our app with the `ContextProvider` so that we can access the preferences anywhere in our app.

```
     <Router>
       <PreferencesContext.Provider value={preferencesValue}>
         <Switch>
    <ProtectedRoute exact path="/room/:roomName" component={Wrapper} />
           <Route path="/room/:roomName/:conversationId/end">
             <EndCall />
           </Route>
           <Route path="/">
             <WaitingRoom />
           </Route>
         </Switch>
       </PreferencesContext.Provider>
     </Router>
```

As you can see in the [structure of our app](https://github.com/nexmo-se/symblAI-demo/blob/main/src/App.js), by default the user will be redirected to the `WaitingRoom` component. There, we will ask the user to type their username and a room name. You can see the [implementation of the waiting room here](https://github.com/nexmo-se/symblAI-demo/tree/main/src/components/WaitingRoom). The `Protected` route is a component that will check whether the user has set up a username, and will redirect the user to the waiting room if not. You can see [the implementation of this route here](https://github.com/nexmo-se/symblAI-demo/tree/main/src/components/ProtectedRoute).  This is to prevent a user from joining a room without having chosen a name. 
If the user has set up a username already, we will redirect the user to the `Wrapper` component, which contains a `Header` and the main component. If you’re curious, you can [have a look at this component here](https://github.com/nexmo-se/symblAI-demo/tree/main/src/components/Wrapper).

This is what the Waiting Room looks like:

![Waiting Room UI requesting username and room name](/content/blog/enable-live-captions-in-vonage-video-using-symbl-ai/screenshot-2021-12-13-at-16.58.37.png)

## UseSymblai Hook

We are going to make use of the Symbl.ai web SDK to abstract away the complexity of opening a WebSocket connection and piping the audio. In a React application, it is a good practice to write a [custom React hook](https://reactjs.org/docs/hooks-custom.html) to make our app more reusable and the code cleaner. You can see [the whole implementation of the custom hook here](https://github.com/nexmo-se/symblAI-demo/blob/main/src/hooks/useSymblai.js), but I’m going to explain every step in detail.

Let’s install and import the SDK: 

`npm i @symblai/symbl-web-sdk`

`import symbl from '@symblai/symbl-web-sdk';`

We are going to create a custom hook that will accept the publisher from the Vonage Video session, as well as a boolean flag that indicates if the publisher has started sending media. The custom hook will return our captions, the other party’s captions, and the name of the speaker.

```export
 
//CODE WILL GO HERE
 
return {
   captions,
   myCaptions,
   name,
 };
 
}
```

```
 let streamRef = useRef(null);
 const { preferences } = useContext(PreferencesContext);
 const [captions, setCaptions] = useState('');
 const [myCaptions, setMyCaptions] = useState('');
 const [name, setName] = useState(null);
 const [symblToken, setSymblToken] = useState(null);
 let { roomName } = useParams();
```

We are creating a few state variables to store our own captions, the other party’s captions, the name of the person speaking, and the token. We will also create a ref to the `streamObject` returned by Symbl.ai once we establish a connection with them. We will consume the context that we have previously created.

We’re going to create a `useEffect` hook that will only run on the first render. The goal of this hook is to get the credentials for the video session and a token for the Symbl.ai connection. [The `getToken` and `getSymblToken` functions are implemented here](https://github.com/nexmo-se/symblAI-demo/blob/main/src/api/fetchCreds.js). They will communicate with an [API on our server side](https://github.com/nexmo-se/symblAI-demo/blob/main/server/index.js#L55) that will handle the credentials generation. We will get the `roomName` from the URL parameters.

```
 useEffect(() => {
   getToken()
     .then((response) => {
       setSymblToken(response.data.accessToken);
       symbl.init({
         accessToken: response.data.accessToken, 
       });
     })
     .catch((e) => console.log(e));
 }, []);
```

 We will go ahead and define another `useEffect` hook that will run once we have published to the session and start the connection with Symbl.ai. We will get a `mediaStreamTrack` from the publisher once we’re publishing to the session. We will then leverage the [Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API) to [create a MediaStreamSource](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/createMediaStreamSource) that will be used as source in the `connectionConfig` for Symbl.ai. 

 If you don’t want to get the `mediaStream` from the Vonage publisher, and just get the audio from the microphone, you can do so by not specifying any source in the `connectionConfig`. By default, the Symbl.ai Web SDK will handle audio context and source nodes on its own.

In our application, for the sake of simplicity, we’re assigning `id` the value of `roomName`, which is a unique identifier used by the clients to connect to the conversation and push audio to Symbl.ai. In a real world application, you need to ensure that this `id` is unique and it’s not reused again after the conversation finishes.

You can see that there’s a `userId` string in the `speaker` object of the `connectionConfig`. If you set up a valid email address there, you will receive an email with some insights from the conversation. If you leave it blank, it won’t send you an email. However, we want to set up the speaker name so that we know whose speech it is when we receive the output from Symbl.ai. As you can see, we’re listening to the `onSpeechDetected` callback:

```
useEffect(() => {
   if (isPublishing && publisher) {
     const audioTrack = publisher.getAudioSource();
     const stream = new MediaStream();
     stream.addTrack(audioTrack);
     const AudioContext = window.AudioContext;
     const context = new AudioContext();
     const source = context.createMediaStreamSource(stream);
     const id = roomName;
 
     const connectionConfig = {
       id,
       insightTypes: ['action_item', 'question'],
       source: source,
       config: {
         meetingTitle: 'My Test Meeting ' + id,
         confidenceThreshold: 0.5, // Offset in minutes from UTC
         encoding: 'LINEAR16',
         languageCode: 'en-US',
       speaker: {
         // Optional, if not specified, will simply not send an email in the end.
         userId: '', // Update with valid email
         name: preferences.userName || uuidv4(),
       },
       handlers: {
         /**
          * This will return live speech-to-text transcription of the call.
          */
         onSpeechDetected: (data) => {
           if (data) {
             if (data.user.name !== preferences.userName) {
               setCaptions(data.punctuated.transcript);
               setName(data.user.name);
             } else {
               setMyCaptions(data.punctuated.transcript);
             }
           }
         },
        
       },
     };
 
     const start = async () => {
       try {
         const stream = await symbl.createStream(connectionConfig);
         streamRef.current = stream;
         await stream.start();
         conversationId.current = await stream.conversationId;
         preferences.conversationId = conversationId.current;
       } catch (e) {
         console.log(e);
       }
     };
     start();
   }
 }, [
   isPublishing,
   roomName,
   preferences,
   publisher,
 ]);
```

We have defined an asynchronous function at the end of our hook that will be called in order to create a connection with Symbl.ai. This is needed because the WebSocket is started in a non-processing state, so we need to instruct Symbl.ai when we want to start the connection.

At this point, we can use our custom hook in the component of our choice. In this application, it will be used in the [Main component](https://github.com/nexmo-se/symblAI-demo/tree/main/src/components/Main). We first need to import it:

```
import { useSymblai } from '../../hooks/useSymblai';
```

And then we can destructure the data by calling the custom hook, passing it the publisher and the `isPublishing` boolean variable:

```
const { captions, name, myCaptions} =
   useSymblai({
     publisher,
     isPublishing,
   });
```

At this point, you can just display the captions in your UI or carry out any logic that you want to. You can have a look at the [implementation of the main video component here](https://github.com/nexmo-se/symblAI-demo/blob/main/src/components/Main/index.js). To recap, `captions` are the other party’s captions, `myCaptions` are your own captions, and `name` is just the name of the other person.

## Bonus

Symbl.ai not only provides you with captioning features, but also sentiment analysis, insights extraction, summary of the call, analytics, and much more. I’ve built a [more complete sample application showcasing these features](https://github.com/nexmo-se/symblAI-demo).

You can find more information about the features the app contains in the API reference:

- [Sentiment Analysis API](https://docs.symbl.ai/docs/concepts/sentiment-analysis)
- [Summary API](https://docs.symbl.ai/docs/concepts/summarization)
- [Action items and questions](https://docs.symbl.ai/docs/concepts/action-items)

The following video shows you what the application looks like. There are two users in the call, Javier and Binoy. As you can see at the top left, there is a graph that shows you the sentiment analysis score for the other party’s speech (ranging from -1 to 1, with 1 being very positive and -1 being very negative). In this case, we can see that Binoy was quite positive as I was talking to him about the cool features Symbl.ai offers.

<youtube id="TFoLBRNCt2k"></youtube>

On the bottom left, you can see some `action_items` that are picked up by the Symbl.ai API. It contains the name of the assignee when available. So in this case, we can see some questions, such as Binoy asking Javier if Symbl.ai was easy to integrate with our Video APIs, and an action item which is Binoy needing to “check them out” (referring to Symbl.ai).

When you click on “finish the call”, the app will redirect you to the analytics page where you can see individual speaker breakdown metrics (talking and silence time) and metrics for the overall meeting. In this case, we can see the statistics for Javier and Binoy. Another very cool feature Symbl.ai provides is the ability to summarise the call using natural language processing. This provides you a few sentences with a brief of the call. This way, you can get an idea about what the call was about by reading some highlights.

This is very helpful, as it can help to avoid long follow-up emails with a recap and action items after a call. Recognizing brand names is always challenging, but we can see how, in this case, Javier has already done an integration with an AI company that allows you to enable live captioning, sentiment analysis, and more. 
Bear in mind that this was a very short meeting, but the longer the meeting is, the more accurate the summary will be.

## What Next?

Hopefully, you now know how you can enable live captioning in your Vonage Video application and gain further insights into your video calls. The completed project is available on GitHub, 

[Let us know on Twitter](https://twitter.com/VonageDev) what projects you build using the Vonage Video API!

Also, [make sure to join our community on Slack](https://app.slack.com/client/T24SLSN21/C24QZH6E7).