---
title: Overview
meta_title: Number Insights API
description: Vonage's Number Insight API delivers real-time intelligence about the validity, reachability and roaming status of a phone number and tells you how to format the number correctly in your application.
---

# Number Insight API Overview

Vonage's Number Insight API delivers real-time intelligence about the validity, reachability and roaming status of a phone number and tells you how to format the number correctly in your application.

## Contents
This document contains the following information:

- [Concepts](#concepts) - what you need to know
- [Basic, Standard and Advanced API levels](#basic-standard-and-advanced-apis) - understand their different capabilities
- **[Getting Started with the Number Insight API](#getting-started)** - try it out
- [Guides](#guides) - learn how to use the Number Insight API
- [Code Snippets](#code-snippets) - code snippets to help with specific tasks
- [Use Cases](#use-cases) - detailed use cases with code examples
- [Reference](#reference) - complete API documentation

## Concepts

* [Webhooks](/concepts/guides/webhooks) - you can use the Advanced API to return comprehensive data about a number to your application when it becomes available, via a webhook.

## Basic, Standard and Advanced APIs
Each API level builds upon the capabilities of the previous one. For example, the Standard API includes all of the locale and formatting information from the Basic API and returns extra data about the type of number, whether it is ported and the identity of the caller (US only). The Advanced API provides the most comprehensive data. It includes everything that is available in the Basic and Standard APIs and adds roaming and reachability information.

> Unlike the Basic and Standard APIs which are synchronous APIs, the Advanced API is intended to be used asynchronously.

### Typical use cases

- **Basic API**: Discovering which country a number belongs to and using the information to format the number correctly.
- **Standard API**: Determining whether the number is a landline or mobile number (to choose between voice and SMS contact) and blocking virtual numbers.
- **Advanced API**: Ascertaining the risk associated with a number.

### Feature comparison
Feature | Basic | Standard | Advanced
:--|:--:|:--:|:--:
Number format and origin| ✅ | ✅ | ✅    
Country Information (country code, name, prefix)| ✅ | ✅ | ✅    
Current Carrier (network code, name, country, network type) | ❌ | ✅ | ✅
Original Carrier (network code, name, country, network type) | ❌ | ✅ | ✅
Porting Information | ❌ | ✅ | ✅
Validity* | ❌ | ❌ | ✅
Reachability* | ❌ | ❌ | ✅
Real-Time Data | ❌ | ❌ | ✅
Roaming status* | ❌ | ❌ | ✅
Roaming carrier & country* | ❌ | ❌ | ✅
CNAM (add-on) | ❌ | ✅ | ✅

\* Only available in certain markets. Please test and/or contact sales for more information.

> Check the legislation in your country to ensure that you are allowed to save user roaming information.

## Getting Started

This example shows you how to use the [Vonage CLI](/tools) to access the Number Insight Basic API and display information about a number.

> For examples of how to use Basic, Standard and Advanced Number Insight with `curl` and the developer SDKs see the [Code Snippets](#code-snippets).

### Before you begin:

* Sign up for a [Vonage API account](https://dashboard.nexmo.com/signup)
* Install [Node.JS](https://nodejs.org/en/download/)

### Install and set up the Vonage CLI

```
$ npm install -g @vonage/cli
```

> Note: Depending on your user permissions, you might need to prefix the above command with `sudo`.

Use your `VONAGE_API_KEY` and `VONAGE_API_SECRET` from the [dashboard getting started page](https://dashboard.nexmo.com/getting-started-guide) to set up the Vonage CLI with your credentials:

```
$ vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

### Execute a Number Insight API Basic lookup

Execute the example command shown below, replacing the phone number with one that you want information about:

```
vonage numberinsight 15555555555
```

### View the response


```text
$ vonage numberinsight 15555555555

Number Formats
National: (555) 555-5555
International: 15745144119

Country Details
Country: United States of America
Country Code: US
ISO 3 Code: USA
Prefix: 1
```


## Guides

```concept_list
product: number-insight
```

## Code Snippets

```code_snippet_list
product: number-insight
```

## Use Cases

```use_cases
product: number-insight
```

## Reference

* [Number Insight API Reference](/api/number-insight)
