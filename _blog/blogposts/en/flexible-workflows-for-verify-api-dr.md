---
title: Flexible Workflows for Verify API
description: "Nexmo’s Verify API is designed to allow you to confirm that a user
  has supplied a correct and valid phone number, by sending them a PIN code and
  asking them to input it. "
thumbnail: /content/blog/flexible-workflows-for-verify-api-dr/E_Flexible-Workflows_1200x600-1.jpg
author: lornajane
published: true
published_at: 2019-10-02T08:00:01.000Z
updated_at: 2021-05-07T14:16:12.714Z
category: tutorial
tags:
  - verify-api
comments: true
redirect: ""
canonical: ""
---
Nexmo's [Verify API](https://developer.nexmo.com/verify/overview) is designed to allow you to confirm that a user has supplied a correct and valid phone number, by sending them a PIN code and asking them to input it.

By default this is done by first sending an SMS with the PIN code in it, and following this with a phone call with a spoken message containing the PIN. Finally, a second phone call is made in an attempt to reach the user.

Having this multi-step, multi-mode process really improves the success rates of verifying the user's phone number. However we know that this isn't the best possible workflow for every user so Verify API now has a new feature: Configurable Workflows.

## Control the Verify Workflow

For each user you need to send a PIN code to, the "right" workflow might be different. That's why Verify API now allows you to specify a `workflow_id` when you make the API call, allowing you to choose from any of five possible workflow patterns.

The additional parameter is added alongside the existing ones, so your API call looks something like this (in Node.js):

```javascript
nexmo.verify.request({
  number: RECIPIENT_NUMBER,
  brand: BRAND_NAME,
  workflow_id: WORKFLOW_ID
}, (err, result) => {
  if (err) {
    console.error(err);
  } else {
    const verifyRequestId = result.request_id;
    console.log('request_id', verifyRequestId);
  }
});
```

You will also find this [code snippet in other languages](https://developer.nexmo.com/verify/code-snippets/send-verify-request-with-workflow) on the Nexmo Developer Portal

The `workflow_id` can be any integer between 1 and 5, and here are the workflows that these numbers represent:

### Workflow 1 (Default Workflow): SMS -> TTS -> TTS

Send a PIN code by text message, follow up with two subsequent voice calls if the request wasn't already verified. This is the default behaviour and probably a sound choice if you're not sure which to pick.

### Workflow 2: SMS -> SMS -> TTS

Send a PIN code by text message, follow up with a second text message and finally a voice call if the request has not been verified. For geographies and/or users where SMS is preferable to a voice call.

### Workflow 3: TTS -> TTS

Call the user and speak a PIN code, follow up with a second call if the request wasn't already verified. If you already know that a phone call works best for this user's situation, a phone call with a retry is a good way to reach them.

### Workflow 4: SMS -> SMS

Send a PIN code by text message, follow up with a second text message if the code hasn't been verified. Ideal for users that don't like phone calls. Including, but not limited to, millenials.

### Workflow 5: SMS -> TTS

Send a PIN code by text message, follow up with a voice call if the code hasn't been verified. Offering both text and speech but with only one attempt at each one includes lots of people without being too intrusive.

## Make the Most of Your Reach

Adjusting your application to make use of the best workflow for your use case (or even using different options for different customers) can really improve the verification rates of your customers.

We're super excited to have this feature publicly available - let us know how you changed your workflows and why! You can always find us on Twitter [@NexmoDev](https://twitter.com/NexmoDev), email us [devrel@nexmo.com](mailto:devrel@nexmo.com) or ask a question in the `#verify-api` channel on the [Nexmo Community Slack](https://developer.nexmo.com/community/slack).