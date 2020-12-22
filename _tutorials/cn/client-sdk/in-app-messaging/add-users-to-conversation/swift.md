---
title:  将用户添加到对话中
description:  将您的两个新用户添加为对话成员

---

将用户添加到对话中
=========

现在，您必须使用 Nexmo CLI 将[用户](/conversation/concepts/user)添加为[对话](/conversation/concepts/conversation)的[成员](/conversation/concepts/member)。
要将 `Alice` 添加到对话中，请使用先前生成的对话 ID (`CON-...`) 替换下方命令中的 `CONVERSATION_ID`，然后运行该命令：

```sh
nexmo member:add CONVERSATION_ID action=join channel='{"type":"app"}' user_name=Alice
```

输出为成员 ID：

    Member added: MEM-aaaaaaa-bbbb-cccc-dddd-0123456789ab

现在，您需要将第二个用户 `Bob` 添加到对话中。同样，替换 `CONVERSATION_ID` 并执行该命令：

```sh
nexmo member:add CONVERSATION_ID action=join channel='{"type":"app"}' user_name=Bob
Member added: MEM-eeeeeee-...
```

