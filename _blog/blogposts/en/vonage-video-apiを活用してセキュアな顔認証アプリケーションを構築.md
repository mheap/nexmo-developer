---
title: Vonage Video APIを活用してセキュアな顔認証アプリケーションを構築
description: このチュートリアルでは、Vonage Video
  APIを活用してセキュアな顔認証アプリケーションを構築し、カスタムソリューションのビルドに属性をパーソナライズし、ワークフローを学習します。
thumbnail: /content/blog/vonage-video-apiを活用してセキュアな顔認証アプリケーションを構築/blog_facial-id-application_1200x600-1.png
author: akshita-arun
published: true
published_at: 2020-10-21T13:58:09.402Z
updated_at: 2021-08-25T13:35:10.682Z
category: tutorial
tags:
  - video-api
  - フェイシャル-id
  - japanese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*本文は英語版からの翻訳となります。日本語版において意味または文言に相違があった場合、英語版が優先するものとします。
https://learn.vonage.com/blog/2020/10/21/build-a-secure-facial-id-application-using-the-vonage-video-api/*

現在の世界的なパンデミックの中で、多くの産業分野では生産性を向上させ、効果的な実装技術を提供するために、デジタルの導入に注力し、顧客の広範なユースケースに対応しています。顔認証はより一般的になり、以下のような産業分野で技術が広く普及しています：

1. ホスピタリティ（航空やホテル）

* ホテルのチェックイン時に、携帯電話やカメラを使って支払いを行う
* フライトのチェックインと搭乗手続き

2. 遠隔医療

* 手作業での書類作成を最小限にするために、緊急サービスが必要な患者を識別する
* 病院管理サービスでは、医師、患者、看護師の顔をスクリーニングすることで、ミスコミュニケーションを防ぎ、一貫した情報を提供している

3. カスタマーサービス

* ユーザー認証
* 詐欺防止

4. 有権者登録

* 有権者の不正行為への対応

上記のすべてのユースケースにおいて、[Vonage Video API](https://tokbox.com/account/user/signup)を活用することで顔認証を可能にし、非接触型サービスを推進すると同時に、ユーザーデータや個人情報を保護しつつ、安全で安心なカスタムソリューションの提供を支援します。

このブログ記事では、顔面認証を使用したVideo APIをご紹介します。開発者は、いくつかの手法や関数を利用するだけで、カスタムソリューションのビルドにこれらの属性をパーソナライズし、顔認証の登録、検出、識別、照合を含むワークフローを理解することができます。私たちの目標は、[opentokプラットフォーム](https://gist.github.com/rktalusani/3b0bb3c61bc6d5b6020612f189e644fe)を使用した顔認証をすぐに使用できるサンプルコードベースを使用して開発時間を短縮することです。

## 概念

Video APIを使用して優れた顔認証アプリケーションを構築するために、サンプルコードスニペットに記載されているメソッドとオブジェクトを使用します。詳細は、Microsoft face APIと連携している[opentokのリファレンスコード](https://gist.github.com/rktalusani/3b0bb3c61bc6d5b6020612f189e644fe)をご覧ください。

## テクノロジーと前提条件

* Opentok JS API
* Microsoft face API
* [Vonage Video APIアカウント](https://tokbox.com/account/?utm_source=blog&utm_medium=blog&utm_campaign=JP+Translated+Posts&utm_id=JP_translated_post#/)

## サブスクライバー画像のスクリーンショットをサーバにアップロード

前述の適正なユースケースでは、顧客はサインアッププロセス中に自分の写真を提供し、その後写真はバックエンドに保存されます。顧客がビデオ通話に参加すると、Vonage Video APIを使用して顧客のビデオストリームのスクリーンショットを取得し、サーバにアップロードして顔の検出を行います。

以下のコードでは、`subscriber.getImgData()`を使ってビデオストリームの画面を取得し、バックエンドにアップロードしています。

```js
function sendScreenShot() {
    var imgdata = undefined;
    if (subscriber) {
        imgdata = subscriber.getImgData();
    }
    if (imgdata != undefined) {
        try {
            var blob = this.b64toBlob(imgdata, "image/png");
            let formData = new FormData();
            formData.append('customer', blob);
            let res = await $HTTPDEMO.post('/faceIDDemo.php',
                formData, {
                    headers: {
                        'Content-Type': 'multipart/form-data'
                    }

                }
            );
            console.log(res.data);
            if (res.data.status != "success") {
                alert("Error uploading the file");
            } else {

            }
        } catch (error) {
            alert("error posting screenshot");
            console.log(error);
        }
    }
}
```

![step 1](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/step-1-upload-an-image.png "step 1")

b64toBlobは、sendScreenShot関数から呼び出されるヘルパーメソッドで、base64文字列をバイト配列に変換し、multipart/form-dataとしてサーバに投稿できるようにします。

```js
function b64toBlob(b64Data, contentType, sliceSize) {
    contentType = contentType || '';
    sliceSize = sliceSize || 512;
    var byteCharacters = atob(b64Data);
    var byteArrays = [];
    for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }
    var blob = new Blob(byteArrays, {
        type: contentType
    });
    return blob;
}
```

## Microsoft APIを使用してFaceIDを識別し、照合結果を比較

![Identifying FaceID Using Microsoft API To Compare Matched Face ID Results ](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/identify.png "Identifying FaceID Using Microsoft API To Compare Matched Face ID Results ")

## OpenTokでFaceIDを検出

detectFaceメソッドは、サーバ側で実行されます。このメソッドは、与えられた画像から顔の特徴を検出して、識別子を返します。このメソッドは、サインアップ時にお客様の画像がアップロードされたとき（id1）と、ビデオストリームのスクリーンショットがアップロードされたとき（id2）の2回、呼び出されます。

以下はコードスニペットのサンプルになります：

```js
function detectFace($img){
        global $faceid_endpoint, $data_dir_url,$faceid_key;

        $client = new GuzzleHttp\Client([
            'base_uri' => $faceid_endpoint
        ]);

        $resp = $client->request('POST', 'face/v1.0/detect?recognitionModel=recognition_02&detectionModel=detection_02', [
            'headers' => [
                'Content-Type' => 'application/json',
                'Ocp-Apim-Subscription-Key' => $faceid_key
            ],
            'json' => ['url'=> $data_dir_url.$img]
        ]);

        $json = json_decode($resp->getBody(),true);
       
        return $json[0];
}
```

![Detecting FaceID in Opentok](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/3.png "Detecting FaceID in Opentok")

## OpenTokでFaceIDを認証

最後の認証では、verifyFace()メソッドを使用し、インプットとして画像IDのid1とid2を渡します。Microsoft face APIは、この2つの顔(id1 & id2)を比較し、登録時に提出された写真とスナップショットを比較して、一致/不一致とスコアを含む結果を提供します。

```js
function verifyFace($id1,$id2){
        global $faceid_endpoint, $data_dir_url,$faceid_key;
        $client = new GuzzleHttp\Client([
            'base_uri' => $faceid_endpoint
        ]);

        $resp = $client->request('POST', 'face/v1.0/verify', [
            'headers' => [
                'Content-Type' => 'application/json',
                'Ocp-Apim-Subscription-Key' => $faceid_key
            ],
            'json' => [
                'faceid1'=>$id1,
                'faceid2'=>$id2
            ]
        ]);

        return $resp->getBody();
}
```

![Verifying FaceID in OpenTok](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/4.png "Verifying FaceID in OpenTok")

### 背景

Vonage APIのカスタマーソリューションチームの主な目的は、開発、統合、およびサポートサービスを拡張することにより、Vonageの開発者がイノベーションの壁を越えられるようにすることです。私たちは、お客様のグローバルでの成長率を加速させることで、収益性の高い顧客中心の企業になることを目指し、持続可能なビジネスを実現するという共通の目標を持つグローバルリーダーと協業しています。

Vonageが提供する高速化サービスの一環として、アプリケーションの最適化、スケールアップ、そして市場への早期参入を支援する実装、導入、採用をガイドすることで、開発期間を最小限に抑えることができます。

## 結論

Vonageでは、顧客の利益を第一に考えたコアバリューを重視しています。絶え間ないイノベーションの努力により、私たちは開発者コミュニティに最新かつ最高の機能を提供することをお約束します。これにより、お客様のユースケースのシナリオに最適なアプリケーションをカスタマイズすることができます。

Vonageを活用したビデオの利用は増加の一途にあり、ビデオに対する需要の増加に伴い、パートナーとの連携を成功させるために、より良い支援とサービスの提供を実現する高品質のリソースを配置することに集中しています。Vonage Video APIは簡単に始めることができますので、[無料アカウントにサインアップ](https://tokbox.com/account/?utm_source=blog&utm_medium=blog&utm_campaign=JP+Translated+Posts&utm_id=JP_translated_post#/)して、今すぐVonageが提供するサービスを最大限に活用してください。

諸機能や開発者向けドキュメント、ブログ記事の内容について、皆様からのフィードバックをお待ちしています。下記のコメント欄にご記入いただくか、[Twitter](https://twitter.com/VonageDev)でお問い合わせいただくか、[コミュニティSlackチャネル](https://developer.nexmo.com/community/slack)にご参加ください。
