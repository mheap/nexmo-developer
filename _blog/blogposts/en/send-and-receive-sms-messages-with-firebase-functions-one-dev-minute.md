---
title: Send and Receive SMS Messages with Firebase Functions | One Dev Minute
description: This quick walk-through will show you how to create an SMS message
  log and a response to the sender using Firebase Cloud Functions and the Real
  Time Database alongside the Vonage SMS API.
thumbnail: /content/blog/send-and-receive-sms-messages-with-firebase-functions-one-dev-minute/thumbnail-and-assets-for-one-dev-minute.jpg
author: amanda-cavallaro
published: true
published_at: 2021-12-06T11:49:51.109Z
updated_at: 2021-11-25T08:55:14.384Z
category: tutorial
tags:
  - sms-api
  - firebase
  - javascript
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Welcome to [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! This series is hosted on the [Vonage Dev YouTube channel](https://www.youtube.com/vonagedev). The goal of this video series is to share knowledge in a bite-sized manner.

This quick walk-through will show you how to create an SMS message log and a response to the sender using Firebase Cloud Functions and the Real Time Database alongside the Vonage SMS API. 

<youtube id="c8gHy_KvQAE"></youtube>

## Transcript

You can send SMS messages using Cloud Functions for Firebase.

You'll need to create a couple of accounts: 

* a Firebase
* and a Vonage API one.

Create the project in the Firebase console and choose whether or not you will use Analytics.

Wait for your project to be created.

Select the Firebase billing plan, in this case, it is the pay as you go.

In the Command line, install the Firebase tools.

Login to Firebase and authenticate. Create the project folder and change directory inside of it.

Initialize the Cloud Functions for Firebase.

Install the dependencies we are going to use inside the functions folder.

Create a `.env` file and add the Vonage environment variables there.

Inside the file `index.js`, add all the required dependencies and environment variables and initialize Firebase.

In the same file, create the first function which will act as a webhook to capture and log incoming SMS messages from a Vonage phone number.

Let's then create a function for Firebase to send the response SMS and to react to database updates.

Deploy the function, send an SMS message from your phone to the Vonage application phone number.

You'll then receive a response SMS message on your phone and an update to Firebase Real-Time Database.

You can find the full code on GitHub. Thank you for watching and happy coding!

## Links

[This Tutorial's Code on GitHub](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqazJ0UDFleGVwSnBfQU1ORTRLYkhDM0xrbkpZQXxBQ3Jtc0trcjJnY0E4QjRybFUwVk5GRWJQSVhMcnJERC1MbHQyWEpqaHNLSklyWjRiMFdZYmt2RzlaVVQ5UWRMYnVDa1V6SE1RcG5jTm5RSl9MbkRWNlhYZkRsYUtkc2JDXzZBM3p4NXRzNkZnTHp0LVMxbEdNUQ&q=https%3A%2F%2Fgithub.com%2Fnexmo-community%2Ffirebase-functions-sms-example).

[Find the Written Tutorial Here](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbUttd1Q0OHBsYU9fWlZyaHZlZ2JhN25FVE1LQXxBQ3Jtc0tsbFNxSVV1Q3ZtNzRUSkU4QUJwYVhHaENZZkJNYXZoemx0YkVjOUpWMmhMcXluRjBYVU4wNVcwdGU5SWFjU0FDUXRCUW1VNEd6U1ZjNTd5ZHl0V20xTW5fSUZfUXBzNldYUDltMlprOEhZRDBpMFMxMA&q=https%3A%2F%2Flearn.vonage.com%2Fblog%2F2020%2F01%2F24%2Fsend-and-receive-sms-messages-with-firebase-functions-dr%2F).

[Check Out the Developer Documentation](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbkdBRVRBMDZsY05fYTJJeE14UmxsMFFGUWJGQXxBQ3Jtc0trY21SMGtEaGRsaVBKUmdpMkxDMlh6NWFrU2JtNjRNcHlGM200bGoyaVRiOGFnN2lYOUFFNnY3V1hZaVFaMWlEamtFOGU0eDdtWmxEVnlJLWlzWFptT3NJM2RpZFQtclg2Z09zVUpHcmZUXzM1T3BOTQ&q=https%3A%2F%2Fdeveloper.vonage.com).

[Details About Vonage SMS Functionality](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa3VKcWlvTTJqXzRTODh6SEdoNUlvdmJuMHo1d3xBQ3Jtc0tub3hvYlFpbnhQVktXdWZFcENEVHNlbFNfUmFZenNOVUFoTmUwWHBwekxrSDBLWW1LZDg5UFBnZ2t4UWpBaFlFazBIcDF2bjRLc1c1ZGVNRUhKblFFRmZDLTQtQXIxMnBVQ1RKR1dGTG5xd0dPRzdqZw&q=https%3A%2F%2Fdeveloper.vonage.com%2Fmessaging%2Fsms%2Foverview).

[Getting Started with Firebase Functions](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbUdadHRpUm4zZkNSSkdmQnMzUUEzdTFxR2ZPd3xBQ3Jtc0trSTc4S0tUbmNGVEFxaHk3Zk5CbmE5c3pQMzgzczd0QUF0M3Y3aTMzWFhiVlhHTkdDa3I3aUFxNGZqN05SZ09TUG1wcFd6UW1FRkl0THFJbWFBRHBTbXg5c1lwbG4zSjZzRXdGS0dGR2l3dHQ2LUQ0NA&q=https%3A%2F%2Ffirebase.google.com%2Fdocs%2Ffunctions%2Fget-started).