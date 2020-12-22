---
title:  接收呼叫
description:  在此步骤中，您将接收呼叫。

---

接收呼叫
====

在 `MainActivity` 类的顶部、视图声明正下方，添加 `call` 属性以保留对正在进行的任何呼叫的引用，并添加 `incomingCall` 属性以保留有关当前呼入电话的信息。

```java
private NexmoCall call;
private Boolean incomingCall = false;
```

在 `MainActivity` 类中 `onCreate` 方法的底部，添加要接收呼入电话通知的呼入电话侦听器。

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    // ...
    client.addIncomingCallListener(it -> {
        call = it;

        incomingCall = true;
        updateUI();
    });
}
```

当应用程序收到呼叫时，我们希望提供接受或拒绝通话的选项。将 `updateUI` 函数添加到 `MainActivity` 类。

```java
class MainActivity : AppCompatActivity() {

    // ...
    private void updateUI() {
        answerCallButton.setVisibility(View.GONE);
        rejectCallButton.setVisibility(View.GONE);
        endCallButton.setVisibility(View.GONE);

        if (incomingCall) {
            answerCallButton.setVisibility(View.VISIBLE);
            rejectCallButton.setVisibility(View.VISIBLE);
        } else if (call != null) {
            endCallButton.setVisibility(View.VISIBLE);
        }
    }
}
```

现在您需要添加侦听器，以将 UI 与 Client SDK 绑定在一起。将此代码添加到 `MainActivity` 类中 `onCreate` 方法的底部：

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    // ...
    answerCallButton.setOnClickListener(view -> {
        in`comingCall = false;
        updateUI();
        call.answer(null);

    });

    rejectCallButton.setOnClickListener(view -> {
        incomingCall = false;
        call = null;
        updateUI();

        call.hangup(null);
    });

    endCallButton.setOnClickListener(view -> {
        call.hangup(null);

        call = null;
        updateUI();
    });
}
```

构建和运行
-----

按 `Cmd + R` 构建并再次运行，当您呼叫之前与您的应用程序链接的号码时，将显示 `Answer` 和 `Reject` 按钮。

