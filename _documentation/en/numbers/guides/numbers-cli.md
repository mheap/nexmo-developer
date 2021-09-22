---
title: Manage Numbers with the Vonage CLI
description: Rent, configure and manage your number inventory using the Vonage CLI
navigation_weight: 2
---

# Manage Numbers with the Vonage CLI

You can use the [Vonage CLI](https://github.com/vonage/vonage-cli) to perform the following operations:

* [List your numbers](#list-your-numbers)
* [Search for new numbers](#search-for-new-numbers)
* [Rent a number](#rent-a-number)
* [Cancel a number](#cancel-a-number)

Read the [installation instructions](/messages/code-snippets/install-cli) to get started.

## List your numbers

The `vonage numbers` command lists all the numbers owned by the  account.

```shell
$ vonage numbers
 Country Number      Type       Features  Application 
 ─────── ─────────── ────────── ───────── ─────────── 
 US      ########### mobile-lvn VOICE,SMS APP_ID      
 US      ########### mobile-lvn VOICE,SMS             
 US      ########### mobile-lvn VOICE,SMS APP_ID          
 US      ########### mobile-lvn VOICE,SMS
```

## Search for new numbers

Use the `vonage numbers:search` command to list numbers available for purchase.

```shell
$ vonage numbers:search US
 Country Number      Type       Cost Features  
 ─────── ─────────── ────────── ──── ───────── 
 US      12017759762 mobile-lvn 0.90 VOICE,SMS 
 US      12017759893 mobile-lvn 0.90 VOICE,SMS 
 US      12017759906 mobile-lvn 0.90 VOICE,SMS 
 US      12017759909 mobile-lvn 0.90 VOICE,SMS 
 US      12017759925 mobile-lvn 0.90 VOICE,SMS 
 US      12017759928 mobile-lvn 0.90 VOICE,SMS 
 US      12017759939 mobile-lvn 0.90 VOICE,SMS 
 US      12017759948 mobile-lvn 0.90 VOICE,SMS 
 US      12017759963 mobile-lvn 0.90 VOICE,SMS 
 US      12017759976 mobile-lvn 0.90 VOICE,SMS 
```

## Rent a number

Use the `vonage numbers:buy` command to rent an available number. You will be prompted to confirm the purchase.

You must specify **either**:

* The `number` you want to rent
* The `country_code` and `pattern` to automatically select any matching available number

```
$ vonage numbers:buy 15555555555 US
Number 15555555555 purchased.
```

## Cancel a number

Use the `vonage numbers:cancel` command to cancel an existing number on your account. You must specify the number you wish to cancel and you will be prompted to confirm cancellation before the number is removed from your account.

```
> vonage numbersvonage number:cancel 15555555555
Number 15555555555 cancelled
```
