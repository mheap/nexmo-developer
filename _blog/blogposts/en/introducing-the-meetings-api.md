---
title: Introducing the Meetings API
description: The quickest path to a video meeting that Vonage has to offer
thumbnail: /content/blog/introducing-the-meetings-api/intro-to-meetings-api.png
author: avital-tzubelivonage-com
published: true
published_at: 2022-03-29T15:26:31.727Z
updated_at: 2022-03-29T15:26:31.761Z
category: release
tags:
  - video-api
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
If you need an integrated video solution in your applications but don't have time or resources to build out video capabilities, then the Meetings API is right for you! It allows you to add real-time, high-quality interactive video meetings into your Web Apps with only a few lines of code. 

## How Does It Work?

Using the API, you can generate *rooms*, which are fully-fledged Vonage meetings that come pre-built with features like messaging, recording, screen sharing, and a handful of other collaborations tools. 
The API also allows for *Whitelabeling*, which means that with the Themes endpoint you can customize the colors and logos that will be displayed in your meeting rooms. Finally, with configured callbacks, you can view details about the meeting, such as when participants joined and recording information. 

![Screenshot of new Meetings API session in progress](/content/blog/introducing-the-meetings-api/meetings.jpeg)

## Instant and Long Term Rooms

The API allows the creation of two types of rooms: 

* An **Instant Room** (or the default room), which is created for meetings happening now, and is active for ten minutes until the first participant joins the room, and for ten minutes after the last participant leaves. 
* A **Long Term Room**, which remains alive until the specified expiration date (the maximum is one year). This room is typically linked to a recurring meeting, person, or resource. 

To use the API, you need to authorize the request with a JSON Web Token. To learn more, visit the Meetings API [Documentation](https://developer.vonage.com/meetings/overview). 

### Create an Instant Room

```curl
   curl -X POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
   -H 'Authorization: Bearer XXXXX' \
   -H 'content-type: application/json' \
   -d '{
   "display_name":"New Meeting Room"
               }'
```

#### Response

```curl
{
    "id": "ec1021f3-df34-4153-b7cb-aedd0f974405",
    "display_name": "My New Room",
    "metadata": null,
    "type": "instant",
    "expires_at": "2022-03-29T08:01:18.513Z",
    "recording_options": {
        "auto_record": false
    },
    "meeting_code": "641766519",
    "_links": {
        "host_url": {
            "href": "https://meetings.vonage.com/?room_token=641766519&participant_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjA3YTA5MmFmLTE5YWUtNDg5Ny05NzQ1LWI2YjJkNjk5N2YyMSJ9.eyJwYXJ0aWNpcGFudElkIjoiZWU0ZjRkMmQtMzEwMy00YjVmLThhYzgtYTY2NjgxMmU4ZGViIiwiaWF0IjoxNjQ4NTQwMjc4fQ.AhrsWT1tSWEjoN0xDAMjVrEMRmvBMcwUWyhsa4yLCrg"
        },
        "guest_url": {
            "href": "https://meetings.vonage.com/641766519"
        }
    },
    "created_at": "2022-03-29T07:51:18.514Z",
    "is_available": true,
    "expire_after_use": false,
    "theme_id": null,
    "initial_join_options": {
        "microphone_state": "default"
    }
}
```

In the code above, we've created an Instant Meeting Room, and you can see that the response contains both host and guest URLs, which lead straight to a meeting room. You'll also notice that theme_id is null, because we haven't added a theme, and that auto_record is false, which means that the recording won't begin automatically when the room opens. 

### Create a Long Term Room

This creation requires a type of `long_term` and the expiration date in ISO format. 
We will also set auto-recording to true, which means that the recording will start as soon as the session is started. 

```curl
   curl -X POST 'https://api-eu.vonage.com/beta/meetings/rooms' \
   -H 'Authorization: Bearer XXXXX' \
   -H 'content-type: application/json' \
   -d '{
    "display_name":"New Meeting Room",
    "type": "long_term",
    "expires_at": "2022-04-28T14:20:20.462Z",
    }'
```

## Themes (Whitelabeling)

The themes API can be used to create themes with different colors, logos, or texts. These themes can then be applied to one room, a few rooms, or all the meeting rooms in the account. 

The styles of the theme affect the welcome page of the meeting, as well as the color scheme within the meeting. 

### Create a Theme

```curl
curl -X POST 'https://api-eu.vonage.com/beta/meetings/themes' \
--header 'Authorization: Bearer XXXXX' \
--header 'Content-Type: application/json' \
--data-raw '{
    "main_color": "#ff6500",
    "brand_text": "Orange",
    "theme_name": "Blog-orange", 
    "short_company_url": "orange"
}'
```

#### Response

```
{
    "theme_id": "b74abfe5-5493-4b3e-b527-642d2484b5e8",
    "theme_name": "Blog-orange",
    "domain": "VCP",
    "account_id": "11f1b84f",
    "application_id": "ad725975-941c-4563-bc5e-4bc369f46467",
    "main_color": "#ff6500",
    "short_company_url": "blog-orange",
    "brand_text": "Orange",
    "brand_image_colored": null,
    "brand_image_white": null,
    "branded_favicon": null,
    "brand_image_white_url": null,
    "brand_image_colored_url": null,
    "branded_favicon_url": null
}
```

As seen in the response, different colors and logos can be set for light or dark mode.
Once the theme ID is applied to a room (by setting `theme_id` on creation or update), the meeting room will look like this: 

![Screenshot of new orange blog theme applied](/content/blog/introducing-the-meetings-api/orange-theme.png)

## Callbacks

If you've configured callbacks on your account, you'll receive notifications about various events happening in your meeting rooms, such as: 

* Room expiration
* Participant attendance
* Recording events
* Recording URL

### Some payload examples:

```json
{
    "event": "session:started",
    "session_id": "2_MX40NjMzOTg5Mn5-MTYzNTg2ODQwODY4NH41cXIzMDdSa1BZa05BUDFpYnhxcTV4MCt-fg",
    "room_id": "b307d837-c0ce-4619-8c5c-70e418ef9693",
    "started_at": "2022-03-02T15:53:28.753Z"
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
    "is_host": false
}
```

## Resources

To learn more about room management, callbacks, recording management, and configuring your themes, visit [the Meetings API Documentation](https://developer.vonage.com/meetings/overview).

Once you've configured your account, free free to try out the API, create some rooms, play around and tell us what you think!
To set up your account and configure callbacks, email us at meetings-api@vonage.com
