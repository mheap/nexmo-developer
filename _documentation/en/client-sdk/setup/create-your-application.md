---
title: Create your application
description: This topic shows you how to create a Vonage application, users and tokens.
navigation_weight: 1
---

# Create your application, users and tokens

In order to use the Client SDK, there are three things you need to set up before getting started:

* [Vonage Application](/application/overview) - an Application which contains configuration for the app that you are building.

* [Users](/conversation/concepts/user) - Users who are associated with the Vonage Application. It is expected that Users will have a one-to-one mapping with your own authentication system.

* [JSON Web Tokens, JWTs](https://jwt.io/) - Client SDK uses JWTs for authentication. In order for a user to log in and use the SDK functionality, you need to provide a JWT per user. JWTs contain all the information the Vonage platform needs to authenticate requests, as well as information such as the associated Applications, Users and permissions.

All of these may be [created by your backend](/conversation/overview). 
If you wish to get started and experience using the SDK without any implementation of your backend, this tutorial will show you how to do so, using the [Vonage CLI](https://github.com/vonage/vonage-cli).

## Prerequisites

Make sure you have the following:

* A Vonage account - [sign up](https://dashboard.nexmo.com)
* [Node.JS](https://nodejs.org/en/download/) and NPM installed
* Install the Vonage CLI.

To install the Vonage CLI, run the following command in a terminal:

```bash
npm install -g @vonage/cli @vonage/cli-plugin-conversations
```

Set up the Vonage CLI to use your Vonage API Key and API Secret. You can get these from the [settings page](https://dashboard.nexmo.com/settings) in the Vonage Dashboard.

Run the following command in a terminal, while replacing `API_KEY` and `API_SECRET` with your Vonage API key and secret:

```bash
vonage config:set --apiKey=API_KEY --apiSecret=API_SECRET
```

## Create a Vonage Application

You now need to create a Vonage application. In this example you create an application capable of handling both in-app Voice and in-app Messaging use cases.

1) First create your project directory if you've not already done so.

2) Change into the project directory you've now created.

3) Use the following command to create a Vonage application with Voice and WebRTC capabilities. Replace the webhook URLs with your own. If your platform restricts the inbound traffic it can receive using IP address-ranges you'll need to add the [Vonage IP addresses](https://help.nexmo.com/hc/en-us/articles/360035471331) to your allow list. The IP addresses can be fetched programmatically by sending a GET request to `https://api.nexmo.com/ips-v4`.

``` shell
vonage apps:create "My Sample App" --voice_answer_url=https://example.com/webhooks/answer --voice_event_url=https://example.com/webhooks/event --rtc_event_url=https://example.com/webhooks/rtc
```

The application is then created.

The file `vonage_app.json` is created in your project directory. This file contains the Vonage Application ID and the private key. A private key file `my_sample_app.key` is also created.

Creating an application and application capabilities are covered in detail in the [documentation](/application/overview).

## Create a User

Create a User who will log in to Vonage Client and participate in the SDK functionality: Conversations, Calls and so on.

Run the following command in your terminal to create a user named Alice: 

```bash
vonage apps:users:create Alice
```

The output with the user ID, is similar to:

```sh
User ID: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

The user ID is used to perform tasks by the SDK, such as login, starting a call and more.

## Generate a User JWT

[JWTs](https://jwt.io) are used to authenticate a user into the Client SDK.

To generate a JWT for Alice run the following command, remembering to replace the `MY_APP_ID` variable with the value that suits your application:

```bash
vonage jwt --key_file=./my_sample_app.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' --subject=Alice --app_id=MY_APP_ID
```

The above command sets the expiry of the JWT to one day from now, which is the maximum amount of time. You may change the expiration to a shortened amount of time, or regenerate a JWT for the user after the current JWT has expired.

> **NOTE**: In production apps, it is expected that your backend will expose an endpoint that generates JWT per your client request.

## Further information

* [More about JWTs and ACLs](/conversation/guides/jwt-acl)
* [In-app Voice tutorial](/client-sdk/tutorials/app-to-phone/introduction)
* [In-app Messaging tutorial](/client-sdk/tutorials/in-app-messaging/introduction)
