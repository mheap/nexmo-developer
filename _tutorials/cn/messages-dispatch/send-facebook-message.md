---
title:  发送 Facebook 消息
description:  在此步骤中，您将学习如何发送 Facebook 消息

---

发送 Facebook 消息
==============

然后，您可以使用 Messages API 回应从 Facebook 用户那里收到的入站消息。

请在下面的示例中使用实际值替换下列变量：

|键 | 说明|
|-- | --|
|`FB_SENDER_ID` | 您的页面 ID。`FB_SENDER_ID` 与您在入站消息 Webhook URL 上的入站消息事件中收到的 `to.id` 值相同。|
|`FB_RECIPIENT_ID` | 您要回复的用户的 PSID。`FB_RECIPIENT_ID` 是您要向其发送消息的 Facebook 用户的 PSID。此值是您在入站消息 Webhook URL 上的入站消息事件中收到的 `from.id` 值。|

示例
---

```code_snippets
source: '_examples/messages/messenger/send-text'
```

> **提示** ：如果使用 Curl 测试，将需要 JWT。您可以在有关[创建 JWT](/messages/code-snippets/before-you-begin#generate-a-jwt) 的文档中看到如何创建 JWT 的说明。

