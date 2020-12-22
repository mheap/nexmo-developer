---
title:  获取对话事件
description:  在此步骤中，您将显示已作为此对话的一部分发送的所有消息

---

获取对话事件
======

在 `getConversation()` 方法的正下方，添加用于检索事件的方法：

```kotlin
private fun getConversationEvents(conversation: NexmoConversation) {
    conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
        object : NexmoRequestListener<NexmoEventsPage> {
            override fun onSuccess(nexmoEventsPage: NexmoEventsPage?) {
                nexmoEventsPage?.pageResponse?.data?.let {
                    _conversationMessages.postValue(it.toList())
                }
            }

            override fun onError(apiError: NexmoApiError) {
                _errorMessage.postValue("Error: Unable to load conversation events ${apiError.message}")
            }
        })
}
```

一旦检索到事件（或返回错误），我们将更新视图 (`ChatFragment`) 以反映新数据。

> **注意** ：我们将使用两个 `LiveData` 流。`_conversationMessages` 用于发布成功的 API 响应，`_errorMessage` 用于发布返回的错误。

更新视图以反映新数据。在 `ChatFragment` 中找到 `private var conversationMessages = Observer<List<NexmoEvent>?>` 属性，并添加此代码来处理我们的对话历史记录：

```kotlin
private var conversationMessages = Observer<List<NexmoEvent>?> { events ->
    val messages = events?.mapNotNull {
        when (it) {
            is NexmoMemberEvent -> getConversationLine(it)
            is NexmoTextEvent -> getConversationLine(it)
            else -> null
        }
    }

    conversationMessagesTextView.text = if (messages.isNullOrEmpty()) {
        "Conversation has No messages"
    } else {
        messages.joinToString(separator = "\n")
    }

    progressBar.isVisible = false
    chatContainer.isVisible = true
}
```

为了处理成员相关的事件（邀请成员、成员加入或离开），我们需要填充 `fun getConversationLine(memberEvent: NexmoMemberEvent)` 方法的主体：

```kotlin
private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
    val user = memberEvent.member.user.name

    return when (memberEvent.state) {
        NexmoMemberState.JOINED -> "$user joined"
        NexmoMemberState.INVITED -> "$user invited"
        NexmoMemberState.LEFT -> "$user left"
        else -> "Error: Unknown member event state"
    }
}
```

上面的方法将 `NexmoMemberEvent` 转换为 `String`，它将在聊天对话中显示为一行。需要对 `NexmoTextEvent` 进行类似的转换。让我们来填充 `getConversationLine(textEvent: NexmoTextEvent)` 方法的主体：

```kotlin
private fun getConversationLine(textEvent: NexmoTextEvent): String {
    val user = textEvent.fromMember.user.name
    return "$user said: ${textEvent.text}"
}
```

> **注意** ：在本教程中，我们仅处理成员相关事件 `NexmoMemberEvent` 和 `NexmoTextEvent`。上面的 `when` 表达式 (`else -> null`) 忽略了其他类型的事件。

现在我们可以发送第一条消息了。

