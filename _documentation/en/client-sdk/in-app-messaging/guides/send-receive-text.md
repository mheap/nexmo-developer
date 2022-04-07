---
title: Send and Receive Text Messages
navigation_weight: 3
---

# Send and Receive Text Messages

## Overview

This guide covers sending and receiving messages within a conversation.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```


This guide will make use of the following concepts:

- **Conversation Events** - `message` events that fire on a Conversation, after you are a Member


## Send a Text Message

Given a conversation you are already a member of:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/send-text
```

## Receive a Text Message

A `message` conversation event will be received when a member sends a text message to a conversation:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/receive-text
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)