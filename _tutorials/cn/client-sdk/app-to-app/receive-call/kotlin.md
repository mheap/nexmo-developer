---
title:  接收呼叫
description:  在此步骤中，您将学习如何接收应用内呼叫

---

接收呼叫
====

在 `MainViewModel` 类中找到 `incomingCallListener` 属性，并填充其主体：

```kotlin
private val incomingCallListener = NexmoIncomingCallListener { call ->
    callManager.onGoingCall = call
    val otherUserName = call.callMembers.first().user.name
    val navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment(otherUserName)
    navManager.navigate(navDirections)
}
```

现在，您需要确保调用上面的侦听器。在 `MainViewModel` 类中找到 `onInit` 方法，并填充其主体：

```kotlin
fun onInit(mainFragmentArg: MainFragmentArgs) {
    val currentUserName = mainFragmentArg.userName
    _currentUserNameMutableLiveData.postValue(currentUserName)

    otherUserName = Config.getOtherUserName(currentUserName)

    client.removeIncomingCallListeners()
    client.addIncomingCallListener(incomingCallListener)
}
```

