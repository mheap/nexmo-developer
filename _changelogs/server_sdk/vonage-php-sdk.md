---
version: '3.0.2'
release: '11 Feb 2022'
---
# [Vonage PHP SDK](https://github.com/Vonage/vonage-php-sdk-core)

---

## 3.0.2
### 11 Feb 2022

- This release adds PSR/log support for v3 and higher, in line with both Symfony and Laravel codebases for compatibility.

---

## 3.0.1
### 3 Feb 2022

This minor release is a composer dependency change to allow either v1.0 or 2.0 of psr/container.

This is to allow upstream packages (such as nexmo-laravel) to resolve successfully.

---

## 3.0.0
### 26 Jan 2022

This release represents a major milestone, with several thousand lines of code marked deprecated being removed. It also contains some minor dependency changes and a bugfix. As deprecated code is being removed, please take careful note where you might be affected by any of the signatures that are no longer present.

As always, I will be on hand for support where implementations need workarounds - the most common will probably be using the `toArray()` methods on entities for backward compatibility.

*Fixed*

- #302 `getCountryPrefix` on an an Insights object is now returned as a string

*Changed*

- Supported PHP versions are now 7.4, 8.0.X and 8.1.X
psr/container now supported for v2
- [#307](https://github.com/Vonage/vonage-php-sdk-core/pull/307) Removed array access for the majority of entities
- [#305](https://github.com/Vonage/vonage-php-sdk-core/pull/305) Further removals of old code including Call and User clients, plus tests for them that are marked deprecated
- [#303](https://github.com/Vonage/vonage-php-sdk-core/pull/303) Now supports PSR logger v2