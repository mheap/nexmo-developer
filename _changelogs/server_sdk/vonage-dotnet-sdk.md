---
version: '5.9.5'
release: '19 Jan 2022'
---
# [Vonage DotNET SDK](https://github.com/Vonage/vonage-dotnet-sdk)

---

## 6.0.1-rc
### 25 May 2022

- Reinstating .ToString method on Ncco class
- Making Vonage serialization settings public
- Removing VersionPrefix from project file as to not confuse
- Renaming Number Insights methods so not confusing between `async` and `Asynchronous`

---

## 6.0.0-rc
### 24 May 2022

- Removing legacy Nexmo classes that have been marked as obsolete in previous versions
- Renaming enums to use Pascal Case as is accepted practice
- Moving serialisation settings to a single location
- Adding methods for new Messages API (SMS, MMS, WhatsApp, Messenger, Viber)
- Refactoring NCCO class to use List as it's base class
- Misc. refactoring

---

## 5.10.0
### 20 Apr 2022

- Real-Time data for advanced number insights
- Unit Test refactoring
- Authentication exceptions to give more information if incorrect authentication credentials are supplied

---

## 5.9.5
### 19 Jan 2022

- NCCO Input "Type" property added to align with documentation

---

## 5.9.3
### 23 Nov 2021

- Fixing an issue caused by the usage of a non thread safe Dictionary.

---

## 5.9.2
### 4 Nov 2021

- Fixing issue with Advance Number Insights throwing an exception when status = `not_roaming`