---
title: Swift
language: swift
---

```swift
conversation.getMembersPage(withPageSize: 100, order: .asc) { error, membersPage in
    guard let membersPage = membersPage, error == nil else { return }
    print(membersPage.memberSummaries)
}
```
