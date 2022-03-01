---
title: Send an MMS
meta_title: Send an MMS using the Messages API
---

# Send an MMS

In this code snippet you will see how to send an MMS using the Messages API.

> **IMPORTANT:** Only US short codes and 10DLC numbers are currently supported for sending MMS. For 10DLC, MMS messages can be sent to AT&T, T-Mobile (previously Sprint), and Verizon networks in the US. [Find out more about setting up 10DLC numbers](/messaging/sms/overview#important-10-dlc-guidelines-for-us-customers) (note: this page references the SMS API, but the contents of the 10 DLC guidelines section also apply to the Messages API).
>
> Some advantages of using 10DLC include higher message throughput, better deliverability, and higher SMS message volumes. See the [Vonage 10DLC overview](https://www.vonage.co.uk/communications-apis/sms/features/10dlc/) for more information.

## Example

Ensure the following variables are set to your required values using any convenient method:

```snippet_variables
- FROM_NUMBER.MMS.MESSAGES
- TO_NUMBER
- IMAGE_URL.MMS.MESSAGES
```

> **NOTE:** Don't use a leading `+` or `00` when entering a phone number, start with the country code, for example 14155550105.

```code_snippets
source: '_examples/messages/mms/send-mms'
application:
  type: messages
  name: 'Send an MMS'
```

## Try it out

When you run the code an MMS message is sent to the destination number.
