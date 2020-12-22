---
title:  构建用户模型
description:  在此步骤中，您将构建用户模型结构。

---

构建用户模型
======

要进行对话，您需要存储有关用户的一些信息：

* 用户名称
* 用户的 JWT
* 他们聊天的对象
* 对话 ID

为此，您将使用 `Struct`。打开 `ViewController.swift` 并添加它，将 `CONVERSATION_ID` 替换为之前创建的对话 ID：

```swift
class ViewController: UIViewController {
    ...
}

struct User {
    let name: String
    let jwt: String
    let chatPartnerName: String
    let conversationId = "CONVERSATION_ID"
}
```

为了后续的简便性，请向用户 Alice 和 Bob 的 `User` 类型添加一些静态属性。使用您之前创建的值替换 `ALICE_JWT` 和 `BOB_JWT`：

```swift
struct User {
    ...

    static let Alice = User(name: "Alice",
                            jwt:"ALICE_JWT",
                            chatPartnerName: "Bob")
    static let Bob = User(name: "Bob",
                          jwt:"BOB_JWT",
                          chatPartnerName: "Alice")
}
```

