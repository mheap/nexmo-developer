---
title: Send Raspberry Pi IP Address on Boot in Node with Messages
description: Being a Raspberry Pi enthusiast, there have been several occasions
  where a reusable script is needed that I can use to improve my projects. A
  prime example of this is knowing what my Raspberry Pi’s IP address is when
  booting in headless mode (without a monitor, keyboard, or mouse). Recently I
  published a tutorial on […]
thumbnail: /content/blog/send-raspberry-pi-ip-address-on-boot-in-node-with-messages/Blog_SMS_WhatsApp_RaspberryPI_1200x600.png
author: greg-holmes
published: true
published_at: 2020-08-05T13:45:36.000Z
updated_at: 2021-04-19T10:45:10.169Z
category: tutorial
tags:
  - node
  - messages-api
comments: true
redirect: ""
canonical: ""
---
Being a Raspberry Pi enthusiast, there have been several occasions where a reusable script is needed that I can use to improve my projects. A prime example of this is knowing what my Raspberry Pi's IP address is when booting in headless mode (without a monitor, keyboard, or mouse).

Recently I published a tutorial on how to build a [Home Surveillance System With Node and a Raspberry Pi](https://learn.vonage.com/blog/2020/05/19/home-surveillance-system-with-node-and-a-raspberry-pi/). When implementing this project, the idea is not to have the Raspberry Pi connected to a monitor, so no default way of knowing the IP address of the Raspberry Pi when it is booted up in a remote location away from any monitors. This tutorial will guide you through a solution to the problem of not knowing the IP address.

## Prerequisites

* A [Raspberry Pi](https://www.raspberrypi.org/)
* [Node](https://nodejs.org/en/) & [NPM](https://www.npmjs.com/) installed on the Raspberry Pi

<sign-up number></sign-up>

## The Code

Inside your project directory, create and open a file called `.env`, adding your environment variables.
You can find your `API_KEY` and `API_SECRET` in the [Vonage Developer Dashboard](https://dashboard.nexmo.com/). Add these values to the first two lines of the example below:

```env
API_KEY=
API_SECRET=
APPLICATION_ID=
APPLICATION_PRIVATE_KEY_PATH=private.key
SMS_FROM="MyIPAddress"
SMS_TO=
WHATSAPP_FROM=
WHATSAPP_TO=
```

If you choose to send SMS notifications, add your mobile number to the `SMS_TO=` part of your `.env` file. If you decide to use WhatsApp for your notifications, then add your WhatsApp enabled mobile number to the `WHATSAPP_TO=` part of your `.env` file.

You can find your `WHATSAPP_FROM` number on the [Messages Sandbox API](https://dashboard.nexmo.com/messages/sandbox) page.

```bash
npm init
```

Follow all of the input requests from the command above. Then, once finished, run the command below to install the `Nexmo Node SDK`, `Express`, `Body-Parser` and `DotEnv` packages into your project:

```bash
npm install nexmo@beta express body-parser dotenv -s
```

Make a new file in your project directory called `index.js`, and then open this file. The first part needed is to retrieve the IP Address of your Raspberry Pi.

Add the code below to your new `index.js` file. The `OS` module provides access to the information of the device's operating system such as the `network interfaces`.

The code below loops through each of these interfaces looking for the interface named `wlan0`, ensuring that interface is `IPv4` and is not an internal-facing interface.

```javascript
const os = require('os');

var ifaces = os.networkInterfaces();

Object.keys(ifaces).forEach(function (ifname) {
  ifaces[ifname].forEach(function (iface) {
    if ('wlan0' === ifname && "IPv4" === iface.family && iface.internal === false) {
      console.log(iface.address);

      return;
    }
  });
});
```

If you run the command below in your Terminal, you should have your device's Wifi IP Address output as a result:

```bash
node index.js
```

Next, it's time to send the IP address as a notification. This tutorial allows you to choose to send the notification as an SMS text message, a WhatsApp message, or both.

## Send SMS

Sending an SMS requires using your API key and API secret, which you've already saved in the `.env` file. First, at the top of your `index.js` file, add the following lines to include the `Nexmo` package and `DotEnv` package:

```env
+const Nexmo = require('nexmo');
const os = require('os');
+const dotenv = require('dotenv');
+dotenv.config();
```

Now, at the bottom of your file, add the following functionality, which initiates the `Nexmo` object with the API key and secret. The next line populates the variable `text` with the string "Your IP Address is:" and then the `ipAddress` passed into the function.

The last part of this method sends the SMS.

```javascript
function sendSms(ipAddress) {
  const nexmo = new Nexmo({
    apiKey: process.env.API_KEY,
    apiSecret: process.env.API_SECRET,
  });

  var text = "Your IP Address is: " + ipAddress;

  nexmo.message.sendSms(process.env.SMS_FROM, process.env.SMS_TO, text);
}
```

## Send WhatsApp

Sending a WhatsApp message requires a little more information, including an `Application ID` and the `Private Key`. To create an application, which generates both the `application_id` variable and the `private.key` file, run the follow command:

```bash
nexmo app:create "My IP address app" --capabilities=messages --messages-inbound-url=https://example.com/webhooks/inbound-message --messages-status-url=https://example.com/webhooks/message-status --keyfile=private.key
```

Open your `.env` file, and update the line `APPLICATION_ID=` to contain your new `Application ID`.

Back in your `index.js` file, at the bottom of the file add the following command:

```javascript
function sendWhatsApp(ipAddress) {
  const nexmo = new Nexmo({
    apiKey: process.env.API_KEY,
    apiSecret: process.env.API_SECRET,
    applicationId: process.env.APPLICATION_ID,
    privateKey: process.env.APPLICATION_PRIVATE_KEY_PATH
  }, {
    apiHost: 'messages-sandbox.nexmo.com'
  });

  var text = "Your IP Address is: " + ipAddress;

  nexmo.channel.send(
    { "type": "whatsapp", "number": process.env.WHATSAPP_TO },
    { "type": "whatsapp", "number": process.env.WHATSAPP_FROM },
    {
      "content": {
        "type": "text",
        "text": text
      }
    },
    (err, data) => {
      if (err) {
        console.error(err);
      } else {
        console.log(data.message_uuid);
      }
    }
  );
}
```

The above example creates a new function called `sendWhatsApp` with the parameter `ipAddress`. The function initiates a new instance of the `Nexmo` object using the `API_KEY`, `API_SECRET`, `APPLICATION_ID`, and `APPLICATION_PRIVATE_KEY_PATH`. The extra important bit of information needed here is setting the `apiHost` to make sure that the connection made is to the `messages-sandbox` API and not the standard production API.

The rest of the method creates a string telling the user what the IP Address, and then sends the `WhatsApp` message.

## Sending the Notification

As it stands, nothing gets sent if you run `node index.js`. The IP Address will be output, nothing further. To send the notification, whether it be as an SMS, WhatsApp message, or both, find the line: `console.log(iface.address);`. Below this line, add the following:

```javascript
// To send an SMS:
sendSms(ipAddress);
// To send a WhatsApp message:
sendWhatsApp(ipAddress);
```

## Run the Command

Now that the code is implemented and working, the operating system now needs to be configured to run this script whenever the Raspberry Pi boots up. To do this, open the following file in your Terminal:

```bash
sudo vim /etc/rc.local
```

This file will run commands whenever the Operating System boots up. Above the line: `exit 0` add the following command to run the project you've just built. Be sure to update the full path of the file `index.js`:

```bash
node /home/pi/ip-address-notification/index.js
```

## Test it!

You've set up a Raspberry Pi, written some code that allows you to either send the IP address of the Raspberry Pi to you via WhatsApp, SMS or Text-To-Speech voice call. All that's left to do now is reboot the Raspberry Pi and watch the notification(s) come into the destination number.

## Further Reading

Here are some more articles you may find helpful in building a service with a Raspberry Pi, or sending WhatsApp messages.

- [Home Surveillance System With Node and a Raspberry Pi](https://learn.vonage.com/blog/2020/05/19/home-surveillance-system-with-node-and-a-raspberry-pi/)
- [How to Send SMS Messages with Node-RED](https://learn.vonage.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
- [How to Send a WhatsApp Message with Node.js](https://learn.vonage.com/blog/2020/04/15/send-a-whatsapp-message-with-node-dr/)
- [Messaging Everywhere With Node.js](https://learn.vonage.com/blog/2020/05/27/messaging-everywhere-with-node-dr/)

And don’t forget, if you have any questions, advice or ideas you’d like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack).