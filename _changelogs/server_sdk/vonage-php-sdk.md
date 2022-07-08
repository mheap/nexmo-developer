---
version: '3.1.0'
release: '20 Jun 2022'
---
# [Vonage PHP SDK](https://github.com/Vonage/vonage-php-sdk-core)

---

## 3.1.0
### 20 Jun 2022

This minor release adds the Messages v1 API functionality to the SDK. You can now send text/image/video/custom messages via WhatsApp, Facebook Messenger, Viber, SMS and MMS. Contains 2 minor bugfixes.

*Changed*
New namespace: messages. To send a message, create a new object that you want to send within this namespace i.e. `Vonage\Messages\Channel\Viber\ViberText()`

*Fixed*
#318 Incorrect use of Cedilla for encoding
#317 Version bump for dependencies

---

## 3.0.5
### 29 Apr 2022

This release fixes a minor bug with the number status callback key reported in #271.

*Fixed*
#271.

*Changed*
Removed the old readme graphic to replace it with the Vonage logo, we've not been Nexmo for quite some time now.

---

## 3.0.4
### 26 Apr 2022

This is a hotfix release that fixes Laravel's usage of the deprecated `message()` client.

The previous release, triggered by #313 was actually a backwards-breaking change mistakenly released while cleaning up other old broken imports.