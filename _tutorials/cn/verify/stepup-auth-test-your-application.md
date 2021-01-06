---
title:  试试看！
description:  测试应用程序

---

试试看！
====

首先，停止应用程序的所有运行中的实例，然后使用以下命令再次运行程序：

```sh
node server.js
```

在浏览器中访问 `http://localhost:3000`，然后点击"验证我"按钮：

![主页](/images/tutorials/verify-stepup-auth-home-page.png)

以 [E.164 format](/concepts/guides/glossary#e-164-format) 输入电话号码，然后点击"获取验证码"按钮：

![输入您的电话号码](/images/tutorials/verify-stepup-auth-enter-number-filled.png)

该号码很快就会收到包含代码的短信。输入代码，然后点击"验证我！"：

![输入 PIN 码](/images/tutorials/verify-stepup-auth-enter-code-filled.png)

您应该返回首页，如果正确输入了号码，则会显示该号码：

![身份验证成功](/images/tutorials/verify-stepup-auth-success.png)

