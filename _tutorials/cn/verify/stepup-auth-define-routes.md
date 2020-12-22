---
title:  定义路由
description:  配置应用程序的端点

---

定义路由
====

您将在应用程序中使用以下路由：

* `/` - 主页，用于确定用户是否已通过身份验证，如果未通过，则提示他们进行身份验证
* `/authenticate` - 显示供用户输入其电话号码的页面
* `/verify` - 当用户输入电话号码时，请在此处重定向以开始验证过程，并显示可供用户输入所收到代码的页面
* `/check-code` - 当用户输入验证码时，此端点将使用 Verify API 来检查他们输入的代码是否为发送给他们的代码
* `/cancel` - 删除所有会话详细信息并将用户发送回主页

在初始化和运行服务器的代码之前，在 `server.js` 中创建以下路由：

```javascript
app.get('/', (req, res) => {

});

app.get('/authenticate', (req, res) => {
  res.render('authenticate');
});

app.post('/verify', (req, res) => {
	res.render('entercode');
});

app.post('/check-code', (req, res) => {

});

app.get('/cancel', (req, res) => {
	req.session.destroy();
	res.redirect('/');
});
```

