---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
// Scenario #1: Send an image from a URL
conversation.sendMessage({
    "message_type": "image",
    "image": {
        "url": "https://example.com/image.jpg"
    }
}).then((event) => {
    console.log("message was sent", event);
}).catch((error)=>{
    console.error("error sending the message", error);
});

// Scenario #2: Upload an image from a file input to Vonage, then send
// Note: the URL will need to be downloaded using the fetch image method mentioned in the next section.
    
const fileInput = document.getElementById('fileInput');
const params = {
    quality_ratio : "90",
    medium_size_ratio: "40",
    thumbnail_size_ratio: "20"
}
conversation.uploadImage(fileInput.files[0], params).then((imageRequest) => {
    imageRequest.onreadystatechange = () => {
        if (imageRequest.readyState === 4 && imageRequest.status === 200) {
            try {
                const { original, medium, thumbnail } = JSON.parse(imageRequest.responseText);
                const message = {
                    message_type: 'image',
                    image: {
                        url: original.url ?? medium.url ?? thumbnail.url
                    }
                }
                return conversation.sendMessage(message);
            } catch (error) {
                console.error("error sending the image", error);
            }
        }
        if (imageRequest.status !== 200) {
            console.error("error uploading the image");
        }
    };
    return imageRequest;
}).catch((error) => {
    console.error("error uploading the image ", error);
});
```
