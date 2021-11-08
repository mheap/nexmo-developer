---
title: Add users to the conversation
description: Add your two new users as Conversation members
---

# Add Users to the Conversation

You must now add your [Users](/conversation/concepts/user) as [Members](/conversation/concepts/member) of the [Conversation](/conversation/concepts/conversation) using Vonage CLI. 
To add `USER1_NAME` to the conversation replace `CONVERSATION_ID` in the command below with your conversation Id generated previously (`CON-...`) and run the command:

```sh
vonage apps:conversations:members:add CONVERSATION_ID USER_ID
```

The output is ID of the Member:

```
Member added: MEM-aaaaaaa-bbbb-cccc-dddd-0123456789ab
```

Now you need to add the second user, `USER2_NAME` to the Conversation. Similarly, replace the `CONVERSATION_ID` and execute the command:

```sh
vonage apps:conversations:members:add CONVERSATION_ID USER_ID
Member added: MEM-eeeeeee-...
```
