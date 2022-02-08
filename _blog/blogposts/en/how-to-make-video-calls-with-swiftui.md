---
title: How to Make Video Calls with SwiftUI
description: Learn how to build a one-to-one video chat in SwiftUI using the
  Vonage Video Client SDK for iOS.
thumbnail: /content/blog/how-to-make-video-calls-with-swiftui/video-call_swiftui_1200x600.png
author: abdul-ajetunmobi
published: true
published_at: 2021-05-26T09:40:37.097Z
updated_at: 2021-05-13T14:24:44.173Z
category: tutorial
tags:
  - swiftui
  - video-api
  - swift
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---

In this tutorial, you will use the Vonage [Video Client SDK](https://tokbox.com/developer/sdks/ios/) for iOS to build a one-to-one video chat in SwiftUI. 

## Prerequisites

* A [Vonage Video API account](https://tokbox.com/account/user/signup).
* Xcode 12 and Swift 5 or greater.

## Create a Vonage Video API Project

Open your [Vonage Video API dashboard](https://tokbox.com/account/#/) and create a new API project. You can call it anything you wish, but leave the codec as VP8. Under the project tools section, create a routed [session](https://tokbox.com/developer/guides/create-session/) ID. You can think of a session as a room in which participants meet and chat. Just below, use the session ID to create a [token](https://tokbox.com/developer/guides/create-token/); you can leave the rest of the fields as their default. Tokens are a method used to authenticate users. Keep a note of your session ID, token and project API key for a future step.

## Creating the iOS Application

The next step is to get the iOS application set up. Once you have created the application, you need to install the Video Client SDK and ask for microphone and camera permissions.

### Create an Xcode Project

To get started, open Xcode and create a new project by going to File > New > Project. Select iOS as the platform and App for the template and give it a name. 

![Xcode platform screen](/content/blog/how-to-make-video-calls-with-swiftui/xcode-platform-screen.png)

Select SwiftUI for the interface, SwiftUI App for the life cycle, and Swift for the language. Finally, a location to save your project.

![Xcode project creation screen](/content/blog/how-to-make-video-calls-with-swiftui/xcode.png)

### Install the Client SDK

Now that you've created the project, you can add the Video Client SDK as a dependency. Close your Xcode project and navigate to the location where you saved the project in your terminal and run the following commands:

1. Run the pod init command to create a new Podfile for your project.
2. Open the Podfile in Xcode using open -a Xcode Podfile.
3. Update the Podfile to have `OpenTok` as a dependency.

```sh
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VideoChat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for VideoChat
  pod 'OpenTok'
end
```

4. Install the SDK using `pod install`.
5. Open the new *xcworkspace* file in Xcode using `open VideoChat.xcworkspace`.

### Permissions

Since the application will be using the microphone and camera to video chat, you need to add descriptions for why you need the permissions, which will be shown in a prompt when running the app.

Edit the `Info.plist` file. The `Info.plist` is a file that contains all the metadata required for the application. Add a new entry to the file by hovering your mouse over the last entry in the list and click the little `+` button that appears. From the dropdown list, pick `Privacy - Microphone Usage Description` and add `Microphone access required to video chat` for its value. Repeat the steps for `Privacy - Camera Usage Description`.

## The Video Client SDK

The Video Client SDK uses the credentials you created in the Video API dashboard to connect to the Vonage servers. 

### Connecting the Client SDK

Create a new file called `OpenTokManager.swift` by going to *File > New File (CMD + N)* and add the following, replacing the empty strings with your credentials:

```swift
import OpenTok

final class OpenTokManager: NSObject, ObservableObject {
    // Replace with your OpenTok API key
    private let kApiKey = ""
    // Replace with your generated session ID
    private let kSessionId = ""
    // Replace with your generated token
    private let kToken = ""

    private lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()

    private lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    private var subscriber: OTSubscriber?
    
    @Published var pubView: UIView?
    @Published var subView: UIView?
    @Published var error: OTErrorWrapper?
}
```

In addition to the credentials, there are variables for a [session](https://tokbox.com/developer/guides/basics/#session), [publisher](https://tokbox.com/developer/guides/basics/#publish) and [subscriber](https://tokbox.com/developer/guides/basics/#subscribe). As mentioned earlier, you can think of a session as a room that the clients connect to; the SDK has the `OTSession` class for this. Publishers,  `OTPublisher`, allow the client to publish audio and video when connected to a session. Subscribers, `OTSubscriber`, allow for the client to subscribe to audio and video from other clients in the session. There are also variables using the `@Published` property wrapper, which is how the `OpenTokManager` class will communicate with the view code later on.

Now that the properties are in place, add the following functions to the `OpenTokManager` class:

```swift
import OpenTok

final class OpenTokManager: NSObject, ObservableObject {
    ...

    public func setup() {
        doConnect()
    }
    
    private func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        session.connect(withToken: kToken, error: &error)
    }
    
    private func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let view = publisher.view {
            DispatchQueue.main.async {
                self.pubView = view
            }
        }
    }
    
    private func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        session.subscribe(subscriber!, error: &error)
    }
    
    private func cleanupSubscriber() {
        DispatchQueue.main.async {
            self.subView = nil
        }
    }
    
    private func cleanupPublisher() {
        DispatchQueue.main.async {
            self.pubView = nil
        }
    }
    
    private func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                self.error = OTErrorWrapper(error: err.localizedDescription)
            }
        }
    }
}
```

The `doConnect` function connects the client to the session, `doPublish` starts publishing, `doSubscribe` starts subscribing. Then there are functions to clean up the subscriber (`cleanupSubscriber`) and publisher (`cleanupPublisher`) when the client disconnects from either, followed by a function to handle errors (`processError`).

### The `OTSessionDelegate`

The `OTSessionDelegate` is how the Video Client SDK communicates changes with the session back to you. Add an extension in the same file: 

```swift
extension OpenTokManager: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        doSubscribe(stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
}
```

When the session connects, `doPublish` is called, when a stream is created `doSubscribe` is called and when the stream is destroyed `cleanupSubscriber` is called. 

### The `OTPublisherDelegate`

The `OTPublisherDelegate` is how the Video Client SDK communicates changes with publishing to a session back to you. Add an extension in the same file: 

```swift
extension OpenTokManager: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}
```

Similarly to the `OTSessionDelegate` when the stream is destroyed, `cleanupPublisher` is called, and `cleanupSubscriber` if there is an active subscription to a stream. 

### The `OTSubscriberDelegate`

The `OTSubscriberDelegate` is how the Video Client SDK communicates changes by subscribing to a session back to you. Add an extension in the same file: 

```swift
extension OpenTokManager: OTSubscriberDelegate {
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let view = subscriber?.view {
            DispatchQueue.main.async {
                self.subView = view
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
```

Similarly to when to publish to a session, if subscribing is successful, you are returned a `UIView` object. In the case of `subscriberDidConnect` the view object being returned is for the subscriber.

## Building the Video Chat UI

With the `OpenTokManager` class complete, you can now build the UI. The Video Client SDK gives you `UIView` objects for the publisher and subscriber views which cannot be directly used in SwiftUI. The [`UIViewRepresentable`](https://developer.apple.com/documentation/swiftui/uiviewrepresentable) protocol allows for bridging from a `UIView` object to a `View` object for SwiftUI. In the `ContentView.swift` file, add the following structs:

```swift
struct OTErrorWrapper: Identifiable {
    var id = UUID()
    let error: String
}

struct OTView: UIViewRepresentable {
    @State var view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.view = uiView
        }
    }
}
```

The `OTView` struct, which conforms to `UIViewRepresentable` has a `UIView` object as a property. This view is returned when the system calls `makeUIView`. Since the lifecycle of views in SwiftUI is controlled by the system, you also need to implement`updateUIView`to handle that. The`OTErrorWrapper`struct allows error to conform to`Identifiable`, which is needed to use the SwiftUI alerts.

Next, replace the `ContentView` struct with the following:

```swift
struct ContentView: View {
    @ObservedObject var otManager = OpenTokManager()
    
    var body: some View {
        VStack {
            otManager.pubView.flatMap { view in
                OTView(view: view)
                    .frame(width: 200, height: 200, alignment: .center)
            }.cornerRadius(5.0)
            otManager.subView.flatMap { view in
                OTView(view: view)
                    .frame(width: 200, height: 200, alignment: .center)
            }.cornerRadius(5.0)
        }
        .alert(item: $otManager.error, content: { error -> Alert in
            Alert(title: Text("OpenTok Error"), message: Text(error.error), dismissButton: .default(Text("Ok")))
        })
        .animation(.default)
        .onAppear(perform: {
            otManager.setup()
        })
    }
}
```

This code adds a property for an instance of the `OpenTokManager` class from earlier. Since the views that `OpenTokManager` is publishing are optional, `.flatmap` is used. So when the views are nil, they are ignored, and when there is a value, they are unwrapped. If the `OpenTokManager` publishes an error, the alert will automatically show since it watching for changes on the published `.error` value.

If you build and run the project, you should now be able to start a video chat! You can use another device or the [OpenTok Playground](https://tokbox.com/developer/tools/playground/) to connect to the session from your laptop.

![video chat ios screenshot](/content/blog/how-to-make-video-calls-with-swiftui/ios.png)

## What Next?

The completed project is available on on [GitHub](https://github.com/opentok/opentok-swiftui-basic-video-chat), and you can read more about the Vonage Video API through our [documentation](https://tokbox.com/developer/guides/).