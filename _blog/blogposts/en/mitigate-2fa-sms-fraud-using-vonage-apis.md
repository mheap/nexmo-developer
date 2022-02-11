---
title: Mitigate 2FA SMS Fraud using Vonage APIs
description: An overview of 2FA SMS fraud, and some potential mitigations against it
thumbnail: /content/blog/mitigate-2fa-sms-fraud-using-vonage-apis/fraud-mitigation.jpg
author: karl-lingiah
published: true
published_at: 2022-01-19T13:22:42.600Z
updated_at: 2022-01-17T15:44:30.295Z
category: tutorial
tags:
  - conversion-api
  - sms
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Communications technology is ever-evolving, and the pace of change has been rapid over recent years. This evolution has brought many benefits to the businesses which leverage these technologies, providing improved interaction with customers and intelligent automation. Unfortunately, there are also bad actors who look to exploit changes in technological trends for nefarious reasons. One example of this is the increase in SMS 2FA fraud.

Two-Factor Authentication (2FA) via SMS has been around for some time, and in recent years it has seen a massive increase in popularity. Most applications these days will offer 2FA, often implemented via the use of an SMS communication channel. Due to this popularity, 2FA systems have become something of a draw for fraudsters who seek to exploit these systems in various ways, such as routing non-legitimate traffic through them.

## Fraud scenario: SMS 2FA Premium Rate Fraud

A common motivation for this type of fraudulent activity is to route messages through to Premium Rate numbers or virtual numbers created by fraudsters as unofficial premium numbers. In order to understand how this fraud is perpetrated, let's first walk through a typical high-level workflow for implementing 2FA via SMS.

1. A customer signs up or creates an account for an application
2. As part of the sign-up/account creation process, the customer specifies a mobile number to be used for 2FA purposes
3. On subsequent logins, as part of the 2FA verification, an SMS is sent to the number with a code that the customer can then enter via the application UI

This kind of basic workflow can be vulnerable to fraud based on non-legitimate traffic, such as routing that traffic to Premium Rate numbers. In order to perpetrate the fraud, at Step 2, a premium rate number can be entered. The fraudsters would then aim to simulate multiple log-ins for this or subsequent account(s), potentially using bots. On each 'login', as part of the 2FA system at Step 3, an SMS would be sent to the Premium Rate number, thus incurring an additional cost for each message far in excess of the cost for a standard message. Fraudsters would typically use bots to sign up for multiple accounts and trigger multiple 2FA SMS messages on each account. The monetary cost of such a fraud could therefore quickly become quite significant.

## Mitigating Against the Fraud - What you can do

There are various ways of mitigating this kind of fraud.

### Rate limiting

One approach could be to limit the number of verification SMS messages sent within a given period of time based on various factors. For example, limiting the number of messages sent to the same number or the same IP address or device id.

While rate limiting can lessen the impact of such a fraud, it may not negate it entirely. Equally important is running a hygiene check on numbers provided for 2FA set-up, helping prevent the source of the fraud itself. This can be achieved through robust input validation.

### Input validation

Looking at the high level workflow from earlier, Step 3 is where the impact of the fraud occurs but the potential for this impact is created earlier, at Step 2, when the Premium Rate number is set up as the number to be used for 2FA. By performing some input validation at this point in the sign-up workflow, it's possible to prevent a Premium Rate number being routed to at Step 3. Let's look at an updated workflow that incorporates input validation:

1. A customer signs up or creates an account for an application
2. As part of the sign-up/account creation process, the customer specifies a mobile number to be used for 2FA purposes

* The specified number is checked against certain pre-set parameters. If the number is deemed to be acceptable according to these parameters, it is added, otherwise it is rejected.

3. On subsequent logins, as part of the 2FA verification, an SMS is sent to the number with a code that the customer can then enter via the application UI

The exact parameters used to identify potentially fraudulent numbers will vary according to the customer base for the application. A common approach is to use country calling codes or number prefix in order to identify from which country a specific number originates.

This type of number information could be used in a couple of ways:

* Only allow numbers from certain countries. This approach is useful if, for example, you know that all of your customers will originate from a specific country that has a high level of regulation of Premium Rate numbers, and so a much lower likelihood for fraud of this type.
* Prevent numbers from [specific countries](https://help.nexmo.com/hc/en-us/articles/360018406532) where you do not operate or hold a client audience.  Additionally, some countries hold a high fraud risk reputation, either due to known Premium Rate number fraud or where monetary kickback  on number fraud is prevalent (with light or no regulation on Premium Rate numbers).

As an aside here, since this fraudulent input is often carried out by bots, implementing a CAPTCHA can prevent some of the fraudulent activity.

## Mitigating Against the Fraud - How we can help

### Use the Vonage Number Insights API

A way of obtaining number identity information is via the Vonage Number Insights API. To do this, we can send a request to the appropriate API endpoint. There are different endpoints for Basic, Standard, and Advanced Insights, with each providing a different level of information about the number. An overview of the differences is available in [this document](https://developer.vonage.com/number-insight/overview#basic-standard-and-advanced-apis). There is also an [API specification](https://developer.vonage.com/api/number-insight) covering all of the endpoints.

The Number Insights API can also be used via the Vonage SDKs. Below is an example of using the Node.js SDK to obtain information on a number via the Advanced Insights endpoint.

```node
vonage.numberInsight.get({level: 'advancedSync', number: '447700900000'}, (error, result) => {
  if(error) {
    console.error(error);
  }
  else {
    console.log(result);
  }
});
```
A typical response from a request to the API would look something like this:

```json
{
  "status": 0,
  "status_message": "Success",
  "lookup_outcome": 0,
  "lookup_outcome_message": "Success",
  "request_id": "55a7ed8e-ba3f-4730-8b5e-c2e787cbb2b2",
  "international_format_number": "447700900000",
  "national_format_number": "07700 900000",
  "country_code": "GB",
  "country_code_iso3": "GBR",
  "country_name": "United Kingdom",
  "country_prefix": "44",
  "request_price": "0.03000000",
  "remaining_balance": "1.97",
  "current_carrier": {
    "network_code": "23410",
    "name": "Telefonica UK Limited",
    "country": "GB",
    "network_type": "mobile"
  },
  "original_carrier": {
    "network_code": "23410",
    "name": "Telefonica UK Limited",
    "country": "GB",
    "network_type": "mobile"
  },
  "valid_number": "valid",
  "reachable": "reachable",
  "ported": null,
  "roaming": "unknown"
}
```

This response contains data points about the number such as `country_code`, `country_code_iso3`, and `country_prefix`, which can be used to identify the country of origin. In addition to country data, other data points can sometimes indicate potentially fraudulent numbers. A `network_type` of `undefined`, or one that alludes to a virtual number, can sometimes be an indicator. Another useful data point is the `reachable` property; if this has a value `unknown`, or something other than `"reachable"`, it could indicate a potentially fraudulent number.

An updated workflow incorporating Number Insights API might look something like this:

1. A customer signs up or creates an account for an application
2. As part of the sign-up/account creation process, the customer specifies a mobile number to be used for 2FA purposes

* Make a HTTP request to the Number Insights API to obtain information on this number
* Use the data in the response to check the number against certain pre-set parameters. If the number is deemed to be acceptable according to these parameters, it is added, otherwise it is rejected.

3. On subsequent logins, as part of the 2FA verification, an SMS is sent to the number with a code that the customer can then enter via the application UI

Although using the Number Insight API to help identify potentially fraudulent numbers can have some immediate benefits in terms of fraud mitigation, this approach is unfortunately somewhat limited in terms of overall impact. The information provided by Number Insights is highly dependent on individual providers. There are also tricky decisions to be made regarding which data points to use; blocking entire countries, for example, may not be an option for business reasons, even if numbers originating from those countries carry a greater risk of fraudulent activity.

Another step, which can provide longer-term and more overarching mitigation, is contributing to robust routing data via the Vonage Conversion API.

### Use the Vonage Conversion API

The [Conversion API](https://developer.vonage.com/messaging/conversion-api/overview/node) allows you to tell Vonage about the reliability and quality of your 2FA communication.  

Conversion, in the context of 2FA, is a measure of whether the authentication code sent to the customer was actually used or not. If it was used, then this is considered to be a conversion.

Since the objective for fraudsters is for the SMS to be sent rather than actually using the code, low conversion rates of your 2FA can be a strong indicator of fraudulent interception in your communication link and help identify attacked routes.  When using the Conversion API, your conversion rate data can be fed into Vonage’s Adaptive Routing™ algorithm, which diverts traffic away from the fraud impacted route to another unaffected route. The Adaptive Routing™ algorithm automatically determines the best carrier routes to deliver SMS and voice calls at any specific moment.

Within the high-level workflow, the Conversion API would come into play at Step 3. Once the customer enters the verification code into the application, details of this action can be received via a webhook associated with the action. A more detailed overview of a typical 2FA workflow is available in [this document](https://developer.vonage.com/messaging/us-short-codes/guides/2fa/). For the purposes of our high-level workflow, an updated version might look something like this:

1. A customer signs up or creates an account for an application
2. As part of the sign-up/account creation process, the customer specifies a mobile number to be used for 2FA purposes

* Make a HTTP request to the Number Insights API to obtain information on this number
* Use the data in the response to check the number against certain pre-set parameters. If the number is deemed to be acceptable according to these parameters, it is added, otherwise it is rejected.

3. On subsequent logins, as part of the 2FA verification, an SMS is sent to the number with a code that the customer can then enter via the application UI

* Once confirmation that the customer has successfully entered the verification code has been received via the associated webhook, send a HTTP request containing the relevant message-id to the Conversion API.


Please contact your account manager or sales when you are ready to implement the Conversion API.