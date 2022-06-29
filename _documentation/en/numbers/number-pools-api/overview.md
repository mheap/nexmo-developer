---
title: Overview
meta_title: Number Pools API
description: Number Pools are collections of numbers associated with a Vonage Account (API Key) that can be leveraged to send outbound SMS traffic to users. The Number Pools API enables Vonage customers to directly manage account-level number pools programmatically as a self-service.
---

# Number Pools API Overview

Number Pools are collections of numbers associated with a Vonage Account (API Key) that can be leveraged to send outbound SMS traffic to users. The Number Pools API enables Vonage customers to directly manage account-level number pools programmatically as a self-service. This self-service allows you to process a variety of requests without having to open a support ticket so they can be processed for you.

The Number Pools API allows you to perform a number of different operations on your account level number pools.

**Pool management operations supported:**

* Retrieve a list of all pools.
* Create a new pool of numbers.
* Get information about a specific pool
* Update part of a number pool.

**Numbers (within a pool) management operations supported:**

* Retrieve a list of numbers in a specific pool.
* Add a number(s) to a pool.
* Remove a specific number from a pool.
* Remove a series of numbers from a pool.

> Note: Currently, the Number Pools API does not support deleting a pool. In order to have a pool removed, you [submit a request to Vonage Customer Support](https://help.nexmo.com/hc/en-us/requests/new).

For additional information on the Number Pools API, refer to the [Vonage Knowledge Base article on Number Pools](https://nexmo.zendesk.com/knowledge/articles/4411966959380/en-us?brand_id=3270356).

## Prerequisites

The Number Pools API is currently in beta so it is only available to certain qualifying Vonage customers. Contact your account manager to have the product capabilities enabled on your account.

## Important 10DLC Considerations

In order to avoid carriers from blocking traffic, ensure all US numbers in a number pool are:

* 10DLC compliant.
* Linked to the SAME 10DLC campaign.

## Reference

* Additional information on [10DLC considerations for U.S. customers](https://developer.vonage.com/messaging/sms/overview#important-10-dlc-guidelines-for-us-customers)
* [Number Pools API reference](/api/number-pools)
* Vonage Knowledge Base [article on Number Pools](https://api.support.vonage.com/hc/en-us/articles/4411966959380)
