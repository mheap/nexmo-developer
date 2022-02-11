---
title: Stream Last Christmas Into a Phone Call with Python
description: Want to win at Whamageddon? In this tutorial we'll show you how to
  play any mp3, including Last Christmas, into a telephone call with the Nexmo
  Voice API
thumbnail: /content/blog/whamageddon-streaming-last-christmas-into-a-phone-call-dr/Streaming-Last-Christmas-into-a-Phone-Call.png
author: aaron
published: true
published_at: 2018-12-12T00:57:19.000Z
updated_at: 2021-05-10T11:08:06.497Z
category: tutorial
tags:
  - python
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Christmas is an expensive time, but I can help save you a fortune on gifts by ensuring no-one is speaking to you on Christmas day by sending them all to Whamhalla!

Every year my friends and I compete in [Whamageddon](https://www.whamageddon.com), the rules are simple:

1. The objective is to go as long as possible without hearing WHAM's Christmas classic; "Last Christmas"
2. The game starts on December 1st, and ends at midnight on December 24th
3. Only the original version applies
4. You're out as soon as you recognise the song

Anyone who has ever set foot outside, or turned on the radio during Christmas can attest as to how difficult it is to avoid "Last Christmas". From one second past midnight on the 1st of December it's as if every store has it on repeat. Most people play the game defensively, avoiding those places which are most likely to be playing the song. We're not most people though; we're going to go on the attack.

## The Principles of War

![Santa driving a tank](/content/blog/stream-last-christmas-into-a-phone-call-with-python/santa-tank.png "Santa driving a tank")

> Seize, retain, and exploit the initiative. Offensive action is the most effective and decisive way to attain a clearly defined common objective. Offensive operations are the means by which a military force seizes and holds the initiative while maintaining freedom of action and achieving decisive results. This is fundamentally true across all levels of war.

We can win Whamageddon either by avoiding the song until 25th of December or by ensuring all our friends hear it before us, so we're last person standing. We need to find a way to trick them into hearing the song, and without exposing ourselves to it at the same time. No friendly fire incidents, please!

The obvious attack vector is to send them a Youtube link of the song, but Rickrolling has left everyone too wary of clicking on unknown Youtube links. We need a channel they wouldn't suspect.

> Strike the enemy at a time or place or in a manner for which he is unprepared. Surprise can decisively shift the balance of combat power. By seeking surprise, forces can achieve success well out of proportion to the effort expended. Surprise can be in tempo, size of force, direction or location of main effort, and timing. Deception can aid the probability of achieving surprise.

## Streaming Audio into a Phone Call

As much as *Last Christmas* permeates everything this time of year I don't think I've ever answered the phone and heard it. Nobody would ever suspect Wham! is calling. 

We're going to use two APIs to accomplish this, [the Nexmo Voice API](https://developer.nexmo.com/voice/voice-api/overview) to make the outbound call and to play the mp3 to our friends, and [the Spotify API](https://developer.spotify.com/my-applications/#!/applications) to provide a short sample of Last Christmas. Both APIs have Python wrappers to make them easier to work with, and we're going to wrap it all up in a nice CLI so we can eliminate our friends with a single command. When we're finished it is going to look just like this:

![Screencast of our Voice Application CL](/content/blog/stream-last-christmas-into-a-phone-call-with-python/pvpwham-screencast.gif "Screencast of our Voice Application CL")

## Getting Started

You'll need a bit of experience with Python to get this running, and at least version 3.6 as we're using f-strings *(because they're amazing)* as well as a couple of other things:

1. The [source code from GitHub](https://github.com/nexmo-community/PVPWham)
2. A Spotify account and your own [Spotify application](https://developer.spotify.com/my-applications/#!/applications). Make a note of your client id and secret as you'll need to add those to your `.env` later
3. [Ngrok](https://ngrok.com/); if you're not sure what this is for you should [read our ngrok tutorial first](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/)

<sign-up></sign-up>

## Configuration

There is an example `.env.example` file in the repository, rename this to `.env` and start filling in the values. For the `NEXMO_APPLICATION_ID` and `NEXMO_PRIVATE_KEY` you have to [create a new Nexmo Application](https://dashboard.nexmo.com/voice/create-application), you can do this via the Dashboard, remember to save the generated `private.key`  somewhere safe and set the value of `NEXMO_PRIVATE_KEY` to the location of your key.

The script also has several dependencies; I'd recommend [installing them via pipenv](https://pipenv.readthedocs.io/en/latest/), but you can use some other Python dependency management if you prefer.

`pipenv install`

Once you have installed your dependencies ensure you have activated your virtual environment *(this would be `pipenv shell` if you're using pipenv)* and that your shell contains the environmental variables from the `.env` file. Lastly, we need to be able to expose our script to the public internet so that the Nexmo webhooks can reach it. For this we'll use ngrok, don't worry about configuring your tunnel, just make sure ngrok is running. 

`ngrok http 80`

You're now ready to run the script.

`python pvpwham.py NUMBER`

There are a few extra options you can specify, run `python pvpwham.py --help` for more information.

Let's step through some of the more interesting parts of the code in more detail.

## Validating the Number

Ensuring we have a valid phone number to target is crucial, nothing else works without it. So we spend a bit of time validating the number and converting it into the correct format. However, people write phone numbers in a whole range of weird and wonderful ways so if we can't validate it we prompt them to stick to E.164, and even provide a link to more information before they're asked to try again.

```python
while e164_number == False:
    insight_response = nexmo_client.get_basic_number_insight(number=number)
    if insight_response["status"] == 3:
        insight_response = nexmo_client.get_basic_number_insight(
            number=number, country=country
        )

    if insight_response["status"] != 0:
        click.clear()
        click.secho(intro, bg="magenta", fg="green")
        click.secho(
            f"{number} does not appear to be a valid telephone number",
            bg="magenta",
            fg="white",
        )
        click.secho(
            "It might work if you enter it in the E.164 format",
            bg="magenta",
            fg="white",
        )

        if click.confirm(wtf_e164_message):
            click.launch(
                "https://developer.nexmo.com/concepts/guides/glossary#e-164-format"
            )

        if click.confirm(try_number_again_message):
            number = click.prompt("Ok, give it to me in E.164 this time")
        else:
            raise click.BadArgumentUsage(
                click.style(
                    f"{number} does not appear to be a valid number. Try entering it in the E.164 format",
                    bg="red",
                    fg="white",
                    bold=True,
                )
            )
    else:
        e164_number = insight_response["international_format_number"]
```

## Finding an MP3 of the Song

We don't need the whole song; a few seconds should be enough to send someone to Whamhalla. The 30-second preview from Spotify is ideal. The script defaults to "Last Christmas", but you can configure this using the `--track` option.

```python
spotify_client_credentials_manager = SpotifyClientCredentials(
    client_id=os.environ["SPOTIFY_CLIENT_ID"],
    client_secret=os.environ["SPOTIFY_CLIENT_SECRET"],
)
spotify_client = spotipy.Spotify(
    client_credentials_manager=spotify_client_credentials_manager
)
tracks = spotify_client.search(track, limit=1, type="track")

if len(tracks["tracks"]["items"]) == 0:
    raise click.BadOptionUsage(
        track,
        click.style(f"Can't find track: {track}", bg="red", fg="white", bold=True),
    )

track = tracks["tracks"]["items"][0]
```

## Our Server

We have several different Nexmo webhooks we have to handle.

Answer URL - this is called whenever someone answers the call and contains a list of actions for Nexmo to perform. In our case, we're going to tell Nexmo to record the call, to use text-to-speech to read out a short warning to the user *(this is disabled by default but can be enabled using the `--delay` option)*, and finally to stream our Spotify preview into the call

```python
@cherrypy.tools.json_out()
def index(self, **params):
    ncco_file = [
        {
            "action": "record",
            "eventUrl": [f"{self.ngrok_tunnel['public_url']}/recording"],
        }
    ]

    if delay == "short":
        ncco_file.append({"action": "talk", "text": "whamageddon"})
    elif delay == "long":
        ncco_file.append(
            {
                "action": "talk",
                "text": "hang up your phone or prepare to enter Whamhalla",
            }
        )

    ncco_file.append(
        {"action": "stream", "streamUrl": [f"{self.preview_url}?t=mp3"]}
    )

    return ncco_file
```

Recording URL - Once the user has hung up the phone and the call is complete Nexmo hits this webhook with the recording details so we can download the mp3 and listen to our friend's dismay as they realise what has happened.

**NB: We record everything, including the audio that we have streamed into the call. You don't want to send yourself to Whamhalla accidentally as well. You could modify the script to use [split recordings](https://developer.nexmo.com/voice/voice-api/guides/recording#split-recording) to prevent this.**

```python
@cherrypy.expose
def fetch_recording():
    data = cherrypy.request.json
    click.secho("## Fetching Call Recording", bg="green", fg="black", bold=True)
    recording_response = nexmo_client.get_recording(data["recording_url"])

    recordingfile = f"/tmp/{data['recording_uuid']}.mp3"
    os.makedirs(os.path.dirname(recordingfile), exist_ok=True)

    with open(recordingfile, "wb") as f:
        f.write(recording_response)

    click.secho("## Call Recording Saved", bg="green", fg="black", bold=True)
    if click.confirm(
        click.style(
            "## Listen to your friend's anguish now?", bg="magenta", fg="white"
        )
    ):
        click.launch(recordingfile)
```

Events URL - This is purely for informational purposes. The script updates the terminal with the latest status it receives via the events webhook.

```python
@cherrypy.expose
@cherrypy.tools.json_in()
def events(self):
    data = cherrypy.request.json
    click.secho(
        f"## Status: {data['status']}", bg="blue", fg="white", bold=True
    )
    return "OK"
```

## Housekeeping

Whenever the call has completed, we have an `on_end_request` hook which does some tidying up. We shut down our Cherrypy server and kill our Ngrok tunnel.

```python
def quit_cherry():
    cherrypy.engine.exit()
    click.secho("## Exiting NCCO Server", bg="blue", fg="white", bold=True)
    requests.delete("http://localhost:4040/api/tunnels/pvpwham")
    click.secho("## Closing tunnel", bg="blue", fg="white", bold=True)
```

## Some Other Fun Commands

You can find some pretty strange things on Spotify if you're creative enough.

`python pvpwham.py NUMBER --track='Rick Astley Never gonna give you up'`

`python pvpwham.py NUMBER --track='Sound Effects Animals Chimps, Apes'`

`python pvpwham.py NUMBER --track='Halloween Sound effects machine ghostly whispers'`

## What Next?

> Direct every military operation toward a clearly defined, decisive and attainable objective. The ultimate military purpose of war is the destruction of the enemy's ability to fight and will to fight.

Even if you don't manage to eliminate all your friends, hopefully the survivors are going to be so anxious every time the phone rings that they'll surrender. Walking into their local shopping centre to sit and wait for the inevitable.

Then after you have crushed the opposition have a look at some of the less militant uses for the Voice API:

* [Building a Voice Broadcast system for critical notifications](https://www.nexmo.com/blog/2017/10/05/fast-voice-broadcast-python-dr/)
* [Using IVR and the Voice API to build a family hotline](https://www.nexmo.com/blog/2018/11/20/build-a-family-hotline-dr/)
* [Triggering Voice calls from wearables *(to escape a bad date)*](https://www.nexmo.com/blog/2018/03/02/getting-bad-date-fitbit-nexmo-dr/)
* [Creating a Code of Conduct hotline](https://www.nexmo.com/blog/2018/11/15/pycascades-code-of-conduct-hotline-nexmo-voice-api-dr/)