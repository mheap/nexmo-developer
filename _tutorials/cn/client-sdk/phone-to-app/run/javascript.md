---
title:  运行您的应用程序
description:  在此步骤中，您将学习如何运行您的“电话呼叫应用”应用程序。

---

运行您的应用程序
========

> **注意** ：如果您尚未执行此操作，请确保已[运行 Ngrok](/client-sdk/tutorials/app-to-phone/prerequisites#how-to-run-ngrok)。

使用 `node server.js` 运行您的应用程序，然后访问 http://localhost:3000

页面上显示呼叫的当前状态和“应答”按钮。

> **注意** ：如果尚未启动开发人员控制台，此时最好在浏览器中启动它。

您现在可以从 PSTN 电话呼叫与 Client SDK 应用程序关联的 Vonage 号码。

您将听到一条消息，提示您等待接通座席。

在 Web 应用中，您会看到通话状态已更新。点击 `Answer` 按钮以应答呼入电话。

现在可以在 Web 应用（座席）和呼入来电者之间进行对话。

完成对话后挂断，通话状态将再次更新。

