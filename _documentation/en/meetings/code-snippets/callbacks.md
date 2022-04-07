---
title: Callbacks
navigation_weight: 3
description: Setting up an Instant Meeting Room
---

# Meetings API Callbacks

API meetings callbacks allow you to receive information about session events, participant activity, recording details, and room expiration.

> To register for callbacks, please send a request to the [Meetings API Team](mailto:meetings-api@vonage.com).

## Types of Callbacks

The following table describe each type of callback notification:

Name | Description |
-- | -- | -- |
``room:expired`` | The room is inactive. Sessions cannot be created for inactive rooms.
``session:started`` | A session has started.
``session:ended`` | A session has finished.
``recording:started`` | A recording is beginning within a session.
``recording:ended`` | A recording has been stopped within a session.
``recording:uploaded`` | A recording is ready to be downloaded.
``participant:joined`` | Someone has joined a session.
``session:participant:left`` | Someone has left a session.

## Example Payloads

### Session Started

> A notification that a session has started.

``` json
{
    "event": "session:started",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODQwODY4NH41cXIzMDdSa1BZa05BUDFpYnhxcTV4MCt-fg",
    "room_id": "b307d837-c0ce-4619-8c5c-70e418ef9693",
    "started_at": "2021-11-02T15:53:28.753Z"
}
```

### New Joiner

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

```json
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
