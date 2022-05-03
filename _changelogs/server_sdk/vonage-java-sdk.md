---
version: '6.4.0'
release: '28 May 2021'
---
# [Vonage Java SDK](https://github.com/Vonage/vonage-java-sdk)

---

## 6.4.0
### 28 May 2021

- Adding Random From Number Feature for the Voice API, if set to `true`, the from number will be randomly selected from the pool of numbers available to the application making the call.
- adjusting operator used to check json payloads
- Adding extra parsing for top level Roaming Status in Advanced Number Insights

---

## 6.3.0
### 20 May 2021

Adding Inbound SMS message validation for JSON based POST requests

---

## 6.2.0
### 11 Mar 2021

- Adding `entityId` and `contentId` fields to SMS messages for India's DLT compliance
- Adding detail and detailEnum fields to call events, this will provide a switchable way for folks to view the newly minted details coming off of calls