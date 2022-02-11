---
title: Build a Speech Translation App on Deno With Azure and Vonage
description: Learn how to create a speech translation VAPI app that runs on Deno
  using Vonage ASR for speech-to-text and Azure text translation.
thumbnail: /content/blog/build-a-speech-translation-app-on-deno-with-azure-and-vonage/Blog_Speach-Translation_Deno-Azure_1200x600-1.png
author: ben-greenberg
published: true
published_at: 2020-06-09T13:33:49.000Z
updated_at: 2021-05-04T13:36:12.414Z
category: tutorial
tags:
  - deno
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Vonage recently released [Automatic Speech Recognition (ASR)](https://developer.nexmo.com/voice/voice-api/guides/asr) as a new feature on the Voice API, which is a great reason to build an entertaining new voice application to leverage this new capability! 

In this tutorial, we will build a voice application running on [Deno](https://deno.land/) that will:

1. Receive a phone call
2. Accept the speech said by the caller at the prompt
3. Convert that speech into text using Vonage ASR
4. Translate it into a randomly chosen language using Microsoft Azure
5. Speak back both the original English text and the newly translated text
6. If the newly translated text has an accompanying [Vonage Voice available](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names), that voice will be used

We are building using Deno as our runtime environment because Deno lets us build a server-side app in TypeScript with lightweight dependencies. It allows us to both integrate only the external code we actually need and to give it only the runtime permissions we desire it to have. 

There are several possible providers we can integrate with to provide text translation. In this tutorial we will be building utilizing the [Microsoft Azure Speech Translation API](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-translation). 

Let's get started!

*tl;dr If you would like to skip ahead and just run the app, you can find a fully working version on [GitHub](https://github.com/nexmo-community/nexmo-asr-deno-demo).*

## Prerequisites

To build this application, you will need several items before we can start implementing it:

* A Vonage Account
* A Vonage provisioned phone number
* A [Microsoft Azure Account](https://portal.azure.com)
* [Deno](https://deno.land) installed on your local machine

Once you have all that taken care of, we can move on to begin our application implementation.

## Vonage API Account

To complete this tutorial, you will need a [Vonage API account](http://developer.nexmo.com/ed?c=blog_text&ct=2020-06-09/build-a-speech-translation-app-on-deno-with-azure-and-vonage). If you don’t have one already, you can [sign up today](http://developer.nexmo.com/ed?c=blog_text&ct=2020-06-09/build-a-speech-translation-app-on-deno-with-azure-and-vonage) and start building with free credit. Once you have an account, you can find your API Key and API Secret at the top of the [Vonage API Dashboard](http://developer.nexmo.com/ed?c=blog_text&ct=2020-06-09/build-a-speech-translation-app-on-deno-with-azure-and-vonage).

This tutorial also uses a virtual phone number. To purchase one, go to *Numbers* > *Buy Numbers* and search for one that meets your needs.

<a href="http://developer.nexmo.com/ed?c=blog_banner&ct=YEAR-MONTH-DAY-SLUG"><img src="https://www.nexmo.com/wp-content/uploads/2020/05/StartBuilding_Footer.png" alt="Start building with Vonage" width="1200" height="369" class="aligncenter size-full wp-image-32500" /></a>

## Creating the Folder Structure

The first step is to create the folder structure for our application. It will look like this at the end:

```
.
+-- data/
|   +-- languages.ts
|   +-- voices.ts
+-- services/
|   +-- auth/
|     +-- token.ts
|   +-- translate.ts
|   +-- language_picker.ts
|   +-- voice_picker.ts
+-- server.ts
+-- .env
```

For this tutorial, we will call the root folder of the application, `speech-translation-app`, but you can name it whatever you would like. Once you have created the root folder, change directory into it and create the `data`, `services`, and `services/auth` subfolders. 

Inside the root folder create `server.ts` and `.env` files by running `touch server.ts .env` from inside the root directory.

Perform a similar action inside the `data`, `services`, and `services/auth` folders, executing `touch` to create the files shown in the directory tree above.

## Creating the Deno Server

In your preferred code editor, open up the `server.ts` file from the root directory that you created in the last step. 

Within this file, we will instantiate an HTTP server, provide it with its routes, and control the flow of the application. 

We are going to use [Opine](https://github.com/asos-craigmorten/opine) as our web framework for the server. Opine is a minimalist framework made for Deno ported from ExpressJS. If you are familiar with ExpressJS, then the constructs in Opine will feel familiar. 

To use Opine, we need to import it at the top of our file. Deno, unlike NodeJS, does not use node_modules or another similar package management system. As a result, each package brought into your application is imported directly from its source:

```ts
import { opine } from "https://deno.land/x/opine@master/mod.ts";
```

Once we have made opine available to use, we can instantiate an instance of it and create the skeleton structure for our routes:

```ts
const app = opine();
 app.get("/webhooks/answer", async function (req, res) {
  // Do something on a GET request to /webhooks/answer
});
 app.get("/webhooks/asr", async function (req, res) {
  // Do something on a GET request to /webhooks/asr
});
 app.get("/webhooks/event", async function (req, res) {
  // Do something on a GET request to /webhooks/event
  res.status = 204
})
 app.listen({ port: 8000 });
 console.log("Server is running on port 8000");
```

The three `GET` requests enumerated in the server correspond to three unique webhooks from the Vonage Voice API. The first one is where the API sends an incoming call. The second one is where the API will send the converted speech to text using the Vonage Automatic Speech Recognition feature. Lastly, the third route is where all the event data for the lifecycle of the call is sent to. 

We need to provide logic for each of these three routes that will control the way our application functions: 
This conversation was marked as resolved by NJalal7

* The incoming call route will handle taking in the caller's voice input and sending it to the Vonage API for text conversion.       
* The second route will receive the text and send it to the Azure Speech Translation API to translate it into a second language. It will also playback to the caller the original and translated messages.
* The final route will receive all call lifecycle event data and acknowledge the receiving of the data.

## Defining the Routes

Let's build the logic for the incoming call `/webhooks/answer` route. 

Inside the route we need to assign the caller ID (`UUID`) to a variable so we can use it later. The `UUID` is a necessary component of the ASR request:

```ts
const uuid = req.query.uuid
```

Next, we need to respond with an HTTP status code of `200` and send back in response a Nexmo Call Control Object (NCCO), which is a JSON object containing the set of instructions we wish the Vonage API to perform:

```ts
res.json([
  {
    action: 'talk',
    text: 'Welcome to the Vonage Universal Translator Randomizer brought to you by Vonage Automatic Speech Recognition run on Deno. Please say something.',
    bargeIn: true
  },
  {
    eventUrl: [asrWebhook],
    eventMethod: 'GET',
    action: 'input',
    speech: {
      uuid: [uuid],
      language: 'en-us'
    }
  }
]);
```

As you can see the NCCO is composed of two actions: `talk` and `input`, respectively. 

The `talk` action welcomes the caller and asks them to say something. It also sets a parameter `bargeIn` to equal `true`, which allows the caller to start speaking before the message has finished.

The `input` action is where we accept the caller's voice input. In this action we define a few unique parameters:

* `eventUrl`: Where to send the completed converted speech to text to. In the action we define the URL as a variable called `asrWebhook`. We will create that later.
* `eventMethod`: Which HTTP verb to use to send the completed speech to text with. In this case, we use `GET`.
* `action`: The base parameter for all NCCO actions. Its value is equal to the action you wish to perform, in this case `input`.
* `speech`: A parameter whose value is equal to an object that contains the `UUID` of the caller and the `language` of the speech that is being converted into text.

All together, this first `GET` route looks like the following:

```ts
app.get("/webhooks/answer", async function (req, res) {
  const uuid = req.query.uuid
  res.status = 200
  res.json([
    {
      action: 'talk',
      text: 'Welcome to the Vonage Universal Translator Randomizer brought to you by Vonage Automatic Speech Recognition run on Deno. Please say something.',
      bargeIn: true
    },
    {
      eventUrl: [asrWebhook],
      eventMethod: 'GET',
      action: 'input',
      speech: {
        uuid: [uuid],
        language: 'en-us'
      }
    }
  ]);
});
```

The second route we need to define is the `/webhooks/asr` route, which will receive the converted speech to text from the Vonage API and act upon it.

There are a few values we want to assign to variables to use. The first is the results of the ASR conversion, which comes to us in the form of an array of objects. The objects are in descending order of probability of accuracy. The second variable will hold the text from the object with the highest accuracy of probability. 

We instantiate the second variable as an empty variable and assign its value based on the condition of whether Vonage ASR was able to pick up the speech offered by the caller. If the speech was recognized then that value is used. However, if the speech was not recognized, then a default value is provided and a message is displayed in the console as to why.

In the last two variables we create we assign the value of the random language choice for the speech to be translated into, and pick the voice to speak the translation with. We then share the language and the voice information in the console:

```ts
const data = await JSON.parse(req.query.speech)
var mostConfidentResultsText;
if (!data.results) {
  console.log("Vonage ASR did not pick up what you tried to say");
  mostConfidentResultsText = 'Vonage ASR did not pick up your speech. Please call back and try again.';
} else {
  mostConfidentResultsText = data.results[0].text;
};
const languageChoice = languagePicker(languageList);
const voiceChoice = voicePicker(voicesList, languageChoice);
console.log(`Language to translate into: ${languageChoice.name} and Vonage language voice being used: ${voiceChoice}`);
```

Then, we set the response HTTP status code to `200` like in the first route, and we respond with another NCCO JSON object:

```ts
res.status = 200
res.json([
  {
    action: 'talk',
    text: `This is what you said in English: ${mostConfidentResultsText}`
  },
  {
    action: 'talk',
    text: `This is your text translated into ${languageChoice.name}`
  },
  {
    action: 'talk',
    text: `${await translateText(languageChoice.code.split('-')[0], mostConfidentResultsText)}`,
    voiceName: voiceChoice
  }
])
```

This NCCO object contains three `talk` actions, each one of them with variables and functions that need to be created. We will do that after we have finished defining the routes.

The first `talk` action says back to the caller their original message in English as it was understood during the automatic speech recognition conversion.

The second `talk` action tells the caller what language their message was translated into.

The third `talk` action says to the caller their newly translated message. It also leverages the `voiceName` parameter to say the translated message in the language's designated voice, if one is available for that language.

The last route we need to define will be a short one. This is the one that will receive the rest of the event webhook data for the call. In this tutorial we are not going to do anything with that data besides acknowledging we received it. We acknowledge it by sending back a `204` HTTP status code, which is the equivalent of saying the message was successful and there is no content to respond with:

```ts
app.get("/webhooks/event", async function (req, res) {
  res.status = 204
})
```

With the server defined, we are ready to build the helper functions that we invoked in the server routes.

## Creating the Services and Data

Let's navigate to the top of the `server.ts` file again and add a few more import statements for functions and data that will define:

```ts
import { languageList } from "./data/languages.ts";
import { voicesList } from "./data/voices.ts";
import { translateText } from "./services/translate.ts";
import { voicePicker } from "./services/voice_picker.ts";
import { languagePicker } from "./services/language_picker.ts";
```

As the snippet above indicates we need to create the five following items:

* `languageList`: An array of possible languages to translate the message into
* `voicesList`: An array of possible voices to speak the translated message with
* `translateText`: The function to translate the text into the second language
* `voicePicker`: The function to choose a voice to speak the translated text with
* `languagePicker`: The function to choose a language to translate the text into

We will build each of these now.

### Defining the Data

First, let's add some data to our application.

We need to add two items of data: a list of languages and a list of voices to speak those languages. 

The list of supported languages is derived from the [Vonage ASR Guide](https://developer.nexmo.com/voice/voice-api/guides/asr#supported-languages). The list of voice names is likewise derived from the [Vonage Voice API Guide](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names).

Open up the `data/languages.ts` file and we will add an array of objects to it:

```ts
export const languageList = [
  { "name": "Afrikaans (South Africa)", "code": "af-ZA" },
  { "name": "Albanian (Albania)", "code": "sq-AL" },
  { "name": "Amharic (Ethiopia)", "code": "am-ET" },
  { "name": "Arabic (Algeria)", "code": "ar-DZ" },
  { "name": "Arabic (Bahrain)", "code": "ar-BH" },
  { "name": "Arabic (Egypt)", "code": "ar-EG" },
  { "name": "Arabic (Iraq)", "code": "ar-IQ" },
  { "name": "Arabic (Israel)", "code": "ar-IL" },
  { "name": "Arabic (Jordan)", "code": "ar-JO" },
  { "name": "Arabic (Kuwait)", "code": "ar-KW" },
  { "name": "Arabic (Lebanon)", "code": "ar-LB" },
  { "name": "Arabic (Morocco)", "code": "ar-MA" },
  { "name": "Arabic (Oman)", "code": "ar-OM" },
  { "name": "Arabic (Qatar)", "code": "ar-QA" },
  { "name": "Arabic (Saudi Arabia)", "code": "ar-SA" },
  { "name": "Arabic (State of Palestine)", "code": "ar-PS" },
  { "name": "Arabic (Tunisia)", "code": "ar-TN" },
  { "name": "Arabic (United Arab Emirates)", "code": "ar-AE" },
  { "name": "Armenian (Armenia)", "code": "hy-AM" },
  { "name": "Azerbaijani (Azerbaijan)", "code": "az-AZ" },
  { "name": "Basque (Spain)", "code": "eu-ES" },
  { "name": "Bengali (Bangladesh)", "code": "bn-BD" },
  { "name": "Bengali (India)", "code": "bn-IN" },
  { "name": "Bulgarian (Bulgaria)", "code": "bg-BG" },
  { "name": "Catalan (Spain)", "code": "ca-ES" },
  { "name": "Chinese, Mandarin (Simplified, China)", "code": "zh" },
  { "name": "Croatian (Croatia)", "code": "hr-HR" },
  { "name": "Czech (Czech Republic)", "code": "cs-CZ" },
  { "name": "Danish (Denmark)", "code": "da-DK" },
  { "name": "Dutch (Netherlands)", "code": "nl-NL" },
  { "name": "English (Australia)", "code": "en-AU" },
  { "name": "English (Canada)", "code": "en-CA" },
  { "name": "English (Ghana)", "code": "en-GH" },
  { "name": "English (India)", "code": "en-IN" },
  { "name": "English (Ireland)", "code": "en-IE" },
  { "name": "English (Kenya)", "code": "en-KE" },
  { "name": "English (New Zealand)", "code": "en-NZ" },
  { "name": "English (Nigeria)", "code": "en-NG" },
  { "name": "English (Philippines)", "code": "en-PH" },
  { "name": "English (South Africa)", "code": "en-ZA" },
  { "name": "English (Tanzania)", "code": "en-TZ" },
  { "name": "English (United Kingdom)", "code": "en-GB" },
  { "name": "English (United States)", "code": "en-US" },
  { "name": "Finnish (Finland)", "code": "fi-FI" },
  { "name": "French (Canada)", "code": "fr-CA" },
  { "name": "French (France)", "code": "fr-FR" },
  { "name": "Galician (Spain)", "code": "gl-ES" },
  { "name": "Georgian (Georgia)", "code": "ka-GE" },
  { "name": "German (Germany)", "code": "de-DE" },
  { "name": "Greek (Greece)", "code": "el-GR" },
  { "name": "Gujarati (India)", "code": "gu-IN" },
  { "name": "Hebrew (Israel)", "code": "he-IL" },
  { "name": "Hindi (India)", "code": "hi-IN" },
  { "name": "Hungarian (Hungary)", "code": "hu-HU" },
  { "name": "Icelandic (Iceland)", "code": "is-IS" },
  { "name": "Indonesian (Indonesia)", "code": "id-ID" },
  { "name": "Italian (Italy)", "code": "it-IT" },
  { "name": "Japanese (Japan)", "code": "ja-JP" },
  { "name": "Javanese (Indonesia)", "code": "jv-ID" },
  { "name": "Kannada (India)", "code": "kn-IN" },
  { "name": "Khmer (Cambodia)", "code": "km-KH" },
  { "name": "Korean (South Korea)", "code": "ko-KR" },
  { "name": "Lao (Laos)", "code": "lo-LA" },
  { "name": "Latvian (Latvia)", "code": "lv-LV" },
  { "name": "Lithuanian (Lithuania)", "code": "lt-LT" },
  { "name": "Malay (Malaysia)", "code":  "ms-MY" },
  { "name": "Malayalam (India)", "code": "ml-IN" }, 
  { "name": "Marathi (India)", "code": "mr-IN" },
  { "name": "Nepali (Nepal)", "code":  "ne-NP"},
  { "name": "Norwegian Bokmål (Norway)",  "code": "nb-NO"},
  { "name": "Persian (Iran)", "code":  "fa-IR"},
  { "name": "Polish (Poland)", "code":  "pl-PL"},
  { "name": "Portuguese (Brazil)", "code": "pt-BR"},
  { "name": "Portuguese (Portugal)", "code": "pt-PT"},
  { "name": "Romanian (Romania)", "code": "ro-RO"} ,
  { "name": "Russian (Russia)", "code": "ru-RU" },
  { "name": "Serbian (Serbia)", "code": "sr-RS" },
  { "name": "Sinhala (Sri Lanka)", "code": "si-LK" },
  { "name": "Slovak (Slovakia)", "code": "sk-SK" },
  { "name": "Slovenian (Slovenia)", "code": "sl-SI" },
  { "name": "Spanish (Argentina)", "code": "es-AR" },
  { "name": "Spanish (Bolivia)", "code": "es-BO" },
  { "name": "Spanish (Chile)", "code": "es-CL" },
  { "name": "Spanish (Colombia)", "code": "es-CO" },
  { "name": "Spanish (Costa Rica)", "code":  "es-CR" },
  { "name": "Spanish (Dominican Republic)", "code": "es-DO" },
  { "name": "Spanish (Ecuador)", "code": "es-EC" },
  { "name": "Spanish (El Salvador)", "code": "es-SV" },
  { "name": "Spanish (Guatemala)", "code": "es-GT" },
  { "name": "Spanish (Honduras)", "code": "es-HN" },
  { "name": "Spanish (Mexico)", "code": "es-MX" },
  { "name": "Spanish (Nicaragua)", "code": "es-NI" },
  { "name": "Spanish (Panama)", "code": "es-PA" },
  { "name": "Spanish (Paraguay)", "code": "es-PY" },
  { "name": "Spanish (Peru)", "code": "es-PE" },
  { "name": "Spanish (Puerto Rico)", "code": "es-PR" },
  { "name": "Spanish (Spain)", "code": "es-ES" },
  { "name": "Spanish (United States)", "code": "es-US" },
  { "name": "Spanish (Uruguay)", "code": "es-UY" },
  { "name": "Spanish (Venezuela)", "code": "es-VE" },
  { "name": "Sundanese (Indonesia)", "code": "su-ID" },
  { "name": "Swahili (Kenya)", "code": "sw-KE" },
  { "name": "Swahili (Tanzania)", "code": "sw-TZ" },
  { "name": "Swedish (Sweden)", "code": "sv-SE" },
  { "name": "Tamil (India)", "code": "ta-IN" },
  { "name": "Tamil (Malaysia)", "code": "ta-MY" },
  { "name": "Tamil (Singapore)", "code": "ta-SG" },
  { "name": "Tamil (Sri Lanka)", "code": "ta-LK" },
  { "name": "Telugu (India)", "code": "te-IN" },
  { "name": "Thai (Thailand)", "code": "th-TH" },
  { "name": "Turkish (Turkey)", "code": "tr-TR" },
  { "name": "Ukrainian (Ukraine)", "code": "uk-UA" },
  { "name": "Urdu (India)", "code": "ur-IN" },
  { "name": "Urdu (Pakistan)", "code": "ur-PK" },
  { "name": "Vietnamese (Vietnam)", "code": "vi-VN" },
  { "name": "Zulu (South Africa)", "code": "zu-ZA" }
]
```

This represents the list of supported languages at the time of publication of this tutorial. The list is subject to change, and the guide on the website should be consulted for the most up to date information.

Next, open up the `data/voices.ts` file and add an array of objects to this file as well. Like the language list, the data here represents the list of voice names at the time of publication. There is often more than one voice per language. For the sake of this tutorial, we have removed duplicate language voices to keep it to one voice per language:

```ts
export const voicesList = [
  { "name": "Salli", "code": "en-US" },
  { "name": "Marlene", "code": "de-DE" },
  { "name": "Nicole", "code": "en-AU" },
  { "name": "Gwyneth", "code": "en-GB" },
  { "name": "Geraint", "code": "cy-GB" },
  { "name": "Raveena", "code": "en-IN" },
  { "name": "Conchita", "code": "es-ES" },
  { "name": "Penelope", "code": "es-US" },
  { "name": "Chantal", "code": "fr-CA" },
  { "name": "Mathieu", "code": "fr-FR" },
  { "name": "Aditi", "code": "hi-IN" },
  { "name": "Dora", "code": "is-IS" },
  { "name": "Carla", "code": "it-IT" },
  { "name": "Liv", "code": "nb-NO" },
  { "name": "Lotte", "code": "nl-NL" },
  { "name": "Jacek", "code": "pl-PL" },
  { "name": "Vitoria", "code": "pt-BR" },
  { "name": "Ines", "code": "pt-PT" },
  { "name": "Carmen", "code": "ro-RO" },
  { "name": "Tatyana", "code": "ru-RU" },
  { "name": "Astrid", "code": "sv-SE" },
  { "name": "Filiz", "code": "tr-TR" },
  { "name": "Mizuki", "code": "ja-JP" },
  { "name": "Seoyeon", "code": "ko-KR" },
  { "name": "Laila", "code": "ara-XWW" },
  { "name": "Damayanti", "code": "ind-IDN" },
  { "name": "Miren", "code": "baq-ESP" },
  { "name": "Sin-Ji", "code": "yue-CHN" },
  { "name": "Jordi", "code": "cat-ESP" },
  { "name": "Montserrat", "code": "cat-ESP" },
  { "name": "Iveta", "code": "ces-CZE" },
  { "name": "Tessa", "code": "eng-ZAF" },
  { "name": "Satu", "code": "fin-FIN" },
  { "name": "Melina", "code": "ell-GRC" },
  { "name": "Carmit", "code": "heb-ISR" },
  { "name": "Lekha", "code": "hin-IND" },
  { "name": "Mariska", "code": "hun-HUN" },
  { "name": "Sora", "code": "kor-KOR" },
  { "name": "Tian-Tian", "code": "cmn-CHN" },
  { "name": "Mei-Jia", "code": "cmn-TWN" },
  { "name": "Nora", "code": "nor-NOR" },
  { "name": "Henrik", "code": "nor-NOR" },
  { "name": "Felipe", "code": "por-BRA" },
  { "name": "Joana", "code": "por-PRT" },
  { "name": "Ioana", "code": "ron-ROU" },
  { "name": "Laura", "code": "slk-SVK" },
  { "name": "Alva", "code": "swe-SWE" },
  { "name": "Kanya", "code": "tha-THA" },
  { "name": "Yelda", "code": "tur-TUR" },
  { "name": "Empar", "code": "spa-ESP" }
]
```

### Defining the Service Functions

Our application uses several functions defined in `services/` that provide the core functionality. We will build each of them out at this point.

To utilize the Microsoft Azure Speech Translation API, we must authenticate to the API using a two-step process. The first step is obtaining a JSON Web Token (JWT) from the token creation API endpoint that we then use in the second step when we make an HTTP call to the translation API endpoint.

Open up the `services/auth/token.ts` file and in it we will create the functionality to obtain a JWT from Azure. Please note this depends upon you successfully creating an account on Microsoft Azure and receiving your API key. The function reads the API key from an environment variable in our `.env` file, which we will define later in this tutorial:

```ts
import "https://deno.land/x/dotenv/load.ts";
const azureEndpoint: any = Deno.env.get("AZURE_ENDPOINT");
var data;
 export const getToken = async (key: string | undefined) => {
  if (!key) {
    console.log("You are missing your Azure Subscription Key. You must add it as an environment variable.");
    return;
  };
  if (!azureEndpoint) {
    console.log("You are missing your Azure endpoint definition. You must add it as an environment variable.");
  };
  data = await fetch(`${azureEndpoint.toString()}sts/v1.0/issuetoken`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-length': '0',
      'Ocp-Apim-Subscription-Key':key.toString()
    }
  })
  var text = await data.text();
  return text; 
};
```

The `getToken()` function accepts a `key` parameter, and along with the Microsoft Azure URL endpoint defined in your dotenv file, it makes a `fetch()` request sending your API key. The value that comes back is your JWT that is explicitly returned as the value from the function. At the very top of the file, we import a dotenv loader module from Deno that lets us read the values in the `.env` file.

If the `key` is `undefined` or if there is no value for the `azureEndpoint`, the function will return early and provide an explanation in the console for what was missing.

Once we have the token from `getToken()`, we are ready to use it to build a helper function to call the translation API and get the translated text back.

Open up the `services/translate.ts` file and in that file we will create a `translateText()` function:

```ts
import { getToken } from './auth/token.ts';
import "https://deno.land/x/dotenv/load.ts";
const azureSubscriptionKey: string | undefined = Deno.env.get("AZURE_SUBSCRIPTION_KEY");
 export const translateText = async (languageCode: string, text: string) => {
  const token =  await getToken(azureSubscriptionKey);
  const response = await fetch(`https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en&to=${languageCode}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify([{"text": text}])
  });
  var translation = await response.json();
  return translation[0][<any>"translations"][0][<any>"text"]
};
```

This function, like the one before it, reads from our `.env` file to obtain the Azure API key that we defined. It takes two arguments: the two-letter language code and the converted speech-to-text.

The function then creates two variables: `token` and `response`. The former invokes the `getToken()` function passing the Azure API key as its argument. The latter invokes a `fetch()` `POST` request to the Azure speech translation API endpoint using the two-letter language code as part of the query parameters. The JWT generated by the `getToken()` function is passed into the `Authorization` header. The `body` of the `POST` request is the converted speech to text made into a JSON string.

The response from the request is held in the `translation` variable and the actual translated text is returned by the function, which is contained inside `translation[0]["translations][0]["text]`.

We have two remaining functions to create before we can move on to define our `.env` environment variables.

The first of the two remaining functions we will build will randomly choose a language from the languages list for the text to be translated into.

Open up `services/language_picker.ts` and add the following code:

```ts
export const languagePicker = (languages: any) => {
 const language = languages[Math.floor(Math.random() * languages.length)];
 return language;
}
```

The function uses a bit of math to randomly pick an index from the languages list and return the value of the object in that index.

The last function we will build will choose a Vonage voice to speak the translated language into, if one exists for the language. If one does not exist, it will return the `Salli` voice, which represents American English. We also guarantee that if the language chosen is one of the regional dialects of Arabic that the voice chosen is one of the Vonage Arabic voices.

Open up `services/voice_picker.ts` and add the following into it:

```ts
var voiceChoice: any = { "name": "Salli", "code": "en-US" }
 export const voicePicker = (voices: Array<object>, language: any) => {
  voiceChoice = voices.find((voice: any) => voice.code === language.code)
  if (language.code.split('-')[0] === 'ar') {
    voiceChoice = { "name": "Laila", "code": "ara-XWW" }
  };
  if (voiceChoice === undefined) {
    voiceChoice = { "name": "Salli", "code": "en-US" }
  };
  return voiceChoice.name;
};
```

That does it for all the functions! If you made it this far, we are almost at the finish line.

The last items we need to take care of are to assign the values to our `.env` environment variables and to provision a Vonage virtual phone number.

## Defining the Environment Variables

There are three values we need to assign in the `.env` file:

* AZURE_SUBSCRIPTION_KEY
* AZURE_ENDPOINT
* VONAGE_ASR_WEBHOOK

The first two are our Azure API key and Azure URL endpoint, respectively. 

The latter is the webhook URL for the data returned by the Vonage Automatic Speech Recognition feature. This latter value needs to be an externally accessible URL. A good tool to use during development is ngrok to make your local environment externally available. You can find a guide to setting up ngrok locally on our [developer website](https://developer.vonage.com/tools/ngrok#testing-with-ngrok).

## Provisioning a Vonage Virtual Phone Number

There are two ways to provision a Vonage virtual phone number. Once you have a [Vonage developer account](https://dashboard.nexmo.com/sign-up) you can either purchase a phone number through the dashboard or using the Vonage CLI. We will do so here using the CLI.

To install the CLI you can use either yarn or npm: `yarn global add @vonage/cli` or `npm install @vonage/cli -g`. After installation you need to provide it with your API credentials obtained from the dashboard:

```sh
vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

Now that your CLI is set up, you can use it to search for available numbers in your country. To do so run the following using your two-letter country code. The example below shows a number search in the United States. Make sure to add the `--features=VOICE` flag to only return numbers that are voice-enabled:

```sh
vonage numbers:search US --features=VOICE
```

Once you found a number you want you can purchase it also with the CLI:

```sh
vonage numbers:buy NUMBER COUNTRYCODE
```

You will be asked to type `confirm` after you submit the command to officially purchase the number.

Since we are creating a voice app, we also need to create a Vonage Application. This, too, can be done with the CLI and, once finished, we can link the recently provisioned phone number to the application. You can also use the creation of the application to supply it with the answer webhook and event webhook URLs. If creating in development, now is a good time to create your ngrok server and supply the ngrok URLs:

```sh
vonage apps:create APP_NAME --voice_answer_url=https://www.example.com/answer --voice_event_url=https://www.example.com/event
```

The command will return to you the application ID: `Application ID: asdasdas-asdd-2344-2344-asdasdasd345`. We will use that ID now to link the application to the phone number:

```sh
vonage apps:link APP_ID --number=YOUR_VONAGE_NUMBER
```

Once you have finished those commands, you are ready to run your application!

## Running the Application

To use your application, start both your ngrok server and your Deno web server. To start the Deno application run the following from the root folder:

```sh
$ deno run --allow-read --allow-env --allow-net server.ts
```

Now that it is running you can give your Vonage provisioned phone number a call and follow the prompt to say a message. Your message will be converted into text using the Vonage Automatic Speech Recognition feature and then translated into a random second language using Microsoft Azure and then said back to you. Enjoy!