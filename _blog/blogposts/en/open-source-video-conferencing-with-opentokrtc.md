---
title: Open Source Video Conferencing
description: Introducing Open Source Video Conferencing with WebRTC and Vonage
  Video APIs. Enabling you to host your own web-based video conferencing
  solution.
thumbnail: /content/blog/open-source-video-conferencing/videoapi_opensource_1200x600.png
author: greg-holmes
published: true
published_at: 2021-03-24T12:21:37.852Z
updated_at: 2021-03-24T12:21:39.210Z
category: tutorial
tags:
  - video-api
  - node
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## What is Vonage Video (Formerly OpenTok / TokBox)?

[Vonage Video (Formerly TokBox / OpenTok)](https://www.vonage.co.uk/communications-apis/video/) is an API that allows businesses to build a custom video experience within any mobile, web, or desktop application.

This API supports all video use-cases, such as 1:1 video consultations, group video chat, or large scale broadcasts to thousands of people. You're able to record any session with control over how to compose and securely deliver these files to your chosen method of storage. Analytics allow you to see project-by-project summaries in the dashboards or see session-specific analytics through the [Advanced Insights API](https://www.vonage.com/communications-apis/video/features/advanced-insights/). The Video API enables you to build on our standard always-on encryption and GDPR-compliance capabilities to offer an extensive range of advanced security, firewall-control, regional isolation and compliance certificate options. There are many more features and services provided within the Vonage Video service. For more information on these, please head over to the landing page.

## What is WebRTC?

Web Real-Time Communication (WebRTC) is a free and open-source project that provides web browsers and mobile applications to have real-time communication with APIs. WebRTC allows audio and video communication to function within your web browser by allowing communication to happen directly between peer-to-peer, which removes the requirement to install plugins or download any native applications.

## What is Vonage Open Source Conferencing and Recording?

Vonage Open Source Conferencing and Recording is your private web-based video conferencing solution. It is based on the Vonage Video API Platform (formerly OpenTok API) and uses the Vonage Video SDKs and APIs. You can deploy the app on your servers to get your video conferencing app running on WebRTC.

If you wish to test this service out without hosting your own servers, you're welcome to head over to our [Demo webpage](https://opentokdemo.tokbox.com/). This demo page is hosted by a default version of the Open Source Conferencing and Recording package, which can be found on our [Github Repository](https://github.com/opentok/opentok-rtc).

## How Can I Host My Own Video Conferencing Software?

### Prerequisites

* [Redis](https://redis.io/)
* [Node](https://nodejs.org/en/)
* [Vonage Video Account](https://tokbox.com/account/user/signup?utm_source=DEV_REL&utm_medium=blog&utm_campaign=how-to-host-your-own-video-conferencing-software-using-webrtc)

### Installation

To run this server, you'll need to clone the repository and install all required third-party libraries. In your terminal, run the three commands below:

```bash
git clone git@github.com:opentok/opentok-rtc.git
cd opentok-rtc
npm install # Installs required packages
```

### Minimum Configuration

Once you've installed all of the required dependencies, some configuration is required. The very least you'll need to do is define your API key and secret, which you can obtain from the Vonage Video Dashboard.

To start, you'll need to create a `config.json` file, and the command below will copy a precompiled `config.json` file with all empty values for you. So run the command:

```bash
cp config/example.json config/config.json
```

Open this file, and the first few lines will be what you see in the example below:

```json
{
   "showTos": false,
   "meetingsRatePerMinute": 30,
   "OpenTok":{
      "apiKey": "<key>",
      "apiSecret": "<secret>",
      "publisherResolution": "640x480"
   },
   ...
}
```

Be sure to replace `<key>` and `<secret>` with your Video API key and the corresponding API secret that you retrieved from the Vonage Video Dashboard.

If you do not wish to keep the credentials within your `config.json` file, you can use environment variables instead. You can set the environment variables using the commands below, again making sure to replace `<key>` and `<secret>` with your values:

```bash
export TB_API_KEY=<key>
export TB_API_KEY=<secret>
```

### Running the Server

Before you run the RTC server, you'll need to make sure Redis is running, so in your terminal, enter the following command:

```bash
redis-server
```

The base command to run the server on localhost with all of the default settings, including the default port (`8123`), is the following command:

```bash
node start
```

However, there are some other flags you can add to your commands for a more customised setup. You can see a few of these examples below: 

```bash
node server -p 8080 # To run the server on a different port to the default
node server -d # To run the server as a daemon in the background
```

If you wish to use SSL, the server expects the SSL Certificate to be named `serverCert.pem` and the SSL private key file named `serverKey.pem`. You can find a pre-generated self-signed SSL certificate pair in the `sampleCerts` directory.

The flag `-S` tells the server it needs to enable the launch of a secure server while the flag `-C <dir>` along with the directory name tells the server where to find the certificates. To run the server using these certificates, you would enter the following:

```bash
node server -S -C sampleCerts
```

For detailed information on available options, run `node server -h`.

### Additional Configuration Options

There are many other options available for configuration to suit your needs. These options can be set either in your config.json file or as an environment variable. The keys for these options are specified first for each choice in the examples below:

* `appName` (config.json) / `APP_NAME` (environment variable) -- The name of the application displayed in various places throughout the lifecycle of the video call. The default value is "Vonage Video Conferencing".

* `introText` (config.json) / `INTRO_TEXT` (environment variable) -- The text displayed under the application name in the first page which displays the `precall` widget. The default value is 'Welcome to Video Conferencing'.

* `showTos` (config.json) / `SHOW_TOS` (environment variable) -- Whether the app will display the terms of service dialog box and require the user to agree to the terms before joining a room. The default value is `false`.

* `meetingsRatePerMinute` (config.json) / `MEETINGS_RATE_PER_MINUTE` (environment variable) -- Determines the maximum amount of new meetings that can be created in a minute. Users will be allowed to join a meeting that already exists. Otherwise a message will appear telling them that the service is not available at the moment. If the value is set to any negative number, rate limiting will be turned off and all meetings will be allowed. If this value is set to 0, all new meetings will be rejected. The default value is -1.

* `minMeetingNameLength` (config.json) / `MIN_MEETING_NAME_LENGTH` (environment variable) -- The minimum length of meeting names created. The default value, 0, indicates that there is no minimum length. (You can set this in the config file using the `minMeetingNameLength` setting.) The default value is 0.

* `maxUsersPerRoom` (config.json) / `MAX_USERS_PER_ROOM` (environment variable) -- The maximum number of users allowed in a room at the same time. Set this to 0, the default, to allow any number of users. The default value is 0.

* `enableRoomLocking` (config.json) / `ENABLE_ROOM_LOCKING` (environment variable) -- Whether or not to include the Lock Meeting command to users in the options menu. This command allows users to prevent new participants from joining a meeting. The default value is `true`.

* `autoGenerateRoomName` (config.json) / `AUTO_GENERATE_ROOM_NAME` (environment variable) -- Whether or not to auto-generate the room name on behalf of the user. If this setting is turned on, we will use haikunator to generate room names for new rooms. If turned off, users will be prompted to enter a room/meeting name when they visit the landing page and won't be allowed to move forward until they do so. The default value is `true`.

* `enableEmoji` (config.json) / `ENABLE_EMOJI` (environment variable) -- Whether or not to enable emoji support in the text chat widget.

### Customising the UI

For information on how to customise the Vonage Open Source Conferencing and Recording UI, see [CUSTOMIZING-UI](https://github.com/opentok/opentok-rtc/blob/master/CUSTOMIZING-UI.md).

### How Is My Service Running?

There is a health status check endpoint at `/server/health`. You can load this URL to check whether the app can connect to all required external services. On success, this health check endpoint sends a response with the HTTP status code set to 200 and the JSON similar to the following:

```json
{
  "name": "opentok-rtc",
  "version": "4.1.1",
  "gitHash": "312903cd043d5267bc11639718c47a9b313c1663",
  "opentok": true,
  "googleAuth": true,
  "status": "pass"
}
```

An example of a failing health check will be similar to the following:

```json
{
  "name": "opentok-rtc",
  "version": "4.1.1",
  "git_hash": "312903cd043d5267bc11639718c47a9b313c1663",
  "opentok": false,
  "error": "OpenTok API server timeout exceeded.",
  "status": "fail"
}
```

## More Reading

* [Vonage Video (Formerly OpenTok / Tokbox)](https://www.vonage.com/communications-apis/video/)
* [Vonage Open Source Conferencing and Recording Github Repository](https://github.com/opentok/opentok-rtc)
* [Broadcast Video Chat with Javascript and Vonage](https://learn.vonage.com/blog/2020/05/14/broadcast-video-chat-with-javascript-and-vonage-dr/)
* [Add Video Capabilities to Zendesk With Vonage Video API](https://learn.vonage.com/blog/2020/09/08/add-video-capabilities-to-zendesk-with-vonage-video-api/)




