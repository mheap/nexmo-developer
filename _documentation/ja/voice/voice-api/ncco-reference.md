---
title:  NCCO の参照
description:  Nexmo Call Control Objects (NCCO) は音声用 API コールの管理に使用されます。

---


NCCO の関連情報
==========

Nexmo Call Control Object (NCCO) は、音声用 API コールフローの操作に使用される JSON 配列です。NCCO が適切に実行されるには、この JSON オブジェクトが有効でなければなりません。

NCCO の開発・テスト中は、音声プレイグラウンドを使って NCCO をインタラクティブに試すことができます。詳細については、「[音声用 API の概要](/voice/voice-api/overview#voice-playground)」を読むか、[Dashboard の [音声プレイグラウンド] で直接確かめる](https://dashboard.nexmo.com/voice/playground)ことができます。

NCCO アクション
----------

コールフローは NCCO のアクションの順番によって制御されます。次のアクションの実行前に完了しなければならない複数のアクションは *同期的* であり、他のアクションは *非同期的* です。つまり、条件が満たされるまで後続アクションを継続する仕組みになっています。たとえば `record` アクションは `endOnSilence` オプションが満たされると終了します。NCCO のすべてのアクションが完了すると、コールは終了します。

以下は NCCO アクションとオプション、および各アクションのタイプです。

アクション | 説明 | 同期/非同期
-- | -- | --
[録音](#record) | コールの全部または一部 | 非同期
[カンバセーション](#conversation) | [カンバセーション](/conversation/concepts/conversation)を作成または既存のカンバセーションに参加 | 同期
[接続](#connect) | 電話番号や VBC 内線などの接続可能なエンドポイント。| 同期
[発話](#talk) | 合成発話をカンバセーションに送信。| 同期。ただし *bargeIn=true* の場合を除く
[ストリーム](#stream) | オーディオファイルをカンバセーションに送信。| 同期、ただし *bargeIn=true* の場合を除く
[入力](#input) | コール相手から桁情報を収集。| 同期
[通知](#notify) | NCCO から進捗を追跡するようアプリケーションにリクエストを送信 |はい

> **注** : [着信コールの接続](/voice/voice-api/code-snippets/connect-an-inbound-call)は、コールやカンファレンスの開始後に Nexmo で NCCO を利用する一例です

録音 (record)
---------------

`record` アクションを使ってコール全体または一部を録音します。

```json
[
  {
    "action": "record",
    "eventUrl": ["https://example.com/recordings"]
  },
  {
    "action": "connect",
    "eventUrl": ["https://example.com/events"],
    "from":"447700900000",
    "endpoint": [
      {
        "type": "phone",
        "number": "447700900001"
      }
    ]
  }
]
```

録音アクションは非同期的です。NCCO で録音アクションが実行されると録音が開始され、このアクションで同期条件が満たされると録音が終了します。具体的には、`endOnSilence`、`timeOut` または `endOnKey` といったアクションです。同期的条件を設定しない場合、音声用 API は録音せずに次の NCCO をすぐに実行します。

適用ワークフローの詳細については、「[録音](/voice/voice-api/guides/recording)」を参照してください。

次のオプションを使って `record` アクションを操作できます。

オプション | 説明 | 必須/任意
-- | -- | --
| `format` | 特定形式でコールを録音。以下の 3 つの形式を選択可能。</br> * `mp3` </br> * `wav` </br> * `ogg` </br> デフォルト値は `mp3`。チャネル数が 2 を超える場合は `wav`。| 任意 | 
| `split` | 送受信オーディオをステレオ録音式の別々のチャネルで録音。このアクションを有効にするには `conversation` に設定。|任意 |
|`channels` | 録音チャネル数 (最大 `32`)。参加者数が | |`channels` を超える場合、1 人超過するたびにファイルの最後のチャネルに追加。分割された `conversation` も有効化が必要。|任意 |
| `endOnSilence` | 無音状態がn秒続いた後、録音停止。録音停止後、録音データは `event_url` に送信。可能な値レンジは 3 以上 10 以下の `endOnSilence`。| 任意 |
| `endOnKey` | 携帯電話に桁がプッシュされると録音停止。可能な値レンジは、`*`、`#` または <code translate="no">9</code> などの任意の 1 桁の値`9` | 任意 | 
| `timeOut` | 最大録音時間 (秒単位)。録音停止後、録音データは `event_url` に送信。可能な値レンジは `3` 秒 ～ `7200` 秒 (2 時間) | 任意 | 
| `beepStart` | `true` に設定して、録音開始時にビープ音を再生 | 任意 | 
| `eventUrl` | 録音終了時に非同期に呼び出される Web フックエンドポイントの URL。録音中のメッセージが Nexmo でホストされる場合、[録音データなどのメタデータのダウンロードに必要な URL](#recording_return_parameters) がこの Web フックに含まれます。| 任意 |
|  `eventMethod` | `eventUrl` へのリクエストに使用される HTTP 方式。デフォルト値は `POST`。| 任意

<a id="recording_return_parameters"></a>
以下の例では `eventUrl` に送信される戻りパラメーターが示されています。

```json
{
  "start_time": "2020-01-01T12:00:00Z",
  "recording_url": "https://api.nexmo.com/v1/files/aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "size": 12345,
  "recording_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "end_time": "2020-01-01T12:01:00Z",
  "conversation_uuid": "bbbbbbbb-cccc-dddd-eeee-0123456789ab",
  "timestamp": "2020-01-01T14:00:00.000Z"
}
```

可能な戻りパラメーターは下表のとおりです。

名前 | 説明
-- | --
`recording_uuid` | このコールに固有の ID。  </br> **注** : `recording_uuid` は *recording\_url* の file uuid と同じではありません。
`recording_url` | コール録音を含むファイルの URL
`start_time` | 録音開始時刻 (ISO 8601 形式): `YYYY-MM-DDTHH:MM:SSZ`。例: `2020-01-01T12:00:00Z`
`end_time` | 録音終了時刻 (ISO 8601 形式): `YYYY-MM-DDTHH:MM:SSZ`。例: `2020-01-01T12:00:00Z`
`size` | *recording\_url* での録音サイズ (バイト単位)。例: `603423`
`conversation_uuid` | このコールに固有の ID。

カンバセーション
--------

`conversation` アクションを使うと、コミュニケーションのコンテキストを維持しながら、標準またはモデレーター付きのカンファレンスを作成できるようになります。同じ `name` の `conversation` を使用する場合、同一の持続的な [カンバセーション](/conversation/concepts/conversation)が再利用されます。カンバセーションに割り当てられる仮想番号に最初にコールする人物がカンバセーションの作成者となります。このアクションは同期的です。

> **注** : 最大 50 人までカンバセーションに招待できます。

次の NCCO の例では各カンバセーションタイプの設定方法が示されています。`answer_url` Web フックの GET リクエストパラメーターを使うと、1 つの NCCO を参加者に、別の NCCO をモデレーターに配信できるようになります。

```tabbed_content
source: '/_examples/voice/guides/ncco-reference/conversation'
```

次のオプションを使って *カンバセーション* を操作できます。

オプション | 説明 | 必須/任意
-- | -- | --
`name` | カンバセーションルームの名前。アプリケーションレベルでは個別の名前が必要。| 必須
`musicOnHoldUrl` | カンバセーション開始まで、参加者にストリーミングされる *MP3* ファイルの URL。カンバセーションはデフォルト設定では、音声アプリに関連付けられる仮想番号に最初の人物がコールしたときに開始します。モデレーターがカンバセーションに参加する前にこの mp3 をストリーミングするには、モデレーター以外のユーザー全員について *startOnEnter* を *false* に設定。| 任意
`startOnEnter` | *true* (デフォルト)に設定すると、コール者のカンバセーション `name` への参加に伴いカンバセーションが開始するようにします。モデレーター付きカンバセーションの出席者について *false* に設定。| 任意
`endOnExit` | モデレーターがコールを終了したときにモデレーター付きカンバセーションが終了するかどうかを指定。デフォルト値の *false* では、カンバセーションは、モデレーターがコール中かどうかにかかわらず、最後の参加者がコールを終了したときにのみ終了。`endOnExit` を *true* に設定すると、モデレーターがコールを終了したときにカンバセーションが終了。| 任意
`record` | *true* に設定してカンバセーションを録音します。標準的なカンバセーションでは、1 人以上の出席者がカンバセーションに接続すると録音が開始されます。モデレーター付きカンバセーションでは、モデレーターが参加したときに録音が開始されます。 *startOnEnter* が *true* に設定される名前付きカンバセーションではこのタイミングで NCCO が実行されます。録音が終了すると、録音のダウンロード元の URL がイベント URL に送信されます。 </br> オーディオはデフォルトでは MP3 形式で録音されます。詳細は[録音](/voice/voice-api/guides/recording#file-formats)ガイドを参照 | 任意
`canSpeak` | 参加者の声が聞こえるコールレッグの UUID リスト。提供されない場合、全員が参加者の声を聞くことができます。リストが空の場合、誰にも参加者の声は聞こえません | 任意
`canHear` | 参加者に聞こえるコールレッグの UUID リスト。提供されない場合、参加者には全員の声が聞こえます。リストが空の場合、参加者には他の参加者の声が聞こえません| 任意

接続 (connect)
----------------

`connect` アクションを使うと、電話番号または VBC 内線などのエンドポイントをコールに接続できるようになります。

このアクションは同期的で、 *connect* の後には NCCO スタックの次のアクションが処理されます。接続アクションは、コールしているエンドポイントがビジーまたはコールできない場合に終了します。接続アクションをネストすることでエンドポイントを順番に呼び出します。

次の NCCO の例では各接続タイプの設定方法が示されています。

```tabbed_content
source: '/_examples/voice/guides/ncco-reference/connect'
```

次のオプションを使って `connect` アクションを操作できます。

オプション | 説明 | 必須/任意
-- | -- | --
`endpoint` | 単一エンドポイントに接続。[利用可能なエンドポイントのタイプ](#endpoint-types-and-values) | 必須
`from` |コール者を特定する [E.164](https://en.wikipedia.org/wiki/E.164) format の数字。Nexmo 仮想番号のいずれかである必要があります。別の値にするとコール者 ID が不明になります。コール者がアプリを利用している場合、このオプションは省略してください。| 任意
`eventType` | 次の目的で、`synchronous` に設定。 </br> * `connect` アクションを同期的にするため </br> * `eventUrl` を有効にして、コールが特定の状態に移行したときに、現在の NCCO を上書きする NCCO を返すため。| 任意 
`timeout` | 呼び出し音に応答がない場合、Nexmo が `endpoint` の呼び出しを止めるまでの秒数を設定。デフォルト値は `60`。 | |
`limit` | 呼び出し音の最大秒数。デフォルトかつ最大値は `7200` 秒 (2 時間)。| 任意 
`machineDetection` | 送信先が留守番電話であることを検知したときに Nexmo が取る動作を設定。次のいずれかを選択します。 </br> * `continue` - Nexmo はコールイベントと共に、HTTP リクエストを `event_url` に送信 `machine` </br> * `hangup` - コールを終了 | 任意
`eventUrl` | 各[コール状態](/voice/voice-api/guides/call-flow#call-states)候補について Nexmo が非同期に呼び出す Web フックエンドポイントを設定。`eventType` が `synchronous` に設定される場合、`eventUrl` はタイムアウト発生時に現在の NCCO を上書きする NCCO を返す可能性があります。| 任意
`eventMethod` | *eventUrl* へのリクエストに Nexmo が採用する HTTP 方式。デフォルト値は `POST`。| 任意 
`ringbackTone` | `ringbackTone` にポイントして **コール者** に繰り返し再生され、無音状態がなくなるようにする URL 値。コールが完全に接続すると、`ringbackTone` は自動的に再生を停止します。携帯電話のエンドポイントに接続する場合、通信会社は独自の`ringbackTone` を提供するため、このパラメーターの使用は推奨されません。例: `"ringbackTone": "http://example.com/ringbackTone.wav"`.| 任意

### エンドポイントのタイプと値

#### 電話 - E.164 format の電話番号

値 | 説明
-- | --
`number` | [E.164](https://en.wikipedia.org/wiki/E.164) format で接続する電話番号。
`dtmfAnswer` | コールが応答され次第ユーザーに送信される桁を設定。`*` と `#` の桁も使用。`p` を使って一時停止(500 ミリ秒/回)。
`onAnswer` | 必須の `url` キーを含む JSON オブジェクト。URL はコールが既存カンバセーションに加わる前に、NCCO を接続先番号で実行する役割を果たします。`ringbackTone` が **コール者** に対して繰り返し再生され、無音状態を避けるようにする URL 値で `ringbackTone` キーを指定することもできます。コールが完全に接続すると、`ringbackTone` は自動的に再生を停止します。例: `{"url":"https://example.com/answer", "ringbackTone":"http://example.com/ringbackTone.wav" }`.`ringback` キーも引き続きサポートされます。

#### アプリ - コールをアプリに接続

値 | 説明
-- | --
`user` | 接続先のユーザー名。このユーザー名を [ユーザーとして追加](/api/conversation#createUser)しておく必要があります

#### Web ソケット - 接続先となる Web ソケット

値 | 説明
-- | --
`uri` | ストリーミングしている Web ソケットへの URI。
`content-type` | ストリーミングしているオーディオのインターネットメディアタイプ。可能な値は、`audio/l16;rate=16000` または `audio/l16;rate=8000`。
`headers` | ユーザーが必要とするメタデータを含む JSON オブジェクト。ヘッダのサンプルは、[Web ソケットへの接続](/voice/voice-api/guides/websockets#connecting-to-a-websocket)を参照

#### SIP - 接続先となる SIP エンドポイント

値 | 説明
-- | --
`uri` | 接続しているエンドポイントへの SIP URI (`sip:rebekka@sip.example.com` 形式)。
`headers` | 必要なデータを含む `key` => `value` の文字列ペア (例: `{ "location": "New York City", "occupation": "developer" }` )

#### VBC - 接続先となる Vonage ビジネスクラウド (VBC) の拡張機能

値 | 説明
-- | --
`extension` | コールの接続先となる VBC 拡張機能。

発話 (talk)
-------------

`talk` アクションにより、合成発話はカンバセーションに送信されます。

発話アクションのテキストはプレーンまたは [SSML](/voice/voice-api/guides/customizing-tts) を使ってフォーマットできます。SSML タグによりテキスト読み上げ合成機能に詳細な指示を出して、ピッチや発音を設定したり、複数言語でテキストを結合したりできます。SSML タグは XML ベースで、JSON 文字列のインラインとして送信されます。

発話アクションはデフォルトでは同期的です。ただし、 *bargeIn* を *true* に設定した場合、NCCO スタックで *入力* アクションをその後に設定する必要があります。
以下の NCCO の例では合成発話メッセージをカンバセーションやコールに送信する方法を示しています。

```tabbed_content
source: '/_examples/voice/guides/ncco-reference/talk'
```

次のオプションを使って *発話* アクションを操作できます。

| オプション | 説明 | 必須/任意 |
| -- | -- | -- |
| `text` | コールやカンバセーションでの合成メッセージを含む最大 1,500 文字の文字列 (SSML タグを除く)。`text` のカンマを 1 つ加えると、合成発話に短い間が挿入されます。もっと長い間を加えるには、SSML で `break` タグを使用する必要があります。[SSML](/voice/voice-api/guides/customizing-tts) タグを使用するには、`speak` エレメントでテキストを囲む必要があります。| 必須 |
| `bargeIn` | `true` に設定して、キーパッドのボタンが押されたときにこのアクションが終了するようにします。この機能を使うと、[自動音声応答 (IVR)](/voice/voice-api/guides/interactive-voice-response) メッセージ全体を聴かずにオプションを選択できるようになります。`bargeIn` を `true` に設定する場合、NCCO スタックの発話以外の次のアクションは **必ず** `input` アクションになります。デフォルト値は `false` です。  </br> `bargeIn` は `true` に一旦設定されると、`input` アクションが指示されるまで、`true` のままになります (`bargeIn: false` が次のアクションで設定される場合でも同様) | 任意 |
| `loop` | コールが閉じられる前に `text` が繰り返される回数。デフォルト値は「1」であり、「0」に設定すると無限にループします。| 任意 |
| `level` | 発話の再生用音量レベル。`-1` ～ `1` の間で設定でき、`0` がデフォルトです。| 任意 |
| `voiceName` | `text` の配信に使われる音声名。送信しているメッセージにふさわしい言語、性別、アクセントの voiceName を使用します。たとえば、デフォルト音声 `kimberly` はアメリカのアクセントがある英語 (en-US) を話す女性です。可能な値は[テキスト読み上げ機能ガイド](/voice/voice-api/guides/text-to-speech#voice-names)のリストを参照してください。| 任意 |

ストリーム (stream)
------------------

`stream` アクションを使うと、オーディオストリームをカンバセーションに送信できるようになります。

ストリームアクションはデフォルトでは同期的です。ただし、 *bargeIn* を *true* に設定した場合、NCCO スタックで *入力* アクションをその後に設定する必要があります。

以下の NCCO の例ではオーディオストリームをカンバセーションやコールに送信する方法を示しています。

```tabbed_content
source: '/_examples/voice/guides/ncco-reference/stream'
```

次のオプションを使って *ストリーム* アクションを操作できます。

オプション | 説明 | 必須/任意
-- | -- | --
`streamUrl` | MP3 または WAV (16-bit) のオーディオファイルをコールやカンバセーションにストリーミングする単一 URL を含む配列。| 必須
`level` | レンジ内のストリームのオーディオレベルを -1 ～ 1 に設定 (精度 0\.1)。デフォルト値は *0* 。| 任意
`bargeIn` | *true* に設定して、キーパッドのボタンが押されたときにこのアクションが終了するようにします。この機能を使うと、[自動音声応答 (IVR)](/voice/guides/interactive-voice-response) メッセージ全体を聴かずにオプションを選択できるようになります。複数のストリームアクションで `bargeIn` を `true` に設定する場合、NCCO スタックのストリーム以外の次のアクションは **必ず** `input` アクションになります。デフォルト値は `false` です。  </br> `bargeIn` は `true` に一旦設定されると、`input` アクションが指示されるまで、`true` のままになります (`bargeIn: false` が次のアクションで設定される場合でも同様) | 任意 |
| `loop` | コールが閉じられる前に `audio` が繰り返される回数。デフォルト値は `1` 。`0` に設定すると無限にループします。| 任意

参照オーディオストリームのファイル形式は MP3 または WAV のいずれかにします。ファイルの再生に問題がある場合は、[どのタイプの録音済みオーディオファイルを使用できますか?](https://help.nexmo.com/hc/en-us/articles/115007447567) の技術仕様に従ってエンコードしてください。

入力 (input)
--------------

`input` アクションを使うと、コール相手が入力した桁を収集できるようになります。このアクションは同期的です。Nexmo は入力を処理し、リクエストで設定した `eventUrl` Web フックエンドポイントに送信される[パラメーター](#input-return-parameters)に入力内容を含めて転送します。Web フックエンドポイントは既存 NCCO に置き換わり、ユーザーが入力した内容に応じてコールを操作する別の NCCO を返します。この機能を使って自動音声応答 (IVR) を作成でき、たとえば *4* が押されたら、営業部門にコールを転送する[接続](#connect)NCCO を返すようにできます。

次の NCCO の例では IVR エンドポイントの設定方法が示されています。

```json
[
  {
    "action": "talk",
    "text": "Please enter a digit"
  },
  {
    "action": "input",
    "eventUrl": ["https://example.com/ivr"]
  }
]
```

次の NCCO の例ではユーザーが `bargeIn` を使って `talk` を中断する方法が示されています。`input` アクションの後には **必ず** `bargeIn` プロパティを持つアクションが来るようにします (例:`talk` または `stream`)。

```json
[
  {
    "action": "talk",
    "text": "Please enter a digit",
    "bargeIn": true
  },
  {
    "action": "input",
    "eventUrl": ["https://example.com/ivr"]
  }
]
```

次のオプションを使って `input` アクションを操作できます。

オプション | 説明 | 必須/任意
-- | -- | --
`timeOut` | コール相手の行為の結果は最後のアクションの`timeOut` 秒後に `eventUrl` Web フックエンドポイントに送信されます。デフォルト値は *3* で、最大は 10 です。|任意
`maxDigits` |ユーザーが押すことができる桁数。最大値は `20` で、デフォルトは `4` 桁です。| 任意
`submitOnHash` | `true` に設定して、コール相手が *\#* を押した後に `eventUrl` にある Web フックエンドポイントにコール相手の行為が送信されるようにします。 *\#* が押されない場合、結果は `timeOut` 秒後に送信されます。デフォルト値は `false` であり、`timeOut` 秒後に Web フックエンドポイントに結果が送信されます。| 任意
`eventUrl` | Nexmo はコール相手が行為を `timeOut` 一時停止した後、または *\#* が押された後にそのコール相手が押した桁をこの URL に送信します。| 任意
`eventMethod` | `event_url` へのイベント情報の送信に使用される HTTP 方式。デフォルト値は `POST`。|任意

次の例では `eventUrl` に送信されるパラメーターが示されています。

```json
{
  "uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid": "bbbbbbbb-cccc-dddd-eeee-0123456789ab",
  "timed_out": true,
  "dtmf": "1234",
  "timestamp": "2020-01-01T14:00:00.000Z"
}
```

#### 入力戻りパラメーター

`eventUrl` に返される入力パラメーター:

名前 | 説明
-- | --
`uuid` | 入力を開始しているユーザーのコールレッグの固有 ID。
`conversation_uuid` | このカンバセーションに固有の ID。
`timed_out` | `timeOut` の値に基づき入力がタイムアウトした場合、`true` を返します。
`dtmf` | コール相手が入力する数字 (順番どおり)。

通知 (notify)
---------------

`notify` アクションを使ってカスタムペイロードをイベント URL に送信します。Web フックエンドポイントは、既存 NCCO に置き換わる別の NCCO を返すか、既存 NCCO を実行し続ける場合は空のペイロードを返す可能性があります。

```json
[
  {
    "action": "notify",
    "payload": {
      "foo": "bar"
    },
    "eventUrl": [
      "https://example.com/webhooks/event"
    ],
    "eventMethod": "POST"
  }
]
```

オプション | 説明 | 必須/任意
-- | -- | --
`payload` | イベント URL に送信される JSON 本文 | 必須
`eventUrl` | イベントの送信先となる URL。通知受領時に NCCO を返す場合、既存 NCCO に置き換わります | 必須
`eventMethod` | `payload` の `eventUrl` への送信時に使用される HTTP 方式| 任意

