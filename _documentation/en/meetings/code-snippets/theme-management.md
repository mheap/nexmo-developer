---
title: Theme Management for Meeting Rooms
navigation_weight: 2
description: Managing Rooms with the Meetings API
---

# Whitelabeling: Theme Management for Meeting Rooms 

Use the themes API to create themes with different colors, logos, or texts. Themes can be applied to one room, a few rooms, or all the meeting rooms in the application. 


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

**POST: `https://api-eu.vonage.com/beta/meetings/themes`**

### Body Content

The following fields can be assigned values in the POST request:

Field | Required? | Description |
-- | -- | -- | --| -- |
``brand_text`` | Yes | The text that will appear on the meeting homepage, in the case that there is no brand image.  
``main_color``| Yes | The main color that will be used for the meeting room.
``theme_name`` | No | The name of the theme (must be unique). If null, a UUID will automatically be generated. 
``short_company_url`` | No | The URL that will represent every meeting room with this theme (must be unique). 

### Request 

The following command will create a theme with orange as the main color and a display text of "Orange". The theme name is used internally and must be unique for each theme.

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

Note that the null values represent the theme images, which can only be added with the (image management process)[#Uploading-Icons-and-Logos], and the URLs that will be generated once those images are uploaded. 

## Update Theme 

**PATCH: `https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}`**

Theme properties that can be updated are the same as those that can be set upon (create)[#create-a-theme]. All images must be added via the (image management process)[#Uploading-Icons-and-Logos].

To update properties, you'll need the theme ID and an object called `update_details`. 

### Request 

```
curl --location --request PATCH 'https://api-eu.vonage.com/beta/meetings/themes/86da462e-fac4-4f46-87ed-63eafc81be48' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw '{
  "update_details": {
    "theme_name": "New-theme",
    "main_color": "#12f64e",
    "brand_text": "New-text",
    "short_company_url": "unique-short-url"
  }
}'
```

## Add a Theme to a Room 

**PATCH: `https://api-eu.vonage.com/beta/meetings/rooms/{ROOM_ID}`**

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

**PATCH: `https://api-eu.vonage.com/beta/meetings/applications`**

A theme can be set as the default theme for the application, meaning that every room created will automatically use the default theme. To do this, first create a theme, and then add it as the `default_theme_id` in an object called `update_details`. 

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
    "default_theme_id":"e8b1d80b-8f78-4578-94f2-328596e01387"
}
```

## Delete a Theme 

**DELETE: `https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}`**

To delete a theme, use a DELETE and the theme ID. However, a theme that is set to default or is currently in use by any room cannot be deleted, and will return an error.

In order to delete a theme that is in use, you must remove it from each room that is using it by finding all rooms using that theme and removing the theme. 

Alternatively, if you wish to override and delete the theme without manually removing it, add a query parameter of `force=true`. The default theme will now be applied to all the rooms that were using this theme. 

```
curl --location --request DELETE 'https://api-eu.vonage.com/beta/meetings/themese/{THEME_ID}?force=true' \
```


## Get All Rooms With Given Theme

**GET: `https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}/rooms`**

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

**PATCH: `https://api-eu.vonage.com/beta/meetings/rooms/{ROOM_ID}`**

In order to remove or replace a theme for a room, update the room by using a PATCH and the room ID. Create an `update_details` object, and pass either `null` or the new theme ID on `theme_id`. Please note that only long term rooms can be updated. 

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

## Uploading Icons and Logos 

The type of images should be uploaded based on the background color. Colored images should be used for a light background, while a lighter image should be used on a dark background. 

**Logo requirements:**
- Format: PNG
- Maximum size: 1MB
- Dimensions: 1 px - 300 px 
- Background must be transparent

**Favicon requirements:**
- Format: PNG
- Maximum size: 1MB
- Dimension: 16 x 16 - 32 x 32 and must be square
- Background must be transparent

In order to add icons and logos to a theme, they first need to be uploaded to the Meetings API AWS bucket, and then paired with the respective theme. 
This will be done in three steps. 

### 1. Retrieve Upload Credentials 

**GET: `https://api-eu.vonage.com/beta/meetings/themes/logos-upload-urls`**

Use a GET on this API to retrieve the credentials needed for upload. The response will contain objects for each favicon, light logo, and colored logo. The `Policy` will be your JWT. Grab the values for the image type you wish to upload. 

#### Response 

```
{
    "url": "https://s3.amazonaws.com/roomservice-whitelabel-logos-prod",
    "fields": {
        "Content-Type": "image/png",
        "key": "auto-expiring-temp/logos/white/a2ef0569-7d2c-4297-b0dd-1af6d8b61be6",
        "logoType": "white",
        "bucket": "roomservice-whitelabel-logos-prod",
        "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
        "X-Amz-Credential": "ASIA5NAYMMB6AP63DGBW/20220410/us-east-1/s3/aws4_request",
        "X-Amz-Date": "20220410T200246Z",
        "X-Amz-Security-Token": XXXXX",
        "Policy": "XXXXX",
        "X-Amz-Signature": "fcb46c1adfa98836f0533aadebedc6fb1edbd90aa583f3264c0ae5bb63d83123"
  }
```

### 2. Upload File to AWS 

**POST: `https://s3.amazonaws.com/roomservice-whitelabel-logos-prod`**

Copy all values from the response above for the image type you with to upload, and paste them in the body of this request. Add the file location as well.

#### Request 

```
curl --location --request POST 'https://s3.amazonaws.com/roomservice-whitelabel-logos-prod' \
--header 'Content-Type: application/json' \
--form 'Content-Type="image/png"' \
--form 'key="auto-expiring-temp/logos/white/a2ef0569-7d2c-4297-b0dd-1af6d8b61be6"' \
--form 'logoType="white"' \
--form 'bucket="roomservice-whitelabel-logos-prod"' \
--form 'X-Amz-Algorithm="AWS4-HMAC-SHA256"' \
--form 'X-Amz-Credential="ASIA5NAYMMB6AP63DGBW/20220410/us-east-1/s3/aws4_request"' \
--form 'X-Amz-Date="20220410T194523Z"' \
--form 'X-Amz-Security-Token="XXXXX"' \
--form 'Policy="XXXXX"' \
--form 'X-Amz-Signature="fcb46c1adfa98836f0533aadebedc6fb1edbd90aa583f3264c0ae5bb63d83123"' \
--form 'file=@"{PATH_TO_FILE}"'
```

This will return a 204 if successful. If you get an error like _"Check your key and signing method"_, check the spaces and formatting of the message body. 


### 3. Add Keys to Theme

**PUT: `https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}/finalizeLogos`**

Use the theme ID of the theme you wish to update, along with the `key` used in the previous step, to link the logo with the theme that you wish to update. You can even make multiple upload calls, and then pass multiple keys to the theme update. 

```
curl --location --request PUT 'https://api-eu.vonage.com/beta/meetings/themes/{THEME_ID}/finalizeLogos' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer XXXXX' \
--data-raw '{
  "keys": [
    "{white-logo-key}",
    "{colored-logo-key}",
    "{favicon-key}"
  ]
}'
```

Once the images are associated with a theme, you'll be able to see their details reflected in the response of a theme GET. The `brand_image_colored`, `brand_image_white` and `branded_favicon` values will contain the AWS Bucket Key, and their respective URLs will point to the image itself. 

## Reference

* [Meetings API Reference](/api/meetings)