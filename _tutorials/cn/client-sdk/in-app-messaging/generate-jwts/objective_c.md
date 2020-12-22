---
title:  生成 JWT
description:  在此步骤中，您将学习如何为对话中的每个用户生成有效的 JWT

---

生成 JWT
======

您需要为每个用户生成 JWT。JWT 用于验证用户的身份。

在以下命令中，记得将 `APPLICATION_ID` 变量替换为您的应用程序的 ID。

```shell
nexmo jwt:generate sub=Alice exp=$(($(date +%s)+86400)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{}}}' application_id=APPLICATION_ID

nexmo jwt:generate sub=Bob exp=$(($(date +%s)+86400)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{}}}' application_id=APPLICATION_ID
```

上述命令用于将 JWT 的有效期设置为从现在起一天（最长有效期）。

记下您为每个用户生成的 JWT。

> **注意** ：在生产环境中，您的应用程序应公开为每个客户端请求生成 JWT 的端点。

更多信息
----

* [JWT 指南](/concepts/guides/authentication#json-web-tokens-jwt)

