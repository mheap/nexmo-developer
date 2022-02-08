---
title: Detecting Music With ShazamKit
description: In this tutorial, you will use ShazamKit to detect music playing
  and send it as a message to a chat with the Vonage Client SDK for iOS.
thumbnail: /content/blog/detecting-music-with-shazamkit/shazamkit_musicdetection_1200x600.png
author: abdul-ajetunmobi
published: true
published_at: 2021-07-08T09:49:47.601Z
updated_at: 2021-07-01T16:35:11.108Z
category: tutorial
tags:
  - shazamkit
  - swift
  - conversation-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In this tutorial, you will use [ShazamKit](https://developer.apple.com/documentation/shazamkit) to detect music playing and send it as a message to a chat with the [Vonage Client SDK for iOS](https://developer.nexmo.com/client-sdk/overview). ShazamKit is available in iOS 15 and above, which at the time of writing is in beta.  

## Prerequisites

* An Apple Developer account and a test device running iOS 15.
* Xcode 13.
* Cocoapods to install the Vonage Client SDK for iOS.
* Our Command Line Interface, which you can install with `npm install @vonage/cli -g`.
* The Vonage CLI Conversations plugin, you can install it with `vonage plugins:install @vonage/cli-plugin-conversations`

<sign-up></sign-up>

## The Starter Project

This tutorial will be building on top of the ["Creating a chat app"](https://developer.nexmo.com/client-sdk/tutorials/in-app-messaging/introduction/swift) project from the Vonage developer portal. This tutorial will start from cloning the finished project from GitHub, but if you are not familiar with using the Vonage Client SDK for iOS to build a chat app, you can start with the tutorial. If you follow the tutorial, you can skip ahead to the enable ShazamKit section.

### Set up a Vonage Application

You now need to create a Vonage Application. An application contains the security and configuration information you need to connect to Vonage. Create a directory for your project using mkdir `vonage-tutorial` in your terminal, then change into the new directory using cd `vonage-tutorial`. Create a Vonage application using the following command: 

```sh
vonage apps:create "ShazamKit" --rtc-event-url=https://example.com/
```

A file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `shazamkit.key` is also created.

Next, create users for your application. You can do so by running:

```sh
vonage apps:users:create Alice
vonage apps:users:create Bob
```

Create a conversation:

```sh
vonage apps:conversations:create "shazam"
```

Add your users to the conversation, replacing `CONVERSATION_ID` and `USER_ID` with the values from earlier:

```sh
# Alice's User ID
vonage apps:conversations:members:add CONVERSATION_ID USER_ID
# Bob's User ID
vonage apps:conversations:members:add CONVERSATION_ID USER_ID
```

The Client SDK uses JWTs for authentication. The JWT identifies the user name, the associated application ID and the permissions granted to the user. It is signed using your private key to prove that it is a valid token. You can create a JWT for your users by running the following command replacing `APP_ID` with your application ID from earlier:

```sh
vonage jwt --app_id=APP_ID --subject=Alice --key_file=./shazamkit.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

```sh
vonage jwt --app_id=APP_ID --subject=Bob --key_file=./shazamkit.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

## Clone the iOS Project

To get a local copy of the iOS project, open your terminal and enter `git clone git@github.com:nexmo-community/clientsdk-app-to-app-chat-swift.git`. Change directory into the `clientsdk-app-to-app-chat-swift` folder by using `cd clientsdk-app-to-app-chat-swift`. Then install dependencies of the project by running `pod install`. Once complete, you can open the Xcode project by running using open AppToAppChat.xcworkspace.

## Authenticating the Client SDK

At the bottom of the `ViewController.swift` file, there is a `User` struct with a static property for our users Alice and Bob. Replace `CONVERSATION_ID`, `ALICE_JWT` and `BOB_JWT` with the values you generated in the terminal earlier. 

```swift
struct User {
    let name: String
    let jwt: String
    let chatPartnerName: String
    let conversationId = "CONVERSATION_ID"
    
    static let Alice = User(name: "Alice",
                            jwt:"ALICE_JWT",
                            chatPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"BOB_JWT",
                          chatPartnerName: "Alice")
}
```

## Enable Shazam

Once the project is open, ensure that you have a unique bundle identifier and enable automatic signing. 

![Bundle identifier section of Xcode](/content/blog/detecting-music-with-shazamkit/bundle.png)

Next, visit the [identifiers section](http://developer.apple.com/account/resources/identifiers/list) of your account on Apple's developer portal. Locate your bundle identifier, and under *App Services* enable ShazamKit.

![App Services on the developer portal](/content/blog/detecting-music-with-shazamkit/app-services.png)

## Detect Music

### Microphone Permissions

To detect the music being played, you will need to access the device's microphone, which requires your permission. Your project contains an `Info.plist` file containing metadata for the app–you will find the file inside the AppToAppChat group.

A new entry in the `Info.plist` file is required:

1. Hover your mouse over the last entry in the list and click the little + button that appears.
2. From the dropdown list, pick `Privacy - Microphone Usage Description` and add `To detect music with Shazam` for its value.

Your `Info.plist` should look like this:

![Info.plist after adding microphone permissions](/content/blog/detecting-music-with-shazamkit/permissions.png)

Next, open your `AppDelegate.swift` file and import `AVFoundation`:

```swift
import UIKit
import AVFoundation
```

Then, call `requestRecordPermission:` inside `application:didFinishLaunchingWithOptions:`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    if AVAudioSession.sharedInstance().recordPermission != .granted {
        AVAudioSession.sharedInstance().requestRecordPermission { (isGranted) in
            print("Microphone permissions \(isGranted)")
        }
    }
    return true
}
```

### Create an Audio Buffer

The app will be using the microphone to continuously detect music in the background, so you will need to create an audio buffer from the microphone to pass to ShazamKit. Open the `ChatViewController.swift` file, import `AVFoundation`, `ShazamKit` and add these properties to the class:

```swift
import UIKit
import ShazamKit
import NexmoClient
import AVFoundation

class ChatViewController: UIViewController {
    
    let session = SHSession()
    let audioEngine = AVAudioEngine()
    var lastMatchID: String = ""

    ... 
}
```

Next add a new function to the class called `startAnalysingAudio`: 

```swift
func startAnalysingAudio() {
    let inputNode = audioEngine.inputNode
    let bus = 0
    inputNode.installTap(onBus: bus, bufferSize: 2048, format: inputNode.inputFormat(forBus: bus)) { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
        self.session.matchStreamingBuffer(buffer, at: time)
    }
    
    audioEngine.prepare()
    try! audioEngine.start()
}
```

This function uses [`AVAudioEngine`](https://developer.apple.com/documentation/avfaudio/avaudioengine) to access the input of the microphone. `AVAudioEngine` is a robust framework that allows you to manipulate audio by plugging in/chaining node objects. You are only interested in the output, `bus 0`, of the `inputNode` for this app. The `installTap` function allows you to observe the output and gives you access to an `AVAudioNodeTapBlock`, which is a typealias for an `AVAudioPCMBuffer` and `AVAudioTime` tuple. Both the buffer and time are then passed along to the `matchStreamingBuffer` function on the `SHSession`, which then tries to match any music playing to the Shazam Catalogue. 

To end the process, you need to add a function called `stopAnalysingAudio` which will safely stop observing the input:

```swift
func stopAnalysingAudio() {
    let inputNode = audioEngine.inputNode
    let bus = 0
    inputNode.removeTap(onBus: bus)
    self.audioEngine.stop()
}
```

Set the session's delegate to this class, call `startAnalysingAudio` at the bottom of the `viewDidLoad` function and `stopAnalysingAudio` in the `logout` function:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    session.delegate = self
    
    ...
    
    getConversation()
    startAnalysingAudio()
}

@objc func logout() {
    client.logout()
    stopAnalysingAudio()
    dismiss(animated: true, completion: nil)
}
```

### The `SHSessionDelegate`

Now that the app is passing a buffer along to ShazamKit you need to implement the `SHSessionDelegate` to receive updates. Create an extension at the bottom of the file:

```swift
extension ChatViewController: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        if let matchedItem = match.mediaItems.first,
           let title = matchedItem.title,
           let artist = matchedItem.artist,
           let matchId = matchedItem.shazamID, matchId != lastMatchID {
            lastMatchID = matchId
            DispatchQueue.main.async {
                self.send(message: "I am currently listening to: \(title) by \(artist) - Via ShazamKit")
            }
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        if error != nil {
            print(error as Any)
        }
    }
}
```

The `didNotFindMatchFor` function is called when ShazamKit found no match or an error. Otherwise, the `didFind` function will be called when a match has been found. 

The matches come back as an array with varying confidence levels, but you will take the first result. Also, the function compares the match ID to the last match to ensure that when you send a message to the chat, it only happens once per match. 

## Try it out

Build and Run (CMD + R) the project on your iOS device and also in the simulator. Log in with a different user on each device. If you play some music in the background, the physical iOS device will pass the audio buffer to ShazamKit. If a song matches the Shazam catalogue, a message will be sent to the chat. 

![Chat showing a song being matched](/content/blog/detecting-music-with-shazamkit/chat.png)

## What Next?

You can find the completed project on [GitHub](https://github.com/nexmo-community/swift-app-to-app-shazamkit). You can do a lot more with the Client SDK. Learn more about the Client SDK on [developer.nexmo.com](https://developer.nexmo.com/client-sdk/overview) and ShazamKit on [developer.apple.com](https://developer.apple.com/documentation/shazamkit)
