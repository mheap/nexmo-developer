---
title: Create the users
description: In this step you learn how to create the Users that will participate in the Conversation.
---

# Create the Users

Each participant in a [Conversation](/conversation/concepts/conversation) is represented by a [User](/conversation/concepts/user) object and must be authenticated by the Client SDK. In a production application, you would typically store this user information in a database.

Execute the following commands to create two users, `Alice` and `Bob` who will log in to the Vonage Client and participate in the in-app voice call (Conversation).

```bash
vonage apps:users:create Alice
vonage apps:users:create Bob
```

This will return user IDs similar to the following:

```sh
User created: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

Make a note of these as you'll need them later.
