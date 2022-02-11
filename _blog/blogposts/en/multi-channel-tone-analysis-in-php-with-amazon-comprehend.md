---
title: Multi-Channel Tone Analysis in PHP with Amazon Comprehend
description: In this post, you'll update an AWS Lambda function introduced in a
  previous post where the results of a voice transcription get stored in RDS.
thumbnail: /content/blog/multi-channel-tone-analysis-in-php-with-amazon-comprehend/Social_Sentiment-Analysis_Voice_1200x627-1.png
author: adamculp
published: true
published_at: 2020-07-02T13:30:32.000Z
updated_at: 2021-05-04T17:18:22.857Z
category: tutorial
tags:
  - php
  - voice-api
comments: true
redirect: ""
canonical: ""
---
In this post, you'll update an [AWS Lambda](https://aws.amazon.com/lambda/) function introduced in a previous post where the results of a voice transcription get stored in [RDS](https://aws.amazon.com/rds/). The objective for this example is to use [Amazon Comprehend](https://aws.amazon.com/comprehend/) to retrieve the tone analysis for an entire conversation, by channels, and then add the results to an [RDS](https://aws.amazon.com/rds/) MySQL database instance.

See [nexmo-community/voice-channels-aws-transcribe-php](https://github.com/nexmo-community/voice-channels-aws-transcribe-php), and [nexmo-community/aws-voice-transcription-rds-callback-php](https://github.com/nexmo-community/aws-voice-transcription-rds-callback-php) for an understanding of what you will be working with for this example.

<sign-up></sign-up>

## Prerequisites

* To get the most from this example, you should look at the following repos to start:

  * [nexmo-community/voice-channels-aws-transcribe-php](https://github.com/nexmo-community/voice-channels-aws-transcribe-php)
  * [nexmo-community/aws-voice-transcription-rds-callback-php](https://github.com/nexmo-community/aws-voice-transcription-rds-callback-php)
* Though the first post is needed, you will mostly be updating code in the second for this example.

## Setup Instructions

With the [nexmo-community/aws-voice-transcription-rds-callback-php](https://github.com/nexmo-community/aws-voice-transcription-rds-callback-php) code deployed, you will need to update the `index.php` file in the following ways:

* Add an import statement for AWS Comprehend, to the top of the file with the other imports.

```php
use Aws\Comprehend\ComprehendClient;
```

* From line 54 to 62, update the `$conn-insert()` contents to include the `sentiment` field.

```php
$conn->insert('transcriptions', [
    'conversation_uuid' => $conversation_uuid,
    'channel' => ($channel['channel_label'] == 'ch_0' ? 'caller' : 'recipient'),
    'start_time' => $startTime,
    'end_time' => $endTime,
    'content' => $item['alternatives'][0]['content'],
    'sentiment' => serialize(getSentiment($conversation['content'])->toArray()),
    'created' => $record_date,
    'modified' => $record_date
]);
```

* Add the following function to the end of the file, that enables `sentiment` to get populated for the database insertion.

```php
function getSentiment(string $content) : Aws\Result {

    $comprehendClient = new ComprehendClient([
        'region' => $_ENV['AWS_REGION'],
        'version' => $_ENV['AWS_VERSION'],
    ]);

    return $comprehendClient->detectSentiment([
        'LanguageCode' => 'en',
        'Text' => $content,
    ]);
}
```

* Update the `conversations` table in the `RDS` database created in the previous post, to include the `sentiment` content.

```sql
USE `voice_transcriptions`;

ALTER TABLE `conversations` ADD COLUMN `sentiment` TEXT AFTER `content`
```

### Deploy to Lambda

With all the above updated successfully, you can now use `Serverless` to redeploy the app to [AWS Lambda](https://aws.amazon.com/lambda/).

```bash
serverless deploy
```

### Ready

Your app is now updated to include tone analysis with the conversation content, going forward.

## Next Steps

If you have any questions or run into troubles, you can reach out to [@VonageDev](https://twitter.com/vonagedev) on Twitter or inquire in the [Nexmo Community](http://nexmo-community.slack.com) Slack team. Good luck.