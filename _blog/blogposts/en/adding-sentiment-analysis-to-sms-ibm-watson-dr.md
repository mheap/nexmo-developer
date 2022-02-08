---
title: Adding Sentiment Analysis to SMS with IBM Watson
description: Understanding sentiment of incoming SMS messages is incredibly
  powerful, check out our one-click deploy IBM Watson Sentiment Analysis
  connector for your app
thumbnail: /content/blog/adding-sentiment-analysis-to-sms-ibm-watson-dr/Sentiment-Analysis-with-Watson.jpg
author: kellyjandrews
published: true
published_at: 2019-04-04T08:00:30.000Z
updated_at: 2021-05-13T17:25:48.456Z
category: tutorial
tags:
  - sms-api
  - sentiment-analysis
  - ibm-watson
comments: true
redirect: ""
canonical: ""
---
When it comes to communications via SMS, I think we all can agree that sometimes the sender's intent can be misinterpreted.  I know that, personally, meaning and context around words can easily be misunderstood.

In whatever way technology contributes to this ongoing difficulty, technology also helps bail us out with sentiment analysis tools. In this case, we are going to connect Nexmo  SMS Messaging with the IBM Watson Tone Analyzer.  

## What is IBM Watson Tone Analyzer?

The IBM Watson Tone Analyzer is an API that allows text to be understood as emotions and communication style.  

This set of APIs allows developers to listen to social channels, monitor customer support and integrate with chatbots. Doing so allows teams to build strategies around customer satisfaction or frustration.

![API graphic](/content/blog/adding-sentiment-analysis-to-sms-with-ibm-watson/sms-sentiment-watson.jpeg)

## Start Coding

<sign-up number></sign-up>

In order to begin sentiment analysis, you will need to setup the [IBM Tone Analyzer service](https://console.bluemix.net/catalog/services/tone-analyzer) on IBM Cloud. Turning on this service will give your application the credentials needed to run the app.  

The repository for the sample application is on [Github](https://nexmo.dev/ibm-nexmo-sms-analysis-repo). The full repo will allow you to deploy to [Heroku](https://nexmo.dev/ibm-nexmo-sms-analysis-heroku), [IBM Cloud](https://nexmo.dev/ibm-nexmo-sms-analysis-ibmcloud), run locally as a Docker container, or remix on [Glitch](https://nexmo.dev/ibm-nexmo-sms-analysis-glitchremix).  

The quickest way to get going is to remix on Glitch and update your environment variables. Check out the readme on directions to get a new virtual number using the [Vonage CLI](https://www.npmjs.com/package/@vonage/cli) or using the [dashboard](https://developer.nexmo.com/numbers/guides/numbers#rent-virtual-numbers).

## What's Happening

The overall purpose of the repo is to show you how simple it is to connect Nexmo SMS with IBM Watson Tone Analyzer.  

The virtual number, when configured, will call the `/message` route for any incoming SMS message to that number.  This route, in turn, calls the `toneAnalyzer.tone` method from the IBM Watson package sending the SMS text to be analyzed. 

![Command Line Analysis](https://www.nexmo.com/wp-content/uploads/2019/04/ibm-sms-sentiment.gif)

While these are arbitrary examples, you can begin to see the power behind something like this. 

## What's Next?

Where do you go from here?  The application only displays the response in the logs.  Ideally, you would create an application that would display the sentiment either as text or perhaps even as emoticons.  

You can build this into an event notification system for real-time analysis for live SMS chat analysis or monitor chatbot activity for potential intervention with humans.