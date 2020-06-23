---
title:  着信 SMS
description:  Nexmo の仮想番号で SMS を受信する方法。
navigation_weight:  5

---


着信 SMS
======

着信 SMS を受け取るには、[Web フックエンドポイント](/concepts/guides/webhooks)を作成し、[Nexmo Developer Dashboard](https://dashboard.nexmo.com/settings) の [API 設定タブ] でそのエンドポイントを使用するアカウントを設定します。

Nexmo 仮想番号への送信メッセージは [GET] または [POST] リクエストを使って Web フックに送信されます。Web フックでメッセージを受信する場合、「`200 OK`」という応答を送信する必要があります。送信しない場合、Nexmo は受信者がメッセージを受信していないと推測して、その後 24 時間送信し続けます。

連結メッセージには特別な注意が必要です。[連結着信メッセージ](#for-concatenated-inbound-messages)を参照してください。

着信メッセージの構造
----------

メッセージは次の特質を持つ JSON オブジェクトとして Web フックエンドポイントに送信されます。

キー | 値 | 必須/任意
--|--|--
`type` | 次のいずれかの値を取ります </br> * `text` - 標準テキスト </br> * `unicode` - Unicode 文字を含むテキストメッセージ </br> * `binary` - バイナリメッセージ | 必須 
`to` | メッセージの送信 *先* の電話番号。 **ユーザーの仮想番号** となります。|必須 
`msisdn` | 着信メッセージの送信 *元* の電話番号。| 必須 
`messageId` | 対象メッセージ用の Nexmo の固有識別子。|必須
`message-timestamp` | Nexmo が着信メッセージをエンドポイントにプッシュし始めた時間。[協定世界時との時差](https://en.wikipedia.org/wiki/UTC%C2%B100:00)で表され、「`YYYY-MM-DD HH:MM:SS`」の形式を取ります。|必須 
`timestamp` | `message-timestamp` の [UNIX タイムスタンプ](https://www.unixtimestamp.com/)表示。| 任意 
`nonce` | リクエストの署名に予測不能の追加要素を加えるランダムな文字列。着信メッセージの署名を計算・検証するには、`nonce` と `timestamp` パラメーターを共有の秘密と併用します。| [署名入り](/concepts/guides/signing-messages)メッセージには必須

### メッセージのタイプが `text` または <code translate="no">unicode</code> の場合 `unicode`

メッセージの `type` が `text` または `unicode` の場合、Web フックエンドポイントへのリクエストに次のプロパティが表示されます。

キー | 値
-- | --
`text` | 着信メッセージの本文。
`keyword` | メッセージ本文の最初の単語。通常、短縮コードと併用されます。

### メッセージのタイプが <code translate="no">binary</code> の場合 `binary`

メッセージの `type` が `binary` の場合、Web フックエンドポイントへのリクエストに次のプロパティが表示されます。

キー |値
-- | --
`data` | このメッセージの内容
`udh` | 16 進でエンコードされた[ユーザーデータヘッダ](https://en.wikipedia.org/wiki/User_Data_Header)

### 連結着信メッセージの場合

仮想番号への送信メッセージが単一メッセージに許容される長さに収まる場合、Web フックエンドポイントへのリクエストには次のプロパティは表示されません。

メッセージの文字数が単一メッセージの最大文字数を超える場合、複数のパートに分けてメッセージを受信し、リクエストに次のプロパティが表示されます。

`concat-ref`、`concat-total`、`concat-part` の各プロパティを使って個別のパートでメッセージが構築されます。

> 通信会社が連結メッセージをサポートしていない場合もあります。お使いの通信会社が連結メッセージをサポートしていない場合、ペイロードには `concat` フィールドがありません。

キー | 値
-- | --
`concat` | `true`
`concat-ref` | トランザクションの参照。メッセージのどのパートもこの `concat-ref` を共有します。
`concat-total` | この連結メッセージの構成パート数。
`concat-part` | メッセージにおけるこのパートの番号。メッセージの最初のパートの番号は `1` です。

