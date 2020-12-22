---
title:  创建用于进行应用内语音通话的代码
description:  在此步骤中，您将学习如何编写代码以进行与其他应用的语音通话。

---

创建用于进行应用内语音通话的代码
================

在您的项目目录中创建一个名为 `index1.html` 的 HTML 文件。

添加以下代码，但要确保将您在[较早步骤](/client-sdk/tutorials/app-to-app/client-sdk/generate-jwts)中为 *进行* 通话的用户生成的 Alice JWT 粘贴到 `USER_JWT` 常量：

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
  </head>
  <body>
    <form id="call-app-form">
      <h1>Call App from App</h1>
      <input type="text" name="username" value="" />
      <input type="submit" value="Call" />
    </form>
    <button id="btn-hangup" type="button">Hang Up</button>
    <script>
      const USER_JWT = "PASTE ALICE JWT HERE";
      const callAppForm = document.getElementById("call-app-form");
      const btnHangUp = document.getElementById("btn-hangup");
      new NexmoClient({ debug: true })
        .login(USER_JWT)
        .then(app => {
          callAppForm.addEventListener("submit", event => {
            event.preventDefault();
            let username = callAppForm.children.username.value;
            app.callServer(username, "app");
          });

          app.on("member:call", (member, call) => {
            btnHangUp.addEventListener("click", () => {
              console.log("Hanging up...");
              call.hangUp();
            });
          });
        })
        .catch(console.error);
    </script>
  </body>
</html>
```

这是您的客户端应用程序，它使用 Client SDK 向目标 *用户* (Bob) 进行语音通话。

此代码有几个关键组件：

1. 简单的 UI，允许您输入用户名，然后点击 `Call` 按钮向指定用户 (Bob) 进行应用内呼叫。
2. 使用 `.login(USER_JWT)` 将用户 (Alice) 登录进 Client SDK（用于身份验证的 JWT）的代码。
3. 用于进行通话的函数是 `callServer(username, type)`，在本例中 `type` 为“app”，因为目标是指定用户 (Bob)。  
   > 
   > **注意** ：进行语音通话的另一种方法是使用点对点通话功能的 `inAppCall(username)`。[`inAppCall()` 的更多信息](/sdk/stitch/javascript/Application.html#inAppCall__anchor)
4. 进行通话时，将加载按钮处理程序。点击 `Hang Up` 按钮时，`call.hangUp()` 会终止通话。

