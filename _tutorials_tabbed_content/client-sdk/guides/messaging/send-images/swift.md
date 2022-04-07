---
title: Swift
language: swift
menu_weight: 1
---

```swift
let image = UIImage(named: "file.png")
guard let imageData = image?.pngData() else { return }

client.uploadAttachment(with: .image, name: "File name", data: imageData) { error, data in
    if let error = error {
        print("Error sending image: \(error.localizedDescription)")
        return
    }
    
    if let imageObject = data?["original"] as? [String: Any],
        let imageUrl = imageObject["url"] as? String {
        let imageMessage = NXMMessage(imageUrl: imageUrl)
        conversation.sendMessage(imageMessage, completionHandler: { [weak self] (error) in
            ...
        })
    }
}
```
