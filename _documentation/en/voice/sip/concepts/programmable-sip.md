---
title: Programmable SIP
---

# Programmable SIP

## Overview

Vonage’s Programmable SIP enables you to integrate your existing SIP Infrastructure with Vonage’s powerful conversational communications platform. This integration will enable you to connect to mobile, landline, SIP and WebRTC endpoints with minimal work, including browsers and mobile applications. It will also bring Voice API functionality, such as multichannel recording, IVR, Text to Speech, WebSocket connectivity for AI integrations, and the power of contextual conversations to your platform.

![SIP Connect Workflow](/images/workflow_sip_connect.png)

## Vonage SIP Domains

A _Vonage SIP Domain_ contains configuration you need to connect to Vonage SIP endpoints and link to your Vonage application.

To route a SIP call to your Vonage application, you need to create a unique Vonage domain, such as `yourcompany`. The domain name will form the SIP URI, for example `sip:number@yourcompany.sip-us.nexmo.com`, and any calls routed to that SIP URI will be routed to your application NCCO `answer_url`.

The authentication method will be determined within your configuration of the Vonage domain. Vonage will authenticate the request and forward it to your application.

Some example domains:

```json
yourcompany.sip-eu.nexmo.com
98765@yourcompany.sip-us.nexmo.com
12345@yourcompany.sip-ap.nexmo.com
```

## Voice Application

To be able to use Programmable SIP you will need to create a Voice-enabled Vonage [Application](/application/overview) first and take note of the Application ID.

## Authentication - Access Control Lists

You can configure an Access Control List for your domain so that your Vonage application will only accept calls from specific endpoints and devices. You do this by adding their IP addresses to an allow list.

## The Programmable SIP API

To provision a domain you can use the Programmable SIP API. The JSON object used to provision a new domain has the following format:

```json
{
  "name": "yourcompany",
  "application_id": "app_id",
  "acl": [
    "xxx.xxx.xxx.xxx/xx", "yyy.yyy.yyy.yyy"
  ]
}
```

`name` should be the desired domain name e.g. `yourcompany`, `application_id` is the id of the Vonage application, for example `c49f3586-9c3c-458b-89fc-3c8beb58865f`. `acl` is a list of IP addresses in CIDR notation like `180.180.180.180/30` and/or single IP address `190.190.190.190`.

An example JSON could thus be:

```json
{
  "name": "yourcompany",
  "application_id": "c49f3586-9c3c-458b-89fc-3c8beb58865f",
  "acl": ["180.180.180.180/30", "190.190.190.190"]
}
```

A full description of the API is available on the [API reference](/api/psip).

## Domain Based Routing

Calls made to a Programmable SIP domain must be handled at a regional level. You must use a Request URI with a regional domain. Please be aware that a Request URI without a regional component in the domain will fail the call.

The following code will indicate to Vonage that you want this SIP call to be handled in the EU:

```
sip:number@yourcompany.sip-eu.nexmo.com
```

Available domains are the same as the A records:

```
sip-us.nexmo.com: USA
sip-eu.nexmo.com: Europe
sip-ap.nexmo.com: Asia Pacific
```

## Custom SIP Headers

You can specify any additional headers you need when sending a SIP Request. Any headers provided must start with `X-` and will be sent to your `answer_url` with a prefix of `SipHeader_`. For example, if you add a header of `X-UserId` with a value of `1938ND9`, Vonage will add `SipHeader_X-UserId=1938ND9` to the request made to your `answer_url`.

> **CAUTION:** Headers that start with `X-Nexmo` are not sent to your `answer_url`.

## Receiving Calls From Vonage

You can use the Voice API NCCO `connect` action to connect a call to your SIP endpoints. 

You may also send Custom SIP Headers to your SIP endpoints using the Voice API NCCO `connect` action.

The detailed documentation is [here](/voice/voice-api/ncco-reference#connect).

## SIP Connect

The SIP Connect feature support will continue where you can dial your virtual number via your SIP endpoint that is attached to your application. _Digest Authentication_ is the accepted authentication method for SIP Connect.

To test this functionality have your PBX forward calls to `sip.nexmo.com`. Here is an example of doing so with an Asterisk extension, transmitting a custom header that will be sent to your `answer_url`:

```
exten => 69100,1,SIPAddHeader(X-UserId:ABC123)
exten => 69100,2,Dial(SIP/nexmo/14155550100)
```

## Further information

* [SIP Overview](/voice/sip/overview)
