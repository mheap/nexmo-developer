---
title: Sentiment Analysis API Comparison
description: Sentiment analysis gives us the ability to extract meaning from
  text, programmatically, allowing developers to build applications with
  feedback loops that can be mostly automated.
thumbnail: /content/blog/sentiment-api-analysis-comparison-dr/TW_EN_Sentiment-Analysis_1200x675.jpg
author: kellyjandrews
published: true
published_at: 2019-10-17T09:20:06.000Z
updated_at: 2021-05-11T12:19:15.404Z
category: tutorial
tags:
  - sentiment-analysis
comments: true
redirect: ""
canonical: ""
---
Written communication between two people often proves challenging when trying to interpret emotion. Online conversations are easily misunderstood, leading to unwanted or unexpected outcomes.  

Sentiment analysis gives us the ability to extract meaning from text, programmatically, allowing developers to build applications with feedback loops that can be mostly automated.

Having the ability to analyze text and route people to the appropriate channel provides a distinct ability to find customers who are less than happy and may need additional assistance or some other intervention.

Any business that utilizes text communication, whether on social media or in support channels,  greatly benefits from this analysis for learning purposes both after the fact or in real time. As a developer, we can provide this functionality to the organization with ease.

## Overview

This post serves as a comparison of four sentiment analysis cloud services: [Amazon Comprehend](https://aws.amazon.com/comprehend/), [Azure Text Analytics](https://azure.microsoft.com/en-us/services/cognitive-services/text-analytics/), [Google Natural Language](https://cloud.google.com/natural-language/), and [IBM Watson Tone Analyzer](https://www.ibm.com/cloud/watson-tone-analyzer).

As text input, I used the [Nexmo Incoming Messages webhook](https://developer.nexmo.com/concepts/guides/webhooks) to allow for instant feedback from the service with each text message.  During the process, I made sure to capture some notes and organized them here to help you evaluate a provider.

## Accuracy and Scoring

Each service uses a slightly different scoring system. However, each tends to use `1` as the baseline for a confidence level. The closer the number is to 1, the more confident the service is that the sentiment is accurate.  Watson Tone Analyzer adds labels to the sentiment like `joy`, `sadness`, and `analytical` to try and classify the sentiment further, where the others tend to rely on positive and negative alone.

As discovered find in the testing below, accuracy for sentiment is easy when phrasing and intent are straightforward.  However, the human context in speech can drastically change a sentiment with the usage of language like sarcasm.  Sarcasm and other language devices make sentiment analysis more difficult to be accurate 100% of the time and generally text communications as a whole.

### "I am happy!"

Every service got this as a positive/joyful response without too much trouble.

* Amazon Comprehend - `Positive - 0.9970158338546753`
* Azure Text Analytics API - `0.9928278923034668`
* Google Natural Language API - `0.800000011920929`
* Watson Tone Analyzer: `1 - Joy`

### "I am sad."

Another easy test that came back with a negative sentiment.  Notice here that Google uses negative numbers for negative sentiment.

* Amazon Comprehend - `Negative - 0.9563825130462646`
* Azure Text Analytics API - `0.0036676526069641113`
* Google Natural Language API - `-0.20000000298023224`
* Watson Tone Analyzer: `1 - Sadness`

### "So happy there was a pop quiz today."

In the third test, I used purposefully misleading text.  This phrase would most likely be sarcasm, and the sentiment would be the opposite of happy.  Every service was less confident that the positive sentiment was accurate, but Google went along with it.  

* Amazon Comprehend - `Positive - 0.978675365447998`
* Azure Text Analytics API - `0.887139081954956`
* Google Natural Language API - `0.800000011920929`
* Watson Tone Analyzer: `0.899749 - Joy`

## Features

The main focus of this post is sentiment analysis. Every service provider listed here provides at least that as a minimum.  Google, Azure, and Amazon, provide additional natural language processing tools as well, such as entity analysis, syntax analysis, content classification, and keyphrase extraction.  IBM Watson Tone Analyzer provides just sentiment analysis alone.  

The pricing for the additional functionality varies by the provider as well, so if you plan on using it, be sure to verify the costs first.

### Supported Languages

The languages supported vary between services quite a bit. Watson Tone Analyzer supports the least amount, supporting only English and French.  All of the other services provide at least these with many additional languages, as well. The common languages between them are German, French, Italian, Spanish, English, and Portuguese.

[Amazon Comprehend Language Support](https://docs.aws.amazon.com/comprehend/latest/dg/supported-languages.html)

[Azure Text Analytics Language Support](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/language-support)

[Google Natural Language API Language Support](https://cloud.google.com/natural-language/docs/languages)

[Watson Tone Analyzer Language Support](https://cloud.ibm.com/docs/services/tone-analyzer?topic=tone-analyzer-utgpe)

## Ease of Use

Sentiment analysis is a well-established functionality for each cloud provider.  Setup for each service was mostly the same, with minor exceptions.  The typical requirements include turning on the service and getting credentials either directly from the service or an authenticated user.

All of the services provide an SDK with the built-in functionality to make setup and usage straightforward.

### Amazon Comprehend

The Amazon Comprehend request uses an array to pass in multiple phrases at once and responds with an index referenced object that uses `Positive`,  `Negative`, `Neutral`, and `Mixed` scores.  Using multiple scores like this could prove useful in times when the phrase is more complex and doesn't merely fall into one score category.

#### Request

```js
function analyzeTone(params) {
  var obj = {
    LanguageCode: "en",
    TextList: [
      params.text,
    ]
  };
    var comprehend = new AWS.Comprehend({region: process.env.AWS_REGION});
    comprehend.batchDetectSentiment(obj, function (err, data) {
    if (err) {
      console.log(err, err.stack);
    }
    else{
      console.dir(data, {depth: null})
    }
  });
}
```

#### Response

```js
{
  ResultList: [
    {
      Index: 0,
      Sentiment: 'POSITIVE',
      SentimentScore: {
        Positive: 0.9970158338546753,
        Negative: 0.0002091785572702065,
        Neutral: 0.002759476425126195,
        Mixed: 0.000015530584278167225
      }
    }
  ],
  ErrorList: []
}
```

If you'd like to test this out we have a repo for [Amazon Comprehend](https://nexmo.dev/aws-nexmo-sms-analysis-js) using Nexmo messaging.

[Amazon Comprehend API Documentation](https://docs.aws.amazon.com/comprehend/latest/dg/comprehend-general.html)

### Azure Text Analytics API

#### Request

Azure Text Analytics also uses an array for multiple lines of text but requires the `text` and `id` to be passed as an object. The response is a little lacking compared to the other services, only providing a score from 0 to 1 with 0 as `negative` and 1 as `positive`.

```js
function analyzeTone(params) {
  const creds = new CognitiveServicesCredentials.ApiKeyCredentials({ inHeader: { 'Ocp-Apim-Subscription-Key': process.env.TEXT_ANALYTICS_SUBSCRIPTION_KEY } });
  const client = new TextAnalyticsAPIClient.TextAnalyticsClient(creds, process.env.TEXT_ANALYTICS_ENDPOINT);

  const inputDocuments = {documents:[
      {id:"1", text:params.text}
  ]}

  const operation = client.sentiment({multiLanguageBatchInput: inputDocuments})
  operation
  .then(result => {
      console.dir(result, {depth: null})
  })
  .catch(err => {
      throw err;
  });

}
```

#### Response

```js
{ documents: [ { id: '1', score: 0.9928278923034668 } ], errors: [] }
```

If you'd like to test this out we have a repo for [Amazon Comprehend](https://nexmo.dev/aws-nexmo-sms-analysis-js) using Nexmo messaging.

[Azure Text Analytics API Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/overview)

### Google Natural Language API

Google Natural Language API provides a method that accepts one document at a time, which may lead to additional traffic with more substantial usage. The response provides a score using -1.0 as `negative` and 1.0 as `positive`, as well as a magnitude score, which is the absolute value of the score. It also responded with two `undefined` keys in the response that, despite additional research, remain unexplained.

#### Request

```js
// Google Cloud Sentiment Analysis
const client = new language.LanguageServiceClient();

function analyzeTone(params) {
  let document = {
    content: params.text,
    type: 'PLAIN_TEXT',
  };

  client.analyzeSentiment({document: document})
      .then(results => {
        console.dir(results, {depth: null})
      })
      .catch(err => {
        console.log('error', err);
      });
}
```

#### Response

```js
[
  {
    sentences: [
      {
        text: { content: 'I am happy!', beginOffset: -1 },
        sentiment: { magnitude: 0.800000011920929, score: 0.800000011920929 }
      }
    ],
    documentSentiment: { magnitude: 0.800000011920929, score: 0.800000011920929 },
    language: 'en'
  },
  undefined,
  undefined
]
```

If you'd like to test this out we have a repo for [Google Natural Language API](https://nexmo.dev/google-nexmo-sms-analysis) using Nexmo messaging.

[Google Natural Language API Documentation](https://cloud.google.com/natural-language/docs/)

### Watson Tone Analyzer

Watson Tone Analyzer also accepts one text input, but also allows for sentences to be passed in and analyzed individually with the flag `sentences` set to true. The response returns a score range 0 to 1, but also includes a `tone_id`  which can include the following:  `anger`, `fear`, `joy`, `sadness`, `analytical`, `confident`, `tentative`.  The tones can help shape the meaning of the phrases a bit better and provides more human context.

#### Request

```js
// IBM Watson Tone Analysis
var toneAnalyzer = new ToneAnalyzerV3({
  iam_apikey: process.env.TONE_ANALYZER_IAM_APIKEY,
  url: process.env.TONE_ANALYZER_URL,
  version: '2017-09-21'
});

function analyzeTone(params) {
  let toneParams = {
    tone_input: { 'text': params.text},
    content_type: 'application/json',
  };

  toneAnalyzer.tone(toneParams)
      .then(toneAnalyzer => {
        console.dir(toneAnalyzer, {depth: null})
      })
      .catch(err => {
        console.log('error', err);
      });
}
```

#### Response

```js
{
  document_tone: { tones: [ { score: 1, tone_id: 'joy', tone_name: 'Joy' } ] }
}
```

If you'd like to test this out we have a repo for [IBM Watson Tone Analyzer](https://nexmo.dev/ibm-nexmo-sms-analysis-repo) using Nexmo messaging.

[Watson Tone Analysis Documentation](https://cloud.ibm.com/apidocs/tone-analyzer)

## Cost

Pricing for these services proved to be a bit confusing at first glance, but after some thinking and computation, I was able to determine how things broke down.

Amazon and Google both charge in a measure of `units`.  Amazon's unit is 100 characters with a minimum of 300, and Google using 1000 character blocks, charging 1-1000 characters the same amount. Azure also charges per 1000 characters, but calls these `text records`. IBM  measures by API calls.

Given that, the easiest way to normalize the different costs is to use a 1000 character message as an example with a volume of 500,000 per month on a standard system (higher compute power available at higher costs).  Volume pricing may help your specific case if you have a significantly higher amount.

| Provider                                                                                                         | Free Tier                | Cost                                    | Normalized Cost* |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------ | --------------------------------------- | ---------------- |
| [Amazon Comprehend](https://aws.amazon.com/comprehend/pricing/)                                                  | N/A                      | Up to 10M Units - $0.0001               | $500             |
| [Azure Text Analytics API](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/text-analytics/) | 5,000 Text Records/Month | 0-500K - $2 per 1,000 text records      | $1000            |
| [Google Natural Language API](https://cloud.google.com/natural-language/pricing)                                 | 5,000 Units/Month        | 5K+ -1M $1.00/1000 units                | $500             |
| [Watson Tone Analyzer](https://www.ibm.com/cloud/watson-tone-analyzer/pricing)                                   | 2,500 API Calls/Month    | 1-250K @ $0.0088<br>250K-500K @ $0.0013 | $2437            |

<small>*\* Costs based on 500,000,000 characters sent per month - as of 10/11/19 - subject to change*</small>

## Recap

Going through all of these services turned out to be a fun exercise and a good learning experience about the power of sentiment analysis.  Each vendor provides a good amount of functionality and accuracy.  When selecting one of the 4 providers, be sure to evaluate based on your language needs, and determine the costs breakdown based on your usage, as each service decreases with volume.

Amazon Comprehend, with its additional features, low cost, and basic language support, makes it my top choice. It's easy to setup, simple to use, and the response object has details that I find very useful.

If you would like to try out any or all of these services, the [Nexmo Extend](https://developer.nexmo.com/extend) team has created some example code to help you get started.

* [Amazon Comprehend](https://nexmo.dev/aws-nexmo-sms-analysis-js)
* [Azure Text Analytics](https://nexmo.dev/azure-nexmo-sms-analysis-js)
* [Google Natural Language API](https://nexmo.dev/google-nexmo-sms-analysis)
* [IBM Watson Tone Analyzer](https://nexmo.dev/ibm-nexmo-sms-analysis-repo)