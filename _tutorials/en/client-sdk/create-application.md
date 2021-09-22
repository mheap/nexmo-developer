---
title: Create a Vonage Application
description: In this step you learn how to create a Vonage Application.
---

# Create your Vonage application

You now need to create a Vonage [Application](/conversation/concepts/application). In this step you create an application capable of handling both in-app Voice and in-app Messaging use cases.

**1.** Create your project directory if you've not already done so, run the following command in your terminal:

``` shell
mkdir vonage-tutorial
```

**2.** Change into the project directory.

``` shell
cd vonage-tutorial
```

**3.** Create a Vonage application [interactively](/application/vonage-cli#interactive-mode). The following command enters interactive mode:

``` shell
vonage apps:create
```

**4.** Specify your application name. Press Enter to continue.

**5.** You can now select your application capabilities using the arrow keys and then pressing spacebar to select the 
capabilities your application needs. For the purposes of this example select both Voice and RTC capabilities using the arrow keys and spacebar to select. Once you have selected both Voice and RTC capabilities press Enter to continue.

> **NOTE:** If your application will be in-app voice only you can select Voice capabilities only. If you want in-app messaging select only RTC capabilities. If your app will have both in-app voice and in-app messaging select both capabilities.

**6.** For "Create voice webhooks?" press Y to select yes.

**7.** For "Answer webhook" enter `https://example.ngrok.io/webhooks/answer` or other suitable URL (this depends on how you are testing). Set the HTTP method to default.

**8.** You are now required to enter the "Voice Event URL". Enter `https://example.ngrok.io/webhooks/event`. Set the HTTP method to default.

**9.** For "Event Webhook" enter `https://example.ngrok.io/webhooks/rtc`, and set the HTTP method to the default. 

**10.** For "Allow the use of data for AI training" you can select Y or N. 

A file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID, name and the private key. A private key file named `your_app_name.key` is also created.

**Please make a note of it as you'll need it in the future.**

![](/screenshots/tutorials/client-sdk/nexmo-application-created.png)

> **NOTE:** For more details on how to create an application and various available application capabilities please see our [documentation](/application/overview).

> **NOTE:** You can also obtain information about your application, including the Application ID, in the [Dashboard](https://dashboard.nexmo.com/voice/your-applications).
