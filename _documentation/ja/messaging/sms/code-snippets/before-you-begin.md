---
title:  始める前に
navigation_weight:  1

---


始める前に
=====

コードスニペットとは
----------

コードスニペットとは独自のアプリケーションで再使用できる短いコードです。
これらのコードは[サンプルレポジトリ](https://github.com/topics/nexmo-quickstart)から取得されます。

コードスニペットを使用し始める前に、以下の情報をよくお読みください。

準備
---

1. [Nexmo アカウントを作成](/account/guides/dashboard-management#create-and-configure-a-nexmo-account) - API キーとシークレットにアクセスしてリクエストを認証できるようにします。
2. [Nexmo 番号をレンタル](/numbers/guides/number-management#rent-a-virtual-number) - 着信 SMS を受信する場合必要です。
3. [REST クライアントライブラリをインストール](/tools) - 選択したプログラミング言語用のライブラリをインストールします。

Web フック
-------

着信 SMS や受信確認を受信するには、[Web フック](/concepts/guides/webhooks)の作成が必要になります。また、Nexmo が Web フックにパブリックインターネット経由でアクセスできるようにします。

開発中は [Ngrok](https://ngrok.com) を使ってローカルマシンで作成した Web フックと Nexmo の API とのアクセスを確立できます。Ngrok の詳しい設定および使用方法については、[ローカル開発での Ngrok の使用](/concepts/guides/testing-with-ngrok) を参照してください。

