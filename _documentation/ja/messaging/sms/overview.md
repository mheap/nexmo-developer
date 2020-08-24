---
title:  概要
description:  このドキュメントでは、テキストメッセージの送受信に使用する Nexmo SMS 用 API に関する情報を掲載しています。
meta_title:  SMS 用 API を使って SMS を送信・受信する。

---


SMS 用 API
=========

Nexmo の SMS 用 API を使用すると、簡単な REST 用 API を使ったテキストメッセージのやり取りが世界中で可能になります。

* プログラムを使って、大量の SMS を世界中で送受信。
* 低レイテンシと確実性の高い方法で SMS を送信。
* ローカル番号を使って SMS を受信。
* 使い慣れた Web テクノロジーでアプリケーションを拡張。
* 使用した分だけ支払い、追加の支払いはなし。

内容
---

このトピックでは次の内容について説明します。

* [最初のステップ](#getting-started) - 最初のステップをすぐ開始するための情報
* [トラブルシューティング](#troubleshooting) - メッセージオブジェクトのステータスフィールドとエラーコード情報
* [基本概念](#concepts) - 初歩的概念
* [ガイド](#guides) - SMS 用 API の使用方法に関する説明
* [コードスニペット](#code-snippets) - 特定のタスクに役立つコードスニペット
* [ユースケース](#use-cases) - コードサンプルのユースケース
* [関連情報](#reference) - REST 用 API のドキュメント

最初のステップ
-------

### SMS を送信

以下の例では、選択した番号への SMS 送信方法を説明します。

Nexmo に登録していない場合は、まず [Nexmo アカウントにサインアップ](https://dashboard.nexmo.com/sign-up)します。[Dashboard の [最初のステップ] ページ](https://dashboard.nexmo.com/getting-started-guide)の API キーとシークレットを書き留めます。

次のサンプルコードに含まれるプレースホルダーの値を置き換えます。

キー | 説明
-- | --
`NEXMO_API_KEY` | Nexmo の API キー。
`NEXMO_API_SECRET` | Nexmo の API シークレット。

```code_snippets
source: '_examples/messaging/sms/send-an-sms'
```

トラブルシューティング
-----------

API コールで問題が生じた場合、[ステータスフィールド](/messaging/sms/guides/troubleshooting-sms)を再確認して、[エラーコード](/messaging/sms/guides/troubleshooting-sms#sms-api-error-codes)を必ず特定してください。

基本概念
----

Nexmo の SMS 用 API を使い始める前に、次の項目を把握しておきます。

* **[番号形式](/voice/voice-api/guides/numbers)** - SMS 用 API には E.164 format の電話番号が必要です。

* **[認証](/concepts/guides/authentication)** - アカウント用 API キーとシークレットを使用する SMS 用 API 認証。

* **[Web フック](/concepts/guides/webhooks)** - SMS 用 API は着信 SMS や受信確認など、判断基準となる HTTP リクエストをアプリケーションの Web サーバーに出します。

ガイド
---

```concept_list
product: messaging/sms
```

コードスニペット
--------

```code_snippet_list
product: messaging/sms
```

ユースケース
------

```use_cases
product: messaging/sms
```

関連情報
----

* [SMS 用 API の関連情報](/api/sms)
* [応答オブジェクトのステータスフィールド](/messaging/sms/guides/troubleshooting-sms)
* [エラーコード](/messaging/sms/guides/troubleshooting-sms#sms-api-error-codes)

