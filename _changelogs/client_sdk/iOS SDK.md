---
version: '4.2.1'
release: '6 Apr 2022'
---
# [iOS SDK](https://developer.nexmo.com/client-sdk/sdk-documentation/ios)

---

## 4.2.1
### 6 Apr 2022

*Fixed*

- `[NXMClient uploadAttachmentWithType:name:data:completionHandler:]` method to upload attachments returns with image data

---

## 4.2.0
### 24 Mar 2022

*Added*

- Support for `call:transfer` within NXMCall
- `[NXMCallDelegate call:didTransfer:event:]` to receive new call transfer event when call transferred to a new conversation.

*Enhancements*

- WebRTC dependency upgraded to version 84.0.22.

---

## 4.1.0
### 25 Feb 2022

*Added*

- [NXMClient getDeviceId] to retrieve device identifier.