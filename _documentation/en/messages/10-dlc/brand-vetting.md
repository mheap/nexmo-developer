---
title: 10 DLC Brand Vetting Overview
meta_title: 10 DLC brand vetting overview 
description: Provides and in-depth explanation of the definition of brand vetting, when brand vetting is recommended and/or required, vetting for additional throughput, and associated costs. 
navigation_weight: 4
---

# 10 DLC Brand Vetting Overview

Vetting is a background check processed by an independent company. When you create a brand through the Vonage API Dashboard, your entity will be assigned a limitation of throughput per second / minute / day for the number of messages you can send to your customers. Some companies are required to apply for vetting; others that require a higher limit than what is assigned by basic verification will also need to go through the vetting process.

In this section, you will learn about:

* [Required versus recommended vetting](#required-versus-recommended-vetting)
* [Vetting for additional throughput](#vetting-for-additional-throughput)
* [Cost of vetting](#cost-of-the-external-vetting)
* [Porting vetting](#porting-vetting)
* [T-Mobile Special Business Review](#t-mobile-special-business-review)
* [How to request brand vetting from the Vonage API Developer Dashboard](#request-brand-vetting-from-the-vonage-api-developer-dashboard)

## Required versus recommended vetting

Vetting is required when:

* You require more throughput than you are currently allowed.
* Your brand has a low brand rating or qualification.
* Your brand requires approval for some campaign use cases.
* The carrier does not allow you to have an embedded link in your messages.

When vetting is recommended when:

* You are registering a 10 DLC brand for a company registered outside the USA. See the table below for a list of countries that are part of The Campaign Registry's (TCR) "optimized approval list."
* The business for which you are registering a 10DLC brand is not listed on the Russell 3000 index. TCR and major US carriers recommend that any business that is not listed on Fortune 1000 or on the Russell 3000 index should apply for external vetting to help prove that the brands are genuine and will adhere to the 10 DLC regulations accordingly.

Companies registered outside of the United States should apply for vetting as many countries do not offer the technology allowing for automatic verification by The Campaign Registry (TCR).

The following countries are part of TCR's "optimized approval list." This means that companies originating from those countries can benefit from automated VAT identification. For any other country, TCR recommends using the primary corporation registration number or tax ID number for the country, and vetting will likely be required.

| Country      | Country Code |
| ----------- | ----------- |
| Croatia      | HR       |
| Hungary   | HU        |
| Ireland   | IE        |
| Italy   | IT        |
| Lithuania   | LT        |
| Luxembourg   | LU        |
| Latvia   | LV        |
| Malta   | MT        |
| Netherlands   | NL        |
| Norway   | NO        |
| Poland   | PL        |
| Portugal   | PT        |
| Romania   | RO        |
| Sweden   | SE        |
| Slovenia   | SI        |
| Slovakia   | SK        |
| Northern Ireland   | XI        |
| United Arab Emirates   | AE        |
| Australia   | AU        |
| Belarus   | BY        |
| Chile   | CL        |
| Iceland   | IS        |
| Malaysia   | MY        |
| New Zealand   | NZ        |
| Saudi Arabia   | SA        |
| Singapore   | SG        |
| Taiwan   | TW        |

## Vetting for Additional Throughput

Customers unhappy with the scores assigned to their 10 DLC brands can apply for vetting to receive a vetting score which will determine the throughput of their campaigns, allowing for higher limits. Refer to this [knowledge base article](https://help.nexmo.com/hc/en-us/articles/4406782736532-Throughput-Limits-for-A2P-10-DLC-Numbers) to find more information about the throughput for each vetting score.

## Cost of the external vetting

Applying for external vetting is a review of your application by an external company. The Campaign Registry directly works with a set of vetting companies approved for 10 DLC.

**Vetting cost: $40 per vetting**

> Note: Vonage currently offers the option for our customers to apply for vetting if they judge it relevant to their situation. We reserve the right to update that process in the future.

## Porting vetting

If you have already created brands & campaigns with a different provider, it is not currently possible to port the vetting information to a different provider.

## T-Mobile Special Business Review

T-Mobile will assign a rating to your 10DLC brand, which will have a designated daily limit of throughput. If you require additional throughput, you can apply for a special business review process with T-mobile.

Please make sure you complete the $40 external vetting that is available through the customer dashboard first before applying for a special business review request.

**Cost: $5000** (this fee is currently waived by T-mobile during their grace period)

If you wish to apply for brand vetting with T-Mobile, please [submit a support request](https://help.nexmo.com/hc/en-us/requests/new).

## Request brand vetting from the Vonage API Developer Dashboard

> Note: You may also make a request for brand vetting programmatically via the [Vonage 10 DLC API](/api/10dlc).

1. Navigate to [Vonage API dashboard > Brands and campaigns](https://dashboard.nexmo.com/sms/brands).
2. Select the **Brand** for which you wish to apply for vetting.
3. Select the **External vetting** tab.
4. Click the **Apply for vetting** button.
    The **External brand vetting** dialog box opens.
5. Select the appropriate options in the drop-down menus.
6. Click the **Apply for external vetting** button.
    An **External brand vetting** confirmation message is displayed.
7. Click the **Close** button.
