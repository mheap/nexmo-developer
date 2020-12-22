---
title:  创建 Vonage 应用程序
description:  在此步骤中，您将学习如何创建 Vonage 应用程序。

---

创建 Vonage 应用程序
==============

现在，您需要创建一个 Vonage [应用程序](/conversation/concepts/application)。在此步骤中，您将创建一个能够处理应用内语音和应用内消息传递用例的应用程序。

**1\.** 创建您的项目目录（如果尚未创建）。

```shell
mkdir vonage-tutorial
```

**2\.** 切换到该项目目录。

```shell
cd vonage-tutorial
```

**3\.** 以[交互方式](/application/nexmo-cli#interactive-mode)创建 Vonage 应用程序。以下命令将进入交互模式：

```shell
nexmo app:create
```

**4\.** 指定应用程序名称。按 Enter 键继续。

**5\.** 现在，您可以使用箭头键选择应用程序功能，然后按空格键选择应用程序
所需的功能。就本示例而言，使用箭头键和空格键选择语音和 RTC 功能。选择语音和 RTC 功能后，按 Enter 继续。

> **注意** ：如果您的应用程序仅处理应用内语音，则只能选择语音功能。如果您需要在应用内进行消息传递，则只能选择 RTC 功能。如果您的应用能够同时处理应用内语音和应用内消息传递，请选择两种功能。

**6\.** 对于“是否使用默认的 HTTP 方法?”，按 Enter 键选择默认值。

**7\.** 对于“语音应答 URL”，请输入 `https://example.ngrok.io/webhooks/answer` 或其他适合的 URL（具体取决于您的测试方式）。

**8\.** 接下来系统会提示您输入“语音回退应答 URL”。如果您的主语音应答 URL 出于某种原因失败了，则此为可选的回退 URL。在这种情况下，只需按 Enter 即可。如果稍后您需要回退 URL，则可以将其添加到 [Dashboard](https://dashboard.nexmo.com/sign-in) 中，或使用 Nexmo CLI。

**9\.** 现在，您需要输入“语音事件URL”。输入 `https://example.ngrok.io/webhooks/event`。

**10\.** 对于“RTC 事件 URL”，输入 `https://example.ngrok.io/webhooks/rtc`。

**11\.** 对于“公钥路径”，按 Enter 键选择默认值。如果要使用自己的公钥-私钥对，请参阅[本文档](/application/nexmo-cli#creating-an-application-with-your-own-public-private-key-pair)。

**12\.** 对于“私钥路径”，输入 `private.key`，然后按 Enter 键。

系统在您的项目目录中创建了一个名为 `.nexmo-app` 的文件，该文件包含新创建的 Vonage 应用程序 ID 和私钥。此外，系统还创建了一个名为 `private.key` 的私钥文件。

**请记下该文件，以备将来需要时使用。** 

```screenshot
image: public/screenshots/tutorials/client-sdk/nexmo-application-created.png
```

> **注意：** 有关如何创建应用程序及各种可用的应用程序功能的更多详细信息，请参阅我们的[文档](/application/overview)。

> **注意：** 您还可以在 [Dashboard](https://dashboard.nexmo.com/voice/your-applications) 中获取有关您的应用程序的信息，包括应用程序 ID。

