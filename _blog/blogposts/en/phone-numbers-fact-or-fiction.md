---
title: "Phone Numbers: Fact or Fiction"
description: What phone numbers should you use in your example code and
  documentation to avoid upsetting real people.
thumbnail: /content/blog/phone-numbers-fact-or-fiction/555-Ghostbusters.png
author: sammachin
published: true
published_at: 2016-06-22T12:39:08.000Z
updated_at: 2021-05-13T11:19:15.167Z
category: tutorial
tags:
  - phone-numbers
  - numbers-api
comments: true
redirect: ""
canonical: ""
---
I'm a phone number geek, I always have been. As a child I used to read the front section of the phone directory where all the area codes and special numbers were listed! So, it's not really surprising that I ended up with a career in telecoms. There's something fascinating about the structure of phone numbers to me. Its like a map all laid out in a (mostly) logical structure.

Most people don't even think about phone numbers. These days we probably rarely interact directly with them as they're stored against contacts in our mobiles. However, they do appear in day to day life, when we see them we do recognise them as a phone number and most of us do have a phone number. As do most people. So, as a developer it's important for us to consider how we use numbers in our apps.

### Why Do Developers Need to Care?

When we're documenting things or capturing screenshots we tend to put in dummy data. Things like `Joe Bloggs` as a name and `joe@example.com` as an email. But when it comes the phone number we put in something easy like `01234 567890`. However that *could* be someones real phone number! 

In this case if we are looking at the UK that area code (`01234`) is for Bedford and the `567890` number has not been allocated. Would you really want it!? Think of all the wrong numbers and prank calls you'd probably receive!

### What Should I Do?

So how can we be sure that we're using a 'safe' number in our examples and demos? One that hasn't been allocated to a real person or business. You wouldn't want to accidentally use a real number that resulted in somebody getting lots of strange calls from developers who had copied and pasted your code!

Did you know that many countries have specifically allocated a part of their numbering plans to use in Fiction?

The main use case is for things like TV and Films. If a character on TV gives another character their mobile number you can be sure a small percentage of the viewers will try calling it. If you're a show with 10m viewers then 0.1% would be 10,000 calls. Rather annoying if the script writers randomly pick your number to use on screen. US movies are full of [examples](https://www.youtube.com/watch?v=XuP4cTRrWz8) of people quoting these numbers.

<youtube id="XuP4cTRrWz8"></youtube>

### What Phone Number Ranges Can I Use?

Now that you know there are safe number ranges to use you'll want to know what those ranges are:

**In the UK**, Ofcom (the telecoms regulator) has assigned part of the number plans to '[Drama Usage](http://stakeholders.ofcom.org.uk/telecoms/numbering/guidance-tele-no/numbers-for-drama)' meaning that these look like real UK numbers of various types, but will never be allocated to a real phone. So you're safe to use them.

**In the US** the numbers used are in the `555` block, with any area code. So `(415) 555-0123` would be a fictitious number in San Francisco.

In fact the `555` block isn't entirely dedicated to fictional use. Some of the `555` block is used for directory and information services, although this is on the decline. Officially only the range `555-0100` through `555-0199` is set aside for fictitious use.

**In Ireland** the block `020-91X-XXXX` is [reserved](http://www.comreg.ie/_fileupload/publications/ComReg0804.pdf) by the regulator.

**Australia** also has [blocks of numbers](http://www.acma.gov.au/Citizen/Consumer-info/All-about-numbers/Special-numbers/fictitious-numbers-for-radio-film-and-television-i-acma) dedicated to use in fiction.

### Other Countries?

If you know of any more countries with a dedicated range then drop me a message. I'm [@sammachin](https://twitter.com/sammachin) on twitter.