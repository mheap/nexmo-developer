---
title: Sending Group Notifications with Google Sheets and Node-RED
description: Send SMS notifications programmatically using Node-RED, the Google
  Sheets API and the Vonage SMS API.
thumbnail: /content/blog/sms-notifications-google-sheets-nodered-dr/Blog_Group-Notifications_NodeRED_1200x600.png
author: julia
published: true
published_at: 2020-03-06T13:16:53.000Z
updated_at: 2021-05-24T16:44:46.195Z
category: tutorial
tags:
  - node-red
  - sms-api
  - google
comments: true
redirect: ""
canonical: ""
---
Ever got a phone call at 7:59 AM telling you your kid's school is closed? It was handy, as you were only a couple miles away - on your way home, after dropping them off.  

The announcement process in most schools is still manual nowadays, which works in most cases. When something unexpected happens though, like the school is snowed in, a handful of people scramble to call hundreds of parents. You might get the notification in time, or you could be part of the lucky bunch that ended up in the last batch at 7:59.

In this tutorial we're going to build a Node-RED flow that programmatically sends out notifications to a list of contacts, using Google Sheets and the Vonage SMS API.  

Follow along and pitch it to the principal? Saves you being stuck in traffic on a snow day.

## Prerequisites

Before getting started, you’ll need a few things: 

* A [Node-RED](https://nodered.org/docs/getting-started/installation) installation, be it a hosted version or on your machine
* A [Google account](https://myaccount.google.com/)
* A Vonage account
* A way to expose your server to the internet. This either means you're running a hosted version of Node-RED or using a tunneling service like [ngrok](https://flows.nodered.org/node/node-red-contrib-ngrok) - get up to speed with this [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) tutorial

<sign-up></sign-up>

## Setting Up Your Editor

Once you open your Node-RED Editor, make sure you have the following packages installed:

* [node-red-contrib-google-sheets](http://flows.nodered.org/node/node-red-contrib-google-sheets)
* [node-red-contrib-nexmo](https://flows.nodered.org/node/node-red-contrib-nexmo)  

To do this, click on the hamburger menu, select *Manage Palette*. Check for already installed packages under *Nodes*, and get new ones from the *Install* tab.

When you're done, make sure to restart Node-RED and you're good to go!

## Configuring Your Google Account

To interact with the *Google Sheets API*, you'll need to use a service account - an identity that an instance can use to run API requests on your behalf. It will be used to identify apps running on your instance to other Google Cloud services.  

In this case, your flow that reads a Google Sheet must first authenticate to the Google Sheets API.  

You'll have to create a service account and grant it access to the Google Sheets API. Next, update your app to pass the service account credentials to the Google Sheets API. This way, your flow authenticates seamlessly to the API without embedding any secret keys or user credentials.

### Step 1: Create a New Service Account

We'll start by creating a new project on the [Service Accounts Page](https://console.cloud.google.com/projectselector2/iam-admin/serviceaccounts?_ga=2.184919274.-272657095.1578084478&supportedpurview=project) of the Google Cloud Platform. Click on *CREATE* to get started.



![google service accounts create project](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-service-accounts-create-project.png)

Next, give your project a name, either select an organization or leave it blank, then press *CREATE*.



![google service accounts name project](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-service-accounts-name-project.png)

You'll shortly see a notification pop up that your project has been created.



![google service accounts project created](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-service-accounts-project-created.png)

Now that you have a project, let's add a service account to it!



![google create service account](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-create-service-account.png)



![google name service account](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-name-service-account.png)

Next, you'll need to create a key that you'll use to authenticate with the GSheet node in your flow. Click on *Create Key*, then select *JSON* as a key type. Save this file when prompted - keep it handy as you'll need it soon, then hit *Done*.  



![google service accounts create key](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-service-accounts-create-key.png)

### Step 2: Enable Google Sheets API for Your Project

From the hamburger menu select *APIs and Services* -> *Dashboard*, then click the *ENABLE APIS AND SERVICES* button. Look for the *Google Sheets API* in the API Library, open it and click *Enable*.



![google sheets enable api for project](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-sheets-enable-api-for-project.gif)

### Step 3: Sharing Google Sheets with Your Service Account

Go to the *Service Accounts* page and make a note of the email address associated with the service account you've just created. You'll need to use this email address to share your spreadsheets with the Service Account.



![google service accouns email](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-service-accouns-email.png)

## Sending Group Notifications with Google Sheets and Node-RED

### Create a Spreadsheet

In case you don't have a Google Sheet ready, go ahead and create one now.  

Google Sheets use a cell-matrix system, where each column can be identified with a letter (starting with A as the first column) and rows are numbered (1 being the first row). In case you'd like to select the second element of the first row, this would be **B1**.  

You can also select ranges of cells by using the **TOP_LEFTMOST_CELL:BOTTOM_RIGHTMOST_CELL** notation. For example, to select the second and third element of rows 1-5, use **B1:C5**.

After creating a spreadsheet you'll see a *Sheet1* tab at the bottom of the screen, which is the worksheet you're currently one. You can rename it or add more worksheets to your spreadsheet. 

For this tutorial, I'm using one worksheet with 4 columns: Name, Surname, Phone, and Email - you'll need at least 2 rows of data to follow along.\
Make sure you add a phone number you have access to, so that you can test your flow later on.

Once your spreadsheet is ready, it's time to share it with your Service Account.  



![google sheets share google sheet](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-share-google-sheet.png)

### Getting the Data from Your Google Sheet

Start your flow by adding a **GSheet** node to your workspace. Configure this node to pull in the data from your Google Sheet by filling out the following fields accordingly:  

| PARAMETERS        | DESCRIPTION                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Creds**         | Press the edit button to provide your Service Account key. Remember the JSON file you downloaded earlier? Copy and paste this JSON key in the text field.                                                                                                                                                                                                                                                                                             |
| **Method**        | Select *Get Cells* from the drop-down menu. This will grab the data from the Google Sheet and pull it into your flow.                                                                                                                                                                                                                                                                                                                                 |
| **SpreadsheetID** | You can figure out your spreadsheet ID from the URL of your Google Sheet. For example, if the URL is *https://docs.google.com/spreadsheets/d/1mmXhj40aeSooxmtku3ma4auLyrHhO8xCSQsklZ1_BU/edit#gid=0*, the SpreadsheetID will be the string found in between `d/` and `/edit`:  *1mmXhj40aeSooxmtku3ma4auLyrHhO8xCSQsklZ1_BU*. Have a look at your spreadsheet URL and find your SpreadSheetID. Then paste this string in the **SpreadSheetID** field. |
| **Cells**         | Select the cells where your data is located on the spreadsheet. In the example below, this value will be: `Sheet1!A2:D30`, as the data is found on the worksheet named "Sheet1", in columns A-D on rows 2-30. Note that we're not including the table headers.                                                                                                                                                                                        |

Once you're done editing the **GSheet** node, press *Done*.  



![google sheets node setup](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-sheets-node-setup.gif)

Next, let's have a look at the data we're getting from the Google Sheets API.  

Add an **inject** and a **debug** node to your workspace and connect them to the **GSheet** one. Hit *Deploy*, click on the **inject** node's button, then have a look at your debug sidebar.



![google sheets node](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-sheet-node.png)

You'll notice that the response in **msg.payload** is an array of arrays, each of these arrays having 4 elements - one line worth of data. 

#### Split the msg.payload Array

This data structure isn't ideal for further processing, so let's split the array of arrays into individual arrays.  

Fortunately, there is a default node already in your palette that will do the heavy lifting for you.  

Find the **split** node under *sequence* in your node palette o the left side of your screen. Add it to your workspace, connect it after the **GSheet** node, follow with a **debug**, then press *Deploy* and run your flow again.

Glance over to the debug sidebar and notice the response coming through as a sequence of individual arrays. This way we can process them one at a time, as they are coming in.



![google sheets sms split node](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-sms-split-node.png)

#### Set Delay

In most cases, you wouldn't want to send out messages at this speed, be it via email, SMS or the channel of your choice.

For example, the Vonage SMS API has a [throughput limit](https://help.nexmo.com/hc/en-us/articles/203993598-What-is-the-Throughput-Limit-for-Outbound-SMS-) for outbound SMS - all API keys are set with 30 API request per second throughput restriction by default. On top of this, there are also restrictions when sending from certain numbers, so you might be restricted to 1 SMS per second. 

To make sure you're not reaching the throughput limits, it's a good idea to set a delay on each array coming through **msg.payload**.  

To do this, find the **delay** node in the *function* section of your node palette, and connect it after the **split** node. Double-click on it to open up the node properties and set the delay to 1 second - this should cover most use cases, but feel free to adjust it as needed. 

### Preparing the Message

At this point, we have all the information we need about the recipients, so let's move on to the message!

Although you could send the same message to all recipients, it's always a good idea to make it a little more personal. Getting the bad news is frustrating enough, and a bad user experience won't make it any better.  

Adding a bit of templating won't only give your message a personal touch, it will also make it appear more professional.

Add a **template** node after **delay**. Double-click on it, set *Property* to **msg.text** and get creative with your message in the text field!

This text field supports [Mustache templating](https://mustache.github.io/), so you could start with greeting the recipient using their name: `{{payload.0}}`. This expression references the first element of the **msg.payload** array, the recipient's first name.



![google sheets sms template node](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-sms-template-node.png)

When you're done editing, press *Done*, then *Deploy*.

### Sending SMS Notifications

There are many channels available to deliver your notifications, but in bad weather conditions SMS might be your best bet, so we'll start with this option.

To send the SMS messages, we'll use the Vonage [SMS API](https://developer.nexmo.com/api/sms).  

Scroll down to the *nexmo* section of your node palette and add **sendsms** to your workspace, connected after the **template** node.

Set up this node by double-clicking on it and filling in the parameters below. You'll find *API KEY* and *API SECRET* by clicking on the edit button next to *Vonage Credentials*. 

| KEY            | DESCRIPTION                                                                                                                                                                                                                   |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **API KEY**    | Your Vonage API key, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).                                                                                                                     |
| **API SECRET** | Your Vonage API secret, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).                                                                                                                  |
| **TO**         | The number you are sending the SMS to, `{{msg.payload.2}}` in this case.                                                                                                                                                      |
| **FROM**       | The number or text shown on a handset when it displays your message. You can also set a custom alphanumeric FROM value if this feature is [supported in your country](https://help.nexmo.com/hc/en-us/articles/115011781468). |
| **TEXT**       | The content of your message. Use `{{msg.text}}` to reference the templated message you've created earlier.                                                                                                                    |

Make sure *Unicode* is ticked to keep the formatting of your message, then press *Done* and *Deploy*.



![google sheets send sms node setup](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-sendsms-node-setup.png)

Run your flow again and see your templated messages appear in the debug sidebar.



![google sheets templated sms in debug](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-templated-sms-debug.png)

### Delivery Receipts

When you make a successful request to the SMS API, it returns an array of message objects. Ideally, each of these has a status of 0, indicating that your message has successfully been scheduled for sending. These are the response objects that you've just seen in the debug area.

While inspecting this output is quite helpful in determining what the Vonage SMS API did, there is no guarantee that the message reached the recipient's handset. Not exactly what you want to hear while sending out snow day alerts, is it?

Once the message reaches its destination, the carrier returns a **[Delivery Receipt](https://developer.nexmo.com/messaging/sms/guides/delivery-receipts)** to Vonage – so don't panic! All you need to do is set up a webhook endpoint that Vonage can forward these **Delivery Receipts** to. 

Connect a **http** input node to a **http response** node, as well as to a **debug** node, then fill in the *URL* field with `/receipt` in the **http** input node.

Next, you'll have to let the Vonage SMS API know where it should forward the delivery receipts. Go to your [API settings](https://dashboard.nexmo.com/settings) in the **Default SMS Setting** section.
Set the default webhook URL for delivery receipts to `YOUR_URL/receipt`, then *Save changes*.



![default sms settings nexmo dashboard](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/default-sms-settings-nexmo-dashboard.png)

Now you can rest assured that your snow day notifications have indeed reached everyone on your list! Don't take my word for it though, head over to the debug sidebar and read through your delivery receipts.



![google sheets sms event webhook](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/gsheets-sms-event-webhook.png)

## Where Next?

### Extra Credit: Write Your Delivery Receipts to the Google Sheet

Although the debug sidebar gives you all the insight you'll ever need, sometimes it's easier to grasp the result if the data is presented in a more organized fashion.

In this section, we'll look into writing your delivery receipts back to the same spreadsheet, on a different worksheet(tab).  

#### Pick Your Data

The delivery receipts will contain the following properties of the **msg.payload** object:

| PROPERTY          | DESCRIPTION                                                                                                                                                                                                          |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| msisdn            | The number the message was sent to.                                                                                                                                                                                  |
| to                | Your Vonage number or the SenderID you've set when sending the SMS.                                                                                                                                                  |
| network-code      | The Mobile Country Code Mobile Network Code (MCCMNC) of the carrier the destination phone number is registered with.                                                                                                 |
| messageId         | The Vonage ID for this message.                                                                                                                                                                                      |
| price             | The cost of this message.                                                                                                                                                                                            |
| status            | Will be one of: *delivered*, *expired*, *failed*, *rejected*, *accepted*, *buffered* or *unknown*, based on where the message is in the delivery process.                                                            |
| scts              | When the delivery receipt was received from the carrier in *YYMMDDHHMM* format. For example, 2001011400 is at 2020-01-01 14:00                                                                                       |
| err-code          | The status of the request. Will be a non 0 value in case of an error. See the [Delivery Receipt documentation](https://developer.nexmo.com/messaging/sms/guides/delivery-receipts#dlr-error-codes) for more details. |
| api-key           | Your Vonage API key.                                                                                                                                                                                                 |
| message-timestamp | The time when Vonage started to push this Delivery Receipt to your webhook endpoint.                                                                                                                                 |

Decide on which of these parameters matter to you, then using a **change** node, set **msg.payload** to an array of the respective properties.  

For example, I'm interested in the timestamp, recipient's number, status, error code and message ID, so I'll set **msg.payload** to the following *expression*:  

```
[payload.\`message-timestamp\`, payload.msisdn, payload.status, payload.\`err-code\`, payload.messageId]
```

Connect this **change** node into the **/receipt** webhook, then follow with a **GSheet** node.

#### Write Your Data to the Google Sheet

Add another worksheet(tab) to your Google Sheet and make a note of its name - will be "Sheet2" by default.

Next, head back over to your Node-RED editor and open up the **GSheet** node properties. Select your credentials from the *creds* drop-down, select **Append Row** as a *Method*, fill in your *SpreadsheetID*, then specify the cell range where you'd like the data to be written. In my case this will be *Sheet2!A:E*, as I'd like the data to be spread accross columns A-E on worksheet "Sheet2".



![google sheets append row setup](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-sheets-append-row-setup.png)

When you're ready, click *Done* and *Deploy*, then run your flow again.

🎉Congratulations! Your Delivery Receipts have now been logged onto the second worksheet of your spreadsheet. Head over to your Google Sheet and check them out!



![google sheets delivery receipts logged](/content/blog/sending-group-notifications-with-google-sheets-and-node-red/google-sheets-delivery-receipts-logged.png)

### Further Hack Ideas

Tired of having to open up your Node-RED Editor to start your flow? Experiment with different ways to kick it off!  

* Try replacing the **inject** node with an [inbound SMS](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/) webhook. Send an SMS to your Vonage number to achieve your task!
* [Inbound calls](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/) would be another great option! You could even build on it and set up an [Interactive Voice Response Menu](https://www.nexmo.com/blog/2020/01/08/interactive-voice-response-node-red-dr)
* Set up a user interface using the [dashboard nodes](https://flows.nodered.org/node/node-red-dashboard)

### Resources

* [SMS API Reference](https://developer.nexmo.com/api/sms)
* [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/)
* Get a better understanding of [delivery receipts](https://developer.nexmo.com/messaging/sms/guides/delivery-receipts)
* [Mustache templating](https://mustache.github.io/)
* [JSONata Docs](http://docs.jsonata.org/overview.html)
* [JSONata Exerciser](https://try.jsonata.org/)

### Try Another Tutorial

* [How to Build an IVR using Node-RED and the Nexmo APIs](https://www.nexmo.com/blog/2020/01/08/interactive-voice-response-node-red-dr)
* [Build Your Own Voicemail With Node-RED and the Nexmo Voice API](https://www.nexmo.com/blog/2019/11/14/build-voicemail-node-red-voice-api-dr)
* [Forward a Call via a Voice Proxy with Node-RED](https://www.nexmo.com/blog/2019/10/17/forward-call-via-voice-proxy-node-red-dr)
* [Build a Conference Call with Node-RED](https://www.nexmo.com/blog/2019/10/07/conference-call-node-red-dr)
* [Verify Phone Numbers with Node-RED](https://www.nexmo.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)