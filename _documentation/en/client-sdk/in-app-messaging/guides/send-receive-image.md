---
title: Send and Receive Images
navigation_weight: 4
---

# Send and Receive Images

## Overview

This guide covers sending and receiving images within a conversation.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```

This guide will make use of the following concepts:

- **Conversation Events** - `message` events that fire on a Conversation, after you are a Member

## Send an Image

Given a conversation you are already a member of:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/send-images
```

## Receive an Image URL

A `message` conversation event will be received when a member sends an image to a conversation:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/receive-image-urls
```

## Download images from Vonage

### Web client

To download an image you need you use the [fetch image](https://developer.nexmo.com/sdk/stitch/javascript/ImageEvent.html#fetchImage__anchor) method.

### Mobile client (Android, iOS)

To download an image you need to add JWT to the image retrieval request. The JWT is passed as an Authorization header (`Authorization: Bearer <JWT>` format). This is the JWT that was used to log in the user. 

Various image libraries are handling request headers differently, so below you will full example for the most popular libraries. Notice the JWT being set as the `Authorization` header for the request:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/download-images
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)
