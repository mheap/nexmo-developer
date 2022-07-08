---
title: Experience Spatial Audio with Vonage Video API
description: This tutorial will teach you to enable spatial audio (3D Audio)
  with the Vonage Video API using Javascript in the browser.
thumbnail: /content/blog/experience-spatial-audio-with-vonage-video/spatial-audio_video-api-1.png
author: binoy-chemmagate
published: true
published_at: 2021-11-17T10:05:57.771Z
updated_at: 2021-11-16T09:19:20.899Z
category: tutorial
tags:
  - javascript
  - video-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introduction

The way we consume audio on our mobile, desktop, and other devices is changing, and the pandemic has definitely influenced our consumption model. One buzzword that is lingering around audio is “spatial audio”. This article will show you how to build a spatial audio experience using Vonage Video APIs and Resonance SDK on Web Browsers. 

Curious how the spatial audio experience would be? Check our sample demo below and please use a headset to watch the video. 

<youtube id="udfty61Jobk"></youtube>

## A Bit of Audio History

Before we talk about Spatial audio/3D audio, let’s talk about audio channels and how they are different. 

### Mono

Mono (means one) audio is single channel audio where the audio played in your right earbud is the same audio played in your left earbud. Every sound is evenly dispersed in both earbuds. 

### Stereo

Stereo audio is two-channel audio where you can hear different sounds played in the right earbud and left earbud. You can distinguish a guitar sound being played on the right and footsteps sounds on the left. 

### Surround Sound

There has been proprietary work done on how the audio is mixed and played back. Mono and/or stereo audio is mixed for the number of speakers and subwoofers in the audio setup (5.1, 7.1, etc. which is equal to 5 speakers and 1 subwoofer or 7 speakers and 1 subwoofer) and played back through all the speakers and subwoofers to create a surround sound feeling. 

### Binaural

This is an improved version of stereo where the recording requires two omnidirectional microphones. When this audio is played back, you hear the sounds as if you are physically present in the location. 

### Spatial Audio

Spatial audio lets you position the audio anywhere in a 3D space. This means you can not just distinguish sound sources between left and right but above, below, front and rear as well. Spatial audio tricks the human brain by delaying the time audio reaches our left and right ears and using higher and lower frequencies. The growth in VR space has fueled the popularity of spatial audio. 

## Should You Care About Spatial Audio?

**Video Conferencing Fatigue** - The audio in video conferencing produces an unnatural listening experience as all the audio comes from the same speaker and distance. This synthetic soundscape is different from a real-life listening experience where the sound is positional, directional, and spherical. Spatial audio can recreate a real-life listening experience by positioning the audio in a 3D space.

**AR and VR Spaces -** Spatial audio produces an immersive experience in AR/VR spaces. Audio plays a key role in AR/VR space as much as visuals and actions.

**Building Social Apps** - Audio/Video live-streaming apps have introduced spatial audio to make conversations more engaging and interactive.

# Spatial Audio Experience Using Vonage Video APIs and Resonance SDK

Our rockstar Customer Solution Engineer Rajkiran Talusani has created a "HOW TO" guide on building spatial audio experience using Vonage Video SDK and Resonance SDK. Please follow the instructions below.

## Requirements

* [Vonage Video SDK](https://tokbox.com/developer/sdks/js/)
* [Resonance SDK](https://resonance-audio.github.io/resonance-audio/)

## Do I Need Any Special Hardware?

No, you just need a stereo headset/earphones or a compatible device for rendering the audio. You do not need a special microphone for this particular example.

## Initial Setup

Resonance audio allows us to place the listener at a specified position in 3D space identified by the x,y, and z coordinates. You can then place any number of audio sources at different positions and Resonance audio would mix the audio streams to sound like you are in a physical space.

![Spatial Audio - Virtual Room Example](/content/blog/experience-spatial-audio-with-vonage-video/image1.png "Spatial Audio - Virtual Room Example")

The first step is to create an AudioContext and a Gain node to control
Resonance audio volume

```javascript
  audioContext = new AudioContext();
  resonanceGain = audioContext.createGain();
```

Next, define a 3D room and its wall materials

```javascript
  let roomDimensions = {
  width: roomWidth,
  height: roomHeight,
  depth: roomDepth,
  };
  
  let roomMaterials = {
  left: 'uniform',
  right: 'uniform',
  up: 'uniform',
  down: 'uniform',
  front: 'uniform',
  back: 'uniform'
  };
```

For all available wall material types, you can check Resonance audio documentation.

Next, we create an instance of Resonance Audio and connect it to the audioContext through resonanceGain. Also, set the initial listener position at the center of the room (0,0,0)

```javascript
  resonanceAudioScene = new ResonanceAudio(audioContext,{
  ambisonicOrder: 1
  });
  
  resonanceAudioScene.output.connect(resonanceGain);
  resonanceGain.connect(audioContext.destination);
  resonanceAudioScene.setRoomProperties(roomDimensions, roomMaterials);
  resonanceAudioScene.setListenerPosition(0, 0, 0);
```

## Connect Subscribers to Resonance Audio

Next, whenever a subscriber is added to the session, we connect the subscriber output to Resonance audio.

```javascript
  function connectVideoToResonanceAudio(subscriber,x=1,y=0,z=1) {
  if(!isSupported)
  return;
  let subscriberId = subscriber.id;
  subscriber.setAudioVolume(0);
  
  console.log("Adding streamId="+subscriber.stream.id+" to the
  map");
  // find the video element 
  var videoElem = subscriber.element.querySelector('video');
  if(videoElem == undefined){
  console.log("Video Element null in connectVideoToResonanceAudio. Something terribly wrong");
  return;
  }
  
  let audioElementSource =
  audioContext.createMediaStreamSource(videoElem.srcObject);
  let source = resonanceAudioScene.createSource();
  audioElementSource.connect(source.input);
  source.setPosition(x, y, z);
  resonanceSources\[subscriberId] = source;
  }
```

Please note that we have set the subscriber volume to 0 because we don't want to hear the subscriber audio directly. Instead, we route subscriber audio through Resonance.

First, we find the `video` element of the subscriber and then get the audio stream of the subscriber using videoElem.srcObject, which returns a MediStream. Then we create a "Resonance audio source" and connect the subscriber audio stream to this source. You can set the initial position of the subscriber source to a default value. We will change this later when the layout is finalized or resized.

## Assign Source Positions to Subscribers

Whenever you have added a new subscriber to the layout or the layout is resized, you should re-assign the source positions based on the relative position of the subscriber on the layout.

Each participant can have their own layout.

In this snippet, we place the listener at the center of the sphere and then place the subscribers around the edge of the half-sphere (approximately).

```javascript
  function adjustAudioSourcePositions(streams, numSpeakersVisible, layoutDiv){\
  // find the center point of the video layout in pixels 
  let layoutRect = document.getElementById(layoutDiv).getBoundingClientRect();
  let layoutCenterX = layoutRect.left + (layoutRect.width/2);
  let layoutCenterZ = layoutRect.top + (layoutRect.height/2);
  // convert pixels to room dimensions in meters
  let scaleX = roomWidth/layoutRect.width;
  let scaleZ = roomHeight/layoutRect.height;
  for(i=0;i<numSpeakersVisible && i <streams.length;i++){
  /* for each subscriber, get the bounding box and find the center relative to
  the center of layoutContainer */
  let subscriberRect =
  document.getElementById(streams\[i].subscriber.id).getBoundingClientRect();
  let subscriberCenterX = subscriberRect.left + (subscriberRect.width/2);
  let subscriberCenterZ = subscriberRect.top + (subscriberRect.height/2);
  
  let relativeX = (subscriberCenterX - layoutCenterX)*scaleX;
  let relativeZ = (subscriberCenterZ - layoutCenterZ)*scaleZ;
  /* lets keep people closer to the center of screen further away on Y axis, so
  it should be like people sitting in half spherical shape */
  let Y = 2 * (1 - (Math.abs(relativeX)/(roomWidth/2)));
  setSourcePosition(streams\[i].subscriber.id,relativeX,Y,relativeZ);
  }
  }
```

## Switching Between Spatial and Mono

If you want to enable spatial mode, all you have to do is to set resonanceGain gain value to 1 and set all subscribers volume to 0. Similarly, to enable mono mode, set all subscribers volume to 50 and resonanceGain gain value to 0.

```javascript
  function changeMode(mode){
  if(!isSupported)
  return;
  if(mode == MODE_SPATIAL){
  console.log("mode is spatial now");
  resonanceGain.gain.value=1;
  setSubscribersVolume(0);
  }
  else if(mode == MODE_NONE){
  console.log("mode is mono now");
  resonanceGain.gain.value=0;
  setSubscribersVolume(50);
  }
  }
  
  
  function setSubscribersVolume(vol){
  if(!isSupported)
  return;
  for (var streamId in subscriberMap) {
  subscriberMap\[streamId].setAudioVolume(vol);
  }
  }
```

## Browser Compatibility

Although all browsers should be compatible, we encountered some issues during testing. Firefox works as expected, but we found that desktop Chrome doesn't enable echo cancellation when audio is routed through WebAudio ([Chrome bug](https://bugs.chromium.org/p/chromium/issues/detail?id=687574)). This means if any of the participants aren't wearing a headset, it can create a bad audio experience for everyone. The workaround for this issue is to route the processed audio through a loopback peer connection and connect to an audio element.

Fix below:

```javascript
  function fixChrome687574(loopbackDestination, audioContext,
  resonanceGainNode,audioEl){
  const outboundPeerConnection = new RTCPeerConnection();
  const inboundPeerConnection = new RTCPeerConnection();
  const onError = e => {
    console.error("RTCPeerConnection loopback initialization error", e);
  };
  outboundPeerConnection.addEventListener("icecandidate", e => {
  inboundPeerConnection.addIceCandidate(e.candidate).catch(onError);
  });
  inboundPeerConnection.addEventListener("icecandidate", e => {
  outboundPeerConnection.addIceCandidate(e.candidate).catch(onError);
  });
  inboundPeerConnection.addEventListener("track", e => {
  audioEl.srcObject = e.streams[0];
  });
  resonanceGainNode.connect(loopbackDestination);
  loopbackDestination.stream.getTracks().forEach(track => {
  outboundPeerConnection.addTrack(track, loopbackDestination.stream);
  });
  outboundPeerConnection.createOffer().then(offer => {
  outboundPeerConnection.setLocalDescription(offer).catch(onError);
  
  inboundPeerConnection
  .setRemoteDescription(offer)
  .then(() => {
  inboundPeerConnection
  .createAnswer()
  .then(answer => {
  answer.sdp = answer.sdp.replace('useinbandfec=1', 'useinbandfec=1', 'stereo=1');
  inboundPeerConnection.setLocalDescription(answer).catch(onError);
  outboundPeerConnection.setRemoteDescription(answer).catch(onError);
  })
  .catch(onError);
  })
  .catch(onError);
  });
  }
```

Safari (14.1.2) also introduces some audio issues, but 15.x seems to be working fine.

## Future Improvements

Even though we have placed the sound sources in 3D space, they are point sources - they emit sound in all directions. As a future improvement, you can make them directional sources, so each subscriber emits sounds in the listener's direction only.

## Conclusion

Today, we built a spatial audio experience using Vonage Video APIs and Resonance SDK by positioning the subscribers in different parts of a virtual room. You can now have more fun in virtual meetings by enabling spatial audio. Please check the [complete source code](https://github.com/nexmo-se/vonage-roundtable/blob/spacial-audio/public/lib/spacial-audio/spacial-audio.js) if you are excited to build this on your own.
