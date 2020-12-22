---
title:  发送验证请求
description:  通过调用验证请求端点开始验证过程

---

发送验证请求
======

通过使用 [Verify API 请求端点](/api/verify#verifyRequest)来启动验证过程，以生成验证码并将其发送给用户。

使用 Node Server SDK。首先，在从 `.env` 读取环境变量的代码行之后将其实例化：

```javascript
const nexmo = new Nexmo(
  {
    apiKey: VONAGE_API_KEY,
		apiSecret: VONAGE_API_SECRET,
	},
	{
		debug: true,
	}
);
```

然后，在 `/verify` 路由处理程序中创建验证请求：

```javascript
app.post('/verify', (req, res) => {
	// Start the verification process
	verifyRequestNumber = req.body.number;
	nexmo.verify.request(
		{
			number: verifyRequestNumber,
			brand: VONAGE_BRAND_NAME,
		},
		(err, result) => {
			if (err) {
				console.error(err);
			} else {
				verifyRequestId = result.request_id;
				console.log(`request_id: ${verifyRequestId}`);
			}
		}
	);
	/* 
    Redirect to page where the user can 
    enter the code that they received
  */
	res.render('entercode');
});
```

> 默认情况下，第一次验证尝试通过短信发送。如果用户未能在指定的时间段内做出响应，则 API 会进行第二次验证尝试，如有必要，进行第三次验证尝试，以便使用语音呼叫来发送 PIN 码。您可以在[指南](/verify/guides/workflows-and-events)中了解有关可用工作流和自定义选项的更多信息。

