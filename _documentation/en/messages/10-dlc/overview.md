---
title: Overview
meta_title: 10 DLC for app-to-person messaging.
description: The 10 DLC API provides you the ability to register your brand, request brand vetting, register a campaign, and link numbers to your campaigns so you can send messages to your users and ensure you're complying with 10 DLC regulations in North America.
navigation_weight: 1
---

# 10 DLC Overview

10 DLC stands for 10 Digit Long Code. Major US carriers have announced their requirements for a new standard for application-to-person (A2P) messaging in the USA, which applies to all messaging over 10 digit geographic phone numbers, also known as 10 DLC. This new standard provides many benefits including supporting higher messaging speeds and better deliverability.

Customers using the Vonage SMS and Messages APIs to send traffic from a +1 Country Code 10 Digit Long Code into US networks will need to register a brand and campaign in order to get approval for sending messages.
The 10 DLC API provides you with the ability to programmatically manage your brand and campaigns so you can comply with U.S. carrier standards and send A2P messages to your customers.

> Note: US numbers can no longer be shared across brands which include both geographic numbers and US shared short codes.
Vonage customers using US shared short codes: T-Mobile and AT&T’s new code of conduct prohibits the use of shared originators, therefore, shared short codes will no longer be an acceptable format for A2P messaging.

For more information about preparation including timelines, pricing, and migration options, see this [knowledge base article](https://help.nexmo.com/hc/en-us/articles/360050905592-10DLC-Preparation).

## What is 10DLC?

You already learned that 10-Digit Long Code is the new standard for Application-to-Person (A2P) messaging in the United States. But what does that mean? If you are a business that communicates with customers in the United States via phone calls or text messages: 10DLC provides a way to send messages using +1 ten-digit geographic numbers.

Mobile carriers like Verizon created 10DLC to ensure messages to customers originate from trusted sources.

Businesses can register for a 10DLC number to send SMS messages, MMS messages, or make phone calls from a ten-digit geographic number.

Under the new A2P 10 DLC regulation, anyone using an A2P (Application to Person) mechanism to send messages (SMS or MMS) is required to go through a registration process via the campaign registry (TCR). The registration process comprises of 4 phases:

1. [Register a brand](brand-overview) for your business.
2. [Request brand vetting](brand-vetting.md) to be assigned a trust score.
3. [Register a campaign](campaign-overview.md) for your brand.
4. [Link numbers to the relevant campaigns](linking-numbers.md).

You can either [use the Vonage API Developer Dashboard](_documentation/en/messages/10-dlc/10-dlc-registration-dashboard.md) or use the [Vonage 10 DLC API](/api/10dlc) to programmatically register your Brand, request brand vetting, register a campaign, and link numbers to a campaign.

## Advantages of 10DLC

10DLC has many advantages. Here are a few of them:

1. **Flexibility:** You can text with your business number or a local number to help you communicate with a personal feel.
2. **Send more messages:** companies registering 10DLC campaigns can send up to 75 messages per second.
3. **Better deliverability:** 10DLC numbers are registered with the carriers, making your messages more likely to reach their recipient.

## What Do I Do if I Have More Than 50 Numbers?

You can link up to 50 numbers to a single campaign. If you have more than 50 numbers, you should first evaluate whether or not you have a true business need to support more than 50 numbers. If so, you must submit a special business review application with T-Mobile. See [Linking numbers to 10 DLC campaigns](linking-numbers.md) to learn more about number pooling.

## References

[Leveraging public APIs with 10 DLC](https://help.nexmo.com/hc/en-us/articles/4432118008468-Leveraging-Public-APIs-with-10-DLC)

[Managing 10 DLC opt-in and opt-out](https://help.nexmo.com/hc/en-us/articles/4417194850964-How-do-I-manage-10-DLC-Opt-In-or-Opt-Out-)

[Troubleshooting when brand details can’t be verified](https://help.nexmo.com/hc/en-us/articles/4407720043284-10-DLC-Brand-Details-Could-Not-Be-Verified)

If you have any questions about registering for 10DLC, please [join our Slack community](https://developer.vonage.com/community/slack) or [send us a message on Twitter](https://twitter.com/VonageDev).
