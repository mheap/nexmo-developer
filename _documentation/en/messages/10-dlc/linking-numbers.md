---
title: Linking Numbers to 10 DLC Campaigns
meta_title: Linking numbers to 10 DLC campaigns  
description: Provides an in-depth explanation of linking numbers to campaigns including number linking requirements, number pooling, rejected numbers, and how to link numbers to a campaign from the Vonage API Developer Dashboard. 
navigation_weight: 6
---

# Linking numbers to 10 DLC campaigns

The final step in your 10 DLC registration process is linking your numbers to your approved campaign ID. You can either [purchase new numbers](https://dashboard.nexmo.com/buy-numbers) or use the numbers you already have under [your account](https://dashboard.nexmo.com/your-numbers).

In this section, you will learn about:

* [Linking a number to a campaign](#linking-a-number-to-a-campaign-from-the-vonage-api-developer-dashboard)
* [Number pooling](#number-pooling)
* [Rejected numbers](#rejected-numbers)

## Linking a number to a campaign from the Vonage API Developer Dashboard

1. Navigate to [Vonage API dashboard > Brands and campaigns](https://dashboard.nexmo.com/sms/brands).
2. Select an existing brand.
3. Select the **Campaigns** tab.
4. Select an existing campaign in the list.
5. Select the **Numbers** tab.
6. Search one of your existing numbers or buy a new number.
7. Click the **Link** button corresponding to the number you wish to link to the campaign.
    A **Link number to campaign** dialog box opens on which you can select a check box to make your number HIPPA compliant. Note that if you want your number to be HIPPA compliant, you must first reach out to your Account Manager.
8. Click the **Link** button.
    After you request to link a number to a campaign, the process will take a few minutes to complete. During this time, you will see a **Pending** status in the **State** column on the number you are linking.

## Number pooling

Most campaigns have a limit of 50 LVN (Long Virtual Numbers) linked to it. Carriers would ideally prefer it if users only used a single number. Please note that for most campaign (except 3), the throughput is calculated at the campaign level, not the number itself. So having more numbers linked to the campaign does not increase the amount of messages you can send. See this [knowledge base article](https://help.nexmo.com/hc/en-us/articles/4406782736532) for more information.

### Special Requests

If you need more than 50 numbers linked to the same campaign, you will have to select the **Number Pool** option when creating the campaign. In addition, you have to [open a support ticket](https://help.nexmo.com/hc/en-us/requests/new) in order to start the procedure of requesting a Special Business Review application to be submitted to T-Mobile. Note that the SBR fee is currently waived, but it will be charged $5000 when T-mobile applies the fee.

**Example of Valid Scenario:** Requesting 2000 LVNs linked to a single Agents & Franchise campaign.

## Rejected numbers

If the number shows a **rejected** status after requesting to link it to a campaign on the Numbers tab; it is possible that the campaign has not yet been approved by all carriers.

Check the campaign **Qualification Details** tab to make sure all carriers have approved the campaign. Then, you can **Unlink** the rejected number and **Link** it again to the same campaign. If this does not solve the problem or you receive any other error message, [submit a support ticket](https://help.nexmo.com/hc/en-us/requests/new).
