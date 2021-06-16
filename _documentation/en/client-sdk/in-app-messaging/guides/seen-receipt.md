---
title: Seen Receipt
navigation_weight: 5
---

# Seen Receipt

## Overview

This guide covers seen receipts within a conversation.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```

This guide will make use of the following concepts:

- **Conversation Events** - `text:seen` events that fire on a Conversation, after you are a Member

## Set Text status to seen

There is the `seen()` method on a TextEvent that will set its status to seen. The following code snippet will set a text's status to seen once a text event happens in the conversation.

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/seen-set-status
```

## Text Seen Receipt

Given a conversation you are already a member of, `text:seen` events will be received when members have seen previously received `text` events in the context of the current conversation:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/seen-receipt
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)
