---
title:  配置应用程序
description:  创建配置文件来存储您的身份验证及其他详细信息

---

配置应用程序
======

您将 API 密钥和密码（可在[开发人员 Dashboard](https://dashboard.nexmo.com) 中找到）和组织名称存储在配置文件中。

在应用程序根目录中创建名为 `.env` 的文件，并输入以下信息，将 `YOUR_API_KEY` 和 `YOUR_API_SECRET` 替换为您自己的密钥和密码：

    NEXMO_API_KEY=YOUR_API_KEY
    NEXMO_API_SECRET=YOUR_API_SECRET
    NEXMO_BRAND_NAME=AcmeInc

