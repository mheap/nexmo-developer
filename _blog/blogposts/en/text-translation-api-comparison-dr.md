---
title: Text Translation API Comparison
description: Translation APIs are essential for working with inbound/outbound
  messages. This is a comparison of the API offerings from Amazon, Google, IBM
  and Microsoft.
thumbnail: /content/blog/text-translation-api-comparison-dr/EFBED5D5-7AAF-4AAC-8C64-214E8559ABD2.jpeg
author: kellyjandrews
published: true
published_at: 2019-12-10T18:19:35.000Z
updated_at: 2021-05-18T11:29:49.180Z
category: tutorial
tags:
  - node
  - sms-api
  - azure
comments: true
redirect: ""
canonical: ""
---
Text translation APIs are essential in the global environment of inbound and outbound messaging. Amazon Web Services, Google Cloud Platform, IBM Watson, and Microsoft Azure all have strong offerings. This post will highlight some of my learnings from using each service.

## Amazon Translate

### Features

[Amazon Transcribe](https://aws.amazon.com/translate/details/) uses what's called neural machine translation to create more natural language translations. The service offers both real-time and batch processes, giving the developer the option to translate text immediately or process after the fact.

Amazon Translate offers 54 languages to choose from, giving you a wide variety of options.  The service will also detect the source language as well, allowing additional flexibility. You can also customize your terminology to make sure you have greater accuracy when it comes to your specific use case.

### Ease of Use

Amazon’s AWS SDK includes Amazon Translate for multiple programming languages.  I used JavaScript and had no trouble working with the service.  

The [documentation for Amazon Translate](https://docs.aws.amazon.com/translate/latest/dg/what-is.html) is easy enough to get you started and thorough enough to cover more complexity as required. They also provide some examples to help you get started.  

My translation method is below as an example -

```js
function translateText(params) {
  var translate = new AWS.Translate({region: process.env.AWS_REGION})
  var opts = {
    SourceLanguageCode: 'auto',
    TargetLanguageCode: 'en',
    Text: params.text
  };
  translate.translateText(opts, function(err, data) {
    if (err) {
      console.log(err, err.stack);
    }
    else{
      console.log(params.text);
      console.dir(data, {depth: null})
    }
  });
}
```

The response received from the service could potentially use more information, but the data provided gives you enough to be functional.  I would like to know what the original text was and maybe some `id`  to match up calls later.  I can build this into my app, but having the additional information would be helpful.

```
Hola
{
  TranslatedText: 'Hello',
  SourceLanguageCode: 'es',
  TargetLanguageCode: 'en'
}
Halo
{
  TranslatedText: 'Hello. Hello',
  SourceLanguageCode: 'id',
  TargetLanguageCode: 'en'
}
```

You can find a full example and tutorial [in my previous Amazon Translate post](https://learn.vonage.com/blog/2019/11/04/translating-sms-messages-with-aws-translate-dr).

### Pricing

The [pricing structure for Amazon Translate](https://aws.amazon.com/translate/pricing/) is straightforward. The service is pay-as-you-go, and charges by the character. It also offers a free tier to get you started.

For 12 months after making your first translation call, AWS gives you 2 million characters per month free, which is more than adequate for testing purposes and even some light customer usage. Anything above the 2 million character allocation is charged the standard rate, which is $15.00 per million characters.

## Azure Text Translator API

### Features

The [Azure Text Translator API](https://azure.microsoft.com/en-us/services/cognitive-services/translator-text-api/) is a part of Cognitive Services and uses neural machine translation to perform its translations. Microsoft also provides a bilingual dictionary to find alternative translations using contextual sentences to help pick the appropriate translation.

Azure Text Translator API offers a wide variety of languages by supporting over 60. The service provides transliteration so you can change the text to use different alphabets. Custom models are an option to handle specific industry terms properly. If needed, the Azure Text Translator API will also translate documents.

A unique offering from Azure is the ability to use a local translation service with your Android apps to translate when not connected to the internet.

### Ease of Use

At the time of writing, the Azure SDKs have been undergoing some significant updates.  The changes are for the better and streamline the setup.  I found the documentation a bit hard to navigate at times, but the source code had enough comments that I could get things sorted out.  

Once I was able to locate the required parameters, and input formats, the Promise structure of the SDK made the code for JavaScript straightforward.

```js
function translateText(params) {
  const creds = new CognitiveServicesCredentials.ApiKeyCredentials({ inHeader: { 'Ocp-Apim-Subscription-Key': process.env.TEXT_TRANSLATION_SUBSCRIPTION_KEY } });
  const client = new TranslatorTextClient(creds, process.env.TEXT_TRANSLATION_ENDPOINT);

  client.translator
    .translate(["en"], [{text:params.text}])
    .then(data => {
      console.dir(data, {depth: null})
    })
    .catch(err => {
      console.error("error:", err);
    });
}
```

The `translator.translate` method allows for multiple inputs for both the text and languages.  The input arrays allow for translating messages into various languages simultaneously, as well as sending multiple messages in batches.

The response is lightweight. Plan on keeping track of the calls made and the original text in your application. These details are not provided.

```js
[
  {
    detectedLanguage: { language: 'es', score: 1 },
    translations: [ { text: 'Hello', to: 'en' } ]
  }
]
```

You can see how to implement this service in JavaScript in my [Azure Text Translation API post](https://learn.vonage.com/blog/2019/11/25/translating-sms-messages-with-azure-translator-text-dr).

### Pricing

The [pricing structure for Azure Text Translation API](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/) is pay-as-you-go and charges $10 per million characters. The service does not offer any free tier outside of the typical Azure trial.  

## Google Cloud Translate

### Features

[Google Cloud Translation API](https://cloud.google.com/translate/#benefits) uses the AutoML Natural Language processing to provide the translations you'd expect from a Google Translate service. Google Cloud also offers the ability to train custom AutoML models or use the pre-trained models already available.

Google Cloud Translate supports over 100 languages and provides language detection. It offers a glossary to prioritize industry-specific terminology translations. If you do go the route of using custom AutoML translation, you can build custom models with more than 50 language pairs.

### Ease of Use

I have always enjoyed using the Google Cloud SDK with JavaScript projects.  The [quickstarts](https://cloud.google.com/translate/docs/quickstarts) are still easy to follow, and [references for the API](https://cloud.google.com/translate/docs/apis) can be easily found and are well structured.  

Google Cloud uses service accounts for authentication. When you provide the credentials file in the project root, the SDK manages the auth for you, making this easily my favorite cloud service API to implement.

```js
function translateText(params) {
  const translate = new Translate();
  const target = process.env.TARGET_LANGUAGE || 'en';

  translate.translate(params.text, target)
        .then(data => {
           console.dir(data, {depth: null})
         })
         .catch(err => {
           console.log('error', err);
         });
}

```

The `translate` object is super simple to use; however, the return does not contain the original text passed back in the response.

```js
[
  'Hi',
  {
    data: {
      translations: [ { translatedText: 'Hi', detectedSourceLanguage: 'es' } ]
    }
  }
]
```

For a more detailed tutorial on how to run Google Cloud Translate with JavaScript, you can check out this [post](https://learn.vonage.com/blog/2019/10/24/extending-nexmo-google-cloud-translation-api-dr).

### Pricing

Google Cloud Translate [pricing](https://cloud.google.com/translate/#pricing) offers two main tiers - Basic and Advanced.  The advanced service has a few additional features available and is the same price as Basic, both costing $20 per million characters.  

The service is also pay-as-you-go, but also explicitly states that it will charge pro-rata, or incrementally.  Pro-rata means it won't wait until you reach 1 million before charging you for usage.  

As of November 1, 2019, they also are offering $10 of free usage per month - which is excellent for development testing.

## IBM Watson Language Translator

### Features

Much like the other three services, [IBM Watson Language Translator](https://www.ibm.com/watson/services/language-translator/) also utilizes neural machine translation to provide more accurate results. Building custom models is an option for this service provider, giving you the same amount of control.

The translated languages for IBM Watson Language Translator appears to be the fewest with only around 30 listed.  The list does hit the majority of use cases, but if you are planning to use a specific language, be sure to check the list before getting started.

IBM Watson Language Translator has a document translation service, giving it a well-rounded set of features for most use cases.

### Ease of Use
IBM Watson Language Translator JavaScript SDK has by far the most verbose authentication syntax, but the methods generally fall in line with the other services as well.

The [documentation](https://cloud.ibm.com/docs/services/language-translator?topic=language-translator-gettingstarted) is easy to follow, and they provide several example applications to get you started.

One slight drawback is that the service doesn't determine the source language automatically, like the other services.  There is a method to assess the incoming language. However, you will need to set the translation model explicitly.

```js
function translateText(params) {

  const languageTranslator = new LanguageTranslatorV3({
    version: '2017-09-21',
    authenticator: new IamAuthenticator({
      apikey: process.env.TRANSLATE_IAM_APIKEY,
    }),
    url: process.env.TRANSLATE_URL,
  });

  const translateParams = {
    text: params.text,
    modelId: 'en-es',
  };

  languageTranslator.translate(translateParams)
    .then(data => {
      console.dir(data, {depth: null})
    })
    .catch(err => {
      console.log('error:', err);
    });
}
```

Once again, the response doesn't contain the original text,  so plan accordingly.

```js
{
  status: 200,
  statusText: 'OK',
  headers: {
    'content-type': 'application/json;charset=UTF-8',
    'content-length': '104',
    'x-xss-protection': '1; mode=block',
    'x-content-type-options': 'nosniff',
    'content-security-policy': "default-src 'none'",
    'cache-control': 'no-cache, no-store',
    pragma: 'no-cache',
    'content-language': 'en-US',
    'strict-transport-security': 'max-age=31536000; includeSubDomains;',
    'x-global-transaction-id': 'guid',
    'x-dp-watson-tran-id': 'guid',
    'x-edgeconnect-midmile-rtt': '25',
    'x-edgeconnect-origin-mex-latency': '229',
    date: 'DATE/TIME OF CALL',
    connection: 'close'
  },
  result: {
    translations: [ { translation: 'Hi' } ],
    word_count: 1,
    character_count: 4
  }
}
```

You can set up your own project by following my previous [tutorial](https://learn.vonage.com/blog/2019/11/12/translate-sms-messages-with-ibm-watson-dr).

### Pricing

The [IBM Watson Language Translator pricing](https://www.ibm.com/watson/services/language-translator/#pricing) was by far the most confusing.  There is a Lite version, which is the free tier.  You can use 1 million characters per month at no cost. However, you won't be able to use custom models until you have a paid plan, and Lite services are deleted after 30 days of inactivity.

The Standard plan gives you 250,000 characters free, but the bullet point had an asterisk and no further details (I assume that standard translations use the default models).  After the initial 250,000, the price is $0.02 per thousand. That price is the same $20 per million once you do the math.

The Advanced plan doesn't appear to give you the 250,000 free but still charges the same as the Standard. Double-check if the same free characters apply here as well before buying. Custom model translations will cost $100 per million characters plus a $15 maintenance fee per model per month.  

## Summary

Using machine learning and neural language models to translate text is a powerful tool for any application.  The models are not perfect, and the service may never be the same as a human translation.  However, translations in real-time to facilitate global communication is too valuable not to continue to improve.

I do find it somewhat disappointing that all four services don't return the original text in the call.  I think it would be nice to have some way to know based on the response where the translation belongs if something gets mixed up during the process.

Overall, I think each service is good enough to handle most use cases your application would require. The translations appear accurate. However, they may be   I believe IBM's price is on the high side, given it's fewer supported languages and lack of language auto-detection.  For me, I would go with Azure or Google due to their matured offering and language models.  

If you have any questions or comments, feel free to leave them below or reach out to me on [Twitter (@kellyjandrews)](https://twitter.com/kellyjandrews).
