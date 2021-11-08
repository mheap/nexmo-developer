---
title: Create a Voice Application
description: Configure a Vonage Application to receive inbound calls
---

# Create a Voice API application

Use the Vonage CLI to create a Voice API application with the webhooks that will be responsible for answering a call on your Vonage number (`/webhooks/answer`) and logging call events (`/webhooks/events`), respectively.

These webhooks need to be accessible by Vonage's servers, so in this tutorial you will use `ngrok` to expose your local development environment to the public Internet. [This blog post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) explains how to install and run `ngrok`.

Run `ngrok` using the following command:

```sh
ngrok http 3000
```

Make a note of the temporary host name that `ngrok` provides and use it in place of `example.com` in the following command:

```sh
vonage apps:create "My Echo Server" https://example.com/webhooks/answer https://example.com/webhooks/events
```

The command returns an application ID (which you should make a note of) and your public key information (which you can safely ignore for the purposes of this tutorial).

Use the CLI to create a Voice API Application that contains configuration details for the application you are building. These include:

* Your Vonage virtual number
* The following [webhook](/concepts/guides/webhooks) endpoints:
  * **Answer webhook**: The endpoint that Vonage makes a request to when your Vonage number receives an inbound call
  * **Event webhook**: The endpoint that Vonage uses to notify your application about call state changes or errors

> **Note**: Your webhooks must be accessible over the public Internet. Consider using [ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) for testing purposes. If you do use `ngrok`, run it now on port 3000 using `ngrok http 3000` to get the temporary URLs that ngrok provides and leave it running for the duration of this tutorial to prevent the URLs from changing.

Replace `example.com` in the following command with your own public-facing URL or `ngrok` host name. Run it in the root of your application directory. This returns an application ID and downloads the authentication details in a file called `call_transcription.key`.

```sh
vonage apps:create "Call Transcription" --voice_answer_url=https://example.com/webhooks/answer --voice_event_url=https://example.com/webhooks/events
```

Make a note of the Application ID and the location of the `call_transcription.key` file. You will need these in later steps.