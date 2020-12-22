---
title:  创建 Webhook 服务器
description:  在此步骤中，您将学习如何创建适合的 Webhook 服务器，使您的 Web 应用能够接受呼入的 PSTN 电话。

---

创建 Webhook 服务器
==============

您将需要创建 Webhook 服务器。当呼入电话进入 Vonage 后，您可以捕获始发号码并使用动态 NCCO 将呼叫转接到 Web 应用程序。使用 `app` 类型的 `connect` 操作即可实现此目的。该呼叫将被转接给通过身份验证的用户，该用户代表座席处理呼入电话。

创建 `server.js` 文件并添加服务器代码：

> **注意** ：在下面的代码中粘贴您的 Vonage 号码和用户名。用户名是指您在上一步中为其创建 JWT 的用户名 (Alice)。

```javascript
'use strict';
const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

app.use(express.static('node_modules/nexmo-client/dist'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const ncco = [
  {
    "action": "talk",
    "text": "Please wait while we connect you to an agent"
  },
  {
    "action": "connect",
    "from": "NEXMO_NUMBER",
    "endpoint": [
      {
        "type": "app",
        "user": "Alice"
      }
    ]
  }
]

app.get('/webhooks/answer', (req, res) => {
    console.log("Answer:");
    console.log(req.query);
    res.json(ncco);
});

app.post('/webhooks/event', (req, res) => {
    console.log("EVENT:");
    console.log(req.body);
    res.status(200).end();
});

app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + '/index.html'));
});

app.listen(port, () => console.log(`Server listening on port ${port}!`));

```

此代码的重要部分包括：

1. 在本示例中，使用静态 NCCO 将呼入电话转接到 `Alice` 标识的座席。
2. NCCO 使用 `app` 类型的 `connect` 操作，提供要连接的用户名。

