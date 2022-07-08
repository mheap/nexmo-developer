---
title: Text to Speech
description: Using our Text-To-Speech engine, you can play machine-generated speech to your callers
navigation_weight: 3
---

# Text to Speech

## Overview

Vonage uses text-to-speech engines to allow you to play machine
generated speech to your users. This can either be done via an NCCO
with the use of the `talk` action, or by [making a PUT request](/api/voice#startTalk) to an
in-progress call.

> You can customize how speech is read out by using [Speech Synthesis Markup Language (SSML)](/voice/voice-api/guides/customizing-tts)

## Example

The following NCCO demonstrates an example use case:

``` json
[
  {
    "action": "talk",
    "text": "Thank you for calling. Please leave your message after the tone."
  }
]
```
## Locale

You should choose a locale that matches the language type of the text
you are asking to be read, trying to read Spanish with an `en-us`
voice for example will not produce good results.

You can set the language code ([BCP-47](https://tools.ietf.org/html/bcp47)) with a `language` parameter in the `talk` command,
if you do not specify a language then Vonage will default to an `en-US` voice. 
For many languages Vonage offers a choice of voices with different styles. The `style` parameter maps to features such as 
vocal range, timbre and tessitura of the selected voice. You can experiment with different styles to find the one appropriate
for your use case. You can choose a specific voice style by using the `style` parameter. By default, the first style (`0`) is used.
Please note not all the voice styles support [SSML](/voice/voice-api/guides/customizing-tts), 
see the list of all the supported languages and SSML enabled styles below.

NCCO example with specific voice language and style:

``` json
[
  {
    "action": "talk",
    "text": "Obrigado pela sua chamada. Por favor, deixe sua mensagem após o sinal.",
    "language": "pt-PT",
    "style": 6
  }
]
```

### Premium Voices

Some voice styles come with a premium alternative, which through the use of AI, have a more natural sound. To use a premium voice style, add the `premium` option in your NCCO:

``` json
[
  {
    "action": "talk",
    "text": "Obrigado pela sua chamada. Por favor, deixe sua mensagem após o sinal.",
    "language": "pt-PT",
    "style": 6,
    "premium": true
  }
]
```

> Premium Voices are chargeable at a rate of €0.0027 per 100 characters.


### Supported Languages

| Language                       | Code      | Style | Premium | [SSML](/voice/voice-api/guides/customizing-tts) Support | Sample                                      |
|--------------------------------|-----------|:-----:|:-------:|:-------------------------------------------------------:|---------------------------------------------|
| Afrikaans                      | af-ZA     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/af-ZA-0.mp3]          |
| Arabic                         | ar        |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ar-0.mp3]             |
| Arabic                         | ar        |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ar-1.mp3]             |
| Arabic                         | ar        |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ar-1-premium.mp3]     |
| Arabic                         | ar        |   2   |         |                                                         | 🔈[/audio/tts-samples/ar-2.mp3]             |
| Arabic                         | ar        |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/ar-3.mp3]             |
| Arabic                         | ar        |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ar-3-premium.mp3]     |
| Arabic                         | ar        |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/ar-4.mp3]             |
| Arabic                         | ar        |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ar-4-premium.mp3]     |
| Arabic                         | ar        |   5   |         |                                                         | 🔈[/audio/tts-samples/ar-5.mp3]             |
| Arabic                         | ar        |   6   |         |                                                         | 🔈[/audio/tts-samples/ar-6.mp3]             |
| Arabic                         | ar        |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/ar-7.mp3]             |
| Arabic                         | ar        |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ar-7-premium.mp3]     |
| Basque                         | eu-ES     |   0   |         |                                                         | 🔈[/audio/tts-samples/eu-ES-0.mp3]          |
| Bengali                        | bn-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/bn-IN-0.mp3]          |
| Bengali                        | bn-IN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/bn-IN-0-premium.mp3]  |
| Bengali                        | bn-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/bn-IN-1.mp3]          |
| Bengali                        | bn-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/bn-IN-1-premium.mp3]  |
| Bulgarian                      | bg-BG     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/bg-BG-0.mp3]          |
| Catalan, Valencian             | ca-ES     |   0   |         |                                                         | 🔈[/audio/tts-samples/ca-ES-0.mp3]          |
| Catalan, Valencian             | ca-ES     |   1   |         |                                                         | 🔈[/audio/tts-samples/ca-ES-1.mp3]          |
| Catalan, Valencian             | ca-ES     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ca-ES-2.mp3]          |
| Chinese, Cantonese (China)     | yue-CN    |   0   |         |                                                         | 🔈[/audio/tts-samples/yue-CN-0.mp3]         |
| Chinese, Cantonese (Hong Kong) | yue-HK    |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/yue-HK-0.mp3]         |
| Chinese, Cantonese (Hong Kong) | yue-HK    |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/yue-HK-1.mp3]         |
| Chinese, Cantonese (Hong Kong) | yue-HK    |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/yue-HK-2.mp3]         |
| Chinese, Cantonese (Hong Kong) | yue-HK    |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/yue-HK-3.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-0.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-1.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-1-premium.mp3] |
| Chinese, Mandarin (China)      | cmn-CN    |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-2.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-2-premium.mp3] |
| Chinese, Mandarin (China)      | cmn-CN    |   3   |         |                                                         | 🔈[/audio/tts-samples/cmn-CN-3.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-4.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-4-premium.mp3] |
| Chinese, Mandarin (China)      | cmn-CN    |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-5.mp3]         |
| Chinese, Mandarin (China)      | cmn-CN    |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-CN-5-premium.mp3] |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   0   |         |                                                         | 🔈[/audio/tts-samples/cmn-TW-0.mp3]         |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-1.mp3]         |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-1-premium.mp3] |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-2.mp3]         |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-2-premium.mp3] |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-3.mp3]         |
| Chinese, Mandarin (Taiwan)     | cmn-TW    |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cmn-TW-3-premium.mp3] |
| Czech                          | cs-CZ     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/cs-CZ-0.mp3]          |
| Czech                          | cs-CZ     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/cs-CZ-0-premium.mp3]  |
| Czech                          | cs-CZ     |   1   |         |                                                         | 🔈[/audio/tts-samples/cs-CZ-1.mp3]          |
| Czech                          | cs-CZ     |   2   |         |                                                         | 🔈[/audio/tts-samples/cs-CZ-2.mp3]          |
| Danish                         | da-DK     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-0.mp3]          |
| Danish                         | da-DK     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-1.mp3]          |
| Danish                         | da-DK     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-1-premium.mp3]  |
| Danish                         | da-DK     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-2.mp3]          |
| Danish                         | da-DK     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-3.mp3]          |
| Danish                         | da-DK     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-3-premium.mp3]  |
| Danish                         | da-DK     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-4.mp3]          |
| Danish                         | da-DK     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-4-premium.mp3]  |
| Danish                         | da-DK     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-5.mp3]          |
| Danish                         | da-DK     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/da-DK-5-premium.mp3]  |
| Dutch (Belgium)                | nl-BE     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-BE-0.mp3]          |
| Dutch (Belgium)                | nl-BE     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-BE-0-premium.mp3]  |
| Dutch (Belgium)                | nl-BE     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-BE-2.mp3]          |
| Dutch (Belgium)                | nl-BE     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-BE-2-premium.mp3]  |
| Dutch (Netherlands)            | nl-NL     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-0.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-1.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-1-premium.mp3]  |
| Dutch (Netherlands)            | nl-NL     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-2.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-2-premium.mp3]  |
| Dutch (Netherlands)            | nl-NL     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-3.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-3-premium.mp3]  |
| Dutch (Netherlands)            | nl-NL     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-4.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-5.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-5-premium.mp3]  |
| Dutch (Netherlands)            | nl-NL     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-6.mp3]          |
| Dutch (Netherlands)            | nl-NL     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nl-NL-6-premium.mp3]  |
| English (Australia)            | en-AU     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-0.mp3]          |
| English (Australia)            | en-AU     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-1.mp3]          |
| English (Australia)            | en-AU     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-1-premium.mp3]  |
| English (Australia)            | en-AU     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-2.mp3]          |
| English (Australia)            | en-AU     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-2-premium.mp3]  |
| English (Australia)            | en-AU     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-3.mp3]          |
| English (Australia)            | en-AU     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-4.mp3]          |
| English (Australia)            | en-AU     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-4-premium.mp3]  |
| English (Australia)            | en-AU     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-5.mp3]          |
| English (Australia)            | en-AU     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-AU-5-premium.mp3]  |
| English (India)                | en-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-0.mp3]          |
| English (India)                | en-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-1.mp3]          |
| English (India)                | en-IN     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-2.mp3]          |
| English (India)                | en-IN     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-2-premium.mp3]  |
| English (India)                | en-IN     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-3.mp3]          |
| English (India)                | en-IN     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-3-premium.mp3]  |
| English (India)                | en-IN     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-4.mp3]          |
| English (India)                | en-IN     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-4-premium.mp3]  |
| English (India)                | en-IN     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-5.mp3]          |
| English (India)                | en-IN     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-IN-5-premium.mp3]  |
| English (India)                | en-IN     |   6   |         |                                                         | 🔈[/audio/tts-samples/en-IN-6.mp3]          |
| English (South Africa)         | en-ZA     |   0   |         |                                                         | 🔈[/audio/tts-samples/en-ZA-0.mp3]          |
| English (United Kingdom)       | en-GB     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-0.mp3]          |
| English (United Kingdom)       | en-GB     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-1.mp3]          |
| English (United Kingdom)       | en-GB     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-2.mp3]          |
| English (United Kingdom)       | en-GB     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-2-premium.mp3]  |
| English (United Kingdom)       | en-GB     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-3.mp3]          |
| English (United Kingdom)       | en-GB     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-3-premium.mp3]  |
| English (United Kingdom)       | en-GB     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-4.mp3]          |
| English (United Kingdom)       | en-GB     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-5-premium.mp3]  |
| English (United Kingdom)       | en-GB     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-5.mp3]          |
| English (United Kingdom)       | en-GB     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-6.mp3]          |
| English (United Kingdom)       | en-GB     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-6-premium.mp3]  |
| English (United Kingdom)       | en-GB     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-7.mp3]          |
| English (United Kingdom)       | en-GB     |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-7-premium.mp3]  |
| English (United Kingdom)       | en-GB     |   9   |         |                                                         | 🔈[/audio/tts-samples/en-GB-9.mp3]          |
| English (United States)        | en-US     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-0.mp3]          |
| English (United States)        | en-US     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-1.mp3]          |
| English (United States)        | en-US     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-2.mp3]          |
| English (United States)        | en-US     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-3.mp3]          |
| English (United States)        | en-US     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-4.mp3]          |
| English (United States)        | en-US     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-5.mp3]          |
| English (United States)        | en-US     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-5-premium.mp3]  |
| English (United States)        | en-US     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-6.mp3]          |
| English (United States)        | en-US     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-6-premium.mp3]  |
| English (United States)        | en-US     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-7.mp3]          |
| English (United States)        | en-US     |   8   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-8.mp3]          |
| English (United States)        | en-US     |   9   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-9.mp3]          |
| English (United States)        | en-US     |  10   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-10.mp3]         |
| English (United States)        | en-US     |  10   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-10-premium.mp3] |
| English (United States)        | en-US     |  11   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-11.mp3]         |
| English (United States)        | en-US     |  11   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-11-premium.mp3] |
| English (United States)        | en-US     |  12   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-12.mp3]         |
| English (United States)        | en-US     |  12   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-12-premium.mp3] |
| English (United States)        | en-US     |  13   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-13.mp3]         |
| English (United States)        | en-US     |  13   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-13-premium.mp3] |
| English (United States)        | en-US     |  14   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-14.mp3]         |
| English (United States)        | en-US     |  14   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-14-premium.mp3] |
| English (United States)        | en-US     |  15   |         |                                                         | 🔈[/audio/tts-samples/en-US-15.mp3]         |
| English (United States)        | en-US     |  16   |         |                                                         | 🔈[/audio/tts-samples/en-US-16.mp3]         |
| English (United States)        | en-US     |  17   |         |                                                         | 🔈[/audio/tts-samples/en-US-17.mp3]         |
| English (United States)        | en-US     |  18   |         |                                                         | 🔈[/audio/tts-samples/en-US-18.mp3]         |
| English (United States)        | en-US     |  19   |         |                                                         | 🔈[/audio/tts-samples/en-US-19.mp3]         |
| English (United States)        | en-US     |  20   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-20.mp3]         |
| English (United States)        | en-US     |  20   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-20-premium.mp3] |
| English (United States)        | en-US     |  21   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-21.mp3]         |
| English (United States)        | en-US     |  21   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-21-premium.mp3] |
| English (United States)        | en-US     |  22   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-US-22.mp3]         |
| English (United States)        | en-US     |  22   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/en-US-22-premium.mp3] |
| English (United States)        | en-US     |  23   |         |                                                         | 🔈[/audio/tts-samples/en-US-23.mp3]         |
| English (Wales)                | en-GB-WLS |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/en-GB-WLS-0.mp3]      |
| Filipino                       | fil-PH    |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-0.mp3]         |
| Filipino                       | fil-PH    |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-0-premium.mp3] |
| Filipino                       | fil-PH    |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-1.mp3]         |
| Filipino                       | fil-PH    |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-1-premium.mp3] |
| Filipino                       | fil-PH    |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-2.mp3]         |
| Filipino                       | fil-PH    |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-2-premium.mp3] |
| Filipino                       | fil-PH    |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-3.mp3]         |
| Filipino                       | fil-PH    |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fil-PH-3-premium.mp3] |
| Finnish                        | fi-FI     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/fi-FI-0.mp3]          |
| Finnish                        | fi-FI     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fi-FI-0-premium.mp3]  |
| Finnish                        | fi-FI     |   1   |         |                                                         | 🔈[/audio/tts-samples/fi-FI-1.mp3]          |
| French (Canada)                | fr-CA     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-0.mp3]          |
| French (Canada)                | fr-CA     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-1.mp3]          |
| French (Canada)                | fr-CA     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-1-premium.mp3]  |
| French (Canada)                | fr-CA     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-2.mp3]          |
| French (Canada)                | fr-CA     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-2-premium.mp3]  |
| French (Canada)                | fr-CA     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-3.mp3]          |
| French (Canada)                | fr-CA     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-3-premium.mp3]  |
| French (Canada)                | fr-CA     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-4.mp3]          |
| French (Canada)                | fr-CA     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-CA-4-premium.mp3]  |
| French (France)                | fr-FR     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-0.mp3]          |
| French (France)                | fr-FR     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-1.mp3]          |
| French (France)                | fr-FR     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-2.mp3]          |
| French (France)                | fr-FR     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-2-premium.mp3]  |
| French (France)                | fr-FR     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-3.mp3]          |
| French (France)                | fr-FR     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-3-premium.mp3]  |
| French (France)                | fr-FR     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-4.mp3]          |
| French (France)                | fr-FR     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-4-premium.mp3]  |
| French (France)                | fr-FR     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-5.mp3]          |
| French (France)                | fr-FR     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-6.mp3]          |
| French (France)                | fr-FR     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-6-premium.mp3]  |
| French (France)                | fr-FR     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-7.mp3]          |
| French (France)                | fr-FR     |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/fr-FR-7-premium.mp3]  |
| French (France)                | fr-FR     |   8   |         |                                                         | 🔈[/audio/tts-samples/fr-FR-8.mp3]          |
| French (France)                | fr-FR     |   9   |         |                                                         | 🔈[/audio/tts-samples/fr-FR-9.mp3]          |
| German                         | de-DE     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-0.mp3]          |
| German                         | de-DE     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-1.mp3]          |
| German                         | de-DE     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-2.mp3]          |
| German                         | de-DE     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-2-premium.mp3]  |
| German                         | de-DE     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-3.mp3]          |
| German                         | de-DE     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-4.mp3]          |
| German                         | de-DE     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-4-premium.mp3]  |
| German                         | de-DE     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-5.mp3]          |
| German                         | de-DE     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-5-premium.mp3]  |
| German                         | de-DE     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-6.mp3]          |
| German                         | de-DE     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-6-premium.mp3]  |
| German                         | de-DE     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-7.mp3]          |
| German                         | de-DE     |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-7-premium.mp3]  |
| German                         | de-DE     |   8   |         |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-8.mp3]          |
| German                         | de-DE     |   8   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/de-DE-8-premium.mp3]  |
| German                         | de-DE     |   9   |         |                                                         | 🔈[/audio/tts-samples/de-DE-9.mp3]          |
| German                         | de-DE     |  10   |         |                                                         | 🔈[/audio/tts-samples/de-DE-10.mp3]         |
| Greek                          | el-GR     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/el-GR-0.mp3]          |
| Greek                          | el-GR     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/el-GR-0-premium.mp3]  |
| Greek                          | el-GR     |   1   |         |                                                         | 🔈[/audio/tts-samples/el-GR-1.mp3]          |
| Greek                          | el-GR     |   2   |         |                                                         | 🔈[/audio/tts-samples/el-GR-2.mp3]          |
| Gujarati                       | gu-IN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/gu-IN-0-premium.mp3]  |
| Gujarati                       | gu-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/gu-IN-1-premium.mp3]  |
| Hebrew                         | he-IL     |   0   |         |                                                         | 🔈[/audio/tts-samples/he-IL-0.mp3]          |
| Hindi                          | hi-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-0.mp3]          |
| Hindi                          | hi-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-1.mp3]          |
| Hindi                          | hi-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-1-premium.mp3]  |
| Hindi                          | hi-IN     |   2   |         |                                                         | 🔈[/audio/tts-samples/hi-IN-2.mp3]          |
| Hindi                          | hi-IN     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-3.mp3]          |
| Hindi                          | hi-IN     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-3-premium.mp3]  |
| Hindi                          | hi-IN     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-4.mp3]          |
| Hindi                          | hi-IN     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-4-premium.mp3]  |
| Hindi                          | hi-IN     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-5.mp3]          |
| Hindi                          | hi-IN     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/hi-IN-5-premium.mp3]  |
| Hungarian                      | hu-HU     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/hu-HU-0.mp3]          |
| Hungarian                      | hu-HU     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/hu-HU-0-premium.mp3]  |
| Hungarian                      | hu-HU     |   1   |         |                                                         | 🔈[/audio/tts-samples/hu-HU-1.mp3]          |
| Icelandic                      | is-IS     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/is-IS-0.mp3]          |
| Icelandic                      | is-IS     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/is-IS-1.mp3]          |
| Icelandic                      | is-IS     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/is-IS-2.mp3]          |
| Indonesian                     | id-ID     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-0.mp3]          |
| Indonesian                     | id-ID     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-0-premium.mp3]  |
| Indonesian                     | id-ID     |   1   |         |                                                         | 🔈[/audio/tts-samples/id-ID-1.mp3]          |
| Indonesian                     | id-ID     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-2.mp3]          |
| Indonesian                     | id-ID     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-2-premium.mp3]  |
| Indonesian                     | id-ID     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-3.mp3]          |
| Indonesian                     | id-ID     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-3-premium.mp3]  |
| Indonesian                     | id-ID     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-4.mp3]          |
| Indonesian                     | id-ID     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/id-ID-4-premium.mp3]  |
| Italian                        | it-IT     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-0.mp3]          |
| Italian                        | it-IT     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-1.mp3]          |
| Italian                        | it-IT     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-2.mp3]          |
| Italian                        | it-IT     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-2-premium.mp3]  |
| Italian                        | it-IT     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-3.mp3]          |
| Italian                        | it-IT     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-3-premium.mp3]  |
| Italian                        | it-IT     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-4.mp3]          |
| Italian                        | it-IT     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-5.mp3]          |
| Italian                        | it-IT     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-5-premium.mp3]  |
| Italian                        | it-IT     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-6.mp3]          |
| Italian                        | it-IT     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/it-IT-6-premium.mp3]  |
| Japanese                       | ja-JP     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-0.mp3]          |
| Japanese                       | ja-JP     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-1.mp3]          |
| Japanese                       | ja-JP     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-1-premium.mp3]  |
| Japanese                       | ja-JP     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-2.mp3]          |
| Japanese                       | ja-JP     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-2-premium.mp3]  |
| Japanese                       | ja-JP     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-3.mp3]          |
| Japanese                       | ja-JP     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-4.mp3]          |
| Japanese                       | ja-JP     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-4-premium.mp3]  |
| Japanese                       | ja-JP     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-5.mp3]          |
| Japanese                       | ja-JP     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ja-JP-5-premium.mp3]  |
| Kannada                        | kn-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/kn-IN-0.mp3]          |
| Kannada                        | kn-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/kn-IN-1.mp3]          |
| Korean                         | ko-KR     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-0.mp3]          |
| Korean                         | ko-KR     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-1.mp3]          |
| Korean                         | ko-KR     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-1-premium.mp3]  |
| Korean                         | ko-KR     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-2.mp3]          |
| Korean                         | ko-KR     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-2-premium.mp3]  |
| Korean                         | ko-KR     |   3   |         |                                                         | 🔈[/audio/tts-samples/ko-KR-3.mp3]          |
| Korean                         | ko-KR     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-4.mp3]          |
| Korean                         | ko-KR     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-4-premium.mp3]  |
| Korean                         | ko-KR     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-5.mp3]          |
| Korean                         | ko-KR     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ko-KR-5-premium.mp3]  |
| Latvian                        | lv-LV     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/lv-LV-0.mp3]          |
| Malay                          | ms-MY     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-0.mp3]          |
| Malay                          | ms-MY     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-0-premium.mp3]  |
| Malay                          | ms-MY     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-1.mp3]          |
| Malay                          | ms-MY     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-1-premium.mp3]  |
| Malay                          | ms-MY     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-2.mp3]          |
| Malay                          | ms-MY     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-2-premium.mp3]  |
| Malay                          | ms-MY     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-3.mp3]          |
| Malay                          | ms-MY     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ms-MY-3-premium.mp3]  |
| Malayalam                      | ml-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ml-IN-0.mp3]          |
| Malayalam                      | ml-IN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ml-IN-0-premium.mp3]  |
| Malayalam                      | ml-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ml-IN-1.mp3]          |
| Malayalam                      | ml-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ml-IN-1-premium.mp3]  |
| Norwegian                      | nb-NO     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-0.mp3]          |
| Norwegian                      | nb-NO     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-1.mp3]          |
| Norwegian                      | nb-NO     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-1-premium.mp3]  |
| Norwegian                      | nb-NO     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-2.mp3]          |
| Norwegian                      | nb-NO     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-2-premium.mp3]  |
| Norwegian                      | nb-NO     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-3.mp3]          |
| Norwegian                      | nb-NO     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-3-premium.mp3]  |
| Norwegian                      | nb-NO     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-4.mp3]          |
| Norwegian                      | nb-NO     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-4-premium.mp3]  |
| Norwegian                      | nb-NO     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-5.mp3]          |
| Norwegian                      | nb-NO     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/nb-NO-5-premium.mp3]  |
| Norwegian                      | nb-NO     |   6   |         |                                                         | 🔈[/audio/tts-samples/nb-NO-6.mp3]          |
| Norwegian                      | nb-NO     |   7   |         |                                                         | 🔈[/audio/tts-samples/nb-NO-7.mp3]          |
| Polish                         | pl-PL     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-0.mp3]          |
| Polish                         | pl-PL     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-1.mp3]          |
| Polish                         | pl-PL     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-2.mp3]          |
| Polish                         | pl-PL     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-2-premium.mp3]  |
| Polish                         | pl-PL     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-3.mp3]          |
| Polish                         | pl-PL     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-3-premium.mp3]  |
| Polish                         | pl-PL     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-4.mp3]          |
| Polish                         | pl-PL     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-4-premium.mp3]  |
| Polish                         | pl-PL     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-5.mp3]          |
| Polish                         | pl-PL     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-6.mp3]          |
| Polish                         | pl-PL     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-7.mp3]          |
| Polish                         | pl-PL     |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-7-premium.mp3]  |
| Polish                         | pl-PL     |   8   |         |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-8.mp3]          |
| Polish                         | pl-PL     |   8   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pl-PL-8-premium.mp3]  |
| Portuguese (Brazil)            | pt-BR     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-BR-0.mp3]          |
| Portuguese (Brazil)            | pt-BR     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-BR-1.mp3]          |
| Portuguese (Brazil)            | pt-BR     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pt-BR-1-premium.mp3]  |
| Portuguese (Brazil)            | pt-BR     |   2   |         |                                                         | 🔈[/audio/tts-samples/pt-BR-2.mp3]          |
| Portuguese (Brazil)            | pt-BR     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-BR-3.mp3]          |
| Portuguese (Brazil)            | pt-BR     |   4   |         |                                                         | 🔈[/audio/tts-samples/pt-BR-4.mp3]          |
| Portuguese (Brazil)            | pt-BR     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-BR-5.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-0.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-1.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-1-premium.mp3]  |
| Portuguese (Portugal)          | pt-PT     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-2.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-2-premium.mp3]  |
| Portuguese (Portugal)          | pt-PT     |   3   |         |                                                         | 🔈[/audio/tts-samples/pt-PT-3.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   4   |         |                                                         | 🔈[/audio/tts-samples/pt-PT-4.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-5.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-6.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-6-premium.mp3]  |
| Portuguese (Portugal)          | pt-PT     |   7   |         |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-7.mp3]          |
| Portuguese (Portugal)          | pt-PT     |   7   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pt-PT-7-premium.mp3]  |
| Punjabi                        | pa-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-0.mp3]          |
| Punjabi                        | pa-IN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-0-premium.mp3]  |
| Punjabi                        | pa-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-1.mp3]          |
| Punjabi                        | pa-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-1-premium.mp3]  |
| Punjabi                        | pa-IN     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-2.mp3]          |
| Punjabi                        | pa-IN     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-2-premium.mp3]  |
| Punjabi                        | pa-IN     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-3.mp3]          |
| Punjabi                        | pa-IN     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/pa-IN-3-premium.mp3]  |
| Romanian                       | ro-RO     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ro-RO-0.mp3]          |
| Romanian                       | ro-RO     |   1   |         |                                                         | 🔈[/audio/tts-samples/ro-RO-1.mp3]          |
| Romanian                       | ro-RO     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ro-RO-2.mp3]          |
| Romanian                       | ro-RO     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ro-RO-2-premium.mp3]  |
| Russian                        | ru-RU     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-0.mp3]          |
| Russian                        | ru-RU     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-1.mp3]          |
| Russian                        | ru-RU     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-1-premium.mp3]  |
| Russian                        | ru-RU     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-2.mp3]          |
| Russian                        | ru-RU     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-2-premium.mp3]  |
| Russian                        | ru-RU     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-3.mp3]          |
| Russian                        | ru-RU     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-3-premium.mp3]  |
| Russian                        | ru-RU     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-4.mp3]          |
| Russian                        | ru-RU     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-5.mp3]          |
| Russian                        | ru-RU     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-5-premium.mp3]  |
| Russian                        | ru-RU     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-6.mp3]          |
| Russian                        | ru-RU     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ru-RU-6-premium.mp3]  |
| Serbian                        | sr-RS     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/sr-RS-0.mp3]          |
| Slovak                         | sk-SK     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/sk-SK-0.mp3]          |
| Slovak                         | sk-SK     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/sk-SK-0-premium.mp3]  |
| Slovak                         | sk-SK     |   1   |         |                                                         | 🔈[/audio/tts-samples/sk-SK-1.mp3]          |
| Spanish (Mexico)               | es-MX     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-MX-0.mp3]          |
| Spanish (Spain)                | es-ES     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-0.mp3]          |
| Spanish (Spain)                | es-ES     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-1.mp3]          |
| Spanish (Spain)                | es-ES     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-2.mp3]          |
| Spanish (Spain)                | es-ES     |   3   |         |                                                         | 🔈[/audio/tts-samples/es-ES-3.mp3]          |
| Spanish (Spain)                | es-ES     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-4.mp3]          |
| Spanish (Spain)                | es-ES     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-5.mp3]          |
| Spanish (Spain)                | es-ES     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-5-premium.mp3]  |
| Spanish (Spain)                | es-ES     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-6.mp3]          |
| Spanish (Spain)                | es-ES     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-6-premium.mp3]  |
| Spanish (Spain)                | es-ES     |   7   |         |                                                         | 🔈[/audio/tts-samples/es-ES-7.mp3]          |
| Spanish (Spain)                | es-ES     |   8   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-8.mp3]          |
| Spanish (Spain)                | es-ES     |   8   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-ES-8-premium.mp3]  |
| Spanish (United States)        | es-US     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-0.mp3]          |
| Spanish (United States)        | es-US     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-1.mp3]          |
| Spanish (United States)        | es-US     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-2.mp3]          |
| Spanish (United States)        | es-US     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-3.mp3]          |
| Spanish (United States)        | es-US     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-US-3-premium.mp3]  |
| Spanish (United States)        | es-US     |   4   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-4.mp3]          |
| Spanish (United States)        | es-US     |   4   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-US-4-premium.mp3]  |
| Spanish (United States)        | es-US     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/es-US-5.mp3]          |
| Spanish (United States)        | es-US     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/es-US-5-premium.mp3]  |
| Swedish                        | sv-SE     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/sv-SE-0.mp3]          |
| Swedish                        | sv-SE     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/sv-SE-1.mp3]          |
| Swedish                        | sv-SE     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/sv-SE-1-premium.mp3]  |
| Swedish                        | sv-SE     |   2   |         |                                                         | 🔈[/audio/tts-samples/sv-SE-2.mp3]          |
| Swedish                        | sv-SE     |   3   |         |                                                         | 🔈[/audio/tts-samples/sv-SE-3.mp3]          |
| Tamil                          | ta-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/ta-IN-0.mp3]          |
| Tamil                          | ta-IN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ta-IN-0-premium.mp3]  |
| Tamil                          | ta-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/ta-IN-1.mp3]          |
| Tamil                          | ta-IN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/ta-IN-1-premium.mp3]  |
| Telugu                         | te-IN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/te-IN-0.mp3]          |
| Telugu                         | te-IN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/te-IN-1.mp3]          |
| Thai                           | th-TH     |   0   |         |                                                         | 🔈[/audio/tts-samples/th-TH-0.mp3]          |
| Thai                           | th-TH     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/th-TH-1.mp3]          |
| Turkish                        | tr-TR     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-0.mp3]          |
| Turkish                        | tr-TR     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-1.mp3]          |
| Turkish                        | tr-TR     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-1-premium.mp3]  |
| Turkish                        | tr-TR     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-2.mp3]          |
| Turkish                        | tr-TR     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-2-premium.mp3]  |
| Turkish                        | tr-TR     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-3.mp3]          |
| Turkish                        | tr-TR     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-3-premium.mp3]  |
| Turkish                        | tr-TR     |   4   |         |                                                         | 🔈[/audio/tts-samples/tr-TR-4.mp3]          |
| Turkish                        | tr-TR     |   5   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-5.mp3]          |
| Turkish                        | tr-TR     |   5   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-5-premium.mp3]  |
| Turkish                        | tr-TR     |   6   |         |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-6.mp3]          |
| Turkish                        | tr-TR     |   6   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/tr-TR-6-premium.mp3]  |
| Turkish                        | tr-TR     |   7   |         |                                                         | 🔈[/audio/tts-samples/tr-TR-7.mp3]          |
| Ukrainian                      | uk-UA     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/uk-UA-0.mp3]          |
| Ukrainian                      | uk-UA     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/uk-UA-0-premium.mp3]  |
| Vietnamese                     | vi-VN     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-0.mp3]          |
| Vietnamese                     | vi-VN     |   0   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-0-premium.mp3]  |
| Vietnamese                     | vi-VN     |   1   |         |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-1.mp3]          |
| Vietnamese                     | vi-VN     |   1   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-1-premium.mp3]  |
| Vietnamese                     | vi-VN     |   2   |         |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-2.mp3]          |
| Vietnamese                     | vi-VN     |   2   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-2-premium.mp3]  |
| Vietnamese                     | vi-VN     |   3   |         |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-3.mp3]          |
| Vietnamese                     | vi-VN     |   3   |    ✔️    |                            ✔️                            | 🔈[/audio/tts-samples/vi-VN-3-premium.mp3]  |
| Welsh                          | cy-GB     |   0   |         |                            ✔️                            | 🔈[/audio/tts-samples/cy-GB-0.mp3]          |

[Download](https://github.com/nexmo-community/vapi-tts-voices) the list of voices as a JSON file.

### Legacy Voice Names

> Previously, in order to set the desired language and voice style, you used the `voiceName` parameter with a certain "name" as the value. The `voiceName` parameter has been deprecated, and while you can continue to use it, it will not contain new styles and languages. For your convenience, see [below](#legacy-voice-names) for a mapping of the legacy `voiceName` parameter to `language` and `style`. Please note, not all the supported styles have a corresponding `voiceName`; thus it's recommended to use `language` and `style` in your application or service. You can listen to the voice samples in the table below.

| ### List of deprecated voice name parameter possible values
|
| 
|
| `voiceName` | Language | `language` | `style` 
| ------------|----------|------------|---------
| `Aditi` | Hindi | hi-IN | 0
| `Alva` | Swedish | sv-SE | 2
| `Amy` | English (United Kingdom) | en-GB | 0
| `Astrid` | Swedish | sv-SE | 0
| `Bianca` | Italian | it-IT | 0
| `Brian` | English (United Kingdom) | en-GB | 4
| `Camila` | Portuguese (Brazil) | pt-BR | 5
| `Carla` | Italian | it-IT | 1
| `Carmen` | Romanian | ro-RO | 0
| `Carmit` | Hebrew | he-IL | 0
| `Catarina` | Portuguese (Portugal) | pt-PT | 3
| `Celine` | French (France) | fr-FR | 0
| `Cem` | Turkish | tr-TR | 7
| `Chantal` | French (Canada) | fr-CA | 0
| `Conchita` | Spanish (Spain) | es-ES | 0
| `Cristiano` | Portuguese (Portugal) | pt-PT | 5
| `Damayanti` | Indonesian | id-ID | 1
| `Dora` | Icelandic | is-IS | 0
| `Emma` | English (United Kingdom) | en-GB | 1
| `Empar` | Spanish (Spain) | es-ES | 3
| `Enrique` | Spanish (Spain) | es-ES | 4
| `Ewa` | Polish | pl-PL | 0
| `Felipe` | Portuguese (Brazil) | pt-BR | 4
| `Filiz` | Turkish | tr-TR | 0
| `Geraint` | English (Wales) | en-GB-WLS | 0
| `Giorgio` | Italian | it-IT | 4
| `Gwyneth` | Welsh | cy-GB | 0
| `Hans` | German | de-DE | 3
| `Henrik` | Norwegian | no-NO | 1
| `Henrik` | Norwegian | nb-NO | 7
| `Ines` | Portuguese (Portugal) | pt-PT | 0
| `Ioana` | Romanian | ro-RO | 1
| `Iveta` | Czech | cs-CZ | 1
| `Ivy` | English (United States) | en-US | 1
| `Jacek` | Polish | pl-PL | 5
| `Jan` | Polish | pl-PL | 6
| `Joana` | Portuguese (Portugal) | pt-PT | 4
| `Joanna` | English (United States) | en-US | 2
| `Joey` | English (United States) | en-US | 7
| `Jordi` | Catalan, Valencian | ca-ES | 1
| `Justin` | English (United States) | en-US | 8
| `Kanya` | Thai | th-TH | 0
| `Karl` | Icelandic | is-IS | 1
| `Kendra` | English (United States) | en-US | 3
| `Kimberly` | English (United States) | en-US | 0
| `Laila` | Arabic | ar | 2
| `Laura` | Slovak | sk-SK | 1
| `Lea` | French (France) | fr-FR | 1
| `Lekha` | Hindi | hi-IN | 2
| `Liv` | Norwegian | nb-NO | 0
| `Lotte` | Dutch | nl-NL | 0
| `Lucia` | Spanish (Spain) | es-ES | 1
| `Luciana` | Portuguese (Brazil) | pt-BR | 2
| `Lupe` | Spanish (United States) | es-US | 2
| `Mads` | Danish | da-DK | 2
| `Maged` | Arabic | ar | 5
| `Maja` | Polish | pl-PL | 1
| `Mariska` | Hungarian | hu-HU | 1
| `Marlene` | German | de-DE | 0
| `Mathieu` | French (France) | fr-FR | 5
| `Matthew` | English (United States) | en-US | 9
| `Maxim` | Russian | ru-RU | 4
| `Mei-Jia` | Chinese, Mandarin (Taiwan) | cmn-TW | 0
| `Melina` | Greek | el-GR | 1
| `Mia` | Spanish (Mexico) | es-MX | 0
| `Miguel` | Spanish (United States) | es-US | 1
| `Miren` | Basque | eu-ES | 0
| `Mizuki` | Japanese | ja-JP | 0
| `Montserrat` | Catalan, Valencian | ca-ES | 0
| `Naja` | Danish | da-DK | 0
| `Nicole` | English (Australia) | en-AU | 0
| `Nikos` | Greek | el-GR | 2
| `Nora` | Norwegian | no-NO | 0
| `Nora` | Norwegian | nb-NO | 6
| `Oskar` | Swedish | sv-SE | 3
| `Penelope` | Spanish (United States) | es-US | 0
| `Raveena` | English (India) | en-IN | 1
| `Ricardo` | Portuguese (Brazil) | pt-BR | 3
| `Ruben` | Dutch | nl-NL | 4
| `Russell` | English (Australia) | en-AU | 3
| `Salli` | English (United States) | en-US | 4
| `Satu` | Finnish | fi-FI | 1
| `Seoyeon` | Korean | ko-KR | 0
| `Sin-Ji` | Chinese, Cantonese | yue-CN | 0
| `Sora` | Korean | ko-KR | 3
| `Takumi` | Japanese | ja-JP | 3
| `Tarik` | Arabic | ar | 6
| `Tatyana` | Russian | ru-RU | 0
| `Tessa` | English (South Africa) | en-ZA | 0
| `Tian-Tian` | Chinese, Mandarin | cmn-CN | 3
| `Vicki` | German | de-DE | 1
| `Vitoria` | Portuguese (Brazil) | pt-BR | 0
| `Yelda` | Turkish | tr-TR | 4
| `Zeina` | Arabic | ar | 0
| `Zhiyu` | Chinese, Mandarin | cmn-CN | 0
| `Zuzana` | Czech | cs-CZ | 2
|

