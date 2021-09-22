---
title: Create a Vonage Application
description: In this step you learn how to create a Vonage Application.
---

# Create your Vonage Application

In this step you will create a Vonage [Application](/conversation/concepts/application) capable of in-app Chat communication use cases.

> **NOTE:** This is the Vonage application project that allows client application to use Vonage backend.

**1.** Create your project directory if you've not already done so, run the following command in your terminal:

``` shell
mkdir vonage-tutorial
```

**2.** Change into the project directory.

``` shell
cd vonage-tutorial
```

**3.** Create a Vonage application by copying and pasting the command below into terminal.

``` shell
vonage apps:create "App to App Chat Tutorial" --rtc_event_url=https://example.com/
```

A file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `app-to-app-chat-tutorial.key` is also created.

Make a note of the Application ID that is echoed in your terminal when your application is created:

![](/screenshots/tutorials/client-sdk/nexmo-application-created.png)

> **NOTE:** An application can be also created using the CLI's [interactive mode](/application/vonage-cli#interactive-mode).

> **NOTE:** For more details on how to create an application and various available application capabilities please see our [documentation](/application/overview).

> **NOTE:** You can also obtain information about your application, including the Application ID, in the [Dashboard](https://dashboard.nexmo.com/voice/your-applications).
