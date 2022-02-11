---
title: Using Dynamic Layouts in HLS/RMTP Broadcasts
description: Find out what layout options are available with the Vonage Video
  API when broadcasting your sessions via HLS and/or RMTP streams.
thumbnail: /content/blog/dynamic-layouts-in-hls-rmtp-broadcasts-with-the-video-api-dr/Blog_Dynamic-Layouts_Video_1200x600.png
author: michaeljolley
published: true
published_at: 2020-09-22T13:00:32.000Z
updated_at: 2021-05-10T22:21:42.299Z
category: tutorial
tags:
  - video-api
comments: true
redirect: ""
canonical: ""
---
The Video API allows you to full control over your user interface when building applications with multi-party video sessions, but what options are available when you need to broadcast those sessions via HLS and/or RTMP streams?

In this post, we'll discuss what built-in layouts are available out-of-the-box, how to create custom layouts of your own, and how to change layouts and stream styles on-the-fly.

> Want to try it out? You can view an example application using the broadcast feature on [GitHub](https://github.com/opentok/broadcast-sample-app). You can also deploy it to Heroku to try out.

## Built-In Layout Types

There are several factors to consider when choosing the best layout for your broadcast. Is someone speaking? Is someone sharing their screen? Is the conversation a panel discussion?

Luckily, the Vonage Video API provides several pre-defined layouts to help you create the best experience for your viewers.

By default, broadcasts use the `bestFit` layout (shown below). This layout changes based on the number of participants and provides every publisher with equal screen real estate.

![bestFit](/content/blog/using-dynamic-layouts-in-hls-rmtp-broadcasts/bestfit.png)

Other options include Picture-in-Picture (`pip`), Vertical Presentation (`verticalPresentation`), and Horizontal Presentation (`horizontalPresentation`).

![Alternative layout options](/content/blog/using-dynamic-layouts-in-hls-rmtp-broadcasts/layout-options.png)

**Update May 2021: New vertical layouts have been added to allow recording or broadcasting in portrait SD and HD resolutions, ideal for mobile devices:**

![Vertical layout to allow recording or broadcasting in portrait resolutions](/content/blog/using-dynamic-layouts-in-hls-rmtp-broadcasts/both.gif)

### New Screen share layout types

[New layout types](https://www.tokbox.com/developer/guides/archive-broadcast-layout/#screen-sharing-layouts) were introduced in May 2021:

* bestFit
* horizontalPresentation
* verticalPresentation
* pip

### Initializing &amp; Changing Layouts

You can specify an initial layout when you start a broadcast. To do so, add a `layout` property containing a `type` property to the request body. This `type` property should correspond to the pre-defined layout you wish to use.

```js
{
  "sessionId": "2_MX44NTQ1MTF--bm1kTGQ0RjVHeGNQZE51VG5scGNzdVl0flB-",
  "layout": {
    "type": "bestFit"
  }
}
```

To change the layout during a live streaming broadcast, use one of the OpenTok server SDKs or call the OpenTok [/broadcast/layout REST API endpoint](https://tokbox.com/developer/rest/#change_live_streaming_layout).

Send a JSON object with a `type` property denoting the layout you need in the body of your request.

```js
{
  "type": "pip"
}
```

But using layouts is only the first step to making your stream look great. The next step is updating class lists for your streams.

Let's use the Vertical Presentation `verticalPresentation` layout as an example. In the image above, you'll notice that the large area contains the word 'focus.' Focus is the name of a class that should be applied to the stream you want to appear in that area.

Whether it's a shared screen, active speaker, or a publisher that you've flagged as the 'presenter,' the stream you want to feature should have the 'focus' class assigned to it and no others. Let's talk about styles and how to apply and modify them.

## Broadcast and Stream Styles

The layout for a broadcast is created in a virtual DOM with the following structure:

```html
<broadcast>
  <stream class="{layoutClassList}" />
  <stream class="{layoutClassList}" />
  <stream class="{layoutClassList}" />
  ...
</broadcast>
```

You'll want to keep this structure in mind as you use the pre-defined layouts or create your custom layouts. By default, the broadcast video is 640x480 pixels, but you can specify the use of 1280x720 when you start the broadcast. In this case, the predefined layouts are adjusted to use a 16:9 aspect ratio.

> Important: Only 16 streams can ever be displayed in a broadcast at one time.

### Changing Styles

The pre-defined layouts supply CSS to control the look and feel of the broadcast. To utilize them, you'll need to specify what classes should apply to which streams. You can change the class list for streams using any of our Server SDKs or via the OpenTok REST API [/session/{sessionId}/stream](https://tokbox.com/developer/rest/#change-stream-layout-classes)
endpoint. Requests to the endpoint would contain a JSON body similar to the below
object:

```js
{
  "items": [
    {
      "id": "8b732909-0a06-46a2-8ea8-074e64d43422", // stream id
      "layoutClassList": ["focus"] // array of classes to apply to the specified stream
    }
  ]
}
```

It's important to notice that the `items` property is an array that allows you to provide details regarding multiple streams in one request. So in the example of using the vertical presentation, you should send the payload above specifying the id of the stream you wish to focus on. If another stream previously had the focus class, you should send it with an empty class list so that the focus class is removed from it.

## Creating Custom Layouts

If one of the pre-defined layouts doesn't meet your needs, you can create a custom layout by sending `custom` as the type and a `stylesheet` property with CSS.

```js
{
  "sessionId": "2_MX44NTQ1MTF--bm1kTGQ0RjVHeGNQZE51VG5scGNzdVl0flB-",
  "layout": {
    "type": "custom",
    "stylesheet": "stream.instructor {position: absolute; width: 100%;  height:50%;}"
  }
}
```

When creating a custom layout, you should consider a few things:

* Default styles applied to the `broadcast` and `stream` elements
* Permitted CSS selectors
* Permitted CSS properties &amp; values

### Default Styles

The `broadcast` and `stream` elements have default rules applied to them. You can
override these styles in your custom CSS. The default rules are:

```css
broadcast {
  position: relative;
  margin:0;
  width: 640px;
  height:480px;
  overflow: hidden;
}
stream {
  display: block;
  margin: 0;
}
```

> Note: The container resolution is fixed and cannot be overridden by CSS.

### Permitted CSS Selectors

Type selectors are only supported for stream elements. The broadcast element cannot be selected. Class selectors (such as .focus) are supported (and preferred.) They can be used to select any group of streams or an individual stream. Adjacent sibling and general sibling combinations are supported (sibling-one + sibling-two, sibling-one ~ sibling-two).

The `:first-child`, `:last-child`, `:nth-child(n)`, and `:nth-last-child(n)` pseudo-class selectors are also supported.

The following selectors are not supported:

* The universal selector (*)
* Descendent selectors (parent ancestor, parent * ancestor)
* Child selectors (parent &gt; child)
* ID selectors (#myidentifier)
* Attribute selectors (\[data-title*="my-title"])
* Pseudo-element selectors are not supported

### Permitted CSS Properties

The following table describes the currently supported CSS properties and their possible values:

| Name                                                         | Value                                                 |
| ------------------------------------------------------------ | ----------------------------------------------------- |
| width, height                                                | positive number ( px/ %)                              |
| min-width, min-height                                        | positive number ( px/ %)                              |
| max-width, max-height                                        | positive number ( px/ %)                              |
| left, right, top, bottom                                     | number ( px/ %)                                       |
| margin, margin-left, margin-right, margin-top, margin-bottom | number ( px/ %)                                       |
| z-index                                                      | positive number                                       |
| position                                                     | 'relative', 'absolute'                                |
| display                                                      | 'inline', 'block', 'inline-block'                     |
| float                                                        | 'none', 'left', 'right'                               |
| object-fit                                                   | 'contain' (the default), 'cover'                      |
| overflow                                                     | 'hidden'                                              |
| clear                                                        | 'none', 'left', 'right', 'both', 'inherit', 'inherit' |

## Continue Learning

Want to learn more about customizing the look of your broadcasts? Check out the links
below:

* [OpenTok Broadcast](https://tokbox.com/developer/guides/broadcast/)
* [Configuring video layout for OpenTok live streaming broadcasts](https://tokbox.com/developer/guides/broadcast/live-streaming/#predefined-layout-types)