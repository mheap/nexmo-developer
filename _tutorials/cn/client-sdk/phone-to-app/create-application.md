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

**3\.** 以[交互方式](/application/nexmo-cli#interactive-mode)创建 Vonage 应用程序。确保通过使用上一步的 gist URL 替换 `GIST-URL` 来更改 `--voice-answer-url` 参数的值。以下命令将进入交互模式：

```shell
nexmo app:create "Phone To App Tutorial" --capabilities=voice --keyfile=private.key  --voice-event-url=https://example.com/ --voice-answer-url=GIST-URL 
```

系统在您的项目目录中创建了一个名为 `.nexmo-app` 的文件，该文件包含新创建的 Vonage 应用程序 ID 和私钥。此外，系统还创建了一个名为 `private.key` 的私钥文件。

**请记下该文件，以备将来需要时使用。** 

```screenshot
image: public/screenshots/tutorials/client-sdk/nexmo-application-created.png
```

> **注意：** 有关如何创建应用程序及各种可用的应用程序功能的更多详细信息，请参阅我们的[文档](/application/overview)。

> **注意：** 您还可以在 [Dashboard](https://dashboard.nexmo.com/voice/your-applications) 中获取有关您的应用程序的信息，包括应用程序 ID。

