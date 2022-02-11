---
title: Introducing the Vonage Reports API
description: The Vonage Reports API is a robust API that allows you to gather
  data about all of the activity that takes place across your account. In this
  post, we’ll look at what data can be exported, how you can access it with both
  JavaScript and Python, and what using an API like this helps you […]
thumbnail: /content/blog/introducing-the-vonage-reports-api/Blog_Vonage-Reports-API_1200x600.png
author: martyn
published: true
published_at: 2020-10-14T13:33:45.000Z
updated_at: 2021-04-19T12:25:26.980Z
category: tutorial
tags:
  - node
  - python
  - reports-api
comments: true
redirect: ""
canonical: ""
---
The [Vonage Reports API](https://developer.nexmo.com/reports/overview) is a robust API that allows you to gather data about all of the activity that takes place across your account.

In this post, we'll look at what data can be exported, how you can access it with both JavaScript and Python, and what using an API like this helps you understand.

## Reports API Overview

The Reports API is an API that gives you access to all the underlying data that your usage of our other APIs produces. For example, when you send an SMS from your account, that action is recorded, alongside the following:

- The cost of sending the message
- The delivery status
- The country the recipient is in
- The recipient's network provider
- The body of the message itself
- How long the message took to deliver

And that's just some of it! It's a very detailed API that gives you full control over how much information is included in the generated reports.

### Which Products Can You Get Reports For?

The Reports API covers [SMS](https://developer.nexmo.com/messaging/sms/overview), [Voice](https://developer.nexmo.com/voice/voice-api/overview), [Verify](https://developer.nexmo.com/verify/overview), [Number Insight](https://developer.nexmo.com/number-insight/overview), [Messages](https://developer.nexmo.com/messages/overview), [Conversations](https://developer.nexmo.com/conversation/overview), and Automated Speech Recognition usage.

Additionally, you can choose to have your reports show inbound or outbound usage—that's the difference between receiving a voice call (inbound) and making a voice call (outbound).

## Requesting Data Via the Reports API

There are two different types of requests you can make with the Reports API:

- Synchronous: Optimised for frequent and periodic retrieval of smaller batches of data of up to approximately 10,000 records.
- Asynchronous: Optimised for infrequent, large queries returning tens of millions of records.

### Synchronous vs. Asynchronous

One way to decide which method to use is by looking at how often you want to gather data.

If you need an up to date or on-demand view of your data and you'll be requesting every hour or every day, the synchronous request method would be adequate.

Alternatively, suppose you're looking to gather data less frequently, but you know you'll be generating lots of records over a single month of usage. In that case, the asynchronous request method is the better choice.

On average, the asynchronous request method takes around 5-10 minutes to generate and return 1 million records.

### Get a Synchronous Report

We'll start by making a synchronous request for SMS data over 24 hours using standard libraries for Node.js and Python. You don't need anything special for these requests so you can adapt them to use your HTTP library of choice.

#### Node.js Synchronous Request

Request up to 24 hours' data using Node.js:

```javascript
#!/usr/bin/env node

const https = require('https');
const querystring = require('querystring');

const VONAGE_API_KEY = 'YOUR_VONAGE_API_KEY';
const VONAGE_API_SECRET = 'YOUR_VONAGE_API_SECRET';

const reportsAPIParams = {
  account_id: VONAGE_API_KEY,
  product: 'SMS',
  direction: 'outbound',
  date_start: '2020-01-01T00:00:00Z',
  date_end: '2020-01-01T23:59:59Z',
};

const options = {
  hostname: 'api.nexmo.com',
  path: '/v2/reports/records?' + querystring.stringify(reportsAPIParams),
  method: 'GET',
  auth: `${VONAGE_API_KEY}:${VONAGE_API_SECRET}`,
};

const requestReport = https.request(options, (res) => {
  res.on('data', (data) => {
    console.log(JSON.parse(data));
  });
});

requestReport.on('error', (e) => {
  console.error(e);
});

requestReport.end();
```

#### Python Synchronous Request

Request up to 24 hours' data using Python:

```python
#!/usr/bin/python

import requests
import base64

from requests.auth import HTTPBasicAuth

VONAGE_API_KEY = "YOUR_VONAGE_API_KEY"
VONAGE_API_SECRET = "YOUR_VONAGE_API_SECRET"

payload = {
    "account_id": VONAGE_API_KEY,
    "product": "SMS",
    "direction": "outbound",
    "date_start": "2020-01-01T00:00:00Z",
    "date_end": "2020-01-01T00:00:00Z",
}

r = requests.get('https://api.nexmo.com/v2/reports/records',
                 params=payload, auth=HTTPBasicAuth(VONAGE_API_KEY, VONAGE_API_SECRET))

print(r.json())
```

### Request Asynchronous Report Data

Next, we'll make the same request for SMS data, but this time we're expecting it to return up to _10 million records_, so we'll switch to the asynchronous request method for this part. The way this process works is something like:

* Make a request for asynchronous report data, supplying a `callback_url` for notification of the report being ready. Then note the `request_id` received in the response.
* _(optional)_ Check on the status of the requested report, using the `request_id`. Once complete, a report with the status `SUCCESS` will also have the report `download_url` in the `_links` section.
* Receive an HTTP request at the `callback_url`. This contains the section `_links` which has the `download_url` for the report.
* Download the report from the `download_url`.

### Node.js Asynchronous Request

Make a request for an asynchronous report to be generated, using Node.js:

```javascript
#!/usr/bin/env node

const https = require('https');

const VONAGE_API_KEY = 'YOUR_VONAGE_API_KEY';
const VONAGE_API_SECRET = 'YOUR_VONAGE_API_SECRET';

const reportsAPIParams = JSON.stringify({
  account_id: VONAGE_API_KEY,
  product: 'SMS',
  direction: 'outbound',
  callback_url: 'https://myapplication.biz/reports/receive',
});

const options = {
  hostname: 'api.nexmo.com',
  path: '/v2/reports',
  method: 'POST',
  auth: `${VONAGE_API_KEY}:${VONAGE_API_SECRET}`,
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': reportsAPIParams.length,
  },
};

const req = https.request(options, (res) => {
  res.on('data', (data) => {
    console.log(JSON.parse(data));
  });
});

req.on('error', (e) => {
  console.error(e);
});

req.write(reportsAPIParams)
req.end();
```

### Python Asynchronous Request

Make a request for an asynchronous report to be generated, using Python:

```python
#!/usr/bin/python

import requests
import json
import base64

from requests.auth import HTTPBasicAuth

VONAGE_API_KEY = "YOUR_VONAGE_API_KEY"
VONAGE_API_SECRET = "YOUR_VONAGE_API_SECRET"

payload = {
    "account_id": VONAGE_API_KEY,
    "product": "SMS",
    "direction": "outbound",
    "date_start": "2020-01-01T00:00:00Z",
    "date_end": "2020-01-02T00:00:00Z",
    "callback_url": "https://myapplication.biz/reports/receive"
}

r = requests.post('https://api.nexmo.com/v2/reports',
                  json=payload, auth=HTTPBasicAuth(VONAGE_API_KEY, VONAGE_API_SECRET))

print(r.json())
```

## Checking the Status of Your Reports

You can check on the status of your reports at any time to check if they have completed (in which case the download will be available) or are still in a `PENDING` state.

### Check Report Status with Node.js

Get a status update on an asychronous report with Node.js:

```javascript
#!/usr/bin/env node

const https = require('https');

const VONAGE_API_KEY = 'YOUR_VONAGE_API_KEY';
const VONAGE_API_SECRET = 'YOUR_VONAGE_API_SECRET';

const REQUEST_ID = 'REQUEST_ID_FROM_PREVIOUS_STEP';

const options = {
  hostname: 'api.nexmo.com',
  path: '/v2/reports/' + REQUEST_ID,
  method: 'GET',
  auth: `${VONAGE_API_KEY}:${VONAGE_API_SECRET}`,
};

const requestReport = https.request(options, (res) => {
  res.on('data', (data) => {
    console.log(JSON.parse(data));
  });
});

requestReport.on('error', (e) => {
  console.error(e);
});

requestReport.end();
```

### Check Report Status with Python

Get a status update on an asynchronous report with Node.js:

```python
#!/usr/bin/python

import requests
import base64

from requests.auth import HTTPBasicAuth

VONAGE_API_KEY = "YOUR_VONAGE_API_KEY"
VONAGE_API_SECRET = "YOUR_VONAGE_API_SECRET"

REQUEST_ID = 'REQUEST_ID_FROM_PREVIOUS_STEP';

r = requests.get('https://api.nexmo.com/v2/reports/' + REQUEST_ID,
                 auth=HTTPBasicAuth(VONAGE_API_KEY, VONAGE_API_SECRET))

print(r.json())
```

For both of the above examples, the response will look something like this:

```json
{
  "request_id": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "request_status": "SUCCESS",
  "product": "SMS",
  "account_id": "abcdef01",
  "date_start": "2017-12-01T00:00:00+00:00",
  "date_end": "2018-01-01T00:00:00+00:00",
  "include_subaccounts": "false",
  "callback_url": "https://requestb.in/12345",
  "receive_time": "2019-06-28T15:30:00+0000",
  "start_time": "2019-06-28T15:30:00+0000",
  "_links": {
    "self": {
      "href": "https://api.nexmo.com/v2/reports/aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
    },
    "download_report": {
      "href": "https://api.nexmo.com/v3/media/aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
    }
  },
  "items_count": 1,
  "direction": "outbound",
  "status": "delivered",
  "client_ref": "abc123",
  "account_ref": "abc123",
  "include_message": "true",
  "network": "23415",
  "from": "441234567890",
  "to": "441234567890"
}
```

Note the `download_report` URL specified in the response. That URL is a link to the downloadable version of the report (a ZIP file containing a CSV). You have up to 72 hours to download the file before it is removed from our servers, and you would need to rerun your report query to get it regenerated.

> Credentials are required to download the report file, there's [an example on the Developer Portal](https://developer.nexmo.com/reports/code-snippets/get-report) showing how to do this.

## Great Ways to Use Reports API

The Reports API gives you the largest amount of information you can get from us regarding the activity on your accounts (and sub-accounts!). This means that the API lends itself to big data type applications, such as:

- Data visualization and analysis via tools like Tableau.
- Being part of a data pipeline implementation for data warehouses.
- Spotting traffic trends, issues, or fraudulent cost spikes on a large scale.
- Providing in-depth analytics to customers on their activity (via sub-accounts).
- Testing and managing outbound campaigns (especially with SMS or Messages APIs).

Once you have access to this data, there are very few limits to what you can do with it.

## Further Reading

If this introductory post has piqued your interest, then your next stop should be the [complete documentation](https://developer.nexmo.com/api/reports) for the Reports API as well as the [main overview of the Reports API](https://developer.nexmo.com/reports/overview) where there's even more detail about what is contained in a generated report.