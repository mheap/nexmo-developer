---
title:  初始化依赖项
description:  加载应用程序将使用的模块

---

初始化依赖项
======

在 `server.js` 中，编写以下代码以初始化依赖项并定义一些用于配置应用程序的变量：

```javascript
require('dotenv').config();

const path = require('path')
const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const app = express();
const Nexmo = require('nexmo');

const VONAGE_API_KEY = process.env.VONAGE_API_KEY;
const VONAGE_API_SECRET = process.env.VONAGE_API_SECRET;
const VONAGE_BRAND_NAME = process.env.VONAGE_BRAND_NAME;

let verifyRequestId = null;
let verifyRequestNumber = null;

// Location of the application's CSS files
app.use(express.static('public'));

// The session object we will use to manage the user's login state
app.use(session({
    secret: 'loadsofrandomstuff',
    resave: false,
    saveUninitialized: true
}));

app.use(bodyParser.urlencoded({ extended: true }));

// For templating
app.set('view engine', 'pug');

// Define your routes here

// Run the web server
const server = app.listen(3000, () => {
    console.log(`Server running on port ${server.address().port}`);
});
```

