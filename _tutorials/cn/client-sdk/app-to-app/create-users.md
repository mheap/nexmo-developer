---
title:  创建用户
description:  在此步骤中，您将学习如何创建将参与应用内语音通话的用户。

---

创建用户
====

使用 [User](/conversation/concepts/user) 对象代表[应用内语音](/client-sdk/in-app-voice/overview)通话中的每位参与者，并且必须使用 Client SDK 验证每位参与者的身份。在生产应用程序中，您通常将此用户信息存储在数据库中。

执行以下命令，以创建两名用户 `Alice` 和 `Bob`，这两名用户将登录 Vonage Client 并参与通话。

```bash
nexmo user:create name="Alice"
nexmo user:create name="Bob"
```

此操作将返回类似如下的用户 ID：

```sh
User created: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

无需记住该用户 ID，因为我们将使用用户名（而不是用户 ID）将他们添加到语音通话中。

