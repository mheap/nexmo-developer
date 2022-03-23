---
title: 10 DLC Campaigns Overview
meta_title: 10 DLC campaigns overview 
description: Provides and in-depth explanation of the definition of campaigns, campaign registration requirements, campaign types, campaign vetting requirements, and subscriber information and message content. 
navigation_weight: 5
---

# 10 DLC Campaigns Overview

Campaigns allow carriers to determine the purpose of the messages originating from the numbers assigned to that campaign. Campaigns have a minimum duration of three months. They do not expire until cancelled, and are billed monthly after the first three months. The TCR does not allow for refunds, so when cancelling a campaign, we will keep it active until the end of the period already paid. Campaign applications are sent to all US carriers for approval. Once they have all approved the campaign (which can take up to 7 days), you can link numbers to the campaign.

Campaigns contain information such as:

* Campaign name (label) & description.
* Use case.
* Throughput qualifications agreed for each carrier.
* Sample messages (used by carriers to check adherence to the use case).
* Subscribers opt-in/out records (requirement of 10DLC for most campaigns).
* Number(s) linked to the campaign.
* Other features (age gate, number pooling, links—requires vetting, controlled content).

In this section, you will learn about:

* [Campaign types](#campaign-types)
* [Vetting and approval requirements](#vetting-and-approval-requirements)
* [Subscriber information and message content](#subscriber-information-and-message-content)
* [How to register a campaign from the Vonage API Developer Dashboard](#register-a-campaign-from-the-vonage-api-developer-dashboard)


## Campaign types

There are two types of campaigns:

* **Standard campaigns:** Basic use cases that usually do not require additional review. 
* **Special campaigns:** Use cases that require additional brand vetting or pre/post Mobile Network Operator (MNO) approval. Some use cases require preapproval from Vonage (i.e. Social Media). Requirements for special campaigns differ from use case to use case and registration may require more time. 

### Standard campaigns

Throughput is considered at campaign level. 

| Name      | Description | Examples      | Requirements |
| ----------- | ----------- | ----------- | ----------- |
| 2FA      | Two Factor Authentication. This use case is for any authentication or verification.       | OTP messages      | Subscriber Opt-in, Subscriber help       |
| Account Notification      | Standard notification for account holders, relating to and being about an account.       | Amazon account notifications      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Customer Care      | All customer interaction, including account management and customer support.       | Technical support, Customer services, Travel agents      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Delivery Notifications      | Information about the status of the delivery of a product or service.       | UPS Parcel deliveries      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Fraud Alert Messaging      | Messaging regarding potential fraudulent activity on an account.       | Foreign login notifications, Unusual banking activity      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Higher Education      | Campaigns created on behalf of Colleges or Universities. It also includes School Districts and education institutions that fall outside of any "free to the consumer" messaging model.       | Notifications about next class schedules, Teachers absences      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Marketing      | Any communication with marketing and/or promotional content.       | Promo codes, Adverts, Loyalty schemes      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Polling and voting      | Requests for surveys and voting for non political arenas.       | Voting for X-Factor candidate, Customer Satisfaction surveys      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Public Service Announcement      | An informational message that is meant to raise the audience's awareness about an important issue.       | Electricity outage, Water works, Road traffic information      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Security Alert      | A notification that the security of a system, either software or hardware, has been compromised in some way and there is an action you need to take.       | Password leak, System intrusion      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Mixed      | Any messaging combination of 2 to 5 standard use cases.       | ---      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |
| Low Volume Mixed      | For brands who needs multiple use cases and have very low throughput requirements. **Note: no vetting or throughput increase possible**       | Test or Demo Account, Single doctor office, Independent shop      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help       |

### Special campaigns (Campaign-level throughput considerations)

Throughput is considered at campaign level.

| Name      | Description | Examples      | Requirements |
| ----------- | ----------- | ----------- | ----------- |
| Charity      | Communications from a registered charity aimed at providing help and raising money for those in need. Includes: 5013C Charity. Does not include religious organizations. **Non-profit only.**       | Red Cross, WWF, Greenpeace      | TBD       |
| Emergency      | Notification services designed to support public safety / health during natural disasters, armed conflicts, pandemics and other national or regional emergencies.       | Fire brigade, Weather alerts, Terror attacks      | TBD       |
| K-12 Education      | Campaigns created for messaging platforms that support schools from grades K-12 and distant learning centers.       | K-12 schools only      | TBD       |
| Sweepstakes      | All sweepstakes messaging.       | Contests, Lotteries	      | TBD       |
| Political      | Part of organized effort to influence decision making of specific groups. All campaigns to be verified. Only federal campaigns. **Non-Profit only.**       | Democratic party, Republican party      | TBD       |
| Social      | Social is restricted for Social influencers.       | Youtube influencer notifications, Celebrity alerts      | Subscriber Opt-in, Subscriber Opt-out, Subscriber help, Requires double opt-in       |
| Sole Proprietor      | **Limited to entities without EIN / Tax ID.**       | Developer testing account, Single individual      | 1 Campaign & maximum of 5 numbers, No vetting        |

### Special Campaigns (Per number basis throughput considerations)

Throughput is considered on a per number basis.

| Name      | Description | Examples      | Requirements |
| ----------- | ----------- | ----------- | ----------- |
| Agents and Franchises      | Agents, franchises, local branches. | HSBC's branches, McDonalds' Franchises, Vonage's offices employees      | TBD |
| Carrier Exemptions      | Exemption by Carrier, can only be approved through manual review and or vetting process. | TBD      | TBD |
| Conversational (Proxy)      | Peer-to-peer app-based group messaging with proxy/pooled numbers. Supporting personalized services and non-exposure of personal numbers for enterprise or A2P communications. | Uber app, Deliveroo app      | TBD |

## Vetting and approval requirements

|   Use Case    | Entity Type |   AT&T Supported    | T-Mobile Supported | External Vetting Required AT&T      | External Vetting Required T-Mobile | Vetting Partner      | Approval Required AT&T | Approval Required T-Mobile |
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| Agents and Franchises |  | Yes | Yes | No | No |  | Post Campaign Registration | No |
| Carrier Exemptions |  | Yes | No | No | TBD |  | Post Campaign Registration | TBD |
| Charity | Non-profit only | Yes | Yes | No | No |  | No | No |
| Conversational Messaging |  | Yes | Yes | No | No |  | Post Campaign Registration | No |
| Emergency |  | Yes | Yes | No | No |  | Post Campaign Registration | No |
| Political | Non-profit only | Yes | Yes | Yes (527 Orgs); No (501c c4 orgs) | Yes (527 Orgs); No (501c c4 orgs) | Campaign Verify | No | Post Campaign Registration |
| Social |  | Yes | No | Yes | TBD | Aeigis; WMC Global | Post Campaign Registration | TBD |
| Sweepstakes |  | Yes | Yes | Yes | No | Aeigis; WMC Global | Post Campaign Registration | Post Campaign Registration |
| Platform Free Trial |  | Yes | Yes | No | No |  | No | No |
| Sole Proprietor | Non-profit only | Yes | Yes | No | No |  | No | No |

## Subscriber information and message content

Each campaign registered for 10DLC requires a full Brand and Campaign use case analysis in order to determine registration approval. There may be additional data and message content types that will require additional approvals, like embedded links within the message content. Subscriber management is another key area which will see more requirements from carriers.

|   Name    | Description |
| ----------- | ----------- |
|   Subscriber Opt-in    | Record that the subscriber has opted into the receiving the messages. |
|   Subscriber Opt-out    | The subscriber has the ability to opt-out of receiving messages through keywords e.g., "STOP", "QUIT", etc. |
|   Subscriber Help    | There is a 'help' mechanism through MO help key words such as 'HELP', 'INFO'. |
|   Age Gated    | Message content is age gated. |
|   Direct Lending    | Messages contain direct lending or loan arrangement content. |
|   Affiliate Marketing    | Messages are controlled by an affiliate other than the brand. |
|   Embedded Link    | There is a call-to-action link/URL to be embedded in all messages sent. |
|   Embedded Phone    | There is a call-to-action phone number to be embedded in all messages. |
|   Number Pool    | If a campaign is using over 50 numbers, it needs to be specified as using a Pool as this can be seen as trying to snowshoe. |
|   Minimum Number of Use Cases    | Minimum number of message examples for approval. |
|   Maximum Number of Use Cases    | Maximum number of message examples for approval. |

## Register a campaign from the Vonage API Developer Dashboard

1. Navigate to [Vonage API dashboard > Brands and campaigns](https://dashboard.nexmo.com/sms/brands).
2. Click **Register a new campaign**.
    The **Create a new campaign** page is displayed.
3. Under **Step 2 Use case**, select the check box associated with the use case that best describes this campaign. The use case describes the specific purpose of the campaign; for instance, marketing or account notifications you wish to send to customers.
4. Click **Done**.
5. Under **Step 3 Carrier qualification**, you can determine whether or not your use case has been approved for sending SMS traffic. Qualification is done by 10DLC enabled carriers. If your use case was rejected, or if your throughput is insufficient, you can appeal through Brand Vetting which is done through a 3rd party.
6. Click **Done**.
7. Under Step 4 Campaign details:
    1. In the **Selected brand** field, identify the brand associated with this campaign.
    2. From the **Vertical** drop-down menu, select the vertical associated with your brand.
    3. In the **Campaign description** field, type a brief description of this campaign.
8. Click **Done**.
9. Under **Step 5 Sample messages**, type up to five examples of messages that will be sent for this campaign.
10. Click **Done**.
11. Under **Step 6 Campaign and content attributes**, select the attributes that apply to this campaign. For instance, select **Subscriber opt-out** if messages sent for this campaign provide customers the opportunity to opt-out. Select all attributes that apply.
12. Click **Review and pay**.
    A confirmation dialog box opens summarizing your campaign details. Any charges to your account are indicated above the campaign details. You will not be able to change the campaign details after registering.
13. Click **Register and pay**.
    The campaign is displayed in the **Campaigns** list on the **Brands and campaigns** page.
