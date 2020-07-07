---
title:  SMS を送信
description:  Nexmo SMS 用 API を使った SMS の送信方法
navigation_weight:  2

---


SMS の送信
=======

SMS を送信するには、以下の例の次の変数を置き換えます。

キー | 説明
-- | --
`TO_NUMBER` | E.164 format での SMS の送信先番号。例: `447700900000`。
`NEXMO_API_KEY` | アカウント概要でご確認ください
`NEXMO_API_SECRET` | アカウント概要でご確認ください

```code_snippets
source: '_examples/messaging/sms/send-an-sms'
```

試行手順
----

上記例を実行すると、指定した携帯電話番号にテキストメッセージが送信されます。

関連情報
----

* [Node.js と Express を使った SMS メッセージの送信方法](https://www.nexmo.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/)
* [顧客エンゲージメント用双方向 SMS](/tutorials/two-way-sms-for-customer-engagement)

