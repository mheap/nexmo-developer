---
title: How to Send SMS With Go
description: Learn how to send an SMS message with Go in less than 20 lines of code.
thumbnail: /content/blog/how-to-send-sms-with-go-dr/TW_Go.jpg
author: martyn
published: true
published_at: 2019-08-28T07:05:49.000Z
updated_at: 2021-04-19T13:00:24.672Z
category: tutorial
tags:
  - go
  - sms-api
comments: true
redirect: ""
canonical: ""
---
In this blog post, we'll show you how to use the [Vonage Go SDK](https://github.com/Vonage/vonage-go-sdk) to send an SMS using Go in less than 20 lines of code.

## Prerequisites

To follow along with this post you'll need to have Golang installed on your development machine. Installation instructions can be found on the [official Golang website](https://golang.org/).

Alternatively, if you're new to Go, or you don't want to go through the installation process, you can work directly in the [Golang Playground](https://play.golang.org/) instead.

## Using the Vonage Go SDK

Fire up your editor and create a new file called `main.go`. Then scaffold the basics of a Go application by typing (or copying) the following code:

```golang
package main

import (
	"fmt"
	"github.com/vonage/vonage-go-sdk"
)

func main() {

}
```

> Note: If you save  `main.go` and the files in the import statement disappear, don't worry, they'll come back once you use them inside the `main()` function.

Now it's time to put some meat on those bones and instantiate the Vonage Go SDK so you can actually make it do things.

Inside the `main()` function add the following:

```golang
auth := vonage.CreateAuthFromKeySecret(API_KEY, API_SECRET)
smsClient := vonage.NewSMSClient(auth)
response, _ := smsClient.Send("44777000000", "44777000777", "Hi from golang", vonage.SMSOpts{})
```

There are two things happening here.

First, you create an `auth` object that combines your API key and secret together using a helper function that will ensure everything is formatted correctly.

> Note: Your API key and secret can be found by logging into your [Vonage Dashboard](https://dashboard.nexmo.com/sign-in). If you don't have an account yet, you can [sign up here](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) and get a free starter credit to run this code!

Second, you instantiate a new `smsClient` that will hold all the functionality the [Vonage Go SDK](https://github.com/Vonage/vonage-go-sdk) provides. Your `auth` object is passed into this.

With this in place, you can now perform actions on the Vonage API, such as sending an SMS.

## Send SMS Messages With Go

With the Vonage API client ready to go, your code will now look like this:

```go
package main

import (
	"fmt"
	"github.com/vonage/vonage-go-sdk"
)

func main() {
    auth := vonage.CreateAuthFromKeySecret(API_KEY, API_SECRET)
    smsClient := vonage.NewSMSClient(auth)
    response, _ := smsClient.Send("44777000000", "44777000777", "Hi from golang", vonage.SMSOpts{})
}
```

In order to send an SMS with Go you need to pass `smsClient` all of the information the SMS needs to make it to its destination.

As a minimum you should include the number the SMS should be sent to, the number it is sent from and the text to be displayed.

The `To` number can be your own number but the `From` number must be an SMS capable number purchased via your [Vonage Dashboard](https://dashboard.nexmo.com).

Now the only thing left to do is to tell our app to _send_ the SMS. This is done using the `Send` method provided by the API client.

The heavy lifting of sending the SMS is all done in a single line:

```golang
response, _ := smsClient.Send("44777000000", "44777000777", "Hi from golang", vonage.SMSOpts{})
```

Finally, add a quick bit of error checking and response output:

```golang
if response.Messages[0].Status == "0" {
    fmt.Println("Message sent")
}
```

Your final `main.go file should look like this:

```golang
package main

import (
	"fmt"
	"github.com/vonage/vonage-go-sdk"
)

func main() {
	auth := vonage.CreateAuthFromKeySecret(API_KEY, API_SECRET)
	smsClient := vonage.NewSMSClient(auth)
	response, _ := smsClient.Send("44777000000", "44777000777", "Hi from golang", vonage.SMSOpts{})

	if response.Messages[0].Status == "0" {
		fmt.Println("Message sent")
	}
}
```

Now the stage is set to send that SMS! Head to your terminal and from inside the folder you're working in run:

```bash
go run main.go
```

If everything worked you'll see `Message Sent` returned to the screen just before the familiar sound of your SMS notification rings out signaling your success.

## Where to Go From Here?

The next change you can make to the code above is to make it a little more secure by removing the hardcoded API key, API secret, and the phone numbers.

A good way to do this is to move them to environment variables that are stored in a `.env` file.

Try implementing this using the [godotenv](https://github.com/joho/godotenv) package and quickly shore up your security.

## Further Reading

If sending an SMS with Go has go you excited about what other communication elements you could be adding to your application then take a look at the examples on the [Vonage Go SDK GitHub repository](https://vonage.github.io/vonage-go-sdk/examples/sms).

There you'll find code for using many other aspects of the Vonage APIs such as making phone calls, receiving SMS messages, and verifying phone numbers.

As ever, we're keen to hear from you. If you have questions about using Go with the Vonage APIs consider joining our [Vonage Community on Slack](https://developer.nexmo.com/community/slack) and asking your questions there.

Contributions to the SDK are also welcome, so if you're keen on helping us expand the scope of it further, feel free to raise a pull request on GitHub.

