---
title: Overview
meta_title: Provides an out of the box video solution for low tech users
description: The Meetings API allows you to integrate real-time, high-quality interactive video meetings into your web apps
product: meetings
navigation_weight: 1
---

# Meetings API Overview

The Meetings API allows you to integrate real-time, high-quality interactive video meetings into your web apps.

> You can try out the Meetings API in the [Vonage API Dashboard](https://dashboard.nexmo.com).

## Contents

* [Requirements](#requirements): What you will need to get started.
* [Terminology](#terminology): Key terms and definitions for the Meetings API.
* [Room Types](#room-types): Defines the types of rooms available.
* [Code Snippets](#code-snippets): Code and instructions for using the Meetings API.
* [Reference](#reference): Further information about the Meetings API.

## Requirements

**Vonage Developer Account**: If you don’t have a Vonage account yet, you can get one here: [Vonage Developers Account](https://dashboard.nexmo.com/sign-up).

**Meetings API Activation**: To activate the Meetings API, you need to register with us. Please send an email request to the [Meetings API Team](mailto:meetings-api@vonage.com).

**API Key and Secret**: Once you’re logged in, you'll find your API Key and Secret in your dashboard under "Getting Started".

Key | Description
-- | --
`VONAGE_API_KEY` | Vonage API key which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).
`VONAGE_API_SECRET` | Vonage API secret which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).

## Terminology

* **Room**: the virtual space in which the video meeting takes place. See [Room Types](#room-types) below.
* **Participants**:
  * **Owner**: usually the creator of the room, this person has special administration capabilities.
  * **Guest**: people attending meeting. Guests have access to standard meeting features.
* **Set up and Configuration**:
  * **Request**: the code snippet you submit to set up a room.
  * **Response**: the data that is returned from your request.
  * **Meeting Room ID**: the ``ID`` is a session identifier which is returned in the response to a meeting request.
  * **Session**: defined as all events that occur during this time, from when the first participant joins, until the last to leave.
  * **Guest URL**: meeting room URL used by guests.
  * **Host URL**: meeting room URL with meeting administration capabilities used by the host.
* **Features**:
  * **Chat**: space for sending written messages that are visible to all attendees in the room.
  * **Record**: you can record a meeting either manually during the meeting or automatically when sending a request.
  * **Room Management**: you can delete, update or retrieve information about rooms.
  * **Callbacks**: allow you to receive information about a session.

## Room Types

There are two room types:

* **Instant Room**:
  * Created for a meeting happening now.
  * Active for ten (10) minutes until the first participant joins the room.
      If no one joins the room within the ten minutes, the room is deleted.
  * Active for ten minutes after the last participant leaves, then it is deleted.
* **Long Term Room**:
  * Remains alive until the expiration date you specify (maximum five years).
  * Typically linked to a recurring meeting, person, or resource.
  * Will require you to specify an expiration date (in UTC format).
  * Enables you to request that a room is automatically deleted ten minutes after the last participant leaves the room.

## Code Snippets

* [Create an Instant Room](code-snippets/create-instant-room)
* [Create a Long Term Room](code-snippets/create-long-term-room)
* [Meeting Room Management](code-snippets/room-management)
* [Callbacks](code-snippets/callbacks)

## Reference

* [Meetings API Reference](/api/meetings)
