---
title:  下载报告
description:  下载完成的报告

---

下载报告
====

报告准备就绪（检查状态请求中的 `request_status` 字段显示 `SUCCESS`）时，您可以通过在 `download_report` 字段中向该 URL 发出 `GET` 请求来下载报告。

创建下载请求
------

要发出请求：

1. 将 HTTP 方法更改为 `GET`。
2. 在地址栏中输入 `download_report` URL。
3. 采用和之前一样的方式完成“授权”选项卡。
4. 在“主体”选项卡中，选择“无”单选按钮。

![下载报告](/images/reports-api/download-report-postman.png)

执行下载请求
------

点击“发送”按钮。响应包含不可读取的文本，因为 API 返回了压缩的 CSV 文件。

单击 Postman 中的“保存响应”按钮，选择“保存到文件”选项，然后在本地计算机上选择用于保存 `.zip` 文件的位置。

![本地保存压缩文件](/images/reports-api/save-report-zip-postman.png)

提取 `.zip` 文件的内容并打开 `.csv` 文件以查看您的报告。

