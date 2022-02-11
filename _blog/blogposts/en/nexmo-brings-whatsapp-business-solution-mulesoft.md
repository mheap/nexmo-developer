---
title: Nexmo Brings WhatsApp Business Solution to Mulesoft
description: Nexmo has added WhatsApp—and its 1.5 billion monthly users—as a
  messaging channel on Mulesoft Anypoint.
thumbnail: /content/blog/nexmo-brings-whatsapp-business-solution-mulesoft/WhatsApp-MuleSoft-Nexmo_1200x675.jpg
author: oscar-rodriguez
published: true
published_at: 2018-09-26T15:45:31.000Z
updated_at: 2021-05-03T21:46:37.866Z
category: announcement
tags:
  - announcement
comments: true
redirect: ""
canonical: ""
---
One of the great things about being an engineer here at Nexmo is having a front row seat to the development of some really compelling customer engagement solutions. Integrating those solutions with technology partners who then enable their users to build new and innovative customer experience use cases is an added treat. 

Take our partner [Mulesoft](https://www.nexmo.com/partners/mulesoft). We built a connector for their Anypoint Platform earlier this year, enabling users to easily integrate real-time messaging with their enterprise apps and data. Now, we’ve added WhatsApp—and its 1.5 billion active monthly users—as another messaging channel on Mulesoft Anypoint.

Now Anypoint users—from full-time software engineers like me to visual builder types—can not only interact with customers globally on the [world’s most popular messaging app](https://www.statista.com/statistics/258749/most-popular-global-mobile-messenger-apps/) but they can create messaging flows where their messages will fallback to other channels like good ol’ reliable SMS when the initial message doesn’t get a response. And that’s saying nothing of the entirely new communication workflows that users can integrate with their business applications by leveraging our Mulesoft connector. 

We know first-hand how high the demand has been for businesses to get their hands on WhatsApp for Business. Our [WhatsApp Business solution](https://www.nexmo.com/products/messages/whatsapp) launched on August 1 and we’ve gotten an extremely strong response from the market. Who doesn’t want a crack at delighting customers on their favorite messaging app? By adding WhatsApp Business to the Anypoint Platform via Nexmo, Mulesoft is offering its users a direct path to WhatsApp implementation. The Whatsapp platform’s end-to-end encryption can be leveraged for notification and support use cases while maintaining privacy.

## WhatsApp Business Use Cases and Requirements

As an official WhatsApp Business Solution provider, Nexmo will work closely with interested brands to properly onboard them. After that process is complete, the building fun can begin. Via the Nexmo’s MuleSoft connector, businesses can leverage Anypoint to easily integrate WhatsApp into their workflows. Here are just a few of the possibilities:

* Simple opt-in to WhatsApp messaging via SMS
* CRM flows that leverage Salesforce customer records
* Connections to support chat platforms such as Salesforce Service Cloud and ZenDesk
* Flows from commerce/logistics platforms to manage shipment and delivery notifications
* Financial service transactional notifications

If you’re attending [Dreamforce 2018](https://www.salesforce.com/dreamforce/) in San Francisco this week, you can actually see how straightforward it is to build one of these use cases on Mulesoft Anypoint. I’ll be showing a demo of the WhatsApp Business solution in Vonage booth #1843.

![Author at Dreamforce 2018 during my Mulesoft, WhatsApp, Salesforce Demo](/content/blog/nexmo-brings-whatsapp-business-solution-to-mulesoft/kevin-alwell_df2018-mulesoft-whatsapp-sfdc-demo.jpeg "At Dreamforce 2018")

The demo walks through setting up notifications via WhatsApp for customer service. The scenario is:

1. A customer submits a support request to a business and opts in to WhatsApp as a messaging channel where they can receive status updates.
2. The business receives the request and creates a new support ticket for it on their Service Cloud environment. The ticket inherits all the info the customer provided, including a brief description of the issue they’re having.
3. The ticket is routed to a service agent for response. Any time the agent makes a change to the ticket, the customer receives a WhatsApp notification until it’s been resolved.

So, how’s it work under the covers? 

Basically, the Nexmo API Connector leverages MuleSoft Anypoint to complete three fundamental actions. 

First, we **create a ticket on the Service Cloud server** upon receiving the customer’s request. 

![Nexmo Messages API Configuration](/content/blog/nexmo-brings-whatsapp-business-solution-to-mulesoft/image2-1-1200x600.png "Nexmo Messages API Configuration")

[](https://www.nexmo.com/wp-content/uploads/2018/09/image2-1.png)Second, we **listen for changes to the ticket** (the agent’s processing as they work to resolve the issue). [](https://www.nexmo.com/wp-content/uploads/2018/09/image1-1.png)

![The agent’s processing as they work to resolve the issue.](/content/blog/nexmo-brings-whatsapp-business-solution-to-mulesoft/image1-1.png "Nexmo Messaging API")

And lastly, we **execute the WhatsApp notifications** to the customer via our API integration.

![And lastly, we execute the WhatsApp notifications to the customer via our API integration.](/content/blog/nexmo-brings-whatsapp-business-solution-to-mulesoft/image3.png "Notifications")

If you’re not coming to Dreamforce—tough break because my demo is amazing—or if you just want to try it out yourself, consult the [Nexmo API Connector documentation](https://anypoint.mulesoft.com/exchange/78148a1f-068f-4c35-b126-bf68daf9a6b2/nexmo-messages-api/) on Mulesoft.com (you’ll need to log in to your Anypoint Platform account) and the [API documentation](https://developer.nexmo.com/messages-and-workflows-apis/messages/overview) on our site. Now, go build something great!