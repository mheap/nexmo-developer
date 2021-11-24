---
title: Reconnect a call or media
description: How to reconnect a call or conversation's media.
navigation_weight: 8
---

# Reconnect a Call or Conversation's Media

## Overview

This guide covers how to reconnect to a call or a conversation's media in your Android and iOS Vonage Client application.

### Automatically Reconnect

The Client SDK can attempt to automatically reconnect to a call or a conversation's media if you set the client's `autoReoffer` configuration property. This is useful for when there is a short drop in internet connectivity or the user switches between cellular and WiFi.

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/reconnect-call/automatically-reconnect'
frameless: false
```

### Listening for Call Status Changes

To know when the status of a call or conversation's media has changed you can listen for media status events with the Android and iOS SDK. Note the disconnected state. A disconnected state means that there has been a temporary network issue and the client will attempt a reconnection providing the `autoReoffer` configuration property is set. If you did not set `autoReoffer` to `true` then you can manually reconnect here. 

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/reconnect-call/status'
frameless: false
```

### Manually Reconnect

The Client SDK has functions for explicitly reconnecting a call or conversation's media. This is useful for example when you want to switch which device a user is speaking on without hanging up the call and starting a new one if the application dies.

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/reconnect-call/reconnect'
frameless: false
```
