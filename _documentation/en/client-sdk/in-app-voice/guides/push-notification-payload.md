---
title: iOS Push Notification Payload
description: This topic shows you example push notification payloads sent to the iOS Client SDK.
navigation_weight: 9
---

# iOS Push Notification Payload Example

These are examples of the push payload that are sent to the iOS Client SDK from Vonage.

## VoIP Push Payload example

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
      "conversation_id": "CON-b24b963a-c50c-46b9-ac26-871d408f2f7c", // Your conversation ID
      "name": "NAM-23c60ce9-77b4-4c99-aaec-cd1ad6cc0e31" // Your conversation name
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

## Regular Push Payload example

```json
{
    "nexmo": {
    "_embedded": {
        "from_user": {
            "id": "USR-31e15475-9b50-4641-913e-91982f9154d0",
            "name": "Bob"
        }
    },
    "_meta": {
        "checkConversationState": 1
    },
    "application_id": "f69c6f7c-6e60-471c-81c2-b6916c85e527", // Your Vonage Application ID
    "body": { // The body of the message
        "text": "Hello World"
    },
    "channels": {
    },
    "conversation_id": "CON-0e389e0b-4af6-4898-94db-1b980b5b2872", // Your conversation ID
    "event_type": "text",
    "from": "MEM-cab5700b-b546-4568-aaf2-697179d8891b",
    "id": 26,
    "name": "Bob", // Name of the from user
    "push_info": {
        "conversation": { // Conversation name and display name
            "display_name": "push",
            "name": "NAM-d7d31e1a-e45b-41e7-924a-aadcccff2463",
        },
        "from_user": { // Detailed from user object 
            "channels": {
            },
            "name": "Bob",
            "user_id": "USR-31e15475-9b50-4641-913e-91982f9154d0",
        },
        "priority": "conserve_power",
        "to_user": {
        }
    },
    "timestamp": "2021-06-24T11:59:12.175Z",
    "user_id": "USR-31e15475-9b50-4641-913e-91982f9154d0",
    },
    "aps": {
        "content-available": 1
    }
}
```

## Further information
* [More about push notifications](/client-sdk/setup/set-up-push-notifications)
* [In-app Voice tutorial](/client-sdk/tutorials/phone-to-app/introduction/swift)
* [Chat app tutorial](/client-sdk/tutorials/in-app-messaging/introduction/swift)