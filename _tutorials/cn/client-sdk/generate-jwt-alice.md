---
title:  生成 JWT
description:  在此步骤中，您将学习如何为 Client SDK 应用程序生成有效的 JWT。

---

生成 JWT
======

Client SDK 使用 [JWT](/concepts/guides/authentication#json-web-tokens-jwt) 进行身份验证。JWT 用于标识用户名、相关的应用程序 ID 和授予该用户的权限。使用您的私钥对其进行签名以证明它是有效的令牌。

> **注意** ：我们将在此页面上创建用于测试的一次性 JWT。在生产应用程序中，您的应用程序应公开为每个客户端请求生成 JWT 的端点。

使用 CLI
------

您可以通过运行以下命令，使用 Nexmo CLI 生成 JWT，但请记住将 `APP_ID` 变量替换为您自己的值：

```shell
nexmo jwt:generate ./private.key exp=$(($(date +%s)+21600)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{}}}' sub=Alice application_id=APP_ID
```

生成的 JWT 将在接下来的 6 小时内有效。

替换选项：使用 Web 界面
--------------

或者，您可以使用我们的[在线 JWT 生成器](/jwt)，将 `Alice` 用作 **子** 参数，并将您的应用程序 ID 用作 **应用程序 ID** 来生成 JWT。

更多信息
----

* [JWT 指南](/concepts/guides/authentication#json-web-tokens-jwt)

