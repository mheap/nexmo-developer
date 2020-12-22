---
title:  创建客户端应用程序
description:  在此步骤中，您将学习如何为您的“电话呼叫应用”应用程序编写代码。

---

创建客户端应用程序
=========

在您的项目目录中创建一个名为 `index.html` 的 HTML 文件。添加以下代码，但要确保粘贴您在本教程[较早步骤](/client-sdk/tutorials/phone-to-app/client-sdk/generate-jwt)中为该用户生成的 JWT：

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <script src="nexmoClient.js"></script>
</head>
<body>

  <h1>Inbound PSTN phone call</h1>
  <p id="notification">Lines are open for calls...</p>
  <br />
  <button type="button" id="answer">Answer</button>
  <button type="button" id="reject">Reject</button>
  <button type="button" id="hangup">Hang Up</button>
  <script>

    const AGENT_JWT = "PASTE ALICE JWT HERE";

    new NexmoClient({ debug: true })
    .login(AGENT_JWT)
    .then(app => {

        const answerBtn = document.getElementById("answer");
        const rejectBtn = document.getElementById("reject");
        const hangupBtn = document.getElementById("hangup");
        const notification = document.getElementById("notification");

        app.on("member:call", (member, call) => {
            notification.textContent = "You are receiving a call";
            // Answer the call.
            answerBtn.addEventListener('click', () => {
                call.answer();
                notification.textContent = "You are in a call";
            });
            // Reject the call
            rejectBtn.addEventListener("click", () => {
                call.reject();
                notification.textContent = `You rejected the call`;
            });
            // Hang-up the call
            hangupBtn.addEventListener("click", () => {
                call.hangUp();
                notification.textContent = `You ended the call`;
            });
        });

        app.on("call:status:changed", (call) => {
          notification.textContent = "Call Status: " + call.status;
        });
    })
    .catch(console.error);
  </script>
</body>
</html>
```

这是您的 Web 应用程序，它使用 Client SDK 接受呼入电话。

此代码的主要功能包括：

1. 可以使用通话状态更新的通知框。
2. 座席想要应答呼入电话时使用的按钮。
3. 座席想要拒绝呼入电话时使用的按钮。
4. 座席想要挂断呼入电话时使用的按钮。
5. 该代码使用在[较早步骤](/client-sdk/tutorials/phone-to-app/client-sdk/generate-jwt)中生成的用户 JWT 登录座席。
6. 该代码设置了两个主要事件处理程序。呼入电话时触发第一个处理程序。然后系统会依次设置 3 个点击按钮事件处理程序，它们分别使用 Client SDK 方法 `call.answer()`、`call.reject()` 和 `call.hangUp()` 应答、拒绝和挂断呼入电话。
7. 第二是通话状态更改 (`call:status:changed`) 事件处理程序，会将通知框的文本设置为呼入电话状态。

