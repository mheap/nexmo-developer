---
title: Christmas Poetry Reading Using Text-To-Speech and SSML
description: Make your text-so-speech sound more natural using Speech Synthesis
  Markup Language. We explain how to modify prosody and pronunciation with SSML.
thumbnail: /content/blog/christmas-poetry-reading-using-text-to-speech-dr/Christmas-Poetry-Reading-Using-Text-To-Speech.png
author: lornajane
published: true
published_at: 2018-12-05T14:09:43.000Z
updated_at: 2021-05-10T09:56:14.633Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Here at Nexmo we do use [text-to-speech](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech) in our telephony applications extensively, but did you know that your text could do more than just speak? Our Voice API supports [SSML (Speech Synthesis Markup Language)](https://www.w3.org/TR/speech-synthesis/) which allows you to add some expression into your text-to-speech outputs.

Since it's Christmas, I thought I'd set myself a Christmas Poem as a challenge! Text-to-speech with just punctuation such as commas and full stops actually works pretty well, so even on the first attempt, you could sort of tell it was supposed to have meter.

> Little Jack Horner 
> Sat in the corner, 
> Eating of Christmas pie: 
> He put in his thumb, 
> And pulled out a plum, 
> And said, “What a good boy am I!”

We can improve on this by marking up the words that should have emphasis. I used `<prosody>` tags to give the strong words in the rhyme more volume and to slow them down. For example "Horner", "corner", "plum" and "thumb" are all marked up with `<prosody rate="x-slow">` to help with the rhythm of the speech.

The text-to-speech didn't know the word "Horner" so I used a `<phoneme>` tag to spell phonetically how the word should be pronounced (which at least makes it rhyme with "corner" in the next line, it still sounds a bit strange to me!). This is a very useful trick when curating your text-to-speech content, especially for proper nouns which are often unfamiliar to the parser. You can also use it for any other words whose pronunciation doesn't come out as you expected.

Finally, for fun, I bleeped out the word "good" in the last line by making use of the `<say-as>` tag and making that word an expletive. This tag can be very useful if your application needs to speak user-supplied content with unknown contents!

Here's the SSML I ended up with:

```xml
<speak>
    <lang xml:lang='en-GB'>
        Little Jack <prosody rate="x-slow"><phoneme alphabet="ipa" ph="ˈhɔːnə">Horner</phoneme></prosody>,
        Sat in the<prosody rate="x-slow">corner</prosody>,
        Eating of <prosody volume="x-loud">Christmas</prosody> <prosody rate="x-slow">pie:</prosody>
        He put in his <prosody rate="x-slow">thumb</prosody>,
        And pulled out a <prosody rate="x-slow">plum</prosody>,
        And said, “What a <say-as interpret-as="expletive">good</say-as> boy am <prosody rate="x-slow">I</prosody>!”
    </lang>
</speak>
```

By including this XML as the `text` field in the `talk` action of my NCCO, and adding a `record` action too, I was able to capture the poetry of the robot:

https://soundcloud.com/user-872225766-984610678/conference-31696a4f-983f-40ea-b81a-ab942fc33782

- - -

You could consider adding some more expression to your spoken interaction with your users by adding SSML - and poetry is a great way to practice. Let us know if you build something poetic this Christmas!