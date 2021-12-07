---
title: Overview
meta_title: Provides an out of the box video solution for low tech users.
description: The Meetings API allows you to easily integrate real-time, high-quality interactive video meetings into your web apps
product: meetings
navigation_weight: 1
---

# Meetings API Overview

The Meetings API allows you to easily integrate real-time, high-quality interactive video meetings into your web apps.

## Contents

* [Requirements](#requirements). What you will need to get started.
* [Terminology](#Terminology). Key terms and definitions for the Meetings API.
* [Code Snippets](#code-snippets). Code and instructions for using the Meetings API.
* [Reference](#reference). Further information about the Meetings API.

## Requirements

**Vonage Developer Account** If you don’t have a Vonage account yet, you can get one  here: [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

**Meetings API Activation** To activate the Meetings API, you must register. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

**API Key and Secret** Once you’re logged in, you'll find your API Key and Secret in your dashboard under "Getting Started".

Key | Description
-- | --
`VONAGE_API_KEY` | Vonage API key which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).
`VONAGE_API_SECRET` | Vonage API secret which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).

## Terminology

* **Room**: the virtual space in which the video meeting takes place.
* **Owner**: usually the creator of the room; this user has special admin capabilities.
* **Chat**: space for sending written messages that are visible to all attendees in the room.
* **Meeting Room ID**: the ``ID`` is a unique identifier for a room which is returned in the response.
* **Guest URL**: meeting room URL used by the guest.
* **Host URL**: meeting room URL with additional capabilities used by the session host.
* **Session**: the duration in which there are participants present in the room, from the first participant to join, until the last to leave.  
* **Instant Room**: an instant room is created for a meeting happening now. This room lives for **ten (10) minutes** until the first participant joins the room. Once the last participant leaves the room, the room lives for ten more minutes, after which it is deleted.
* **Long Term Room**: a long term room remains alive until expiration date (max five years). It is typically linked to a recurring meeting, person, or resource.
It requires an expiration date (in UTC format), and has the option of automatically deleting the room ten minutes after the last participant leaves the room.
Note that once a room that has been deleted, it will be set to `is_available` = false.

## Code Snippets

* [Create an Instant Room](code-snippets/create-instant-room)
* [Create a Long Term Room](code-snippets/create-long-term-room)
* [Meeting Room Management](code-snippets/room-management)

## Reference

* Link to the Meetings API. **TBA**
