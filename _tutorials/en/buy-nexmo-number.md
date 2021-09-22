---
title: Buy a Vonage number
description: In this step you learn how to purchase a Vonage number.
---

# Buy a Vonage number 

## Using the Dashboard

First you can browse [your existing numbers](https://dashboard.nexmo.com/your-numbers).

If you have no spare numbers you can [buy one](https://dashboard.nexmo.com/buy-numbers).

## Using the Vonage CLI

You can purchase a number using the Vonage CLI. The following command purchases an available number in the US. Specify [an alternate two-character country code](https://www.iban.com/country-codes) to purchase a number in another country.

```bash
$ vonage numbers:search US
$ vonage numbers:buy 15555555555 US
```

