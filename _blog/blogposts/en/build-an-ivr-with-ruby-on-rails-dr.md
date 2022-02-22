---
title: How to Build a Simple IVR with Ruby on Rails
description: Build an Interactive Voice Response (IVR) Ruby on Rails application
  powered by the Vonage Voice API with this step-by-step walkthrough.
thumbnail: /content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/ruby_ivr_1200x600.png
author: ben-greenberg
published: true
published_at: 2019-07-04T14:32:23.000Z
updated_at: 2021-08-25T13:02:19.649Z
category: tutorial
tags:
  - ruby-on-rails
  - voice-api
comments: true
redirect: ""
canonical: ""
---
> We've built this example using Ruby 3.0.0 and Ruby on Rails 6.1.4.1, and the Vonage Voice API.

Have you ever dialed a company and been prompted to follow along with menu prompts? If you have then you have interacted with an Interactive Voice Response (IVR). The IVR acts on input provided by the caller, usually in the form of numeric keypad choices. You can build your own IVR using Ruby on Rails and the Vonage Voice API.

In this walkthrough, we will build a small Rails application that will host a simple IVR service. After we are done, you can expand on this application to build whatever you need. In this tutorial, our application will accept a numeric input (also called a DTMF code) from the caller, and then speak back the input entered to the caller. 


## Prerequisites

You will need the following to follow along in this tutorial:

* [Ruby on Rails](https://rubyonrails.org/)
* [ngrok](https://ngrok.io) so Vonage can access the service running locally on your machine

<sign-up></sign-up>

## Getting Started

### Create a Rails Application

The first thing we need to do is to create a new Rails application. You can do so on your command line with the following:

```bash
$ rails new vonage-rails-ivr-demo --skip-activerecord
```

The above command will create our Rails app in `/vonage-rails-ivr-demo`, and will also skip installing a database. In this tutorial we will not be persisting our data, so we do not need it. 

Change directories into the `vonage-rails-ivr-demo` folder and run `bundle install` from the command line. While Vonage has a robust [Ruby SDK gem](https://github.com/Vonage/vonage-ruby-sdk), and a [Rails initializer gem](https://github.com/Nexmo/nexmo-rails), we do not need to install either for this application. 

### Create an IVR Controller

Now that our application has been created our next step is to create the Controller that will respond to two routes with [Nexmo Call Control Objects (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference). The first route will answer the call and request the caller to press a number on their keypad. The second route will speak back the number the caller entered.

To create our Controller run the following from the command line:

```bash
$ rails generate controller IVR
```

Once that has completed, open up the application in your preferred code editor and let's edit the newly generated `/app/controllers/ivr_controller.rb`. We are going to add methods for our two routes now. First, let's create the `#answer` method that will pick up the call:

```ruby
# ivr_controller.rb

class IvrController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  BASE_URL = ''

  def answer
    render json:
      [
        {
          action: 'talk',
          text: 'Welcome! This is the Vonage Ruby on Rails IVR Demo Application. Please enter a number on your keypad, followed by the hash key.',
          language: "en-US",
          style: 9
        },
        {
          action: 'input',
          submitOnHash: true,
          eventUrl: ["#{BASE_URL}/event"]
        }
      ].to_json
  end
end
```

As shown above, the `#answer` method provides two NCCO instructions. The first is the `talk` action, wherein the caller is greeted by the application. I chose the United States locale and style number 9. The Voice API provides a robust selection of language and style options, see more in the [text-to-speech guide.](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech)
**Note:** the previous voiceName parameter is now deprecated. [Read more.](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#supported-languages)

The second action is the `input` action, and we have set the optional parameter `submitOnHash` to `true` so that the input ends when the user presses the hash key on their phone. We also provide the required `eventUrl` parameter with a URL that points to our other route that will respond to the user input.

Lastly, we see that the `#answer` method uses a constant variable called `BASE_URL` that is currently defined as an empty string. Later in this walkthrough, we will fill that in with our ngrok externally accessible URL. 

Now, let's add our second and final Controller action, `#event`. This will act upon the caller input by speaking back to the caller their number choice:

```ruby
# ivr_controller.rb

def event
  number = params['dtmf']

  render json:
  [
    {
      action: 'talk',
      text: "You entered #{number}. Thank you for trying the Vonage Ruby on Rails IVR Demo Application!",
      language: "en-US",
      style: 9
    }
  ].to_json
end
```

All together our Controller will look like this:

```ruby
# ivr_controller.rb

class IvrController < ApplicationController
  skip_before_action :verify_authenticity_token

  BASE_URL = ''

  def answer
    render json:
      [
        {
          action: 'talk',
          text: 'Welcome! This is the Vonage Ruby on Rails IVR Demo Application. Please enter a number on your keypad, followed by the hash key.',
          language: "en-US",
          style: 9
        },
        {
          action: 'input',
          submitOnHash: true,
          eventUrl: ["#{BASE_URL}/event"]
        }
      ].to_json
  end

  def event
    number = params['dtmf']

    render json:
    [
      {
        action: 'talk',
        text: "You entered #{number}. Thank you for trying the Vonage Ruby on Rails IVR Demo Application!",
        language: "en-US",
        style: 9
      }
    ].to_json
  end

end
```

### Define Routes

The next step we need to do is to define our routes. We do that by editing the `/config/routes.rb` file and adding the two URL paths corresponding to our two Controller actions:

```ruby
# routes.rb

Rails.application.routes.draw do
  get '/answer', to: 'ivr#answer'
  post '/event', to: 'ivr#event'
end
```

### Configure ngrok

Starting with Rails 6, you must give your ngrok tunnel URL permission to access your development environment. The NGROK_URL will be replaced by your actual ngrok URL in the following step. Add the following to your `development.rb` file. \
\
**Note:** You must restart your rails server after editing `development.rb` for changes to take effect.

```ruby
#development.rb

  config.hosts << "NGROK_URL.ngrok.io"
```

At this point, our Rails application is ready to run. Now let's set up our ngrok externally accessible URL. We will need that for the final step, which is creating our Vonage application and our Vonage provisioned phone number.

## Connect to the Outside World

### Set Up ngrok

There are several ways to make our local development server externally accessible, but one of the simplest ways is with ngrok. You can read [this article](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) for a more detailed explanation of how ngrok works.

However, for our purposes, we just need to get it running and copy the URL that it provides us.

In order to start ngrok, open up a new terminal window and execute the following from the command line:

```bash
$ ngrok http 3000
```

You will now see a ngrok logging interface in your terminal window. Near the top of the interface is a line that begins with `Forwarding` and contains two URLs. The first is the externally accessible ngrok URL, which ends with `ngrok.io` followed by `http://localhost:3000`, that being your local development server. Now, when you or Vonage contacts the `ngrok.io` URL, it will forward it to your local server.

Now would be a good time to go back to the `ivr_controller.rb` and replace the empty string with your ngrok URL for the `BASE_URL` constant. You should also replace your ngrok URL for NGROK_URL in the `development.rb`  file. We will also be using it in our next step of setting up our Vonage account, phone number, and Voice application.

## Get Connected with Vonage

### Set Up a Vonage Account

In order for our voice application to work, we need a Vonage account, a Vonage provisioned phone number, a Vonage application, and, lastly, we need to link our application to our phone number.

You can create a Vonage account for free, and as an added bonus, your account will be credited with 2 euros to begin using your new application. Visit the [Vonage API Developer Dashboard](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) and follow the sign-up steps if you do not already have a Vonage API Developer account. Once you complete sign-up, you will see your Vonage API Developer Dashboard.

From the left-hand menu, click on the `Voice menu` item. You will see the following options:

![voice menu options](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/ivr-screenshot3.png "voice menu options")

Click on the `Getting started` option and you will be directed to a page where you can test the text-to-speech functionality or set up a new Vonage application. Find the following `Create an application` form:

![create application form](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/ivr-screenshot5.png "create application form")

Complete the form with the following:

* `Application name` text field enter `vonage-rails-ivr-demo`

Once you have finished, go ahead and click the `Create Application` button.

After the application has been created you can generate a public/private key pair. We will not be using them for this tutorial, but it is good to know where they are in case you choose to expand upon this application with more functionality.

You now have created a Vonage Voice application. Our next step is to purchase a Vonage phone number and link it to this application. Click on the `Configure application` As seen below:

![configure application button](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/screen-shot-2021-08-24-at-20.43.18.png "configure application button")

This will redirect you to the settings page for your application. In the second half of the page, you can link your application to Vonage provisioned phone numbers. Click on the `Buy numbers` button and you will be directed to a page where you can choose a country, features, type, and four digits you would like the number to have.

![buy numbers menu](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/ivr-screenshot-2.png "buy numbers menu")

For our purposes: pick the country that you are currently in so that the call will be a local call for you; pick `Voice` for features and either mobile or landline for type. You do not need to enter anything for the `Number` text field. When you click `Search`, you will see a list of phone numbers available.

Pick one by clicking the `Buy` button, and click the black `Buy` button once more in the confirmation prompt.

Once you own the number, you can now link it to your `vonage-rails-ivr-demo` Voice application. To do so, click on the `Your applications` option from the left-hand panel. Navigate back to your application page. Now you will see your newly purchased phone number listed in the second half of the page, as seen below:

![link numbers menu](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/screen-shot-2021-08-24-at-20.52.35.png "link numbers menu")

Simply click the white `link` button. The button will turn red and change to `unlink.` Your Vonage phone number is now linked to your application.
Our last step is to configure the Vonage application to accept phone calls and send them to the IVR Rails app. Click the `edit` button in the top section, under your application's name. You will be redirected to a page called `Edit vonage-rails-ivr-demo.` Scroll until you find the following Capabilities section:

![Voice API Capabilities Form](/content/blog/how-to-build-a-simple-ivr-with-ruby-on-rails/ivr-screenshot-1.png "Voice API Capabilities Form")

Complete the form with the following:

* `Answer URL` text field enter your ngrok URL again: `https://[ngrok url here]/answer`
* `Event URL` text field enter your ngrok URL: `https://[ngrok url here]/event`

Scroll to the bottom of the page and click the `save-changes` button.

With that last step, you have finished! You now have a fully functional simple IVR Rails application powered by Vonage. You can give it a go by starting your Rails server, and with ngrok also running, give your application a call at the phone number you just purchased.

## Further Reading

To continue learning about what we discussed consider exploring the following:

* [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference)
* [Voice API Overview](https://developer.nexmo.com/voice/voice-api/overview)
* [Voice API Reference Guide](https://developer.nexmo.com/voice/voice-api/api-reference)
* [Building a Twitter IVR with the Nexmo Voice API](https://www.nexmo.com/blog/2018/06/26/twitter-interactive-voice-response-dr/)