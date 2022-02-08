---
title: Dual Channel Transcription with Split Recording
description: The new split recording feature in Nexmo's Voice API allows you to
  record two call participants in their own audio channels, making transcription
  a breeze.
thumbnail: /content/blog/dual-channel-transcription-split-recording-dr/split-recording-dev.png
author: mheap
published: true
published_at: 2018-04-17T10:00:54.000Z
updated_at: 2021-05-12T20:38:21.204Z
category: tutorial
tags:
  - transcription
  - voice-api
comments: true
redirect: ""
canonical: ""
---
As part of our [Voice API](https://developer.nexmo.com/voice/voice-api/overview) offering, Nexmo allows you to record parts (or all) of a call and fetch the audio once the call has completed. Today, we're happy to announce a new enhancement to this functionality: split recording. Split recording makes common tasks such as call transcription even easier.

When split recording is enabled, the downloaded recording will contain participant A (let's call her Alice) in the left channel, and participant B (let's call him Bob) in the right channel. This allows you to work with the audio from a single participant easily.

In this post, we're going to walk through a simple use case. Alice calls the bank to find out information about her account, and Bob is the customer support agent who answers the call.

## Record the Call in Stereo

When Alice calls the number provided by the bank, Nexmo answers the call, plays an introductory message and connects it to the bank's real phone number—recording all of the audio in the call. To accomplish this, you'd use the following [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/api/voice/ncco):

```json
[
  {
    "action": "talk",
    "text": "This call may be recorded for security and quality purposes"
  },
  {
    "action": "record",
    "eventUrl": ["https://example.com/recording"]
  },
  {
    "action": "connect",
    "eventUrl": ["https://example.com/events"],
    "from": "447700900000",
    "endpoint": [
      {
        "type": "phone",
        "number": "447700900001"
      }
    ]
  }
]
```

The important part of this NCCO is the `record` action, which will record the audio and send the URL to `https://example.com/recording` once the call is complete:

```json
{
  "action": "record",
  "eventUrl": ["https://example.com/recording"]
}
```

To enable dual-channel recording, we need to update this action to contain `"split" : "conversation"` like so:

```json
{
  "action": "record",
  "split" : "conversation",
  "eventUrl": ["https://example.com/recording"]
}
```

That's all there is to it! When you [fetch the call recording](https://developer.nexmo.com/voice/voice-api/guides/record-calls-and-conversations) from Nexmo, you'll have Alice's audio in the left channel and Bob's in the right.

## Call Transcription with IBM Watson

Once you have the audio file, it's time to transcribe the text. There aren't many providers that accept dual channel audio and transcribe them separately, so for this post we'll use `ffmpeg` to split the track into two mono tracks and transcribe them separately using [IBM's speech-to-text API](https://www.ibm.com/watson/services/speech-to-text/).

To split your audio file into two files, run the following command in a terminal (you may need to [install](https://www.ffmpeg.org/) `ffmpeg` first):

```bash
ffmpeg -i YOUR_AUDIO_FILE.mp3 -map_channel 0.0.0 left.mp3 -map_channel 0.0.1 right.mp3
```

Now that we have two audio files we can send them to Watson and get the text back as JSON in response. You can use your language of choice to do this, but the quickest way to get things working is by using `curl`:

```bash
curl -X POST -u "USERNAME:PASSWORD" -H 'Content-Type: audio/mpeg' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?timestamps=true" --data-binary @left.mp3 > left.json

curl -X POST -u "USERNAME:PASSWORD" -H 'Content-Type: audio/mpeg' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?timestamps=true" --data-binary @right.mp3 > right.json
```

This will give us two JSON files that look similar to the following:

```json
{
   "results": [
      {
         "alternatives": [
            {
               "timestamps": [
                  [
                     "my",
                     3.83,
                     3.94
                  ],
                  [
                     "name",
                     3.94,
                     4.18
                  ],
                  [
                     "is",
                     4.18,
                     4.31
                  ],
                  [
                     "Alice",
                     4.31,
                     4.96
                  ]
               ],
               "confidence": 0.923,
               "transcript": "my name is Alice "
            }
         ],
         "final": true
      },
      ...
    ]
}
```

## Build the Conversation

As we requested timestamps, we can rebuild a timeline of the conversation as it happened. Once again, you can use your favourite language for this (I'll be using PHP). The steps we have to follow are:


* Loop through JSON and merge all of the entries into a single list.</li>
* Order the entries based on the start timestamp.</li>
* Output the conversation in order, with the timestamp, name, and text shown.</li>

The PHP code to do this looks like the following:

```php
<?php

$left = json_decode(file_get_contents('left.json'))->results;
$right = json_decode(file_get_contents('right.json'))->results;

function mapEntry($input, $name, $conversation = []) {
    foreach ($input as $entry){
        $text = $entry->alternatives[0];
        $conversation[] = [
            'from' => $name,
            'ts' => $text->timestamps[0][2],
            'text' => $text->transcript
        ];
    }
    return $conversation;
}

$conversation = mapEntry($left, 'Alice');
$conversation = mapEntry($right, 'Bob', $conversation);

usort($conversation, function($a, $b) {
    return $a['ts'] > $b['ts'];
});

foreach ($conversation as $c) {
    echo '['.$c['ts'].'s] '.$c['from'].': '.$c['text'].PHP_EOL;
}
```

When we run this code we see our conversation as it happened:

```
[0.63s]  Bob: welcome to the call what's your name
[3.94s]  Alice: my name is Alice
[7.05s]  Bob: how are you feeling today
[10.17s] Alice: great thank you
[11.81s] Bob: how can I help
[13.74s] Alice: I'd like information about my account
[20.1s]  Bob: thank you for the information I'm connecting you to my colleague ashley now
```

### Transcription Made Easy with Split Recording

Nexmo's new split recording feature allows you to record two participants in their own audio channel, making transcription a breeze. To enable the feature, all you have to do is add `"split" : "conversation"` to your `record` action.

To learn more about split recording, you can read our [product blog post](https://www.nexmo.com/blog/2018/04/04/improve-accuracy-call-transcriptions-split-recording/) on the release or [check out the documentation](https://developer.nexmo.com/voice/voice-api/guides/record-calls-and-conversations).