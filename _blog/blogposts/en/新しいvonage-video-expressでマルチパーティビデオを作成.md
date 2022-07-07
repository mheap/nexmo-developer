---
title: 新しいVonage Video Expressでマルチパーティビデオを作成
description: このガイドに従って、Vonage Video API セッションを 1 対 1
  からマルチパーティビデオに移行する際のプラットフォームの制限とベストプラクティスを学んでください。
thumbnail: /content/blog/create-a-multiparty-video-app-with-the-new-video-express/react-native_video-express_1200x600.png
author: enrico-portolan
published: true
published_at: 2021-09-27T12:34:21.375Z
updated_at: 2022-03-01T09:10:50.223Z
category: tutorial
tags:
  - video-express
  - video-api
  - japanese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*この記事は[Javier Molina Sanz](https://learn.vonage.com/authors/javier-molina-sanz/)との共同執筆によるものです*

このブログ記事は、ReactJSと新しいVonage Video Expressを活用して、マルチパーティビデオアプリケーションを開発する上で役立ちます。Video Express は、デフォルトで以下の機能を提供します：

* **ルームマネージャと参加者マネージャ**: シンプル化されたパブリッシュ、サブスクライブおよびストリーム管理ロジック
* **レイアウト管理**: カスタマイズ可能なコンポーネントを備えたレスポンシブUIとレイアウトマネージャを標準装備
* **ビデオ品質の最適化**: 参加者数、レンダリングサイズ、CPU、ネットワーク状況に応じたフレームレートや解像度
* **ネットワークの最適化**: 見えない参加者や話さない参加者の映像や音声を自動的に削除し、帯域幅のリソースを最適化
* **優れた操作性**: パブリッシュ、サブスクライブ、ストリームをルームと参加者にリプレースすることで、より自然なインタラクションを提供

> このチュートリアルの全てのソースコードは[GitHub](https://github.com/nexmo-se/video-express-react-app)に掲載されています。

## アプリのアーキテクチャ

アプリは大きく分けて、サーバサイドとクライアントサイドの2つのセクションに分かれます。サーバサイドは、クレデンシャルの生成とアーカイブ管理を担当するシンプルなNodeJSサーバであり、クライアントサイドは、React Hooksを使用したReact SPA（シングルページアプリケーション） です。

クライアントサイドで実際のアクションが発生し、Video Expressを使用することで、レスポンシブかつ拡張性に優れ、最適化されたマルチパーティビデオ会議アプリを実装することができました。

## Client

Reactアプリケーションは、NPM経由でReactアプリケーションは、NPM経由で@ [@vonage/video-express](https://www.npmjs.com/package/@vonage/video-express)モジュールを活用しています。また、HTMLのスクリプトタグにより、Video Expressも使用できることを覚えておいてください。詳細は[Video Express Documentationドキュメント](https://tokbox.com/developer/video-express/)をご覧ください。

このアプリは、React 16.8に付属するReact Hooksをベースにしています。次に、このアプリケーションの主なフックについて詳しく見ていきましょう

### UseRoom

[UseRoom](https://github.com/nexmo-se/video-express-react-app/blob/main/src/hooks/useRoom.js)フックは、ビデオルームのライフサイクルを扱うフックです。Video Expressを活用することにより、セッション、パブリッシャー、サブスクライバーのライフサイクルを管理する必要がありません。代わりに、 [Room](https://tokbox.com/developer/video-express/reference/room.html)オブジェクトをインスタンス化し、`room.join()`メソッドを使用するだけで、裏側ですべてを処理してくれます。

まず、Roomオブジェクトを初期化し、コールに参加するための関数を作成する必要があります。認証情報 (`apiKey`、`sessionId`、`token`) と、`userName`などパブリッシャーの設定に用いるパラメータや、Roomを表示するコンテナ、およびその他のパブリッシャーの設定が必要になります。


Video Express が提供するデフォルトのレイアウトマネージャを使用するため、いくつかのレイアウトパラメータを設定します：初期レイアウトにグリッドビューを設定し、スクリーン共有ビューにおけるカスタム HTML 要素を定義します。パラメータの一覧は[こちら](https://tokbox.com/developer/video-express/reference/room.html#constructor-options)をご覧ください。


```js
const createCall = useCallback(
    (
      { apikey, sessionId, token },
      roomContainer,
      userName,
      publisherOptions
    ) => {
      if (!apikey || !sessionId || !token) {
        throw new Error('Check your credentials');
      }

      roomRef.current = new MP.Room({
        apiKey: apikey,
        sessionId: sessionId,
        token: token,
        roomContainer: 'roomContainer',
        participantName: userName,
        managedLayoutOptions: {
          layoutMode: 'grid',
          screenPublisherContainer: 'screenSharingContainer'
        }
      })
       startRoomListeners();

       roomRef.current
        .join({ publisherProperties: finalPublisherOptions })
        .then(() => {
          setConnected(true);
          setCamera(roomRef.current.camera);
          setScreen(roomRef.current.screen);
          addLocalParticipant({ room: roomRef.current });
        })
        .catch(e => console.log(e));
    },
    [ ]
  );
```

`Room`オブジェクトが初期化されたら、`startRoomListeners` 関数を呼び出して、Roomオブジェクトのイベントリスナーを開始します。次に、オプションの`publisherSettings`とともに`room.join()`メソッドを呼び出し、セッションに参加させます。イベントリスナーは、新しい参加者の参加、新しい画面共有ストリームの作成、あるいはユーザーによる通話の再接続などのイベントを通知するために必要となります。

```js

const startRoomListeners = () => {
    if (roomRef.current) {
      roomRef.current.on('connected', () => {
        console.log('Room: connected');
      });
      roomRef.current.on('disconnected', () => {
        setNetworkStatus('disconnected');
        console.log('Room: disconnected');
      });
      roomRef.current.camera.on('created', () => {
        setCameraPublishing(true);
        console.log('camera publishing now');
      });
      roomRef.current.on('reconnected', () => {
        setNetworkStatus('reconnected');
        console.log('Room: reconnected');
      });
      roomRef.current.on('reconnecting', () => {
        setNetworkStatus('reconnecting');
        console.log('Room: reconnecting');
      });
      roomRef.current.on('participantJoined', participant => {
        console.log(participant);
        addParticipants({ participant: participant });
        console.log('Room: participant joined: ', participant);
      });
      roomRef.current.on('participantLeft', (participant, reason) => {
        removeParticipants({ participant: participant });
        console.log('Room: participant left', participant, reason);
      });
    }
  };
```

参加者のリストを表示できるように、セッションの参加者も記録していることに注意してください。参加者が入室または退室すると更新されるステート変数を作成します。

また、大変役立つ機能としてネットワークステータスのコンポーネントも実装されています。この機能は、ユーザーの切断や再接続時にUIを更新し、ネットワークに関する問題をユーザーに知らせます

### UseDevices

現在では、複数のオーディオ／ビデオデバイスを利用することが一般的になっています。イヤホンを使いたいユーザーもいれば、外付けのWebカメラをコンピューターに接続したいユーザーもいます。ビデオアプリケーションでは、ユーザーがさまざまなデバイスから選択できるようにすることが重要です。[useDevices](https://github.com/nexmo-se/video-express-react-app/blob/main/src/hooks/useDevices.js) フックは、利用可能なデバイスの一覧を取得する方法を説明します。



```js
  useEffect(() => {
    navigator.mediaDevices.addEventListener('devicechange', getDevices);
    getDevices();

    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', getDevices);
    };
  }, [getDevices]);
```

メディアデバイスの変更を検知するイベントリスナーを設定しました。変更が発生したときに、`getDevices()`関数をトリガーします。


```js
const getDevices = useCallback(async () => {
    if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
      console.log('enumerateDevices() not supported.');
      return;
    }
    try {
      const devices = await MP.getDevices();
      const audioInputDevices = devices.filter(
        (d) => d.kind.toLowerCase() === 'audioinput'
      );
      const audioOutputDevices = devices.filter(
        (d) => d.kind.toLowerCase() === 'audiooutput'
      );
      const videoInputDevices = devices.filter(
        (d) => d.kind.toLowerCase() === 'videoinput'
      );
      setDeviceInfo({
        audioInputDevices,
        videoInputDevices,
        audioOutputDevices
      });
      // });
    } catch (err) {
      console.log('[loadDevices] - ', err);
    }
  }, []);
```

`getDevices()`関数は、[MP.geDevices()](https://tokbox.com/developer/video-express/reference/get-devices.html)メソッドを呼び出し、ユーザーがデバイスへのアクセスを許可した際に、利用可能なデバイスのリストを返します。次に、デバイスをフィルタリングして、利用可能なさまざまなデバイスをステートに追加します。

```js
const [deviceInfo, setDeviceInfo] = useState({
    audioInputDevices: [],
    videoInputDevices: [],
    audioOutputDevices: []
  });
```

### UsePreviewPublisher

Video Expressは、通話前のユーザーエクスペリエンスも支援しており、具体的には[PreviewPublisher](https://tokbox.com/developer/video-express/reference/preview-publisher.html) クラスを実装しています。`PreviewPublisher`クラスの目的は、開発者がメディアを容易にプレビューし、`Room`オブジェクトを作成しなくてもデバイス（オーディオ/ビデオ）が正常に動作することを確認できるようにすることです。

ユーザーが正しいデバイスを選択し（複数ある場合）、マイクが音声を拾い、カメラが正常に動作することを確認するためのプレビューを作成します。[GitHub](https://github.com/nexmo-se/video-express-react-app/blob/main/src/hooks/usePreviewPublisher.js)で全般的な実装内容を確認してください。

まず、UseDevicesフックから利用可能なデバイスを取得します。

```js
const { deviceInfo, getDevices } = useDevices();
```


プレビューパブリッシャーとターゲット要素を初期化した後、`previewMedia`メソッドを呼び出してメディアを可視化します。また、デバイスアクセスや`audioLevel`イベントを処理するために、いくつかのイベントリスナーを設定します。ご覧の通り、(`accessAllowed`イベントで)ユーザーがデバイスへのアクセスを許可するまで`getDevices`()関数を呼び出さないようにします。

```js
const createPreview = useCallback(
    async (targetEl, publisherOptions) => {
      try {
        const publisherProperties = Object.assign({}, publisherOptions);
        console.log('[createPreview]', publisherProperties);
        previewPublisher.current = new MP.PreviewPublisher(targetEl);
        previewPublisher.current.on('audioLevelUpdated', (audioLevel) => {
          calculateAudioLevel(audioLevel);
        });
        previewPublisher.current.on('accessAllowed', (audioLevel) => {
          console.log('[createPreview] - accessAllowed');
          setAccessAllowed(DEVICE_ACCESS_STATUS.ACCEPTED);
          getDevices();
        });
        previewPublisher.current.on('accessDenied', (audioLevel) => {
          console.log('[createPreview] - accessDenied');
          setAccessAllowed(DEVICE_ACCESS_STATUS.REJECTED);
        });
        await previewPublisher.current.previewMedia({
          targetElement: targetEl,
          publisherProperties
        });

        setPreviewMediaCreated(true);
        console.log(
          '[Preview Created] - ',
          previewPublisher.current.getVideoDevice()
        );
      } catch (err) {
        console.log('[createPreview]', err);
      }
    },
    [calculateAudioLevel, getDevices]
  );
```

ユーザーがデバイスへのアクセスを許可したかどうかを知るために、SDKからのいくつかのイベントをサブスクライブし、UIを更新することで、マイクが音声を拾っていることをユーザーに知らせるために、オーディオレベルイベントをサブスクライブします。また、オーディオ／ビデオデバイスへのアクセスが拒否された場合は、ユーザーにアラートを表示するようにします（[実装](https://github.com/nexmo-se/video-express-react-app/tree/main/src/components/DeviceAccessAlert)を参照)。

### Waiting Room

このアプリケーションで最も重要なコンポーネントの一つが[WaitingRoom](https://github.com/nexmo-se/video-express-react-app/tree/main/src/components/WaitingRoom)コンポーネントであり、ここで`useDevices`と`usePreviewPublisher`フックを使用します。ウェイティングルームは通話前のページであり、ユーザーは正しいオーディオ／ビデオデバイスを選択し、マイクとカメラが動作するかどうかを確認し、名前を選択することができます。

以下がウェイティングルームになります：

![Screenshot of waiting room on mobile device](/content/blog/create-a-multiparty-video-app-with-the-new-video-express/waiting-room.png "Screenshot of waiting room on mobile device")

ユーザーの選択を保持するいくつかのステート変数があります。これにより、ユーザーがオーディオまたはビデオをオフにした状態でルームに参加したり、名前を設定したり、オーディオデバイスを変更したりすることができます。

```js
const roomToJoin = location?.state?.room || '';
const [roomName, setRoomName] = useState(roomToJoin);
const [userName, setUserName] = useState('');
const [isRoomNameInvalid, setIsRoomNameInvalid] = useState(false);
const [isUserNameInvalid, setIsUserNameInvalid] = useState(false);
const [localAudio, setLocalAudio] = useState(
    user.defaultSettings.publishAudio
  );
const [localVideo, setLocalVideo] = useState(
    user.defaultSettings.publishVideo
);
const [localVideoSource, setLocalVideoSource] = useState(undefined); const [localAudioSource, setLocalAudioSource] = useState(undefined);
let [audioDevice, setAudioDevice] = useState('');
let [videoDevice, setVideoDevice] = useState('');
```


オーディオやビデオのソースなど、ユーザーの選択を処理する[UserContext](https://github.com/nexmo-se/video-express-react-app/blob/main/src/App.js#L53)を作成しました。`usePreviewPublisher`フックを使って、ウェイティングルームのパブリッシャープレビューを作成・破棄し、利用可能なデバイスのリストとその他の有用なステート変数を獲得します。

```js
const {
    createPreview,
    destroyPreview,
    previewPublisher,
    logLevel,
    previewMediaCreated,
    deviceInfo,
    accessAllowed
  } = usePreviewPublisher();
```

コンポーネントがマウントされ、ウェイティングルーム用のコンテナが作成されたところで、ロジックが開始されます。では、パブリッシャープレビューを作成します。

```js
useEffect(() => {
    if (waitingRoomVideoContainer.current) {
      createPreview(waitingRoomVideoContainer.current);
    }

    return () => {
      destroyPreview();
    };
  }, [createPreview, destroyPreview]);
```

`useEffect`フックは、プレビューが作成されると実行され、現在使用中のデバイスでデバイスのリストを初期化します。`getAudioDevice()`と`getVideoDevice()`の呼び出しに注意してください。前者はプロミスであり、後者は同期メソッドです。

```
useEffect(() => {
    if (previewPublisher && previewMediaCreated && deviceInfo) {
      console.log('useEffect - preview', deviceInfo);
      previewPublisher.getAudioDevice().then(currentAudioDevice => {
        setAudioDevice(currentAudioDevice.deviceId);
      });
      const currentVideoDevice = previewPublisher.getVideoDevice();
      console.log('currentVideoDevice', currentVideoDevice);
      setVideoDevice(currentVideoDevice.deviceId);
    }
  }, [
    deviceInfo,
    previewPublisher,
    setAudioDevice,
    setVideoDevice,
    previewMediaCreated
  ]);
```

デバイスを変更するロジックは、オーディオとビデオに関するものとほぼ同じです。ここではオーディオについて説明しますが、[WaitingRoom](https://github.com/nexmo-se/video-express-react-app/blob/main/src/components/WaitingRoom/index.js)コンポーネントの実装を確認することができますので覚えておいてください。

```js
useEffect(() => {
    if (previewPublisher) {
      if (localVideo && !previewPublisher.isVideoEnabled()) {
        previewPublisher.enableVideo();
      } else if (!localVideo && previewPublisher.isVideoEnabled()) {
        previewPublisher.disableVideo();
      }
    }
  }, [localVideo, previewPublisher]);
```

ユーザーが使用するビデオデバイスを変更したときに起動するイベントリスナーがあります：

```js
const handleVideoSource = React.useCallback(
    e => {
      const videoDeviceId = e.target.value;
      setVideoDevice(e.target.value);
      previewPublisher.setVideoDevice(videoDeviceId);
      setLocalVideoSource(videoDeviceId);
    },
    [previewPublisher, setVideoDevice, setLocalVideoSource]
  );
```

## 結論

この記事では、まったく新しいVideo ExpressをReactアプリケーションと統合する方法を紹介しています。このアプリケーションは、ウェイティングルーム、デバイスの選択、ネットワークステータスの検知、画面共有、チャットなど、ビデオアプリケーションに関連する主な機能を実装しています。

[Github Repo](https://github.com/nexmo-se/video-express-react-app)をクローンして、あなたのアプリケーションで自由に使い始めてください。
