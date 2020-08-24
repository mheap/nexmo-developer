---
title:  Unicode を含む SMS を送信
description:  Unicode を含む SMS を Nexmo SMS 用 API で送信する方法
navigation_weight:  3

---


Unicode を含む SMS の送信
===================

Nexmo の SMS 用 API は、中国語、日本語、韓国語での通信時に必要となる Unicode 文字もサポートしています。

Unicode 文字を含む SMS を送信するには、以下の例の次の変数を置き換えます。

キー | 説明
-- | --
`TO_NUMBER` | SMS の送信先番号 (例: `447700900000`)。
`NEXMO_API_KEY` | Nexmo Dashboard でご確認ください。
`NEXMO_API_SECRET` | Nexmo Dashboard でご確認ください。

```code_snippets
source: '_examples/messaging/sms/send-an-sms-with-unicode'
```

試行手順
----

上記例を実行すると、指定した携帯電話番号に Unicode 文字を含むメッセージが正常に送信されます。

> Unicode メッセージの最大文字数は通常のメッセージの 160 でなく 70 であることにご注意ください。この点に関する詳細については[ヘルプページ](https://help.nexmo.com/hc/en-us/articles/204076866-How-long-is-a-single-SMS-body-)を参照してください

関連情報
----

* [SMS の連結とエンコード](/messaging/sms/guides/concatenation-and-encoding)
* [Node.js と Express を使った SMS メッセージの送信方法](https://www.nexmo.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/)
* [顧客エンゲージメント用双方向 SMS](/tutorials/two-way-sms-for-customer-engagement)

