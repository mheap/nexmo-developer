---
title: Theme Management for Meeting Rooms
navigation_weight: 2
description: Managing Rooms with the Meetings API
---

# Whitelabeling: Theme Management for Meeting Rooms 

Use the themes API to create themes with different colors, logos, or texts. Themes can be applied to one room, a few rooms, or all the meeting rooms in the account. 


## Prerequisites

* **Vonage Developer Account**: If you do not already have one, sign-up for a free account on the [Vonage Developers Account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav).

* **Meetings API Activation**: To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

* **Application ID and Secret**: Once you’re logged in to the [Vonage API Dashboard](https://dashboard.nexmo.com), click on Applications and create a new Application. Click  `Generate public and private key` and record the private key. You'll be using the private key with the Application ID to [Generate a JSON Web Token (JWT)](https://developer.vonage.com/jwt). For further details about JWTs, please see [Authentication](/concepts/guides/authentication).

### Setting Up The Request 

The endpoint for creating a theme is ``https://api-eu.vonage.com/beta/meetings/themes``

**Required Headers:**
- Content Type: ``Content-Type: application/json``
- Authorization: Use the [JWT Generator](https://developer.vonage.com/jwt) to create a JWT from the Application ID and private key of the application. You'll use your JWT to create a [Token Authorization](/concepts/guides/authentication) string that is made up of ``Bearer`` and the JWT you created.

## Create a Theme 

### Body Content

The following fields can be assigned values in the POST request:

Field | Required? | Description |
-- | -- | -- | --| -- |
``them_name`` | Yes | The name of the theme (must be unique). 
``brand_text`` | Yes | The text that will appear on the meeting homepage.
``main_color``| Yes | The main color that will be used for the meeting room.
``short_company_url`` | No | The url that will represent the company's meeting room homepage (must be unique).
``brand_image_colored`` | No | The brand image to be used in the welcome page and on a dark background
``brand_image_white`` | No | The brand image to be used in on a white background
``branded_favicon`` | No | The favicon that will appear in the browser tab 
``brand_image_white_url`` | No | 
``brand_image_colored_url`` | No | 
``branded_favicon_url`` | No | 

### Request 

**The following command will create a theme with orange as the main color and a display text of "Orange". The theme name is used internally and must be unique for each theme.**

```
curl --location --request POST 'https://api-eu.vonage.com/beta/meetings/themes' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer {JWT}' \
--data-raw '{
    "main_color": "#ff6500",
    "brand_text": "Orange",
    "theme_name": "orange-room", 
}'
```

### Response 

```
{
    "theme_id": "49d900c8-372b-4c9e-b682-5601cbdc1f7a",
    "theme_name": "orange-room",
    "domain": "VCP",
    "account_id": "11f1b84f",
    "application_id": "ad725975-941c-4563-bc5e-4bc369f46467",
    "main_color": "#ff6500",
    "short_company_url": null,
    "brand_text": "Orange",
    "brand_image_colored": null,
    "brand_image_white": null,
    "branded_favicon": null,
    "brand_image_white_url": null,
    "brand_image_colored_url": null,
    "branded_favicon_url": null
}
```

Note that only required parameters were set on the room. All null values can be changed on a [theme update](). 

## Add a Theme to a Room 

A theme can be applied to a **Long Term room** upon room creation or update. To apply the theme at room update, you'll need the `theme_ID` and `room_ID`: 

```
curl --location --request PATCH 'https://api-eu.vonage.com/beta/meetings/rooms/{ROOM_ID}' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw '{
    "update_details": {
        "theme_id": "e8b1d80b-8f78-4578-94f2-328596e01387"
        }   
}   
```

Check out [creating a long term room](/_documentation/en/meetings/code-snippets/create-long-term-room.md) to see how it looks in creation. 

## Set Theme as Default

A theme can be set as the default theme for the account, meaning that every room created will automatically use the default theme. To do this, first create a theme, and then use its ID on the `applications` endpoint. 

### Request 

```
curl --location --request PATCH 'https://api-eu.vonage.com/beta/meetings/applications' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw '{
  "update_details": {
    "default_theme_id": "e8b1d80b-8f78-4578-94f2-328596e01387"
  }
}'
```

### Response 

```
{
    "application_id":"3db604ce-b4c0-48f4-8b82-4a03ac9f6bk7",
    "account_id":"69b2a6d2",
    "default_theme_id":"e8b1d80b-8f78-4578-94f2-328596e01387"}
```

## Delete a Theme 

To delete a theme, use a DELETE and the theme ID. However, a theme that is currently in use by any room cannot be deleted, and will result in an error that says: 
`"Theme XXX is used by n rooms"`. 
In order to delete a theme that is in use, you must remove it from each room that is using it by finding all rooms using that theme and removing the theme. 

## Get All Rooms with Given Theme

Sometimes you might want to know which rooms are using a particular theme. For example, before deleting a theme, it must be removed from all rooms which are using it. To retrieve a list of these rooms, you need the theme ID. 

### Request 

```
curl --location --request GET 'https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}/rooms' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw ''
```

This will return a list of all rooms using this theme. 

## Remove Theme From Room 

In order to remove a theme from a room, update the room using a PATCH and the room ID, and pass `null` as the theme ID in `update_details`. Please note that only long_term rooms can be updated. 

### Request 

```
curl --location --request PATCH 'https://api-eu.vonage.com/beta/meetings/rooms/{ROOM_ID}' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw '{
    "update_details": {
        "theme_id": null
        }   
}'
```