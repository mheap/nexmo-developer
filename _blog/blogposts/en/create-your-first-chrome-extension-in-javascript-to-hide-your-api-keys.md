---
title: Create Your First Chrome Extension in JavaScript to Hide Your API Keys
description: In this tutorial, you will learn how to create a chrome extension.
  The example we will walk through today is to hide your Vonage API keys on the
  dashboard. The knowledge you’ll acquire from following the steps of this
  tutorial will give you a foundation on how to create your own chrome
  extensions for different purposes.
thumbnail: /content/blog/create-your-first-chrome-extension-in-javascript-to-hide-your-api-keys/javascript_hide-api-keys_1200x600.png
author: amanda-cavallaro
published: true
published_at: 2021-08-31T10:35:06.887Z
updated_at: 2021-08-23T10:21:09.603Z
category: tutorial
tags:
  - chromeextension
  - javascript
  - browser
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In this tutorial, you will learn how to create a chrome extension. The example we will walk through today is to hide your Vonage API keys on the dashboard. The knowledge you’ll acquire from following the steps of this tutorial will give you a foundation on how to create your own chrome extensions for different purposes.

## What Is a Chrome Extension

A Chrome extension is a software program that allows you to extend the chrome functionalities and change your browser experience. An extension can be built with HTML, CSS, JavaScript and a `manifest.json` file. The latter one provides Chrome with the information required to run the scripts for the extension to work.

## Create the Chrome Extension Folder

Create a new folder in your computer that will contain the `manifest.json` file and the bootstrap file, in our example we will name it `index.js`. For my example, I'll name this folder `chrome-extension`.

## Create the `manifest.json` file

A `manifest.json` file is required when creating a chrome extension, as it tells your program the function to be executed. 

Create a `manifest.json` file. From your terminal on Unix, you can type `touch manifest.json`. 

Populate it with the required information as you can see in the code snippet below. 

Let's look at each line step by step together.

* `name` is the extension name that will appear on the chrome extensions list.
* `description` is the description of what your chrome API does.
* `version` is the current version of your extension, if you make changes you can bump it.
* `author` should contain the name of the chrome extension creator.
* `manifest_version` refers to the version of the manifest, at the time of writing this blog post the latest one is 3.
* `content_scripts` are files that can make changes to the DOM and pass information to the extension. You can learn more on the [content script official webpage](https://developer.chrome.com/docs/extensions/mv3/content_scripts/). In this example, we would like our script to match the webpage <https://dashboard.nexmo.com/> and any of its subpages. We state the logic to be followed will be written on the file `index.js`.

```json
{
    "name": "API Key Hider",
    "description": "A chrome extension to blur your Vonage API keys",
    "version": "1.0",
    "author": "Amanda Cavallaro",
    "manifest_version": 3,
    "content_scripts": [{
      "matches": [
        "https://dashboard.nexmo.com/*"
      ],
      "js": ["index.js"]
    }]
}
```

## Create the bootstrap file

From your terminal create the `index.js` file. On a Unix machine, you can do so by typing `touch index.js`.

In order to have a chrome extension, you can create a simple function and it will be applied to the browser once you import it. 

Here's an example you could use to create a simple alert that would be executed once.

```javascript
function createAnAlert() {

 alert();

}

createAnAlert();
```

For this tutorial, we will use the code below to blur some API keys. 

Let's create a function called blurApiKeys. We will use `document.querySelector` and `document.querySelectorAll` to find the HTML elements that contain the API Key and the API Secret Key. Finally, we will add a blur of 20 pixels to these elements using CSS styling and setInterval calls the blurApiKeys function every 10 milliseconds.

```javascript
function blurApiKeys() {
  let apiKey = document.querySelector('#apiKeyField > div');

  if (apiKey) {
    apiKey.style.filter = 'blur(20px)';
  }

  let apiKeyLabel = [...document.querySelectorAll('label')].filter((x) =>
    x.textContent.includes('API Key')
  );

  let apiSecretLabel = [...document.querySelectorAll('label')].filter((x) =>
    x.textContent.includes('API secret 1')
  );

  for (let label of apiKeyLabel) {
    let div = label.nextElementSibling;

    if (div) {
      div.style.filter = 'blur(20px)';
    }
  }

  for (let label of apiSecretLabel) {
    let div = label.nextElementSibling;

    if (div) {
      div.style.filter = 'blur(20px)';
    }
  }
}

setInterval(blurApiKeys, 10);
```

## Import the Folder Created to Your Chrome Extensions

Now it’s time to import these two files you’ve created and add them as a chrome extension to your browser.

1. Open the Chrome browser.
2. Navigate to `chrome://extensions/`.
3. Click on developer mode on the top right to enable it (if it isn’t already).
4. Click Load unpacked on the top left and a file uploader tool will open.
5. Search for where you created the folder `chrome-extension` on your computer, click on it and finally click the select button.
6. You can see a new chrome extension called “API Key Hider” was created as it was specified in the name property of the `manifest.json`.
7. Make sure this chrome extension is enabled (toggled). If you ever would like to turn it off you can untoggle or remove it from your chrome extensions list.

You can see the above steps in a gif below: 

![A visual representation on how to import the Chrome Extension onto chrome](https://lh5.googleusercontent.com/V5WM3zlBYxucwFac4i8z9SkHNQ40yl4bdx6kfDZPwc5JwFW5dCgFc8heOp0nmtpcnvRwSODY0zpgaJGyKiTap3cyp8hBey6CLtPxgYcHytyAf33zOcSRbO7602msJPeA_iJYLQFV "A gif showing how to import the Chrome Extension onto chrome")

## Test It Out

Your chrome extension is now loaded and you can see the functionality of the function you created working in the browser. 

To test the function we created, navigate to the [Vonage Dashboard](https://dashboard.nexmo.com/), navigate through the pages in the dashboard and you’ll notice both your Vonage API and secret keys are hidden. If you need to copy them, the copy button next to it still works even though the keys are blurred, as per the image below.

![A screenshot of the settings page on the Vonage Dashboard with the keys blurred.](https://lh3.googleusercontent.com/cV7OP34ray68_XpRjvLt8Av0FrLsxtEm5teAyKQhkNwXS_-WUvYo0TEf6mi84hncPsapAS-IalMgONgtQg4rEp1Qpj5duN24TQ_uPPuGhAseQHtG9IPI5etUIISYCaKYeKIhR1wp "Settings page on the Vonage Dashboard with the blurred keys")

## Congratulations

Well done! You created a chrome extension to hide your Vonage API keys, now that you understand how to create, import and enable a chrome extension you can let your creativity flow and create many more extensions!

If you'd like to take it to the next level you can learn [how to publish it to the Chrome Webstore](https://developer.chrome.com/docs/webstore/publish/) from the official documentation.

Hope you enjoyed this. Feel free to contact me [on Twitter](https://twitter.com/amdcavallaro) or join our [Community Slack Channel](https://developer.nexmo.com/community/slack).