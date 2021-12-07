---
title: Meeting Room Management
navigation_weight: 2
description: Managing Rooms with the Meetings API
---

# Meeting Room Management

## Contents

* [Overview](#overview).
* [Individual Room Retrieval](#individual-room-retrieval).
* [Retrieve all Rooms](#retrieve-all-rooms).
* [Room Deletion](#room-deletion).
* [Room Update](#room-update).
* [Callbacks](#callbacks).
* [Recordings](#recordings).

## Overview

The Meetings API provides the following Room Management features.

## Individual Room Retrieval

Notice the ``ID`` received in the response. This is the ``ID`` of the room which will be used for room retrieval:

``` curl
--request GET 'https://api-eu.vonage.com/beta/meetings/rooms/b731a3a9-5552-410b-8d5e-72eac07cb45d' \
--header 'authorization: basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
--header 'content-type: application/json'
```

> The response will be identical whether the room is long term or instant.

## Retrieve all Rooms

To retrieve all rooms, omit the ``ID``:

``` curl
--location --request GET 'https://api-eu.vonage.com/beta/meetings/rooms/' \
--header 'authorization: basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
--header 'content-type: application/json'
```

## Room Deletion

You use the ``ID`` to perform a DELETE action on a room:

``` curl
--location --request DELETE 'https://api-eu.vonage.com/beta/meetings/rooms/b307d837-c0ce-4619-8c5c-70e418ef9693' \
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
--header 'Content-Type: application/json'
```

> This operation will return a ``204`` status.

## Room Update

A room can be updated by using a PATCH action and the room ID. Changes can be for ``display_name``, ``metadata``, ``expires_at``, and ``recording_options``
> These should be included in an object called ``update_details``

``` curl
{
--location --request PATCH 'https://api-eu.vonage.com/beta/meetings/rooms/e6acf820-7093-416f-a2bd-bcdacd7cc593' \
--header 'Authorization: Basic MTFmMWI4NGY6UnVpbnJIMWxneGZXNGJibQ==' \
--header 'Content-Type: application/json' \
--data-raw '{
  "update_details": {
    "expires_at": "2021-11-11T16:00:00.000Z"
                    }
            }
}
```

## Callbacks

API meetings callbacks allow you to receive information about session events, participant activity, recording details, and room expiration.

> To register for callbacks, please send a request to the [Meetings API Team](mailto:meetings-api@vonage.com).

### Types of Callbacks

* **Room Expired** ``room:expired``: A notification that a room is inactive. Sessions cannot be created for inactive rooms.
* **Session Started** ``session:started``: A notification that a session has started.
* **Session Ended** ``session:ended``: A notification that a session has finished.
* **Recording Started** ``recording:started``: A notification about a recording beginning within a session.
* **Recording Ended** ``recording:ended``: A notification about a recording being stopped within a session.
* **Recording Uploaded** ``recording:uploaded``: A notification that a recording is ready to be downloaded.
* **Participant Joined** ``participant-joined``: A notification about someone joining a session.
* **Participant Left** ``session:participant:left``: A notification about someone leaving a session.

### Example Payloads

#### Session Started

> A notification that a session has started.

``` json
{
    "event": "session:started",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODQwODY4NH41cXIzMDdSa1BZa05BUDFpYnhxcTV4MCt-fg",
    "room_id": "b307d837-c0ce-4619-8c5c-70e418ef9693",
    "started_at": "2021-11-02T15:53:28.753Z"
}
```

#### New Joiner

> A notification about someone entering a session.

``` json
{
    "event": "session:participant:joined",
    "participant_id": "b424e1c4-e988-4ce2-8ab9-e3efea7de542",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODQwODY4NH41cXIzMDdSa1BZa05BUDFpYnhxcTV4MCt-fg",
    "room_id": "b307d837-c0ce-4619-8c5c-70e418ef9693",
    "name": "New Joiner",
    "type": "Guest",
    "is_host": true
}
```

#### Recording

> Set this option to start recording. See [Recordings below](#Recordings).

``` json
{
    "event": "recording:started",
    "recording_id": "17461b93-f793-48a0-9392-7d82de40432f",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg"
}
```

#### Recording Uploaded

> A notification that a recording is ready to be downloaded. See [Recordings below](#Recordings).

``` json
{
    "event": "recording:uploaded",
    "recording_id": "17461b93-f793-48a0-9392-7d82de40432f",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg",
    "started_at": "2021-11-02T15:55:35.000Z",
    "ended_at": "2021-11-02T15:56:13.000Z",
    "duration": 38,
    "url": "https://prod-meetings-recordings.s3.amazonaws.com/46339892/17461b93-f793-48a0-9392-7d82de40432f/archive.mp4?..."
}
```

## Recordings

Recordings are associated with the session in which they occurred. To retrieve or manage recordings, you'll need the recording ID, which can be found in the callbacks.

### Retrieve All Recordings From A Session

To get all recordings for a Session ID, you can use the `sessions` endpoint:

``` curl
--location --request GET 'https://api-eu.vonage.com/beta/meetings/sessions/2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg/recordings'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```

### Retrieve Individual Recording

Once you have the recording ID, you can use the ``recordings`` endpoint to get a recording:

``` curl
--location --request GET 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```

### Delete A Recording

Similarly, you can delete a recording with a ``DELETE`` action on the same endpoint:

``` curl
--location --request DELETE 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```
