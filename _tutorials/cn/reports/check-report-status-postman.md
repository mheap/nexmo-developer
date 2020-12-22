---
title:  检查报告状态
description:  检查报告进度

---

检查报告状态
======

通过向 `href` 中指定的 URL（`_links` 下方）发出 `GET` 请求来响应您的[创建报告请求](/reports/tutorials/create-report-using-graphical-tools/reports/create-report-postman#create-the-request)，检查报告是否准备就绪。

创建获取状态请求
--------

要发出请求：

1. 将 HTTP 方法更改为 `GET`。
2. 在地址栏中输入报告特定的 URL。
3. 如上一步所述，完成“授权”选项卡。
4. 在“主体”选项卡中，选择“无”单选按钮。

![请求报告状态](/images/reports-api/request-status-postman.png)

执行获取状态请求
--------

点击“发送”按钮。响应中的 `request_status` 字段应包含 `PROCESSING` 或 `SUCCESS`。如果是 `PROCESSING`，请再等待几分钟，然后再重复相同的检查状态请求。

示例：

```json
{
    "request_id": "a68908f0-4f23-4b47-a09b-9f4de0ce0737",
    "request_status": "PROCESSING",
    "product": "SMS",
    "account_id": "NEXMO_API_KEY",
    "date_start": "2019-04-01T00:00:00+0000",
    "date_end": "2019-07-01T00:00:00+0000",
    "include_subaccounts": false,
    "direction": "outbound",
    "include_message": false,
    "receive_time": "2019-10-25T14:13:38+0000",
    "start_time": "2019-10-25T14:13:39+0000",
    "_links": {
        "self": {
            "href": "https://api.nexmo.com/v2/reports/a68908f0-4f23-4b47-a09b-9f4de0ce0737"
        },
        "download_report": {
            "href": "https://api.nexmo.com/v3/media/885f608c-76af-4c5f-a0bb-242dee60ffd8"
        }
    },
    "items_count": 45544
}
```

