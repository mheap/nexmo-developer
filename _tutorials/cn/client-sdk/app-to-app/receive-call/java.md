---
title:  接收呼叫
description:  在此步骤中，您将学习如何接收应用内呼叫

---

接收呼叫
====

在 `MainViewModel` 类中找到 `incomingCallListener` 属性，并填充其主体：

```java
private NexmoIncomingCallListener incomingCallListener = call -> {
    callManager.setOnGoingCall(call);
    String otherUserName = call.getCallMembers().get(0).getUser().getName();
    NavDirections navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment(otherUserName);
    navManager.navigate(navDirections);
};
```

现在，您需要确保调用上面的侦听器。在 `MainViewModel` 类中找到 `onInit` 方法，并填充其主体：

```java
public void onInit(MainFragmentArgs mainFragmentArgs) {
    String currentUserName = mainFragmentArgs.getUserName();
    currentUserNameMutableLiveData.postValue(currentUserName);

    String otherUserName = Config.getOtherUserName(currentUserName);
    otherUserNameMutableLiveData.postValue(otherUserName);

    client.removeIncomingCallListeners();
    client.addIncomingCallListener(incomingCallListener);
}
```

