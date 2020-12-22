---
title:  聊天事件
description:  在此步骤中，您将处理聊天事件。

---

聊天事件
====

之前，您在 Nexmo CLI 中创建了一个对话，并将两个用户添加到该对话中。在 Client SDK 中作为 `NXMConversation` 对象建模的对话是指用户的通信方式。您可以在[对话 API 文档](/conversation/concepts/conversation)中了解有关对话的更多信息。聊天事件或 `NXMEvent` 对象使用您创建的对话发送，因此要获取聊天事件，您首先需要获取对话。为了实现此功能，需要以下各部分中显示的为 `ChatViewController.swift` 添加的内容。

在 `conversationTextView` 下方添加对话和事件的属性：

```swift
class ChatViewController: UIViewController {
    ...
    let conversationTextView = UITextView()

    var conversation: NXMConversation?
    var events: [NXMEvent]? {
        didSet {
            processEvents()
        }
    }
    ...
}
```

在 `viewDidLoad` 函数的末尾添加 `getConversation` 的函数调用：

```swift
override func viewDidLoad() {
    ...

    getConversation()
}
```

在 `ChatViewController.swift` 文件的末尾添加函数以获取对话、事件并处理这些事件：

```swift
class ChatViewController: UIViewController {
    ...
    func getConversation() {
        client.getConversationWithUuid(user.conversationId) { [weak self] (error, conversation) in
            self?.conversation = conversation
            if conversation != nil {
                self?.getEvents()
            }
            conversation?.delegate = self
        }
    }
    
    func getEvents() {
        guard let conversation = self.conversation else { return }
        conversation.getEventsPage(withSize: 100, order: .asc) { (error, page) in
            self.events = page?.events
        }
    }
    
    func processEvents() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.conversationTextView.text = ""
            self.events?.forEach { event in
                if let memberEvent = event as? NXMMemberEvent {
                    self.showMemberEvent(event: memberEvent)
                }
                if let textEvent = event as? NXMTextEvent {
                    self.showTextEvent(event: textEvent)
                }
            }
        }
    }
    
    func showMemberEvent(event: NXMMemberEvent) {
        switch event.state {
        case .invited:
            addConversationLine("(event.member.user.name) was invited.")
        case .joined:
            addConversationLine("(event.member.user.name) joined.")
        case .left:
            addConversationLine("(event.member.user.name) left.")
        @unknown default:
            fatalError("Unknown member event state.")
        }
    }

    func showTextEvent(event: NXMTextEvent) {
        if let message = event.text {
            addConversationLine("(event.fromMember?.user.name ?? "A user") said: '(message)'")
        }
    }

    func addConversationLine(_ line: String) {
        if let text = conversationTextView.text, text.count > 0 {
            conversationTextView.text = "(text)\n(line)"
        } else {
            conversationTextView.text = line
        }
    }
}
```

`getConversation` 使用 Nexmo CLI 中的对话 ID 来获取对话，如果成功，将调用 `getEvents` 以获取聊天事件。Client SDK 支持分页，因此要获取聊天事件，您必须指定页面大小。

一旦获取事件，将通过 `processEvents` 处理这些事件。在 `processEvents` 中，有强制转换为 `NXMMemberEvent` 或 `NXMTextEvent` 的类型，它们分别通过 `showMemberEvent` 和 `showTextEvent` 附加到 `conversationTextView`。您可以在[对话 API 文档](/conversation/concepts/event)中了解有关支持的事件类型的更多信息。

对话代理
----

初始加载后，应用程序还需要对对话中的事件做出反应，因此您需要使 `ChatViewController` 符合 `NXMConversationDelegate`。在文件末尾添加：

```swift
extension ChatViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        NSLog("Conversation error: (error.localizedDescription)")
    }

    func conversation(_ conversation: NXMConversation, didReceive event: NXMTextEvent) {
        self.events?.append(event)
    }
}
```

收到新事件后，会将其附加到 `events` 数组，然后再次开始处理事件。

构建和运行
-----

按 `Cmd + R` 构建并再次运行。登录后，您将看到两个用户都按预期加入了对话：

![显示连接事件的聊天界面](/images/client-sdk/ios-messaging/chatevents.png)

