---
title: How to Add Streaming Video on Linux with OpenTok Linux SDK
description: With OpenTok Linux SDK, you will be able to create desktop
  applications that support video surveillance solutions on embedded Linux
  systems and other applications where audio and video streaming is needed.
thumbnail: /content/blog/opentok-linux/FB_OpenTokLinux.png
author: jose-antonio
published: true
published_at: 2019-08-14T21:43:11.000Z
updated_at: 2021-05-07T15:06:21.065Z
category: tutorial
tags:
  - video-api
  - linux-sdk
comments: true
redirect: ""
canonical: ""
---
## How to Add Streaming Video on Linux with OpenTok Linux SDK

As part of our OpenTok Labs initiative, we're happy to share the new samples of our Linux SDK. Using the Linux SDK, you will be able to create desktop applications that support video surveillance solutions on embedded Linux systems and other applications where audio and video streaming is needed. The OpenTok Labs label indicates that the SDK is currently on a best effort basis, rather than an officially supported SDK, so we’d love you to contribute by filing issues and sending pull requests to improve it. The OpenTok Linux SDK is designed to work with reduced consumption of system resources and low memory footprint. You can use the Linux SDK via a C API, which will allow developers to integrate it nearly anywhere. Given that Linux has been widely adopted for a variety of use cases, you can now extend your reach and add real-time communications to Linux-based devices using the OpenTok platform.

## How it Works

If you are already familiar with the OpenTok SDK APIs and concepts, then getting started with the Linux SDK will be easy because it uses the same OpenTok concepts, such as sessions, publishers, and subscribers, among others. With the OpenTok Linux SDK, we also follow a programming model where the application initiates actions, such as connect to a session, start publishing, and subscribe to a stream, etc. After the action is initiated and certain events occur, then the application is notified via callbacks. These events, for example, include:

*   when a session is connected successfully or there is an error,
*   when a publisher starts publishing,
*   when there is a new participant in the session, and when a new participant starts publishing, which triggers the creation of a new subscriber, etc.

Let’s get started on how to implement the common steps used to add live video to any application using the OpenTok client SDKs.

## Connect to a Session

When connecting to a session, the developer has to provide the callback functions that implement the response for the events that the application is interested in. The pointers to these functions are provided via a struct, which act as an argument to the function that can create a session. The pointer to this new session is later used when connecting the session. As with our other sample applications, the developer has to provide the OpenTok credentials (i.e., API KEY, session id, and token).

```
// ...

void onOpenTokSessionConnectedCallback(otc_session *session, void *user_data) {
}

void onOpenTokSessionStreamReceivedCallback(otc_session *session, 
                                            void *user_data,
                                            const otc_stream *stream) {
}

void onOpenTokSessionStreamDroppedCallback(otc_session *session,
                                           void *user_data,
                                           const otc_stream *stream) {
}

void onOpenTokSessionErrorCallback(otc_session *session,
                                   void *user_data,
                                   const char* error_string,
                                   enum otc_session_error error) {
}

// ...

struct otc_session_cb session_callbacks = {0};
session_callbacks.user_data = this;
session_callbacks.on_connected = onOpenTokSessionConnectedCallback;
session_callbacks.on_stream_received = onOpenTokSessionStreamReceivedCallback;
session_callbacks.on_stream_dropped = onOpenTokSessionStreamDroppedCallback;
session_callbacks.on_error = onOpenTokSessionErrorCallback;
session_ = otc_session_new(apiKey.c_str(), sessionId.c_str(), &session_callbacks);

if (session_ == nullptr) {
  return;
}

otc_session_connect(session_, token.c_str());
```


## Publish Audio and Video into a Session

For publishers, we follow the same approach and provide callback functions that implement the response for events that the application is interested in. For the publisher, the developer is responsible for creating those callback functions. They implement the response to certain events, for example: when the publisher starts publishing (the stream is created, then an event is fired), or there is a new frame from the publisher video stream that can be rendered or an error occurs. The pointers to these callback functions are provided through another struct that is passed as an argument to the function that creates a new publisher.

```
void onOpenTokPublisherStreamCreatedCallback(otc_publisher *publisher, 
                                             void *user_data, 
                                             const otc_stream *stream) {
}

void onOpenTokPublisherRenderFrameCallback(otc_publisher *publisher,
                                           void *user_data,
                                           const otc_video_frame *frame) {
}

void onOpenTokPublisherErrorCallback(otc_publisher *publisher,
                                     void *user_data,
                                     const char* error_string,
                                     enum otc_publisher_error error_code) {
}

struct otc_publisher_cb publisher_cb = {0};
publisher_cb.user_data = this;
publisher_cb.on_stream_created = onOpenTokPublisherStreamCreatedCallback;
publisher_cb.on_render_frame = onOpenTokPublisherRenderFrameCallback;
publisher_cb.on_error = onOpenTokPublisherErrorCallback;
publisher_ = otc_publisher_new(name_.c_str(), nullptr, &publisher_cb);

if (publisher_ == nullptr) {
  return;
}
```


Once the session connected callback function is called, then the application can start publishing. It can be implemented within the callback function itself. Note: this is a callback function for the session. A pointer to it was provided when creating the session above.

```
void onOpenTokSessionConnectedCallback(otc_session *session, void *user_data) {
  // ...
  if ((session_ != nullptr) && (publisher_ != nullptr)) {
    otc_session_publish(session_, publisher_);
  }
  // ...
}
```


The application should not allow the publisher to publish until the session is connected.

## Subscribe to an Audio and Video Stream

Whenever there is a new participant connected to the session, and the participant is publishing, the session is notified via the session stream received callback. We can implement how a subscriber is created within the session callback function. Please note, this callback function belongs to the session created above, and a pointer to it was provided when creating the session. Similar to the session and publisher objects, the developer has to implement callback functions. An error one should always be provided to trigger the error notifications. This refers to the error callback. If an error occurs, then the callback function is called. When the subscriber is created, the session can connect to the new subscriber and start receiving the audio and video stream from the new participant.

```
// ...

void onOpenTokSubscriberRenderFrameCallback(otc_subscriber *subscriber,
					    void *user_data,
					    const otc_video_frame *frame) {
}

void onOpenTokSubscriberErrorCallback(otc_subscriber *subscriber,
                                      void *user_data,
                                      const char* error_string,
                                      enum otc_subscriber_error error_code) {
}

// ...

void onOpenTokSessionStreamReceivedCallback(otc_session *session,
					    void *user_data,
					    const otc_stream *stream) {
  // ...
  struct otc_subscriber_cb subscriber_cb = {0};
  subscriber_cb.user_data = conference;
  subscriber_cb.on_render_frame = onOpenTokSubscriberRenderFrameCallback;
  subscriber_cb.on_error = onOpenTokSubscriberErrorCallback;
  otc_subscriber* subscriber = otc_subscriber_new((otc_stream*)stream, &subscriber_cb);
  if (subscriber == nullptr) {
    return;
  }
  otc_session_subscribe(session, subscriber);
  // ...
}

// ...
```


## Render Video Stream

If you want to render the video stream for publishers and subscribers using OpenTok Linux SDK, then there are several good resources, like [Simple DirectMedia Layer Library well-known third-party libraries](https://www.libsdl.org/) that can help. The two callback functions below are called when there is a new frame to be rendered for publishers and subscribers.


```
void onOpenTokSubscriberRenderFrameCallback(otc_subscriber *subscriber,
					    void *user_data,
					    const otc_video_frame *frame) {
}

void onOpenTokPublisherRenderFrameCallback(otc_publisher *publisher,
                                           void *user_data,
                                           const otc_video_frame *frame) {
}

```



We can have a render manager, or something similar, that renders the frame for us. In the example below, we are using the Simple DirectMedia Layer library.


```
void Renderer::onFrame(otc_video_frame* frame) {
  if (!window_) {
    return;
  }
  SDL_Surface* surface_ =  SDL_GetWindowSurface(window_);

  auto pixels = otc_video_frame_get_plane(frame, 0);
  SDL_Surface* sdl_frame = SDL_CreateRGBSurfaceFrom(
      const_cast<unsigned char*>(pixels),
      otc_video_frame_get_width(frame),
      otc_video_frame_get_height(frame),
      32,
      otc_video_frame_get_width(frame) * 4,
      0,0,0,0);

  SDL_BlitScaled(sdl_frame, NULL, surface_, nullptr);
  SDL_FreeSurface(sdl_frame);

  SDL_UpdateWindowSurface(window_);
}
```


## OpenTok Linux SDK Samples

A couple of weeks ago we made public a [Github repository for OpenTok Linux SDK](https://github.com/opentok/opentok-linux-sdk-samples) with some samples to help provide a better understanding of the features and best practices. As of today, we have three different samples; however, we are working on adding much more. In one of the samples, you can implement a basic video chat application that can be run on a regular Linux desktop environment (e.g. Ubuntu 18.04.2 LTS, Bionic Beaver). As we mentioned early on, OpenTok Linux SDK can be used to implement a video surveillance solution, using a tiny single-board computer, such as the Raspberry Pi, to stream video as a publisher-only endpoint. This publisher-only endpoint functionality is part of the sample we provide.

## OpenTok Linux SDK Release Life Cycle

As of today, the OpenTok Linux SDK is in closed beta (private beta). Our new SDK is capable of delivering value, which is why we are introducing it now. However, it’s not yet ready for primetime. We are still in the process of creating all of the necessary things, such as developer documentation and resources for our developer center. In the meantime, we would love to get your feedback! We invite you to give our new SDK a try and let us know what you think. [OpenTok Linux SDK](https://github.com/opentok/opentok-linux-sdk-samples) builds can be found at [our repository on GitHub](https://github.com/opentok/opentok-linux-sdk-samples/tree/master/assets). Get started with any of the three builds included on GitHub, including x86_64, armv7 and arm64. Stay tuned for more news about the OpenTok Linux SDK.