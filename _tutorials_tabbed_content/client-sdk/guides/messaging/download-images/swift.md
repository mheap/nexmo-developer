---
title: Swift
language: swift
menu_weight: 1
---

You can download the image using `URLSession`, notice the JWT being set as the `Authorization` header for the request:

```swift
func loadImage(urlString: String, token: String, completionHandler: @escaping (UIImage?) -> Void) {
    if let url = URL(string: urlString) {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                  error == nil else {
                completionHandler(nil)
                return
            }
            
            completionHandler(UIImage(data: data))
        }
        
        task.resume()
    }
}
```

When calling the above function make sure to update your `UIImageView` on the main thread:

```swift
loadImage(urlString: "IMAGE_URL", token: "JWT") { image in
    if let image = image {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
```
