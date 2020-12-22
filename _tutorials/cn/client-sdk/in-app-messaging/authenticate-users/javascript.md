---
title:  验证用户身份
description:  在此步骤中，您将通过之前创建的 JWT 验证用户的身份

---

验证用户身份
======

您的用户必须通过身份验证才能参与对话。您使用对话 ID 以及在上一步中生成的 JWT 执行此身份验证。

在 `chat.js` 文件顶部声明以下变量，并使用您自己的值填充 `USER1_JWT`、`USER2_JWT` 和 `CONVERSATION_ID`：

```javascript
const USER1_JWT = '';
const USER2_JWT = '';
const CONVERSATION_ID = '';

const messageTextarea = document.getElementById('messageTextarea');
const messageFeed = document.getElementById('messageFeed');
const sendButton = document.getElementById('send');
const loginForm = document.getElementById('login');
const status = document.getElementById('status');

const loadMessagesButton = document.getElementById('loadMessages');
const messagesCountSpan = document.getElementById('messagesCount');
const messageDateSpan = document.getElementById('messageDate');

let conversation;
let listedEvents;
let messagesCount = 0;
let messageDate;

function authenticate(username) {
  if (username == "USER1_NAME") {
    return USER1_JWT;
  }
  if (username == "USER2_NAME") {
    return USER2_JWT;
  }
  alert("User not recognized");
}
```

您还需要将事件侦听器添加到 `login` 表单中，以获取用户的 JWT 并将其传递给 `run` 函数。`run` 函数尚未执行任何操作，但此时您拥有有效的用户 JWT，可开始构建您的应用程序。

```javascript
loginForm.addEventListener('submit', (event) => {
  event.preventDefault();
  const userToken = authenticate(document.getElementById('username').value);
  if (userToken) {
    document.getElementById('messages').style.display = 'block';
    document.getElementById('login').style.display = 'none';
    run(userToken);
  }
});

async function run(userToken){

}
```

