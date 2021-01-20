---
title: Push Notification Payload
description: This topic shows you an example of the push notification payload send to the Client SDK.
navigation_weight: 9
---

# Push Notification Payload Example

This is an example of the push payload that is send to the Client SDK from Vonage. The key part to your application being in the `push_info` object. 

```json
{
  "application_id": "e2dd57b5-5071-4506-8827-8efa5b96fc9d", // Your Vonage Application ID
  "timestamp": "2021-01-06T17:18:19.093Z",
  "user_id": "USR-6c38a318-a24d-43c4-a667-563696416040",
    "push_info": { // Information for the push notification
    "conversation": {
      "name": "NAM-23c60ce9-77b4-4c99-aaec-cd1ad6cc0e31"
    },
    "from_user": { // Information about the user calling
      "channels": {},
      "name": "Alice",
      "user_id": "USR-6c38a318-a24d-43c4-a667-563696416040"
    },
    "priority": "immediate",
    "to_user": { // Information about the user being called
      "channels": {},
      "name": "Bob",
      "user_id": "USR-6c38a318-a24d-43c4-a667-563696416040"
    }
  },
  "body": { // The body of the event, similar to the one sent to your Vonage Application's Event URL
    "channel": {
      "cpa": 0,
      "cpa_time": 0,
      "from": {
        "headers": {},
        "number": "Unknown",
        "type": "phone"
      },
      "legs": {},
      "max_length": 0,
      "preanswer": 0,
      "ring_timeout": 0,
      "to": {
        "type": "app",
        "user": "Bob"
      },
      "type": "app"
    },
    "cname": "NAM-23c60ce9-77b4-4c99-aaec-cd1ad6cc0e31", 
    "conversation": {
      "conversation_id": "CON-b24b963a-c50c-46b9-ac26-871d408f2f7c", // Your conversation name
      "name": "NAM-23c60ce9-77b4-4c99-aaec-cd1ad6cc0e31" // Your conversation ID
    },
    "initiator": {
      "invited": {
        "isSystem": 1
      }
    },
    "invited_by": "<null>",
    "media": {
      "audio": {
        "earmuffed": 0,
        "enabled": 1,
        "muted": 0
      },
      "audio_settings": {
        "earmuffed": 0,
        "enabled": 1,
        "muted": 0
      }
    },
    "timestamp": {
      "invited": "2021-01-06T17:18:19.091Z"
    },
    "user": {
      "media": {
        "audio": {
          "earmuffed": 0,
          "enabled": 1,
          "muted": 0
        },
        "audio_settings": {
          "earmuffed": 0,
          "enabled": 1,
          "muted": 0
        }
      },
      "member_id": "MEM-08b07065-1d83-4bc7-b953-af7fb4dd3f5d",
      "name": "Bob",
      "user_id": "USR-6c38a318-a24d-43c4-a667-563696416040"
    }
  },
  "channels": {},
  "conversation_id": "CON-b24b963a-c50c-46b9-ac26-871d408f2f7c",
  "event_type": "member:invited", // The event type (https://developer.nexmo.com/conversation/concepts/event)
  "from": "MEM-08b07065-1d83-4bc7-b953-af7fb4dd3f5d",
  "id": 8,
  "name": "Bob"
}
```



## Further information
* [More about push notifications](/client-sdk/setup/set-up-push-notifications)
* [In-app Voice tutorial](/client-sdk/tutorials/phone-to-app/introduction)
