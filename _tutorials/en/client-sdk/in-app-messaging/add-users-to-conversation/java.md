---
title: Add users to the conversation
description: Add your two new users as Conversation members
---

# Add Users to the Conversation

You must now add your [Users](/conversation/concepts/user) as [Members](/conversation/concepts/member) of the [Conversation](/conversation/concepts/conversation) using Vonage CLI. 
To add Alice to the conversation, replace `CONVERSATION_ID` in the command below with your conversation ID generated previously (`CON-...`) and `ALICE_USER_ID` with the ID generated (`USR-...`) when you created the Alice user in the previous step:

```sh
vonage apps:conversations:members:add CONVERSATION_ID ALICE_USER_ID
```

The output is ID of the Member:

```
Member added: MEM-aaaaaaa-bbbb-cccc-dddd-0123456789ab
```

Now you need to add Bob to the Conversation. Similarly, replace the `CONVERSATION_ID` and `BOB_USER_ID` then run the command:

```sh
vonage apps:conversations:members:add CONVERSATION_ID BOB_USER_ID
Member added: MEM-eeeeeee-...
```