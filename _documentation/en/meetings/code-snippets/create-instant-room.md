---
title: Create an Instant Room
navigation_weight: 0
description: Setting up an Instant Meeting Room
---

# Setting up an Instant Meeting Room

How to setup an Instant (default) room using the Meetings API.

## Prerequisites

* **Vonage Developer Account** If you don’t have a Vonage account yet, you can get one  here: [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

* **Meetings API Activation** To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **API Key and Secret** Once you’re logged in, you'll find your API Key and Secret in your dashboard under "Getting Started".

## Setup POST Request

**POST Endpoint**: The (POST) endpoint when creating a meeting room is: `` https://api.vonage.com/beta/meetings/rooms ``

**Required Headers**: You need to add the ``Content-Type`` to your headers: Content-Type: application/json ``

**Authorization**: Basic [Authentication](/concepts/guides/authentication) is enabled with your `VONAGE_API_KEY` and `VONAGE_API_SECRET` from your account.

## Body Content

You'll need to provide the following:

* ``display_name`` (required) the name of the meeting room.
* ``metadata`` metadata that will be included in all callbacks.
* ``type`` which can be ``instant`` or ``long term``.
* ``expires_at`` (required for the ``long_term`` type). The room expiration date in Universal Time Coordinated (UTC) format.
* ``recording_options`` an object containing various meeting recording options:
   ``auto_record`` (boolean) sets whether the session will be recorded or not.

## Request

``` curl

   --request POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
   --header 'authorization: basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
   --header 'content-type: application/json' \
   --data-raw '{
   "display_name":"New Meeting Room"
               }
```

## Response

An instant room has been created by default, which means that the expiration date was automatically set to 10 minutes after room creation.

As this room has not yet expired, ``is_available`` is set to true. By default, ``auto_record`` was set to ``false``.

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

> Your Instant Room has been created.