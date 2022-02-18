---
title: Send SMS and WhatsApp Messages in Salesforce With the Vonage APIs
description: Learn to install Vonage’s open source connector and Lightning
  component to allow you to send push notifications and perform 2-way SMS and
  WhatsApp messaging straight from Salesforce.
thumbnail: /content/blog/send-sms-and-whatsapp-messages-in-salesforce-with-the-vonage-apis/whatsapp_salesforce_api.png
author: marc-marchal-de-corny
published: true
published_at: 2022-02-04T14:50:52.935Z
updated_at: 2022-02-03T16:18:50.499Z
category: tutorial
tags:
  - salesforce
  - javascript
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introduction

In this tutorial, we are going to install Vonage’s open source connector and Lightning component to allow you to send push notifications and perform 2-way SMS and WhatsApp messaging straight from Salesforce!

We’ll be using Salesforce, Node.js, Apex, JavaScript, and the [Vonage Messages API](https://developer.vonage.com/messaging/sms/overview). 

The open source components can be found in the following GitHub repositories:

* [Node.js connector](https://github.com/Vonage-Community/sample-messages-salesforce-nodejsconnector)
* [Lightning Web Component](https://github.com/Vonage-Community/sample-messages-salesforce-lightning_component)

You can see it in action here:

<youtube id="uUSaXOnNTOk"></youtube>

## Setting up Salesforce Org

If you are reading this tutorial, you most certainly aren’t new to Salesforce, but before you start, let’s make sure that you have the correct setup.

* You need to be a System Administrator in the Org to install the package.
* Before installing this directly on your production Org, why don’t you deploy it in a sandbox environment? They call these developer accounts, and you can get as many as you like here: [Developer Sign-up](https://developer.salesforce.com/signup).

By the time you have gone through the onboarding flow, you will have your OWN developer instance of Salesforce, and you can do whatever you like without breaking anything! 

## Create Connected App Inside Salesforce

1. When connected to your Salesforce Org, go to 'Setup' in the top right!
2. ⚙️  Search for App Manager in the left-hand menu.

![App manager selection](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img2.png)

3. Then click on 'New Connected App'.

![New Connected App](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img3.png "New Connected App")

4. Create the Connected App as per the screenshot and tick 'Enable OAuth Settings'.

![App Manager Setup View](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img4.png "App Manager Setup View")

5. Add a callback URL to a local webhook (this does not get used in our case)
   under the API section and select 'Full Access' under 'Selected OAuth Scopes'. 

![Enable Oauth settings](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img5.png "Enable Oauth settings")

6. When you click 'Continue' on the following page, you will find the 'Consumer Key' and 'Consumer Secret'. Store both of these for the later part of the integration.

## Install the Salesforce Unmanaged Package

Option 1: Install it via the link 

1. Go to the [GitHub link for the Lightning Web Component](https://github.com/Vonage-Community/sample-messages-salesforce-lightning_component), and at the very top, you will find a link to 'install the unmanaged package'. Please use the link in the first paragraph of GitHub, as it will be updated with the latest version.
2. Click on the link to install the package. When you have finished, it will take you to the installed application page:

![Installed packages](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img6.png "Installed packages")

Option 2: Install it via GitHub

1. Download the [Lightning Web Component on GitHub](https://github.com/Vonage-Community/sample-messages-salesforce-lightning_component), install the [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) and follow the instructions.

To continue, you need to have the package installed and the Consumer Key and Consumer Secret.

## Deploying the Salesforce Node.Js Connector

In order to do 2-way SMS and WhatsApp inside Salesforce, you need to create a webhook to receive the inbound messages from Vonage API and send them into the Salesforce Org via a Custom Object. We’ve got you covered. 

You will need to download the code from the [Node.js connector](https://github.com/Vonage-Community/sample-messages-salesforce-nodejsconnector) and deploy it onto your favourite Node.js environment: Heroku, AWS Lambda, etc.

Before deploying your code, you will need to provide the correct environment variables for the JavaScript connector. You will need to retrieve your API credentials for Salesforce so that this Node.js script can call the Salesforce API. 

Please follow the steps:

1. Retrieve your Connected App setting:
   We followed this step earlier. These are your CONSUMER KEY AND CONSUMER SECRET and you will need to save them under the following environment variables. [More info here](https://help.salesforce.com/s/articleView?id=sf.connected_app_create.htm&type=5) 

* SFDC_CONSUMER_KEY
* SFDC_CONSUMER_SECRET

2. Create a dedicated Salesforce user (or reuse an existing user):
   [More info here](https://help.salesforce.com/s/articleView?language=en_US&type=5&id=adding_new_users.htm). 

In the step above, after creating the user, you will be able to save the username and password of the user under the following environment variables:

* SFDC_USERNAME
* SFDC_PASSWORD

Please store the URL on which you are hosting the service as you will need it when you set up the webhooks within the Vonage API Applications. Two URLs will be exposed:

* Inbound URL: https://yourNodeServer/webhook/inbound
* Event URL: https://yourNodeServer/webhook/event

## Setting up Vonage API Dashboard

If you don’t have a Vonage API account, head to our [Sign-up page](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) or go straight to our [dashboard](https://dashboard.nexmo.com/). 

You will need to perform 3 things:

1. Get your API key and Secret: You can find them as soon as you have created your account [on the dashboard](https://dashboard.nexmo.com/settings).
2. Create an Application and configure webhooks:
   Create an application under the API key [on the Applications page of the dashboard](https://dashboard.nexmo.com/applications).

Generate a public and private key (these will not be used). Under the Capabilities, activate Messages and insert the two callback URLs you created in the previous Node.js step.

![](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img7.png)

3. Associate an SMS/WhatsApp phone number or use the WhatsApp Sandbox: you will need to order a phone number for WhatsApp or SMS. You can buy these by logging on to the [Numbers page](https://dashboard.nexmo.com/buy-numbers).

You can also easily create a WhatsApp number using our new [Embedded Sign-up feature](https://dashboard.nexmo.com/messages/social-channels).

Otherwise, you can use our WhatsApp Sandbox right away by configuring the same webhooks as before on the dedicated [Sandbox page](https://dashboard.nexmo.com/messages/sandbox).

At this point, inbound messages should directly trigger your node connector and get pushed straight into Salesforce! You’re nearly done!

## Configuring Your Vonage Credentials Inside Salesforce

So now that inbound messages from Vonage should be working, let’s look at setting up the outbound part. Since the package is installed, you will find specific settings for the Vonage credentials.

1. As before, go into the Setup section (top left menu).
2. Then look for Custom Settings.

![Custom Settings](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img8.png)

3. You will find one called 'Vonage API Configuration'.

![Vonage API Configuration](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img9.png)

4. Click on 'Manage' and then 'New' at the top to add your credentials.

![Edit Vonage API Configuration](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img10.png)

5. Enter all fields accordingly. Tick 'USE_SANDBOX_FOR_MESSAGES_API' and enter 'WHATSAPP_LVN' as '14157386102', if you are using the WhatsApp Sandbox.
6. Save it!

## Decide Where You Want to Place the Lightning Component

So now that you are here, you can decide where you want to position the Lightning component installed. 

Let’s see how you can add it to the cases.

1. Open a case by going to the Service Console and viewing an existing open case.
2. Click on the cog in the top right-hand menu and select 'Edit Page'.

![Setup](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img11.png)

3. Let’s create a new tab next to Feed and Related Select the middle window.

![Feed and Details](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img12.png)

4. Click 'Add Tab' and select 'Custom' to rename it. 

![Custom](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img13.png)

5. Look on the left-hand side and look under the Custom Lightning component. Drag and drop the `VonageMessaging` component into the right part of the page.

![Screenshot of the Components Page](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img14.png)

You’re DONE. You can now send and receive messages from any case. 

![Case](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img15.png)

## Bonus: You Can Also Automate Outbound Notification via the Process Builder and Flow

If you need to automate messages straight out of Salesforce, you can use the integration to send SMS and WhatsApp messages.

1. Go to 'Setup' and search for 'Process Builder'. 
2. Click 'New' to create a new process. 
3. Build your process with objects, conditions, and under 'Immediate Action', you can decide to send an SMS or a WhatsApp message as per the screenshot. 
4. Select Apex and then 'Send Vonage Message'.

![Process Builder](/content/blog/push-and-conversational-sms-and-whatsapp-in-salesforce-with-vonage/img16.png)

## What's Next?

Now that you have integrated SMS and WhatsApp into Salesforce, your team can run all their B2C communication straight within Service Cloud or Sales Cloud and keep all your data in one place. Stay tuned as we will be adding even more features as part of our full-blown product.