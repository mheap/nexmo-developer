---
title: Vonage JavaScript Client SDK v8 Released
description: Vonage JavaScript Client SDK version 8 release updates and changes.
thumbnail: /content/blog/vonage-javascript-client-sdk-v8-released/blog_sdk-updates_1200x600.png
author: dwanehemmings
published: true
published_at: 2021-07-13T09:10:46.769Z
updated_at: 2021-07-02T16:24:27.131Z
category: release
tags:
  - javascript
  - clientsdk
  - release
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The Vonage JavaScript Client SDK recently published version 8.0. The [release](https://developer.nexmo.com/client-sdk/sdk-documentation/javascript/release-notes) has a few changes and additions that will be covered in this blog post.

## Breaking Changes

There are a couple of changes in what and how data is retrieved. Emitted events now return a subset of the Member Object. This way, it will be easier to access the Member information needed. Here’s an example:

```
conversation.on("any:event", ({memberId, userId, userName, displayName, imageUrl, customData}, event) => {});
```

The `Conversation.members` Map is being deprecated, but don’t worry; the following new functions will be able to get the same data. 

## New functions

Version 8 sees the addition of some new [functions](https://developer.nexmo.com/client-sdk/in-app-messaging/guides/get-member-s-information/javascript).

There is `getMembers()` to get a paginated list of Members of the Conversation. Like with other paginated lists (Events and Conversations), parameters can be set to query the service and get the list of Members.

```
const params = {
    order: "desc", // default "asc"
    page_size: 100 // default 10
}
conversation.getMembers(params).then((members_page) => {
    members_page.items.forEach(member => {
        console.log("Member: ", member);
    })
}).catch((error) => {
    console.error("error getting the members ", error);
});
```

Previously, `Conversation.members.forEach` would have been used to get a list of Members.

To get the information for a particular Member `conversation.members.get("MEM-id")` would have been used. In the JavaScript Client SDK version 8 and from now on, the `getMember("MEM-id")` function takes its place. Pass in the id of the Member, and their Member Object will be returned.

```
conversation.getMember("MEM-id").then((member) => {
    console.log("Member: ", member);
}).catch((error) => {
    console.error("error getting member", error);
});
```

In version 8, you can easily get the local user's Member information in the Conversation from the new `getMyMember()`.

```
conversation.getMyMember().then((member) => {
    console.log("Member: ", member);
}).catch((error) => {
    console.error("error getting my member", error);
});
```

With these changes in the Vonage JavaScript Client SDK v.8, the data needed will be easier to obtain. For more detailed information, please visit the [SDK documentation](https://developer.nexmo.com/sdk/stitch/javascript/index.html). To find tutorials, guides, and more, have a look at the [developer portal](https://developer.nexmo.com/client-sdk/overview).
