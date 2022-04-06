---
title: Java
language: java
---

```java
public void sendImage(File file){
	client.uploadAttachment(file, new NexmoRequestListener<NexmoImage>() {
		@Override
		public void onSuccess(@Nullable NexmoImage result) {
			if (result != null){
				NexmoMessage message = NexmoMessage.fromImage(result.getOriginal().getUrl());
				conversation.sendMessage(message, new NexmoRequestListener<Void>() {
					@Override
					public void onError(@NonNull NexmoApiError error) {
						Log.d("TAG", "Error: failed to send message, " + error.getMessage());
					}
					@Override
					public void onSuccess(@Nullable Void result) {}
				});
			}
		}
		@Override
		public void onError(@NonNull NexmoApiError error) {
			Log.d("TAG", "Error: Image not uploaded, " + error.getMessage());
		}
	});
    }
```
