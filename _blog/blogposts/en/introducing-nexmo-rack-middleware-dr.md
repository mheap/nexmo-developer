---
title: Introducing Nexmo Rack Middleware
description: Nexmo Rack Middleware makes it easy to incorporate Nexmo API
  functionality into your Ruby application. Just add the middleware to your app
  and get started!
thumbnail: /content/blog/introducing-nexmo-rack-middleware-dr/Rack-Middleware_1200x600.png
author: ben-greenberg
published: true
published_at: 2019-12-04T09:00:56.000Z
updated_at: 2021-05-18T11:39:58.189Z
category: announcement
tags:
  - sms-api
  - ruby
comments: true
redirect: ""
canonical: ""
---
Behind every great web framework is infrastructure that makes it all possible. Whether you are building with Ruby on Rails, Sinatra or other Ruby based web frameworks, you are most likely utilizing Rack.

Rack makes it possible to build a customizable interface between your favorite framework and your application server. This will allow you to introduce middleware into your program.

Rack middleware are succinct applications that are called upon during a web application's request and response lifecycle.

So, whether you are looking to middleware for security, logging, serving static files or more, you can do so in a relatively straightforward process.

## Introducing Nexmo Rack

<sign-up number></sign-up>

If you are working on a Nexmo based application written in Ruby now you can take advantage of the newly released `nexmo_rack` to incorporate Nexmo API functionality into your middleware stack.

[Nexmo Rack Middleware](https://github.com/Nexmo/nexmo-rack) is our latest offering in our growing Ruby toolkit, which already includes a [Ruby SDK](https://github.com/Nexmo/nexmo-ruby) and a [Rails initializer gem](https://github.com/Nexmo/nexmo-rails).

We released the Nexmo Rack middleware at RubyConf 2019 with its first use-case of verifying signed SMS messages. This is a very relevant area for Rack middleware. If you are working with SMS in your application, then this first feature of `nexmo_rack` is something that could benefit your development.

[Signed SMS messages](https://developer.nexmo.com/concepts/guides/signing-messages) is a way to verify that the message originated from its claimed source, that it has not been tampered with and to protect against message interception.

With Nexmo you can use signatures for both outbound and inbound messaging. We support a variety of signing algorithms, including `MD5`, `SHA-256`, `SHA-512` and others. You must set and use a `SIGNATURE SECRET` to encrypt and decrypt signed SMS messages. Your `SIGNATURE SECRET` can be set in your [Nexmo Dashboard](https://dashboard.nexmo.com).

## Get Started With Nexmo Rack

To use the Nexmo Rack middleware, you need to install the gem. If you are building a Rails application, you can include it in your project's `Gemfile`:

```ruby
gem 'nexmo_rack'
```

To install the gem in a standalone Ruby application, you can simply install it on your system by running `gem install nexmo_rack` from the command line.

After installing the gem, you must provide it your signature secret, and the desired signature hashing method.

### Provide Your Credentials

Nexmo Rack supports both environment variables and Rails Credentials, and you are welcome to use whichever you prefer when providing the gem with your API credentials. Regardless of your chosen method,  it is always advisable to not commit your credentials to version control.

If you are using environment variables, open up your `.env` file and add two new entries for your Nexmo signature secret and the desired signing algorithm:

```ruby
NEXMO_SIGNATURE_SECRET = 'your_secret_key'
NEXMO_SIGNATURE_METHOD = 'md5hash'
```

If you are using the Rails Credentials system, you must first open up your decrypted Rails Credentials by executing `EDITOR="code --wait" rails credentials:edit` from your command line. You can replace the value for the `EDITOR=` variable with your preferred code editor.

Once the credentials file is open, you can add the signature secret and signature method with the following namespacing:

```ruby
nexmo:
  signature_secret: your_secret_key
  signature_method: md5hash
```

### Using The Middleware

Once Nexmo Rack is properly credentialed in your application you can go ahead and use it. One of the best features of Rack middleware is its usage simplicity.

The `VerifySignature` functionality will inspect every incoming request for a `sig` key, and will seek to verify the signature of those messages that have the `sig` key. If the message is verified it will pass it to the next item in your stack, and if the message is not verified it will return a `403 Forbidden` status. You can enable this functionality in either a standalone Ruby application or a Rails application.

#### Mounted Into a Rails Application

Add the Nexmo Rack middleware into your `config/application.rb` file to initialize it within your application:

```ruby
config.middleware.use Nexmo::Rack::VerifySignature
```

#### As a Standalone Application

Add the Nexmo Rack middleware into your `config.ru` Rack configuration file:

```ruby
use Nexmo::Rack::VerifySignature
```

That is all you have to do to start taking advantage of seamless signed SMS validations using Nexmo Rack!

Do you have any questions or comments? We would love to hear what you are building with Nexmo Rack or any of our Ruby tooling. You can join the Nexmo Developer Relations team on [Slack](https://developer.nexmo.com/community/slack), send us an [email](mailto:devrel@nexmo.com) or connect with us on [Twitter](https://twitter.com/NexmoDev). 

## Further Reading

Interested in discovering more?

* [Signed Messages Concept Overview](https://developer.nexmo.com/concepts/guides/signing-messages)
* [Nexmo Rack on GitHub](https://github.com/Nexmo/nexmo-rack)
* [Nexmo SDKs and Tools](https://developer.nexmo.com/tools)