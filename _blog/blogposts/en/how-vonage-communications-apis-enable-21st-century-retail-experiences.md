---
title: "How Vonage Communications APIs Enable 21st Century Retail Experiences"
description: Show Rooming is a growing concern for brick-and-mortar retailers.
  See how Vonage APIs can work together to provide a smooth in-person
  experience.
thumbnail: /content/blog/how-vonage-communications-apis-enable-21st-century-retail-experiences/21st-century-retail.png
author: bernard-slede
published: true
published_at: 2022-07-07T09:20:41.503Z
updated_at: 2022-07-07T09:20:42.316Z
category: inspiration
tags:
  - node
  - verify-api
  - voice-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*This article was written in collaboration with [Chris Tankersley](https://developer.vonage.com/blog/authors/christankersley)*

## The perfect storm of challenges for retailers

Before we look at the solution, let’s look at the seriousness of the situation for retail as an industry. A few years ago, the director of a leading North American retailer sent an alarmed email to his fellow board members: "We are in deep trouble". He had just been to one of the stores and noticed a number of shoppers walking around with their phones and seemingly taking pictures of the merchandise. Puzzled, he asked a few of them what they were doing.

They were actually using their phones to read the bar codes, check out the item prices at a rival online store, and complete purchases on their phones. That effectively meant the brick-and-mortar retailer was serving as the showroom for the online competitor! This phenomenon, called “showrooming”, meant each retailer was now sitting on real estate assets that it was no longer exclusively benefiting from.

Recent trends in several markets have heightened the challenge for retailers: the Covid-19 pandemic significantly impacted foot traffic in stores for several months, and now that economies have restarted, supply chain issues have increased, and stores are having difficulties finding staff.

[UBS is predicting](https://www.cnbc.com/2022/04/13/ubs-50000-retail-store-closures-in-us-by-2026-after-pandemic-pause.html) 50,000 store closures in the U.S. alone over the next 5 years. So, the question is: how do you keep the doors open and customers coming? 

## Digital engagement in physical spaces

As we saw, retail is facing major challenges with “showrooming”, diminishing foot traffic, supply chain disruptions and hiring issues. Digital communications are helping solve some of those challenges by enabling new experiences. 

Research has shown that sales conversations that involve a video interaction are more likely to result in a successful outcome for the sellers. 

Back to the showrooming issue, by enabling communications while the customers are in the store, a remote sales assistant can help seal the deal there and then, by measuring sentiment, gauging any hesitation and addressing any questions.

For instance, if the shopper is indeed thinking about comparison shopping, the agent can do an instant price match while communicating with the shopper in the store and possibly throw in a special coupon or promotion such as for delivery or installation. If the store can meet the customer’s needs while they are ready to make a purchase, they should.

## How the Vonage APIs can help with retail challenges

Vonage Video API can be used to allow the shopper to see the human they are speaking to, with facial expressions and everything that makes an interaction rich; for the shopper to show the agent what they are looking at; and for the agent to share their screen if need be. A Retailer can easily measure the ROI by enabling a switch to video for those conversations (with the shopper’s consent, of course).

To help visualize a solution that can be rapidly implemented, here is a contact center augmentation scenario that Vonage is actively working on with some of its partners:

* A customer walks into a store to purchase a high-priced TV set, needs help deciding and there is no experienced store staff to assist them; 
* The retailer has placed QR codes on their TV sets; 
* The shopper scans a QR code which takes them to a webpage on their phone; 
* On that page, the shopper can enter their phone number to chat using Vonage SMS
  this effectively puts the shopper in live communication with a remote store representative who is knowledgeable about TV products.

![Vonage contact center augmentation scenario](/content/blog/how-vonage-communications-apis-enable-21st-century-retail-experiences/cc-retail_blog-graphic-xs.png)

While this article is meant to help get some gears turning, we do have some sample code you can use to see sample code on how Vonage APIs can help with retail interactions. The sample application will show you how to use our Verify API to validate a user and our Voice API to place an in-browser call to a support agent. 

## Sample code

### Prerequisites

* Node.js v14 or higher
* Our Command Line Interface, which you can install with `npm install @vonage/cli -g`
* [Example Code](https://github.com/Vonage-Community/blog-retail-demo) that shows this solution working end-to-end
* [Ngrok](https://ngrok.com/) for testing locally

<sign-up></sign-up>

### Application setup

The example code requires a Vonage Application to be created. To create the application, we will be using our command-line interface. If you have not set up the CLI yet, do so by running the command `vonage config:set --apiKey=api_key --apiSecret=api_secret` in your terminal, where the API Key and Secret are the API key and secret found on your [account’s settings](https://dashboard.nexmo.com/settings) page.

If you're running the application locally you'll want to use ngrok to provide an external endpoint. Provide either your ngrok URL or (or other hosting URL) with routes `/webhooks/answer` for the Answer Url and `/webhooks/events` for the Event Url.

You now need to create a Vonage Application. An application contains the security and configuration information you need to connect to Vonage. In your terminal, create a Vonage application using the following command replacing the answer and event URLs with your ngrok or hosting URLs:

```sh
vonage apps:create "Store Demo" --voice_event_url=https://example.com/webhooks/events --voice_answer_url=https://example.com/webhooks/answer 
```

We can use Vonage Verify to make sure that the chat request is valid. First, we can make a small page to ask for the user's telephone number:

```javascript
// src/routes/verify.js
router.get('/', (request, response) => {
  response.render('verify/start', {
    item_name: request.query.item_name
  })
})
```

```
// views/verify/start.pug
doctype html 
html 
    head 
        title Store Chat Login
    
    body 
        form(method="post")
            div
                label Enter your mobile phone number to start a chat with #{item_name} 
            div
                input(name="mobile_number")
            div
                input(type="submit", value="Send Verification Code")
```

The user can enter their telephone number, and we will fire off a verification request. This will send a four-digit code to the user's telephone number that they can enter on the next screen.

```javascript
// src/routes/verify.js
router.post('/', (request, response) => {
  vonage.verify.request({
    number: request.body.mobile_number,
    brand: 'Vonage Store Demo',
    workflow_id: 6
  }, (err, results) => {
    if (err) {
      console.error(err)
    }

    request.session.verify_request_id = results.request_id
    request.session.mobile_number = request.body.mobile_number
    request.session.save()

    response.redirect('/verify/check')
  })
})
```

```
// views/verify/check.pug
doctype html 
html 
    head 
        title Store Chat Login
    
    body 
        form(method="post")
            div
                label Please enter the verification code that was sent to you 
            div
                input(name="verify_pin")
            div
                input(type="submit", value="Submit Verification Code")
```

The user can enter the PIN that is sent to their device. Most mobile devices will pick up the SMS message and allow the user to auto-fill the form as well. If the user does not receive the SMS, Vonage will also attempt to call the handset and provide the PIN via a voice call.

```javascript
// src/routes/verify.js
router.post('/check', async (request, response) => {
  vonage.verify.check({
    request_id: request.session.verify_request_id,
    code: request.body.verify_pin
  }, async (err, results) => {
    if (err) {
      delete request.session.verify_request_id
      request.session.save()
    } else {
      request.session.verified = true
      request.session.save()
      request.session.user = await getUser(request.session.mobile_number)

      response.redirect('/voice')
    }
  })
})
```

Once the number has been verified, we can create a user that will enable us to allow the user to call our agent later on directly from the browser. `getUser()` will find the user in our system, and if they do not exist, automatically create them. 

At this same time, you can interact with your CRM or agent system to alert an agent that a user has requested help. 

The QR code information is automatically passed along to the representative regarding the store location and the brand, model, and price of the TV.
The agent answers preliminary questions the shopper has. Because typing is not always convenient for the shopper, the agent can offer to seamlessly switch to a voice conversation, using the Vonage click-to-call capability. This applies whether the customer is using a regular webpage, SMS or chat, or even the store’s own mobile app.

Once the user was verified, our webpage can give them the option to call our system.

```
// views/voice/index.pug
doctype html 
html 
    head 
        title Store Chat Login
        script(type="module", src="https://unpkg.com/nexmo-client@latest/dist/nexmoClient.js?module")
    
    body 
        p
            | You are currently logged in as 
            span(id="username")

        p A chat agent will contact you via text shortly.

        p
            | If you would rather talk to an agent, click 
            button(type="button", id="call_agent") here

        p
            button(type="button", id="hangup") Hang Up
```

To begin, we add two buttons to the page that will allow the user to actually contact the agent as well as hang up. We also include the Vonage Client SDK, which handles the background setup for in-browser messaging and voice.

As for the browser code, we need to do a few things. We need to generate an authentication token, called a JWT. This token allows our browser to make a request to the Vonage API that facilitates the in-browser calling. We will generate this token server-side, as it requires a secret block of text called a Private Key.

```javascript
// src/routes/jwt.js
router.get('/jwt', (request, response) => {
  const jwt = vonage.generateJwt({
    sub: request.session.user.name,
    acl: {
      paths: {
        '/*/users/\*\*': {},
        '/*/conversations/**': {},
        '/*/sessions/**': {},
        '/*/devices/\*\*': {},
        '/*/image/**': {},
        '/*/media/**': {},
        '/*/applications/\*\*': {},
        '/*/push/**': {},
        '/*/knocking/**': {},
        '/\*/legs/\**': {}
      }
    }
  })

  response.json({ jwt })
})
```

Our server will create the JWT specifically for our user, and our front-end will save this. We can then use this JWT to connect to the Vonage APIs using the `NexmoClient`, which is a JavaScript class provided by our Client SDK.

```
// views/voice/index.pug
async function getJwt() {
    let jwt;
    await fetch('/auth/jwt')
        .then(results => results.json())
        .then(data => {
            jwt = data.jwt
        })
        .catch(err => console.error(err))

    return jwt;
}
```

Once we have connected to the Vonage API with `nexmo.login(jwt)`, we can attach a listener that will call our agent when the user clicks the appropriate button. We will also go ahead and wire up the "Hang Up" button so the user can end the call from their end.

```javascript
async function bootstrap() {
    let jwt = await getJwt();
    nexmo = new window.NexmoClient()
    app = await nexmo.login(jwt)
    document.getElementById('username').innerHTML = app.me.name

    document.getElementById("call_agent").addEventListener('click', (event) => {
        app.callServer('#{from_numer}');
    })

    app.on("member:call", (member, call) => {
        document.getElementById('hangup').addEventListener('click', (event) => {
            call.hangUp();
        });
    })
}
```

To see the code described in this blog post in action have a look at the [Github repo](https://github.com/Vonage-Community/blog-retail-demo). 

## Conclusion

With Vonage APIs, retail executives can meet their brick-and-mortar customers’ needs and minimize leakage of revenue to their competition. Vonage APIs can be added to a variety of applications in almost any programming language, allowing your users to decide how they want to be contacted.

Hopefully, this gives you some ideas to start seeing how you can integrate Vonage Communication APIs into your retail experience. 

If you have any questions come join our [Vonage Community Slack](https://developer.vonage.com/community/slack) or send us a message on [Twitter](https://twitter.com/VonageDev).

### Further Reading

* [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview)
* [Vonage Verify API](https://developer.vonage.com/verify/overview)
* [Vonage Voice API](https://developer.vonage.com/verify/overview)
* [Contact Center Intelligence](https://www.vonage.com/communications-apis/contact-center-intelligence/)
* [Real-Time Sentiment Analysis](https://www.vonage.com/communications-apis/programmable-solutions/sentiment-analysis/)
