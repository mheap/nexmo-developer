---
title:  聊天事件
description:  在此步骤中，您将处理聊天事件。

---

聊天事件
====

之前，您在 Nexmo CLI 中创建了一个对话，并将两个用户添加到该对话中。在 Client SDK 中作为 `NXMConversation` 对象建模的对话是指用户的通信方式。您可以在[对话 API 文档](/conversation/concepts/conversation)中了解有关对话的更多信息。聊天事件或 `NXMEvent` 对象使用您创建的对话发送，因此要获取聊天事件，您首先需要获取对话。为了实现此功能，需要以下各部分中显示的为 `ChatViewController.m` 添加的内容。

在界面中添加对话和事件的属性以及 `NXMConversationDelegate` 的符合项：

```objective_c
@interface ChatViewController () <UITextFieldDelegate, NXMConversationDelegate> 
...
@property NXMConversation *conversation;
@property NSMutableArray<NXMEvent *> *events;
@end
```

在 `viewDidLoad` 函数的末尾添加 `getConversation` 的函数调用：

```swift
- (void)viewDidLoad {
    ...

    [self getConversation];
}
```

在 `ChatViewController.m` 文件的末尾添加函数以获取对话、事件并处理这些事件：

```objective_c
- (void)getConversation {
    [self.client getConversationWithUuid:self.user.conversationId completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
        self.conversation = conversation;
        if (conversation) {
            [self getEvents];
        }
        conversation.delegate = self;
    }];
}

- (void)getEvents {
    if (self.conversation) {
        [self.conversation getEventsPageWithSize:100 order:NXMPageOrderAsc completionHandler:^(NSError * _Nullable error, NXMEventsPage * _Nullable events) {
            self.events = [NSMutableArray arrayWithArray:events.events];
            [self processEvents];
        }];
    }
}

- (void)processEvents {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.conversationTextView.text = @"";
        for (NXMEvent *event in self.events) {
            if ([event isMemberOfClass:[NXMMemberEvent class]]) {
                [self showMemberEvent:(NXMMemberEvent *)event];
            } else if ([event isMemberOfClass:[NXMTextEvent class]]) {
                [self showTextEvent:(NXMTextEvent *)event];
            }
        }
    });
}

- (void)showMemberEvent:(NXMMemberEvent *)event {
    switch (event.state) {
        case NXMMemberStateInvited:
            [self addConversationLine:[NSString stringWithFormat:@"%@ was invited", event.member.user.name]];
            break;
        case NXMMemberStateJoined:
            [self addConversationLine:[NSString stringWithFormat:@"%@ joined", event.member.user.name]];
            break;
        case NXMMemberStateLeft:
            [self addConversationLine:[NSString stringWithFormat:@"%@ left", event.member.user.name]];
            break;
    }
}

- (void)showTextEvent:(NXMTextEvent *)event {
    NSString *message = [NSString stringWithFormat:@"%@ said %@", event.fromMember.user.name, event.text];
    [self addConversationLine:message];
}

- (void)addConversationLine:(NSString *)line {
    NSString *currentText = self.conversationTextView.text;
    
    if (currentText.length > 0) {
        self.conversationTextView.text = [NSString stringWithFormat:@"%@\n%@", currentText, line];
    } else {
        self.conversationTextView.text = line;
    }
}
```

`getConversation` 使用 Nexmo CLI 中的对话 ID 来获取对话，如果成功，将调用 `getEvents` 以获取聊天事件。Client SDK 支持分页，因此要获取聊天事件，您必须指定页面大小。

一旦获取事件，将通过 `processEvents` 处理这些事件。在 `processEvents` 中，有强制转换为 `NXMMemberEvent` 或 `NXMTextEvent` 的类型，它们分别通过 `showMemberEvent` 和 `showTextEvent` 附加到 `conversationTextView`。您可以在[对话 API 文档](/conversation/concepts/event)中了解有关支持的事件类型的更多信息。

对话代理
----

初始加载后，应用程序还需要对对话中的事件做出反应，因此您需要从 `NXMConversationDelegate` 实现一些函数。在 `ChatViewController.m` 类的末尾添加：

```objective_c
@implementation ViewController
    ...

- (void)conversation:(NXMConversation *)conversation didReceiveTextEvent:(NXMTextEvent *)event {
    [self.events addObject:event];
    [self processEvents];
}

- (void)conversation:(NXMConversation *)conversation didReceiveMemberEvent:(NXMMemberEvent *)event {
    [self.events addObject:event];
    [self processEvents];
}

- (void)conversation:(NXMConversation *)conversation didReceive:(NSError *)error {
    NSLog(@"Conversation error: %@", error.localizedDescription);
}
```

收到新事件后，会将其附加到 `events` 数组，然后再次开始处理事件。

构建和运行
-----

按 `Cmd + R` 构建并再次运行。登录后，您将看到两个用户都按预期加入了对话：

![显示连接事件的聊天界面](/images/client-sdk/ios-messaging/chatevents.png)

