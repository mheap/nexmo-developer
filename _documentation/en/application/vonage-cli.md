---
title: Vonage CLI
meta_title: Vonage Command Line Interface (CLI
Description: The Vonage CLI can be used to create and manage applications.
navigation_weight: 2
---

# Managing applications with the Vonage CLI

The Vonage CLI allows you to create and manage your Vonage applications. To obtain help type `vonage` once the CLI has been installed.

## Installation

The  CLI can be installed with the following command:

```shell
npm install -g @vonage/cli
```

The core CLI includes everything to support Application API V2 on the command line. You can check your installed version with the command:

```shell
vonage --version
vonage -v
```

For additional help on any feature in the CLI, you can use the help flag:

```shell
vonage --help
vonage apps -h
```

## Setting your configuration

Before you can start working with your apps, you will need to set your configuration (API Key and API Secret). This can be done using the `config:set` command:

```shell
vonage config:set --apiKey=XXXXXX --apiSecret=XXXXXX
```

Your API Key and API Secret can be obtained via the [Dashboard](https://dashboard.nexmo.com). Once set, you can check your config by running `vonage config`.

## Listing your applications

To list your current applications use:

```shell
vonage apps
```

This displays a list showing the application ID, name and capabilities.

## Show application details

To show the details of a specific application (where the `APP_ID` is the application  ID of an application that already exists):

```shell
vonage apps:show APP_ID
```

Returns something like:

```shell
Application Name: glorious_falcon

Application ID: d4bb...7180c

Voice Settings
   Event Webhook:
      Address: https://example.com/webhook_name
      HTTP Method: POST
   Answer Webhook:
      Address: https://example.com/webhook_name
      HTTP Method: POST

Messages Settings
   Inbound Webhook:
      Address: https://example.com/webhook_name
      HTTP Method: POST
   Status Webhook:
      Address: https://example.com/webhook_name
      HTTP Method: POST

RTC Settings
   Event Webhook:
      Address: https://www.sample.com/webhook/rtc_event_url
      HTTP Method: POST

VBC Settings
Enabled

Public Key
-----BEGIN PUBLIC KEY-----
MIIBI.....
-----END PUBLIC KEY-----
```

## Creating an application

### Interactive mode

First create a new directory for your application and change into it. You can then create an application in **interactive mode** using the command:

```shell
vonage apps:create
```

This will present a series of prompts, requesting the necessary information to create your application. Sensible defaults are provided at each prompt.

### Script mode

In any environment where the Vonage CLI is installed, you can also use it in a script.  The only required argument is the application `name`.


```shell
vonage apps:create "Test Application 1" --voice_event_url=http://example.com/webhooks/event --voice_answer_url=http://example.com/webhooks/answer --rtc_event_url=http://example.com/webhooks/rtcevent
```

This creates the `vonage_app.json` file in your project directory containing the Application ID, Application name and private key. This also creates a second file with the private key named `app_name.key`.

Note that the webhook URLs you are required to set depends on the capabilities you want to use in your application. This is explained in more detail in the [application webhooks](/application/overview#webhooks) topic.

## Creating an application with your own public/private key pair

You can create an application with your own public key if you have a suitable public/private key pair already.

First you need a suitable public/private key pair. To create one, first enter:

```shell
ssh-keygen -t rsa -b 4096 -m PEM -f private.key
```

Press enter (twice) to not use a passphrase. This generates your private key, `private.key`.

Then enter the following:

```shell
openssl rsa -in private.key -pubout -outform PEM -out public.key.pub
```

This generates `public.key.pub`. This is the public key you use in creating or updating your Vonage application:

```shell
vonage apps:create "Application with Public Key" --public_keyfile=public.key.pub
```

## Updating an application

You can patch/update a previously created application with a command similar to:

```shell
vonage apps:update [APP_ID] --voice_event_url=http://example.com/webhooks/event --voice_answer_url=http://example.com/webhooks/answer --rtc_event_url=http://example.com/webhooks/rtcevent
```

You can change the application name, modify any of the webhooks, or add new capabilities. If you don't provide the `APP_ID` argument, it will use interactive mode.

## Deleting an application

You can delete an application with the following command:

```shell
vonage apps:delete APP_ID
```

When providing the `APP_ID` argument, it is assumed that you understand you are deleting and there is no confirmation.

### Interactive Mode

The CLI also provides an interactive method of deletion, which allows for singular or multiple app deletion:

```shell
vonage apps:delete
```
You will need to confirm this action.

> **NOTE:** Deletion cannot be reversed.

## Reference

* [Vonage CLI GitHub repository](https://github.com/vonage/vonage-cli)
