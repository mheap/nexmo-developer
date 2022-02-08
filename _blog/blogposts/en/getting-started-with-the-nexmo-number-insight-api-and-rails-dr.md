---
title: Getting Started with the Vonage Number Insight API and Rails
description: Use the Vonage Number Insight API and Rails to quickly check
  valuable information on phone numbers globally in real time.
thumbnail: /content/blog/getting-started-with-the-nexmo-number-insight-api-and-rails-dr/NI-w-Rails.png
author: ben-greenberg
published: true
published_at: 2019-03-25T15:37:11.000Z
updated_at: 2021-05-12T22:45:55.525Z
category: tutorial
tags:
  - number-insight-api
  - ruby
comments: true
redirect: ""
canonical: ""
---
The Vonage [Number Insight API](https://developer.nexmo.com/number-insight/overview) provides you with the ability to quickly check in real time the validity, reachability, roaming status, and more about any phone number globally.

There are three types of requests you can make to the Number Insight API:

* **Basic:** Returns the local and international formatting for the number, country code, country name, and country prefix.
* **Standard:** Returns all of the same as Basic, along with current and original cell carrier, whether the number was ported, and whether it is roaming.
* **Advanced:** Returns all the same as Standard, along with whether the number is reachable and if it is a valid number or not.

In addition, you can also make the Advanced request asynchronously. In order to make an asynchronous Advanced request, you need to supply a callback URL. 

We are going to walk through creating a Rails application that facilitates looking up basic, standard and advanced number insights on any phone number utilizing the Number Insight API. In addition to following along in this blog post, you can also clone a [working copy](https://github.com/Nexmo/nexmo-rails-number-insights) from GitHub. We will explore using the Advanced Asynchronous Number Insight API in a separate blog post.

## Prerequisites

Before we begin we need to make sure we have the following set up and ready:

* [Rails 5.2.2+](http://rubyonrails.org/)
* [Ruby 2.5.3+](https://www.ruby-lang.org/en/downloads/)

<sign-up number></sign-up>

## Set Up Rails

Once you have created your Nexmo account and have Ruby on Rails installed on your system we are ready to begin. The first thing we need to do is initialize a new Rails project. You can execute the following command in your terminal:

```bash
$ rails new number-insights-app --database=postgresql
```

With the above command, we have created a new Rails application called `number-insights-app` and designated PostgreSQL as our database of choice. You can change the name of the application to whatever you choose and, also replace the database parameter with your preferred database if you would like to use something other than PostgreSQL. 

Once you have completed the above command, change into your new application's directory and open up the project in your preferred code editor. Add the following to the `Gemfile`:

```ruby
# Gemfile

gem 'nexmo'
gem 'dotenv-rails'
```

Once you have saved the `Gemfile`, go ahead and run `bundle install` from your command line. This will install the [Vonage Ruby gem](https://github.com/Nexmo/nexmo-ruby) and the [dotenv gem](https://github.com/bkeepers/dotenv) into your application. The Nexmo gem provides easy access to the suite of Vonage APIs and the dotenv gem allows you to securely store environment variables without revealing them in your version control. 

At this point, you can also run `rake db:migrate`. This will set up the database schema for your application. For the purpose of this walkthrough, we are not going to persist the data we receive, but you are welcome to do so. 

Our next step is to create our Controller methods and our Routes.

### Define Our Controller Actions

The application we are creating is going to present to the user a form with two fields:

* A text input for a phone number
* Radio buttons to select which kind of Number Insight to run the number against

Therefore, we are going to need the following Controller actions: `index`, `show`, and `create`. The `index` action will be the top-level page for our application that will have the HTML form. The `show` action will present the data after the API request has been made. The `create` action will submit the data to the Vonage Number Insight API. Additionally, we are going to create two private methods: `nexmo` and `insight_type`. The former will instantiate an instance of the Vonage client, and the latter will be where we process the HTML form and decide what kind of Number Insight request to make.

#### The `index` and `show` Actions

The `index` and `show` actions will be our simplest to define. All we need is to define them. First, create a file in `app/controllers/` called `number_insights_controller.rb` and add the following:

```ruby
# number_insights_controller.rb

class NumberInsightsController < ApplicationController
    def index
    end

    def show
    end
end
```

#### The `create` Action

The `create` action will receive the form data from the user and send it to our `insight_type` method for processing. Thus, we define the action as follows, making sure we call the `#insight_type` method, passing the form parameters to the method, and the rendering the `show` view:

```ruby
# number_insights_controller.rb

def create
    insight_type(params)
    render :show
end
```

At this point, we need to create the previously mentioned private methods to instantiate our Nexmo client and to process the form data and make the correct API request. After designating these as `private` methods, let's first create our Nexmo instantiation method:

```ruby
# number_insights_controller.rb

private

def nexmo
    client = Nexmo::Client.new(api_key: ENV['NEXMO_API_KEY'], api_secret: ENV['NEXMO_API_SECRET'])
end
```

Next, let's create the method that will process the HTML form data and send it with the appropriate Nexmo API request:

```ruby
# number_insights_controller.rb

def insight_type(params)
    if params[:type] == 'basic'
        @data = nexmo.number_insight.basic(number: params[:number])
    elsif params[:type] == 'standard'
        @data = nexmo.number_insight.standard(number: params[:number])
    elsif params[:type] == 'advanced'
        @data = nexmo.number_insight.advanced(number: params[:number])
    else
        flash[:failure] = "Please try to submit the form again, something went wrong."
        redirect_to '/number_insights'
    end
    @data = @data.to_h
end
```

The `#insight_type` method, as shown above, takes one argument, which is the HTML form `params` and then runs through an if/else statement checking for the `type` of request selected. If the `type` does not match one of the defined types (e.g. `basic`, `standard`, or `advanced`) then a message is shared with the user that something went wrong and they are redirected to the `index` view. Lastly. the data returned from the API request is converted into a `key:value` hash form for easier handling in the view.

At this point, we need to define the routes for our application.

### Create Our Routes

Our application needs three routes:

* A `GET` route to the `index` action
* A `GET` route to the `show` action
* A `POST` route to the `create` action

Let's add them to the `config/routes.rb` file:

```ruby
# routes.rb

get '/number_insights', to: 'number_insights#index'

get '/number_insights/show', to: 'number_insights#show'

post '/number_insights/new', to: 'number_insights#create'
```

In order for our application to communicate with the Vonage Number Insight API, we need to provide it with the proper credentials. We will do that next.

### Your Vonage API Credentials

To obtain your Vonage API key and API secret, navigate to the [Vonage Dashboard](https://dashboard.nexmo.com) and once you log in you will see your credentials near the top of the page. All you need to do is click on the eye icon to reveal the API secret. You can also click on the copy icon of each item to automatically copy them to the clipboard.

![api credentials](/content/blog/getting-started-with-the-vonage-number-insight-api-and-rails/api_credentials.png "api credentials")

You are going to want to take advantage of the functionality of the `dotenv` gem you installed earlier, so create a file called `.env` in the root folder of your project. This is where we will store our Vonage API credentials. Also, it is a good idea to add `.env` to a `.gitignore` file, if you have not done so already, to ensure that it is not committed to your version control history.

In your code editor, open up the `.env` file and add the API key and secret in the following format, making sure to put your credentials after the `=` sign on each line: 

```ruby
# .env

NEXMO_API_KEY=
NEXMO_API_SECRET=
```

At this point, the only thing left to do is to create our views and then our application is ready to use.

### Set Up Our Views

We need two views and we also need to add a space in the application layout for the `flash` error message that we defined earlier in case the user provided an invalid `type` input in the HTML form. Let's add the space for the error message first.

Open up the `app/views/layouts/application.html.erb` file and right after the opening `<body>` tag and before the `<%= yield %>` tag on a new line add the following:

```ruby
# application.html.erb

<% if flash %>
    <% flash.each do |key, msg| %>
        <%= msg %>
    <% end %>
<% end %>
```

Now, if there is an error message during the processing of the form data, the user will see it at the top of the page.

#### The `index` View

The `index` view contains the HTML form where the user submits the phone number they are looking for number insights on and the type of insight they are requesting. 

Create a new folder inside `/views/` called `number_insights` and add an `index.html.erb` file inside of it. Within the `index.html.erb` file let's create our form:

```ruby
# index.html.erb

<h2>Nexmo Number Insights with Rails</h2>

<%= form_tag('/number_insights/new') do %>
    <%= label_tag(:number, "Phone Number:") %>
    <%= text_field_tag(:number) %>
    <br /><br />
    <%= radio_button_tag(:type, "basic") %>
    <%= label_tag(:type_basic, "Basic") %>
    <br />
    <%= radio_button_tag(:type, "standard") %>
    <%= label_tag(:type_standard, "Standard") %>
    <br />
    <%= radio_button_tag(:type, "advanced") %>
    <%= label_tag(:type_advanced, "Advanced") %>
    <br /><br />
    <%= submit_tag("Search") %>
<% end %>
```

We take advantage of Rails view helpers to create an HTML form that submits a `POST` request to `/number_insights/new` and contains one text field, three radio buttons, and a submit button.

#### The `show` View

Within the `show` view we are creating an HTML table that will dynamically populate its header row and data rows with the data returned from our API request. In this way, we do not need to hardcode a table for each type of API request, but rather we will let the application do that work for us. If you recall, we converted the data returned from our API request to a `key:value` hash format and saved it to the `@data` instance variable. We will use the `keys` for the header row and the `values` for the data rows.

An important item to call attention to is that some of the data items returned in the `standard` and `advanced` API requests contain a hash of hashes, and thus we need to make a second level of iteration over those nested hashes to retrieve the data inside of them. That is what is happening beginning with the `<% if value.class == Nexmo::Entity %>` condition check below.

```ruby
# show.html.erb

<h2>Number Insight Details</h2>
<h3>Number: <%= params[:number] %></h3>

<table>
    <tr>
        <% @data.each do |key, value| %>
            <th><%= key %></th>
        <% end %>    
    </tr>
        <tr>
        <% @data.each do |key, value| %>
            <% if value.class == Nexmo::Entity %>
                <td>
                    <% value.to_h.each do |subkey, subvalue| %>
                        <%= subvalue %>
                    <% end %>
                </td>
            <% else %>
                <td><%= value %></td>
            <% end %>
        <% end %>
    </tr>
</table>
```

We have now finished creating our application. Go ahead and try it with different phone numbers and with different Vonage Number Insight API request types. You can start your application from the command line with `rails -s` and navigate in your web browser to `http://localhost:3000/number_insights`. Congratulations!

### Further Reading

If you are interested in finding out more about the Nexmo Number Insight API check out the following:

* [Vonage Number Insight API Reference](https://developer.nexmo.com/api/number-insight)
* [Get Complete Caller Data with New Vonage Number Insight Feature](https://www.nexmo.com/blog/2017/03/21/know-caller-name-cnam-number-insight/)
* [Validate a Number with Ruby and Number Insight API](https://developer.nexmo.com/tutorials/validate-a-number)