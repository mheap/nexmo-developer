---
title:  创建用户
description:  在此步骤中，您将学习如何创建 Client SDK 用户。

---

创建用户
====

[用户](/conversation/concepts/user)是使用 Vonage Client SDK 时的关键概念。当用户通过 Client SDK 进行身份验证时，提供的凭据会将其标识为特定用户。通过身份验证的每个用户通常与用户数据库中的一位用户对应。

要创建名为 `Alice` 的用户，请使用 Nexmo CLI 运行以下命令：

```bash
nexmo user:create name="Alice"
```

此操作将返回类似如下的用户 ID：

```bash
User created: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

