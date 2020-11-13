---
title: Send an MMS
meta_title: Send an MMS using the Messages API
---

# Send an MMS

> **Action Needed For Vonage Customers Using US Shared Short Codes**
>
> **Effective immediately, Vonage will no longer accept new programs for Shared Short Codes for A2P messaging.** T-Mobile and AT&T’s new code of conduct prohibits the use of shared originators, therefore, existing Shared Short Code traffic must be migrated by March 1, 2021. To help you with this transition, please use the Vonage [guide to alternatives](https://help.nexmo.com/hc/en-us/articles/360050905592).  Please [contact us](mailto:support@nexmo.com) to migrate to a new solution.

In this code snippet you will see how to send an MMS using the Messages API.

> **IMPORTANT:** Only US Short codes are currently supported for sending MMS.

## Example

Ensure the following variables are set to your required values using any convenient method:

| Key           | Description  |
| ---- | ---- |
| `FROM_NUMBER` | The phone number you are sending the MMS from. (US Short Code only) |
| `TO_NUMBER`   | The phone number you are sending the message to. |
| `IMAGE_URL`     | The URL of the media you want to send. Accepted file formats are `.jpg`, `.jpeg`, `.png`, and `.gif`. |

> **NOTE:** Don't use a leading `+` or `00` when entering a phone number, start with the country code, for example 14155550105.

```code_snippets
source: '_examples/messages/mms/send-mms'
application:
  type: messages
  name: 'Send an MMS'
```

## Try it out

When you run the code an MMS message is sent to the destination number.
