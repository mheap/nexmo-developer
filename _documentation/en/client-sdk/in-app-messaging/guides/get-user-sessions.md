---
title: Get User Sessions
navigation_weight: 10
---

# Get User Sessions

## Overview

This guide covers how to get the a user's active [sessions](/conversation/concepts/session), which can be used as a way to show an online status. 

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app) and you are able to [create a conversation](/client-sdk/in-app-messaging/guides/simple-conversation).

```partial
source: _partials/client-sdk/messaging/chat-app-tutorial-note.md
```

### Get a User's Sessions

Given a user's ID you can get their sessions. The call to get a user's sessions is [paginated](/client-sdk/in-app-messaging/guides/handling-pagination/).

```tabbed_content
 source: '_tutorials_tabbed_content/client-sdk/guides/get-user-sessions'
 frameless: false
```

If the sessions page contains a session object, you can assume that the user has been recently connected to the Vonage Client SDK. 

