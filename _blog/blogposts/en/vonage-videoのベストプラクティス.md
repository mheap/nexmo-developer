---
title: Vonage Videoのベストプラクティス
description: Vonage Video APIを活用した豊富な機能を備えるビデオアプリケーションの構築を開始する前に、Vonageが推奨するベストプラクティスを説明します。
thumbnail: /content/blog/vonage-videoのベストプラクティス/best-practices-videoapi_1200x627.png
author: simon-jones
published: true
published_at: 2021-05-24T08:19:19.710Z
updated_at: 2021-08-24T08:19:19.754Z
category: inspiration
tags:
  - video-api
  - ビデオapi
  - japanese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*本文は英語版からの翻訳となります。日本語版において意味または文言に相違があった場合、英語版が優先するものとします。*
https://learn.vonage.com/blog/2021/05/24/best-practices-to-get-started-with-the-vonage-video-api/

このドキュメントでは、Vonage Video APIを活用した豊富な機能を備えるビデオアプリケーションの構築を開始する前に、Vonageが推奨する注目すべきベストプラクティスについて説明しています。

[VonageのWebサイト](https://www.vonage.com/communications-apis/video/)で新規アカウントを設定してください。設定は無料で、また新規アカウント登録時に自動的に10ドル付与致します。

## 関連資料/サポートに関して

Vonage Video APIにおける開発者向けの詳細ドキュメントは、[Video API開発者サイト](https://tokbox.com/developer/)で公開されています。
このサイトでは、サンプルコードやリリースノートなどをはじめとして、基本的にあらゆる質問に対応しています。また、サイトには[「Video APIに関する質問と回答」](https://support.tokbox.com/hc/en-us)といった大変役立つセクションも用意されています。
今後とも皆様によりよい支援をご提供するため、是非メールにてフィードバックをいただけたら幸いです：video.api.support@vonage.com

## ビデオプラットフォーム

Vonage videoは、オーディオ/ビデオコミュニケーションにwebRTCを使用しており、Web、iOS、Android向けのクライアントライブラリ、サーバSDK、REST APIで構成されています。詳細についてはこちらをご覧ください。
https://tokbox.com/developer/guides/basics/#opentok-platform

主な用語：

* Video API には、ユーザー名やログインの概念がなく、アプリケーションで作成する必要があります。プラットフォームでは、認証にトークンを使用します。
* セッション：セッションとは、接続とストリームの論理グループを指します。同じセッション内の接続でメッセージを交換することができます。セッションは、参加者がお互いに交流できる「部屋」のようなものだと考えてください。セッションを再利用すると、トラブルシューティングが困難になり、実装の安全性が損なわれる可能性があるため、再利用しないでください。
* 接続：セッションに参加し、メッセージの送受信が可能なエンドポイントを指します。接続にはプレゼンスがあり、接続されていてメッセージを受信できる状態と、切断されている状態があります。
* ストリーム：2つの接続間のメディアストリームのことを言い、メディアを含む実際のバイトが交換されていることを意味します。
* パブリッシャー：ストリームをパブリッシュしているクライアント。
* サブスクライバー：ストリームを受信しているクライアント。

## 環境

ビデオアプリケーションを設計する際には、テスト用と本番用の2つの環境を用意することを検討してください。簡単なアイテムをテストするには、VonageのプレイグラウンドやOpenTokのコマンドラインを使うこともできます。

1. テスト用と本番用のプロジェクトキーを作成します
2. OpenTok CLIにリンクを貼ります - https://www.npmjs.com/package/opentok-cli
3. プレイグラウンドにリンクを貼ります - https://tokbox.com/developer/tools/playground_doc/

エンタープライズサーバをご利用のお客様は、新規に追加されたAPIキーはデフォルトでスタンダード環境を使用することに注意してください。APIキーの環境をスタンダードからエンタープライズに変更する必要がある場合は、アカウントポータルで変更してください。

エンタープライズJS SDKは以下で入手できます：
https://enterprise.opentok.com/v2/js/opentok.min.js

詳細は以下をご覧ください：
https://tokbox.com/developer/enterprise/content/enterprise-overview.html

### APIキー/シークレット、トークン、セッションID

APIキーとシークレット

* パブリックレポジトリに公開しないことで、秘密とプライベートを守ります。
* クライアントライブラリやコンパイルされたモバイルSDKにシークレットキーを保存しないでください。
* RESTコールにはHTTPSのみを使用してください。

セッションID

* 新規セッションごとに必ず新たなsessionIdを作成してください。
* セッションの品質スコアとデータはsessionIdによってインデックス化されます。sessionIdごとに複数の会話が存在する場合、Vonage Inspectorツールを用いてデバッグすることは困難になります。なぜなら、再利用されたsessionIdは、エンドユーザーが実際に体験した通話品質よりも低い品質スコアが報告される傾向あるからです。

トークン

* トークンを生成するサーバは、安全かつ認証されたエンドポイントの背後に設置されている必要があります
* 参加者ごとに必ず新しいトークンを生成してください。
* ークンを保存または再利用しないでください。
* デフォルトでは、トークンの有効期限は24時間となっており、接続時に確認されます。ユースケースやアプリケーションに応じて、有効期限を調整してください。
* （データパラメータを使用して）トークンにユーザー名や参加者を特定できる情報を追加することができますが、個人情報は決して使用しないでください。
* モデレーター、パブリッシャー、サブスクライバーなど、必要に応じてロールを設定してください。
* トークンの詳細情報は以下をご覧下さい。
  https://tokbox.com/developer/guides/create-token/

## メディアサーバとメディアモード

**中継**：このメディアモードはVonageメディアサーバを使用しません。中継モードを使用するかどうかは以下を確認してください：

* レコーディングが不要
* 1対１でサードパーティセッションのみ
* 参加者間でダイレクトメディアが望ましい
* エンドツーエンドのメディアの暗号化が必要

なお、中継モードでは、クライアント間でメディアが交換されるため、メディアの品質は管理されません。そのため、サブスクライバーのフレームレートや解像度の設定はできません。詳細は次をご覧ください。https://tokbox.com/developer/guides/scalable-video/

**転送**：このメディアモードはVonageメディアサーバを使用します。転送モードを使用するかどうかは以下を確認してください：

* 3人以上の参加者
* アーカイブが必要
* メディア品質コントロールが必要（オーディアフォールバックとビデオリカバリ）
* SIP相互接続が必要
* インタラクティブまたはライブストリーミングブロードキャストが必要

メディアモードの詳細は以下をご覧ください。
https://tokbox.com/developer/guides/create-session/

**オーディオフォールバック**：転送モードでは、ビデオ通話をサポートするには帯域幅が低すぎる場合、Vonage SDKは、自動的にオーディオオンリーモードにフォールバックします。ただし、この動作を無効にしたい場合は、getStats()メソッドを使用して、アップロード/ダウンロードの帯域幅、パケットロス、フレームレートなどのリアルタイム統計値を取得することで可能になります。この情報に基づいて品質を推定し、例えば、低品質のビデオを表示する代わりに、より高い帯域幅レベルでビデオをカットするなどの判断を下すことができます。

**getStatsメソッド：**上記のカスタムオーディオフォールバックを導入するほか、getStats()ポーリングを使用して接続品質に関する情報を取得し、ユーザーにリアルタイム情報を表示したり、トラブルシューティングの目的に活用したりすることができます。

次の例をご覧ください。https://github.com/nexmo-se/opentok-get-stats

**Vonage Inspectorツール**：Inspectorを用いて、セッション中のメディアパフォーマンス、並びにコールの最中に使用されたコーデック、モード（中継または転送）、イベント、および高機能を把握することができます。詳細は以下をご覧ください。
https://tokbox.com/developer/tools/inspector_doc/

## ブロードキャスト

**インタラクティブ**：このタイプのブロードキャストでは、クライアントが双方のストリームをサブスクライブすることにより、相互のインタラクションを可能にします。重要なのは、このタイプのブロードキャストは、最大3,000サブスクライバーまでしかサポートしておらず、それを超えるとエラーメッセージが出てしまいます。以下にこのブロードキャストを使用する際の留意点を紹介します：

\*サポートに問い合わせることでサイマルキャストが可能になります。詳細は以下をご覧ください。
https://support.tokbox.com/hc/en-us/articles/360029733831-TokBox-Scalable-Video-Simulcast-FAQ
サイマルキャストはデフォルトでは、全てのAPIキーでヒューリスティックに設定されています。つまり、サイマルキャストは3つ目の接続がコールに参加した後でのみ開始されることになります（1対1のコールによるサイマルキャストを回避するため）。ヒューリスティックに設定されている場合、最初の2つの接続ではサイマルキャストは使用されないことに注意してください。

* 最大5名のパブリッシャーに対応しています。ストリームが増加した場合、サブスクライバーの最大人数に影響を及ぼすことを念頭においてください。パブリッシャー数に基づくサブスクライバーの最大数を計算するには、パブリッシャー数を最大参加者（3,000）で割ってください。例えば、2名のパブリッシャーの場合1,500のサブスクライバーになります（3,000÷2）。
* 接続イベントの抑制に関しては以下をご覧ください。
  https://tokbox.com/developer/guides/broadcast/live-interactive-video/#suppressing-connection-events
* 詳細は以下のサイトにアクセスしてください。
  https://tokbox.com/developer/guides/broadcast/live-interactive-video/

**ライブストリーミング**：このタイプのブロードキャストでは、ストリームをサブスクライブできる3,000名以上のサブスクライバーに対応しています。ビデオのブロードキャストには、RTMP（リアルタイムメッセージングプロトコル）とHLS（HTTPライブストリーミング）の2つのタイプのプロトコルが使用できます。どちらを選択するにしても、エクスペリエンス品質を落とさないために、パブリッシャーを最大5名に制限してください。

### HLSとRTMPの比較

* RTMPは、RTMPデリバリプラットフォームによってサブスクライバー数が制限されているのに対して、HLSでは無制限にサポートしています。
* HLSの遅延が15-20秒なのに対して、Vonageプラットフォームを活用したRTMPの遅延は5秒です。これにはRTMPデリバリプラットフォームによる遅延は含まれていません。なぜなら、ビデオの処理方法による遅延もこれに加味されるためです。
* HLS再生機能は、全てのブラウザでサポートされているわけではありませんが、フロープレイヤーとして使用できるプラグインが用意されています。再生では、ビデオスクラブ（巻き戻し／早送り）で、ライブ配信を最初まで戻したり、現在のライブ配信に戻ったりすることができます。
* HLS/RTMPの最大継続時間は2時間に設定されています。2時間以上のブロードキャストは、最大継続時間のプロパティを変更してください（最大10時間）。
* HLS/RTMPストリームは、最後のクライアントがセッションから退出してから60秒後に自動停止します。

レイアウト、最大継続時間、ライブストリームの開始/終了方法などのライブストリーミングに関する詳細は、以下をご覧ください。
https://tokbox.com/developer/guides/broadcast/live-streaming/

## ユーザーインターフェース/エクスペリエンス

* 一般的に、[UIカスタマイゼーションドキュメント（Web、iOS、Android、Windows](https://tokbox.com/developer/guides/customize-ui/js/)）をご覧いただき、アプリケーションに関連するセクションを、お読みいただくことを推奨しています。
* **事前コールテスト**：ユーザーのデバイスや接続において、セッションに参加する前にネットワークやハードウェアのテストが必要な場合、事前コールテスト機能を追加してください。テストごとに新規のsessionIDを作成し、より正確な結果を得るために、最低30秒のテスト時間を設けることを忘れないでください。

  * [Vonage事前コールテストツール](https://tokbox.com/developer/tools/precall)を使用して、ユーザーがVideo APIの一般的な接続テストを行うことができます。
  * 自社の事前コールテストの仕組みと連携し、全てのテストデータを集約したい場合、以下を活用することができます：

    * [iOS/Android Githubサンプルs](https://github.com/opentok/opentok-network-test)
    * [Javascript Network Test Package](https://github.com/opentok/opentok-network-test-js)
  * また、Vonageのライブミーティングデモでデモの関連ソースコードを調べることにより、事前コールテストをアプリケーションに組み込む方法を確認することができます。
* ビデオストリームのパブリッシュ/サブスクライブ：Handlersを活用

  * Completion Handlersにより、ビデオAPIセッションの接続、パブリッシュ、サブスクライブ、あるいは信号の送信に関するフィードバックを得ることができます。詳細は以下をご覧ください。

    * [Javascript例外処理](https://tokbox.com/developer/guides/exception-handling/js/)
    * [iOS例外処理](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSessionDelegate.html)
    * [Android例外処理](https://tokbox.com/developer/sdks/android/reference/)
  * OTオブジェクトの例外イベントをリッスンすることもでき、例外イベントで説明されている、より一般的なエラーに対して例外イベントをスローします。
  * 接続が確立されると、通常オーディオとビデオをパブリッシュし、その他の参加者のストリームをサブスクライブします。UIでパブリッシャーとサブスクライバーを管理する場合、パブリッシャーとサブスクライバーのインスタンスのそれぞれのイベントを利用することができ、特定のイベントまたは例外が発生した場合、ユーザーに対して有益な情報を表示することができます。パブリッシャーとサブスクライバーの各種のイベントについては以下をご覧ください：

    * [パブリッシャーイベント（JS)](https://tokbox.com/developer/sdks/js/reference/Publisher.html#events)
    * [サブスクライバーイベント（JS)](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#events)
    * AndroidとiOSについては上記の「例外処理」をご覧ください
* **オーディオフォールバック**：Vonageのメディアサーバでは、常時ネットワークの状態をチェックしており、エンドユーザーの接続に関する問題を検知すると、パケットロスが15%を超える場合、ビデオを自動的に停止してオーディオのみで継続するとともに、これに関するイベントが送信されます（iOSの場合：[subscriberVideoDisabled:reason:](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoDisabled:reason)と[subscriberVideoEnabled:reason:](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoEnabled:reason)）。このようなイベントをUIに表示し、影響を受けるユーザーに対して、接続品質が低下したためにオーディオのみに切り替えたことを知らせることを推奨します。オーディオのみの切り替えのしきい値を構成することはできません。詳細は以下の例をご覧ください：
* [ビデオ無効の警告](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#event:videoDisableWarning)
* [ビデオ無効の理由](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoDisabled:reason:)
* [ビデオ有効の理由](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoEnabled:reason:)

オーディオフォールバックはデフォルトで有効になっていますが、audioFallbackEnabledパラメータで無効にすることができます。詳細は[こちら](https://tokbox.com/developer/sdks/js/reference/OT.html)。

* **セッションへの再接続**：参加者がネットワーク関連の問題で突然セッションから脱落した場合、セッションへの再接続を試みます。よりよいユーザーエクスペリエンスを実現するため、こうしたイベントを捕捉し、UIに正しく表示してセッションへの再接続を試みていることをユーザーに知らせることを推奨します。詳細は[こちら](https://tokbox.com/developer/guides/connect-session/js/#automatic_reconnection)をご覧ください。
* **アクティブスピーカー**：オーディオのみのセッションでは、オーディオレベルメーターを追加し、参加者が現在のアクティブスピーカーを把握できるように可視化することをお薦めします。また、ビデオでは、アクティブスピーカーの画面を拡大するように設定してみてください。UIの調整は定期的に送信されるaudioLevelUpdatedイベントを活用してください。詳細は以下をご覧ください。
  https://tokbox.com/developer/guides/customize-ui/js/ 
* **Loudness detector（音量検知**：音量検知機能により、ミュートされているユーザーが話そうとしていることを特定することができます。この場合、audioLevelが0に設定された状態で、[audioLevelUpdated](https://tokbox.com/developer/sdks/js/reference/AudioLevelUpdatedEvent.html)イベントが発生します。つまり、この状況を避けるにはAudioContextの使用が必要になります。参考までに[ブログ](https://vonagedev.medium.com/how-to-create-a-loudness-detector-using-vonage-video-api-8dbcf93595a8)をご覧ください。
* **Issue API(イシューAPI）のレポート**：https://tokbox.com/developer/guides/debugging/js/#report-issue。
これにより、アプリケーションのエンドユーザーは、クライアントサイドより個々のイシュー（問題）IDを生成することができます。顧客はイシューIDを保存し、サポートのチケットを発行する際に使用することができます。イシューIDは、問題が報告された個々の接続IDを特定し、サポート部門による調査に役立てることができます。

## 機能

* **チャット（テキストメッセージジング**：Vonageのシグナリング[https://tokbox.com/developer/sdks/js/reference/Session.html](<* https://tokbox.com/developer/sdks/js/reference/Session.html>) #signalを使用してメッセージを送信することができますが、メッセージはVonageのビデオプラットフォームに保存されるわけではありません。テキストメッセージング機能を追加する場合、テキストメッセージが送信された後にセッションに参加するユーザーがいることもあり、そのユーザーはメッセージを閲覧できないことを念頭においてください。また、セッションをレコーディングする場合、テキストメッセージは保存されません。この問題を解決するために、NexmoクライアントSDKの使用をお薦めします（このドキュメントの最後に掲載されているサンプルコード、Nexmoアプリ内メッセージングをご覧ください）。
* **アーカイブ**：レコーディングでは、Composed（まとめてレコーディング）とストリーム別のレコーディングといった2つのタイプのサービスがあります。以下にその違いと留意事項を紹介します

  * Composed（まとめてレコーディング）

    * 最大16ストリームまでレコーディングできますが、オーディオのみのストリームの場合、最大50までレコーディング可能
    * 全てのメディアストリームを含むシングルMP4ファイル
    * カスタマイズ可能なレイアウト：<https://tokbox.com/developer/guides/archiving/layout-control.html>　
    * 自動で開始可能（最大240分。レコーディングが停止されない場合、新規ファイルにアーカイブを開始）
    * 異なるレイアウトクラスを割り当てることにより、レコーディングに特定のストリームを優先して含めることが可能。例えば、画面共有ストリームを優先する：<https://tokbox.com/developer/guides/archive-broadcast-layout/#stream-prioritization-rules>
  * Individual Stream

    * ストリーム別
    * 最大50ストリームまでレコーディング
    * 複数の個別ストリーム/ファイルをZIPフォルダに保存
    * 事後処理ツールでカスタマイズされたコンテンツを作成
    * 自動的に開始することは不可
* **アーカイブの保存：**Vonageでは、アップデートが失敗した場合、クラウドストレージが構成されていない場合、あるいはストレージフォールバックの無効化オプションが選択されていない場合、アーカイブのコピーを72時間保管します。アップロードフォールバックを有効にせずにアップロードが失敗した場合、アーカイブは復元できませんので注意してください

  * AWS S3：AWSにアーカイブファイルをアップロードする方法については以下をご覧ください。
  * Azure：Azureにアーカイブファイルをアップロードする方法については以下をご覧ください。

  <https://tokbox.com/developer/guides/archiving/using-azure.html>

### アーカイブに関するFAQ：

* アーカイブは暗号化されていますか？

  * いいえ。ただしアーカイブに暗号化機能を追加することができます。詳細は以下をご覧ください。
    https://tokbox.com/developer/guides/archiving/opentok-encryption.html
* オーディオもしくはビデオのみレコーディングできますか？

  * はい。RESTを使用してhasVideo/hasAudioでtrueかfalseを設定してください：
    https://tokbox.com/developer/rest/#start_archive
* 識別するためにアーカイブに名前をつけることはできますか？

  * はい。RESTを使用して任意の識別子<String>に名前を設定します：
    https://tokbox.com/developer/rest/#start_archive
* アーカイブのステータスをどのようにチェックできますか？

  * アーカイブインスペクターを使用します。Vonageのサポートエンジニアが書いた有益な記事を参考にしてください：
    https://support.tokbox.com/hc/en-us/articles/360029733871-Archiving-FAQ
* セッションの特定のストリームのみレコーディングできますか？

  * いいえ。全てのストリームがレコーディングされ、一部のストリームを選択してアーカイブすることはできません。

アーカイブにSafariブラウザを使用する際の重要な注意点：*Safariクライアントからパブリッシュされたストリームのビデオの場合、*[Safari OpenTokプロジェクト](https://tokbox.com/developer/sdks/js/safari/)*を使用する必要があります。さもないとSafariからパブリッシュされたストリームはオーディオのみになります*。

* **画面共有**：ミラー効果を回避するため、画面を共有しているパブリッシャーを隠します。

  * ContentHint：モーション、ディテールなど：このフラグは、2.20以降に設定可能であり、設定するべきです。

## 品質、パフォーマンス、互換性

* **デバイス**：複数パーティのセッションでは、参加者が多ければ多いほど必要な処理能力が高まるため、できるだけ参加者数を制限してください。

Vonageが推奨する参加者人数：

* モバイル=4（エンジニアリングの公式発表では最大8までサポート）
* ラップトップ=10
* デスクトップ=15
* **帯域幅要件**に関しては[「OpenTokの使用時における最低限の帯域幅要件とは？」](https://support.tokbox.com/hc/en-us/articles/360029732311-What-is-the-minimum-bandwidth-requirement-to-use-OpenTok-)をご覧ください。
* **プロキシ**：ユーザーがプロキシ経由でしかインターネットにアクセスできない場合、webRTCは認証を要求するプロキシではあまりよく機能しないため、「透過的な」プロキシを使用するか、ブラウザでHTTPS接続を構成する必要があります。Vonageのネットワークチェックフローについては以下をご覧ください。
  https://tokbox.com/developer/guides/restricted-networks/
* **ファイアウォール**：最低限ファイアウォールのルールに含める必要があるポートやドメイン：

  * TCP 443
  * FQDN: tokbox.com
  * FQDN: opentok.com
  * STUN/TURN: 3478

可能でしたらUDP 1025 – 65535のレンジの使用を試してください。このレンジでは、ユーザーに最大限のエクスペリエンスを提供するポートレンジをカバーしています。また、これによりTURNの必要性もなくなり、このようなネットワーク要素を介してメディアを中継しなければ、レイテンシが減少します。

* **コーデック**：コーデックの互換性については以下をご覧ください。https://tokbox.com/developer/guides/codecs/
  VonageはVP9、VP8、H.264コーデックをサポートしていますが、VP9は、全ての参加者がChromeを使用しているセッションの中継メディアモードでのみ有効です。

VP8とH.264の違い：

* VP8はソフトウェアコーデックであり、成熟度が高く、より低いビットレートを扱うことができます。

さらに、スケーラブル/サイマルキャストビデオをサポートしています。

* H.264はデバイスによってソフトウェアまたはハードウェアで利用することができますが、スケーラブルビデオやサイマルキャストはサポートしていません。

コーデックはデフォルトでVP8に設定されています。特定のプロジェクトキーに対して、割り当てられたコーデックを変更する必要がある場合、ポータルにログインして変更してください。

## セッションモニタリング

* Vonageの開発者向けページをご覧ください。
  https://tokbox.com/developer/guides/session-monitoring/
* セッションモニタリングにより、WebフックURLを登録することができます。
* この機能を使用してセッションとストリームをモニタリングすることができます。例えば、セッションの参加人数を制限することができ、通常JSのforceDisconnect機能とともに使用します：
  https://tokbox.com/developer/guides/moderation/js/#force_disconnect
  また、モデレーターがサーバにアクションを呼び出し、強制的に接続を切るためのRESTコールを実行させることもできます：https://tokbox.com/developer/guides/moderation/rest/
* 利用状況の追跡に使用することができます。より優れた利用状況の追跡には、高度なインサイトを活用することができます：
  https://tokbox.com/developer/guides/insights/#obtaining-session-data-advanced-insights-

## アドオン

企業顧客は簡単にアドオンを購入できるようになりました。[本プレゼンテーション](https://docs.google.com/presentation/d/16Q9XRznFLs5rl2DZFYt5Nwl1ibKj_j_y-9XQZ5C3VSc/edit#slide=id.gafa078777f_0_18)のスライドでは、セルフサービスツールで構成できるアドオンリストが掲載されていますので参考にしてください。

* SIPの相互接続

  * 使用方法：https://tokbox.com/developer/guides/sip/　
  * SIPの相互接続により、電話のダイヤルインを構築する方法：
    https://learn.vonage.com/blog/2019/04/23/connecting-webrtc-and-pstn-with-opentok-and-nexmo-dr
* 構成可能なTURN

  * 使用方法：https://tokbox.com/developer/guides/configurable-turn-servers/　
* IPプロキシ

  * 使用方法：https://tokbox.com/developer/guides/ip-proxy/　
  * AWSでのホスティング方法：https://support.tokbox.com/hc/en-us/articles/360046878351-How-to-install-and-configure-a-test-Proxy-Server-in-AWS
* リージョナルメディアゾーン

  * データシート：https://tokbox.com/pdf/datasheet-regional_media_zones.pdf　
* 中国中継

  * 解説：https://support.tokbox.com/hc/en-us/articles/360029413612-What-is-China-Relay-　
  * 仕組み：https://support.tokbox.com/hc/en-us/articles/360029732451-How-does-China-relay-work-　
  * 必要性：https://support.tokbox.com/hc/en-us/articles/360029411992-Why-is-China-relay-necessary-
* IPホワイトリスト

  * <https://support.tokbox.com/hc/en-us/articles/360029732031-Can-I-get-a-list-of-the-IP-ranges-of-TokBox-servers->
* AES-256暗号化

## セキュリティとプライバシー

Vonage Video APIは、最高レベルのセキュリティ基準を遵守するようにカスタマイズすることができます。VonageのプラットフォームはGDPRを遵守しており、HIPAAにも準拠しています。ヨーロッパの顧客に対しては拡張アドオンを提供しており、KBV認定（ドイツ）や安全なデータの所有と保護を目的としたその他のプライバシー法（欧州全域）など、ローカルの認証やスタンダードを遵守できるようにしています。

GDPRの詳細はこちら：https://www.vonage.com/communications-apis/platform/gdpr/

Vonageのプライバシーポリシーはこちら：https://www.vonage.com/legal/privacy-policy/　

Vonageのサブプロセッサの全リストはこちら：
https://www.vonage.com/communications-apis/platform/gdpr/sub-processors/　

さらに、データ処理に関する補遺（DPA）はGDPRのページで確認し、自己署名を行うことができます。

NDAの締結を元に、SOC2などのレポートや、Vonageのビデオプラットフォームが満たしている高度なセキュリティ基準を証明する、第三者機関によるペネトレーションテストを提供することができます。

## サンプルコードへのリンク：

* 事前コールテスト

  * Vonage事前コールテストサイト：https://tokbox.com/developer/tools/precall/
  * Gitレポジトリ：

    * iOSとAndroid：https://github.com/opentok/opentok-network-test
    * Javascript: <https://github.com/opentok/opentok-network-test-js>
* セッションモニタリング

  * コールキューイング：https://github.com/opentok/opentok-video-call-center
* Vonageテキストチャット：https://github.com/opentok/accelerator-textchat-js、 https://github.com/nexmo-community/stream-video-with-textchat　
* Vonageアプリ内メッセージング：https://github.com/nexmo-community/video-messaging-app　
* インタラクティブ/ライブストリーミングブロードキャスト：https://github.com/opentok/broadcast-sample-app/
* 個々のストリームアーカイブを処理するための後処理ツールのサンプルコード：
  https://github.com/opentok/archiving-composer
* eラーニングのチュートリアル/試験サンプル：
  https://github.com/opentok/opentok-elearning-samples 
* 高度なインサイトのダッシュボードサンプル：
  https://github.com/opentok/insights-dashboard-sample　

## 月間使用量の算出/Video APIの段階的な価格設定

* [OpenTokの月間使用量の見積り方法](https://support.tokbox.com/hc/en-us/articles/360029732691-How-do-I-estimate-my-OpenTok-monthly-usage-)
* [Video APIの価格設定](https://www.vonage.com/communications-apis/video/pricing/?icmp=l3nav_pricing_novalue)
