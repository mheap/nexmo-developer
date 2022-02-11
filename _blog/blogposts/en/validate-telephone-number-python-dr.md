---
title: Validate Telephone Numbers with Nexmo Number Insights and Python
description: Ensure telephone numbers are valid and reachable and learn how to
  protect your business from fraud by checking number type, location and porting
  status.
thumbnail: /content/blog/validate-telephone-number-python-dr/Validate-Phone-Numbers-with-Number-Insights-and-Python.png
author: aaron
published: true
published_at: 2019-06-26T07:01:01.000Z
updated_at: 2021-04-26T09:31:43.794Z
category: tutorial
tags:
  - python
  - number-insight-api
comments: true
redirect: ""
canonical: ""
---
Phone number verification can do a lot more than ensuring that a telephone number is formatted correctly; it can help protect you and your customers from fraud, ensure your customers are reachable and offer a better overall customer experience.

Nexmo's [Number Insight API](https://www.nexmo.com/products/number-insight) has several different tiers of information based upon the level of detail you require. I'll go through each of these in more detail below, but in summary, they are:

1. *Basic API*, used to identify which number the country is from and to ensure that it is correctly formatted. This tier is free to use.
2. *Standard API*, determine the type of number; landline, mobile (cellular), or virtual as well as the service provider.
3. *Advanced API*, our most detailed level and the most useful for discerning risk. This API provides information on number porting, roaming, validity, and reachability (not available in the US), as well as caller name and type. This Caller ID Name (CNAM) is only available for US numbers.

## Prerequisites

2. [The Nexmo Server SDK for Python](https://github.com/Nexmo/nexmo-python). You can download this from GitHub or install from PyPI.
   <sign-up></sign-up>

## Optional Requirements

I've published [the source code for the examples below on GitHub](https://github.com/nexmo-community/python-number-insight); it has a few additional requirements.

1. [Poetry, for packaging and dependency management](https://poetry.eustace.io/)
2. [Black](https://github.com/python/black), [pylint](https://www.pylint.org/), and [flake8](http://flake8.pycqa.org/en/latest/). These packages help ensure my code is clean, clear, and well formatted

## Set Up

Each of the APIs uses the Nexmo Python client, so first, we instantiate an instance of the client using our Nexmo API key and secret, which you can find on [your Nexmo dashboard](https://dashboard.nexmo.com/).

```python
self.client = nexmo.Client(
    key=os.environ["NEXMO_API_KEY"], secret=os.environ["NEXMO_API_SECRET"]
)
```

## Basic API

Let's start with the free tier.

```python
response = cls.client.get_basic_number_insight(number=cls.number)
```

<script id="asciicast-232919" src="https://asciinema.org/a/232919.js" async></script>

Here you can see a successful response; the script is converting the object returned by the Nexmo client to a JSON string before printing to the Terminal. To make the rest of the examples more readable, I use [jq to format the output](https://stedolan.github.io/jq/).

<script id="asciicast-232920" src="https://asciinema.org/a/232920.js" async></script>

In the example above you can see that the API takes an [E.164 formatted number](https://en.wikipedia.org/wiki/E.164) and returns both the international and national formatting for the number, this is useful when displaying telephone numbers in a human-readable format to your users.

## Notes About the Demos

It's worth noting that while I have created a CLI to demo the usage of Number Insight, it's not a requirement to use the API. You can use the Nexmo Server SDK for Python directly within your Python scripts; [the source is MIT Licensed](https://github.com/Nexmo/nexmo-python#license).

While this demo only works with number insight, if you would like to access all of Nexmo's APIs from the command line we also have [the Vonage CLI](https://github.com/Vonage/vonage-cli). You could even combine the two.

<script id="asciicast-232915" src="https://asciinema.org/a/232915.js" async></script>

## Standard API

```python
response = cls.client.get_standard_number_insight(number=cls.number)
```

<script id="asciicast-232922" src="https://asciinema.org/a/232922.js" async></script>

As well as the information provided by the Basic API, the Standard API returns information on the number type and carrier. You can see a full feature comparison table on [Nexmo Developer](https://developer.nexmo.com/number-insight/overview#feature-comparison).

Information on number type can be useful in determining how you should contact the user. For example, if the network type is `mobile`, then you may [use SMS for notifications](https://www.nexmo.com/products/messages), but if the network type is `landline`, then [you should use the Voice API](https://www.nexmo.com/products/voice). Some services choose to block users from using virtual numbers to register by ensuring the network type is not `virtual`.

The Standard tier is also the first level, which [charges per API call](https://www.nexmo.com/pricing).

<script id="asciicast-232923" src="https://asciinema.org/a/232923.js" async></script>

## Advanced API

The Advanced API contains much more information and is incredibly useful in helping to prevent fraud and for protecting your users.

<script id="asciicast-232917" src="https://asciinema.org/a/232917.js" async></script>

There is a wealth of information provided by the Advanced API, but it is still a single function call.

```python
response = cls.client.get_advanced_number_insight(number=cls.number, cnam=True)
```

You need to add `cnam=True` to retrieve CNAM data for US numbers, where available.

<script id="asciicast-232927" src="https://asciinema.org/a/232927.js" async></script>

## Fraud Detection and Risk Management

One of the most valuable uses of the Number Insights API is as part of your fraud detection and risk management process. Is the number valid, is it reachable, does the carrier location match other location information you have for the user; these are all examples of questions you could use within your risk scoring process during registration.

By combining the Number Insight API with [Nexmo Verify](https://www.nexmo.com/products/verify), you can also protect high-value transactions within your application. Has any of the information changed since the user registered, is the CNAM different, is the number ported, has the carrier changed, is the number roaming but the user's location remains the same; again all questions which can inform your risk scores.

## Location Checking

To make it easier to check that the location of a number matches that of the user, our Advanced API also includes optional IP matching. If you provide the user's IP address, we attempt to determine the country the IP address originates from and return either an `ip_match_level` of `country` if they match or `mismatch` if they don't.

```python
response = cls.client.get_advanced_number_insight(number=cls.number, ip=ip)
```

<script id="asciicast-232921" src="https://asciinema.org/a/232921.js" async></script>

## Summary

A handy way to remember [which Number Insight level to use](https://developer.nexmo.com/number-insight/overview#basic-standard-and-advanced-apis):

1. Basic, what country is the number from and how should it look
2. Standard, what type of number is it and who provided it
3. Advanced, does this number raise any red flags which might indicate a risk to my business or my users