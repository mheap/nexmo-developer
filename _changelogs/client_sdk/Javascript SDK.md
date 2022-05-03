---
version: '8.4.1'
release: '14 Feb 2022'
---
# [Javascript SDK](https://developer.nexmo.com/client-sdk/sdk-documentation/javascript)

---

## 8.4.1
### 14 Feb 2022

*Fix*

- Fix events ordering when gap in inbound events

---

## 8.4.0
### 21 Jan 2022

*New* 

Added new `connectivityReport()` function to get a connectivity report for all Vonage data centers and media servers

```javascript
rtc.connectivityReport().then((report) => {
  console.log(report);
}).catch((error) => {
  console.log(error);
});
```

---

## 8.3.1
### 9 Dec 2021

*New*

Set the default sync level for the login process from lite to none
