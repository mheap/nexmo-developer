---
title:  生成 JWT
description:  在此步骤中，您将学习如何为 Client SDK 应用程序生成有效的 JWT。

---

生成 JWT
======

Client SDK 使用 [JWT](/concepts/guides/authentication#json-web-tokens-jwt) 进行身份验证。JWT 用于标识用户名、相关的应用程序 ID 和授予该用户的权限。使用您的私钥对其进行签名以证明它是有效的令牌。

> **注意** ：我们将在此页面上创建用于测试的一次性 JWT。在生产应用程序中，您的应用程序应公开为每个客户端请求生成 JWT 的端点。

请记住，在下面的部分中，将 `MY_APP_ID` 变量替换为您自己的值。如果您对多个用户进行测试，请生成多个 JWT（每次更改 `sub` 值）。

使用 CLI
------

您可以通过运行以下命令，使用 Nexmo CLI 生成 JWT：

```shell
nexmo jwt:generate ./private.key exp=$(($(date +%s)+21600)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{}}}' sub=Alice application_id=MY_APP_ID
```

生成的 JWT 将在接下来的 6 小时内有效。

使用 Web 界面
---------

或者，您可以使用我们的[在线 JWT 生成器](/jwt)，使用以下参数生成 JWT。

**应用程序 ID：** `MY_APP_ID`  
**子参数：** `Alice`  
**ACL：** 

```json
{
  "paths": {
    "/*/users/**": {},
      "/*/conversations/**": {},
      "/*/sessions/**": {},
      "/*/devices/**": {},
      "/*/image/**": {},
      "/*/media/**": {},
      "/*/applications/**": {},
      "/*/push/**": {},
      "/*/knocking/**": {}
  }
}
```

更多信息
----

* [JWT 指南](/concepts/guides/authentication#json-web-tokens-jwt)

