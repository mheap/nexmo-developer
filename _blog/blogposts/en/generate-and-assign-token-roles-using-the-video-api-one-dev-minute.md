---
title: Generate and Assign Token Roles using the Video API | One Dev Minute
description: In this video Amanda Cavallaro, our developer advocate shows you
  how the token roles allow you to identify users and change the permission
  roles using the video-api.
thumbnail: /content/blog/generate-and-assign-token-roles-using-the-video-api-one-dev-minute/videoapi_waitingroom.png
author: amanda-cavallaro
published: true
published_at: 2021-09-15T13:24:38.295Z
updated_at: 2021-09-15T13:24:38.314Z
category: tutorial
tags:
  - video-api
  - javascript
  - nodejs
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Welcome to[ One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! This series is hosted on the [Vonage Dev YouTube channel](https://www.youtube.com/vonagedev). The goal of this video series is to share knowledge in a bite-sized manner. 

In this video, Amanda Cavallaro, our Developer Advocate, shows you how the token roles allow you to identify users and change the permission roles using the Vonage Video API. 

<youtube id="1yzLSpwqrw8"></youtube>

## Transcript

Hi! This is Amanda Cavallaro, a Developer Advocate at Vonage, and today I'll talk about generating and assigning token roles. 

To authenticate a user connecting to a video API session we must use a  unique authentication key called "token". 

There are three possible token roles: subscriber, publisher, and moderator. 

Let's generate a token using the video API Node.js server-side library. 

We first install Opentok from the terminal. In your coding editor, you set the constants with the  API key and the API secret that you receive when you sign up to use the video API.  

You can create or use an existing session ID. Next, we call the generateToken method that will return a token in the string format. 

You can generate tokens for clients to use when connecting to the session. In this example, we are creating a username "Amanda" of role "publisher". 

The options parameter is an optional object used to set the role, expiry time, and connection data of the token. We then add the token options to the generated token, run Node and the name of the file we created and in your terminal, you can see your token. 

There are a number of things you can do with your generated token depending on its role. You have additional permissions if you receive a moderator token. You can, for instance, disconnect, mute other users, or even stop publishing their streams. 

In this video, you saw how to generate and design a token. You can learn further from the links below!

## Links

[Code present in this video](https://tokbox.com/developer/guides/create-token/node/)

[Capabilities](https://tokbox.com/developer/sdks/js/reference/Capabilities.html[](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbWRZWm1HeFU1dWU5RVFHeVcybWtCVkQ4ZEl2QXxBQ3Jtc0trc0xrN1hWcWFOa0xpY3I3YU53ZlQtSUNNaUo4NUItSmphaU45VWpFdjF4UjlQN1dVNC0xRTV3Rjh4LTlCUl9Gc3UzVnVTUWQ4eHBVZ1BhdkxEdHZyWHNYam92b2hMdXh4S3poZkZYM2k1aXNTMVM4cw&q=https%3A%2F%2Ftokbox.com%2Fdeveloper%2Fsdks%2Fjs%2Freference%2FCapabilities.html))

[Create Token](https://tokbox.com/developer/guides/create-token/) [](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqblF1S1lPUXRBVnUtUElVY3pGd1BjRkM2cWpNZ3xBQ3Jtc0trSTFmbG1VeHlQSnJPcEwyNE5pTmxBZ2JtYW1hSGN2TnV6WE9IOUw0bGhrYnFOaFlkWjQyVXFrUVVJRGxMeUFvY292dVlVLUI4SEtpWEZxSWkwRkx5UC01SGx5RTBTZWZFTmFaLTRZdVlGdlVHTHdCVQ&q=https%3A%2F%2Ftokbox.com%2Fdeveloper%2Fguides%2Fcreate-token%2F)

Join the [Vonage Developer Community Slack](https://developer.nexmo.com/community/slack)