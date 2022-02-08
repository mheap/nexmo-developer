---
title: Provisioning and Sending WhatsApp Stickers with Vonage APIs
description: Learn how to provision stickers for your Vonage WhatsApp business
  account, and how to send a sticker using the Vonage Messages API
thumbnail: /content/blog/provisioning-and-sending-whatsapp-stickers-with-vonage-apis/whatsapp_stickers.png
author: karl-lingiah
published: true
published_at: 2022-01-13T13:54:47.470Z
updated_at: 2022-01-12T14:13:32.724Z
category: tutorial
tags:
  - messages-api
  - whatsapp
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Stickers have been a very popular feature of WhatsApp chats for years now. In this post we'll explain what they are and how to use them in your WhatsApp communications, via the Vonage Messages APIs.

Stickers are visual artifacts that can be used in a WhatsApp chat, similar to emojis, but with larger images. [This article](https://faq.whatsapp.com/android/chats/how-to-use-stickers/), from the official WhatsApp documentation portal, explains how WhatsApp users can download and use stickers.

![Cute WhatsApp dragon sticker](/content/blog/provisioning-and-sending-whatsapp-stickers-with-vonage-apis/whatsapp-sticker.png "Cute WhatsApp dragon sticker")

There are numerous sticker packs already made available by WhatsApp and 3rd party developers. One of the great things about stickers is that anyone can create and publish custom third-party sticker packs. Custom stickers designed around your brand can be a novel and fun way to build brand awareness and customer engagement!

## Creating a Sticker Pack

In order to publish a custom sticker pack, you'll need to create a sticker app and then release this to the Google Play store and/or the Apple App store. We won't go into the details of how to create a sticker app in this post, but a great place to start is this [user guide](https://faq.whatsapp.com/general/how-to-create-stickers-for-whatsapp) in the WhatsApp documentation. The WhatsApp team have also provided a [sample app](https://github.com/WhatsApp/stickers) which you can adapt for your own use.

There are certain requirements for stickers, in terms of sizing, format, and so on, which are listed in the [Android](https://github.com/WhatsApp/stickers/blob/main/Android/README.md) for the repo and [iOS](https://github.com/WhatsApp/stickers/blob/main/iOS/README.md) README documents in the sample app repository.

## Provisioning WhatsApp stickers for use

Once the sticker app has been created and released, your customers can install the app and download your sticker pack for use in their WhatsApp chats. If you want to use the stickers yourself though (for example in WhatsApp messages you send to customers via the Messages API) you first need to provision the sticker pack for use by your WhatsApp Business Account.

Provisioning is carried out via the [Vonage WhatsApp Provisioning API](https://developer.vonage.com/api/whatsapp-provisioning).

If you haven't done so already, the first step is to provision a WhatsApp deployment. This can be done by sending a POST request to the following /whatsapp-manager/deployments endpoint as detailed in the [API specification](https://developer.vonage.com/api/whatsapp-provisioning#createDeployment):

https://api.nexmo.com/v0.1/whatsapp-manager/deployments

More information on provisioning WhatsApp deployments is available in [this document](https://developer.vonage.com/messages/whatsapp-provisioning/provision-deployment).

Provisioning a WhatsApp deployment will provide you with a Deployment ID, which you can then use for various aspects of managing that deployment, including provisioning custom sticker packs for use by your WhatsApp Business Account. Provisioning the sticker pack requires a POST request to the following API endpoint:

https://api.nexmo.com/v0.1/whatsapp-manager/deployments/:deployment_id/stickerpacks

Note: :deployment_id in the path is replaced with the Deployment ID of your WhatsApp deployment.

The request body would look something like this:

```json
{
  "publisher": "your-publisher-name",
  "name": "your-sticker-pack-name",
  "ios_app_store_link": "https://itunes.apple.com/app/id3133333",
  "android_app_store_link": "https://play.google.com/store/apps/details?id=com.example"
}
```

A successful response would include the ID of the deployed sticker pack.

```json
{
  "stickerpacks": [
    {
      "id": "sticker-pack-id1"
    }
  ]
}
```

More details about making requests to this endpoint are available in the [API specification](https://developer.vonage.com/api/whatsapp-provisioning#createStickerpacks).

## Sending a sticker (using the Messages API)

Once your sticker pack is provisioned, you can then use the stickers in a WhatsApp chat. To do this you will need the sticker id for the individual sticker that you want to send. There are a couple of steps required to get this:

1. **Get the sticker index**. This is done via a `GET` request to an endpoint which contains the `deployment_id` and the `stickerpack_id`, and is detailed in [this API specification](https://developer.vonage.com/api/whatsapp-provisioning#getStickers). The response returns an object with an `index` property, the value of which is the sticker index required for the next step.
2. **Get the id for a sticker**. This requires another `GET` request to different endpoint, this time conatining the `deployment_id` and `stickerpack_id` along with the `sticker_index` obtained in the previous step. This request will return an array of sticker objects, each with an `id` property. This endpoint is detailed in [this API specification](https://developer.vonage.com/api/whatsapp-provisioning#getStickerByIndex).

Once you have the `id` of the sticker, you can send it in a WhatsApp message, using the [Vonage Messages API](https://developer.vonage.com/messages/overview).

Sending a sticker involves a POST request to the following endpoint: https://api.nexmo.com/v1/messages.

The JSON payload for the request body might look something like this:

```json
{
   "from":"447700900000",
   "to":"447700900001",
   "channel":"whatsapp",
   "message_type":"custom",
   "custom":{
      "type":"sticker",
      "sticker":{
         "id":"13aaecab-2485-4255-a0a7-97a2be6906b9"
      }
   }
}
```

Note the `channel` being set to `whatsapp` and the `message_type` of custom, as well as the custom object having a `type` of `sticker`, and a sticker object which contains the sticker id obtained earlier.

For more information on using the Messages API, and on sending WhatsApp messages, please refer to the following resources:

* [Messages API specification](https://developer.vonage.com/api/messages-olympus)
* [Understanding WhatsApp messaging](https://developer.vonage.com/messages/concepts/whatsapp)
* [Custom objects](https://developer.vonage.com/messages/concepts/custom-objects)