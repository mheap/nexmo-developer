---
title: Integrate Advanced Insights to Monitor Video Quality
description: The Advanced Insights API provides data at the session and stream
  level. The Insights API allows you to explore your sessions’ metadata at the
  project level
thumbnail: /content/blog/integrate-advanced-insights-to-monitor-video-quality/Social_Monitor-Video-Quality_1200x627.png
author: michaeljolley
published: true
published_at: 2020-06-30T13:39:26.000Z
updated_at: 2021-05-04T17:05:23.379Z
category: tutorial
tags:
  - graphql
  - insights-api
comments: true
redirect: ""
canonical: ""
---
Healthcare. Education. Collaboration. Odds are you've been communicating via online video conferencing a lot more frequently. Minutes used by customers of the Vonage Video API increased 232% from February to March alone. In the healthcare industry, video minutes increased by 727%.

With this increase in load, it's more important than ever to know what type of quality of service you're providing your customers. Are Mr Pates' students able to clearly see and hear their lessons? Is Dr Sanchez able to provide the quality of care her patients need? If they experience problems, you want to have answers.

That's why Vonage created the [Insights and Advanced Insights APIs](https://tokbox.com/developer/guides/insights/). These GraphQL APIs help you build scalable, reliable solutions for your end-users, but it's important to know what data is provided, when it's available and how long it's accessible.

## Insights API

The Insights API allows you to explore your sessions' metadata at the project level. This metadata includes metrics like:

* **Usage:** Information on stream published minutes, stream subscribed minutes, archive usage, broadcast usage, and SIP usage
* **Quality:** Information about video quality
* **Errors:** The failure rates for connecting to sessions, publishing, and subscribing

![Example GraphQL code used with the Insights API](/content/blog/integrate-advanced-insights-to-monitor-video-quality/insights-example.png "Example GraphQL code used with the Insights API")

The API allows you to filter and group the data by the SDK type, SDK version, country, region, browser, browser version, and additionally, segment the data at daily, weekly or monthly intervals.

### Data Retention

Insights data is aggregated daily at the project level. Because of this, it is not available in real-time. **Insights API data has an expected availability latency of 36 - 48 hours.**

![Timeline displaying retention spans of the Insights API](/content/blog/integrate-advanced-insights-to-monitor-video-quality/insights-retention.png "Timeline displaying retention spans of the Insights API")

For 60 days, Insights data is available in daily aggregated segments. Beyond that, and for up to 12 months, it is available in monthly aggregates. After 12 months, the data is not retained by the Insights API.

## Advanced Insights API

The Advanced Insights API provides data at the session and stream level. Sessions are divided into meetings and each session could consist of many meetings. A new meeting is created when someone joins the session and it has had no participants for the previous 10 minutes.

The session data includes:

* **Metadata:** Media mode, published minutes, and subscribed minutes
* **Meetings:** An array of any meetings that occurred during the time-frame specified for this session. It includes:

  * **Connections:** An array of connections defining each client that joined the session during the meeting. It includes SDK used, browser used, information about publishers/subscribers and more
  * **Metadata:** Published minutes, subscribed minutes, and when the meeting was created and destroyed
  * **Publishers:** An array of publishers that were present during the meeting. It includes data about their streams, subscribers, and stream statistics
  * **Subscribers:** An array of subscribers that were present during the meeting. It includes information about the subscriber's stream and stream statistics

![Example GraphQL query for the Advanced Insights API](/content/blog/integrate-advanced-insights-to-monitor-video-quality/adv-insights-example.png "Example GraphQL query for the Advanced Insights API")

### Stream Statistics

The power of Advanced Insights lies in in-stream statistics. This data includes 30-second snapshots of audio &amp; video latency, bitrate, packet loss ratio, and codecs. It also includes video resolution information and whether a stream included audio and/or video at the time of the snapshot.

Using this information you can review the entire experience of the user in terms of the quality of their stream and compare that data across metrics like SDK, browser, time-of-day, and more. Using this level of insight you can optimize your applications across platforms to ensure your customers have the best experience possible.

### Data Retention

Advanced Insights data is available for 21 days. The retention period is based on the created-at time of a meeting within a session. **The data has an expected availability latency of 5 minutes from meeting end.**

![Timeline displaying retention spans of the Advanced Insights API](/content/blog/integrate-advanced-insights-to-monitor-video-quality/adv-insights-retention.png "Timeline displaying retention spans of the Advanced Insights API")

During our regular database maintenance windows, Advanced Insights data may not be accessible. All data will be backfilled shortly after the specified maintenance period.

|                             | Day             | Time          | Data Available By |
| --------------------------- | --------------- | ------------- | ----------------- |
| Daily database maintenance  | Monday - Sunday | 9pm - 11pm PT | 11:30pm PT        |
| Weekly database maintenance | Sunday          | 4am - 7am PT  | 8am PT            |

## Integrating Advanced Insights

In many cases, you'll want to retain access to your Insights and Advanced Insights data for longer than our retention policies provide. Whether using server-less functions or scheduled tasks, you'll want to query the API endpoints at regular intervals to retrieve and load the data to your database. Storing this data long-term in your database of choice provides you with the opportunity to seamlessly provide insights to your team and/or clients and compare metrics over larger time-scales.

> Remember, data in both APIs are aggregated using Pacific Time so be sure to include any timezone offsets when determining the time of day to run your queries.

### Insights API Query Frequency

Since the Insights API is aggregated daily, you shouldn't query it more than once daily. Querying and storing this data each day or even every few days would be sufficient.

### Advanced Insights API Query Frequency

Advanced Insights data for a meeting is available 5 minutes after the meeting has ended. The appropriate time to query this data is dependent on your applications need for near real-time data. **Be sure to account for the Advanced Insights database maintenance periods specified above.**

## Wrap Up

With the Insights &amp; Advanced Insights data at your fingertips, you'll be able to identify trends in client platforms, browsers and empower your team to identify issues with packet loss, user bitrates, and latency within minutes. To learn more about the Insights &amp; Advanced Insights APIs and how they can empower you to make more informed decisions, check out the links below:

* [Request a Free Trial of Advanced Insights](https://www.vonage.com/communications-apis/campaigns/advanced-insights/)
* [Get In-Depth Data to Transform Your Users' Live Video Experiences](https://www.vonage.com/resources/articles/get-in-depth-data-to-transform-your-video-application-experience/)
* [Insights Dashboard &amp; API](https://tokbox.com/developer/guides/insights/)
* [Insights Data Retention and Latency](https://tokbox.com/developer/guides/insights/#data-retention-and-latency)
* [Getting Started with Advanced Insights](https://www.nexmo.com/blog/2020/04/07/getting-started-with-advanced-insights)
* [Using Apollo to Query GraphQL from Node.js ](https://www.nexmo.com/blog/2020/03/12/using-apollo-to-query-graphql-from-node-js-dr)