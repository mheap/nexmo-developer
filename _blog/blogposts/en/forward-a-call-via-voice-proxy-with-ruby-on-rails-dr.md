---
title: Forward a Call via Voice Proxy with Ruby on Rails
description: In this tutorial you'll see how to build a voice proxy for
  forwarding voice calls using the Nexmo Voice API and Ruby on Rails.
thumbnail: /content/blog/forward-a-call-via-voice-proxy-with-ruby-on-rails-dr/voice-proxy-ruby.png
author: ben-greenberg
published: true
published_at: 2019-04-16T09:58:17.000Z
updated_at: 2021-05-13T18:19:18.733Z
category: tutorial
tags:
  - voice-api
  - ruby
comments: true
redirect: ""
canonical: ""
---
We may conduct a lot of our daily lives with apps, but nonetheless, making phone calls is still a necessary part of our world. Every time we do business over a phone call we expose our private phone number to others. This can pose both privacy and security risks for all parties involved. However, with utilizing a voice proxy, you can alleviate this issue and make phone calls with confidence.

A voice proxy is a method by which phone calls are routed to their final destination through an intermediary phone number. The final phone number is masked behind the intermediary number, thereby maintaining its privacy. In this tutorial, we are going to walk through creating a Ruby on Rails application to forward voice calls via a voice proxy using the Nexmo Voice API. 

## Prerequisites

<sign-up number></sign-up>

To work through this tutorial, you will need a [Nexmo account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav). Sign up now if you don't already have an account.

In addition, you will also need:

* [Ruby on Rails](https://rubyonrails.org/)
* [ngrok](https://ngrok.io) to expose our Rails application to the outside

## Forward a Voice Call via Voice Proxy with Rails

We are going to accomplish the following tasks to forward a voice call with the Nexmo Voice API via voice proxy:

1. Create a Rails application
2. Expose our application externally so Nexmo can communicate with it
3. Set up our Nexmo account, purchase a Nexmo phone number and create a Nexmo Voice application
4. Create the Rails Controller, View and Routes

### Create a Rails Application

From the command line execute the following:

```bash
$ rails new forward-voice-proxy --database=postgresql
```

The above command will create a new Rails application with PostgreSQL as its default database. Open up the new Rails application in your code editor of choice and add the `dotenv-rails` and `nexmo` gems to your `Gemfile` in the root directory of the project:

```ruby
# Gemfile

gem 'nexmo'
gem 'dotenv-rails`
```

We are now ready to install our gem dependencies into our application. We do so by running `bundle install` from the terminal. We can also run `rake db:migrate` at this point from the terminal as well to set up the database. We won't be using the database in this tutorial to persist the data, but you could add that feature to your own application, if you prefer.

At this point, we will set up ngrok in order to obtain our externally accessible URL, which will be used by Nexmo to communicate with our application.

### Exposing the Application

There are several ways to make our local development server externally accessible, but one of the simplest ways is with ngrok. You can read [this article](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) for a more detailed explanation of how ngrok works. However, for our purposes, we just need to get it running and copy the URL that it provides us.

In order to start ngrok, open up a new terminal window and execute the following from the command line:

```bash
$ ngrok http 3000
```

You will now see an ngrok logging interface in your terminal window. Near the top of the interface is a line that begins with `Forwarding` and contains two URLs. The first is the externally accessible ngrok URL, which ends with `ngrok.io` followed by `http://localhost:3000`, that being your local development server. Now, when you or Nexmo contacts the `ngrok.io` URL, it will forward it to your local server.

Make sure to copy the `ngrok.io` URL down somewhere safe. We will be using it in our next step of setting up our Nexmo account, phone number and Voice application.

### Create a Nexmo Account with Phone Number and Voice Application

In order for our voice application to work, we need a Nexmo account, a Nexmo provisioned phone number, a Nexmo application, and, lastly, we need to link our application to our phone number.

You can create a Nexmo account for free, and as an added bonus, your account will be credited with 2 euros to begin using your new application. Navigate to <https://dashboard.nexmo.com/sign-up> in your web browser and go through the sign up steps. Once you have finished you will be in your Nexmo dashboard.

From the left-hand menu, click on the `Voice menu` item. You will see the following four options under `APPLICATIONS`:

<img src="https://www.nexmo.com/wp-content/uploads/2019/04/voice-menu-options.png" alt="Voice Menu Options" width="510" height="426" class="aligncenter size-full wp-image-28974" />

Click on the `Create an application` option and you will be directed to a page where you can set up a new Nexmo application.

Complete the form with the following:

* `Application name` text field enter `voice-proxy-forwarding-demo`
* `Event URL` text field enter your ngrok URL: `https://[ngrok url here]/event`
* `Answer URL` text field enter your ngrok URL again: `https://[ngrok url here]/webhooks/answer`

Once you have finished, go ahead and click the blue `Create Application` button.

You now have created a Nexmo Voice application. Our next step is to purchase a Nexmo phone number and link it to this application.

From the Nexmo Dashboard, click on the `Numbers` menu item on the left-hand menu. You will see three options appear:

![Numbers menu](/content/blog/forward-a-call-via-voice-proxy-with-ruby-on-rails/numbers-menu-options.png)

Click on the `Buy numbers` option and you will be directed to a page where you can choose a country, features, type, and four digits you would like the number to have.

![Buy numbers](/content/blog/forward-a-call-via-voice-proxy-with-ruby-on-rails/buy-numbers-menu.png)

For our purposes: pick the country that you are currently in, so that the call will be a local call for you; pick `Voice` for features and either mobile or land line for type. You do not need to enter anything for the `Number` text field. When you click `Search`, you will see a list of phone numbers available.

Pick one by clicking the orange `Buy` button, and clicking the orange `Buy` button once more in the confirmation prompt.

Once you own the number, you can now link it to your `voice-proxy-forwarding-demo` Voice application. To do so, click on the gear icon next to the phone number and you will see the following menu:

![Edit numbers](/content/blog/forward-a-call-via-voice-proxy-with-ruby-on-rails/edit-number-menu.png)

Select the `voice-proxy-forwarding-demo` Application from the drop down list and click on the blue `Ok` button. Your Nexmo phone number is now linked to your Voice application and ready to accept and forward inbound phone calls via voice proxy.

Our last step before we are ready to run our application is to define our Rails Controller actions and Routes.

### Create Rails Controller and Routes

Go ahead and create a Controller file called `call_controller.rb` in `/app/controllers/`. Inside the Controller we are going to define a single Controller action and three constant variables. The action will contain the [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) instructions to forward the phone call via voice proxy to our personal number. The three constant variables will hold our ngrok URL, Nexmo number and personal number, respectively.

```ruby
# call_controller.rb

class CallController < ApplicationController
    BASE_URL = 'YOUR NGROK URL GOES HERE'
    NEXMO_NUMBER='YOUR NEXMO PROVISIONED NUMBER GOES HERE'
    PERSONAL_NUMBER = 'YOUR PERSONAL NUMBER GOES HERE'

    def answer
        render json:
        [
            {
                "action": "talk",
                "text": "Please wait while we forward your call"
              },
            {
                :action => 'connect',
                :eventUrl => [],
                :from => NEXMO_NUMBER,
                :endpoint => [
                    {  
                        :type => 'phone',
                        :number => PERSONAL_NUMBER
                    }
                ]
            }
        ]
    end
end
```

Lastly, we need to define the route in `routes.rb` so our Rails application knows where to direct the Nexmo `GET` request to. Go ahead and open up `/config/routes.rb` and add the following:

```ruby
# routes.rb

get '/webhooks/answer', to: 'call#answer'
```

You will notice that the path for the `GET` request is the same URL we provided when we set up our Nexmo Voice application in the Nexmo Dashboard.

Our application is ready to run! Congratulations!

### Running the Application

To run your application all you need to do is from the command line execute the following:

```bash
$ rails s
```

This will initiate your Rails server. In another terminal window, make sure that ngrok is also running. Now, call your Nexmo phone number and you will hear your application say to you: "Please wait while we forward your call," and then your call you will be forwarded via voice proxy. 

What if you want your application to forward your call without announcing it is doing so? All you need to do is remove the `talk` NCCO instruction from the `#answer` route in the Controller. When you do so your final Controller method will look like the following:

```ruby
# call_controller.rb

def answer
    render json:
    [
        {
            :action => 'connect',
            :eventUrl => [],
            :from => NEXMO_NUMBER,
            :endpoint => [
                {  
                    :type => 'phone',
                    :number => PERSONAL_NUMBER
                }
            ]
        }
    ]
end
```

## Further Reading

If you are interested in exploring and reading more, consider the following:

* [Nexmo Call Control Object Reference Guide](https://developer.nexmo.com/voice/voice-api/ncco-reference)
* [Nexmo Voice API Overview](https://developer.nexmo.com/voice/voice-api/overview)
* [How to Handle Inbound Phone Calls with Ruby on Rails](https://www.nexmo.com/blog/2017/12/21/handle-inbound-phone-calls-ruby-rails-dr/)