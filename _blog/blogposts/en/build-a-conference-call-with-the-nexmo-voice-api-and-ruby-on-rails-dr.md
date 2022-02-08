---
title: Build a Conference Call with the Nexmo Voice API and Ruby on Rails
description: Get started with creating a fully featured conference call with the
  Nexmo Voice API and Ruby on Rails with this tutorial.
thumbnail: /content/blog/build-a-conference-call-with-the-nexmo-voice-api-and-ruby-on-rails-dr/ruby-conference-call-1.png
author: ben-greenberg
published: true
published_at: 2019-05-10T07:30:09.000Z
updated_at: 2021-05-14T15:39:57.258Z
category: tutorial
tags:
  - ruby
  - ruby-on-rails
  - voice-api
comments: true
redirect: ""
canonical: ""
---
In this walkthrough, we are going to create a Ruby on Rails conference call application that utilizes the Nexmo Voice API. Within the Nexmo documentation, a conference call is also referred to as a *conversation*, and we will be using these terms interchangeably. 

You can find the full working code for this sample on [GitHub](https://github.com/nexmo-community/nexmo-rails-conference-call).

## Prerequisites

* [Ruby on Rails](https://rubyonrails.org/)
* [ngrok](https://ngrok.io) to expose our Rails application to the outside

## Create a Conference Call with Ruby on Rails

We are going to accomplish the following tasks to create a conference call ("conversation") with the Nexmo Voice API:

1. Create a Rails application
2. Expose our application externally so Nexmo can communicate with it
3. Set up our Nexmo account, purchase a Nexmo phone number, and create a Nexmo Voice application
4. Create the Rails Controller and Routes

### Create a Rails Application

From the command line execute the following:

```bash
$ rails new rails-conference-call --database=postgresql
```

The above command will create a new Rails application with PostgreSQL as its default database. 

Next let's install our gem dependencies into our application. We do so by running `bundle install` from the terminal. We can also run `rake db:migrate` at this point from the terminal as well to set up the database. We won't be using the database in this tutorial to persist the data, but you could add that feature to your own application, if you prefer.

At this point, we will set up ngrok in order to obtain our externally accessible URL, which will be used by Nexmo to communicate with our application.

### Exposing the Application

There are several ways to make our local development server externally accessible, but one of the simplest ways is with ngrok. You can read [this article](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) for a more detailed explanation of how ngrok works. However, for our purposes, we just need to get it running and copy the URL that it provides us.

In order to start ngrok, open up a new terminal window and execute the following from the command line:

```bash
$ ngrok http 3000
```

You will now see an ngrok logging interface in your terminal window. Near the top of the interface is a line that begins with `Forwarding` and contains two URLs. The first is the externally accessible ngrok URL, which ends with `ngrok.io` followed by `http://localhost:3000`, that being your local development server. Now, when you or Nexmo contacts the `ngrok.io` URL, it will forward it to your local server.

Make sure to copy the `ngrok.io` URL down somewhere safe. We will be using it in our next step of setting up our Nexmo account, phone number, and Voice application.

### Create a Nexmo Account with Phone Number and Voice Application

<sign-up number></sign-up>

In order for our voice application to work, we need a Nexmo account, a Nexmo provisioned phone number, a Nexmo application, and, lastly, we need to link our application to our phone number.

From the left-hand menu, click on the `Voice menu` item. You will see the following four options under `APPLICATIONS`:

![Voice menu options](/content/blog/build-a-conference-call-with-the-nexmo-voice-api-and-ruby-on-rails/voice-menu-options.png)

Click on the `Create an application` option and you will be directed to a page where you can set up a new Nexmo application.

Complete the form with the following:

* `Application name` text field enter `conference-call-demo`
* `Event URL` text field enter your ngrok URL: `https://[ngrok url here]/event`
* `Answer URL` text field enter your ngrok URL again: `https://[ngrok url here]/webhooks/answer`

Once you have finished, go ahead and click the blue `Create Application` button.

You now have created a Nexmo Voice application. Our next step is to purchase a Nexmo phone number and link it to this application.

From the Nexmo Dashboard, click on the `Numbers` menu item on the left-hand menu. You will see three options appear:

![Number menu options](/content/blog/build-a-conference-call-with-the-nexmo-voice-api-and-ruby-on-rails/numbers-menu-options.png)

Click on the `Buy numbers` option and you will be directed to a page where you can choose a country, features, type, and four digits you would like the number to have.

![buy numbers](/content/blog/build-a-conference-call-with-the-nexmo-voice-api-and-ruby-on-rails/buy-numbers-menu.png)

For our purposes: pick the country that you are currently in, so that the call will be a local call for you; pick `Voice` for features and either mobile or land line for type. You do not need to enter anything for the `Number` text field. When you click `Search`, you will see a list of phone numbers available.

Pick one by clicking the orange `Buy` button, and clicking the orange `Buy` button once more in the confirmation prompt.

Once you own the number, you can now link it to your `conference-call-demo` Voice application. To do so, click on the gear icon next to the phone number and you will see the following menu:

![conference call](/content/blog/build-a-conference-call-with-the-nexmo-voice-api-and-ruby-on-rails/edit-numbers-conference-call.png)

Select the `conference-call-demo` Application from the drop down list and click on the blue `Ok` button. Your Nexmo phone number is now linked to your Voice application and ready to accept and forward inbound phone calls via voice proxy.

Our last step before we are ready to run our application is to define our Rails Controller actions and Routes.

### Create Rails Controller and Routes

Go ahead and create a Controller file called `conference_controller.rb` in `/app/controllers/`. Inside the Controller we are going to define a single Controller action. The action will contain the [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) instructions to create the conference call.

```ruby
# conference_controller.rb

class ConferenceController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def answer
        render json:
            [
                {
                    :action => 'talk',
                    :text => 'Welcome to the Nexmo powered conference call'
                },
                {
                    :action => 'conversation',
                    :name => 'nexmo-conversation'
                }
            ].to_json
    end

    def event
    end
end
```

The NCCO instruction defined in the above `#answer` method contains two actions:

1. Welcome the caller with a `talk` action
2. Put the caller in the conference call, also referred to as a `conversation`. 

The name of the `conversation` in the second action of the NCCO is defined at this point. It can be called anything, and once it is defined initially, all subsequent callers can be directed into it. Additionally, all other [NCCO `conversation` options](https://developer.nexmo.com/voice/voice-api/ncco-reference#conversation) can be defined for this conference call by referencing the `conversation` name.

Lastly, we need to define the routes in `routes.rb` so our Rails application knows where to direct the Nexmo `GET` request to and where to `POST` the status updates our application receives from the Nexmo API. Go ahead and open up `/config/routes.rb` and add the following:

```ruby
# routes.rb

get '/webhooks/answer', to: 'conference#answer'
post '/event', to: 'conference#event'
```

You will notice that the paths for the `GET` and `POST` requests are the same URLs we provided when we set up our Nexmo Voice application in the Nexmo Dashboard.

Our application is ready to run! Congratulations!

### Running the Application

To run your application all you need to do is from the command line execute the following:

```bash
$ rails s
```

This will initiate your Rails server. In another terminal window, make sure that ngrok is also running. Now, call your Nexmo phone number and you will hear your application say to you: "Welcome to the Nexmo powered conference call". You can invite others to join you in your conference call by providing them with the phone number.

## Further Reading

If you are interested in exploring and reading more, consider the following:

* [Nexmo Call Control Object Reference Guide](https://developer.nexmo.com/voice/voice-api/ncco-reference)
* [Nexmo Voice API Overview](https://developer.nexmo.com/voice/voice-api/overview)
* [Connect Callers Into a Conference](https://developer.nexmo.com/voice/voice-api/code-snippets/connect-callers-into-a-conference)
* [Record a Conversation](https://developer.nexmo.com/voice/voice-api/code-snippets/record-a-conversation)