---
title:  创建用于接收应用内语音通话的代码
description:  在此步骤中，您将学习如何编写代码以接收来自其他应用的应用内语音通话。

---

创建用于接收应用内语音通话的代码
================

在您的项目目录中创建一个名为 `index2.html` 的 HTML 文件。

添加以下代码，但要确保将您在[较早步骤](/client-sdk/tutorials/app-to-app/client-sdk/generate-jwts)中为 *接听* 电话的用户生成的 Bob JWT 粘贴到 `USER_JWT` 常量：

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
  </head>
  <body>
    <h1>Inbound app call</h1>
    <p id="notification">Lines are open for calls...</p>
    <br />
    <button id="button">Answer</button>
    <script>
      const USER_JWT ="PASTE BOB JWT HERE";

      new NexmoClient({ debug: true })
        .login(USER_JWT)
        .then(app => {
          let btn = document.getElementById("button");
          let notification = document.getElementById("notification");
          app.on("member:call", (member, call) => {
            notification.innerHTML = "Inbound app call - click to answer...";
            btn.addEventListener("click", event => {
              event.preventDefault();
              call.answer();
            });
          });
          app.on("call:status:changed", call => {
            notification.innerHTML = "Call Status: " + call.status;
          });
        })
        .catch(console.error);
    </script>
  </body>
</html>
```

这是您的客户端应用程序，它使用 Client SDK 接收来自源 *用户* (Alice) 的语音通话。

此代码有几个关键组件：

1. 简单的 UI，允许您查看是否有呼入电话，并点击 `Answer` 进行应答。
2. 使用 `.login(USER_JWT)` 将用户 (Bob) 登录进 Client SDK（用于身份验证的 JWT）的代码。
3. 点击“应答”按钮时将应答呼叫的事件处理程序。
4. 当通过 `call:status:changed` 事件更改通话状态时，显示事件处理程序和 UI。

