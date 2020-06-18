---
title: Migrating from the SMS Message Search API
description: Retrieve SMS message details using the Reports API
navigation_weight: 1
---

# Migrating from the SMS Message Search API

The [SMS Message Search API](/api/developer/messages) is deprecated and will shortly be removed. We encourage users to use the [Reports API](/reports/overview) for this purpose instead.

You can use the Reports API either [synchronously or asynchronously](/reports/overview#synchronous-and-asynchronous-operation) to retrieve SMS message records. 

## Synchronous retrieval

Use [this endpoint](/api/reports#get-records) to retrieve SMS records synchronously, using **one** of the following approaches:

* **By message ID**: Returns a single SMS record, if one is found that matches the provided `id` parameter.

* **By time period**: Returns multiple SMS records that were sent in a time window that you specify using the `date_start` and `date_end` parameters, which cannot be more than 24 hours apart. These records are returned in JSON format in batches of up to 1,000 records. If more than 1,000 records match then the response will contain a link to the next batch.

> **Note**: Set the `include_message` parameter to `true` in the request to return the message text.

See the [Get JSON records using the command line tutorial](/reports/tutorials/get-json-records-cli/reports/get-json-records).

## Asynchronous retrieval

If you are expecting many thousands of records, you should consider [creating a report](/api/reports#create-async-report). This generates a compressed CSV file that contains all matching records. A link to the CSV file is returned in the response.

See either [Create a CSV report using the command line](/reports/tutorials/create-and-retrieve-a-report) or [Create a CSV report using a graphical tool](/reports/tutorials/create-report-using-graphical-tools).

