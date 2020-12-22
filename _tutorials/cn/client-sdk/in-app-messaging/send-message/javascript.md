---
title:  发送消息
description:  在此步骤中，您可以让用户发送消息

---

发送消息
====

为了向对话中的其他参与者发送消息，您需要调用 `conversation.sendText()` 方法。

您可以通过在 `run` 函数末尾为消息框的“提交”按钮添加处理程序来执行此操作：

```javascript
// Listen for clicks on the submit button and send the existing text value
sendButton.addEventListener('click', async () => {
  await conversation.sendText(messageTextarea.value);
  messageTextarea.value = '';
});
```

