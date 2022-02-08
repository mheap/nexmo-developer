---
title: Unity and OpenTok, Take Two!
description: Get ready to learn how to use Unity3D with Vonage video
  communications API. Build live video into 3D, 2D, VR, and AR visualizations
  for games across platforms and devices.
thumbnail: /content/blog/video-gaming-unity-opentok/E_Unity_OpenTok_1200x600.jpg
author: roberto-perez-cubero
published: true
published_at: 2019-08-12T16:01:19.000Z
updated_at: 2021-05-07T15:20:45.834Z
category: tutorial
tags:
  - video-api
  - unity
comments: true
redirect: ""
canonical: ""
---
Time has passed quickly, since we first talked about [using OpenTok in Unity, the real-time, cross-platform game engine, a year ago](https://tokbox.com/blog/add-opentok-live-video-chat-to-unity/). Fast forward to a month ago, and we introduced our first iteration with Unity3d in beta, during our v2.16 release of OpenTok. Unity enables developers so they can build 3D, 2D, VR, and AR visualizations for games across platforms and devices, including Console, PC, Mobile, Instant, AR, and VR games. 

In this second iteration, we leveraged Unity’s cross-platform factor to build a sample that runs in the same platforms as OpenTok. Previously, we built a sample to work in Windows using Unity and OpenTok Windows SDK. In the new sample, you will be able to run your application or game in Android, iOS, Windows and MacOS, and all of that without modifying one single line of your code. 

If you are eager to test it out, grab the sample from the [GitHub repo](https://github.com/opentok/opentok-unity-samples), open it with your Unity Editor, and start building it for the platform of your choice.

## Wait, Is This Magic? How Does It Work?

Let’s take a look at this simple block diagram to see how everything is laid out: [![](https://www.nexmo.com/wp-content/uploads/2019/08/Table-1.png)](https://www.nexmo.com/wp-content/uploads/2019/08/Table-1.png) In the new sample, we bundled all supported OpenTok platform libraries, so that Unity will pick the right SDK when a developer is building a game for any given platform. 

In the diagram, we used different colors to differentiate each part of the sample. The boxes in blue are .NET components that are on Unity runtime. There are three different components to consider: In blue, you can see the code of your game or application. 

In addition to that, also in blue there are the OpenTok client code that interacts with OpenTok SDK and Unity engine. 

The green box represents the OpenTok SDK API. This is where well-known Session, Publisher, and Subscriber classes live. Since unity uses .NET and, more precisely, C# language, we used the same API as Windows SDK. 

And last, there are the yellow boxes. They represent the native code that will run on the platform of choice, once you build the final executable version of your game. Now we can see our final goal and run the same code in all platforms. This is thanks to OpenTokUnity.dll, which transports Session, Publisher, or Subscribe interactions to native code in each platform. 

In terms of file artifacts, everything is under [Assets/DLL folder](https://github.com/opentok/opentok-unity-samples/tree/master/Assets/DLLs),

 [![](https://www.nexmo.com/wp-content/uploads/2019/08/image2.png)](https://www.nexmo.com/wp-content/uploads/2019/08/image2.png) 

As you can see in this capture, there is OpenTokUnity.dll file, and within every folder lives its native library. You will find the same binaries we distribute via our official channels like cocoapods, nuget, or maven. 

If you want to use this approach in your project, you should copy all the contents from Assets/DLL into your project. (Don’t forget to copy the .meta files, as they contain information about the platform targets for each file)

## At the Root of Everything, There is Some C# Code

Now that we covered the role of every component in the equation, we can go into more detail about how it works inside Unity. Everything you need to have a video call within a unity game or application is within [the sample and its four files](https://github.com/opentok/opentok-unity-samples/tree/master/Assets/Scripts). [![](https://www.nexmo.com/wp-content/uploads/2019/08/Table-2.png)](https://www.nexmo.com/wp-content/uploads/2019/08/Table-2.png)

### SceneScript

This script is attached to a GameObject Scene. It will run when the sample starts, mainly creating an `OpenTokSession` object. 

This class holds two GameObject instances. One for the publisher and another for the subscriber. Video will appear in the scene within the content of the GameObjects. Furthermore, both GameObjects are used in the OpenTokSession constructor. We will see in more detail how video frames end in the GameObjects.

It also calls `Connect()` method to connect to opentok session. 

Please note that this file is a subclass of `MonoBehaviour`, which means that its `Update` method will be called periodically from Unity engine. This script will notify the `OpenTokSession` instance about this update.

### OpenTokSession

OpenTokSession refers to the main file where all OpenTok SDK interactions happen. It’s also the file that calls OpenTokUnity.dll. 

This is not a Monobehaviour subclass, so no method will be called automatically from Unity. 

Most code in this class is about connecting to an OpenTok Session.This includes things like: implementing opentok events, publishing, and subscribing. It looks like very similar to what you will find in our platform sample repositories, when looking for Basic Video Chat sample applications. 

However, there is an important detail about how Publisher and Subscriber is created. Let’s see, for example, how a new Publisher is created:

```
publisher = new Publisher(Context.Instance, renderer: 
publisherRenderer, capturer:videoCapturer);
```

The renderer and capturer parameters are very common in OpenTok SDK. In some platforms like iOS or Android, you are not required to provide them because OpenTok SDK has a default implementation that can be used. 

This sample works in all platforms. If you want to have a renderer and a capturer that works across platforms, then one approach to consider would be to use Unity SDK to build the capturer and renderer.

### OpenTokRenderer

The main responsibility of this class is, as its name suggests, is to render video frames within a GameObject Texture. 

With this purpose in mind, this class is a subclass of MonoBehaviour and implements Opentok IVideoRenderer interface. 

As it is a Monobehaviour subclass, it will be attached to Publisher or Subscriber GameObjects. It has access to the Texture2D instance where it will be rendering video frames. 

As it implements OpenTok IVideoRenderer interface, its RenderFrame method will be called when a new videoframe is ready to render. 

If you want to get more details about how the sample renders frames, please take a look at the [class code](https://github.com/opentok/opentok-unity-samples/blob/master/Assets/Scripts/OpenTokRenderer.cs).

### OpenTokVideoCapture

The last piece in the puzzle is the capturer, This class role is very simple. It uses WebCamTexture unity class to access to the device camera, and send the video frames from the camera to OpenTok SDK by implementing IVideoCapturer interface.

## Conclusion

Our first iteration of the sample shows you how RTC comms works in Unity. In the new version, you can use OpenTok for video and audio communication in a real world Unity Game or Application. 

If you want to expand your user base, then it’s crucial to have the ability to deploy your game on different platforms—which is why our target was to support as many platforms as possible.