---
title:  使用 Postman 创建 CSV 报告
description:  使用 Postman 工具创建 CSV 格式报告

---

使用 Postman 创建 CSV 报告
====================

在 Postman 工作区中，将 HTTP 方法设置为 `POST` 并输入以下 URL： `https://api.nexmo.com/v2/reports/`

然后，您需要：

* [授权请求](#authorize-the-request)
* [设置请求主体的格式](#format-the-request-body)
* [创建请求](#create-the-request)
* [执行请求](#execute-the-request)

授权请求
----

选择“授权”选项卡并输入以下值：

* 类型： `Basic Auth`
* 用户名：您的 Vonage API 密钥
* 密码：您的 Vonage API 密码

> **注意** ：您可以在[开发人员 Dashboard](https://dashboard.nexmo.com) 中找到您的 API 密钥和密码。

![创建报告](/images/reports-api/create-report-postman.png)

设置请求主体的格式
---------

在“主体”选项卡中，选择“原始”单选按钮，并从下拉列表中选择“JSON”。

![设置请求格式](/images/reports-api/format-request-body-postman.png)

创建请求
----

在“主体”选项卡中，输入如下所示的请求主体，将 API 密钥替换为您自己的 API 密钥，并将 `date_start` 和 `date_end` 替换为您感兴趣的时间段内的适当值。

> **注意** ：不包括 `end_date` 参数 - 生成的报告涵盖从 `start_date` 到 `end_date` 中指定的时间和日期之前的时间段。

### 短信报告

![创建短信报告请求](/images/reports-api/create-request-body-sms-postman.png)

### 语音报告

![创建短信报告请求](/images/reports-api/create-request-body-voice-postman.png)

> **注意** ：`product` 必须是 `SMS`、`VOICE-CALL`、`VERIFY-API`、`NUMBER-INSIGHT`、`MESSAGES` 或 `CONVERSATION` 之一。

执行请求
----

点击“发送”按钮。响应将显示为以下格式：

```json
{
    "request_id": "a68908f0-4f23-4b47-a09b-9f4de0ce0737",
    "request_status": "PENDING",
    "product": "SMS",
    "account_id": "VONAGE_API_KEY",
    "date_start": "2019-04-01T00:00:00+0000",
    "date_end": "2019-07-01T00:00:00+0000",
    "include_subaccounts": false,
    "direction": "outbound",
    "include_message": false,
    "receive_time": "2019-10-25T14:13:38+0000",
    "_links": {
        "self": {
            "href": "https://api.nexmo.com/v2/reports/a68908f0-4f23-4b47-a09b-9f4de0ce0737"
        }
    }
}
```

> **注意** ：如果要查询的数据量很大，则可能需要一段时间才能生成报告。

