---
title:  概要
meta_title:  SMS、MMS、WhatsApp、Viber、Facebook Messenger から同じ API を使ってメッセージを送信しましょう。
navigation_weight:  1

---


メッセージ用 API の概要
==============

メッセージ用 API は次の通信チャネルでのメッセージ送信 (一部は送受信) に対応しています。

* SMS/MMS
* Facebook Messenger
* Viber
* WhatsApp

今後、他のチャネルもサポートする可能性があります。

下図ではメッセージ用 API と配信用 API の関係が示されています。

![メッセージと配信の概要](/assets/images/messages-dispatch-overview.png)

内容
---

* [ベータ版について](#beta)
* [サポート機能](#supported-features)
* [外部アカウント用 API](#external-accounts-api)
* [最初のステップ](#getting-started)
* [基本概念](#concepts)
* [コードスニペット](#code-snippets)
* [チュートリアル](#tutorials)
* [ユースケース](#use-cases)
* [関連情報](#reference)

ベータ版について
--------

この API は現在ベータ版です。

Nexmo ではユーザーからのフィードバックを常に歓迎しています。ご提案は製品の改善に役立ちます。サポートが必要な場合は件名に「メッセージ用 API」を含めて、[api.support@vonage.com](mailto:api.support@vonage.com) 宛てにメールを送信してください。恐れ入りますが、ベータ版の期間中、サポート対応時間は月曜から金曜に限定させていただきます。

Nexmo はベータ版の期間中、API 機能の拡張に取り組みます。

サポート機能
------

今回のリリースでは次の機能をサポートしています。

| チャネル               | 発信テキスト | 発信画像 | 発信オーディオ | 発信動画 | 発信ファイル | 発信テンプレート |
|:-------------------|:------:|:----:|:-------:|:----:|:------:|:--------:|
| SMS                |   ✅    | 非対応  |   非対応   | 非対応  |  非対応   |   非対応    |
| MMS                |   ✅    |  ✅   |   非対応   | 非対応  |  非対応   |   非対応    |
| Viber サービスメッセージ    |   ✅    |  ✅   |   非対応   | 非対応  |  非対応   |    ✅     |
| Facebook Messenger |   ✅    |  ✅   |    ✅    |  ✅   |   ✅    |    ✅     |
| WhatsApp           |   ✅    |  ✅   |    ✅    |  ✅   |   ✅    |    ✅     |

| チャネル               | 着信テキスト | 着信画像 | 着信オーディオ | 着信動画 | 着信ファイル | 着信場所 |
|:-------------------|:------:|:----:|:-------:|:----:|:------:|:----:|
| MMS                |   ✅    |  ✅   |   非対応   | 非対応  |  非対応   | 非対応  |
| Viber サービスメッセージ    |   ✅    | 非対応  |   非対応   | 非対応  |  非対応   | 非対応  |
| Facebook Messenger |   ✅    |  ✅   |    ✅    |  ✅   |   ✅    |  ✅   |
| WhatsApp           |   ✅    |  ✅   |    ✅    |  ✅   |   ✅    |  ✅   |

下表のとおり、[カスタムオブジェクト](/messages/concepts/custom-objects)も一部サポートしています。

| チャネル               | 発信ボタン | 発信場所 | 発信連絡先 |
|:-------------------|:-----:|:----:|:-----:|
| SMS                |  非対応  | 非対応  |  非対応  |
| MMS                |  非対応  | 非対応  |  非対応  |
| Viber サービスメッセージ    |   ✅   | 非対応  |  非対応  |
| Facebook Messenger |   ✅   | 非対応  |  非対応  |
| WhatsApp           |   ✅   |  ✅   |   ✅   |

**キー:** 

* ✅ = サポート対象。
* ❌ = チャネルではサポート対象、Nexmo ではサポート対象外。
* n/a = 該当チャネルではサポート対象外。

外部アカウント用 API
------------

[外部アカウント用 API](/api/external-accounts) は Viber サービスメッセージ、Facebook Messenger、WhatsApp をメッセージ用 API と配信用 API で使用する際、各チャネルのアカウント管理に使用されます。

最初のステップ
-------

この例では、適当な手段を使って次の変数を実際の値に置き換える必要があります。

キー | 説明
-- | --
`NEXMO_API_KEY` | Nexmo API のキー ([Nexmo Dashboard](https://dashboard.nexmo.com) から取得可能)。
`NEXMO_API_SECRET` | Nexmo API のシークレット ([Nexmo Dashboard](https://dashboard.nexmo.com) から取得可能)。
`FROM_NUMBER` | 自分の電話番号または送信者の識別用テキスト。
`TO_NUMBER` | メッセージの送信先となる電話番号。

> **注:** 電話番号は先頭に `+` や `00` を付けずに国番号から入力してください (例: 447700900000)。

次のコードはメッセージ用 API を使った SMS メッセージの送信方法を示しています。

```code_snippets
source: '_examples/messages/sms/send-sms-basic-auth'
```

基本概念
----

```concept_list
product: messages
```

コードスニペット
--------

```code_snippet_list
product: messages
```

チュートリアル
-------

* [SMS メッセージの送信方法](/messages/tutorials/send-sms-with-messages/introduction)
* [Viber メッセージの送信方法](/messages/tutorials/send-viber-message/introduction)
* [WhatsApp メッセージの送信方法](/messages/tutorials/send-whatsapp-message/introduction)
* [Facebook Messenger メッセージの送信方法](/messages/tutorials/send-fbm-message/introduction)

ユースケース
------

```use_cases
product: messages
```

関連情報
----

* [メッセージ用 API の関連情報](/api/messages-olympus)
* [外部アカウント用 API の関連情報](/api/external-accounts)

