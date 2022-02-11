---
title: Getting Started with Web Components
description: Looking at getting started using Web Components? This tutorial has
  interactive examples and code you can modify to see the results in real-time.
thumbnail: /content/blog/getting-started-with-web-components-dr/E_Web-Components_1200x600.png
author: dwanehemmings
published: true
published_at: 2020-03-24T14:13:02.000Z
updated_at: 2021-05-24T22:04:10.432Z
category: tutorial
tags:
  - javascript
  - web-components
comments: true
redirect: ""
canonical: ""
---
JavaScript frameworks and libraries, we can all agree there are a lot of them. Angular, React, Vue, Svelte—the list seems to grow every year. But, what do they all have in common? The answer is that they are used to build applications on the web, and they provide the ability to create reusable components.

What if you could create components based on existing web standards, components that do not depend on the framework or library used to glue everything together into an application? That is where Web Components come in.

## Who is Using Web Components?

Here are a few companies you may have heard of that implement Web Components:

![Company Logos that are using Web Components](/content/blog/getting-started-with-web-components/webcomponents-companies.jpeg "Logos of companies using Web Components. Google, Salesforce, Electronic Arts, Twitter, YouTube and GitHub")

Google: many properties including the AMP web component framework ([source](https://amp.dev))

Salesforce: Lightning Web Components ([source](https://developer.salesforce.com/docs/component-library/documentation/lwc))

Twitter: Embedded Tweets ([source](https://twittercommunity.com/t/upcoming-change-to-embedded-tweet-display-on-web/66215))

GitHub: The “Updated  ago” ([source](https://www.webcomponents.org/community/articles/interview-with-joshua-peek))

YouTube: The site is built using Web Components ([source](https://www.youtube.com/watch?v=VBbejeKHrjg))

## Case Study

Let’s dive deeper into how Electronic Arts (EA) uses Web Components. ([source](https://www.youtube.com/watch?v=FJ2KEvzlyo4))

EA is one of the largest game companies with over 22 studios and 10,000 people in 30 locations all over the world. Needless to say, they release a lot of games (NBA Live, Star Wars, The Sims, Battlefield, etc).

In the beginning, the web team took the approach of designing and developing each game’s website independently, one site at a time. As you can imagine, this leads to a lack of a coherent experience for users browsing all the games EA offers. It was also difficult for the designers and developers working on the sites. They were spending 80% of their time on “Commodity Web”, (i.e. navigation, footers, and media galleries) instead of building custom experiences for each game title. 

To invert that ratio, The Network Design System (NDS) was created. With the NDS, they were able to take the Commodity Web components and add:

* Theming capabilities
* Ability to integrate with any language and framework
* Support for their Micro-site Architecture
* Delivery as a User Interface as a Service (UIaaS)

And you know who else has most likely used Web Components? 

You. Have you ever wondered how is it possible that you can just set the ‘src’ attribute on a `<video>` or `<audio>` and have a fully functional player with buttons, volume control, progress bar, timer, and other options? Web Components.

<video controls src="https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4" poster="https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217" width="620">Sorry, your browser doesn't support embedded videos, but don't worry, you can <a href="https://archive.org/details/BigBuckBunny_124">download it</a> and watch it with your favorite video player!</video>
[source](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video#Examples)

<audio controls src="https://interactive-examples.mdn.mozilla.net/media/examples/t-rex-roar.mp3">Your browser does not support the audio element. </audio>
[source](https://interactive-examples.mdn.mozilla.net/media/cc0-audio/t-rex-roar.mp3)

## An Example

Let’s look at an example that’s just as easy to use, but has a lot more happening behind the scenes—the [model-viewer](https://modelviewer.dev/) Web Component developed by Google.

Here is the code needed to display a 3D model:

```js
<!-- Import the component -->
<a href="https://unpkg.com/@google/model-viewer/dist/model-viewer.js">https://unpkg.com/@google/model-viewer/dist/model-viewer.js</a>
<a href="https://unpkg.com/@google/model-viewer/dist/model-viewer-legacy.js">https://unpkg.com/@google/model-viewer/dist/model-viewer-legacy.js</a>
<!-- Use it like any other HTML element -->
<model-viewer src="shared-assets/models/Astronaut.glb" alt="A 3D model of an astronaut" auto-rotate camera-controls></model-viewer>
```

With a simple HTML tag, you can embed a 3D model without needing to know WebGL and the WebXR Device API.

Here is the model-viewer Web Component implemented within and without a framework / library:

### Vanilla JavaScript

<iframe src="https://codesandbox.io/embed/web-components-vanillajs-e059s?fontsize=14&hidenavigation=1&theme=dark" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" title="web-components-vanillajs" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media; usb" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>

### Angular

<iframe src="https://codesandbox.io/embed/webcomponents-angular-3bsij?fontsize=14&hidenavigation=1&theme=dark" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" title="webcomponents-angular" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media; usb" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>

### React

<iframe src="https://codesandbox.io/embed/webcomponents-react-w9wjr?fontsize=14&hidenavigation=1&theme=dark" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" title="webcomponents-react" allow="geolocation; microphone; camera; midi; vr; accelerometer; gyroscope; payment; ambient-light-sensor; encrypted-media; usb" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>

## What Makes Up a Web Component

Hopefully seeing who is using and what can be created with Web Components now has you wanting to know how to create your own.

As stated before, Web Components are built on Web Standards. These low-level APIs consist of:

* Custom Elements
* Shadow DOM
* HTML Templates

Custom Elements API: Allows you to register a custom element on the page.

* Must include a hyphen/dash (kebab-case) i.e. my-custom-element. No single word elements to prevent name clashes.
* It’s a class object that defines its behavior.
* Also determines which, if any, built-in elements the custom elements extends i.e. input (HTMLInputElement), button (HTMLButtonElement), etc.

Shadow DOM API: Facilitates a method to attach a separate DOM to an element

* It provides encapsulation to keep the style, structure, and behavior separate from the outside code. It helps to “...contain the gross” - Paul Lewis ([source](https://www.youtube.com/watch?v=plt-iH_47GE))
* Allows for the remapping of events i.e. turn a click event into something more meaningful.

HTML Templates API: Creates a flexible template that will be inserted into the custom elements shadow DOM.

* the `<template>` element’s content is not immediately rendered. We define the HTML structure upfront and clone when needed via JavaScript.
* Used to efficiently render HTML and update it when the user interacts with our web component.
* For more complex templates, it may be easier to use a library, framework, or tool.

## Basic Example

Here’s an example Web Component I wrote with comments to help explain what is going on.

<iframe height="234" style="width: 100%;" scrolling="no" title="odevs-wc-example" src="https://codepen.io/conshus/embed/NWPzwGO?height=234&theme-id=light&default-tab=js,result" frameborder="no" allowtransparency="true" allowfullscreen="true">
  See the Pen <a href='https://codepen.io/conshus/pen/NWPzwGO'>odevs-wc-example</a> by conshus de OUR show
  (<a href='https://codepen.io/conshus'>@conshus</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

## Browser Support

If you're wondering about browser support, Web Components are supported in modern browsers.

![Table showing browser support for Web Components.](/content/blog/getting-started-with-web-components/browser-support.jpeg "Table showing browser support for Web Components.")

For older browsers, you can use polyfills: <https://www.webcomponents.org/polyfills>

At Vonage, we are creating Web Components to build a Design System like Electronic Arts mentioned earlier. Our goal is for users to be able to easily assemble components to build things like chat applications without having to worry about what is happening behind the scenes.

Here are some resources for more information on Web Components:

* <https://www.webcomponents.org/>
* <https://developer.mozilla.org/en-US/docs/Web/Web_Components>
* <https://open-wc.org/>

## What’s Next?

The Web Component example I made was a simple one. As the complexity of a component grows, using a tool may make development easier. In the next blog post, we’ll be comparing different frameworks and tools that create Web Components.