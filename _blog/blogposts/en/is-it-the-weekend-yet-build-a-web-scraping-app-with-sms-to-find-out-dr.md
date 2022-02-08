---
title: Scrape the Web for Updates and Send SMS Alerts with Ruby
description: Follow this tutorial to create a Ruby on Rails application that
  scrapes the web and delivers updates via SMS to the subscribed recipients
thumbnail: /content/blog/is-it-the-weekend-yet-build-a-web-scraping-app-with-sms-to-find-out-dr/Dev_Web-Scraping-App_1200x600.png
author: ben-greenberg
published: true
published_at: 2020-03-27T17:55:30.000Z
updated_at: 2021-05-18T13:07:32.361Z
category: tutorial
tags:
  - sms-api
  - ruby-on-rails
  - ruby
comments: true
redirect: ""
canonical: ""
---
We have all been there. You wake up and it is a new day, and you just need to know the answer to the most burning question. Is it the weekend yet? Your week has been so busy with professional and personal responsibilities. All you want to do is take a couple of days to sit back and relax. 

To answer the question you could, of course, open up your calendar app on your phone or ask your favorite personal digital home assistant. But, why do those things when you could build yourself an app that sends you a text message instead?

We are going to create a Ruby on Rails application that does the following:

* Allows for both new subscribers and for the ability to unsubscribe from the list
* Scrapes the answer to our question from [isittheweekend.com](http://isittheweekend.com)
* Sends the answer from our scraped data daily to all the subscribed recipients

To wrap it all together, we will also be creating a Rake task that will run all these tasks at once, and designating its execution once every 24 hours.

If you prefer, you can also find a fully working version of this application on [GitHub](https://github.com/nexmo-community/ruby-sms-weekend-checker).

Let's get started!

## Prerequisites

* [Ruby on Rails](https://rubyonrails.org/)
* [ngrok](https://ngrok.io)

<sign-up number></sign-up>

## Generate the Rails Application

The first thing we need to do is to create our new Rails application. From your command line execute the following:

```bash
$ rails new weekend-checker-app --database=postgresql
```

This creates the necessary file structure for our Rails application and sets the default database to PostgreSQL.

Once that is done, `cd` into the directory that was created. Before we install our dependencies, we will add the additional gems our application will use.

Open up the code in your preferred code editor and navigate to the `Gemfile`. Inside the `Gemfile` add the following gems:

```ruby
gem 'nexmo'
gem 'watir'
gem 'webdrivers', '~> 4.0'
gem 'whenever', require: false
gem 'dotenv-rails'
```

We are using the `nexmo` gem to send the SMS updates, the `watir` and `webdrivers` gems to make the HTTP request to a site with dynamic JavaScript content, the `whenever` gem to schedule the Rake task, and the `dotenv-rails` gem to manage the environment variables.

After you have saved the `Gemfile`, you are ready to run `bundle install` from the command line.

The next step is creating our database schema and models.

## Create the Database Schema and Models

Now that our Rails application is created and has its dependencies installed, the next task is to create the correct database schema to house the data we will need to operate our application. We need to store the following types of information:

* Recipients: *The list of subscribers with their phone numbers*
* DiffStorage: *Copies of the website data to compare against to determine if there was a change*

We will use the Rails generator tool to create the migration files and then subsequently edit each one.

```bash
$ rails generate model Recipient number:string subscribed:boolean
$ rails generate model DiffStorage website_data:text
```

Those commands will create both model files in `app/models` and migration files in `db/migrate`. Before committing those changes to your application, once the generator actions are done, inspect the files created in both directories to make sure they are correct. 

Specifically, in the migration files, you want to ensure that each migration includes `t.timestamps`, which adds a `created_at` and `updated_at` column to the table. You should also see the `number` and `subscribed` columns in the `Recipient` migration file, with types set to `string` and `boolean`, respectively. Similarly, you should see a column in the `DiffStorage` migration file for `website_data` with the type set to `text`.

The model files inside `app/models` should be empty besides the class declarations and their inheritance from `ApplicationRecord`.

When it looks satisfactory, it is time to run `rake db:migrate` from the command line. The command will output the results to your console, and if you inspect the `db/schema.rb` file you will be able to see the schema you created initialized inside the application.

Lastly, we also need to create `Messenger` and `Scraper` models, but we do not need a migration for them. To do so, we run the Rails generator again and append a `--migration=false` flag to it:

```bash
$ rails generate model Messenger --migration=false
$ rails generate model Scraper --migration=false
```

Now has come the time to define the logic inside the models.

## Defining the Models

As mentioned above, we have four models that are responsible for unique areas of the application:

* `DiffStorage`: *Checks for any differences in the website data*
* `Recipient`: *Manages adding and removing subscribers*
* `Messenger`: *Manages the sending of SMS messages*
* `Scraper`: *Responsible for scraping the website for data*

### Defining the DiffStorage Model

The `DiffStorage` model will contain two class models. One will contain the URL that we are scraping. The second will check for any changes since the last time the website was scraped and invoke the next steps in the application when the conditions are met.

First, let's define the URL in its own method so that we create a single place where it exists and can be easily modified if we choose to do so later:

```ruby
def self.url
  'http://isittheweekend.com'
end
```

Next, the bulk of this model will live inside the `#check_last_record` class method:

```ruby
def self.check_last_record
  today_answer = Scraper.call(self.url)
  if DiffStorage.any?
    yesterday_answer = DiffStorage.last
  else
    yesterday_answer = ''
  end
  Messenger.send_update_message(Recipient.all, yesterday_answer, today_answer)
end
```

The above method first calls the method in the `Scraper` class that will begin the website scraping to obtain the most recent snapshot and assigns that data to `today_answer`. It then wraps the next step inside an `if` statement asking if there are any records in `DiffStorage`. If there are previous records stored there, then the method grabs the most recent one and assigns it to `yesterday_answer`. If there were no previous records then an empty string is assigned to `yesterday_answer`. Lastly, it sends the recipients and the two variables to the `Messenger` model to process for sending the message.

### Defining the Scraper Model

The `Scraper` model will be responsible for doing the work of gathering the data from [isittheweekend.com](http://isittheweekend.com) to determine if it is indeed the weekend or not. The model will have four class methods and we will define each one here:

```ruby
require 'nokogiri'
require 'webdrivers/chromedriver'
require 'watir'

class Scraper < ApplicationRecord
  def self.call(url)
    self.get_url(url)
  end

  def self.get_url(url)
    doc = HTTParty.get(url)
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto(url)
    parsed_page ||= Nokogiri::HTML.parse(browser.html)
    answer = parsed_page.css('h1#isit').text
    self.check_text(answer)
  end

  def self.check_text(data)
    if data == '' || data == nil
      puts "There was no text received from the web scrape."
      exit
    else
      puts "There was data in the text received from the web scrape."
      self.store_text(data)
    end
  end

  def self.store_text(text)
    record = DiffStorage.new
    record.website_data = text
    if record.save
      puts "Record Updated Successfully"
    end
    return record
  end
end
```

Each action within the act of scraping is defined into its own small method so as to keep our concerns separated. The `#call` method is the point of entry for the class. This is what gets invoked by other methods outside of itself. The `#get_url` method makes the HTTP request by simulating a Chome browser request using the `Watir` library and parses it with `Nokogiri`. The `#check_text` method checks if any data was obtained. The `#store_text` method saves that data to the database.

### Defining the Messenger Model

Within the `Messenger` model will be all the code responsible for sending the daily SMS update to the subscribers. We will create a method that will send the message, a method that composes the weekend response text, a method that puts the whole message together, and a method that manages a confirmation message if a subscriber sends a removal request.

First, the method to send the update message:

```ruby
def self.send_update_message(recipients, yesterday, today)
  @client = Nexmo::Client.new(
    api_key: ENV['NEXMO_API_KEY'],
    api_secret: ENV['NEXMO_API_SECRET']
  )
  puts "Sending Message to Each Recipient"
  recipients.each do |recipient|
    if recipient.subscribed == true
      client.sms.send(
        from: ENV['FROM_NUMBER'],
        to: recipient.number,
        text: self.weekend_message(yesterday, today)
      )
      puts "Sent message to #{recipient.number}"
    end
  end
end
```

The value for the `text` parameter above refers to a class method called `#weekend_message`. This method will compose the string for the weekend update by checking if today is the same as yesterday or not:

```ruby
def self.weekend_message(yesterday, today)
  if today == yesterday
    response = "Today is the same as yesterday, and the answer is #{today}."
  elsif today =! yesterday
    response = "Today is not the same as yesterday, the answer for today is #{today}."
  else
    response = 'Today and yesterday are both neither affirmative or positive. Are we in an alternative dimension of time and space?'
  end
  self.compose_message(response)
end
```

Next, the method containing the `HEREDOC` string with the body of the message:

```ruby
def self.compose_message(response)
  <<~HEREDOC
  Hello! 
  It is a new day, but is it a weekend day?
  #{response} 
  To be removed from the list please respond with "1".
  HEREDOC
end
```

Finally, the method to send a removal confirmation message:

```ruby
def self.send_removal_message(to)
  @client.sms.send(
    from: ENV['FROM_NUMBER'],
    to: to,
    text: 'You have been successfully removed.'
  )
end
```

The last model we need to define before we continue to the next step is the `Recipient` model.

### Defining the Recipient Model

This model does not contain any of its class methods. The only addition we will make to this model is adding two validations to the data for recipients. These validations will act as a safeguard when adding new phone numbers to the database. We will check that a) a number is indeed being provided in the data and b) the number is not a duplicate of an already existing record. To do these validations we add two lines under the class definition:

```ruby
class Recipient < ApplicationRecord
  validates :number, presence: true
  validates :number, uniqueness: true
end
```

## Create the Controller and Routes

We are getting close to finishing the construction of our app! The next step is defining the controller actions that will dictate the flow of the application. First, let's generate the controller using the Rails generator from the command line:

```bash
$ rails generate controller WeekendChecker
```

This will create a new empty controller file in `app/controllers` called `weekend_checker_controller.rb` and complementary view files in `app/views/weekend_checker`. We will add an index view shortly. At this point, we'll focus on the controller.

The controller needs three actions to correspond to three routes: `#index`, `#create` and `#event`. The `#index` route will be the default and only view for our website. That will be the place where individuals can subscribe to the list. The `#create` route will be where new numbers get processed. Finally, the `#event` route will be where the application receives webhook data from the SMS API, including removal requests, and processes them.

```ruby
class WeekendCheckerController < ApplicationController

  def index
  end

  def create
    @recipient = Recipient.new(recipient_params)
    if @recipient.save
      flash[:notice] = "Phone number saved successfully."
    else
      flash[:alert] = "Form did not save. Please fix and try again."
    end
    redirect_to '/'
  end
  
  def event
    if params[:text] == '1'
      recipient = Recipient.find_by(number: params[:msisdn])
      if recipient
        if recipient.update(subscribed: false)
          Messenger.send_removal_message(params[:msisdn])
        end
      end
    end
    puts params

    head :no_content
  end

  private

  def recipient_params
    params.permit(:number, :subscribed)
  end
end
```

These three controller actions need three corresponding routes defined in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  get '/', to: 'weekend_checker#index'
  get '/webhooks/event', to: 'weekend_checker#event'
  post '/recipient/new', to: 'weekend_checker#create'
end
```

The penultimate item for our application code setup is creating a basic view for the `/` route.

### Defining the View

In order to subscribe to the SMS list, we will create a view accessible at the top-level of the URL that will contain a sign-up form.

Inside the `app/views/weekend_checker` folder add an `index.html.erb` file. It will contain the following code:

```ruby
<h2>Is It The Weekend? Get a Daily Text to Find Out!</h2>
<p>
This is a free service that will analyze <a href="http://isittheweekend.com">isittheweekend.com</a> and check for any updates once a day. If there is an update it will send you a text message at the number you provide. 
</p>
<p>
To remove yourself from the SMS list, reply to the text message you receive with the number "1".
</p>
<p>
SMS messages are sent using the <a href="https://developer.nexmo.com">Nexmo SMS API</a>.
</p>

<% flash.each do |type, msg| %>
  <div>
    <%= msg %>
  </div>
<% end %>

<%= form_with model: @recipient, url: "/recipient/new" do |f| %>
  <%= f.telephone_field :number, :placeholder => '12122222222' %>
  <%= f.hidden_field :subscribed, value: true %>
  <%= f.submit "Add Number" %>
<% end %>
```

The final coding task we have to do is to set up our new Rake task that will run all this code and configure the `whenever` gem to execute the Rake task once a day.

## Create the Rake Task and Schedule It

Once again, we will use a Rails generator from the command line to create the file for our Rake task. From the command line run the following:

```bash
$ rails generate task scraper check_site_update
```

The above task will create a file in `lib/tasks` called `scraper.rake`. When we open it inside our code editor it will look like this:

```ruby
namespace :scraper do
  desc "TODO"
  task :check_site_update => :environment do
  end
end
```

Let's redefine the `desc` with a short string of what this task will do: `desc "Check Website for Any Updates"`. Next, inside the `task` block add the `DiffStorage#check_last_record` class method, which is the entry point for all the work we created previously:

```ruby
namespace :scraper do
  desc "Check Website for Any Updates"
  task :check_site_update => :environment do
    DiffStorage.check_last_record
  end
end
```

Now that our Rake task is defined, we lastly need to initialize the `whenever` gem and let it know that we want this task run once a day. To do that, first, we run the initializer command for the gem from the command line:

```bash
$ bundle exec wheneverize .
```

The above command creates a `schedule.rb` file inside the `config/` folder. Add the following code to that file to run the `scraper:check_site_update` task daily:

```ruby
every 1.day do
  rake "scraper:check_site_update"
end
```

Now that the schedule is created, we need to update the crontab file on our machine to know about this new job. We do that by running `bundle exec whenever --update-crontab` from the command line. Once that is done, the task is fully initialized and configured to run once a day on our machine.

The code for our application is all set. The only thing that is missing now is creating our Nexmo account, obtaining our Nexmo API credentials and provisioning a virtual phone number to send the daily text messages with. Once we have this information we will add it to our application as environment variables.

## Nexmo API Credentials and Phone Number

To create an account navigate to the [Nexmo Dashboard](https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=github&utm_campaign=weekend-checker-sms-app) and complete the registration steps. Once you have finished registering, you will enter your Dashboard.

If you have not done so previously, create a `.env` file in the top-level directory of your application and add your `NEXMO_API_KEY` and `NEXMO_API_SECRET` to it. The values for those are found at the top of the dashboard page under the `Your API credentials` header.

```ruby
NEXMO_API_KEY=
NEXMO_API_SECRET=
```

The next task we need to do inside the dashboard is to provision a phone number. After you click on the `Numbers` link on the sidebar navigation, a drop-down menu will appear. Once you select the `Buy numbers` option and then click the `Search` button you will see a list of possible numbers to acquire.

When searching for numbers by feature, country, and type, it is recommended to select the country that your users will be based in, `SMS` for features and `Mobile` for type.

After clicking the orange `Buy` button for the number you wish to purchase, you can add that number to your `.env` file as a new variable called `FROM_NUMBER`:

```ruby
NEXMO_API_KEY=
NEXMO_API_SECRET=
FROM_NUMBER=
```

The last item we need to do inside our dashboard is to provide an externally accessible URL as the event webhook for the phone number. For development purposes, [ngrok](https://ngrok.io) is a good tool to use, and you can follow [this guide](https://developer.nexmo.com/concepts/guides/testing-with-ngrok) on how to get up and running with it.

From the dashboard `Numbers` sidebar navigation drop-down, once you select `Your numbers` you will see your newly provisioned phone number in a list presentation. After clicking on the gear icon to manage its properties, a settings dialog menu will be shown to you.

In the above screenshot example, you would replace the `Inbound Webhook URL` text field with your own URL ending with `/webhooks/event`.

That's it! Our code is all finalized and our Nexmo credentials are all set. At this point, you face a choice for running your application. You can either run it locally or you could deploy it to an external hosting provider, like Heroku. In the final step, we will discuss how to run it locally. 

If you are interested in deploying it for a more long-term solution, you can visit the [GitHub repository](https://github.com/nexmo-community/weekend-checker-sms-app) and click on the `Deploy to Heroku` button at the top of the README to start that process.

## Running the Application

We are now ready to run our brand new application! In order to run it locally, the Rails event webhook needs to be accessible to the outside world outside of your local environment. For example, if you are using ngrok after following [this guide](https://developer.nexmo.com/concepts/guides/testing-with-ngrok) then both the Rails application and ngrok need to be running simultaneously. 

To start the Rails application execute the following from your command line:

```bash
$ bundle exec rails server
```

Then you can navigate in your browser of choice to `localhost:3000`. You will see the sign-up form you created. Go ahead and fill it out with your phone number and submit it. Now, once the Rake task is run, you should expect to receive an SMS letting you know if it is the weekend and whether today is different than yesterday!

## Next Steps

The application we built while whimsical demonstrates the potential for leveraging web scraping and SMS to create an application that delivers updates to subscribers. There are countless potential use cases for an application like this. Whether you are interested in replicating this exact scenario or in porting the code for your own use case, there is, even more, to explore on this topic. 

For further exploration of other SMS possibilities check out the following resources:

* [Send SMS Reminders of Google Calendar Events with Zapier](https://learn.vonage.com/blog/2020/03/04/how-to-send-sms-reminders-of-google-calendar-events-with-zapier-dr)
* [Create an Interactive Scavenger Hunt with Nexmo's SMS and Voice API](https://learn.vonage.com/blog/2019/08/14/how-to-create-an-interactive-scavenger-hunt-with-nexmos-sms-and-voice-api-dr)
* [Shipping Notifications on WordPress WooCommerce with SMS](https://learn.vonage.com/blog/2020/01/11/shipping-notifications-on-wordpress-woocommerce-with-nexmo-sms-dr)