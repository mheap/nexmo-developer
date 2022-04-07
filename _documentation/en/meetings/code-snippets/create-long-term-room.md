---
title: Create a Long Term Room
navigation_weight: 1
description: Setting up a Long Term Meeting Room
---

# Set up a Long Term Meeting Room

How to setup a long term room using the Meetings API.

## Prerequisites

* **Vonage Developer Account**: If you do not already have one, sign-up for a free account on the [Vonage Developers Account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav).

* **Meetings API Activation**: To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **Application ID and Secret**: Once you’re logged in to the [Vonage API Dashboard](https://dashboard.nexmo.com), click on Applications and create a new Application. Click  `Generate public and private key` and record the private key. You'll be using the private key with the Application ID to [Generate a JSON Web Token (JWT)](https://developer.vonage.com/jwt). For further details about JWTs, please see [Authentication](/concepts/guides/authentication).

## Setup POST Request

**POST Endpoint**: The (POST) endpoint when creating a meeting room is: ``https://api.vonage.com/beta/meetings/rooms``.

**Required Headers**: You need to add the ``Content-Type`` to your headers: ``Content-Type: application/json``.

**Authorization**: Use the [JWT Generator](https://developer.vonage.com/jwt) to create a JWT from the Application ID and private key of the application. You'll use your JWT to create a [Token Authorization](/concepts/guides/authentication) string that is made up of ``Bearer`` and the JWT you created.

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

You can use the example code below to create a long term room which expires on October 21st 2022 and will be automatically recorded. This room will also receive an "Orange" theme, which you can learn more about [here](/_documentation/en/meetings/code-snippets/theme-management.md).

``` curl
curl -X POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json' \
-d '{
    "display_name":"New Meeting Room",
    "type":"long_term",
    "expires_at":"2022-10-21T18:45:50.901Z", 
    "recording_options": {
        "auto_record": true}, 
    "theme_id": "e8b1d80b-8f78-4578-94f2-328596e01387"
}'
```

## Response

You will receive a response similar to the following:

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
    "created_at": "2022-10-19T18:22:24.965Z",
    "is_available": true,
    "expire_after_use": false,
    "theme_id": "e8b1d80b-8f78-4578-94f2-328596e01387",
    "initial_join_options": {
        "microphone_state": "default"
}
```

> Your Long Term Room has been created. It expires on October 19th, 2022, has a theme called "Orange", and will begin recording automatically. Note the ``ID`` if you are going to further configure this room.
