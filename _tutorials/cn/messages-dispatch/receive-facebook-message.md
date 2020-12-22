---
title:  接收 Facebook 消息
description:  在此步骤中，您将学习如何接收 Facebook 消息。

---

接收 Facebook 消息
==============

首先，请确保您的 Webhook 服务器正在运行。它应 **同时** 正确处理[入站消息回调](/messages/code-snippets/inbound-message)和[消息状态回调](/messages/code-snippets/message-status)，然后至少一个 `200` 以确认每个回调。您将需要实施此操作，以便获取发送入站消息的 Facebook 用户的 PSID。获取后，您将能够回复。

当 Facebook 用户将 Facebook 消息发送到您的 Facebook 页面时，回调将发送到入站消息 Webhook URL。回调示例如下所示：

```json
{
  "message_uuid":"aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "to":{
    "type":"messenger",
    "id":"0000000000000000"
  },
  "from":{
    "type":"messenger",
    "id":"1111111111111111"
  },
  "timestamp":"2020-01-01T14:00:00.000Z",
  "message":{
    "content":{
      "type":"text",
      "text":"Hello from Facebook Messenger!"
    }
  }
}
```

您需要在此处提取 `from.id` 值，因为它是发送回复所需的 ID。

