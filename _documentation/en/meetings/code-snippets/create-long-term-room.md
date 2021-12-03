---
title: Create a Long Term Room
navigation_weight: 1
description: Setting up a Long Term Meeting Room
---

# Setting up a Long Term Meeting Room

How to setup a long term room using the Meetings API.

## Prerequisites

* **Vonage Developer Account** If you don’t have a Vonage account yet, you can get one  here: [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

* **Meetings API Activation** To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **API Key and Secret** Once you’re logged in, you'll find your API Key and Secret in your dashboard under "Getting Started".

## Setup POST Request

## Request

You can use the example code below create a long term room which expires on October 21st 2022. Each session will be recorded (``auto_record = true``):

``` curl
--request POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
--header 'authorization: basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
--header 'content-type: application/json' \
--data-raw '{
   "display_name":"New Meeting Room",
   "type":"long_term",
   "expires_at":"2022-10-21T18:45:50.901Z", 
   "recording_options": {
       "auto_record": true}
}
```

## Response

You will receive a request similar to the following:

``` json
{
    "id": "bc41d742-b336-4bf6-8643-aa97b5f5025c",
    "display_name": "New Meeting Room",
    "metadata": null,
    "type": "long_term",
    "expires_at": "2022-10-21T18:45:50.901Z",
    "recording_options": {
        "auto_record": true
    },
    "meeting_code": "117744699",
    "_links": {
        "host_url": {
            "href": "https://meetings.vonage.com/?room_token=117744699&participant_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYyNjdkNGE5LTlmMTctNGVkYi05MzBmLTJlY2FmMThjODdjOSJ9.eyJwYXJ0aWNpcGFudElkIjoiZmVlNDVmMDItMDhmOC00ZTdmLWE1MjAtZmYwYjYyZGI2NWM3IiwiaWF0IjoxNjM0NjY3NzQ1fQ.CDHtC3nW2B_jIXhfRTPzznH1j7kzcH3-gbL5h9bxIEE"
        },
        "guest_url": {
            "href": "https://meetings.vonage.com/117744699"
        }
    },
    "created_at": "2021-10-19T18:22:24.965Z",
    "is_available": true
}
```

> Your Long Term Room has been created.
