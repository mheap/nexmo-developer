---
title:  创建 Vonage 应用程序
description:  在此步骤中，您将学习如何创建 Vonage 应用程序。

---

创建 Vonage 应用程序
==============

在此步骤中，您将创建能够处理应用内语音通信用例的 Vonage [应用程序](/conversation/concepts/application)。

> **注意** ：此 Vonage 应用程序项目允许客户端应用程序使用 Vonage 后端。

**1\.** 创建您的项目目录（如果尚未创建）。

```shell
mkdir vonage-tutorial
```

**2\.** 切换到该项目目录。

```shell
cd vonage-tutorial
```

**3\.** 通过复制下面的命令并将其粘贴到终端中来创建 Vonage 应用程序。确保通过使用上一步的 gist URL 替换 `GIST-URL` 来更改 `--voice-answer-url` 参数的值。

```shell
nexmo app:create "App to Phone Tutorial" --capabilities=voice --keyfile=private.key  --voice-event-url=https://example.com/ --voice-answer-url=GIST-URL
```

系统在您的项目目录中创建了一个名为 `.nexmo-app` 的文件，该文件包含新创建的 Vonage 应用程序 ID 和私钥。此外，系统还创建了一个名为 `private.key` 的私钥文件。

**请记下应用程序 ID，以备将来需要时使用。** 

```screenshot
image: public/screenshots/tutorials/client-sdk/nexmo-application-created.png
```

> **注意** ：也可以使用 CLI 的[交互模式](/application/nexmo-cli#interactive-mode)创建应用程序。

> **注意：** 有关如何创建应用程序及各种可用的应用程序功能的更多详细信息，请参阅我们的[文档](/application/overview)。

> **注意：** 您还可以在 [Dashboard](https://dashboard.nexmo.com/voice/your-applications) 中获取有关您的应用程序的信息，包括应用程序 ID。

