---
title:  创建 Node.js 应用程序
description:  在此步骤中，您将创建基本 Node.js 应用程序

---

创建 Node.js 应用程序
===============

在终端提示符输入以下命令：

```sh
mkdir stepup-auth
cd stepup-auth
touch server.js
```

运行 `npm init` 以创建 Node.js 应用程序，并接受所有默认设置。

您要创建的应用程序使用 [Express](https://expressjs.com/) 框架进行路由，并使用 [Pug](https://www.npmjs.com/package/pug) 模板系统构建 UI。

除了 `express` 和 `pug`，您还将使用以下外部模块：

* `express-session` - 管理用户的登录状态
* `body-parser` - 解析 `POST` 请求
* `dotenv` - 将您的 Vonage API 密钥和密码以及应用程序名称存储在 `.env` 文件中
* `nexmo` - [Node Server SDK](https://github.com/nexmo/nexmo-node)

通过在终端提示符运行以下 `npm` 命令来安装这些依赖项：

```sh
npm install express express-session pug body-parser dotenv nexmo
```

> **注意** ：本教程假定您已经安装了 [Node.js](https://nodejs.org/) 并在类似 Unix 的环境中运行。Windows 环境的终端命令可能会有所不同。

