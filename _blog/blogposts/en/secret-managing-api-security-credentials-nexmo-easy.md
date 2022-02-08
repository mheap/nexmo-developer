---
title: "It’s No Secret: Managing API Security Credentials with Nexmo Is Easy"
description: "For enterprise developers, the Nexmo platform has a feature that
  allows them to deploy two API secrets for their accounts at the same time:
  Secret Rotation."
thumbnail: /content/blog/secret-managing-api-security-credentials-nexmo-easy/API-Security.png
author: oleksandr-bodriagov
published: true
published_at: 2018-10-05T16:00:58.000Z
updated_at: 2021-05-03T22:05:45.360Z
category: tutorial
tags:
  - secret-management-api
comments: true
redirect: ""
canonical: ""
---
If you're a developer who builds and maintains applications for a large enterprise, you likely have a set of policies that govern how often your team needs to update the security credentials for any APIs that your apps utilize. Large enterprises often enforce these policies to minimize the possibility of someone outside the organization gaining access to the APIs and using their accounts for fraudulent activity. 

Nexmo, the Vonage API Platform, provides all developers with API secrets so they can securely make calls from their accounts as well as control who among their internal users has access to those accounts. For enterprise developers, the Nexmo platform now has a feature that allows them to deploy two API secrets for their accounts at the same time: [Secret Rotation](https://developer.nexmo.com/api/account/secret-management). 

With Secret Rotation, enterprise developers can create, test, and deploy new API secrets without having to bring down an application or service. This allows enterprise developers to update their API credentials regularly—maintaining a high degree of security—without disruption. 

Nexmo provides the Secret Rotation feature through the [Secret Management API](https://developer.nexmo.com/api/account/secret-management), which enables:

* programmatic management of API secrets.
* control of API secret renewal frequency.
* control of secondary API secrets.

## How Secret Rotation Works

Each Nexmo account can maintain two API secrets at any given time. With the Secret Management API, you can create a second API secret and test it before revoking the existing API secret in your production network. This secret renewal procedure is in line with [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html) (NIST.SP.800-63b). 

![image explaining how the secret rotation works](/content/blog/it’s-no-secret-managing-api-security-credentials-with-nexmo-is-easy/image3-1-.png "secret rotation")

\*\* Nexmo does not set any limits on API secret lifetime. API secret expiration is left entirely to customer discretion.

## Create Secondary Account Secrets

Nexmo secondary accounts are an enterprise feature that facilitates differential product configuration, reporting, and billing. The Secret Management API allows you to [manage secondary](https://www.nexmo.com/blog/2016/06/29/new-user-management-features-in-the-nexmo-dashboard/) API secrets if the secondary accounts belong to your primary account. As depicted in the diagram below, you can programmatically create secrets for any of your secondary accounts by supplying your primary account credentials in the API call.

![primary account image](/content/blog/it’s-no-secret-managing-api-security-credentials-with-nexmo-is-easy/primaryaccount.png "primary account")

![create secret screenshot](/content/blog/it’s-no-secret-managing-api-security-credentials-with-nexmo-is-easy/createsecret.jpeg "create secret for subaccount")

## Manage Secondary Account Secrets

The Secret Management API acts as a single point of management for secondary API secrets and simplifies the programmatic initialization of secondary accounts. You can create, test, roll out, and revoke secrets for secondary accounts with your primary account credentials. Users of the Secret Management API just need to bear these important specifications in mind:

1. The secondary accounts need to belong to your primary account.
2. Any secondary account should have at least one API secret but no more than two simultaneously. API secrets should conform to [minimal complexity requirements](https://developer.nexmo.com/api/account/secret-management#createSecret).

For more information on how you can start using Secret Rotation, visit our [Secret Management API documentation page](https://developer.nexmo.com/api/account/secret-management).