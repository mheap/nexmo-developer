---
title: Nexmo’s Node.js Server SDK Added Support for Host Overriding
description: Nexmo has recently released v2.6.0 of our Node.js SDK and added the
  ability to change the host used for making the HTTP requests.
thumbnail: /content/blog/nexmo-node-server-sdk-support-host-overriding-dr/nodejs-sdk-update-2400x1200-1.png
author: laka
published: true
published_at: 2020-01-17T18:14:46.000Z
updated_at: 2021-04-27T15:24:14.972Z
category: release
tags:
  - node
  - sdk
  - javascript
comments: true
redirect: ""
canonical: ""
---
We've recently released [v2.6.0 of our Node.js SDK](https://www.npmjs.com/package/nexmo) and added the ability to change the host used for making the HTTP requests.

## Why?

This feature allows you to override the default hosts, `api.nexmo.com` and `rest.nexmo.com`, in the SDK. One of the most common uses cases for this feature is bypassing the load balancer, and making the HTTP requests towards one of our location-specific Data Centres, for example, `api-sg-1.nexmo.com`.

Let's take a look at our ["Make an outbound call with an NCCO"](https://developer.nexmo.com/voice/voice-api/code-snippets/make-an-outbound-call-with-ncco/node) Code Snippet and change it to use the Singapore Data Centre when making the phone call.

```javascript
const Nexmo = require('nexmo')

const nexmo = new Nexmo({
  apiKey: NEXMO_API_KEY,
  apiSecret: NEXMO_API_SECRET,
  applicationId: NEXMO_APPLICATION_ID,
  privateKey: NEXMO_APPLICATION_PRIVATE_KEY_PATH
}, {
  apiHost: 'api-sg-1.nexmo.com'
})

nexmo.calls.create({
  to: [{
    type: 'phone',
    number: TO_NUMBER
  }],
  from: {
    type: 'phone',
    number: NEXMO_NUMBER
  },
  ncco: [{
    "action": "talk",
    "text": "This is a text to speech call from Nexmo"
  }]
});
```

Looking closely, the only change we made to the code snippet was adding an options object in the `Nexmo` instance, with an `apiHost` property.

Another common use case for this feature is using a proxy or gateway to inspect your requests before they get passed on to the Nexmo API. Let's use [curlhub](https://curlhub.io/) to inspect all our API traffic.

![curlhub interface](/content/blog/nexmo’s-node-js-server-sdk-added-support-for-host-overriding/curlhub.png "curlhub interface")

After you sign up, curlhub gives you a `Bucket Id`. For example, `n43s3qc13thd`. That gets appended to any host you want to proxy. So if we want to proxy `api.nexmo.com`, the corresponding curlhub host is `api-nexmo-com-n43s3qc13thd.curlhub.io`. The same logic applies for `rest.nexmo.com`, and the corresponding curlhub host is `rest-nexmo-com-n43s3qc13thd.curlhub.io`.

In order to use those as the proxies for the requests our SDK makes, we'll have to add the `apiHost` and `restHost` properties to our `new Nexmo` instance.

```javascript
const Nexmo = require('nexmo')

const nexmo = new Nexmo({
  apiKey: NEXMO_API_KEY,
  apiSecret: NEXMO_API_SECRET,
  applicationId: NEXMO_APPLICATION_ID,
  privateKey: NEXMO_APPLICATION_PRIVATE_KEY_PATH
}, {
  apiHost: 'api-nexmo-com-n43s3qc13thd.curlhub.io',
  restHost: 'rest-nexmo-com-n43s3qc13thd.curlhub.io'
})
```

## What's Next

We're working on improving our Node.js SDK, and you can track our progress at <https://github.com/nexmo/nexmo-node>. If you have any suggestions or issues, please feel free to raise them in GitHub or in our [community slack](https://developer.nexmo.com/community/slack).