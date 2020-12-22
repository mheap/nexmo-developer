---
title:  获取对话
description:  在此步骤中，您将用户加入对话中

---

获取对话
====

拥有有效的用户令牌后，是时候初始化新的 `NexmoClient` 实例并获取用于聊天应用的对话了。

```javascript
async function run(userToken) {
  let client = new NexmoClient({ debug: true });
  let app = await client.login(userToken);
  conversation = await app.getConversation(CONVERSATION_ID);
}
```

