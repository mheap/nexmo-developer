---
title: 10 DLC guidelines for US customers
navigation_weight: 6
description: Understanding 10 DLC guidelines for US based SMS.
---

# Important 10 DLC guidelines for US customers

10 DLC stands for 10 Digit Long Code. Major US carriers have announced their requirements for a new standard for application-to-person (A2P) messaging in the USA, which applies to all messaging over 10 digit geographic phone numbers, also know as 10 DLC. This new standard provides many benefits including supporting higher messaging speeds and better deliverability.

Customers using the Vonage SMS API to send traffic from a **+1 Country Code 10 Digit Long Code into US networks** will need to register a brand and campaign in order to get approval for sending messages. 

> **Note:** US numbers can no longer be shared across brands which include both geographic numbers and US Shared Short Codes.

> Vonage customers using US shared short codes:
T-Mobile and AT&T’s new code of conduct prohibits the use of shared originators, therefore, **Shared Short codes** will no longer be an acceptable format for A2P messaging.
    
    * Vonage customers using a Shared Short Code must migrate SMS traffic to either a [10 DLC](https://help.nexmo.com/hc/en-us/articles/360027503992-US-10-DLC-Messaging), [Toll Free SMS Number](https://help.nexmo.com/hc/en-us/articles/115011767768-Toll-free-Numbers-Features-Overview), or  [Dedicated Short Code](https://help.nexmo.com/hc/en-us/articles/360050950831). 
    * Vonage customers using our Shared Short Code API ***must migrate*** to either our [SMS API](/messaging/sms/overview) or [Verify API](/verify/overview).
    * Customers using Dedicated Short Codes are not affected by these changes within the scope of 10 DLC.

To learn more about 10 DLC including important dates and carrier-specific information, see the knowledge base.

If you have decided moving to 10 DLC is right for your campaigns, you must:
    1. [Register your brand](#register-a-brand)
    2. Register a campaign (coming soon)
    3. Link a number (coming soon)

## Register a brand

1. Navigate to [Vonage API dashboard > SMS > Brands and campaigns](https://dashboard.nexmo.com/sms/brands).
2. Click **Register a new brand**.
3. Fill in all required fields on the **Register a new brand** form.
4. Click **Review details**. A confirmation dialog box opens.
5. Review your brand details.
6. Click **Register and pay**.
    
    > **Note:** You will not be able to change your brand details after registering.
	Your brand information is displayed in the Brand list on the Brands and campaigns page where you can monitor the status of its registration and view more details.
