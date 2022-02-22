---
title: Build a Voicemail with Ruby on Rails
description: Create your own voicemail application powered by Ruby on Rails and
  the Nexmo Voice API with this step-by-step tutorial. Get started today!
thumbnail: /content/blog/build-a-voicemail-with-ruby-on-rails-dr/ruby-voicemail.png
author: ben-greenberg
published: true
published_at: 2019-06-17T08:00:00.000Z
updated_at: 2021-05-13T22:21:35.368Z
category: tutorial
tags:
  - ruby-on-rails
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Have you ever wanted to be able to provide customers with a phone number they can call and just leave you a message? You can create your own voicemail application powered by the Nexmo Voice API and Ruby on Rails. In this tutorial we will walk through the steps to get up and running. Your application will be able to receive phone calls, record voicemail messages and have a web interface to display all messages and play them.

If you prefer, you can also clone a complete working copy of this application on [GutHub](https://github.com/Nexmo/nexmo-rails-voicemail-demo)

Let's get started!

## Prerequisites

<sign-up number></sign-up>

In order to work through this tutorial you will need the following:

* Rails 5.2+
* ngrok

## Create a Voicemail Application

We are going to walk through the following steps:

1. Create a New Rails application
2. Set Up a Nexmo account
3. Set Up ngrok
4. Set Up Our Rails App

Once we have finished all of the above steps we will be ready to call our new application, leave a message and then play it from our web interface.

### Create a New Rails Application

From your command line execute the following:

```bash
$ rails new nexmo-rails-voicemail-demo --database=postgresql
```

Once it is finished you will now have a brand new Rails application called `nexmo-rails-voicemail-demo` with PostgreSQL defined as its database. At this point you will also want to create the development database in PostgreSQL. You can do that by running the following:

```bash
$ createdb nexmo-rails-voicemail-demo_development
```

Now that the database is created we can create our table which will store the information for each voicemail recording. We want a table that will hold the unique identifiers for the `Conversation`, the recording and the sender's phone number. We will define what a `Conversation` is and how to use it when we discuss creating the Controller. The following command will create our table:

```bash
$ rails generate migration CreateRecordings conversation_uuid:string recording_uuid:string from:numeric
```

You can inspect the migration file the generator created by opening up the application in your preferred code editor and viewing the file in the `/db/migrate` folder. It will be named `create_recordings.rb` preceded by a timestamp of when you executed the above command. The file should look something like this:

```ruby
class CreateRecordings < ActiveRecord::Migration[5.2]
  def change
    create_table :recordings do |t|
      t.string :conversation_uuid
      t.string :recording_uuid
      t.numeric :from

      t.timestamps
    end
  end
end
```

If the migration file looks good then you can go ahead and execute the migration by running `rake db:migrate` from your command line. 

The last step for now in setting up our Rails application is installing our dependencies. Open up the `Gemfile` in the root folder of the application and add the following:

```ruby
# Gemfile

gem 'nexmo_rails'
gem 'dotenv-rails'
```

Once the file is saved go ahead and run `bundle install` from your terminal. You will have installed the `nexmo_rails` initializer gem into your application, which enables us to instantiate a credentialed Nexmo client. We are going to hold off on running the Nexmo initializer for now since we first need to create our Nexmo account and receive our API credentials. You also installed the `dotenv-rails` gem that will assist us when we add our Nexmo API credentials as environment variables.

We are now ready to move on to the next step and set up our Nexmo account.

### Set Up ngrok

There are several ways to make our local development server externally accessible, but one of the simplest ways is with ngrok. You can read [this article](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) for a more detailed explanation of how ngrok works. However, for our purposes, we just need to get it running and copy the URL that it provides us.

In order to start ngrok, open up a new terminal window and execute the following from the command line:

```bash
$ ngrok http 3000
```

You will now see an ngrok logging interface in your terminal window. Near the top of the interface is a line that begins with `Forwarding` and contains two URLs. The first is the externally accessible ngrok URL, which ends with `ngrok.io` followed by `http://localhost:3000`, that being your local development server. Now, when you or Nexmo contacts the `ngrok.io` URL, it will forward it to your local server.

Make sure to copy the `ngrok.io` URL down somewhere safe. We will be using it in our next step of setting up our Nexmo account, phone number and Voice application.

### Set Up a Nexmo Account

In order for our voice application to work, we need a Nexmo account, a Nexmo provisioned phone number, a Nexmo application, and, lastly, we need to link our application to our phone number.

You can create a Nexmo account for free, and as an added bonus, your account will be credited with 2 euros to begin using your new application. Visit the [Vonage API Developer Dashboard](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) and follow the sign-up steps if you do not already have a Vonage API Developer account. Once you complete sign-up, you will see your Vonage API Developer Dashboard.

From the left-hand menu, click on the `Voice menu` item. You will see the following four options under `APPLICATIONS`:

![Create voice app](/content/blog/build-a-voicemail-with-ruby-on-rails/create-voice-app.png)

Click on the `Create an application` option and you will be directed to a page where you can set up a new Nexmo application.

Complete the form with the following:

* `Application name` text field enter `nexmo-rails-voicemail-demo`
* `Event URL` text field enter your ngrok URL: `https://[ngrok url here]/event`
* `Answer URL` text field enter your ngrok URL again: `https://[ngrok url here]/webhooks/answer`

Once you have finished, go ahead and click the blue `Create Application` button.

After the application has been created you can generate a public/private key pair. You will need these keys when accessing the voicemail recordings from the API. Click on `generate public/private key pair` and move the automatically downloaded `private.key` file to the root folder of our application. 

If you have not done so already now would be a good time to create a `.gitignore` file in the top level of your application and add `./private.key` to it so as not to commit your private key to version control.

You now have created a Nexmo Voice application. Our next step is to purchase a Nexmo phone number and link it to this application.

From the Nexmo Dashboard, click on the `Numbers` menu item on the left-hand menu. You will see three options appear:

![buy numers](/content/blog/build-a-voicemail-with-ruby-on-rails/numbers.png)

Click on the `Buy numbers` option and you will be directed to a page where you can choose a country, features, type, and four digits you would like the number to have.

![numbers](/content/blog/build-a-voicemail-with-ruby-on-rails/buy-numbers.png)

For our purposes: pick the country that you are currently in, so that the call will be a local call for you; pick `Voice` for features and either mobile or land line for type. You do not need to enter anything for the `Number` text field. When you click `Search`, you will see a list of phone numbers available.

Pick one by clicking the orange `Buy` button, and clicking the orange `Buy` button once more in the confirmation prompt.

Once you own the number, you can now link it to your `nexmo-rails-voicemail-demo` Voice application. To do so, click on the gear icon next to the phone number and you will see the following menu:

![webhook dashboard](/content/blog/build-a-voicemail-with-ruby-on-rails/screen-shot-2019-06-14-at-15.12.52.png)

Select the `nexmo-rails-voicemail-demo` Application from the drop down list and click on the blue `Ok` button. Your Nexmo phone number is now linked to your Voice application and ready to accept and forward inbound phone calls via voice proxy.

Our last step before we are ready to run our application is to define our Rails Controller, View, Model and Routes.

### Set Up Our Rails App

Before we begin to write the code for our model, view and controller let's take a moment to walk through what we want the application to do. There are two different aspects to our application:

* Receive a phone call and record a message
* Display and make accessible the recordings on a webpage

In order to accomplish the first task of receiving a call and recording a message we need to have a webhook route that can accept the request from the Nexmo Voice API upon answering a call and send back instructions to the API. We then need a separate route that can accept the status updates for the call.

The second task for our application necessitates a route that can accept a `GET` request to list all the recordings. Furthermore, since we need to list all the recordings, we will then need to save each recording into the database we created earlier. We will also want to save each recording itself to be able to make it easy to play back to the listener.

Now that we have a path forward conceptually of what we are working towards, let's start building it.

#### Define Our Routes

Open up the `/config/routes.rb` file in your code editor and add the following routes:

```ruby
# routes.rb

get '/', to: 'voicemail#index'
get '/answer', to: 'voicemail#answer'
post '/event', to: 'voicemail#event'
post '/recording', to: 'voicemail#new'
```

We have created four separate routes that will direct all the traffic to our application to the appropriate methods in our soon to be created voicemail controller. We created two `GET` request routes; one to handle the top-level request to list all recordings and one to receive the initial API request from Nexmo when a phone call is answered. We also created two `POST` requests; one to receive status updates from Nexmo about the call, and one to save the recording when the call is finished.

#### Define Our Controller Actions

The routes we created referenced a controller that we have not created yet, so let's go ahead and do that now. From the command line execute the following:

```bash
$ rails generate controller Voicemail
```

This will create a file in `/app/controllers` called `voicemail_controller.rb`. We need to create an action for each of the routes. These actions will contain the logic behind the route and direct the traffic to the appropriate view, when appropriate. The actions are the following:

* `#index`: Contains an instance variable called `@recordings` that contains all the voicemail records. 
* `#answer`: Renders a Nexmo Call Control Object (NCCO) \[JSON object containing the instructions for the Nexmo API] to the Nexmo API. 
* `#event`: Receives updates from the Nexmo API. When the application receives a status of `answered`, the method creates a new entry in the `Recordings` table. 
* `#new`: Accessed by the API when a recording has been made and updates a recording entry with the `recording_uuid`, the unique ID for the recording audio.

Lastly, before defining any methods, we create two constant variables: `NEXMO_NUMBER` and `EXTERNAL_URL`, to contain our Nexmo phone number we provisioned and the URL for our externally accessible ngrok URL, respectively. Make sure to define those in your controller with your information.

This is what our controller will look like when it is finished:

```ruby
# voicemail_controller.rb

class VoicemailController < ApplicationController
    skip_before_action :verify_authenticity_token

    NEXMO_NUMBER = YOUR PHONE NUMBER GOES HERE
    EXTERNAL_URL = 'YOUR NGROK URL GOES HERE'
    
    def index
        @recordings = Recording.all
    end

    def answer
        render json:
        [
            {
                :action => 'talk',
                :text => 'Leave your message after the beep.'
            },
            {
                :action => 'record',
                :beepStart => true,
                :eventUrl => [ "#{EXTERNAL_URL}/recording" ],
                :endOnSilence => 3
            }
        ]
    end

    def event
        if params['status'] == 'answered'
            Recording.create(conversation_uuid: params['conversation_uuid'], from: params['from'])
        end
    end

    def new
        if params['recording_url']
            recording = Recording.find_by(uuid: params['conversation_uuid'])
            recording.recording_uuid = params['recording_uuid']
            recording.save
            Nexmo.files.save(params['recording_url'], "public/voicemail/#{params['recording_uuid']}.wav")
        end
    end
end
```

#### Define Our Model

In our app we only need to create one model that we will use to interact with our `Recordings` table in the database. Go ahead and create a file called `recording.rb` in `/app/models/` and all you need to do inside of it is simply define that it is a model that inherits from `ActiveRecord::Base`:

```ruby
# recording.rb

class Recording < ActiveRecord::Base
end
```

Now that we have our Routes, our Controller and our Model defined, the next item we need to create is an `#index` view. Let's go ahead and do that now.

#### Create Our View

We need to create one view for our application, which will be where all the voicemail recordings will be displayed. The user can click on any one of them to play the recording. We need to create an `index.html.erb` file in `/app/views/voicemail`. Within that file we want to take advantage of the `@recordings` instance variable we created in the voicemail Controller `#index` action that contains all the entries in the `Recordings` table. We will iterate over that data and create an HTML table to list all the recordings. Our final view will have the following code:

```html
# index.html.erb

<h1>Your Voicemail</h1>

<strong>You have <%= Dir["public/voicemail/*"].length %> messages</strong>

<br /><br />

<table>
    <tr>
        <th>From</th>
        <th>Timestamp</th>
        <th>Conversation UUID</th>
        <th>Recording</th>
    </tr>
    <% @recordings.each do |r| %>
        <tr>
            <td><%= r.from %></td>
            <td><%= r.created_at %></td>
            <td><%= r.conversation_uuid %></td>
            <td><a href="/voicemail/<%= r.recording_uuid %>.wav">Click here to listen</a></td>
        </tr>
    <% end %>
</table>
```

The one additional item we added to the view, in addition to the HTML table, is a count of the number of voicemail recordings. We utilize the `#length` method in Ruby to count the number of files in the voicemail recordings local folder and display that number.

With the creation of the view, our app is now almost ready. The last item we need to do is add our Nexmo API credentials as environment variables and initialize our Nexmo client using the Nexmo Rails initializer.

#### Adding Nexmo Credentials and Initializing a Nexmo Client

Earlier in this tutorial, we installed the `dotenv-rails` and `nexmo_rails` gems as dependencies. The former helps us manage using environment variables in our application, while the latter contains a Rails generator to intialize a Nexmo credentialed client.

The first thing we want to do to add our Nexmo credentials is open up, or create the file if it does not exist yet, `.env` in the root folder of our project. Within the `.env` file we are going to add our credentials for our Nexmo API key, secret, private key file path and application ID. It will look like the following, replacing the values with your unique credentials that you obtained from the Nexmo dashboard:

```
# .env

NEXMO_API_KEY=your api key
NEXMO_API_SECRET=your api secret
NEXMO_APPLICATION_ID=your application id
NEXMO_PRIVATE_KEY=./private.key
```

Now that our credentials are added as environemnt variables, we are ready to run the generator. From the command line execute the following:

```bash
$ rails generate nexmo_initializer
```

That's it! You now have a fully functioning application. 

Start your Rails server, and making sure ngrok is running, go ahead and give it a call and leave yourself a message!