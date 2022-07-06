---
title: iOSとFlutterを活用したアプリから電話へのコール
description: Flutterを使用してiOSアプリケーションを構築し、VonageクライアントSDKを用いてモバイルアプリケーションから電話をかけられるようにします。
thumbnail: /content/blog/iosとflutterを活用したアプリから電話へのコール/flutter_inapp-call-2_1200x600.png
author: igor-wojda
published: true
published_at: 2021-04-01T08:35:09.354Z
updated_at: 2021-08-25T08:35:09.397Z
category: tutorial
tags:
  - conversation-api
  - flutter
  - japanese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*本文は英語版からの翻訳となります。日本語版において意味または文言に相違があった場合、英語版が優先するものとします。
https://learn.vonage.com/blog/2021/04/01/make-app-to-phone-call-using-ios-and-flutter/*

本日は、[Flutter](https://flutter.dev/)を使用して`iOS`アプリケーションを構築し、[VonageクライアントSDK](https://developer.nexmo.com/client-sdk/overview)を用いて[Vonage Conversation API](https://www.vonage.com/communications-apis/conversation/)により、モバイルアプリケーションから電話をかけられるようにします。アプリケーションは3つの画面（3つのUIステート）で構成されます。

![UI states: logon, make a call, and end call](/content/blog/make-app-to-phone-call-using-ios-and-flutter/ui-states.png)

## 前提条件

`Flutter iOS`アプリケーションのソースコードは、[GitHub](https://github.com/nexmo-community/client-sdk-voice-app-to-phone-flutter)で公開されています。

`iOS`デバイス向けに`Flutter`アプリケーションを構築する前に、以下の前提条件を満たす必要があります：

* コールコントロールオブジェクト（[NCCO](https://developer.nexmo.com/voice/voice-api/guides/ncco)）を作成
* Vonage CLI（旧Nexmo CLI）をインストール
* Vonageアプリケーションを設定
* Flutter SDKをインストール
* Flutterプロジェクトを作成

## Vonageアプリケーション

### NCCOを作成

[コールコントロールオブジェクト（NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference)は、Voice API callのフローをコントロールするために使用するJSON配列です。
NCCOは公開され、インターネットからアクセスできる必要があります。そのためにこのチュートリアルでは、[GitHub Gist](https://gist.github.com/)を使って構成をホストする便利な方法を紹介します。それでは新しいgistを追加しましょう：

1. https://gist.github.com/（Githubにログイン）
2. ncco.jsonをファイル名にして、新しいgistを作成します
3. 以下のJSONオブジェクトをgistにコピー＆ペーストします：

```json
[
    {
        "action": "talk",
        "text": "Please wait while we connect you."
    },
    {
        "action": "connect",
        "endpoint": [
            {
                "type": "phone",
                "number": "PHONE_NUMBER"
            }
        ]
    }
]
```

4. PHONE_NUMBERをあなたの電話番号に置き換えます（[Vonageの番号はE.164形式](https://developer.nexmo.com/concepts/guides/glossary#e-164-format)で、+と-は有効ではありません。電話番号を入力する際には、必ず国コードを指定してください。例：US：14155550100、UK：447700900001) [](https://developer.nexmo.com/concepts/guides/glossary#e-164-format)
5. Create secret gistボタンをクリックします
6. Rawボタンをクリックします
7. 次のステップで使用するので、ブラウザに表示されているURLをメモします

### Vonage CLIをインストール

[Vonage CLI](https://developer.nexmo.com/application/nexmo-cli)は、コマンドラインを使用して多くの操作を実行することができます。アプリケーションの作成、会話の作成、Vonage番号の購入などのタスクを実行したい場合は、Vonage CLIをインストールする必要があります。

Vonage CLIはNode.jsが必要ですので、[まずNode.jsをインストール](https://nodejs.org/en/download/)します。

npmでCLIのベータ版をインストールするには、以下のコマンドを実行します：

```cmd
npm install nexmo-cli@beta -g
```

Vonage API KeyとAPI Secretを使用するためにVonage CLIを設定します。ダッシュボードの設定ページから設定できます。

以下のターミナルのコマンドを実行し、API_KEYとAPI_SECRET[をダッシュボード](https://dashboard.nexmo.com/settings)の値にリプレースします：

```cmd
nexmo setup API_KEY API_SECRET
```

### Vonageアプリケーションを設定

1. プロジェクトディレクトリを作成し、次のターミナルのコマンドを実行します：

```cmd
mkdir vonage-tutorial
```

2. プロジェクトディレクトリに移動します：:

```cmd
cd vonage-tutorial
```

3. 下記のコマンドをターミナルにコピー＆ペーストして、Vonageアプリケーションを作成します。GIST-URLを前のステップのgistのURLにリプレースすることで、引数--voice-answer-urlの値を変更します。

```
nexmo app:create "App to Phone Tutorial" --capabilities=voice --keyfile=private.key --voice-event-url=https://example.com/ --voice-answer-url=GIST-URL
```

アプリケーションの作成時に、ターミナルにエコーされるApplication IDをメモしておきます。

> 注：`.nexmo-app`という名前の隠しファイルがプロジェクトディレクトリに作成され、新しく作成された`Vonage Application ID`と秘密鍵が含まれます。また、`private.key`という名前の秘密鍵ファイルが既存フォルダに作成されます。

### ユーザーを作成

各参加者は[User](https://developer.nexmo.com/conversation/concepts/user)オブジェクトで表され、Client SDKによって認証される必要があります。本番アプリケーションでは、通常、ユーザー情報をデータベースに保存します。

次のコマンドを実行して`Alice`というユーザーを作成します：

```cmd
nexmo user:create name="Alice"
```

### JWTを生成

`JWT`はユーザーの認証に使用されます。ターミナルで以下のコマンドを実行し、ユーザー`Alice`のJWTを生成します。以下のコマンドでは、`APPLICATION_ID`をアプリケーションのIDにリプレースしてください。

```
nexmo jwt:generate sub=Alice exp=$(($(date +%s)+86400)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' application_id=APPLICATION_ID
```

上記のコマンドでは、`JWT`の有効期限を最大の1日後に設定しています。

`Alice`用に生成した`JWT`をメモしておきます。

> 注：本番環境では、アプリケーションは、クライアントのリクエストごとに`JWT`を生成するエンドポイントを公開する必要があります。

## Xcodeをインストール

AppStoreを開いて[Xcode](https://developer.apple.com/xcode/)をインストールします。

## Flutterを設定

### Flutter SDKをインストール

`Flutter SDK`をダウンロードしてインストールします。

この手順は、`MacOS`、`Win`、`Linux`で異なりますが、一般的には特定のOS用の`Flutter SDK`をダウンロードし、`Flutter SDK`ファイルを解凍して、sdk╲binフォルダをシステムの`PATH`変数に追加します。プラットフォームごとの詳細な説明は[こちら](https://flutter.dev/docs/get-started/install)をご覧ください。 

幸いなことに、`Flutter`には、`SDK`と全ての必要な「コンポーネント」が存在し、正しく構成されているか確認できるツールが付属しています。次のコマンドを実行してください：

```cmd
flutter doctor
```

`Flutter Doctor`が、`Flutter SDK`がインストールされ、その他のコンポーネントもインストールされていて、正しく構成されているかどうか確認します。

## Flutterプロジェクトを作成

ターミナルを使用して`Flutter`プロジェクトを作成します：

```cmd
flutter create app_to_phone_flutter
```

上記のコマンドで、`Flutter`プロジェクトを含む`app_to_phone_flutter`フォルダを作成しま

> 「`Flutter`プロジェクトには、`iOS`プロジェクトを含む`ios`フォルダ、`Android`プロジェクトを含む`android`フォルダ、そして`web`プロジェクトを含む`web`フォルダがあります。」

`pubspec.yaml`ファイルを開き、`permission_handler`の依存関係を追加します（`sdk: flutter`のすぐ下）：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  permission_handler: ^6.0.1+1
```

> 「`yaml`ファイルではインデントが重要なので、`permission_handlerがflutter`: アイテムと同じインデントレベルであることを確認してください。」

ここで次のコマンドを実行して（パスは`Flutter`プロジェクトのルート）、上記の依存関係をダウンロードします。

```cmd
flutter pub get
```

上記のコマンドは`ios`サブフォルダに`Podfile`も作成します。`ios╲Podfile`を開き、`platform`の行をアンコメントして、`platform`のバージョンを11にアップデートします：

```
platform :ios, '11.0'
```

同じファイルの終わりに`pod 'NexmoClient'`を追加します：

```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  pod 'NexmoClient'
```

ターミナルで`app_to_phone_flutter/ios`フォルダを開き、ポッドをインストールします：

```cmd
pod install
```

上記のコマンドは、`Flutter`、パーミッションハンドラー、`Client SDK`など、必要な全ての依存関係をダウンロードします。

`XcodeでRunner.xcworkspace`を開き、アプリを実行して、上記の設定が正しく行われたことを確認します。

## Flutter/iOSの双方向コミュニケーション

現在、`Client SDKはFlutter`のパッケージとしては提供されていないので、`Android`ネイティブのクライアント`SDK`を使用し、`iOS`と`Flutter`の間で[MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)を使って通信する必要があります。これにより、FlutterはAndroidのメソッドを呼び出し、iOSはFlutterのメソッドを呼び出します。

`Flutter`のコードはlib/main.dartファイルに格納され、`iOS`のネイティブコードは`ios/Runner/AppDelegate.swift`ファイルに格納されます。

## Flutterアプリケーションを起動

Flutterアプリケーションは、[Dart](https://dart.dev/)というプログラミング言語を使って構築されています。

`lib/main.dart`ファイルを開き、コンテンツを全て以下のコードにリプレースします：

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CallWidget(title: 'app-to-phone-flutter'),
    );
  }
}

class CallWidget extends StatefulWidget {
  CallWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 64),
            _updateView()
          ],
        ),
      ),
    );
  }

  Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          child: Text("LOGIN AS ALICE")
      );
    }
  }

  Future<void> _loginUser() async {
      // Login user
  }

  Future<void> _makeCall() async {
      // Make call
  }

  Future<void> _endCall() async {
      // End call
  }
}

enum SdkState {
  LOGGED_OUT,
  LOGGED_IN,
  WAIT,
  ON_CALL,
  ERROR
}
```

上記のコードには、アプリケーションの状態を管理する役割(ユーザーのロギングとコールの管理)を担うカスタム`CallWidget`が含まれています。`SdkState`の列挙型は`Vonage Client SDK`の可能な状態を表します。この列挙型は、`Dart`を使用した`Flutter`用と`Swift`を使用した`iOS`用で2回定義されます。ウィジェットには、`SdkState`の値に基づいてUIを変更する`_updateView`メソッドが含まれています。

`Xcode`からアプリケーションを実行します：

![Running the application from xcode](/content/blog/make-app-to-phone-call-using-ios-and-flutter/run-xcode.png)

`Login as Alice`ボタンが表示されます：

![Logged out screen showing Login as Alice button](/content/blog/make-app-to-phone-call-using-ios-and-flutter/loggedout.png)

### ログイン画面

The `Login as Alice` button is disabled so now add `onPressed` handler to the `ElevatedButton` to allow logging in:

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    }
  }
```

ネイティブコードと通信し、ユーザーをログインさせるために、`_loginUser`メソッドのボディをアップデートします：

```dart
Future<void> _loginUser() async {
    String token = "ALICE_TOKEN";

    try {
      await platformMethodChannel.invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      print(e);
    }
  }
```

`ALICE_TOKEN`を、先ほど`Vonage CLI`から取得したJWTトークンにリプレースし、会話アクセスのためにユーザー`Alice`を認証します。`Flutter`は`loginUser`メソッドを呼び出し、`token`を引数として渡します。`loginUser`メソッドは`MainActivity`クラスで定義されています（後ほど説明します）。このメソッドを`Flutter`から呼び出すには、`MethodChannel`を定義する必要があります。`_CallWidgetState`クラスの先頭に`platformMethodChannel`フィールドを追加します：

`_CallWidgetState`クラスの先頭に`platformMethodChannel`フィールドを追加します：

```dart
class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  static const platformMethodChannel = const MethodChannel('com.vonage');
```

`com.vonage`の文字列は、`iOS`のネイティブコード（`AppDelegate`クラス）でも参照される、固有のチャンネル`ID`を表しています。次に、このメソッドコールを`iOS`ネイティブ側で処理する必要があります。

`FlutterMethodChannel`への参照を保持する`ios/Runner/AppDelegate`クラスと`vonageChannel`プロパティを開きます：

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var vonageChannel: FlutterMethodChannel?
    
...
```

`Flutter`からのメソッドコールをリッスンするには、`AppDelegate`クラス（上記の`application`メソッドと同じレベル）内の`addFlutterChannelListener`メソッドを追加します：

:

```swift
func addFlutterChannelListener() {
        let controller = window?.rootViewController as! FlutterViewController
        
        vonageChannel = FlutterMethodChannel(name: "com.vonage",
                                             binaryMessenger: controller.binaryMessenger)
        vonageChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "loginUser":
                if let arguments = call.arguments as? [String: String],
                   let token = arguments["token"] {
                    self.loginUser(token: token)
                }
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
```

上記のメソッドは、`Flutter`のメソッドコールを`AppDelegate`クラスで定義されたメソッド（今回は`loginUser`）に「変換」します。

また、同じクラス内の`loginUser`メソッドがありません（まもなくボディを埋める予定です）：

```swift
func loginUser(token: String) {

}
```

ここで、`application`メソッド内に`addFlutterChannelListener`メソッドコールを追加します：

```swift
override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        addFlutterChannelListener()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
```

コードが正しく書かれています - `Login As Alice`ボタンを押すと、`Flutter`アプリは`_loginUser`メソッドを呼び出します。`Flutter`プラットフォームのチャネルを通じて、このメソッドが`AppDelegate`クラスで定義された`loginUser`メソッドを呼び出します。

`Xcode`からアプリケーションを実行して、コンパイルされていることを確認します。

ユーザーがログインできるようにする前に、`Vonage SDK Client`を初期化する必要があります。

### クライアントを初期化

`AppDelegate`クラスを開き、ファイルの先頭に`NexmoClient`のインポートを追加します：

```swift
import NexmoClient
```

同じファイルに、`Vonage Client`への参照を保持する`client`プロパティを追加します。

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var vonageChannel: FlutterMethodChannel?
    let client = NXMClient.shared

...
```

ここで、クライアントを初期化するために、`initClient`メソッドを追加します：

```swift
func initClient() {
        client.setDelegate(self)
    }
```

既存の`application`メソッドから`initClient`メソッドを呼び出すには、以下の例のように`initClient()`の行を追加する必要があります：

```swift
override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initClient()
        addFlutterChannelListener()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
```

会話を許可する前に、ユーザーが正しくログインしたことを知る必要があります。`AppDelegate`ファイルで、`Vonage Client SDK`の接続状態の変更をリッスンするデリゲートを追加します：

```swift
extension AppDelegate: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        switch status {
        case .connected:
            notifyFlutter(state: .loggedIn)
        case .disconnected:
            notifyFlutter(state: .loggedOut)
        case .connecting:
            notifyFlutter(state: .wait)
        @unknown default:
            notifyFlutter(state: .error)
        }
    }
}
```

最後に、`notifyFlutter`メソッドを同じクラスに追加する必要があります：

```swift
    func client(_ client: NXMClient, didReceiveError error: Error) {
        notifyFlutter(state: .error)
    }
}
```

### ユーザーをログイン

`loginUser`メソッドのボディを変更して、クライアントインスタンスの`login`を呼び出します：

```swift
func loginUser(token: String) {
        self.client.login(withAuthToken: token)
    }
```

この方法により、`Client SDK`を使ってユーザー（Alice）がログインし、会話にアクセスすることができます。

### クライアントSDKの状態変更をFlutterに通知

`Client SDK`の状態の変更を`Flutter`に通知するためには、`Client SDK`の状態を表すenumを追加する必要があります。すでにこれに相当する`SdkState`列挙型を`main.dart`ファイルに追加しました。`MainActivity.kt`ファイルの下部に、以下の`SdkState`列挙型を追加します：

```swift
enum SdkState: String {
        case loggedOut = "LOGGED_OUT"
        case loggedIn = "LOGGED_IN"
        case wait = "WAIT"
        case onCall = "ON_CALL"
        case error = "ERROR"
    }
```

これらの状態を（上のデリゲートから）`Flutter`に送るためには、`AppDelegate`クラスに`notifyFlutter`メソッドを追加する必要があります：

```swift
func notifyFlutter(state: SdkState) {
        vonageChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
```

列挙型に状態を保存していますが、それを文字列として送信していることに注目してください。

### FlutterでSDKの状態の更新を取得

`Flutter`で状態の更新を取得するには、メソッドチャネルの更新をリッスンする必要があります。`main.dart`ファイルを開き、カスタムハンドラーで`_CallWidgetState`コンストラクターを追加します：

```dart
_CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
  }
```

同じクラス`(_CallWidgetState)`の中に、ハンドラーメソッドを追加します：

```dart
Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {return v.toString() == arguments;}
            );
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
```

これらのメソッドは、`Android`から「シグナル」を受け取り、それを列挙型に変換します。次に、`SdkState.WAITとSdkState.LOGGED_IN`の状態をサポートするために、`_updateView`メソッドの内容を以下の例のように更新します：

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    }  else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: Text("MAKE PHONE CALL")
      );
    }
  }
```

`SdkState.WAIT`の間は、プログレスバーが表示されます。ログインに成功すると、アプリケーションに`MAKE PHONE CALL`ボタンが表示されます。

アプリを実行して、`LOGIN AS ALICE`と書かれたボタンをクリックします。MAKE PHONE CALLボタンが表示され、これは`SdkState enum`）に基づいた`Flutter`アプリの別の状態です。)以下はこの例の画像になります：

![Make a phone call UI state](/content/blog/make-app-to-phone-call-using-ios-and-flutter/makeaphonecall.png)

### コールする

次に、電話をかけるための機能を追加する必要があります。`main.dart`ファイルを開き、`_makeCall`メソッドのボディを以下のように更新します：

```dart
Future<void> _makeCall() async {
    try {
      await platformMethodChannel
          .invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
  }
```

上記のメソッドはiOSと通信するため、`AppDelegate`クラスのコードも更新する必要があります。`addFlutterChannelListener`メソッド内の`switch`文に`makeCall`句を追加します：

```swift
func addFlutterChannelListener() {
        let controller = window?.rootViewController as! FlutterViewController
        
        vonageChannel = FlutterMethodChannel(name: "com.vonage",
                                             binaryMessenger: controller.binaryMessenger)
        vonageChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "loginUser":
                if let arguments = call.arguments as? [String: String],
                   let token = arguments["token"] {
                    self.loginUser(token: token)
                }
                result("")
            case "makeCall":
                self.makeCall()
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
```

次に、同じファイルに`onGoingCall`プロパティを追加します。これは、コールが進行中であるかどうか、またいつ進行中であるかを定義するものです：

```swift
var onGoingCall: NXMCall?
```

> 注：現在、`Client SDK`は進行中のコールリファレンスを保存していないため、`AppDelegate`クラスに保存する必要があります。この参照は、後でコールを終了する際に使用します。

同じクラスに`makeCall`メソッドを追加します：

```swift
func makeCall() {
        client.call("IGNORED_NUMBER", callHandler: .server) { [weak self] (error, call) in
            guard let self = self else { return }
            
            if error != nil {
                self.notifyFlutter(state: .error)
                return
            }
            
            self.onGoingCall = call
            self.notifyFlutter(state: .onCall)
        }
    }
```

T上記のメソッドは、`Flutter`アプリの状態を`SdkState.WAIT`に設定し、`Client SDK`のレスポンス(エラーまたは成功)を待ちます。ここで、`main.dart`ファイル内に両方の状態（`SdkState.ON_CALLとSdkState.ERROR`）のサポートを追加する必要があります。以下のように`_updateView`メソッドのボディを更新します：

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: Text("MAKE PHONE CALL")
      );
    } else if (_sdkState == SdkState.ON_CALL) {
      return ElevatedButton(
          onPressed: () { _endCall(); },
          child: Text("END CALL")
      );
    } else {
      return Center(
        child: Text("ERROR")
      );
    }
  }
```

状態が変化するたびに、UIが変更されます。コールする前に、アプリケーションはマイクを使用するための特定の許可を必要とします。次のステップでは、これらの許可をリクエストするための機能をプロジェクトに追加します。

### 許可をリクエスト

アプリケーションはマイクにアクセスする必要があるので、マイクへのアクセスをリクエストしなければなりません（`Flutter`では`Permission.microphone`）。

`ios/Runner/info.plist`ファイルを開き、`Privacy - Microphone Usage Description`キーに`Make a call`の値を追加します：

![Setting add microphone permission](/content/blog/make-app-to-phone-call-using-ios-and-flutter/microphone-permission.png)

すでに`Flutter`プロジェクトに[permission_handler](https://pub.dev/packages/permission_handler)パッケージを追加しました。では、`main.dart`ファイルの先頭で、以下の例のように`permission_handler`パッケージをインポートする必要があります：

```dart
import 'package:permission_handler/permission_handler.dart';
```

特定の許可のリクエストを起動させるためには、`main.dart`ファイル内の`_CallWidgetState`クラスに`requestPermissions()`メソッドを追加する必要があります。そこで、この新しいメソッドをクラス内に追加します：

```dart
Future<void> requestPermissions() async {
    await [ Permission.microphone ].request();
  }
```

上記のメソッドは、`permission_handler`を使って許可をリクエストします。

同じクラスで、`_makeCall`クラスのボディを修正して、メソッドチャネル経由でメソッドを呼び出す前に許可をリクエストします：

```dart
Future<void> _makeCall() async {
    try {
      await requestPermissions();
 
      ...
  }
```

Rアプリを起動し、`MAKE PHONE CALL`をクリックしてコールを開始します。許可ダイアログが表示されるので、許可するとコールが開始されます。

> リマインダー：`NCCO`では以前に電話番号を定義しました。

アプリケーションの状態が`SdkState.ON_CALL`に更新され、UIが更新されます：

![On call UI](/content/blog/make-app-to-phone-call-using-ios-and-flutter/oncall.png)

### コールを終了

コールを終了するには、`platformMethodChannel`を使ってネイティブ`iOS`アプリケーション上でメソッドをトリガーする必要があります。`main.dart`ファイル内で、`_endCall`メソッドのボディを更新します：

```dart
Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {}
  }
```

上記のメソッドはiOSと通信するので、`AppDelegate`クラスのコードも更新する必要があります。`addFlutterChannelListener`メソッド内の`switch`文に`endCall`句を追加します：

```swift
func addFlutterChannelListener() {
        let controller = window?.rootViewController as! FlutterViewController
        
        vonageChannel = FlutterMethodChannel(name: "com.vonage",
                                             binaryMessenger: controller.binaryMessenger)
        vonageChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "loginUser":
                if let arguments = call.arguments as? [String: String],
                   let token = arguments["token"] {
                    self.loginUser(token: token)
                }
                result("")
            case "makeCall":
                self.makeCall()
                result("")
            case "endCall":
                self.endCall()
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
```

同じクラスに `endCall` メソッドを追加します：

```swift
func endCall() {
        onGoingCall?.hangup()
        onGoingCall = nil
        notifyFlutter(state: .loggedIn)
    }
```

上記のメソッドは、`Flutter`アプリの状態を`SdkState.WAIT`に設定し、`Client SDK`からのレスポンス（エラーまたは成功）を待ちます。両方のUIの状態は、`Flutter`アプリですでにサポートされています（`_updateView`メソッド）。

コールの終了は、`Flutter`アプリケーションのUIにある`END CALL`ボタンを押すことで処理しました。しかし、コールは`Flutter`アプリ以外でも終了することができます。例えば、（実際の電話で）コールを受ける側が通話を拒否したり、応答した後で終了させることができます。

これらのケースをサポートするためには、`NexmoCallEventListener`リスナーをコールインスタンスに追加し、コール固有のイベントをリッスンする必要があります。

`AppDelegares.swift`ファイルに、`NXMCallDelegate`を追加します：

```swift
extension AppDelegate: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        if (status == .completed || status == .cancelled) {
            onGoingCall = nil
            notifyFlutter(state: .loggedIn)
        }
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {
        
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        notifyFlutter(state: .error)
    }
}
```

上記のリスナーを登録するには、`makeCall`メソッド内の`onSuccess`コールバックを変更します：

```swift
func makeCall() {
        client.call("IGNORED_NUMBER", callHandler: .server) { [weak self] (error, call) in
            guard let self = self else { return }
            
            if error != nil {
                self.notifyFlutter(state: .error)
                return
            }
            
            self.onGoingCall = call
            self.onGoingCall?.setDelegate(self)
            self.notifyFlutter(state: .onCall)
        }
    }
```

アプリを起動して、モバイルアプリから物理的な電話番号に電話をかけます。

# サマリ

これでアプリケーションの構築に成功しました。これにより、`Vonage Client SDK`を使用して、モバイルアプリケーションから電話に電話をかける方法を学びました。プロジェクト全体については、[GitHub]  (https://github.com/nexmo-community/client-sdk-voice-app-to-phone-flutter)をご覧ください。このプロジェクトには、さらに`Android`のネイティブコード（`android`フォルダ）が含まれており、Android上でもこのアプリを実行することができます。

その他の機能については、[他のチュートリアル](https://developer.vonage.com/client-sdk/tutorials) や[Vonage開発者センター](https://developer.vonage.com/)をご覧ください。

# 関連資料

* [Vonage開発者センター](https://developer.vonage.com/)
* [初めてのFlutterアプリ](https://flutter.dev/docs/get-started/codelab)
* [Flutterプラットフォームチャネル](https://flutter.dev/docs/development/platform-integration/platform-channels)
