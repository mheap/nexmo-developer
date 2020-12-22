---
title:  创建 UI
description:  创建用于托管聊天的网页

---

创建 UI
=====

创建用于 Web 聊天的用户界面。

以下 HTML 定义了将用于显示以下内容的 `<section>`：

* 当前登录用户的名称
* 用户的当前状态 - 即他们当前是否正在键入消息
* 到目前为止发送和接收的消息
* 供用户输入新消息的文本区域

一旦呈现页面主体，网页会加载三个脚本：

* `nexmo-client` Node 模块中的 `nexmoClient.js` 文件
* `moment.js` 帮助设置接收消息的日期和时间格式。通过运行以下命令安装此模块： `npm install moment`
* 将包含您的应用程序代码的 `chat.js` 文件。将这个空文件复制到项目的根目录中

在项目目录中创建一个名为 `index.html` 的文件，其中包含以下内容：

```html
<!DOCTYPE html>
<html>

<head>
  <style>
    body {
      font: 13px Helvetica, Arial;
    }

    #login,
    #messages {
      width: 80%;
      height: 500px;
    }

    form input[type=text] {
      font-size: 20px;
      height: 35px;
      padding: 0px;
    }

    button {
      height: 35px;
      background-color: blue;
      color: white;
      width: 75px;
      position: relative;
      font-size: 15px;
    }

    textarea {
      width: 85%;
      font-size: 20px;
    }

    #messageFeed {
      font-size: 18px;
      padding-bottom: 20px;
      line-height: 22pt;
    }

    #status {
      height: 35px;
      font-size: 12px;
      color: blue;
    }

    #send {
      width: 85%;
    }

    #messages {
      display: none;
    }
  </style>
</head>

<body>

  <form id="login">
    <h1>Login</h1>
    <input type="text" id="username" name="username" value="" class="textbox">
    <button type="submit">Login</button>
  </form>

  <section id="messages">
    <h1 id="sessionName"></h1>

    <div id="loadSection">
      <button id="loadMessages">
        Load Previous Messages
      </button>
      &nbsp; &nbsp;<h3>Showing <span id="messagesCount"></span> starting at <span id="messageDate"></span></h3>
    </div>

    <div id="messageFeed"></div>

    <div>
      <textarea id="messageTextarea"></textarea>
      <button id="send">Send</button>
      <div id="status"></div>
    </div>
  </section>

  <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
  <script src="./node_modules/moment/moment.js"></script>
  <script src="./chat.js"></script>

</body>

</html>
```

