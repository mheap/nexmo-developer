---
title: A Sneak Peek at the Vonage API Projects at DotSlash 5.0
description: The article provides an overview of the hackathon winning teams'
  projects and their experiences using the Vonage APIs.
thumbnail: /content/blog/a-sneak-peek-at-the-vonage-api-projects-at-dotslash-5-0/dotslash.png
author: clarisse-ng
published: true
published_at: 2022-01-26T16:44:43.721Z
updated_at: 2022-01-24T14:26:33.968Z
category: event
tags:
  - video-api
  - sms-api
  - hackathon
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---

## Introduction

Vonage and the Sardar Vallabhbhai National Institute of Technology, Surat celebrated the start of the year 2022 with a hackathon called [DotSlash 5.0](https://hackdotslash.co.in/). Vonage is a proud sponsor of the online hackathon that challenged the student developers in India to build applications that are useful for society. In just 36 hours, more than 1,600 students designed and built 117 impressive projects. A variety of challenging problems statements was addressed, such as road safety, smart city management, developer tools, tech for everyone, personal growth & well-being, and much more.

[Dwane Hemmings](https://learn.vonage.com/authors/dwanehemmings/), a developer advocate at Vonage, led a successful [workshop](https://www.youtube.com/watch?v=NwaT81H8fIA) on the Vonage Video Express and Video API, which demonstrated how users can incorporate the API in their projects, in addition to other Communication APIs. 

Here is a look at the winning teams and what they experienced.

## Team: GrowerLabs

![CodeTogether application homepage](/content/blog/a-sneak-peek-at-the-vonage-api-projects-at-dotslash-5-0/codetogether-application-homepage.png "CodeTogether application homepage")

CodeTogether was created by a group of 3 students – [Diya Karmakar](https://devfolio.co/@astron_diya), [Apara Biswas](https://devfolio.co/@apara), and [Shayan Debroy](https://devfolio.co/@shayancyber). This team also made it to the Top 10.

### What Does CodeTogether Do?

CodeTogether is a platform that allows coders to enjoy collaborative coding and communication through online voice calls, real-time chat, and tools such as whiteboard. It eliminates the barrier of using different platforms and brings together all the essential features in one central location so that programmers can discuss, plan and code together. The saved code of one collaborator can be easily seen by others by allowing them to save the changes in their codes.

### What Inspired You To Build This Project? 

As programmers, we often encounter a variety of issues during collaborative coding, such as sharing code snippets with fellow programmers, communicating with them to discuss the problem while planning out approaches to solve it in the best manner. Many times we have to jump between platforms just to do a proper collaboration, such as using Google Meet to talk to one another, and sharing code snippets through WhatsApp or Discord, even though they are not meant for code sharing because the formatting gets messed up. This approach can lead to a lackluster collaboration.

### What Is The Biggest Problem?

For voice calling features like Discord, we needed an API so that we do not have to reinvent the wheel and implement WebRTC from scratch. Luckily, we found a perfect API, that is, Vonage, which is one of the sponsors of the hackathon. The mentors from Vonage helped us to implement this audio calling feature smoothly.

### What Did You Learn?

We learned about integrating Vonage API and implementing audio call functionality in our platform through the session hosted by Dwane Hemmings. Though we had prior knowledge about real-time communication with WebSockets, it was our first time implementing the WebSocket in this manner.

### How’s Your Experience Using The Vonage APIs?

We came to know about Vonage API through this hackathon. We then attended the session hosted during the hackathon on the Vonage API and found it quite easy to implement the API for the voice call feature. The solution was ideal for the feature we wanted to add to CodeTogether. Furthermore, the documentation was also quite easy to understand.

### What’s Next For You?

We'll try implementing more APIs from the Vonage family and learning more about them.

View the [CodeTogther](https://code-together-eight.vercel.app/) application and [code on GitHub](https://github.com/shayan-cyber/DotSlashProj). Watch the CodeTogether [demo video](https://www.youtube.com/watch?v=w-AcD3Icy60).

## Team: Mozart

![Mozart DevTool](/content/blog/a-sneak-peek-at-the-vonage-api-projects-at-dotslash-5-0/mozart-devtool.png "Mozart DevTool")

Mozart DevTool was built by 3 students – [Mohammad Ansah](https://devfolio.co/@Ansah), [Garvit Shah Shah](https://devfolio.co/@gobbledygook) and  [Pratham Gandhi](https://devfolio.co/@prathamgandhi). These students also earned an honorable mention.

### What Does Mozart DevTool Do?

Mozart Devtools eases the workflow of a developer using VSCode Extensions. It helps to: 

* Manage user tasks and schedule reminders on Telegram using Bot
* Improve users’ health and help account for their tasks
* Regular schedule reminders to improve better workflows
* Add tasks and manage them inside the VS-Code itself
* Open Stack Overflow, Spotify within the VS-Code
* Get a summary of time spent through SMS
* Various health Boosters like Eye-care and Movement Reminders for immersive developers

### What Inspired You To Build This Project?

We were asked by friends about challenges they face while developing a program and their replies were our inspiration for the project. The team is working to resolve three issues: task management, the health of developers, and time management. Our goal is to increase productivity while reducing unnecessary stress.

### What Problems Are You Solving?

We were trying to:

* Find the right API for sending SMS and WhatsApp Integration
* Set up the endpoints correctly, and then schedule Telegram message jobs via Cron
* Use Video call, Voice, and SMS in one API

### What Did You Learn?

We learned how to present a program to an audience. This was our first experience working with the VSCode-ext library and JavaScript. In the process, we also became familiar with the pre-structuring of the program and the functions of VS-CODE. We also gained knowledge about OTP and API services for sending messages.

### How’s Your Experience Using The Vonage APIs?

We came to know about Vonage API through the hackathon sessions and webinars. We used the SMS API from Vonage as it was easier to create. The video tutorials were also very helpful. 

### What’s Next For You?

We aim to integrate voice commands, a GUI for better usage. The project will also be equipped with auto-save functionality. Our final goal is to deploy the extensions so that the developer community can use them freely. As part of the plan, we will have user verification via OTP and send reminders via WhatsApp and Telegram using the WhatsApp message sender API from Vonage. The VSCode extension will also include video call and voice features for the developer teams.

View the Mozart DevTool [code on GitHub](https://github.com/Mozart-dotSlash). Watch the Mozart DevTool [demo video](https://www.youtube.com/watch?v=QrUx8J_pDeI).

## Conclusion

We thoroughly enjoyed supporting the student developers in the DotSlash 5.0 hackathon and were delighted that they were able to take their ideas and make them work for the benefit of the community.

You can learn more about the Vonage [SMS API](https://developer.vonage.com/messaging/sms/overview) and the [video platform](https://tokbox.com/developer/guides/basics/). 

Try creating your own project using the [Video API](https://tokbox.com/developer/) or [Video Express](https://tokbox.com/developer/video-express/). To get started, check out Dwane’s [Video API Glitch demo](https://glitch.com/edit/#!/remix/vonage-video-api-basic?path=README.md%3A1%3A0) and [Video Express Glitch demo](https://glitch.com/edit/#!/remix/video-express-demo?path=README.md%3A1%3A0). Take some inspirations from [projects](https://learn.vonage.com/tags/video-api/) that others have built such as [getting a responsive layout](https://learn.vonage.com/blog/2021/11/18/auto-layout-for-vonage-video-application/), [adding live captions](https://learn.vonage.com/blog/2021/12/16/enable-live-captions-in-vonage-video-using-symbl-ai/), [creating a personal Twitch](https://learn.vonage.com/blog/2021/12/15/create-a-personal-twitch-with-vonage-video-api-and-web-components/), and [building an e-learning application](https://learn.vonage.com/blog/2021/12/08/post-hackathon-the-e-learning-app-built-with-video-api/). 

Tell us what projects you’ve built on [Twitter](https://twitter.com/VonageDev) or reach out to us with your questions in the [Developer Community Slack Channel](https://developer.vonage.com/community/slack). Have fun coding!