---
title:  显示消息历史记录
description:  在此步骤中，您将显示已作为此对话的一部分发送的所有消息

---

显示消息历史记录
========

您希望用户看到对话中的所有消息。您可以通过处理对话的 `getEvents` 方法（以检索在当前会话开始之前发送和接收的消息）及其 `text` 事件（当用户发送消息时提醒您的应用程序）来实现此目的。

如果消息数量超过请求的页面大小，则可以使用 `getNext()` 接收下一页。可以在[文档](https://developer.nexmo.com/sdk/stitch/javascript/EventsPage.html#getNext)中找到 `getNext()` 的更多信息。点击“加载先前的消息”按钮时调用此函数。将此代码置于 `loginForm` 事件侦听器之后和 `run` 函数之前。

```javascript
loadMessagesButton.addEventListener('click', async (event) => {
  // Get next page of events
  let nextEvents = await listedEvents.getNext();
  listMessages(nextEvents);
});
```

您的应用程序可以从发送给每个处理程序的事件数据中检索消息详细信息，并将其添加到消息列表中。

为了列出消息，我们将创建一个 `listMessages` 函数，它将使用事件页面并执行一些步骤。

首先，如果事件页面的下一页有消息，将显示“加载先前的消息”按钮。为此，将调用 `hasNext()` 并根据是否有另一页消息返回布尔值。您可以在[文档中](https://developer.nexmo.com/sdk/stitch/javascript/EventsPage.html#hasNext)了解 `hasNext()` 的更多信息。

接下来，您将遍历事件、设置其格式并进行组合，然后将其添加到消息列表中。

将以下代码添加到 `chat.js` 的底部：

```javascript
function listMessages(events) {
  let messages = '';

  // If there is a next page, display the Load Previous Messages button
  if (events.hasNext()){
    loadMessagesButton.style.display = "block";
  } else {
    loadMessagesButton.style.display = "none";
  }

  // Replace current with new page of events
  listedEvents = events;

  events.items.forEach(event => {
    const formattedMessage = formatMessage(conversation.members.get(event.from), event, conversation.me);
    messages = formattedMessage + messages;
  });

  // Update UI
  messageFeed.innerHTML = messages + messageFeed.innerHTML;
  messagesCountSpan.textContent = `${messagesCount}`;
  messageDateSpan.textContent = messageDate;
}
```

在本示例中，您将使用用户的身份通过以不同的颜色显示来区分他们发送的消息和从其他用户那里收到的消息。通过将以下代码添加到 `chat.js` 底部来创建 `formatMessage` 函数：

```javascript
function formatMessage(sender, message, me) {
  const rawDate = new Date(Date.parse(message.timestamp));
  const formattedDate = moment(rawDate).calendar();
  let text = '';
  messagesCount++;
  messageDate = formattedDate;

  if (message.from !== me.id) {
    text = `<span style="color:red">${sender.user.name} (${formattedDate}): <b>${message.body.text}</b></span>`;
  } else {
    text = `me (${formattedDate}): <b>${message.body.text}</b>`;
  }

  return text + '<br />';

}
```

实现了在页面上显示消息的方法后，请将以下内容添加到 `run` 函数的底部来加载历史消息：

```javascript
// Update the UI to show which user we are
document.getElementById('sessionName').innerHTML = conversation.me.user.name + "'s messages"

// Load events that happened before the page loaded
  let initialEvents = await conversation.getEvents({ event_type: "text", page_size: 10, order:"desc" });
  listMessages(initialEvents);

```

最后，您需要为传入的新消息设置事件侦听器。您可以通过侦听 `conversation.on('text')` 事件来做到这一点。此外，还会更新消息计数。将以下内容添加到 `run` 函数的底部：

```javascript
  // Any time there's a new text event, add it as a message
  conversation.on('text', (sender, event) => {
    const formattedMessage = formatMessage(sender, event, conversation.me);
    messageFeed.innerHTML = messageFeed.innerHTML +  formattedMessage;
    messagesCountSpan.textContent = `${messagesCount}`;
  });
```

