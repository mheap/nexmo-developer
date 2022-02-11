---
title: Creating a Voice Journal for the Next Web
description: Create a distributed audio journal and deploy it onto the
  peer-to-peer web. Use Nexmo Voice APIs to create new audio entries by merely
  making a phone call
thumbnail: /content/blog/next-web-voice-journal-python-vue-javascript-dr/p2p-voice-journal-featured.png
author: aaron
published: true
published_at: 2018-06-19T14:25:13.000Z
updated_at: 2021-05-13T08:18:53.781Z
category: tutorial
tags:
  - python
  - voice-api
comments: true
redirect: ""
canonical: ""
---
The world-wide-web is a wondrous thing. We can create and share information easier than at any point before in human history.

> Writing a tutorial for the [@NexmoDev](https://twitter.com/NexmoDev?ref_src=twsrc%5Etfw) blog while 35,000 feet above the Atlantic [\#devrellife](https://twitter.com/hashtag/devrellife?src=hash&ref_src=twsrc%5Etfw) [pic.twitter.com/mvxGDuEDky](https://t.co/mvxGDuEDky)
>
> — Aaron Bassett - what timezone is it? (@aaronbassett) [May 15, 2018](https://twitter.com/aaronbassett/status/996214436946788352?ref_src=twsrc%5Etfw)

However, much of what we create lives within walled gardens; this is the antithesis to the original idea of the www. Breaking down these walled gardens has been something Tim Berners Lee has been talking about since at least 2009!

> In fact, data is about our lives. You just -- you log on to your social networking site, your favorite one, you say, "This is my friend." Bing! Relationship. Data. You say, "This photograph, it's about -- it depicts this person. " Bing! That's data. Data, data, data. Every time you do things on the social networking site, the social networking site is taking data and using it -- re-purposing it -- and using it to make other people's lives more interesting on the site. But, when you go to another linked data site -- and let's say this is one about travel, and you say, "I want to send this photo to all the people in that group," you can't get over the walls.

— [Sir Tim Berners-Lee](https://www.ted.com/talks/tim_berners_lee_on_the_next_web)

In fact, decentralisation has been a fundamental aspect of the www since its inception.

> Decentralisation: No permission is needed from a central authority to post anything on the web, there is no central controlling node, and so no single point of failure … and no “kill switch”! This also implies freedom from indiscriminate censorship and surveillance.

— [Web Foundation, History of the Web](https://webfoundation.org/about/vision/history-of-the-web/)

## Introducing the person-to-person web

![Voice Journal Screenshot](/content/blog/creating-a-voice-journal-for-the-next-web/voice-journal-screenshot.png "Voice Journal Screenshot")

With the person-to-person web, there is no server required. Each visitor to your site becomes a peer in the swarm. Connecting directly together and sharing your site's files with each other. Not only does this help keep your site online, but it also creates freedom from indiscriminate censorship.

Let's look at how we can use the [Dat protocol](https://www.datprotocol.com/) with [Nexmo's Voice API](https://developer.nexmo.com/voice/voice-api/overview) to create a distributed website to host an audio journal. You can [download the code for this example on Github](https://github.com/nexmo-community/p2p-voice-journal).

## Process Flow

The process flow for our application is straightforward. When we call our Nexmo Virtual Number, it records the audio as an MP3, notifies our server that there's a new recording. Then, when our server receives the notification from Nexmo, it downloads the MP3 file and adds it to our archive, and it is automatically shared with all peers using the Dat protocol.

## Nexmo Call Control Object and the Recording Action

Recording the audio is [exceptionally simple with Nexmo](https://developer.nexmo.com/voice/voice-api/guides/record-calls-and-conversations). We create an [NCCO file with a single `record` action](https://developer.nexmo.com/api/voice/ncco). You may also want to use the TTS functionality to play a message before your recording; I've chosen not to, and instead, I instruct Nexmo to play a beep when it is ready to record. Much like an answering machine.

```
@hug.get('/')
def ncco():
    return [
        {
            "action": "record",
            "eventUrl": ["<SERVER URL>/recordings"],
            "endOnKey": "*",
            "beepStart": True
        }
    ]
```

In the code above I'm using [Hug to create a JSON endpoint](http://www.hug.rest/) to serve my NCCO file to the Nexmo API. For more information on creating voice applications with Nexmo (and for details on what an NCCO file is), please read some of my previous tutorials:

* [Proxy Voice Calls Anonymously with Express, the Nexmo Voice API, and a Virtual Number](https://www.nexmo.com/blog/2018/05/22/voice-proxy-node-javascript-express-dr/)
* [Be a Text-to-Speech Super Hero with Nexmo Voice APIs](https://www.nexmo.com/blog/2017/08/14/text-to-speech-phone-call-with-django-dr/)
* [Inbound Voice Call Campaign Tracking with Nexmo Virtual Numbers and Mixpanel](https://www.nexmo.com/blog/2017/08/03/inbound-voice-call-campaign-tracking-dr/)

I also explain more about Nexmo Voice Applications in my live coding webinars; it's about 20 minutes in:

<youtube id="pHf9Df3Ns2U"></youtube>

## Saving the Recording

Once the call has finished, or the user has pressed *"*"* Nexmo notifies us about the new recording via the webhook we specified as the `eventUrl` in the code above. The request to our webhook contains the `recording_url` which we can use to download the MP3 file. However, first, we need to authenticate with Nexmo to ensure that we have permission to download the recording. We use [JWTs for authentication](https://jwt.io/).

```
@hug.post('/recordings')
def recordings(recording_url, recording_uuid):
    iat = int(time.time())
    now = datetime.datetime.now()

    with open('nexmo_private.key', 'rb') as key_file:
        private_key = key_file.read()

    payload = {
        'application_id': os.environ['APPLICATION_ID'],
        'iat': iat,
        'exp': iat + 60,
        'jti': str(uuid.uuid4()),
    }

    token = jwt.encode(payload, private_key, algorithm='RS256')

    recording_response = requests.get(
        recording_url,
        headers={
            'Authorization': b'Bearer ' + token,
            'User-Agent': 'voice-journal'
        }
    )
    if recording_response.status_code == 200:
        recordingfile = f'./site/recordings/{now.year}/{now.month}/{recording_uuid}.mp3'
        os.makedirs(os.path.dirname(recordingfile), exist_ok=True)

        with open(recordingfile, 'wb') as f:
            f.write(recording_response.content)
```

Most of the code above is for the JWT authentication [*[yeah, someone really should make that easier to do in the Python client… ?](https://www.nexmo.com/wp-content/uploads/2018/06/slack-screenshot.png)]. After we download the recording, we save the MP3 file, making sure to keep our archive nice and organised.

```
/recordings/<current year>/<current month>/<recording uuid>.mp3
```

By structuring our recordings in this way on disk, even without our application frontend, we can easily find and listen to a recording from a particular day.

## Distributing our Recordings

There are two main ways of distributing our site via [Dat](https://datproject.org/); [using the Dat CLI](https://github.com/datproject/dat), or via the [Beaker Browser](https://beakerbrowser.com/). For simplicity, we're going to use Beaker in this example. However, if you wanted to run your webhook on a server, or as a serverless function, then use the Dat CLI. [Tara Vancil](https://twitter.com/taravancil) has a great article on how they [use the Dat CLI to publish updates on their blog](https://taravancil.com/blog/how-i-publish-taravancil-com/) ([dat version](dat://6dff5cff6d3fba2bbf08b2b50a9c49e95206cf0e34b1a48619a0b9531d8eb256/blog/how-i-publish-taravancil-com/)). One thing to bear in mind is that our application frontend uses some [Beaker specific APIs](https://beakerbrowser.com/docs/apis/dat.html) for interacting with our archive and displaying information about the swarm; unlike Tara's site, it does not work in a regular browser, so you do not need [dathttpd](https://github.com/beakerbrowser/dathttpd).

If you haven't done so already, you should [download Beaker now](https://beakerbrowser.com/install/).

## Join my Swarm

**Note: Much like BitTorrent and other P2P protocols, members of a swarm can by necessity see the IP addresses of other members. Remember this is peer-to-peer distribution, it does not go through a centralised service. You can skip the next section if you're not comfortable sharing your IP address with other swarm participants.**

Open the following `dat://` link in Beaker: <dat://8354c381e6f859e57ef6979af7e287acf3d528d8463f54774c36b6bc8aa514d6/>

Congratulations, you are now a member of my swarm and can distribute the audio recordings to other visitors.  You're (one of) my web servers, thank you!

However, when you close your browser, you leave the swarm. The files remain on your computer, but you're no longer distributing them to other visitors. To ensure that there is always at least one peer available I have added the archive to [\#_hashbase](https://hashbase.io/).

## The Application Frontend

You don't need to create a UI to access your recordings. Beaker creates a simple interface for us to use if our archive directory does not contain an index file. It's functional, but not very pretty. We can do better.

![Directory listing rendered by Beaker Browser](/content/blog/creating-a-voice-journal-for-the-next-web/dir-listing.png "Directory listing rendered by Beaker Browser")

Our frontend is a [Vue application](https://vuejs.org/), which uses the Vonage Volta design system. Volta is the same design system which [we used in the recent Nexmo Dashboard redesign](https://www.nexmo.com/blog/2018/05/15/the-nexmo-dashboard-gets-a-new-look/). Unfortunately, Volta is not open source, at least not yet.

We also use some Beaker specific APIs for interacting with our archive.

```
const archive = new DatArchive(window.location)
let allRecordings = await archive.readdir('/recordings', {recursive: true, stat: true})
```

In the code above we interrogate our archive, reading the contents of our recordings directory and filtering out any files which are not MP3s. The `stat` option instructs Beaker to run `stat()` on every entry and return with `{name:, stat:}`.

Another noteworthy part of the page is the information boxes at the top of the page.

![Screenshot of swarm information UI](/content/blog/creating-a-voice-journal-for-the-next-web/info-boxes.png "Screenshot of swarm information UI")

We use another [Beaker API to](https://beakerbrowser.com/docs/apis/dat.html) retrieve this information, `getInfo()`

```
async peers () {
    return await this.archiveInfo.peers
},
async version () {
    return await this.archiveInfo.version
},
async mtime () {
    let timestamp = await this.archiveInfo.mtime
    return moment(timestamp).startOf().fromNow()
},
async filesize () {
    let size = await this.archiveInfo.size
    return filesize(size, {round: 2})
}
```

## Archive History

> The Dat protocol ensures that the archive is signed by the author, and can be checked for correctness by querying network peers (distribution uniformity). Only one version of the archive’s history can be distributed. If a signed Dat archive is found to differ from a peer’s signed copy, it is treated as corrupt, as the differing content could indicate a targeted attack by the Dat author. It’s important that all users receive the same content, and that’s why Dat has integrity verification built in.

— [Beaker Browser, Publish Software Securely](https://beakerbrowser.com/docs/tutorials/publish-software-securely.html)

![History log screenshot](/content/blog/creating-a-voice-journal-for-the-next-web/history-screenshot.png "History log screenshot")

Using the Beaker Web APIs, we can query and display this log of changes to our archive; this log even shows if the author has deleted any journal entries.

```
archiveHistory: {
    async get () {
    const archive = new DatArchive(window.location)
    const completeHistory = archive.history({start: 0, reverse: true})
    return completeHistory
    }
},
```

## Learn More

* Try forking my archive and adding new recordings via the Nexmo Voice API. If you get stuck, the [Beaker Browser docs](https://beakerbrowser.com/docs/using-beaker/), [Nexmo Voice API overview](https://developer.nexmo.com/voice/voice-api/overview), and [this post about ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) will help.
* Read the [Nexmo documentation around recording calls and conversations](https://developer.nexmo.com/voice/voice-api/guides/record-calls-and-conversations).
* Find out more about the [Dat Project](https://datproject.org/), the [Dat protocol](https://www.datprotocol.com/), and [Beaker Browser](https://beakerbrowser.com/about.html).
* Explore some of the other impressive things you can do with the Nexmo Voice API; view our posts on [real-time sentiment analysis](https://www.youtube.com/watch?v=nFIj8RVy8Pg), [anonymous voice proxies](https://www.nexmo.com/blog/2018/05/22/voice-proxy-node-javascript-express-dr/), [critical voice messages](https://www.nexmo.com/blog/2017/10/05/fast-voice-broadcast-python-dr/), [real-time translation](https://www.nexmo.com/blog/2018/03/14/speech-voice-translation-microsoft-dr/).
* Have a play in the [Nexmo Voice Playground](https://dashboard.nexmo.com/voice/playground)!