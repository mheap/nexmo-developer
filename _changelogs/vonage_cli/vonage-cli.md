---
version: '1.1.2'
release: '25 Feb 2022'
---
# [Vonage CLI]((https://github.com/Vonage/vonage-cli))

The [Vonage Command Line Interface (CLI)](https://github.com/Vonage/vonage-cli) lets you manage your account and access Vonage APIs from the command line.

---

## 1.1.2
### 25 Feb 2022

- fix: Args not found bug
- fix(jwt): default A to full permissions
- fix(sms): -h was throwing an error

[View full changelog](https://github.com/Vonage/vonage-cli/commits/@vonage/cli@1.1.2)

---

## 1.1.1
### 22 Feb 2022

- chore(utils): Fix build issue with OutputArgs by @kellyjandrews in #47
- fix(conversations): Correct conversations output and add tests by @kellyjandrews in #46
- fix(applications): Add req'd inputs and fix usage by @kellyjandrews in #48
- feat(sms): Add SMS plugin by @kellyjandrews in #49

[View full changelog](https://github.com/Vonage/vonage-cli/commits/@vonage/cli@1.1.1)

---

## 1.1.0
### 12 Jan 2022

This update includes a new command, `numbers:update`.

Currently allows updates of the inbound SMS url.
Use `vonage numbers:update -h` for details on usage.

This also includes new testing harness and various bug fixes.