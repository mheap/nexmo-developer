---
title: Send SMS from a Spreadsheet
description: Send SMS from a spreadsheet and help Nelly holla back at Kelly
  Rowland in this tutorial from Katie McLaughlin. Creating an SMS client in
  Google sheets
thumbnail: /content/blog/how-to-send-sms-from-a-spreadsheet-dr/New-spreadsheet-who-dis.png
author: glasnt
published: true
published_at: 2019-01-23T21:39:18.000Z
updated_at: 2021-05-21T05:21:26.904Z
category: tutorial
tags:
  - javascript
comments: true
spotlight: true
redirect: ""
canonical: ""
---


A song that reached #1 in the charts around the world back in the day had a slightly confusing use of technology, where it looks like a text message is being sent or received on a Nokia phone using a spreadsheet application. In an interview on Australian television a few years ago, [Nelly was asked precisely this question](https://youtu.be/mr63bjj5fSg?t=189), and responded with: "It was new technology at the time. It looks a little dated now; I can see that". [An article from The Independent](https://www.independent.co.uk/arts-entertainment/music/news/nelly-kelly-rowland-dilemma-music-video-spreadhsheet-phone-a7442351.html) at the time laments that "Humanity still hasn’t got as advanced as being able to type ‘TEXT NELLY’ in an Excel cell and it work as a command".

![2002 was weird. Kelly Rowland texted her bf via Microsoft excel and got mad cuz he didn't text back.](/content/blog/send-sms-from-a-spreadsheet/xfmgoob.png "2002 was weird. Kelly Rowland texted her bf via Microsoft excel and got mad cuz he didn't text back.")

However, it's now 2019, and this functionality exists, thanks to Nexmo. 

Based on the information provided in the music video, we can see that Kelly Rowland (a third of the late ‘90s hit group Destiny's Child) has a spreadsheet loaded on her Nokia 9290 Communicator showing the text "WHERE YOU AT? HOLLA WHEN YOU GET THIS".

![A clip from the music video for Nelly's Dilemma, picturing the message "WHERE YOU AT? HOLLA WHEN [YOU GET THIS.]" in cell A1 of an excel spreadsheet, loaded on a Nokia 9290 Communicator](/content/blog/send-sms-from-a-spreadsheet/bqrigbh.gif "A clip from the music video for Nelly's Dilemma, picturing the message \\\\"WHERE YOU AT? HOLLA WHEN [YOU GET THIS.]\\\\" in cell A1 of an excel spreadsheet, loaded on a Nokia 9290 Communicator")

The question is: was this her last sent message? A received message? Moreover, who was it sent to?

Based on the meme, she's SMS'ing her (unnamed) boyfriend. Given this, she'd be upset at the lack of response (the equivalent of "Read: 9:28 pm" in today's terms). 

However, by going through the lyrics, it might be that she's SMSing Nelly, who is ignoring her advances, as she's in a relationship with another man with whom she has a child. 

So for the context of this article, I'm going to assume that Kelly SMS'd Nelly, and never received a reply, hence the drop Nokia moment.

How could we replicate this functionality nowadays? Relatively simply, with the Nexmo API and a bit of spreadsheet scripting. 

<sign-up></sign-up>

From here, we have all the pieces we need to [send an sms using cURL](https://developer.nexmo.com/messaging/sms/overview/curl?utm_campaign=dev_spotlight&utm_content=sms_excel_mclaughlin)

```
curl -X "POST" "https://rest.nexmo.com/sms/json" 
  -d "from=Kelly" 
  -d "text=WHERE YOU AT? HOLLA WHEN YOU GET THIS." 
  -d "to=17607067425" 
  -d "api_key=$NEXMO_API_KEY" 
  -d "api_secret=$NEXMO_API_SECRET"
```

Now we need to work out how to get this functionality into a spreadsheet. I'm using Google Sheets because I'd like to think it's what Kelly would have used should she have implemented this using today's tech. Also, using Google Sheets means this application is web-scale, which is always a bonus. 

We'll create a spreadsheet called "Dilemma SMS", and recreate what we can see from the original music video. 

In order to make actions in this spreadsheet, we'll be taking advantage of the fetchURL API in order to send a POST request to our endpoint.

```
function smsNelly() { 
  var api_key = 'xxxxxxxx'
  var api_secret = 'xxxxxxxxxxxxxxxx'

  var formData = {
    'from': 'Kelly',
    'to': 17607067425,
    'text': 'WHERE YOU AT? HOLLA WHEN YOU GET THIS.',
    'api_key': api_key,
    'api_secret': api_secret
  }
  
  UrlFetchApp.fetch(
    'https://rest.nexmo.com/sms/json', 
    {'method': 'post', 'payload': formData});
}
```

Now, to link this into something executable into our spreadsheet is going to take some doing. For this, we're going to leverage Google Apps Script.

![Spreadsheet script editor screenshot](/content/blog/send-sms-from-a-spreadsheet/qnbymds.png "Spreadsheet script editor screenshot")

To navigate to the Script Editor, there's a handy link from the Tools > Script editor menu. From here, we can create a new project with our function. 

![Script editor with function](/content/blog/send-sms-from-a-spreadsheet/pasted-image-0.png "Script editor with function")

For now, we've hardcoded all the values, just to keep this example simple. 

Next, we need to link this into our spreadsheet. We can create a mock 'button' by adding an image to our sheet and linking this function to the image. Thus, when we click on the image, the function runs. 

For the image, I'll be using the word 'Send' in the classic Nokia font. It's what Nelly would have wanted. 

![Assign script to image](/content/blog/send-sms-from-a-spreadsheet/pasted-image-0-1.png "Assign script to image")

With my image imported, if I right-click on the image to select it, and then click the "•••" menu, I can assign my script. 

**Super important note:** in this spreadsheet, always right-click images to highlight them. Once we assign the script, a left-click will execute the script. And we don't want to be texting Nelly any more than we already are, seeing as though he's not replying to just one SMS. That would be rude. 

![Assign script dialog](/content/blog/send-sms-from-a-spreadsheet/pasted-image-0-2.png "Assign script dialog")

From here, save our changes, and then we can click the button and tada! Executed script!

Except it's not that simple. We're executing functionality that can be malicious (we're calling out to random endpoints, for goodness sake), so Google is going to get us to authorise our application and get our explicit okay before we can use it. 

![Authorisation required dialog](/content/blog/send-sms-from-a-spreadsheet/pasted-image-0-3.png "Authorisation required dialog")

![Grant permission](/content/blog/send-sms-from-a-spreadsheet/unnamed-1.png "Grant permission")

These dialogs will only appear the first time we try and run the script; subsequent executions will Just Work™.

Assuming that Nelly ever actually checks his phone, he'll get the message: 

![Phone with SMS sent from spreadsheet](/content/blog/send-sms-from-a-spreadsheet/m0kztbc.jpg "Phone with SMS sent from spreadsheet")

*Maybe if he didn't have his phone on silent, he might have seen the message earlier?*

From here, we really should do something to clean up our code. We've hardcoded our message for a start, not to mention our API details. 

For that, we just need to extend our script to add a function to pull data directly from our spreadsheet. For example, pulling our text message from A1: 

```
function getMessage() { 
   var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet()
   var textMessage = ss.getRange("A1").getValue();
   Logger.log(textMessage);
   return textMessage
} 
```

This functionality can also be used to pull our API details from other cells in the sheet, if you like.

**Tip:** Reference Logger.log() to log useful information, accessible from your script under View > Logs. 

**Protip:** While you're testing, replace https://rest.nexmo.com/sms/json with https://httpbin.org/post, use dummy API keys, and log the response from the API. You'll get a copy of your POST command without using SMS credits. 

However, one thing that The Independent article touts as being future tech is "typ\[ing] ‘TEXT NELLY’ in an Excel cell and it works as a command". 

With some adjustments to our spreadsheet, this is totally possible. 

One thing we haven't yet included in the spreadsheet is the concept of Contacts; we've only hardcoded the SMS recipient.

If we create a new sheet in our spreadsheet, called Contacts, and list NELLY with 'his' number, we can change our script to pull from NELLY rather than the phone number. 

![Creating contacts](/content/blog/send-sms-from-a-spreadsheet/unnamed-2.png "Creating contacts")

![Contacts](/content/blog/send-sms-from-a-spreadsheet/unnamed-3.png "Contacts")

Noting here that we're prefacing our mobile numbers with a single quote mark. This ensures the digits are treated as strings, and not numbers, as Sheets likes to add the scientific notation to larger numbers. 

We'll also have to extend and change our script to pull the contact number from the Contacts sheet. 

```
  var CONTACT_CELL = "B1"
  var MESSAGE_CELL = "B2"

  var ss = SpreadsheetApp.getActiveSpreadsheet()
  var dataSheet = ss.getSheetByName("SMS")
  var contactSheet = ss.getSheetByName("Contacts")
  
  var contact = dataSheet.getRange(CONTACT_CELL).getValue();
  var toNumber = null
  
  // loop through all the contacts in the Contacts sheet
  var data = contactSheet.getDataRange().getValues();
  for (var i = 0; i < data.length; i++) {
    if (contact == data[i][0]) { 
      toNumber = data[i][1];
    }
  }
  
  if (toNumber == null) { 
    msg = "Contact not found: " + contact;
    throw new Error(msg);
  } 
 
  var textMessage = dataSheet.getRange(MESSAGE_CELL).getValue();

  // then continue to build the formData, as normal
```

However, The Independent wants the ability to type TEXT NELLY and have it just work. To implement this, we'd have to have our script start with the 'command' input, pull out the action and the contact from that, and work from there. 

This is left as an exercise for the reader. (It wouldn't be too hard using basic string functions. You might have noticed that the scripts we're using are JavaScript utilising Google's built-in libraries, so either raw JS or an API would help you here.)

## Postscript

If you plan to take this concept further than just a proof of concept, do make sure you go through the steps to validate yourself as a Google Developer. Otherwise, you'll get a worried email from Google about your use of your unverified app. 

![Permissions screen](/content/blog/send-sms-from-a-spreadsheet/unnamed-4.png "Permissions screen")

[Ready for your moment in the spotlight? Apply to be a guest writer now.](https://developer.nexmo.com/spotlight?utm_campaign=dev_spotlight&utm_content=SMS_excel_McLaughlin)