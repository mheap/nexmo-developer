---
title:  添加正在键入指示符
description:  在此步骤中，您将学习用户键入时如何显示

---

添加正在键入指示符
=========

为了使应用程序更加完善，您将在对话中的其他各方键入内容时告知用户。

将以下代码添加到 `run` 函数的底部：如果您的应用程序在消息文本区域检测到 `keypress` 事件，请调用 `conversation.startTyping` 函数以提醒您的应用程序该用户当前正在键入内容。

如果您在文本区域检测到 `keyup` 事件的时间超过半秒，则可以假定用户已停止键入并调用 `conversation.stopTyping` 来提醒您的应用程序。

```javascript
messageTextarea.addEventListener('keypress', (event) => {
  conversation.startTyping();
});

var timeout = null;
messageTextarea.addEventListener('keyup', (event) => {
  clearTimeout(timeout);
  timeout = setTimeout(() => {
    conversation.stopTyping();
  }, 500);
});
```

当您的应用程序检测到用户已开始输入或停止键入内容时，可以确定事件来自哪个用户。如果该用户不是使用您的应用程序的人，则您可以在应用程序中更新其状态。

将以下内容添加到 `run` 函数的底部：

```javascript
conversation.on("text:typing:on", (data) => {
  if (data.user.id !== data.conversation.me.user.id) {
    status.innerHTML = data.user.name + " is typing...";
  }
});

conversation.on("text:typing:off", (data) => {
  status.innerHTML = "";
});
```

