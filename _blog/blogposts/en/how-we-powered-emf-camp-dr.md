---
title: How We (Em)powered EMF Camp
description: Nexmo sponsored the live captioning at EMF Camp, and a team of
  Nexmo Developer Advocates participated in various ways. Get recaps of all the
  builder fun.
thumbnail: /content/blog/how-we-powered-emf-camp-dr/emf-1200.png
author: devrelnexmo
published: true
published_at: 2018-09-11T12:09:56.000Z
updated_at: 2021-05-03T21:12:05.937Z
category: event
tags:
  - emfcamp
  - developer
  - event
comments: true
redirect: ""
canonical: ""
---
Around the start of September, some 2000 people descended on an internet-connected field for three days of [EMF Camp](https://www.emfcamp.org/) talks, performances, and workshops. There was everything from blacksmithing to biometrics, chiptunes to computer security, high-altitude ballooning to lockpicking, origami to democracy, and online privacy to knitting. 

And of course, we were there! We sponsored the live captioning of the event, done by the lovely people at [White Coat Captioning](https://twitter.com/whitecoatcapxg). Our Developer Advocates, [Bibi](https://twitter.com/Rabeb_Othmani), [Julia](https://twitter.com/iza_biro), [Laka](https://twitter.com/lakatos88), [Lorna](https://twitter.com/lornajane), [Mark](https://twitter.com/judy2k) and [Sam](https://twitter.com/sammachin) participated in the event in various ways. We even had our own camp village called "Nexmo & Friends." We'll let each one of them tell you about their experience over the weekend: 

**Mark:** This time two years ago, my Twitter erupted with seemingly every person I know enjoying themselves at EMF. At this point, I'd never heard of EMF, so I felt hugely left out! I was so lucky to be able to make it this year - I arrived back in the UK from Sydney just 2 days earlier - but then so did [Andrew Godwin](https://www.emfcamp.org/line-up/2018/223-taming-terrain-sculpting-geoscapes-from-lidar), and he was speaking! 

I was rather over-confident about how much I could fit in during the day - I had 3 workshops penciled in for one day, and I didn't make any of them! I was too busy watching talks, meeting new people and generally just getting distracted by the various sights (mostly lit up by LEDs or flames.) 

Being a Python developer, I knew that once the badges were released I would be in my element, and I was not disappointed. A tweet of Lorna's resulted in some people with badge problems coming to visit our "village", so we started digging in and fixing problems with the supporting software which had only had limited testing on Windows. It's always lovely to be able to help people, and especially nice when it's [in person](https://twitter.com/annedejavu/status/1036653258033586176)!

I'm already looking forward to the next EMF and trying to work out what I can create by then so that I can truly be a part of this awesome event. 

**Julia:** I've always had a soft spot for Electronics, making and breaking things - Christmas lights, TV and car included (Sorry, dad!). It hasn't come as a surprise that EMF Camp turned out to be the playground I had always dreamed of, but never knew existed. When I heard that we'd be participating this year, I channeled my excitement into a special edition [Nexmo sticker](https://twitter.com/iza_biro/status/1036676167099707392) and then waited patiently until the day itself. 

Like the others, I found the selection of talks and workshops was so good that attending everything I'd planned quickly became challenging. At this point came my first failure for the weekend. Then I discovered the [\#emfailure](https://twitter.com/search?q=%23emfailure&src=typd) challenge, courtesy of [@grajohnt](https://twitter.com/grajohnt), and kept on returning throughout the following days, whenever I took a break from wandering around, tinkering with my badge or polishing the schedule app. I really enjoyed failing in public and, hopefully, providing entertainment for anyone passing by.

**Sam:** This is the 3rd EMF for me (4th if you count the one-day event in 2013), In 2014 I built a very small GSM network based on [OpenBTS](http://openbts.org/), and I cooked BBQ for about 12 people in our camp. In 2016 Nexmo sponsored and I built an app for the WiFi connected badge to deliver SMS to users, I cooked BBQ for about 20 people.

![Sam the Chef cooking](/content/blog/how-we-em-powered-emf-camp/42701790670_0fd5fc72ca.jpeg "Sam The Chef")

So what to do for 2018, Well I ordered 4Kg of beef brisket a week before, and started it in my (WiFi enabled) [Sous Vide](https://anovaculinary.com/) on the Wednesday morning, 40 hours at 135F followed by ~3 hours in the smoker and grill at camp:) Oh yes and I also built a much larger GSM network and integrated it with the DECT and SIP networks, working together with the [Eventphone](http://eventphone.de/) team I'll go into more detail on the network we built in a later post. 

As Nexmo also sponsored the live captioning I had to engineer a solution to get the audio from the sound desk to the captioners and display their output on a screen at the side of the stage. This involved mounting TV's and convincing my colleagues to dust of their hardware skills to make up super long ethernet cables. Again look out for a deeper dive on what we did there coming soon. 

**Lorna:** I knew I'd enjoy EMF, I have a background in Electronics and as a bit of a craft enthusiast I suspected there would be plenty to enjoy - and I was not disappointed! I enjoyed being able to get to many of the sessions and mix with the other attendees. The topics were many and varied, and there were people making things everywhere we looked. I saw talks covering everything from wearable tech, mental health, Internet of Things and much more. 

I think my highlight of the weekend was the attendee "badges". Once you collect your various components and assemble them, you can configure the badge to display your name on the screen—and at that point, the accuracy of the term "badge" ends. This device is a fully-fledged microcomputer and programmable phone. Sitting in a field in the sunshine writing python to make the neopixels change colour when I pressed the buttons was great fun. A bunch of people dropped by the Nexmo village to work on their badges with our team and we really enjoyed meeting everyone. The badges is a huge project and the team that worked on this did so well to pull off such an ambitious design! 

**Laka:** I've wanted to go to EMF for the past two years, I missed the last edition and felt I'd missed out. So when Sam said he needed "some web apps" built to power the live captioning, I jumped at the idea immediately and ended up with two applications. 

Remember we said **we sponsored the live captioning**? The stenographers (captioners) work from home so I created an application to stream the talk audio to them. This application is using [Vue.js](https://vuejs.org/) and the [Nexmo In-App Audio SDK](https://developer.nexmo.com/stitch/in-app-voice/overview) to enable audio on the stage computer and send it one way via WebRTC to a stenographer half way around the world. You can see it in action at <https://nexmo-emf-transcription.herokuapp.com/> and the stenographers seemed to [like it](https://twitter.com/whitecoatcapxg/status/1035552274955870208).

The live captions were coming back over [StreamText](https://streamtext.net/), which was running headless on a RaspberryPi taped together with the side-stage TV and streaming the text. 

I also created a second app to display the schedule and give access to the captions during and after the event. This time I built a Progressive Web App using Vue.js and the [Nexmo In-App Messaging SDK](https://developer.nexmo.com/stitch/in-app-messaging/overview) to take the schedule for the three main tracks, enhance them with some conversation magic, and display the captions next to the talk description. In a perfect world, the captions from StreamText would get to the app via WebSockets, but the reality of the field was harsh and the captions didn't arrive in the app in real time. We'll add the captions to the app as soon as StreamText releases the timestamped version. In the meantime you can take a look at the app at <https://nexmo-emf-schedule.herokuapp.com/> and keep an eye for those captions. 

These applications gave me a chance to work more with Vue.js and I think I might be in love. Stay tuned for a step-by-step write-up in the coming weeks about how I created the two Vue.js apps.