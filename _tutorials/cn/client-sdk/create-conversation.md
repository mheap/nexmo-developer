---
title:  创建对话
description: 创建使用户能够进行沟通的对话

---

创建对话
====

创建用户用于彼此沟通的[对话](/conversation/concepts/conversation)。

```bash
nexmo conversation:create display_name="CONVERSATION_NAME"
```

输出类似如下内容：

    Conversation created: CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab

记下新生成的对话 ID (`CON-...`)。稍后您将使用它将[用户](/conversation/concepts/user)作为[成员](/conversation/concepts/member)添加到[对话](/conversation/concepts/conversation)中。

