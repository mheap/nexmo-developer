---
title:  发送消息
description:  在此步骤中，您将向对话发送一条消息

---

发送消息
====

是时候发送第一条消息了。

在 `ChatViewModel` 类中，找到 `onSendMessage` 方法并填充其主体：

```java
public void onSendMessage(String message) {
    if (conversation == null) {
        _errorMessage.postValue("Error: Conversation does not exist");
        return;
    }

    conversation.sendText(message, new NexmoRequestListener<Void>() {
        @Overridew
        public void onError(@NonNull NexmoApiError apiError) {

        }

        @Override
        public void onSuccess(@Nullable Void aVoid) {

        }
    });
}
```

> **注意** ：在 `ChatFragment` 类中，包含为您编写的 `sendMessageButton listener`。当用户点击 `send` 按钮时调用此方法。如果存在消息文本，则调用上面的 `viewModel.onSendMessage()` 方法。

您会注意到，尽管消息已发送，但对话中并未包含该消息。可以在发送消息后调用 `getConversationEvents()` 方法，但 SDK 提供了一种更好的方式来处理这种情况。

