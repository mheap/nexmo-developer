---
title:  通过故障转移发送 Facebook 消息
description:  在此步骤中，您将学习如何使用 Dispatch API，通过自动故障转移到短信来发送 Facebook 消息。此步骤展示了简单的工作流，如果 600 秒后仍未读取 `messenger` 消息，则会发生自动故障转移，然后发送短信。

---

通过故障转移发送 Facebook 消息
====================

向 Dispatch API 端点提出一个请求，即可通过故障转移到另一个渠道来发送 Facebook 消息。

在本示例中，您将实现以下工作流：

1. 使用 Messages API 向用户发送 Facebook Messenger 消息。
2. 如果 600 秒后仍未读取 Facebook Messenger 消息，则工作流将故障转移到后续步骤。
3. 使用 Messages API 向用户发送短信。`FROM_NUMBER` 是您发送消息使用的号码。`TO_NUMBER` 是接收方的电话号码。

|键 | 说明|
|-- | --|
|`FROM_NUMBER` | 您发送消息使用的电话号码。 **输入电话号码时请勿使用前导 `+` 或 `00`，以国家/地区代码开头，例如，447700900000。** |
|`TO_NUMBER` | 接收方的电话号码。 **输入电话号码时请勿使用前导 `+` 或 `00`，以国家/地区代码开头，例如，447700900000。** |
|`FB_SENDER_ID` | 您的页面 ID。`FB_SENDER_ID` 与您在入站消息 Webhook URL 上的入站消息事件中收到的 `to.id` 值相同。|
|`FB_RECIPIENT_ID` | 您要回复的用户的 PSID。`FB_RECIPIENT_ID` 是您要向其发送消息的 Facebook 用户的 PSID。此值是您在入站消息 Webhook URL 上的入站消息事件中收到的 `from.id` 值。|

示例
---

```code_snippets
source: '_examples/dispatch/send-facebook-message-with-failover'
```

