---
title: Send an MMS
meta_title: Send an MMS using the Messages API
---

# Send an MMS

In this code snippet you will see how to send an MMS using the Messages API.

> **IMPORTANT:** Only US short codes, 10DLC numbers and SMS Enabled Toll Free Numbers are currently supported for sending MMS. For US short codes, MMS messages can be sent to AT&T, T-Mobile (previously Sprint), and Verizon networks in the US. [Find out more about setting up 10DLC numbers](/messaging/sms/overview#important-10-dlc-guidelines-for-us-customers) (note: this page references the SMS API, but the contents of the 10 DLC guidelines section also apply to the Messages API).
>
> Message throughput, deliverability, and SMS message volumes may vary depending on the type of number used. For more information on this, and on MMS in general, see the [Vonage MMS overview page](https://www.vonage.co.uk/communications-apis/messages/features/mms/), the [Vonage 10DLC overview page](https://www.vonage.co.uk/communications-apis/sms/features/10dlc/), and the [Vonage Phone Numbers overview page](https://www.vonage.co.uk/communications-apis/phone-numbers/).


## Example

Find the description for all variables used in each code snippet below:

```snippet_variables
- VONAGE_APPLICATION_ID
- VONAGE_APPLICATION_PRIVATE_KEY_PATH
- FROM_NUMBER.MMS.MESSAGES
- VONAGE_NUMBER.MMS.MESSAGES
- VONAGE_FROM_NUMBER
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
