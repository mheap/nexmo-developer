---
title:  检查报告状态
description:  检查报告进度

---

检查报告状态
======

请求报告后，可能需要一些时间才能生成报告。您可以通过调用 `GET /v2/reports/:id` 端点来检查报告的进度，例如：

```bash
curl -u API_KEY:API_SECRET https://api.nexmo.com/v2/reports/REQUEST_ID
```

将 `REQUEST_ID` 替换为[创建报告端点的初始调用](/reports/tutorials/create-and-retrieve-a-report/reports/create-report)返回的 `request_id`。

> 除了轮询报告的状态之外，您还可以注册一个 Webhook，Vonage 的 API 将在生成报告时向其发出请求。为此，请在创建报告时指定 `callback_url` 参数。

响应将包含报告的相关信息。只有在完成报告的生成时，才会显示 `download_report` 字段。您可以使用它来[检索报告](/reports/tutorials/create-and-retrieve-a-report/reports/download-report)，如下一步所示。

```json
{
  "request_id": "6c5506b7-f16a-44dc-af06-756bbf467488",
  "request_status": "SUCCESS",
  "product": "SMS",
  "account_id": "$API_KEY",
  "date_start": "2019-02-27T00:00:00+0000",
  "date_end": "2019-02-28T23:59:59+0000",
  "include_subaccounts": false,
  "direction": "outbound",
  "include_message": false,
  "receive_time": "2019-06-17T16:39:06+0000",
  "start_time": "2019-06-17T16:39:06+0000",
  "_links": {
    "self": {
      "href": "https://api.nexmo.com/v2/reports/6c5506b7-f16a-44dc-af06-756bbf467488"
    },
    "download_report": {
      "href": "https://api.nexmo.com/v3/media/b003ed27-b4b2-4a7d-b4a5-6255ce08eea5"
    }
  },
  "items_count": 14952
}
```

