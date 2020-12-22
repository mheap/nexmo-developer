---
title:  创建消息 Webhook 服务器
description:  使用 Webhook 服务器接收入站消息

---

在此代码段中，您将学习如何处理入站消息。

> **注意** ：Messages API 不支持入站短信和短信送达回执回调（通过特定于应用程序的 Webhook）。为了接收短信和短信送达回执的回调，您需要将设置[短信的帐户级别 Webhook](https://dashboard.nexmo.com/settings)。

示例
---

确保已在 Dashboard 中设置了您的入站消息 [Webhook](/tasks/olympus/configure-webhooks)。至少，您的处理程序必须返回 200 状态代码，以避免不必要的回调排队。在测试消息应用程序之前，请确保您的 Webhook 服务器正在运行。

```code_snippets
source: '_examples/messages/webhook-server'
```

