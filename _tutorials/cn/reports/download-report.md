---
title:  下载报告

---

下载报告
====

生成报告后，您可以使用 Media API 下载结果。

```bash
curl -u $API_KEY:$API_SECRET -o report.zip DOWNLOAD_URL
```

将 `DOWNLOAD_URL` 替换为[报告状态响应](/reports/tutorials/create-and-retrieve-a-report/reports/check-report-status)的 `download_report` 字段中提供的链接。

运行上述命令后，会将报告作为名为 `report.zip` 的文件下载到当前文件夹中。解压缩此压缩文件以查看您的报告。

