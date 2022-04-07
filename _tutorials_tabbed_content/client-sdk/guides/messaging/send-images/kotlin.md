---
title: Kotlin
language: kotlin
---

```kotlin
fun sendImage(file: File){
	client.uploadAttachment(file, object : NexmoRequestListener<NexmoImage> {
		override fun onSuccess(image: NexmoImage?) {
			val message = image?.original?.let { NexmoMessage.fromImage(it.url) }
			if (message != null) {
				conversation?.sendMessage(message, object: NexmoRequestListener<Void?> {
					override fun onError(apiError: NexmoApiError) {
						Log.d("TAG", "Error: failed to send message, ${apiError.message}")
					}
					override fun onSuccess(aVoid: Void?) {}
				})
			}
		}
		override fun onError(error: NexmoApiError) {
			Log.d("TAG", "Error: Image not uploaded, ${error.message}")
		}
	})
}
```
