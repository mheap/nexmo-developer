---
title:  学习如何配置您的 Webhook
description:  学习如何配置您的 Webhook 以接收来自所选渠道的消息

---

您必须配置至少两个 Webhook：

* 消息状态 Webhook
* 入站消息 Webhook

生成消息状态更新时，例如 `delivered`、`rejected` 或 `accepted`，将在 *消息状态* Webhook URL 收到回调。

收到入站消息时，将在 *入站消息* Webhook URL 上调用带消息有效负载的回调。

> **重要：** 应配置两个 Webhook URL。至少您的 Webhook 处理程序应针对入站消息和消息状态回调均返回 200 响应。

### 配置 Webhook URL

在 [Dashboard](https://dashboard.nexmo.com) 中，转到[消息和调度](https://dashboard.nexmo.com/messages/create-application)。

> **提示：** 如果已在生产环境中使用您的 Vonage 帐户中消息的 Webhook URL，并且您希望第二个 URL 以使用 Messages API，请发送电子邮件至 [support@nexmo.com](mailto:support@nexmo.com) 并请求提供子 API 密钥。

在标记为 **状态 URL** 和 **入站 URL** 的字段中输入您的 Webhook URL。

您为 Webhook URL 输入的值取决于 Webhook 服务器的位置，例如：

| Webhook |                        URL                         |
|---------|----------------------------------------------------|
| 状态 URL  | `https://www.example.com/webhooks/message-status`  |
| 入站 URL  | `https://www.example.com/webhooks/inbound-message` |

> **注意** ：应将 `POST` 的默认方法用于这两个 Webhook URL。

### 入站短信 Webhook

Messages API 不支持入站短信和短信送达回执回调（通过上一节中所述的特定于应用程序的 Webhook）。为了接收短信和短信送达回执的回调，您需要将设置[短信的帐户级别 Webhook](https://dashboard.nexmo.com/settings)。

### Webhook 队列

请注意，从 Vonage 发出的 Webhook，例如消息状态 Webhook URL 和入站消息 URL 上的 Webhook，均由 Vonage 按消息加入队列。

请确保所有应用程序通过 200 响应确认 Webhook。

### 已签名的 Webhook

为了验证 Webhook 的来源，您可以验证 Webhook 的签名，请参阅[此处](https://developer.nexmo.com/messages/concepts/signed-webhooks)的说明

