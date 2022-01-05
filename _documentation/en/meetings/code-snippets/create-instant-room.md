---
title: Create an Instant Room
navigation_weight: 0
description: Setting up an Instant Meeting Room
---

# Set up an Instant Meeting Room

How to set up an Instant (default) room using the Meetings API.

## Prerequisites

* **Vonage Developer Account**: If you do not already have one, sign-up for a free account on the [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

* **Meetings API Activation**: To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **API Key and Secret**: Once you’re logged in to the [Vonage API Dashboard](https://dashboard.nexmo.com), you'll find your API Key and Secret on the Meetings API menu.

## Set up POST Request

**POST Endpoint**: The endpoint for creating a meeting room is: ``https://api-eu.vonage.com/beta/meetings/rooms``.

**Required Headers**: You need to add the ``Content-Type`` to your headers: ``Content-Type: application/json``.

**Authorization**: Log into your [Vonage API Dashboard](https://dashboard.nexmo.com) to retrieve your `VONAGE_API_KEY` and `VONAGE_API_SECRET`. You'll combine these to create a [Basic Authentication](/concepts/guides/authentication) string.

## Body Content

The following fields can be assigned values in the POST request:

Field | Required? | Description |
-- | -- | -- | --| -- |
``display_name`` | Yes | The name of the meeting room.
``metadata`` | No | Metadata that will be included in all callbacks.
``type``| No | The type of meeting which can be ``instant`` (the default) or ``long term``.
``expires_at`` | No | The room expiration date in Universal Time Coordinated (UTC) format.
``recording_options`` | No | An object containing recording options for the meeting. For example:
| | | If ``auto_record``=``true``, the session will be recorded.
| | | If ``auto_record``=``false``, the session will not be recorded.

## Request

You can use the following code to start an instant room (default options):

``` curl

   curl -X POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
   -H 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
   -H 'content-type: application/json' \
   -d '{
   "display_name":"New Meeting Room"
               }
```

To create an instant room and automatically turn on recording:

``` curl
   curl -X POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
   -H 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
   -H 'Content-Type: application/json' \
   -d '{
   "display_name":"New Meeting Room"
   "recording_options": {
       "auto_record": true}
               }
```

## Response

When an instant room is created the expiration date is set to 10 minutes.

As this room has not yet expired, ``is_available`` is set to true.

> If you set ``auto_record`` to ``true`` in your request, this option will be shown as ``true`` in the code below.

``` json
{
   "id":"a66e451f-794c-460a-b95a-cd60f5dbdc1a",
   "display_name":"New Meeting Room",
   "metadata":null,
   "type":"instant",
   "expires_at":"2021-10-19T17:54:17.219Z",
   "recording_options":{
      "auto_record":false
   },
   "meeting_code":"982515622",
   "_links":{
      "host_url":{
         "href":"https://meetings.vonage.com/?room_token=982515622&participant_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYyNjdkNGE5LTlmMTctNGVkYi05MzBmLTJlY2FmMThjODdj3BK7.eyJwYXJ0aWNpcGFudElkIjoiODNjNjQxNTQtYWJjOC00NTBkLTk1MmYtY2U4MWRmYWZiZDNkIiwiaWF0IjoxNjM0NjY1NDU3fQ.PmNtAWw5o4QtGiyQB0QVeq_qcl6fs0buGMx5t4Fy43c"
      },
      "guest_url":{
         "href":"https://meetings.vonage.com/982515622"
      }
   },
   "created_at":"2021-10-19T17:44:17.220Z",
   "is_available":true
}
```

> Your Instant Room has been created. Note the ``ID`` if you are going to further configure this room.
