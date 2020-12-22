---
title:  创建客户端应用程序
description:  在此步骤中，您将学习如何为您的“应用呼叫电话”应用程序编写代码。

---

创建客户端应用程序
=========

在您的项目目录中创建一个名为 `index.html` 的 HTML 文件。添加以下代码，但要确保将您在本教程[较早步骤](/client-sdk/tutorials/app-to-phone/client-sdk/generate-jwt)中为该用户生成的 JWT 粘贴到 `USER_JWT` 常量：

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
    <style>
        input, button {
            font-size: 1rem;
        }
        #hangup {
            display:none;
        }
    </style>
</head>

<body>
    <h1>Call Phone from App</h1>
    <label for="phone-number">Your Phone Number:</label>
    <input type="text" name="phone-number" value="" placeholder="i.e. 14155550100" id="phone-number" size="30">
    <button type="button" id="call">Call</button>
    <button type="button" id="hangup">Hang Up</button>
    <div id="status"></div>

    <script>
        const USER_JWT = "PASTE YOUR JWT HERE";
        const phoneNumberInput = document.getElementById("phone-number");
        const callButton = document.getElementById("call");
        const hangupButton = document.getElementById("hangup");
        const statusElement = document.getElementById("status");
        new NexmoClient({ debug: true })
            .login(USER_JWT)
            .then(app => {
                callButton.addEventListener("click", event => {
                    event.preventDefault();
                    let number = phoneNumberInput.value;
                    if (number !== ""){
                        app.callServer(number);
                    } else {
                        statusElement.innerText = 'Please enter your phone number.';
                    }
                });
                app.on("member:call", (member, call) => {
                    hangupButton.addEventListener("click", () => {
                        call.hangUp();
                    });
                });
                app.on("call:status:changed",(call) => {
                    statusElement.innerText = `Call status: ${call.status}`;
                    if (call.status === call.CALL_STATUS.STARTED){
                        callButton.style.display = "none";
                        hangupButton.style.display = "inline";
                    }
                    if (call.status === call.CALL_STATUS.COMPLETED){
                        callButton.style.display = "inline";
                        hangupButton.style.display = "none";
                    }
                });
            })
            .catch(console.error);
    </script>

</body>

</html>
```

这是您的 Web 应用程序，它使用 Client SDK 通过 Vonage 向目标电话进行语音通话。

此代码有几个关键组件：

1. 简单的 UI，允许您输入电话号码，然后点击 `Call` 按钮进行语音通话。
2. 用于使用户登录的代码（使用 JWT 进行身份验证）。
3. 用于拨打电话的函数 `callServer(number)`，其中 `number` 是采用 [E.164](/concepts/guides/glossary#e-164-format) 格式的目标电话号码。

输入电话号码并点击 `Call` 按钮后，您将听到报告通话状态的语音。当呼叫接通时，您可以应答呼叫，然后通过该应用听到对话。

