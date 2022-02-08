---
title: Build Watson-enhanced Voice Agents on IBM Cloud with Nexmo
description: Through the Nexmo platform integration with IBM Voice Gateway, you
  can orchestrate voice interactions with a cognitive self-service agent powered
  by Watson.
thumbnail: /content/blog/build-watson-enhanced-voice-agents-on-ibm-cloud-with-nexmo/DevBlog-IBMMeetup.png
author: oscar-rodriguez
published: true
published_at: 2019-02-25T17:01:23.000Z
updated_at: 2021-05-12T03:23:40.774Z
category: tutorial
tags:
  - ibm-watson
comments: true
redirect: ""
canonical: ""
---
Why do I love being an engineer at Nexmo, the Vonage API Platform? Because I get to work not only on the real-time communication tech we build but also on integrations with other amazing technologies. Case in point: Nexmo just became the preferred voice integration partner for IBM Voice Gateway, a SIP endpoint that you can use to connect phone calls with IBM Watson speech and conversation services. 

Through the IBM Voice Gateway and Nexmo platform integration, you can direct voice interactions with a cognitive self-service agent—[IBM Voice Agent with Watson](https://cloud.ibm.com/docs/services/voice-agent/connect-SIP.html#nexmo-setup)—or access real-time transcriptions of a phone call between two people. Imagine the possibilities for, say, a contact center application. 

Here’s a diagram of the Nexmo and IBM Voice Agent integration to give you an idea of how it works.

![Nexmo, IBM Voice Gateway and IBM Voice Agent with Watson](/content/blog/build-watson-enhanced-voice-agents-on-ibm-cloud-with-nexmo/image1-1-1127x600.png "Nexmo, IBM Voice Gateway and IBM Voice Agent with Watson")

The Nexmo platform is not only whitelisted as a telephony provider for Voice Gateway, but it also provides the call anchor and core telephony integration for Voice Agent. If you’re on IBM Cloud (the platform formerly known as Bluemix), you can now easily integrate your voice applications with these Watson services, which power innovative IVA (interactive voice assistant) solutions:

*   [Watson Speech To Text](https://console.bluemix.net/catalog/services/speech-to-text)
*   [Watson Text To Speech](https://console.bluemix.net/catalog/services/text-to-speech)
*   [Watson Assistant](https://console.bluemix.net/catalog/services/watson-assistant)

You also have the benefit of being able to seamlessly build and deploy those applications in the IBM cloud, which means they can be up and running in no time.

And, yes, you read that acronym correctly—it’s IVA. We’re way beyond traditional IVR (interactive voice _response_) systems here. With direct access to Watson AI and its communication services, you can build voice agents that communicate in a more conversational way and have the capability to handle more complex customer interactions than standard phone menus.

## Nexmo and IBM Voice Agent with Watson: Getting Started

To get you started with this powerful integration, I’ve created a GitHub repo, [Nexmo Watson Voice Agent Integration](https://github.com/nexmo-community/watson-voice-agent), that should simplify the process for you. It includes code samples and a tutorial that explains how to stand up a Nexmo voice application, an IBM service orchestration engine (SOE), and an Express server that will allow you to update calls on the fly. 

The SOE provides a simple way to customize the Voice Gateway and Voice Agent behavior for your app. It acts as a Watson Conversation proxy between the Voice Gateway/Voice Agent and the Watson Conversation service, modifying requests sent from the gateway/agent to Watson and modifying responses sent back to the gateway/agent from Watson. 

We use [Node-Red](https://www.nexmo.com/blog/2019/02/21/nexmo-node-red-package-dr/) as the SOE for this integration. If you haven’t used Node-Red before, it’s a handy builder tool that enables teams to wire together application workflows by dragging and dropping dynamic components such as APIs, hardware devices and online services onto a palette. Hosting your voice application as a Node-Red flow will simplify and centralize your solution architecture in IBM Cloud. 

After you’ve completed the tutorial, you’ll be able to call your app, ask it a question that could be susceptible to semantic confusion, and it will be able to detect your intent. It’s pretty cool; [give it a try](https://github.com/nexmo-community/watson-voice-agent). 

With the Nexmo integration with Voice Agent, it’s easier than ever for IBM Cloud developers to offer Watson-enhanced voice interactions to all of their users. What are you waiting for?
