---
title: Auto Layout for Vonage Video Application
description: Using opentok-layout-js we can easily render vonage video call
  participants on the screen. This saves time and makes it super simple to build
  video application using vonage video sdk.
thumbnail: /content/blog/auto-layout-for-vonage-video-application/auto-layout_videoapi.png
author: mofi-rahman
published: true
published_at: 2021-11-18T10:29:04.444Z
updated_at: 2021-11-11T15:40:53.817Z
category: tutorial
tags:
  - video-api
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Vonage Video API makes it easier to create our own video chat application with as little as 15 lines of code. To make it look and feel like a proper video chat app we have to do some more work. One challenge is to properly place the participants on the screen. Apps like Zoom, Teams, Google Meet, and Webex all have their own distinct looks. Fundamentally they all accomplish the same goal: place participants on the screen in some form of a grid and rearrange them based on different screen sizes. That's what we will do for our Vonage Video Application today.

Here is an example of what we will be building.

![Screen recording of a demo application where multiple copies of a live webcam video are added to the screen, then the screen dimensions are changed to demonstrate video feeds resizing and layout shift. One video feed is selected and gets larger. Then video feeds are removed one by one.](https://media.giphy.com/media/sJiLXHB3UwDr93Pv6W/source.gif)

## Prerequisite

- Text editor (e.g. [VS Code](https://code.visualstudio.com/))
- Web Browser

## Getting started

The source code for this demo is in [this repo](https://github.com/moficodes/opentok-layout-demo). 

The main ingredient to make our auto layout work is [Opentok Layout JS](https://github.com/aullman/opentok-layout-js). This is an open-source library created by Adam Ullman. 

## Code Deep Dive

The code for this demo is fairly short. There are 4 files in total. Three that we will create (`index.html`, `style.css`, `script.js`) and one (`opentok-layout.js`) that is downloaded from [Opentok Layout JS](https://github.com/aullman/opentok-layout-js) repository. 

### index.html

In the `<head>` section of our HTML file, we add a reference to the Opentok Client Library. It is used for getting access to `OT` which allows us to get camera access. We also include `opentok-layout.js` and our `style.css`.

```html
    <script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
    <script src="js/opentok-layout.js"></script>
    <link rel="stylesheet" href="css/style.css" />
```

In the `<body>`, we add an empty `div` with `id="layout"`. This is the container where we will place all our participant videos. We also have two buttons used for adding and removing videos from our layout.

```html
    <div id="layout"></div>
    <div id="buttons">
      <input
        type="button"
        name="add"
        value="Add"
        id="add"
        onclick="addElement()"
      />
      <input
        type="button"
        name="remove"
        value="Remove"
        id="remove"
        onclick="removeElement()"
      />
    </div>
``` 

Finally, we add a reference to our `script.js` file right after the `</body>` tag.

### style.css

Most of the CSS file is used to place the buttons at the bottom of the screen Which leaves the rest of the screen real estate for the `layout` container. The container has a CSS transition property set to make the layout changes from adding and removing videos look smooth.

### script.js

This is where we initialize and make use of the Opentok Layout JS library. We first create a reference to our layout container, `layoutEl`. Then a `layout` variable is initialized and set to an Opentok Layout JS function that returns when passed in `layoutEl` and some options.

```js
var layoutEl = document.getElementById('layout');
var layout;
```


```js
function updateLayoutValues() {
  const opts = {
    maxRatio: 3 / 2,
    minRatio: 9 / 16,
    fixedRatio: false,
    alignItems: 'center',
    bigPercentage: 0.8,
    bigFixedRatio: false,
    bigMaxRatio: 3 / 2,
    bigMinRatio: 9 / 16,
    bigFirst: true,
    scaleLastRow: true,
    smallMaxWidth: Infinity,
    smallMaxHeight: Infinity,
    bigMaxWidth: Infinity,
    bigMaxHeight: Infinity,
    bigAlignItems: 'center',
    smallAlignItems: 'center',
  };
  layout = initLayoutContainer(layoutEl, opts).layout;
}
updateLayoutValues();
```

There is an explanation of all the `opts` properties and possible values in the Opentok Layout JS [ReadMe](https://github.com/aullman/opentok-layout-js#usage). 

`layout` is called every time we need to reorganize the application's layout when videos are added, removed, or the window resizes.

There are also event listeners for the add and remove buttons. Another event listener is created for when a participant's video is double-clicked which will toggle between enlarging or shrinking the video. 

## Conclusion

This was a quick explanation to showcase how you can achieve a responsive layout for your Vonage Video application.

For an even quicker path to creating a multi-party video application, you can make use of [Vonage Video Express](https://tokbox.com/developer/video-express/). Video Express uses `opentok-layout-js` and wraps our OpenTok Client SDK. You can learn how to use Vonage Video Express with [this article](https://learn.vonage.com/blog/2021/09/27/create-a-multiparty-video-app-with-the-new-video-express/) by Enrico.

If you have any questions or comments, please reach out to us via [Twitter](https://twitter.com/vonagedev) or [Slack](https://developer.nexmo.com/community/slack).


