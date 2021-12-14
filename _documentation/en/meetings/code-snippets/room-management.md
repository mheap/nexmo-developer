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
* [Recordings](#recordings).

## Overview

The Meetings API provides the following Room Management features.

## Individual Room Retrieval

Notice the ``ID`` received in the response. This is the ``ID`` of the room which will be used for room retrieval using a GET request:

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
> These should be included in an object called ``update_details``.

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
