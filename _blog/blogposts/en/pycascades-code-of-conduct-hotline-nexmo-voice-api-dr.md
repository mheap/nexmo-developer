---
title: Enhancing PyCascades Code of Conduct Hotline with Nexmo Voice API
description: In this Developer Spotlight we'll look at how Mariatta enhanced the
  PyCascades Code of Conduct hotline with Nexmo Voice APIs, Zapier and Slack
thumbnail: /content/blog/pycascades-code-of-conduct-hotline-nexmo-voice-api-dr/PyCascades-CoC-Hotline.png
author: mariatta
published: true
published_at: 2018-11-15T16:58:53.000Z
updated_at: 2021-05-04T14:13:37.111Z
category: tutorial
tags:
  - python
  - voice-api
comments: true
spotlight: true
redirect: ""
canonical: ""
---
Hello, my name is [Mariatta](https://mariatta.ca). I work as a Platform Engineer at [Zapier](https://zapier.com). I am a Python Core Developer, and I also help organize the [PyCascades](https://www.pycascades.com) conference.

At PyCascades, [diversity](https://2019.pycascades.com/diversity-and-inclusion/) in our community is a priority, not an afterthought. One of the ways we try to achieve this is by having a strong code of conduct and enforcement. To facilitate the reporting of code of conduct issues, Alan Vezina, one of our organizers, created a [code of conduct (CoC) hotline](https://github.com/cache-rules/coc-hotline). The hotline has since been adopted by PyCon US 2018 and DjangoCon 2018.

Here's how the first PyCascades CoC hotline works. When someone wishes to report a code of conduct issue, they can call the hotline number. At that time, all of our organizers will be notified, and the caller will then be connected to the first organizer who responds. For accountability, information about the call is also posted to a Slack channel, so we have a record of the call.

Since the hotline launched, I've been thinking of ideas for how the hotline can be enhanced for the coming year.

In this blog post, I'm going to show you how I used Nexmo Voice API and Zapier to enhance the PyCascades Code of Conduct Hotline.

These are the features in the enhanced hotline:

* The caller is greeted, letting them know that they've reached PyCascades Code of Conduct Hotline. It is important that the caller knows they've reached the correct number, the official PyCascades Code of Conduct Hotline.
* All calls are automatically recorded. Code of Conduct reporting is an important and sensitive matter. Having a recording helps us to stay accountable, as well as allowing us to go back and replay the call so we don't miss any details.
* Hold music now plays while the caller is waiting to be connected to one of our staff members. 
    
* When an organizer answers the call, the caller will hear a message identifying the organizer: "*Mariatta* is joining this call."
* We've added an alert to let the organizer know that this call is regarding PyCascades Code of Conduct. I screen my calls. I often ignore calls from 1-800 numbers or unknown calls whose number I don't recognize. During the conference period, I need to know whether these calls are regarding Code of Conduct issues (which I should take), or if the calls are a telemarketing call offering me a free cruise (which I will ignore). 
* A ledger of all CoC call activities is now logged in a Google Spreadsheets.

In addition, the following feature still needs to work:

* Info about incoming calls to the CoC hotline posted to Slack. Slack is one of the main ways PyCascades organizers communicate. The Slack message serves as both notification, and a record that a call took place, even if no one answered.

Other technical info:

The hotline is written in Python, and my web framework of choice is [aiohttp](https://aiohttp.readthedocs.io/en/stable/), an async web server and client framework for Python. I've used aiohttp to build GitHub bots like [miss-islington](https://github.com/python/miss-islington) and [black-out](https://github.com/Mariatta/black_out).

The web service is deployed to Heroku. Most of The PSF's web infrastructure is hosted on Heroku, so as a Python core developer, I've been more familiar with Heroku than other types of cloud infrastructure.

One of the main reasons for choosing Nexmo API, for me, is because Nexmo has supported the Python community in many ways including sponsoring PyCon US 2018, DjangoCon 2018 and the first ever PyCascades ? The other reason for choosing Nexmo API is because the nexmo-python library is available open source, and it is compatible with the newer Python versions and tested against Python 3.7.

You can view the source code of the [Enhanced CoC Hotline](https://github.com/Mariatta/enhanced-coc-hotline).

<sign-up></sign-up>

## Nexmo Voice App Setup

First, let me give you a walkthrough of how my Nexmo Voice application is set up.

![Nexmo Voice App settings screenshot](/content/blog/enhancing-pycascades-code-of-conduct-hotline-with-nexmo-voice-api/nexmo_voice_app_settings.png "Nexmo voice app settings")

When setting up a Voice application in Nexmo, you need to configure two webhook URLs, an Event URL and an Answer URL.

The Event URL is always required; this is where Nexmo will send you information whenever there is a change in the state of the call.

## Receiving the Events webhook and logging the activities

The following is an example payload delivered by the Event webhook:

```
{
    "status": "started",
    "direction": "outbound",
    "from": "12025550124",
    "uuid": "80c80c80-80ce-80c8-80c8-80c80c80c80c",
    "conversation_uuid": "CON-be2be2be-a0dd-a0dd-a0dd-34b34b34b34b",
    "timestamp": "2018-10-25T17:42:17.552Z",
    "to": "12025550124"
}
```

It contains information like the caller's number, which number was dialled, the status of the call, the timestamp, and unique call and conversation identifiers. This is all useful information that can be logged so we have records of each activity.

Instead of creating my own web service to receive these webhooks, I've created a Zapier integration. One of the integrations you can use in Zapier is [Webhooks by Zapier](https://zapier.com/page/webhooks/). With Webhooks by Zapier, you can receive data from any service or send requests to any URL without writing code or running servers. In other words, you can receive and give webhooks.

When I created a new Zap using Webhooks by Zapier as the trigger action, Zapier generated a "hooks.zapier.com" URL that I can use for receiving the webhooks. I supplied the hooks.zapier.com URL as the Events URL in Nexmo Voice Application.

![Webhook Trigger Screenshot](/content/blog/enhancing-pycascades-code-of-conduct-hotline-with-nexmo-voice-api/webhook_trigger.png "Webhook Trigger")

Now that I've set up Zapier to receive the events webhook from Nexmo, I can do many things. First, I added a Slack integration, so a message is automatically posted in our private CoC channel about incoming calls to the hotline. Next, I added a Google Sheets integration, so any activities related to the hotline are automatically added as a new row in Google Sheets.

![CoC Events screenshot](/content/blog/enhancing-pycascades-code-of-conduct-hotline-with-nexmo-voice-api/coc_events.png "CoC Events")

## Answering calls

When a caller dials in the number for the hotline, Nexmo will send the payload of that event to the answer URL. The Answer URL needs to return an NCCO ([Nexmo Call Control Object](https://developer.nexmo.com/voice/voice-api/ncco-reference)) that governs this call.

The answer URL is set to my webservice's `/webhook/answer/` URL. ([source code](https://github.com/Mariatta/enhanced-coc-hotline/blob/98b4e1c629ee16a20f7a23a89347fde9cfc06dbb/webservice/__main__.py#L57))

I wanted the caller to be greeted and notified that they've reached the PyCascades Code of Conduct Hotline. Therefore, the first NCCO I returned is a "talk" action:

```python
    ncco = [
        {
            "action": "talk",
            "text": "You've reached the PyCascades Code of Conduct Hotline. This call is recorded."
        }
    ]
```

Next, since I'm now receiving events when a caller has dialled the hotline, I need to call all of our staff members and connect them to the same call. For this, I need to add the caller and the staff into a conference call.

To add callers into a conference call I'll add a "conversation" NCCO action with the same name.

```python
{
            "action": "conversation",
            "name": conversation name,
}
```

So, do I need to make up a "name" for the conversation? Not necessarily. Take a look at the [payload delivered the Answer URL](https://developer.nexmo.com/voice/voice-api/guides/call-flow#answer-url-payload)

An example GET request to the answer_url is as follows:

```
/webhooks/answer?to=447700900000&from=447700900001&conversation_uuid=CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab&uuid=aaaaaaaa-bbbb-cccc-dddd-0123456789cd
```

Notice that the payload includes a `conversation_uuid`. Instead of "making up" new names for the conversation, I decided to use the same `conversation_uuid` as the conversation name.

So I retrieved the `conversation_uuid` from the request and used it in the NCCO.

```python
    conversation_uuid = request.rel_url.query["conversation_uuid"].strip()
    ...
    {
            "action": "conversation",
            "name": conversation_uuid,
            ...
    }
```

To record the conversation, I can specify `"record": True` in the conversation NCCO dictionary. When the recording ends, Nexmo will also send a webhook to the `eventUrl`, and the payload to this webhook will include the url where the recording is stored.

The following is an example payload to the recording `eventUrl` webhook:

```
{
  "start_time": "2020-01-01T12:00:00Z",
  "recording_url": "https://api.nexmo.com/media/download?id=aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "size": 12345,
  "recording_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "end_time": "2020-01-01T12:01:00Z",
  "conversation_uuid": "bbbbbbbb-cccc-dddd-eeee-0123456789ab",
  "timestamp": "2020-01-01T14:00:00.000Z"
}
```

Again, instead of configuring my own web service to receive the webhook, I made use of Webhooks by Zapier. I created a different Zap for receiving the recording webhooks.

![Recording Zapier screenshot](/content/blog/enhancing-pycascades-code-of-conduct-hotline-with-nexmo-voice-api/recording_zap.png "Zapier Recording")

In this Zap, I added a Google Spreadsheet integration, so that the information from the payload, including the `recording_url`, are automatically added as a new row in Google Spreadsheets. In addition, I added a Slack integration so that our staff members are notified of the new recording.

At this point, the conversation NCCO looks like the following:

```python
    conversation_uuid = request.rel_url.query["conversation_uuid"].strip()
    ...
    {
            "action": "conversation",
            "name": conversation_uuid,
            "record": True,
            "eventUrl": [os.environ.get("ZAPIER_CATCH_HOOK_RECORDING_FINISHED_URL")],

            ...
    }
```

At this point, there are two things that I need the hotline to do. First, I need it to call each staff member, so I can add them to the conversation. And second, I need it to play some music while the caller is waiting to be connected.

## Play music while the caller waits

Playing music into this call is quite straightforward. Add the `"musicOnHoldURL"` to the NCCO, and supply a url to the music to be played, for example:

```python
    "musicOnHoldUrl": ["https://..../music.mp3"]
```

I’m using the music from [Wistia’s Music collection](https://wistia.com/resources/music), specifically from The Let ‘Em In Sessions. You can view the license for these music [here](https://github.com/Mariatta/enhanced-coc-hotline/blob/master/wistia_music_-_let_em_in_license_readme.txt). 

```python
    import random
    
    MUSIC_WHILE_YOU_WAIT = [
        "https://assets.ctfassets.net/j7pfe8y48ry3/530pLnJVZmiUu8mkEgIMm2/dd33d28ab6af9a2d32681ae80004886e/oaklawn-dreams.mp3",
        "https://assets.ctfassets.net/j7pfe8y48ry3/2toXv1xuOsMm0Yku0YEGya/a792ce81a7866fc77f6768d416018012/broken-shovel.mp3",
        "https://assets.ctfassets.net/j7pfe8y48ry3/16VJzaewWsKWg4GsSUiwGi/9b715be5e8c850e46de98b64e6d31141/lennys-song.mp3",
        "https://assets.ctfassets.net/j7pfe8y48ry3/1qApZVYkxaiayA6aysGAOo/8983586c8ab4db8b69490718469a12f5/new-juno.mp3",
        "https://assets.ctfassets.net/j7pfe8y48ry3/6iXXKtJCp2oCMiGmsmAKqu/8163a8fe863405292ba3609193593add/davis-square-shuffle.mp3",
    ]
    
    ncco = {
        ...
        "musicOnHoldUrl": [random.choice(MUSIC_WHILE_YOU_WAIT)],
    }
```

## Call the other staff members to the conference call

Now I need to call each of the staff members and add them to this call.

This is not something I can accomplish in the NCCO. So I made use of the [Nexmo Python
client](https://github.com/Nexmo/nexmo-python) library. It can be installed using `pip`, so I added `nexmo` to my requirements.txt file.

I created a helper function for instantiating the client.

```python
    def get_nexmo_client():
        app_id = os.environ.get("NEXMO_APP_ID")
        private_key = os.environ.get("NEXMO_PRIVATE_KEY_VOICE_APP")
    
        client = nexmo.Client(application_id=app_id, private_key=private_key)
        return client
```

I also created a helper function for retrieving the staff phone numbers. The phone numbers are stored as environment variables in Heroku, in the following format:

```
    [
            {
                "name": "Mariatta",
                "phone": "12025550124"
            },
            {
                "name": "Miss Islington",
                "phone": "12025550123"
            }
        ]
```

The helper function is quite straightforward:

```python
    import json
    
    def get_phone_numbers():
        return json.loads(os.environ.get("PHONE_NUMBERS"))
```

Now that I have functions to retrieve the nexmo client, as well as the phone numbers to dial, I can dial the numbers.

To call a number using Nexmo Python client library:

```python
    response = client.create_call({
      'to': [{'type': 'phone', 'number': 12025550124}],
      'from': {'type': 'phone', 'number': 12025550123},
      'answer_url': ['https://example.com/answer']
    })
```

In the `create_call` call method, I needed to supply the `to` phone number, as well as the `from` phone number. The `to` phone number is the staff's phone number that I'd like to call.

For the `from` number, instead of giving the hotline caller's phone number, I used the `hotline` number itself; this way, the staff knows by reading the caller ID that this call is from the hotline.

What about the `answer_url`? The `answer_url` is the webhook for when a staff answers this call. The desired behavior here is that the staff who answered the call gets added to the conversation where the hotline caller is. Therefore, in addition to the Nexmo-provided payload to the webhook, I need to pass in the `conversation_name` (which is the `conversation_uuid`).

I created a new endpoint in my web service to handle this webhook by including both the `conversation_uuid` and the call `uuid` to in the URL:

```python
    @routes.get(
        "/webhook/answer_conference_call/{origin_conversation_uuid}/{origin_call_uuid}/"
    )
    async def answer_conference_call(request):
    
        origin_conversation_uuid = request.match_info["origin_conversation_uuid"]
        origin_call_uuid = request.match_info["origin_call_uuid"]
        ...
```

With this endpoint created, whenever a staff member answers the call from the hotline, I will have a way to find out which conversation to add them to.

Finally, the answer webhook looks like the following:

```python
@routes.get("/webhook/answer/")
async def answer_call(request):
    conversation_uuid = request.rel_url.query["conversation_uuid"].strip()
    call_uuid = request.rel_url.query["uuid"].strip()

    ncco = [
        {
            "action": "talk",
            "text": "You've reached the PyCascades Code of Conduct Hotline. This call is recorded.",
        },
        {
            "action": "conversation",
            "name": conversation_uuid,
            "record": True,
            "eventMethod": "POST",
            "musicOnHoldUrl": [random.choice(MUSIC_WHILE_YOU_WAIT)],
            "eventUrl": [os.environ.get("ZAPIER_CATCH_HOOK_RECORDING_FINISHED_URL")],
            "endOnExit": False,
            "startOnEnter": False,
        },
    ]

    client = get_nexmo_client()
    phone_numbers = get_phone_numbers()

    for phone_number_dict in phone_numbers:
        client.create_call(
            {
                "to": [{"type": "phone", "number": phone_number_dict["phone"]}],
                "from": {
                    "type": "phone",
                    "number": os.environ.get("NEXMO_HOTLINE_NUMBER"),
                },
                "answer_url": [
                    f"https://mariatta-enhanced-coc.herokuapp.com/webhook/answer_conference_call/{conversation_uuid}/{call_uuid}/"
                ],
            }
        )
    return web.json_response(ncco)
```

## Adding Staff Members to the Conference Call

The `answer_conference_call` endpoint was created with the purpose of adding the staff members to the conference call. To accomplish this, I needed to return an NCCO to the webhook that contains a "conversation" action and the name of the conversation. But before they are added, I'd like to greet the staff so they know that they're joining the PyCascades Code of Conduct Hotline.

Recall that the `PHONE_NUMBERS` environment variable also includes the names of the phone number owner.

I created the following function to retrieve the name of the phone number owner:

```python
    def get_phone_number_owner(phone_number):
        phone_numbers = get_phone_numbers()
        for phone_number_info in phone_numbers:
            if phone_number_info["phone"] == phone_number:
                return phone_number_info["name"]
    
        return None
```

With that function, I can greet the staff as follows:

```python
    @routes.get(
        "/webhook/answer_conference_call/{origin_conversation_uuid}/{origin_call_uuid}/"
    )
    async def answer_conference_call(request):
    
        to_phone_number = request.rel_url.query["to"]
        origin_conversation_uuid = request.match_info["origin_conversation_uuid"]
    
        phone_number_owner = get_phone_number_owner(to_phone_number)
    
        ncco = [
            {
                "action": "talk",
                "text": f"Hello {phone_number_owner}, connecting you to PyCascades hotline.",
            },
            {
                "action": "conversation",
                "name": origin_conversation_uuid,
                "startOnEnter": True,
                "endOnExit": True,
            },
        ]
        return web.json_response(ncco)
```

At this time, you might be wondering, what the `origin_call_uuid` is used for. I figured that it could be a nice courtesy to let the hotline caller know that which member of the PyCascades staff is answering their call. Also, remember that this is a conference call, so potentially more than one person may join. Instead of letting someone join silently, I'm giving a heads up to everyone in the call of who just joined.

```python
    client = get_nexmo_client()

    response = client.send_speech(
        origin_call_uuid, text=f"{phone_number_owner} is joining this call."
    )
```

So now the `answer_conference_call` endpoint looks like the following:

```python
    @routes.get(
        "/webhook/answer_conference_call/{origin_conversation_uuid}/{origin_call_uuid}/"
    )
    async def answer_conference_call(request):

        to_phone_number = request.rel_url.query["to"]
        origin_conversation_uuid = request.match_info["origin_conversation_uuid"]
        origin_call_uuid = request.match_info["origin_call_uuid"]
    
        phone_number_owner = get_phone_number_owner(to_phone_number)
        client = get_nexmo_client()
    
        try:
            response = client.send_speech(
                origin_call_uuid, text=f"{phone_number_owner} is joining this call."
            )
        except nexmo.Error as er:
            print(
                f"error sending speech to {origin_call_uuid}, owner is {phone_number_owner}"
            )
            print(er)
    
        else:
            print(f"Successfully notified caller. {response}")
    
        ncco = [
            {
                "action": "talk",
                "text": f"Hello {phone_number_owner}, connecting you to PyCascades hotline.",
            },
            {
                "action": "conversation",
                "name": origin_conversation_uuid,
                "startOnEnter": True,
                "endOnExit": True,
            },
        ]
        return web.json_response(ncco)
```

## The Completed Call Flow

With that, the enhanced PyCascades Code of Conduct is completed.

The complete call flow is as follows:

* A caller dials the hotline.
* PyCascades staff members receive a Slack notification that there is an incoming call to the hotline.
* Information on the call is added to Google Sheets.
* Caller hears a message: "Welcome to the PyCascades Code of Conduct Hotline. This call is recorded."
* Caller hears music while they wait to be connected.
* Each PyCascades staff receive a call from the hotline.
* A PyCascades staff answers the call, and hears, "Hello {staffname}, connecting you to PyCascades hotline."
* Meanwhile, the caller hears the message "{staffname} is joining this call."
* Staff and caller continue the conversation.
* Staff hangs up, at which point the call recording is completed.
* Staff members receive a Slack notification that there is a new recording.
* Information on the recording is also added in Google Sheets.

## Downloading the Recording

The recording can be downloaded by using Nexmo Python client, and the `recording_url` is the url received in the recording events webhook.

```python
    client = get_nexmo_client()
    recording = client.get_recording(recording_url)
```

Call recordings are stored in Nexmo for one month before they get automatically deleted. Since these calls are important and we don't want to lose the recordings, I've created a command line script that can be used to [downloading the recordings](https://github.com/Mariatta/enhanced-coc-hotline/blob/master/download_recording/__main__.py).

The script can be run as follows:

```
    python3 -m download_recording url1 url2 url3 ...
```

Once the script is run, the recordings are downloaded and stored locally in the `recording` directory.

## Conclusions

Thanks to Nexmo and Zapier, I'm able to enhance the PyCascades Code of Conduct hotline. Setting up this hotline does seem to be more complicated than [before](https://github.com/cache-rules/coc-hotline#installation).

However, I believe the new enhancements like auto-recording, auto-logging in Google Spreadsheets are useful to all of our staff members, so I'm willing to spend the extra time to set this up for PyCascades. In addition, by using Zapier instead of hardcoding it, we can be more flexible in case we want to add additional integrations.

Thanks for reading! If you have further questions, regarding the hotline, PyCascades, or Zapier, please do not hesitate to email me at mariatta.wijaya@zapier.com 

- - -

**Note from Nexmo Developer Relations:** We’re super happy Mariatta decided to use Nexmo to help make PyCascades Code of Conduct reporting better. We believe having a CoC is a vital part of creating a welcoming and inclusive space. We’d like to show our support to any conference or meet-up which would like to run a Code of Conduct hotline. If you are an event organiser and you would like to use Mariatta’s Code of Conduct hotline for your event please <a href="mailto:devrel@nexmo.com">email devrel@nexmo.com</a> and we’ll happily support you in setting up the application and with some free Nexmo credit.