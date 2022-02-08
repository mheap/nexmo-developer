---
title: How to send SMS Messages with Swift and Vapor using Async/Await
description: Use the new async/await feature from Swift 5.5 to send an SMS using
  the Vonage Messages API
thumbnail: /content/blog/how-to-send-sms-messages-with-swift-and-vapor-using-async-await/2fa_swift-vaporasync-1.png
author: abdul-ajetunmobi
published: true
published_at: 2021-11-24T11:03:09.252Z
updated_at: 2021-11-19T15:52:49.980Z
category: tutorial
tags:
  - swift
  - vapor
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Swift 5.5 introduces the async/await language feature to help improve the readability of concurrent Swift code by removing the need for completion handlers. This post will be very similar to [How to send SMS Messages with Swift, Vapor and Vonage](https://learn.vonage.com/blog/2021/01/12/how-to-send-sms-messages-with-swift-vapor-and-vonage/) on our blog. This post will be using the [Messages API V1](https://learn.vonage.com/blog/2021/11/16/announcing-vonage-messages-api-version-1-0/) rather than the SMS API but will be a good way to illustrate the improvements from using async/await.

If you are familiar with the original blog post, you can skip to the "Send the SMS" section.

## Prerequisites

<sign-up></sign-up>

* Xcode 13 and Swift 5.5 or greater.
* The [Vapor toolbox](https://docs.vapor.codes/4.0/install/macos/) installed on your machine.

## Create a Vapor Project

You can create a Vapor project using the new project command `vapor new AsyncTextMessage` in your terminal. It will first prompt you whether you would like to Fluent (press `n` to skip), then whether you want to use Leaf. [Leaf](https://docs.vapor.codes/4.0/leaf/getting-started) is a templating language that you will use to generate dynamic HTML pages, so press `y` to include it. Once the command has finished, change directory into the folder it created for you using `cd AsyncTextMessage`.

You will also need to create a `.env` file to store your Vonage API account credentials. In your terminal, use the following command to create the file replacing `X` and `Y` with your API key and secret, respectively:

`echo "APIKEY=X \nAPISECRET=Y" > .env`

Now you can open the project in Xcode using the `vapor xcode` command. Once Xcode opens, it will start downloading Vapor's dependencies using Swift Package Manager (SPM). To view the dependencies, you can open the `Package.swift` file.

By default, Xcode runs your application from a randomized local directory. Since you will be loading local resources, you need to set a custom working directory. Go to Product > Scheme > Edit Scheme... and set the working directory to your project's root folder.

![Setting custom working directory](/content/blog/how-to-send-sms-messages-with-swift-and-vapor-using-async-await/directory.png)

Press CMD+R to build and run. Once complete, find your web page at `localhost:8080`.

## Create a Web Page

Now that your project is set up, you will create an interface to enter a phone number and message for the SMS. Open the `index.leaf` file under Resources/Views and update it:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Send a text message</title>
  </head>

  <body>
    <h1>Send a text message using the Vonage Messages API</h1>

    #if(messageId):
      <p> Successful SMS ID: #(messageId)</p>
    #endif

    <form action="/send" method="post">
        <p>
        <label>Phone number E.g. 447000000000</label><br>
        <input type="text" name="to">
        </p>

        <p>
        <label>Text message</label><br>
        <textarea name="text"> </textarea>
        </p>
        <button type="submit">Send text</button>
    </form>
  </body>
</html>
```

The above code adds a form with inputs for a phone number and a message, and once the form is submitted, it will send a `POST` request to `/send`. Notice the Leaf block starting with #`if(messageId):`. It checks for a value for the `messageId` variable, and if set, it will add the text to the page. If you build and run (CMD + R), you will now see your updated page.

# Create the Model Structs

A benefit of using Vapor is that you can lean on the Swift language's type-safety. You can model inputs and outputs to your server using that conform to the `Codable` protocol; Vapor has a `Content` protocol for this.

Create a struct called `Input` that conforms to `Content` at the bottom of the `routes.swift` file:

```swift
struct Input: Content {
    let to: String
    let text: String
    let from = "SwiftText"
    let channel = "sms"
    let messageType = "text"

    private enum CodingKeys: String, CodingKey {
        case to
        case text
        case from
        case channel
        case messageType = "message_type"
    }
}
```

The Vonage Messages API expects fields in snake case, so the structs have the CodingKeys enum to map their property names to their snake case equivalent. Below the Input struct, create another struct for the response that is expected from the Messages API:

```swift
struct Response: Content {
    let messageId: String
    
    private enum CodingKeys: String, CodingKey {
        case messageId = "message_uuid"
    }
}
```

## Send the SMS

To send the SMS, you need to make a call to the Vonage Messages API. To do this, you need to define the `/send` route used by the web form, parse the form data, and then make the request. Start by defining the new route in the `routes` function:

```swift
app.post("send") { req async throws -> View in
    do {
        let input = try req.content.decode(Input.self)
    }
}
```

Note how the method uses `req async throws -> View in`. This means that the function is asynchronous and could throw errors. Hence the `do` block inside, which is decoding the web form fields into an `Input` struct. The closure returns a `View`. This differs from previously where you would have to return a future that would have eventually resolved into a `View`. 

Next, you will use Vapor's [Client](https://docs.vapor.codes/4.0/client/) API, which allows you to make external HTTP calls, to call the Messages API. Add the call to the send route:

```swift
app.post("send") { req async throws -> View in
    do {
        let input = try req.content.decode(Input.self)
        
        let clientResponse = try await req.client.post("https://api.nexmo.com/v1/messages") { req in
            try req.content.encode(input, as: .json)
            let auth = BasicAuthorization(
                username: Environment.get("APIKEY")!,
                password: Environment.get("APISECRET")!
            )
            req.headers.basicAuthorization = auth
        }
        
        let messageResponse = try clientResponse.content.decode(Response.self)
        
        return try await req.view.render(
            "index",
            ["messageId": "\(messageResponse.messageId)"]
        )
    }
}
```

The above code will await the result of the call to the Messages API, which uses the API credentials for authorization, then `clientResponse` will be set with the result. This allows you to write code as if it was synchronous. Also, since the code is in a `do` block, if there is an error it will just throw and be handled automatically or you can add a `catch` to handle them yourself. 

The following line decodes the response from the Messages API, then finally that is used to render the page. Again this uses `try await`, so when `req.view.render` completes, it will either return a `View` instance or throw an error.

## Try It Out

Build and run (CMD + R) the project, open `localhost:8080` in your browser, then fill in a phone number and a message.

![Sending a message via the web page](/content/blog/how-to-send-sms-messages-with-swift-and-vapor-using-async-await/page.png)

Clicking the send button will send the data to the route you defined earlier, make the call to the Vonage Messages API, and if successful it will show the message ID.

![The web page showing a successful message ID](/content/blog/how-to-send-sms-messages-with-swift-and-vapor-using-async-await/success.png)

## What Next?

You can find [the completed project on GitHub](https://github.com/Vonage-Community/blog-messages-swift_vapor-async_sms).

You can do more with the Messages API, such as sending messages on Whatsapp and Facebook Messenger. Learn about it on our [developer platform](https://developer.vonage.com/messaging/sms/overview).