---
version: '2.5.5'
release: '5 Jan 2021'
---
# [Vonage Python SDK](https://github.com/Vonage/vonage-python-sdk)

---

## 2.5.5
### 5 Jan 2021

Patched issues with PyJWT >1.8 (TypeError: can't concat str to bytes)

This patch ensures all versions of PyJWT are supported.

---

## 2.5.3
### 14 Sept 2020

- Minor patches to reflect Vonage namespace changes

---

## 2.5.2
### 27 Aug 2020

- Support for Independent SMS, Voice and Verify APIs with tests as well as current client methods
- Getters/Setters to extract/rewrite custom attributes
- PSD2 Verification support
- Dropping support for Python 2.7
- Roadmap to better error handling
- Supporting Python 3.8