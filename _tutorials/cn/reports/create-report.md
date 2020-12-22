---
title:  使用命令行创建 CSV 报告
description:  在此步骤中，您将学习如何使用命令行工具 `curl` 创建报告。

---

创建报告
====

要创建报告，请向 `https://api.nexmo.com/v2/reports` 发送 `POST` 请求。您包含在请求中的参数将确定返回哪些记录。

例如，使用以下请求查看 2019 年 6 月从您的 Vonage 帐户发送的所有短信：

```bash
curl -X POST https://api.nexmo.com/v2/reports/ \
  -u $API_KEY:$API_SECRET \
  -H "Content-Type: application/json" \
  -d '{"account_id": "API_KEY","product": "SMS","direction": "outbound","date_start": "2019-06-01T00:00:00+0000","date_end": "2019-07-01T00:00:00+0000"}'
```

响应包含 `request_id`。请记下其内容，将来[检查报告状态](/reports/tutorials/create-and-retrieve-a-report/reports/check-report-status)时需要用到。

> **注意** ：使用日期范围进行过滤时，包括 `start_date`，不包括 `end_date`。这意味着以上示例将不包含 `00:00:00` 发送的任何短信。

如需可用的过滤参数的完整列表，请参阅 [Reports API 参考](/api/reports)。

