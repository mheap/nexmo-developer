---
title: Using Number Insight via the Vonage CLI
description: Use the Vonage CLI to get information about a phone number.
navigation_weight: 2
---

# Using Number Insight via the Vonage CLI

## Overview

You can use the [Vonage CLI](https://github.com/vonage/vonage-cli) to work with the Number Insight API without having to create the requests using `curl` or by writing program code. This guide shows you how.

## Getting Started

### Before you begin:

* Sign up for a [Vonage account](https://dashboard.nexmo.com/signup) - this will give you the API key and secret that you will need to access the Number Insight API.
* Install [Node.JS](https://nodejs.org/en/download/) - you will use `npm` (the Node Package Manager) to install the Vonage CLI.

### Install and Setup the Vonage CLI (Command Line Interface)

```partial
source: _partials/reusable/install-vonage-cli.md
```

## Try your own number with the Basic API

The Number Insight Basic API is free to use. Test it with your own number by using `vonage numberinsight [NUMBER]` and replacing `[NUMBER]` shown with your own number. The number must be in [international format](/voice/voice-api/guides/numbers#formatting):

```bash
$ vonage numberinsight 15555555555
```

The Vonage CLI displays the basic level of insights by default:

```bash
Number Formats
National: (555) 555-5555
International: 15555555555

Country Details
Country: United States of America
Country Code: US
ISO 3 Code: USA
Prefix: 1
```


> If you do not see a response similar to that shown above, check your API credentials and ensure that you have installed Node.js and the Vonage CLI properly. You can check your config by running `vonage config`

## Test the Standard and Advanced APIs

The Standard and Advanced Number Insight APIs provide even more information about the number including details of the operator and roaming status (for mobile numbers). See the [feature comparison table](/number-insight/overview#basic-standard-and-advanced-apis) to see the response data that each API level includes.

> **Note**: Calls to the Standard and Advanced APIs are not free, and you will be asked to confirm that you wish to charge your account when you use them.

### Using the Number Insight Standard API

To use the Number Insight Standard API, use the following command:

```bash
$ vonage numberinsight --level=standard 15555555555
```

After running this command, you should see the following prompt:

```
This operation will charge your account. Proceed?
```

Enter `y` to proceed, and `n` to abort.

A typical response from the Standard API looks like this:

```
Number Formats
National: (555) 555-5555
International: 15555555555

Country Details
Country: United States of America
Country Code: US
ISO 3 Code: USA
Prefix: 1

Current Carrier
Name: CARRIER
Country: US
Network Type: undefined
Network Code: #####

Original Carrier
Name: CARRIER
Country: US
Network Type: undefined
Network Code: #####

Ported: ported

Roaming Status: undefined

Account Balance
Request Cost: 0.00500000
Remaining Balance: 100.00000000
```

### Using the Number Insight Advanced API


```bash
$ vonage numberinsight --level=advanced 15555555555
```

As with the Standard API, you should see a `This operation will charge your account. Proceed?` prompt.

A typical response from the Advanced API looks like this:

```text
Partial success - some fields populated

Number Formats
National: (555) 555-5555
International: 15555555555

Country Details
Country: United States of America
Country Code: US
ISO 3 Code: USA
Prefix: 1

Current Carrier
Name: CARRIER
Country: US
Network Type: undefined
Network Code: #####

Original Carrier
Name: CARRIER
Country: US
Network Type: undefined
Network Code: #####

Ported: ported

Roaming Status: undefined

Valid Number: valid

Reachable: unknown

Account Balance
Request Cost: 0.03000000
Remaining Balance: 100.00000000
```
