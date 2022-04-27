---
title: Meeting Room Management
navigation_weight: 2
description: Managing Rooms with the Meetings API
---

# Meeting Room Management

## Individual Room Retrieval

Notice the ``ID`` received in the response. This is the ``ID`` of the room which will be used for room retrieval using a GET request:

``` curl
curl -X GET 'https://api-eu.vonage.com/beta/meetings/rooms/b731a3a9-5552-410b-8d5e-72eac07cb45d' \
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json'
```

> The response will be identical whether the room is long term or instant.

## Retrieve all Rooms

To retrieve all rooms, omit the ``ID``:

``` curl
curl -X GET 'https://api-eu.vonage.com/beta/meetings/rooms/' \
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json'
```

## Room Deletion

You use the ``ID`` to perform a DELETE action on a room:

``` curl
curl -X DELETE 'https://api-eu.vonage.com/beta/meetings/rooms/b307d837-c0ce-4619-8c5c-70e418ef9693' \
-H 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ==' \
-H 'Content-Type: application/json'
```

> This operation will return a ``204`` status.

## Expiration Update

The expiration date of a long term room can be updated by using a PATCH action and the room ID. The new date should be included in an object called ``update_details``. Please note that only long term rooms can be updated. 

``` curl
curl -X PATCH 'https://api-eu.vonage.com/beta/meetings/rooms/b731a3a9-5552-410b-8d5e-72eac07cb45d' \
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json' \
-d '{ "update_details": { "expires_at": "2022-11-11T16:00:00.000Z" } }'
```

## Recording

> Set this option to start recording. See [Recordings Below](#recordings).

``` json
{
    "event": "recording:started",
    "recording_id": "17461b93-f793-48a0-9392-7d82de40432f",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg"
}
```

## Recording Uploaded

> A notification that a recording is ready to be downloaded. See [Recordings Below](#recordings).

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

Recordings are associated with the session in which they occurred. To retrieve or manage recordings, you'll need the recording ``ID``, which can be found in the callbacks.

### Retrieve All Recordings From A Session

To get all recordings for a Session ID, you can use the `sessions` endpoint:

``` curl
curl -X GET 'https://api-eu.vonage.com/beta/meetings/sessions/2_MX40NjMzOTg5Mn5-MTYzNTg2ODUxNzIzNH5mOUVub3hPNCt6czlwQzdvaTYvbm5lOTN-fg/recordings'
-H 'Authorization: Basic YWFhMDEyOmFiYzEyMzQ1Njc4OQ=='
-H 'Content-Type: application/json'
```

### Retrieve Individual Recording

Once you have the recording ID, you can use the ``recordings`` endpoint to get a recording:

``` curl
curl -X GET 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json'
```

### Delete A Recording

Similarly, you can delete a recording with a ``DELETE`` action on the same endpoint:

``` curl
curl -X DELETE 'https://api-eu.vonage.com/beta/meetings/recordings/17461b93-f793-48a0-9392-7d82de40432f'
-H 'Authorization: Bearer XXXXX' \
-H 'Content-Type: application/json'
```
