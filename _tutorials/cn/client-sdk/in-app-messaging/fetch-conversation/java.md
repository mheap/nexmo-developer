---
title:  获取对话
description:  在此步骤中，您将用户加入对话中

---

获取对话
====

聊天屏幕（`ChatFragment` 和 `ChatViewModel` 类）负责获取对话以及所有对话事件。

视图 (`ChattFragment`) 创建将调用 `viewModel.getConversation()` 方法来加载对话。

在 `ChatViewModel` 类中，查找以下行并填充 `getConversation()` 方法实现：

```java
private void getConversation() {
    client.getConversation(Config.CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
        @Override
        public void onSuccess(@Nullable NexmoConversation conversation) {
            ChatViewModel.this.conversation = conversation;

            if (ChatViewModel.this.conversation != null) {
                getConversationEvents(ChatViewModel.this.conversation);
                ChatViewModel.this.conversation.addMessageEventListener(messageListener);
            }
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            ChatViewModel.this.conversation = null;
            _errorMessage.postValue("Error: Unable to load conversation " + apiError.getMessage());
        }
    });
}
```

请注意 `client` 的使用 - 它引用的对象与 `LoginViewModel` 中引用的 `client` 对象完全相同（也可通过 `NexmoClient.get()` 检索实例）。

> **注意** ：从上一步提供的 `Config.CONVERSATION_ID` 检索对话 ID。

如果已检索对话，则可以继续执行下一步：获取对话的事件。

