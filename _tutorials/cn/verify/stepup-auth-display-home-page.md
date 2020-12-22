---
title:  显示主页
description:  显示主页和用户的身份验证状态

---

显示主页
====

在 `/` 路由中，您想检查会话是否已存在。如果没有，则提示用户使用手机号码验证其帐户详细信息，然后才能继续执行其他操作。

通过身份验证后，系统将创建会话对象，您可以使用它来检索并显示用户的手机号码。

在 `/` 路由处理程序中输入以下代码：

```javascript
app.get('/', (req, res) => {
	if (!req.session.user) {
		res.render('index', {
			brand: NEXMO_BRAND_NAME,
		});
	} else {
		res.render('index', {
			number: req.session.user.number,
			brand: NEXMO_BRAND_NAME,
		});
	}
});
```

运行以下命令：

```sh
node server.js
```

在浏览器中访问 `http://localhost:3000`，并确保页面显示正确：

![主页](/images/tutorials/verify-stepup-auth-home-page.png)

另外，请确保当您点击“验证我”按钮时，您会被重定向到可以输入手机号码的页面：

![输入代码页面](/images/tutorials/verify-stepup-auth-enter-number-page.png)

尽管您可以在此处输入电话号码，但您仍然不会收到验证码。您将在下一步中实现该功能！

