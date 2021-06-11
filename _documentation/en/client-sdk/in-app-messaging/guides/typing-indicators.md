---
title: Typing Indicators
navigation_weight: 6
---

# Typing Indicators


## Overview

This guide covers text typing indicators within a conversation.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```

This guide will make use of the following concepts:

- **Conversation Events** - `text:typing:on` (start typing) and `text:typing:off` (stop typing) events that fire on a Conversation, after you are a Member


## Typing Indicators

Typing Indicators are used to notify conversation members on whether or not a member is currently typing a text message.

### Send typing state events

Set the Member's current typing (on/off) state when they start or stop typing a text message:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/typing-indicators-producer
```

### Listen for the state of other members

The following will listen for the typing (on/off) events created by the above calls:

```tabbed_content
source: _tutorials_tabbed_content/client-sdk/guides/messaging/typing-indicators-consumer
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)
