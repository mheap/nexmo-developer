---
title:  发送 WhatsApp 消息
description:  在此步骤中，您将学习如何发送 WhatsApp 消息。

---

发送 WhatsApp 消息
==============

请注意，只有当客户先向企业发送消息时，才能发送自由格式文本消息。从收到客户消息的最后时刻起，企业最多有 24 小时来发送回自由格式消息。24 小时之后，需要使用 WhatsApp 模板 (MTM)。

如果您尚未收到客户的消息，则在发送消息之前，您需要先发送 WhatsApp 模板 (MTM)。您可以在[了解 WhatsApp 消息传递](/messages/concepts/whatsapp)中了解更多相关信息。

如果您想查看用于发送 WhatsApp 模板的代码，则可以查看[发送 WhatsApp 模板](/messages/code-snippets/send-whatsapp-template)代码段。

|键 | 说明|
|-- | --|
|`WHATSAPP_NUMBER` | 您的 WhatsApp 号码。|
|`TO_NUMBER` | 您要向其发送消息的电话号码。|

> **注意** ：输入电话号码时请勿使用前导 `+` 或 `00`，以国家/地区代码开头，例如，447700900000。

示例
---

```code_snippets
source: '_examples/messages/whatsapp/send-text'
```

> **提示** ：如果使用 Curl 测试，将需要 JWT。您可以在有关[创建 JWT](/messages/code-snippets/before-you-begin#generate-a-jwt) 的文档中看到如何创建 JWT 的说明。

