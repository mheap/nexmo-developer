---
title:  检查验证码
description:  检查用户输入的验证码是否与发送的验证码相同

---

检查验证码
=====

要验证用户提交的代码，您可执行调用以[验证检查端点](/api/verify#verifyCheck)。您传入 `request_id`（在上一步中，通过调用将其返回至验证请求端点）。

通过响应确定用户输入的代码是否正确。如果状态显示零，则表示他们输入的代码与发送给他们的代码是相同的。在这种情况下，创建用户会话对象。

检查代码后，将您的用户返回主页。

在 `/check-code` 路由处理程序中输入以下代码以实现此目的：

```javascript
app.post('/check-code', (req, res) => {
	// Check the code provided by the user
	nexmo.verify.check(
		{
			request_id: verifyRequestId,
			code: req.body.code,
		},
		(err, result) => {
			if (err) {
				console.error(err);
			} else {
				if (result.status == 0) {
					// User provided correct code, so create a session for that user
					req.session.user = {
						number: verifyRequestNumber,
					};
				}
			}
			// Redirect to the home page
			res.redirect('/');
		}
	);
});
```

