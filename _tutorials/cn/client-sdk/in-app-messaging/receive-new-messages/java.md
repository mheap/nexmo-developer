---
title:  接收新消息
description:  在此步骤中，您将显示任何新消息

---

接收新消息
=====

您可以通过实现对话侦听器来显示传入的消息。

现在，在 `ChatFragment` 类中找到 `private val messageListener = object : NexmoMessageEventListener` 属性，并实现对话侦听器 `onTextEvent(textEvent: NexmoTextEvent)` 方法：

```java
private NexmoMessageEventListener messageListener = new NexmoMessageEventListener() {
    @Override
    public void onTextEvent(@NonNull NexmoTextEvent textEvent) {
        updateConversation(textEvent);
    }

    @Override
    public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {

    }

    @Override
    public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {

    }

    @Override
    public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {

    }

    @Override
    public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {

    }

    @Override
    public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {

    }
};
```

现在，每次收到新消息时，系统将调用 `onTextEvent(textEvent: NexmoTextEvent)` 侦听器，新消息将传递给 `updateConversation(textEvent: NexmoTextEvent)` 方法，并通过 `conversationMessages` `LiveData` 调度到视图（用于在加载对话事件后调度所有消息的相同的 `LiveData`）。

最后要做的是确保在 `ChatViewModel` 被销毁时（例如，当用户向后导航时）删除所有侦听器。在 `ChatViewModel` 类中填充 `onCleared()` 方法的主体。

```java
@Override
protected void onCleared() {
    conversation.removeMessageEventListener(messageListener);
}
```

