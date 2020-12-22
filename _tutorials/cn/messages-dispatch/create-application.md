---
title:  创建消息和调度应用程序
description:  在此步骤中，您将学习如何创建消息和调度应用程序。消息和调度应用程序包含消息状态 Webhook 和入站消息 Webhook，其中入站消息的类型为 `whatsapp`、`messenger` 或 `viber_service_msg`。必须通过您的帐户级别短信 Webhook 处理入站短信。
meta_title:  创建适用于 Vonage API 的消息和调度应用程序
meta_description:  消息和调度应用程序包含消息状态 Webhook 和入站消息 Webhook，其中入站消息的类型为 `whatsapp`、`messenger` 或 `viber_service_msg`。必须通过您的帐户级别短信 Webhook 处理入站短信。

---

创建您的应用程序
--------

有两种替代方法可以创建消息和调度应用程序：

1. 使用 Nexmo CLI
2. 使用 Dashboard

以下各节介绍了每种方法。

### 如何使用 Nexmo CLI 创建消息和调度应用程序

要使用 Nexmo CLI 创建您的应用程序，请在 shell 中输入以下命令：

```shell
nexmo app:create "My Messages App" --capabilities=messages --messages-inbound-url=https://example.com/webhooks/inbound-message --messages-status-url=https://example.com/webhooks/message-status --keyfile=private.key
```

此命令将创建具有消息[功能](/application/overview#capabilities)的 Vonage 应用程序，按指定配置 Webhook URL，并生成私钥文件 `private.key`。

### 如何使用 Dashboard 创建消息和调度应用程序

您可以在 [Dashboard](https://dashboard.nexmo.com/applications) 中创建消息和调度应用程序。

要使用 Dashboard 创建您的应用程序：

1. 在 Dashboard 中的[应用程序](https://dashboard.nexmo.com/applications)下，点击 **创建新的应用程序** 按钮。

2. 在 **名称** 下，输入应用程序名称。选择一个名称以便将来引用。

3. 点击 **生成公钥和私钥** 按钮。这将生成一个公钥/私钥对，并且您的浏览器将会下载私钥。

4. 在 **功能** 下，选择 **消息** 按钮。

5. 在 **入站 URL** 框中，输入您的入站消息 Webhook 的 URL，例如 `https://example.com/webhooks/inbound-message`。

6. 在 **状态 URL** 框中，输入您的消息状态 Webhook 的 URL，例如 `https://example.com/webhooks/message-status`。

7. 点击 **生成新的应用程序** 按钮。现在进入“创建应用程序”流程的下一步，在此步骤中，您可以将 Vonage 号码链接到此应用程序，并将外部帐户（例如 Facebook）链接到此应用程序。

8. 如果有您要链接到此应用程序的外部帐户，请点击 **链接的外部帐户** 选项卡，然后点击与您要链接的帐户对应的 **链接** 按钮。

现在您已经创建了您的应用程序。

> **注意** ：测试您的应用程序前，确保已配置 Webhook 并且 Webhook 服务器正在运行。

