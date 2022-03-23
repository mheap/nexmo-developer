---
title: 10 DLC Brand Overview
meta_title: 10 DLC brand overview 
description: Provides and in-depth explanation of the definition of a brand, brand registration requirements, defining your business, and data requirements for registering a brand for 10 DLC. 
navigation_weight: 3
---

# 10 DLC Brand Overview

Users relying on Vonage APIs to send SMS and MMS traffic from a +1 Country Code 10-Digit Long Code into US networks need to register a brand and campaign in order to get approval for sending 10 DLC messages. The first step in the process is to register a brand. This section outlines what you need to know about brand registration for 10 DLC messages.

A brand is the legal entity of the business. For example:

* "ABC Sodas" would submit only one brand, "ABC Sodas," and this would be sufficient for all their other consumer brands such as "Cherry Soda" and "Root Beer Soda."
* Vonage Business Cloud would submit one brand as it is a SaaS solution, through which other businesses communicate.

> Note: See the Vonage Knowledge Base for more information on [brand creation guidelines](https://help.nexmo.com/hc/en-us/articles/4407712172692-10DLC-Guidelines-for-brand-creation).

In this section, you will learn about:

* [Brand registering requirements](#requirements)
* [Registering a single brand versus multiple brands](#registering-a-single-brand-vs-registering-multiple-brands)
* [Registering a brand from the Vonage API Developer Dashboard](#register-a-brand-from-the-vonage-api-developer-dashboard)
* [Defining the business type](#defining-the-business-type)
* [Reseller businesses](#reseller-businesses)
* [Parent and sub-accounts](#parent-and-sub-accounts)
* [Tax and stock information](#tax-and-stock-information)
* [Brand status](#brand-status)

## Requirements

The following is a list of general requirements:

* Users can only send messages with the same use case that have been registered with their campaign.
* Resellers of Vonage SMS services will, in most cases, need to register their users' brands and campaigns for them.
* US numbers cannot be shared across brands, which includes both geographic numbers and US Shared Short Codes.
* SMS + Voice enabled numbers will only be affected if outbound messages are sent, at which point it will be throttled and pass-through fees will be applied. SMS Inbound and Voice capabilities will remain the same.

## Registering a Single Brand vs Registering Multiple Brands

A large SaaS platform with a few large customers might consider separately registering those large customers as their own brands. The majority of smaller customers can be registered under one brand. This means that if there are any spam or reputation issues, they can be isolated to those individual brands.

If you are an SMS aggregator with no brand value added on top and pass through the message, you would need to apply as a reseller and each of the businesses you serve would need to apply as their own brand.

In summary:

* If you operate as one legal entity and only send content as that legal entity, submit only one brand.
* If you are operating as a SaaS business with value added, submit one brand.
* If you are operating as an SMS aggregator, submit individual brands for the legal entities that you represent.

## Register a brand from the Vonage API Developer Dashboard

> Note: You may also register your brand programmatically via the [Vonage 10 DLC API](/api/10dlc).

1. Navigate to [Vonage API dashboard > Brands and campaigns](https://dashboard.nexmo.com/sms/brands).
2. Click **Register a new brand**.
3. Fill in all required fields on the **Register a new brand** form.
4. Click **Review details**. A confirmation dialog box opens.
5. Review your brand details.
6. Click **Register and pay**.

> **Note:** You will not be able to change your brand details after registering.

Your brand information is displayed in the Brand list on the Brands and campaigns page where you can monitor the status of its registration and view more details.

The following table describes the data values you will need when you register a brand for 10 DLC:

| Name      | Description |
| ----------- | ----------- |
| Account      | Account to associate with the Brand.       |
| Entity Type      | Business type behind the brand. Is this a form of business or individual/freelance developer?    |
| Partner      | Identify if this brand is a partner or reseller so it can have multiple campaigns/numbers.       |
| Website URL      | The website of the business.       |
| Vertical      | The segment in which the business operates.       |
| Email      | The email address of support contact, i.e., the person who set up the brand.       |
| Display Name      | Brand/Marketing name of the business.       |
| Company Name      | The legal name of the business.       |
| EIN      | Tax ID of the business.       |
| Alternative Business Id Type      | Alternative Business Identifier Type, e.g., DUNS, LEI, GIIN.       |
| Alternative Business Name      | Alternative Business Identifier.       |
| Phone      | The support contact telephone in e.164 format, e.g., +12023339999.       |
| Street      | Street name and house number, e.g., 1000 Sunset Hill Road.       |
| City      | City name.       |
| State      | State or province. For the United States, use 2 character codes, e.g., 'CA' for California.       |
| Postal Code      | Zip Code or postal code, e.g., 21012.       |
| Country      | 2 letter ISO-2 country code, e.g., US.       |
| Stock Symbol      | The stock symbol of the brand.       |
| Stock Exchange      | The stock exchange of the brand.       |

## Defining the business type

Some campaigns are limited to specific business types. For example, for a registered campaign type that is a Charity use case, it is unlikely that the campaign will be approved for any business entity type other than a registered charity.

The four supported business entity types include:

* Publicly traded company
* Private for-profit company
* Not-for-profit company
* Sole Proprietor

## Reseller businesses

Vonage SMS Resellers are those who resell the Vonage SMS API.

Understanding if a brand is a reseller or partner is critical. It determines if you need to register a single brand and campaign or multiple brands and campaigns for your 10 DLC program. This impacts the program cost, and will also impact the time to set-up and get brands and campaigns registered.

Single account, multiple brands

Orchestration of the different brand customers is managed within a single parent account when a single parent business that provides software which allows multiple businesses (their brand customers) to send SMS within their own branding and content. 

A single account, multiple brands model includes the following attributes:

* Parent business who resells SMS services.
* Each brand has different use cases.
* Each brand has its own content and branding.

## Parent and sub-accounts

This model is more like a Partner model where a parent business account directly manages each of their own brand customers. Their customers are managed through separate sub-accounts since numbers, billing, and configuration is set up according to each customer's needs.

You can share brands across multiple accounts. Identify which account with which you want to share the brand and Vonage can set that up for you. This is useful for example if you create the brand under your parent account and want to share it with sub-accounts as well.

A parent and sub-accounts model includes multiple sub-accounts one per customer or child business

## Tax and Stock Information

If your business is a publicly traded company, the Stock Symbol is mandatory, and for all companies other than individuals an EIN is required.

## Brand Status

Your brand will receive a status after registration. If the status is **Verified**, then you can start creating campaigns under that specific brand. If the status is **Unverified**, follow the instructions in this [knowledge base article](https://help.nexmo.com/hc/en-us/articles/4407720043284) regarding the steps you need to follow in order to get the brand **Verified**.
