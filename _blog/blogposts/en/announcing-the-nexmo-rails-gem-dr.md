---
title: Announcing the Nexmo Rails Gem
description: With the new Nexmo Rails gem you can get started creating fully
  featured Ruby on Rails communications apps easily and quickly.
thumbnail: /content/blog/announcing-the-nexmo-rails-gem-dr/announcing-the-nexmo-rails-gem.png
author: ben-greenberg
published: true
published_at: 2019-04-30T11:00:40.000Z
updated_at: 2021-05-13T20:13:31.065Z
category: release
tags:
  - ruby
  - conference
comments: true
redirect: ""
canonical: ""
---
Back at RailsConf 2016, we adopted the community-driven Nexmo Ruby gem and [made it an officially supported client library](https://www.nexmo.com/blog/2016/05/04/ruby-gem/). Since then, Ruby developers have been able to integrate Nexmo into their applications with more ease. Whether you were looking to create a [Voice app](https://www.nexmo.com/blog/2017/11/02/outbound-text-to-speech-voice-call-ruby-on-rails-dr/), [send](https://www.nexmo.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/) or [receive](https://www.nexmo.com/blog/2017/10/23/receive-sms-messages-ruby-on-rails-dr/) an SMS, obtain [insights on numbers](https://www.nexmo.com/blog/2019/03/25/getting-started-with-the-nexmo-number-insight-api-and-rails-dr/) around the world, or more, you could do it with the Nexmo Ruby gem. 

We are excited to share at [RailsConf 2019](https://nexmo.dev/railsconf/) that we have taken another step to make it even easier for Ruby on Rails developers to use the full suite of Nexmo APIs in their Rails applications with the new [Nexmo Rails gem](https://github.com/Nexmo/nexmo-rails). The Nexmo Rails gem performs another integration step for you by initializing a Nexmo client instance and making it available throughout your application.

## Setting Up the Nexmo Rails Gem

Nexmo enables you to create sophisticated Rails applications using our broad range of cloud communications APIs. The Nexmo Rails gem makes it simple and straightforward to get started. Here's how to install the Nexmo Rails gem:

### Gemfile

First, add the Nexmo Rails gem to your `Gemfile`:

```ruby
# Gemfile

gem 'nexmo-rails'
```

Then run `bundle install` from your command line to install the dependency.

<sign-up></sign-up>

### Nexmo API Credentials

You need to provide the gem with your Nexmo API credentials to access the functionality of our APIs. Once you have created your Nexmo account, navigate to your dashboard and add your API key and API secret to the `.env` file in the root folder of your application:

```ruby
# .env

NEXMO_API_KEY= # Your API key
NEXMO_API_SECRET= # Your API secret
```

Some of the Nexmo APIs also require an API signature, private key, or application ID. You can add those, if appropriate, to your `.env` as well:

```ruby
# .env

NEXMO_API_SIGNATURE= # Your API signature
NEXMO_PRIVATE_KEY= # Path to your private key file
NEXMO_APPLICATION_ID= # Your application ID
```

Ensure you have installed the `dotenv-rails` gem and added the `.env` file to your `.gitignore` so as not to commit your credentials to version control. 

### Initialize Your Client

Now you are ready to initialize a Nexmo client for your application. This is easily done by running the initializer from your command line:

```ruby
$ rails generate nexmo_initializer
```

This creates an initializer file in `/config/initializers/` called `nexmo.rb` that contains the details your application requires to instantiate the Nexmo client. Now, when you start your Rails application, you have access to a fully-authenticated Nexmo instance to begin sending text messages, creating voice interactivity, and much more.

## Using Your Nexmo Client

Now that your Nexmo Rails gem has been successfully installed and you have run the Nexmo initializer, you can begin to use the Nexmo client anywhere inside your application.

To use the Nexmo client, reference the `Nexmo` instance followed by the specific method and parameters you wish to use. For example, to send an SMS you would do the following:

```ruby
Nexmo.sms.send(from: '14155550100', to: '14155550101', text: 'Hello world')
```

To retrieve details about a number using the standard Number Insight API you would use the following:

```ruby
Nexmo.number_insight.standard(number: '14155550100')
```

To search for available phone numbers in the United States you would run the following:

```ruby
Nexmo.numbers.search(country: 'US')
```

More information on all the available functionality within the Nexmo Ruby client library can be found on [GitHub](https://github.com/Nexmo/nexmo-ruby). All of the methods within the Ruby client library can be accessed with the Rails gem—just remember to substitute the variable name `client` in the Ruby client library examples with `Nexmo`.

## Let's Talk at RailsConf

![Rails Conf](/content/blog/announcing-the-nexmo-rails-gem/railsconf.png)

We are so thrilled to share this during <a href="https://nexmo.dev/railsconf">RailsConf 2019</a> in Minneapolis. As mentioned earlier, it was during RailsConf 2016 in Kansas City that we unveiled the Nexmo Ruby gem, and it is really meaningful to continue the tradition of new and exciting developments at this year's conference. 

Come and find our booth at the conference. We'll be there with good conversation and, of course, lots of swag. We would love to hear about how you are using Nexmo in your applications or how you are thinking of incorporating Nexmo in future work. Let us know you'll be there by [tweeting @NexmoDev with the hashtag #railsconf](https://nexmo.dev/tweetrailsconf).