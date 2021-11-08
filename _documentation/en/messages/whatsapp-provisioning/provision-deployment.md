---
title: Provision a WhatsApp deployment
meta_title: Provision a WhatsApp deployment and perform OTP verification with the WhatsApp Provisioning API. 
description: Use the WhatsApp Provisioning API to provision your WHatsApp deployment and perform one time password (OTP) verification. 
navigation_weight: 3
---

# Provision the WhatsApp deployment

## Before you begin

Prior to deploying the WhatsApp cluster, you must gather some information from the **Settings** page on the [WhatsApp Business dashboard](https://business.facebook.com/settings), including:

WhatsApp Business Account ID

1. Navigate to your [business settings](https://business.facebook.com/settings) page and select **Accounts > WhatsApp Accounts**.
2. Select the WhatsApp Business account you are provisioning.
3. Your WhatsApp Business Account ID is located at the top of the page, below WhatsApp Business Account Name.

Phone Number

1. Navigate to your [business settings](https://business.facebook.com/settings) page and select **Accounts > WhatsApp Accounts**.
2. Select the WhatsApp Business account you are provisioning.
3. Under the **Settings** tab, open **WhatsApp Manager > Phone numbers**.
4. Locate the desired phone number in the list.

Certificate (associated with your phone number)

1. Navigate to your [business settings](https://business.facebook.com/settings) page and select **Accounts > WhatsApp Accounts**.
2. Select the WhatsApp Business account you are provisioning.
3. Under the **Settings** tab, open **WhatsApp Manager > Phone numbers**.
4. Locate the desired phone number in the list.
5. Click the **View** button (in the **Certificate** column).
6. Copy the associated certificate to your clipboard and paste it in a separate document. You will need it in a subsequent step.

## Install  the Vonage CLI

```partial
source: _partials/reusable/install-vonage-cli.md
```

## Create a Vonage Application

A Vonage API application contains the security and configuration information you need to connect to Vonage endpoints and use the Vonage APIs. In this case, you must create an application that uses the Vonage Messages API.

> Note: Your WhatsApp account must be connected to your Vonage account before you can link it to a Vonage application. You can connect your WhatsApp account to your Vonage account via the [Vonage API Dashboard](https://dashboard.nexmo.com/messages/social-channels).

* Both CLI and Dashboard examples are [here](https://developer.vonage.com/messages/code-snippets/create-an-application)


## Generate your JWT

```partial
source: _partials/reusable/generate-a-jwt.md
```

### Provision WhatsApp Deployment

Key | Description
---|---
`country_code` | The international dialing code of the number being provisioned.
`number` | The WhatsApp number being provisioned.
`vname_certificate` | The certificate, which you can retrieve from your WhatsApp Business dashboard. > **NOTE:** Each time you click the **View** button, the certificate will change. Either download or copy your certificate so you can use it in a subsequent step.
`method` | The method for delivering the one time password (OTP). Must be either `sms` or `voice`.
`waba_id` | The WhatsApp Business Account ID of the WhatsApp Number.

```
curl -X POST https://api.nexmo.com/v0.1/whatsapp-manager/deployments\
  -H "Authorization: Bearer "$JWT\
  -H "Content-Type: application/json"\
  -d '{
        "country_code": "44",
        "number": "7877001122",
        "vname_certificate": "CnQKMAj669nb79e",
        "method": "sms",
        "waba_id": "345676589250625"
      }'
```

Once provisioned, the WhatsApp cluster progresses through the following deployment stages: `INITIALIZING`, `CREATING_CLUSTER` and `CLUSTER_CREATE`D. When the `CLUSTER_CREATED` stage is reached an OTP voice call or SMS is sent to the specified number and the deployment status becomes `CODE_SENT`. When the OTP is received, call the Verify API to complete the process.

### Verify OTP

Key | Description
---|---
`code` | The one time password being submitted for verification.

```
curl -X POST https://api.nexmo.com/v0.1/whatsapp-manager/$DEPLOYMENT_ID/verify\
  -H "Authorization: Bearer "$JWT\
  -H "Content-Type: application/json"\
  -d '{ "code": "$CODE" }'
```

Now that the WhatsApp cluster has been successfully deployed, you may manage your [WhatsApp Business profile](/messages/whatsapp-provisioning/manage-profile).

## Reference

* [Understanding WhatsApp messaging](/messages/concepts/whatsapp)
* [External Accounts API Reference](/api/whatsapp-provisioning)
