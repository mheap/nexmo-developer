---
title: Delivered and Seen Receipts
navigation_weight: 5
---

# Delivered and Seen Receipts

## Overview

This guide covers delivered and seen receipts within a conversation.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```

This guide will make use of the following concepts:

**Conversation Events:**

* `message:delivered` events that fire on a Conversation, after you are a Member
* `message:seen` events that fire on a Conversation, after you are a Member

## Set Message Status to Delivered

There is a method that will set a `Message` status to delivered. The following code snippet will set a messages's status to delivered once a message event happens in the conversation.

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/delivered-set-status
```

## Message Delivered Receipt

Given a conversation you are already a member of, `message:delivered` events will be received when `Message` events are set to delivered in the context of the current conversation:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/delivered-receipt
```

## Set Message Status to Seen

There is a method that will set a `Message` status to seen. The following code snippet will set a messages's status to seen once a message event happens in the conversation.

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/seen-set-status
```

## Message Seen Receipt

Given a conversation you are already a member of, `message:seen` events will be received when `Message` events are set to seen in the context of the current conversation:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/seen-receipt
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)
