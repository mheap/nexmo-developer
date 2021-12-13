---
title: Create a Long Term Room
navigation_weight: 1
description: Setting up a Long Term Meeting Room
---

# Setting up a Long Term Meeting Room

How to setup a long term room using the Meetings API.

## Prerequisites

* **Vonage Developer Account**: If you do not already have one, sign-up for a free account on the [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

* **Meetings API Activation**: To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **API Key and Secret**: Once you’re logged in to the [Vonage API Dashboard](https://dashboard.nexmo.com), you'll find your API Key and Secret on the Meetings API menu.

## Setup POST Request

**POST Endpoint**: The (POST) endpoint when creating a meeting room is: ``https://api.vonage.com/beta/meetings/rooms``.

**Required Headers**: You need to add the ``Content-Type`` to your headers: ``Content-Type: application/json``.

**Authorization**: Basic [Authentication](/concepts/guides/authentication) is enabled with your `VONAGE_API_KEY` and `VONAGE_API_SECRET` from your account.

## Body Content

The following fields can be assigned values in the POST request:

Field | Required? | Description |
-- | -- | -- | --| -- |
``display_name`` | Yes | The name of the meeting room.
``metadata`` | No | Metadata that will be included in all callbacks.
``type``| No | The type of meeting which can be ``instant`` (the default) or ``long term``.
``expires_at`` | Yes | You need to supply a room expiration date in Universal Time Coordinated (UTC) format for a long term room.
``recording_options`` | No | An object containing various meeting recording options. For example:
| | | If ``auto_record``=``true``, the session will be recorded.
| | | If ``auto_record``=``false``, the session will not be recorded.

## Request

You can use the example code below to create a long term room which expires on October 21st 2022 and will be automatically recorded:

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

> Your Long Term Room has been created. Note the ``ID`` if you are going to further configure this room.
