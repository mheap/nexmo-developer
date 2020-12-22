---
title:  进行呼叫
description:  在此步骤中，您将学习如何进行应用到应用的呼叫。

---

进行呼叫
====

在 `MainViewModel` 类中找到 `startAppToAppCall` 方法，并填充其主体以启用呼叫：

```java
@SuppressLint("MissingPermission")
public void startAppToAppCall() {
    String otherUserName = otherUserLiveData.getValue();
    lastCalledUserName = otherUserName;
    client.call(otherUserName, NexmoCallHandler.SERVER, callListener);
    loadingMutableLiveData.postValue(true);
}
```

> **注意** ：只有在给定了使用的 NCCO 配置时，Alice 呼叫 Bob 的场景才能正常工作。

现在，您需要确保在按下该按钮后会调用上述方法。打开 `MainFragment` 类，并更新 `onViewCreated` 方法中的 `startAppToAppCallButton.setOnClickListener`：

```java
startAppToAppCallButton.setOnClickListener(it -> viewModel.startAppToAppCall());
```

