---
title: Mettings API Callbacks
navigation_weight: 0
description: Setting up an Instant Meeting Room
---

# Meetings API Callbacks

API meetings callbacks allow you to receive information about session events, participant activity, recording details, and room expiration.

> To register for callbacks, please send a request to the [Meetings API Team](mailto:meetings-api@vonage.com).

# Types of Callbacks

The following table describe each type of callback notification:

Name | Description |
-- | -- | -- |
``room:expired`` |  The room is inactive. Sessions cannot be created for inactive rooms.
``session:started`` | A session has started.
``session:ended`` | A session has finished.
``recording:started`` | A recording is beginning within a session.
``recording:ended`` | A recording has been stopped within a session.
``recording:uploaded`` | A recording is ready to be downloaded.
``participant:joined`` | Someone has joined a session.
``session:participant:left`` | Someone has left a session.

# Example Payloads

## Session Started

> A notification that a session has started.

``` json
{
    "event": "session:started",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODQwODY4NH41cXIzMDdSa1BZa05BUDFpYnhxcTV4MCt-fg",
    "room_id": "b307d837-c0ce-4619-8c5c-70e418ef9693",
    "started_at": "2021-11-02T15:53:28.753Z"
}
```

## New Joiner

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

## Recording

> Set this option to start recording. See [Recordings below](#Recordings).

``` json
{
    "event": "recording:started",
    "recording_id": "17461b93-f793-48a0-9392-7d82de40432f",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg"
}
```

## Recording Uploaded

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

# Recordings

Recordings are associated with the session in which they occurred. To retrieve or manage recordings, you'll need the recording ``ID``, which can be found in the callbacks.

## Retrieve All Recordings From A Session

To get all recordings for a Session ID, you can use the `sessions` endpoint:

``` curl
--location --request GET 'https://api-eu.vonage.com/beta/meetings/sessions/2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg/recordings'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```

## Retrieve Individual Recording

Once you have the recording ID, you can use the ``recordings`` endpoint to get a recording:

``` curl
--location --request GET 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```

## Delete A Recording

Similarly, you can delete a recording with a ``DELETE`` action on the same endpoint:

``` curl
--location --request DELETE 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
--header 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
--header 'Content-Type: application/json'
```
