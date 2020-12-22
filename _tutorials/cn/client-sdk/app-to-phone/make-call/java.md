---
title:  进行呼叫
description:  在此步骤中，您将学习如何拨打电话。

---

进行呼叫
====

在 `MainViewModel` 类中找到 `startAppToAppCall` 方法，并填充其主体以启用呼叫：

```java
@SuppressLint("MissingPermission")
    public void startAppToPhoneCall() {
        // Callee number is ignored because it is specified in NCCO config
        client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, callListener);
        loadingMutableLiveData.postValue(true);
    }
```

> **注意** ：我们设置了 `IGNORED_NUMBER` 参数，因为我们的号码是在 NCCO 配置（您先前配置的 Vonage 应用程序应答 URL）中指定的。

现在，您需要确保在按下 UI 按钮后调用上述方法。打开 `MainFragment` 类，并更新 `onViewCreated` 方法中的 `startAppToPhoneCallButton.setOnClickListener`：

```java
startAppToPhoneCallButton.setOnClickListener(it -> viewModel.startAppToPhoneCall());
```

