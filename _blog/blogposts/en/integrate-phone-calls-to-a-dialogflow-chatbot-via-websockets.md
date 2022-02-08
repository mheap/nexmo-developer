---
title: Integrate Phone Calls to a Dialogflow Chatbot Via WebSockets
description: "This tutorial will help you to start with an example Dialogflow
  bot and interact with it from phone calls using provided sample reference
  codes using Vonage Voice API. "
thumbnail: /content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/dialogflow-bot_voice-call_120x600.png
author: amanda-cavallaro
published: true
published_at: 2021-10-13T09:54:47.863Z
updated_at: 2021-07-26T14:55:40.801Z
category: tutorial
tags:
  - voice-api
  - nodejs
  - dialogflow
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introduction

This tutorial will show you how to make a phone call to a Dialogflow agent using Dialogflow Essentials and a Vonage WebSockets integration. 

The diagram below shows an overview of the architecture.

![Architecture overview showing how the parts are connected](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/highlevel-15.29.19.png "Diagram of the call")

## Pre-requisites

To perform the actions outlined in the following steps, you will need to create:

1. A [Dialogflow account](https://dialogflow.cloud.google.com/) 
2. A [Vonage API Account](https://dashboard.nexmo.com/)

## Create a Dialogflow Agent

Dialogflow is a Software as a Service (SaaS) and a Natural Language Understanding platform used to build conversational user interfaces. 

An agent is a Dialogflow instance, which you can think of as your chatbot application. It allows you to take what the users say, map it to [intents](https://cloud.google.com/dialogflow/es/docs/intents-overview) and provide them with responses. 

### Follow the steps

1. Open the [dialogflow console](https://dialogflow.cloud.google.com/)
2. Create an agent by giving it a name, setting the default language, choosing the timezone, and clicking on the button to create an agent. The button can either be shown as `Create` or `Create Agent`
3. On the menu on the left click on the gear icon
4. Under Google Project, click on the project ID name. For instance, `VonageDF`
   This will take you to the [Google Cloud console](https://console.cloud.google.com/)

![Gif showing the steps to create the dialogflow Agent](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/dialogflow.gif "Gif showing the steps to create the dialogflow Agent")

## Create a Service Account on the Google Cloud Console

We will use the graphical user interface to manage our Google Cloud project and resources via the Google Cloud console using the same project created in Dialogflow. In the following steps, we will create a service account for access control and authentication.

### Follow the steps

1. From the [Google Cloud console](https://console.cloud.google.com/), click on `Go to project settings`
2. On the menu on the left, click on `Service accounts`
3. At the top bar, click on `+ Create Service Account`
4. Give it a Service Account Name you'll remember, for instance `VonageDF`
5. Add a service account description
6. Click on `Create and Continue`
7. Under `Grant this service account access to project`, filter and select the role `Dialogflow API Admin`

![Gif showing the seven above steps while creating the Service Account](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/googlecloud1.gif "Gif showing the seven above steps while creating the Service Account")

You are now taken back to the Service Accounts page

8. Click on the three dots under `action`
9. Click on `Manage keys`
10. Click on `Add Key`
11. Click on `Create new Key`
12. Select `JSON`
13. Click on `Create`
14. You can see one `.json` file was downloaded. We will add this file to the [Dialogflow Reference Connection GitHub repository](https://github.com/nexmo-community/dialogflow-reference-connection) we will clone in the next step

![Gif showing the above steps to generate the keys](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/googlecloud2.gif "Gif showing the above steps to generate the keys")

## Set Up the Dialogflow Reference Connection

The Dialogflow Reference Connection makes use of the [WebSockets feature](https://docs.nexmo.com/voice/voice-api/websockets) of the Vonage Voice API. When a voice call is established, a Voice API application triggers a WebSocket connection to the [Dialogflow-reference-connection](https://github.com/nexmo-community/dialogflow-reference-connection). It streams the audio to and from the voice call in real-time.

In the following steps below, we will give two options as examples. Using ngrok to tunnel the connecting server, which is interacting with our Dialogflow Agent and deploying it Heroku.

### Follow the steps

1. Clone the [dialogflow-reference-connection repository](https://github.com/nexmo-community/dialogflow-reference-connection) from GitHub and change the directory
   `git clone https://github.com/nexmo-community/dialogflow-reference-connection && cd dialogflow-reference-connection` 
2. Open the code in your favorite IDE or text editor
3. Add the `.json` file just downloaded to the root of the project
4. Create a `.env` file from the `.env.example`
5. Populate the environment variables:
   	 `GCLOUD_PROJECT_ID=<TheProjectIdFoundOnDialogflow>`
   	 `GOOGLE_CLOUD_CREDENTIALS=<TheJSONFileYouDownloaded.json>`
   From the terminal:
6. Install the dependencies
   `npm install`
7. Run the file Dialogflow connecting server
   `node df-connecting-server.js` 
   There are many deployment types, such as App Engine, Heroku, Cloud Run.

For this tutorial, we will show examples using the [ngrok](https://ngrok.com) tunneling. [Here's a link explaining more about ngrok](https://developer.nexmo.com/tools/ngrok) and Heroku.

**Option 1: Example with ngrok**

8. Run `ngrok http 5000`
9. Make a note of the URL found in the console (e.g. `xxxx.ngrok.io`). We will add this information in the  `DF_CONNECTING_SERVER` argument of  Set Up the Dialogflow Voice API Sample Application' part of the tutorial

![The ngrok URL highlighted on the Visual Studio Code IDE](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/df_connecting_server.png "The ngrok URL highlighted on the IDE")

**Option 2: Example with Heroku**

12. Install [git](https://git-scm.com/downloads)
13. Install [Heroku command line](https://devcenter.heroku.com/categories/command-line) and login to your Heroku account
14. If you do not yet have a local git repository, create one: `git init`
15. Start by creating this application on Heroku from the command line using the Heroku CLI. Note: In the below command, replace `thisappname` with a unique name on the whole Heroku platform. `heroku create thisappname`
16. On your Heroku dashboard where your application page is shown, click on `Settings` button, add the following `Config Vars` and set them with their respective values:

```bash
GCLOUD_PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS  
```

17. Deploy the application `git push heroku master` or `git push heroku main` depending on your branch name.
18. Make a note of the URL found in the console (e.g. `thisappname.herokuapp.com`). We will add this information in the  `DF_CONNECTING_SERVER` argument of 'Set Up the Dialogflow Voice API Sample Application' part of the tutorial

## Set Up Your Vonage Voice API Application Credentials and Phone Number

   ![An image explaining that to complete this tutorial you need a VONAGE API Account and to purchase a virtual number](https://lh5.googleusercontent.com/sMtzm5Ru-Mi6YwkpuKSn9Y-Da5MSzbKWjlpRTUW7bXSJZYbH1c_OWAxt_5211PAmMvg6ICu-OrmewGa1b5OrBeKfe-bU2aAM13CpjBWvoJLAcFsAW9ACdSCU1TiOCKi7-zTKYlrw)

### Follow the steps

1. Create an Application from the [Vonage API Dashboard](https://dashboard.nexmo.com/)
2. Give the application a name, for instance `VonageDF` 
3. Click on the button to generate a public and private key, a `private.key` file will be downloaded. We will add it to the Dialogflow Voice API Sample Application in the next section of this tutorial
4. Link a phone number to this application. If you do not already have one, on the menu on the left click on `Numbers` and then `Buy Numbers` and follow the steps to purchase it

We will set up the Dialogflow Voice API Sample application and get back to this Vonage application dashboard soon to add more information.

## Set Up the Dialogflow Voice API Sample Application

This sample application uses the Vonage Voice API to answer incoming voice calls and set up a WebSocket connection to stream audio to and from the Dialogflow reference connection for each call.

The [dialogflow reference connection](https://github.com/nexmo-community/dialogflow-reference-connection) code will:

* Send audio to the Dialogflow agent from caller's speech,
* Stream audio responses from the Dialogflow agent to the caller via the WebSocket,
* Post back in real-time transcripts and caller's speech sentiment scores via webhooks callbacks to this [Voice API Sample Application](https://github.com/nexmo-community/dialogflow-sample-voice-application).

Once this application is running, you will call the phone number linked to your application to interact via voice with your Dialogflow agent.

We will use ngrok to tunnel the connecting server which is interacting with our Dialogflow Agent, but if you'd like to see an example using Heroku you can follow the steps from [Dialogflow Voice API Sample Application](https://github.com/nexmo-community/dialogflow-sample-voice-application) from GitHub.

### Follow the steps

1. From your terminal, clone the [Dialogflow Voice API Sample Application](https://github.com/nexmo-community/dialogflow-sample-voice-application) from GitHub and change the directory
    `git clone https://github.com/nexmo-community/dialogflow-sample-voice-application && cd dialogflow-sample-voice-application`
   You can continue to follow the below steps explanation or from the readme file of the [Dialogflow Voice API Sample Application](https://github.com/nexmo-community/dialogflow-sample-voice-application)
2. Add the `private.key` generated from the Vonage Dashboard and downloaded to your machine to the project root
3. From the `.env.example` create a `.env` file
4. Populate the environment variables with the information present on the [Vonage API Dashboard](https://dashboard.nexmo.com/)

* The `SERVICE_NUMBER` is the virtual number you purchased. Remember to add the country code without any 00s or + beforehand
* The `DF_CONNECTING_SERVER` is the server from the Dialogflow Reference you already have running (the one you previously took note of)

5. Install the dependencies
   `npm install`
6. Run the `df-application.js` 
   `node df-application.js`
   Below you can find the next steps for ngrok and for Heroku respectfully:

   **Option 1: Below are Steps using ngrok**
7. On a separate terminal tab run `ngrok http 8000`
   Get back to the Vonage Dashboard website and under capabilities:
8. Toggle Voice to enable this capability
9. Add the ngrok URL running on `dialogflow-sample-voice-application`  followed by `/answer` on the Answer URL. Make sure HTTP GET is selected.
10. Add the ngrok URL running on `dialogflow-sample-voice-application`  followed by  `/event` on the Event URL. Make sure HTTP POST is selected.
11. Click on Save Changes

![Vonage Dashboard](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/application.png "Vonage Dashboard")

 **Option 2: Below Steps using Heroku** 

7. On a separate terminal tab, If you do not yet have a local git repository, create one:  `git init`
8. Start by creating this application on Heroku from the command line using the Heroku CLI. Note: In  command, replace `myappname` with a unique name on the whole Heroku platform. `heroku create myappname`
9. On your Heroku dashboard where your application page is shown, click on `Settings` button, add the following `Config Vars` and set them with their respective values found in your `.env` file.

```bash
API_KEY
API_SECRET
APP_ID
SERVICE_NUMBER
DF_CONNECTING_SERVER
```

   Add also the parameter `PRIVATE_KEY_FILE` with the value `./private.key`  

10. On your Heroku dashboard where your application page is shown, click on the `Open App` button and copy the URL
11. Now, let's deploy the application. Get back to the Vonage Dashboard website and under capabilities:
12. Toggle Voice to enable this capability
13. That hostname (the URL you just copied from Heroku) will be used followed by `/answer` on the Answer URL. Make sure HTTP GET is selected
14. Do the same for  `/event` on the Event URL. Make sure HTTP POST is selected
15. Click on Save Changes

![Vonage Dashboard](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/screenshot-2021-09-04-at-17.53.26.png "Vonage Dashboard")

## Improving the Dialogflow Agent

If you were to try and call the phone number at this point of the tutorial, you would be able to interact with the starting point of the conversation from the Dialogflow perspective, the `Default Welcome Intent`.

A message would be sent back to the caller from the list of the user responses. But the conversation would not take turns as we do not have any other data trained for other turns of conversation.

Let's take a step back and explore some of the concepts of Dialogflow to add the utterances the users might say, provide them with a response, and add the end of the conversation, so that you can see a full conversation in turns taking place.

Once you create an agent, you will create intents that will handle and shape the conversation.

In the event of a user utterance, Dialogflow matches what is being said to an intent, which is based on the NLP and the training phrases that a user could potentially say to match that intent. Once the intent classification happens, a response is sent back to the user.

Entities are the types of information that we will extract from the conversation. For the use-case we will see below, we are booking a table via a phone call. The information we will extract from the conversation are `person`, `date` and `time`.

Let's improve the Default Welcome Intent, create an intent, outline the entities, and add an end to the conversation and test it out.

### Follow the steps

1. Open the [dialogflow console](https://dialogflow.cloud.google.com/) and make sure you're in the correct agent for this tutorial
2. Click on the `Default Welcome Intent`
3. Scroll down, erase the responses and add: `Welcome to our Demonstration Restaurant. When and for whom would you like to book a table?`
4. Click Save
5. Click on the Intents menu item  
6. Click on the New Intent button
7. Give it the name of `Table Booker`
8. Under Training Phrases add the following training phrases
   	- A table for Nicole on the 10th at 13:00, please.
   	- Could I book a slot at 14:00 on 10/12/2021 for Joseph?
   	- I'd like to book a table on the 10/09/2020 at 16:00 for Amanda
   You will notice that as you type these sentences, some words will be outlined in a colorful highlight, make sure to double click the words and make sure they are using the correct entities `@sys.person`, `@sys.date` and `@sys.time`. 
9. Under Actions and Parameters, tick `required` for `person`, `date` and `time`
10. Add prompts for each one of the parameters because in case they haven't said that specific piece of information during the conversation, they'll be prompted to add them

![Training phrases examples](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/trainingphrases.png "Training phrases examples")

11. In the response, you can add the following: `Table booked for $person at $time on $date. Thank you!`
12. Toggle `Set this intent as end of conversation`, below responses
13. Click Save

![Table Booker Intent Overview](/content/blog/integrate-phone-calls-to-a-dialogflow-chatbot-via-websockets/dialogflow.png "Table Booker Intent Overview")

## Interact Via Voice With the Dialogflow Agent

Now that we have all the parts set up it's time to call your virtual phone number and test it out, let's go through what is going on and then follow our final step to make the call!

Once you call the phone number linked to your Voice API application to interact with the Dialogflow Agent
You will hear the confirmation message: `Connecting your call, please wait.`. That Text To Speech from the Vonage API platform is played as soon as the platform answers your call.

Once the WebSocket is established, the Vonage API platform plays the Text To Speech `Hello` to the Dialogflow Agent (you as the caller will not hear that).

You just set up read back to you by the Dialogflow agent.

At this point, you will interact with the intents you set up in the previous section of this tutorial to book a table.

You will see the transcriptions on the Dialogflow reference connection application console and also on the Dialogflow sample voice API application console.

If you'd like to see the sentiment analysis results, you'll have to enable the Cloud Natural API from the Google Cloud console. If it's not enabled you'll get an error similar to `PERMISSION_DENIED: Cloud Natural Language API has not been used in project xxxx before or it is disabled`.

Let's go to our final step and see all the building blocks together in action!

### Follow the steps

1. Call the phone number linked to your Voice API application and interact with the Dialogflow Agent
2. Here's a potential way you could test the conversation:

   1. Vonage Websocket: Connecting your call, please wait. 
   2. Bot: Welcome to our Demonstration Restaurant. When and for whom would you like to book a table?
   3. You: I'd like to book a table at 10:00 am on 01/09/2022 for Tanya
   4. Bot response: Table booked for Tanya at 10:00 on 01/09/2022. Thank you!

   **End of call** 

## Congratulations

You have completed this tutorial on making phone calls to a Dialogflow agent using a Vonage WebSockets integration.

## Resources

You can find the [Dialogflow Reference sample](https://github.com/nexmo-community/dialogflow-reference-connection) and [Sample Voice Application on Github](https://github.com/nexmo-community/dialogflow-sample-voice-application).

Check the [WebSockets reference guide](https://developer.vonage.com/voice/voice-api/guides/websockets).

Check the [A blog post explaining ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr).

You can also look at a similar example using an [Amazon Lex Bot](https://learn.vonage.com/blog/2021/03/10/connecting-voice-calls-to-an-amazon-lex-bot/). 

I hope you enjoyed this. Feel free to contact me [on Twitter](https://twitter.com/amdcavallaro) or join our [Community Slack Channel](https://developer.vonage.com/community/slack).