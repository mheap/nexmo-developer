---
title:  验证用户身份
description:  在此步骤中，您将通过之前创建的 JWT 验证用户的身份

---

验证用户身份
======

您的用户必须通过身份验证才能参与通话。登录屏幕 (`LoginFragment` 和 `LoginViewModel` 类）负责验证用户的身份。

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/login-screen-users.png
```

> **注意：** 您使用在上一步中生成的 `JWTs` 执行此身份验证。

获取 NexmoClient 实例
-----------------

您必须在 `LoginViewModel` 类内检索客户端实例。通常情况下，通过注入提供示例，但出于教程目的，您将直接使用静态方法检索实例。在 `LoginViewModel` 类中找到 `private val client` 属性并更新其实现：

```java
private NexmoClient client = NexmoClient.get();
```

务必再次添加缺少的导入项。

登录用户
----

您的用户必须通过身份验证才能参与通话。在 `LoginViewModel` 类中找到 `onLoginUser` 方法，并将其替换为此代码：

```java
void onLoginUser(User user) {
    if (!StringUtils.isBlank(user.jwt)) {
        this.user = user;
        client.login(user.jwt);
    }
}
```

> **注意：** 在 `LoginFragment` 类中，探索为您编写的 `loginUser` 方法。点击两个 `Login ...` 按钮之一时，会调用此方法。此方法可调用上面的 `onLoginUser` 方法。

> **注意：** `User` 类型是我们在 `Config.kt` 文件中定义的 `data class`。

监控连接状态
------

成功建立连接后，您需要将用户导航至 `MainFragment`。在 `LoginViewModel` 类内找到 `LoginViewModel` 构造函数，并将其替换为此代码：

```java
public LoginViewModel() {
    client.setConnectionListener(new NexmoConnectionListener() {
        @Override
        public void onConnectionStatusChange(@NonNull ConnectionStatus connectionStatus, @NonNull ConnectionStatusReason connectionStatusReason) {
            if (connectionStatus == ConnectionStatus.CONNECTED) {
                navigate();
                return;
            }

            connectionStatusMutableLiveData.postValue(connectionStatus);
        }
    });
}
```

上述代码将用于监控连接状态，并且如果用户通过身份验证 (`ConnectionStatus.CONNECTED`)，它会将用户导航至 `MainFragment`。

现在您可以在该应用中拨打电话了。

