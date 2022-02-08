---
title: How to Get an SMS Delivery Receipt in ASP .NET MVC
description: Receive SMS delivery receipts using ASP.NET MVC and Nexmo's SMS
  API. Confirm that your most important messages have been successfully
  delivered
thumbnail: /content/blog/get-sms-delivery-receipt-asp-net-mvc-dr/sms-dlr-net.png
author: bibi
published: true
published_at: 2017-07-21T15:54:50.000Z
updated_at: 2021-05-18T08:42:26.053Z
category: tutorial
tags:
  - asp.net
  - sms-api
comments: true
redirect: ""
canonical: ""
---
Now that you have successfully [sent an SMS](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/) and [received an SMS](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/) using your Vonage number, it’s time to check the status of the message to ensure it was delivered. To do this, we have to fetch the delivery receipt, which will return the delivery status of the message.

## Requirements

* A Visual Studio project
* A project set up as described in the previous [blog post](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/) in this tutorial series which you can find on [GitHub.](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/SMSRecieveStarterProject)
* Optional: [Vonage CLI](https://github.com/Vonage/vonage-cli)

<sign-up number></sign-up>

## Receive webhooks on your localhost

The Vonage SMS API uses webhooks to inform the ASP.NET app of the status of the sent text message. As explained in the [previous tutorial](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/), we will be using [ngrok to expose the port to the internet](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) so Vonage’s servers can connect to it while testing.

![Example of Ngrok running](/content/blog/how-to-get-an-sms-delivery-receipt-in-asp-net-mvc/image_0.png)

Go back to Visual Studio and run your program, then head over to the [Vonage Dashboard](https://dashboard.nexmo.com/). On the **Settings** page, towards the bottom, you will see **Callback for Delivery Receipt** under the **API Settings**. Paste the ngrok URL inside the textbox and add **/SMS/DLR** to the end of it. This will route the message to the Receive action in the SMS controller.

![Configuring Nexmo webhooks](/content/blog/how-to-get-an-sms-delivery-receipt-in-asp-net-mvc/image_1.png)

## Diving into code

In this tutorial series, we started by learning how to send an SMS.

In this [first tutorial](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr), we created an ASP.NET MVC project and added a controller called `SMSController.cs`. Afterwards, we created two action methods. One of which was to present the view for the details of the SMS (destination number and message text) and the other was to retrieve the values from the form and send an SMS.

In the [second tutorial](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr), we created another action method to print the details of incoming SMS message to the output window.

In order to read the delivery receipt, we will create an action method called **DLR** in the `SMSController.cs`.

![Code example receiving DLR](/content/blog/how-to-get-an-sms-delivery-receipt-in-asp-net-mvc/image_2.png)

As you can see in the code above, you need to add **\[FromUri]** in the parameter to be able to read the delivery receipt. Above this method, add a **HTTPGetAttribute** to restrict the method to handling GET requests. Print the messageID (**message ID**), msisdn (**Vonage virtual number**), to (**destination number**), and the status (**status message**) to the output window using ‘Debug.WriteLine’.
You can [check the list of status codes here](https://developer.nexmo.com/api/sms#delivery-receipt).

Now you are ready to go! Send an SMS using your Vonage virtual number and open up the output window in Visual Studio. There you should see the delivery receipt for the text you have sent! You have now successfully setup your virtual number to return a status for a text message via a webhook!

![Example output of a DLR](/content/blog/how-to-get-an-sms-delivery-receipt-in-asp-net-mvc/image_3.png)

## Helpful links

* [Vonage .NET code snippets](https://github.com/Vonage/vonage-dotnet-code-snippets)
* [Vonage SMS REST API](https://developer.vonage.com/messaging/sms/overview)
* [Nexmo C# Client Library](https://github.com/Nexmo/nexmo-dotnet)