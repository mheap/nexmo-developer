---
title: Release Notes
description: Release notes. A list of most important fixes and new features for Client SDK.
navigation_weight: 0
---

# Release Notes

## 4.3.1  - 2022-05-09

### Fix

- Fix `[NXMConversation sendMessage:message completionHandler:handler]` for `NXMMessageTypeImage`, `NXMMessageTypeAudio`, `NXMMessageTypeVideo` and `NXMMessageTypeFile` message types.


## 4.3.0  - 2022-04-28

### Added

- `pushNotificationTTL` property added to `NXMClientConfig` to set TTL for push notifications.
- `[NXMConversation sendMarkDeliveredMessage:message completionHandler:handler]` method added to send delivery receipts.
- `[NXMConversation sendMarkSeenMessage]` now supports seen status for all messages.
- `NXMMessageStatusTypeSubmitted`, `NXMMessageStatusTypeRejected`, `NXMMessageStatusTypeUndeliverable` states added to `NXMMessageStatusEvent`


## 4.2.1  - 2022-04-06

### Fixed

- `[NXMClient uploadAttachmentWithType:name:data:completionHandler:]` method to upload attachments returns with image data

## 4.2.0  - 2022-03-24

### Added

- Support for `call:transfer` within `NXMCall`
- `[NXMCallDelegate call:didTransfer:event:]` to receive new call transfer event when call transferred to a new conversation.

### Enhancements

- WebRTC dependency upgraded to version `84.0.22`.

## 4.1.0  - 2022-02-25

### Added

- `[NXMClient getDeviceId]` to retrieve device identifier.

## 4.0.6  - 2022-02-15

### Fixed

- Fix DSYM Warnings

## 4.0.5  - 2022-02-15

### Added

- Bitcode Support

## 4.0.4  - 2022-01-14

### Fixed

- Inbound call event processing queue defaults to non suspended

## 4.0.3  - 2021-12-13

### Fixed

- Umbrella header.

## 4.0.2  - 2021-12-07

### Fixed

- CocoaPods dependencies.

## 4.0.0  - 2021-12-06

### Added

- `[NXMConversation sendMessage:completionHandler:]` method to send `NXMMessage`.
- `[NXMClient uploadAttachmentWithType:name:data:completionHandler:]` method to upload attachments.
- `NXMMessage` represents a message to send.
- `NXMMessageType` for messages of type `text`, `image`, `audio`, `video`, `file`, `template`, `vcard` and `custom`.
- `NXMEventTypeMemberMessageStatus`, a new `NXMEventType` case, represents a member message status event that can be received on an `NXMConversation`.

### Enhancements

- WebRTC dependency upgraded to version `84.0.0`.
- Enforce direction for `NXMCallMemberStatus` during calls.

### Changed

- `NXMDirectionType` renamed to `NXMChannelType`.

### Deprecated

- `[NXMConversation sendText:completionHandler:]` method.
- `[NXMConversation sendAttachmentWithType:name:data:completionHandler:]` method.

## 3.3.0 - 2021-11-22

### Added

- `NXMClientConfig`'s `apiPinning` and `websocketPinning` optional fields to enable HTTP and web-socket SSL pinning.
- `[NXMPinningConfig fromPublicKeys:]` method to create a public-key-based pinning configuration.
- `NXMConnectionStatusReasonSSLPinningError` describing a client connection update due to an SSL pinning error.

### Changed

- Minimum supported iOS version (`IPHONEOS_DEPLOYMENT_TARGET`) bumped to `10.3`.

## 3.2.1 - 2021-11-08

### Fixed

- Stash events while conversation is downloading to avoid missed events

## 3.2.0 - 2021-10-19

### Added

- `NXMClientConfig.autoMediaReoffer` to allow to automatically reconnect media when network interfaces changes.
- `[NXMClientConfig description]` for a quick `NXMClientConfig`'s instance description.
- `NXMMediaConnectionStatus` enumerate.
- `[NXMConversationDelegate conversation:onMediaConnectionStateChange:legId:]` to receive media connection state changed notification.
- `[NXMConversation reconnectMedia]` to trigger a media reconnection.
- `[NXMClient reconnectCallWithConversationId:andLegId:completionHandler:]` to reconnect a call given a conversation id and a leg id.
- `NXMCall.conversation` to get the conversation associated to a call.

### Deprecated

- `[NXMClientConfig initWithApiUrl:websocketUrl:ipsUrl:]`.
- `[NXMClientConfig initWithApiUrl:websocketUrl:ipsUrl:iceServerUrls:]`.
- `[NXMClientConfig initWithApiUrl:websocketUrl:ipsUrl:useFirstIceCandidate:]`.
- `[NXMClientConfig initWithApiUrl:websocketUrl:ipsUrl:iceServerUrls:useFirstIceCandidate]`.

## 3.1.0 - 2021-09-06

### Added

- `[NXMClient inAppCallWithCallee:completionHandler:]` method to perform in-app calls.
- `[NXMClient serverCallWithCallee:customData:completionHandler:]` method to perform server calls, optionally specifying `customData`.

### Enhancements

- Internal API calls optimized for conversation creation.

### Deprecated

- `[NXMClient call:callHandler:completionHandler:]` method.
- `NXMCallHandler` enumerate.
- `[NXMLogger getLogFileNames]` method.

## 3.0.1 - 2021-07-12

### Fixed

- Sending DTMF during calls.
- Prewarmed media termination.

### Changed

- `NXMMemberEvent`'s `member` substituted with `memberId`.

## 3.0.0 - 2021-07-01

### Added

- Added `NXMMemberSummary` returned by `[NXMConversation getMembersPageWithPageSize:order:completion:]` (paginated), representing a subset of member's information.
- Added `NXMMemberEvent`'s `invitedBy` that represents the inviter name, if exists.
- Added `NXMEventEmbeddedInfo` to all events returned by `NXMEvent`'s `embeddedInfo` and containing the `NXMUser` linked to the event.
- Added `[NXMConversation getMemberWithMemberUuid:completion:]` returning the member given its identifier.

### Enhancements

- Allow 1K members on a conversation.
- Improved `callServer` setup time by pre-warming leg.
- Disabled media after RTC hangup event.
- Fixed text typing events handling.

### Breaking changes

- Removed `NXMCallMember`, replaced with `NXMMember`.
- Removed `NXMCallMember`'s `status`, moved to `[NXMCall callStatusForMember:member:]`.
- Removed `[NXMCallMember mute:]` converted into `[NXMMember enableMute]` and `[NXMMember disableMute]`.
- Removed `NXMConversation`'s `allMembers` (replaced with `[NXMConversation getMembersPageWithPageSize:order:completion:]` (paginated)).
- Removed `[NXMConversationUpdateDelegate conversation:didUpdateMember:withType:]`, replaced with `[NXMConversationDelegate conversation:didReceiveMemberEvent:]` with the following possible states: `NXMMemberStateInvited`, `NXMMemberStateJoined` and  `NXMMemberStateLeft`. Can be subscribed to using `NXMConversation`'s `delegate`.
- Renamed `NXMCall`'s `otherCallMembers` to `allMembers`.
- Renamed `NXMCall`'s `myCallMember` to `myMember`.
- The `legs` endpoint should be included in `acl` paths on `JWT` token creation.

```json
"acl": {
  "paths": {
    ...,
    "/*/legs/**": {}
  }
}
```

## 2.5.0 - 2020-11-23

### Changed

- Renamed `NXMCallMemberStatusCanceled` to `NXMCallMemberStatusCancelled`.
- Renamed `NXMLegStatusCanceled` to `NXMLegStatusCancelled`.

### Enhancements

- Notified with `NXMCallMemberStatusCancelled` on `NXMCallDelegate` for call hang up.

## 2.4.0 - 2020-09-24

### Added

- Expose the reason `NXMConnectionStatusReasonTokenExpired` on connection status `NXMConnectionStatusDisconnected` for the `NXMClientDelegate`.

## 2.3.0 - 2020-08-17

### Added

- `[NXMClientConfig AMS]` static method.

### Fixed

- Custom events parsing.

## 2.2.2 - 2020-07-20

### Fixed

- Event syncing after socket disconnection.

## 2.2.1 - 2020-07-06

### Fixed

- Server-call error reported by `NXMCallDelegate` on call completion.

### Enhancements

- Improved call events handling.
- Improved conversation expiration handling.

## 2.2.0 - 2020-04-22

### Added

- Added `isConnected` method to `NXMClient` to show current connection state.

```objective_c
[NXNClient.shared isConnected]
```

### Fixed

- API Event `client_ref` handling.

## 2.1.10 - 2020-04-16

### Enhancements

- Improved single ICE candidate gathering implementation.

## 2.1.9 - 2020-04-14

### Fixed

- `NXMClientConfig` convenience initializer implementations.

## 2.1.8 - 2020-04-02

### Added

- Add `useFirstIceCandidate` parameters to `NXMClientConfig`

```objective_c
NXMClientConfig *config = [[NXMClientConfig alloc] initWithApiUrl:restUrl
                                                     websocketUrl:wsUrl
                                                           ipsUrl:ipsUrl
                                             useFirstIceCandidate:NO];
```

## 2.1.5 - 2020-03-18

### Enhancements

- Updated Device Registration format for production environments.

## 2.1.1 - 2020-03-05

### Added

- `NXMClient`'s `getConversationsPageWithSize:order:filter:completionHandler:` method to get conversations with paging.

### Deprecated

- `NXMClient`'s `getConversationsPageWithSize:order:completionHandler:` method to get conversations with paging.

### Enhancements

- The Client SDK is now built with Xcode 11.

## 2.1.0 - 2020-01-31

### Added

- `NXMPushPayload` for custom push notifications.

```objective_c
 if (NXNClient.shared isNexmoPushWithUserInfo:pushInfo]){
    NXMPushPayload *pushPayload = [myNXNClient processNexmoPushPayload:pushInfo];
    if (!pushPayload){
        // "Not a Nexmo push!!"
        return;
    };

    if (pushPayload.template == NXMPushTemplateCustom) {
        // Got custom push
        pushPayload.customData // your customData
    }
 }
```

## 2.0.0 - 2020-01-15

### Added

- `NXMHelper` with `descriptionForEventType:` method.
- `NXMConversation`'s `getEvents:` method replaced by `getEventsPage:`, `getEventsPageWithSize:order:completionHandler:`, `getEventsPageWithSize:order:eventType:completionHandler:`.

```objective_c
[myNXMConversation getEventsPagePageWithSize:15
                                       order:NXMPageOrderDesc
                                   eventType:nil
                           completionHandler:^(NSError * _Nullable error, NXMEventsPage * _Nullable page) {
                               if (error || !page) {
                                   // handle error...
                                   return;
                               }

                               // use page...
                           }];
```

- `NXMConversationsPage`'s `nextPage:` and `previousPage:` completion handlers are now non-null.

### Fixed

- Calling `conversation.getEvents` returned a `NXMMemberEvent` with the field `member` set to `nil`.

## 1.2.3 - 2019-12-17

### Fixed

- `conversation.getEvents` returned some `NXMEvent`s containing a nil `fromMember`
- Added descriptive `userInfo` for `NXMError`s.

## 1.2.2 - 2019-12-12

### Fixed

- Added support for DTLS in WebRTC.
- `didReceiveCall` and `didReceiveConversation` being called only once for the same call or conversation.
- Added option to enable push notification with only one `pushKit` or `userNotification` token.
- Fix for `NXMClientConfig` region URLs.
- On login with invalid user, return `NXMConnectionStatusReasonUserNotFound`.
- Added build architectures: `armv7` and `armv7s`.

## 1.2.1 - 2019-12-05

### Added

Configuration for ICE server:

```objective_c
NXMClientConfig *config = [[NXMClientConfig alloc] initWithApiUrl:restUrl
                                                     websocketUrl:wsUrl
                                                           ipsUrl:ipsUrl
                                                    iceServerUrls:iceUrls];
[NXMClient setConfiguration:config];
```

This configuration is optional and a default will be set if not specified.

> Note: `setConfiguration` should be used before accessing `NXMClient.shared`.

### Fixed

Corrected `nil` values for `fromMember` for `NXMConversation` events.

## 1.2.0 - 2019-12-03

### Added

`NXMClient`'s `getConversationsPageWithSize:order:completionHandler:` method to get conversations with paging.

`NXMConversationsPage`, which represents the retrieved page, provides the following instance methods:

- `hasNextPage` / `hasPreviousPage` to check if forward/backward page retrieval is possible and
- `nextPage:` / `previousPage:` to asynchronously retrieve the next/previous page.

### Changed

`NXMClient`'s `getConversationWithUUid:completionHandler:` method's name typo (now called `getConversationWithUuid:completionHandler:`).

## 1.1.1 - 2019-11-21

### Added

`NXMClientConfig` object in order to change data center configuration. How to use:

```objective_c
[NXMClient setConfiguration:NXMClientConfig.DC];
```

`NXMClient setConfiguration` is optional, configuration will set to a default value.

> Note: you must call `setConfiguration` method before using `NXMClient.shared`.

## 1.1.0 - 2019-11-14

### Fixed

- iOS 13 push notifications support.
- Start server call stability.
- Receiving a DTMF event in call and conversation.

### Added

`NXMConversationDelegate` did receive DTMF event method:

```objective_c
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveDTMFEvent:(nullable NXMDTMFEvent *)event;
```

### Changed

`NXMClient` - client enable push notifications method changed.
`param pushKitToken` - only for VoIP push (incoming calls).
`param userNotificationToken` - all push types:

```objective_c
- (void)enablePushNotificationsWithPushKitToken:(nullable NSData *)pushKitToken
                          userNotificationToken:(nullable NSData *)userNotificationToken
                                      isSandbox:(BOOL)isSandbox
                              completionHandler:(void(^_Nullable)(NSError * _Nullable error))completionHandler;
```

## 1.0.0 - 2019-09-05

### Fixed

- `NexmoClient` when disconnected returns error callback for all function.
- `CallMember` status calculated by the current leg status.
- `CallMember` supports failed, busy, timeout and canceled statuses.
- Supports member invited.
- `Conversation` has media methods.
- `NexmoClient` is now singleton.
- Call method changed to string instead of array.
- `NexmoClient` delegate methods renamed.

### Added

- Added conversation media:

```objective_c
NXMConversation myConversation;
[myConversation enableMedia];   // my media will be enabled
[myConversation disableMedia];  // my media will be disabled
```

- Added invite member:

```objective_c
NXMConversation myConversation;
[myConversation inviteMemberWithUsername:@"someUsername"
                              completion:myCompletionBlock];
```

- Added the member state initiator:

```objective_c
NXMMember *member = someMember;
NSDictionary<NSValue *, NXMInitiator *> *initiators = member.initiators;

NXMInitiator leftStateInitiator = initiators[NXMMemberStateLeft];
leftStateInitiator.isSystem;
leftStateInitiator.userId;
leftStateInitiator.memberId;
leftStateInitiator.time;
```

- Added `NXMConversationUpdateDelegate` to notify on member updates like media,leg, and state.
- Added `updatesDelegate` property to `NXMConversation`:

```objective_c
@property (nonatomic, weak, nullable) id <NXMConversationUpdateDelegate> updatesDelegate;
```

Example:

```objective_c
@interface MyClass() <NXMConversationUpdateDelegate>
@implementation MyClass

- (void)setConversation:(NXMConversation *conversation) {
    conversation.updatesDelegate(self); // register to conversation updatesDelegate
}

- (void)conversation:(nonnull NXMConversation *)conversation didUpdateMember:(nonnull NXMMember *)member withType:(NXMMemberUpdateType)type {
    if (type == NXMMemberUpdateTypeState) {
        // the member state changed
    }

    if (type == NXMMemberUpdateTypeMedia) {
        // the member media changed
    }
}
@end
```

### Changed

- `NXMClient` is now a singleton:

```objective_c
NXMClient.shared // the shared instance of NXMClient
```

- Renamed:

```objective_c
@property (nonatomic, readonly, nullable, getter=getToken) NSString *authToken; // was token

// was - (void)login;
- (void)loginWithAuthToken:(NSString *)authToken;

// was - (void)refreshAuthToken:(nonnull NSString *)authToken;
- (void)updateAuthToken:(nonnull NSString *)authToken;

// was callees array
- (void)call:(nonnull NSString *)callee
    callHandler:(NXMCallHandler)callHandler
    delegate:(nullable id<NXMCallDelegate>)delegate
  completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion;
completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completionHandler;
```

- `NXMClientDelegate` renamed:

```objective_c
@protocol NXMClientDelegate <NSObject>

// was - (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason;
- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason;

// was - (void)incomingCall:(nonnull NXMCall *)call;
- (void)client:(nonnull NXMClient *)client didReceiveCall:(nonnull NXMCall *)call;

// was - (void)incomingConversation:(nonnull NXMConversation *)conversation;
- (void)client:(nonnull NXMClient *)client didReceiveConversation:(nonnull NXMConversation *)conversation;
@end
```

- `NXMConversation` `otherMembers` property renamed to `allMembers`:

```objective_c
NXMConversation myConversation = someConversation;
NSArray<NXMMember *> * allMembers = myConversation.allMembers // return the all conversation members

- (void)joinMemberWithUsername:(nonnull NSString *)username // username instead of userId
```

- `NXMConversationDelegate` renamed methods:

```objective_c
// was - (void)customEvent:(nonnull NXMCustomEvent *)customEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveCustomEvent:(nonnull NXMCustomEvent *)event;

// was - (void)textEvent:(nonnull NXMMessageEvent *)textEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveTextEvent:(nonnull NXMTextEvent *)event;

// was - (void)attachmentEvent:(nonnull NXMMessageEvent *)attachmentEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveImageEvent:(nonnull NXMImageEvent *)event;

// - (void)messageStatusEvent:(nonnull NXMMessageStatusEvent *)messageStatusEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMessageStatusEvent:(nonnull NXMMessageStatusEvent *)event;

// was - (void)typingEvent:(nonnull NXMTextTypingEvent *)typingEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveTypingEvent:(nonnull NXMTextTypingEvent *)event;

// was - (void)memberEvent:(nonnull NXMMemberEvent *)memberEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMemberEvent:(nonnull NXMMemberEvent *)event;

// was - (void)legStatusEvent:(nonnull NXMLegStatusEvent *)legStatusEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveLegStatusEvent:(nonnull NXMLegStatusEvent *)event;

// was - (void)mediaEvent:(nonnull NXMEvent *)mediaEvent;
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMediaEvent:(nonnull NXMMediaEvent *)event;
```

- Use `username` instead of `userId`.

- `NXMCallDelegate` renamed:

```objective_c
// was - (void)statusChanged:(nonnull NXMCallMember *)callMember;
- (void)didUpdate:(nonnull NXMCallMember *)callMember status:(NXMCallMemberStatus)status;
- (void)didUpdate:(nonnull NXMCallMember *)callMember muted:(BOOL)muted;

// was - (void)DTMFReceived:(nonnull NSString *)dtmf callMember:(nonnull NXMCallMember *)callMember;
- (void)didReceive:(nonnull NSString *)dtmf fromCallMember:(nonnull NXMCallMember *)callMember;
```

- `NXMEvent` and `NXMMemberEvent` add member object instead of `memberId`:

```objective_c
@property (nonatomic, readonly, nonnull) NXMMember *member;
```

- `NXMImageInfo` renamed properties:

```objective_c
@property NSInteger sizeInBytes; // was size
@property NXMImageSize size; // was type
```

- `NXMMessageStatusEvent` renamed property:

```objective_c
@property NSInteger referenceEventId; // was refEventId
```

- `NexmoClient` logger exposed - `NXMLogger` object:

```objective_c
[NXMLogger setLogLevel:NXMLoggerLevelDebug];
NSArray *logNames = [NXMLogger getLogFileNames];
```

### Removed

- `NXMLoggerDelegate`

```objective_c
NXMClient myClient = ...;
[myClient setLoggerDelegate:LoggerDelegate];
```

## 0.3.0 - 2019-06-03

### Added

- Interoperability with the JS and Android SDKs - Calls can now be placed between apps using the iOS, JS or Android SDKs.

### Changed

- `NXMCallMember` - added member channel with direction data:

```objective_c
@interface NXMCallMember : NSObject
...
@property (nonatomic, readonly, nullable) NXMChannel *channel;
...
@end
```

```objective_c
@interface NXMChannel : NSObject

@property (nonatomic, readonly, nonnull) NXMDirection *from;
@property (nonatomic, readonly, nullable) NXMDirection *to;

@end
```

```objective_c
@interface NXMDirection : NSObject

@property (nonatomic, assign) NXMDirectionType type;
@property (nonatomic, copy, nullable) NSString *data;

@end
```

### Removed

- `NXMCallMember`'s `phoneNumber` and `channelType` were removed.

## 0.2.56 - 2019-01-24

### Added

- Change log file.

### Changed

- Memory management improvements.
- Fetch missing and new events on network changes.
- Returning User objects instead of Ids.
- Bug fixes.
- Add `non-null` or `nullable` to properties.
- Rename `call.decline` to `call.reject`.

## 0.1.52 - 2019-01-01

- Initial beta release with basic call and chat features.

- Please refer to list of features and usage: <https://developer.nexmo.com/>
- **Cocoapods**: <https://cocoapods.org/pods/nexmoclient>


