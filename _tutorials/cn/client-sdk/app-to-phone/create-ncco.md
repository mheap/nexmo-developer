---
title:  创建 NCCO
description:  在此步骤中，您将使用 GitHub Gist 修改您的 NCCO。

---

创建 NCCO
=======

Nexmo 呼叫控制对象 (NCCO) 是一个 JSON 数组，可用于控制语音 API 呼叫的流程。有关 NCCO 的更多信息可在[此处](/voice/voice-api/ncco-reference)找到。

NCCO 必须是公开的，并且可通过互联网访问。为此，您将使用 [GitHub Gist](https://gist.github.com/)，它提供了一种便捷的方式来托管配置：

1. 确保您已登录 [GitHub](https://github.com)，然后转到 https://gist.github.com/。

2. 在“包含扩展名的文件名”中输入 `ncco.json`。

3. 复制以下 JSON 对象并粘贴进 gist：

```json
[
    {
        "action": "talk",
        "text": "Please wait while we connect you."
    },
    {
        "action": "connect",
        "endpoint": [
            {
                "type": "phone",
                "number": "PHONE_NUMBER"
            }
        ]
    }
]
```

1. 将 `PHONE_NUMBER` 替换为您的电话号码。Vonage 号码采用 [E.164](/concepts/guides/glossary#e-164-format) 格式，“\+”和“-”均为无效字符。输入您的号码时，请确保指定国家/地区代码，例如，美国：14155550100 和英国：447700900001。

2. 点击 `Create secret gist` 按钮：

```screenshot
image: public/screenshots/tutorials/client-sdk/app-to-phone/create-ncco/gist1.png
```

1. 点击 `Raw` 按钮：

```screenshot
image: public/screenshots/tutorials/client-sdk/app-to-phone/create-ncco/gist2.png
```

1. 记下浏览器中显示的 URL，您将在下一步中用到它。

