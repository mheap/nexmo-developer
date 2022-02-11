---
title: Share Screens Together With Your Friends and Co-workers
description: Learn how to enhance Vonage Video's Basic Video Chat App with
  screen-sharing capabilities using HTML and javascript
thumbnail: /content/blog/share-screens-together-with-your-friends-and-co-workers/sharescreens_1200x600.png
author: misha-behei
published: true
published_at: 2021-03-11T10:40:16.115Z
updated_at: ""
category: tutorial
tags:
  - video-api
  - javascript
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In certain scenarios, there might be a need for having multiple screens to be shared at the same time. With Vonage Video API, you have an opportunity to do exactly that. 


This blog post will show how to build a simple Javascript application that utilizes Vonage Video API that allows having multiple screen share streams at the same time. This can be useful for collaboration efforts or for simple fun, such as playing a game of tic-tac-toe together with friends or family. 

## Prerequisites

To develop this project, you are going to need the following:
* Vonage Video API account
* Basic knowledge of JavaScript
* Video API documentation 
* Clone certain GitHub repositories 

## Implementation

We will use a Basic Video Chat sample from the Opentok Github directory as a starting point for this tutorial. Please download the following repository - [https://github.com/opentok/opentok-web-samples](https://github.com/opentok/opentok-web-samples) and we will be working with the Basic Video Chat part of this repository.

We will be using a session ID and token generated through your Vonage Video API account. Please visit [tokbox.com/account](https://tokbox.com/account) to do so and copy-paste information to the `config.js` file of the repository. For a deployed application, it is recommended that you generate session IDs and tokens via the [backend server](https://tokbox.com/developer/guides/create-token/).  

In the Basic Video Chat sample app, navigate to the index.html, and let’s add a button for the screen share.

Add the following code in the `<body>` of the HTML page:

```html
<button onclick=”screenShare()”>Share your screen </button>
```

Now navigate to the `js/app.js` part of the codebase and add the following `screenShare()` function: 

```javascript
function screenShare() {
    OT.checkScreenSharingCapability(function(response) {
    if(!response.supported || response.extensionRegistered === false) {
      console.log("screen sharing is not supported")
    } else if (response.extensionInstalled === false) {
      console.log("older browser like IE might require a plugin")
    } else {
      // Screen sharing is available. Publish the screen.
      var publisher = OT.initPublisher('screenshare',
        {videoSource: 'screen'},
        function(error) {
          if (error) {
            console.log(error);
          } else {
            session.publish(publisher, function(error) {
              if (error) {
                console.log(error);
              }
            });
          }
        }
      );
    }
  });
}
```

After this, go back to the `index.html` file and add the `<div>` for the screensharing stream:

```html
<div>
	<div id=”subscriber”></div>
	<div id=”publisher”></div>
	<div id=”sceenshare”></div>
</div>
```

We would like to keep publisher, subscriber, and screen-share streams separate to make sure that users can also see each other during the screen sharing activity. You can update the `css/app.css` file to add additional layout styling; however, without any changes, the screen-sharing streams will appear in the upper left corner. 


To test this, open the `index.html` file in your browser (such as Google Chrome), publish your video and click the “Share your screen” button underneath your video stream. Afterward, join from a different device or browser to test this out!


In conclusion, this article showed you a simple way to enhance the Basic Video Chat app with screen-sharing capabilities that allow users to share their screens simultaneously. This was done through enhancements to the HTML and JavaScript files of the existing OpenTok GitHub repository. 



