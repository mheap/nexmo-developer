---
title: Send Messages with Nexmo through Golang and AWS Lambda
description: Create an API using AWS Lambda and AWS API Gateway that sends an
  SMS message with the Nexmo Messaging API, but with the Go programming language
thumbnail: /content/blog/send-messages-with-nexmo-through-golang-and-aws-lambda-dr/AWS_SMS_1200x675.jpg
author: nraboy
published: true
published_at: 2019-11-25T13:57:00.000Z
updated_at: 2021-05-21T09:11:37.669Z
category: tutorial
tags:
  - golang
  - aws
  - messages-api
comments: true
spotlight: true
redirect: ""
canonical: ""
---
I recently saw a tutorial by [Tom Morris](https://twitter.com/tommorris) on the Nexmo blog titled [Sending SMS from Python with Google Cloud Functions](https://www.nexmo.com/blog/2019/03/21/sending-sms-from-python-with-google-cloud-functions-dr), and thought it was an interesting example and use of SMS messaging, even though Python and Google Cloud Functions are not my normal.

After reading the blog, I thought it would be interesting to expand it to AWS Lambda as the functions provider and switch the language to Golang, something that I'm very passionate about.

In this tutorial, we're going to create an API using AWS Lambda and AWS API Gateway that sends an SMS message with the Nexmo Messaging API, but with the Go programming language.

## The Requirements

There are a few requirements that must be satisfied prior to working through this tutorial:

* You need to have Go installed and be at least somewhat familiar with the language.
* You need to have a Nexmo developer account.
* You need to have an Amazon Web Services account.

Since Go is a compiled language, we need to be able to develop and build locally. Our builds will be uploaded to AWS, hence the need for an AWS account. These applications will make use of the Nexmo Messaging API.

## Building a Messaging Function with Go and the AWS Lambda SDK

When it comes to the development of the Go application, there isn't too much going on. In terms of the flow of events, they'll look something like this:

1. The user will make a request to the function.
2. The function will send an HTTP request to the Nexmo Messages API.
3. The function will respond with the error or message id from the API.

While the core logic will be around an HTTP request, there will be a bit of setup in regards to the request and response data model.

Within the **$GOPATH**, create a new project with a **main.go** file that contains the following:

```
package main

var NEXMO_API_KEY string = "API_KEY_HERE"
var NEXMO_API_SECRET string = "API_SECRET_HERE"

func main() {}
```

Both the API key and the API secret can be obtained from within the Nexmo developer portal.

Since this is going to be an AWS Lambda project, the Go SDK for Lambda must be installed. From the command line, execute the following:

```
go get github.com/aws/aws-lambda-go/lambda
```

With the SDK installed through the Go package manager, it can be used within the project. To use it within the project, we can make the following changes:

```
package main

import "github.com/aws/aws-lambda-go/lambda"

var NEXMO_API_KEY string = "API_KEY_HERE"
var NEXMO_API_SECRET string = "API_SECRET_HERE"

func Handler() {}

func main() {
    lambda.Start(Handler)
}
```

As you can probably suspect, all of our messaging logic will appear in the `Handler` function since that is what will be executed when the client makes a Lambda request.

Before we get into the logic, we need to define some data models for the various requests and responses. Go requires that we explicitly define our data models through `struct` variables so that JSON can be properly marshaled between requests.

Add the following to the **main.go** file:

```
type NexmoMessageContent struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

type NexmoMessage struct {
	Content NexmoMessageContent `json:"content"`
}

type NexmoMessageService struct {
	Type   string `json:"type"`
	Number string `json:"number"`
}

type NexmoMessagesRequest struct {
	From    NexmoMessageService `json:"from"`
	To      NexmoMessageService `json:"to"`
	Message NexmoMessage        `json:"message"`
}

type NexmoMessagesResponse struct {
	Id string `json:"message_uuid"`
}
```

If you've ever used the Nexmo Messages API, you'll be familiar with the JSON that is expected to be sent with every request to the API. The above data structures represent the data that will be sent. With the JSON annotations in place, the JSON would look something like this:

```
{
    "from": { "type": "sms", "number": "SENDER_NUMBER_HERE" },
    "to": { "type": "sms", "number": "RECIPIENT_NUMBER_HERE" },
    "message": {
        "content": {
            "type": "text",
            "text": "Hello World"
        }
    }
}
```

When sending a request to the Nexmo Messages API, a response with a UUID will be returned if it was successful. We've written a `NexmoMessagesResponse` struct which holds this data and plan to send it back to the client.

The only thing we're missing now is the request that the client will be making to the Lambda function. If our example is trying to mimic the Google Cloud Functions example, we are expecting a recipient phone number and the mobile platform they are using.

With this information in mind, we can create a data structure that looks like the following:

```
type LambdaRequest struct {
	Platform  string `json:"platform"`
	Recipient string `json:"recipient"`
}
```

With all the data models crafted, we can focus the rest of our effort on making the messaging request.

Making HTTP requests in Go isn't a difficult process. I explained a few of the approaches in-depth, in a previous tutorial that I wrote titled [Consume RESTful API Endpoints within a Golang Application](https://www.thepolyglotdeveloper.com/2017/07/consume-restful-api-endpoints-golang-application/), although my personal choice would be to use a Go `http.Client` structure. In this particular example, we're going to need to make a POST request as outlined in the [Nexmo documentation](https://nexmo.developer.com).

Let's start by creating a `SendMessage` function which will essentially build a request like that of Nexmo's many cURL examples:

```
func SendMessage(body map[string]string) (NexmoMessagesResponse, error) {
	nexmoMessagesRequest := &NexmoMessagesRequest{
		From: NexmoMessageService{
			Type:   "sms",
			Number: body["from"],
		},
		To: NexmoMessageService{
			Type:   "sms",
			Number: body["to"],
		},
		Message: NexmoMessage{
			Content: NexmoMessageContent{
				Type: "text",
				Text: body["message"],
			},
		},
	}
	bodyData, _ := json.Marshal(nexmoMessagesRequest)
	request, _ := http.NewRequest("POST", "https://api.nexmo.com/v0.1/messages", bytes.NewBuffer(bodyData))
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")
	request.Header.Set("Authorization", "Basic "+base64.StdEncoding.EncodeToString([]byte(NEXMO_API_KEY+":"+NEXMO_API_SECRET)))
	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return NexmoMessagesResponse{}, err
	} else {
		data, _ := ioutil.ReadAll(response.Body)
		var result NexmoMessagesResponse
		json.Unmarshal(data, &result)
		return result, nil
	}
}
```

The above function will take a `map[string]string` and return a `NexmoMessagesResponse` or an error. The first part of the function takes data from the map and constructs an object that will be marshaled into JSON. When it comes to constructing the HTTP request, the object is used as the body and various headers are defined, one of which is an authorization header.

With Nexmo a JSON Web Token (JWT) can be used or the API key and API secret. In this example, the API key and API secret will be used.

The `SendMessage` function is most of the work done.

Since we're using the AWS Lambda SDK for Go and we have a `Handler` function, the next step is to define what's in the `Handler` function. It should look something like this:

```
func Handler(request LambdaRequest) (NexmoMessagesResponse, error) {
	return SendMessage(
		map[string]string{
			"from":    "15404161937",
			"to":      request.Recipient,
			"message": request.Platform,
		},
	)
}
```

Remember, the client accessing our API should be providing the platform and recipient information. Remember, they need to define what mobile platform they are using and the phone number the SMS message should be sent to.

If you can believe it, the AWS Lambda function is complete. When triggered with the appropriate recipient and platform information, the SMS message will be sent and the id of the message will be returned.

Next, we need to get the function into AWS Lambda and make the function accessible as part of standard HTTP requests, typical in an API.

## Configuring AWS Lambda and AWS API Gateway as a Scalable Web API

Before we even get into the AWS portal, we should probably build our Go project. From the command line, while in the project path, execute the following:

```
GOOS=linux go build
```

AWS requires our application to be compatible with Linux. Lucky for us, Go ships with all the correct tool-chains to cross-compile. For more information on cross-compiling with Go, check out my [previous tutorial](https://www.thepolyglotdeveloper.com/2017/04/cross-compiling-golang-applications-raspberry-pi/) on the subject.

As part of a Lambda requirement, the binary must be zipped. Take note of the file name and add it to a ZIP archive at the root of the archive. The filename of the binary represents the handler’s name.

Next, jump into the [AWS Developer Console](https://aws.amazon.com) and choose to create a new Lambda function. The name isn't too important, just make sure it is using the Go runtime.

![AWS Developer Console](https://www.nexmo.com/wp-content/uploads/2019/11/aws-lambda-1.png "AWS Developer Console")

Inside the dashboard for the particular function, choose to upload the ZIP archive that you have just just created. Remember to supply the correct filename for the handler information.

We’re also going to want to add API Gateway as a trigger for the function.

Enter the API Gateway part of the AWS Developer Console. This is where a public endpoint will be created to point to the function. Within the dashboard for the API Gateway, choose **Create Method** within the **Resources** tab.

![Create Method](https://www.nexmo.com/wp-content/uploads/2019/11/api-gateway-create-method-1.png "Create Method")


The method created should be a POST request and it should reference the ARN value of the AWS Lambda function when asked. When finished, don't forget to deploy the API through the same menu as creating a new method.

At this point, the Lambda function should be reachable through the API Gateway that was configured. We can obtain the URL through the **Stages** tab if a custom domain isn’t configured.

## Conclusion

We just saw how to send messages to mobile devices using AWS Lambda and the Go programming language. To sum it up, if a user were to make a request to the API, managed with API Gateway, the request would flow to AWS Lambda, be sent to Nexmo, and then be sent to the user’s device. A use case, as previously mentioned, might be to send the app store link, whether it be Google Play or iTunes, to the user's phone through SMS.

While not explored in this example, we can easily add to this project by creating a front-end for your users to engage with rather than having strictly a RESTful API.