---
title: Nexmo Ruby v7.2.0 Release
description: The latest release of the Nexmo Ruby SDK is now available. Version
  7.2.0 extracts JWT handling offering much more control over ACLs and more.
thumbnail: /content/blog/nexmo-ruby-v7-2-0-release/Blog_Ruby-SDK-Update_1200x600.png
author: ben-greenberg
published: true
published_at: 2020-07-27T12:29:47.000Z
updated_at: 2021-05-04T17:41:11.208Z
category: release
tags:
  - release
  - ruby
  - sdk
comments: true
redirect: ""
canonical: ""
---
The Nexmo Ruby SDK recently published a new release, v7.2.0. This new version has rewritten the JSON Web Token generation feature to use the new `nexmo-jwt` Ruby gem to generate tokens. 

The [nexmo-jwt gem](https://github.com/Nexmo/nexmo-jwt-ruby) offers users more flexibility in designing a token exactly for their specific needs, and as part of this release, that functionality is now available to every user of the SDK itself.

## What Purpose Do JSON Web Tokens (JWTs) Serve

JWTs are used for many of our API services for authentication. A JWT is a self-contained mechanism for sharing information securely between machines.

Each Vonage JWT is signed with a public and private key pair using the [RSA256](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) algorithm. The process of encoding and decoding a token using this key pair enables trust to be established between the client and the server.

As mentioned, some of Vonage's newest and feature-rich APIs take advantage of JSON Web Tokens to securely authenticate and communicate. These APIs include Voice, Messages, Dispatch, and Conversation.

The [Authentication Guide](https://developer.nexmo.com/concepts/guides/authentication) on the developer portal has a full list of each API and which mode of authentication it supports.

There is a lot of complexity that is involved in generating a fully credentialed JWT by hand to use with the Vonage APIs. It is possible to do so, and we have [a guide](https://developer.nexmo.com/conversation/guides/jwt-acl#other-languages) also on the developer portal that explains the process step-by-step.

Yet, because of all of the interlinked and complex parameters it requires, we recommend using one of our SDKs to do the work for you.

## Vonage APIs JWT Generation in Ruby: What Changed?

Ever since JWT authentication was introduced to the Nexmo Ruby SDK it leveraged the [jwt](https://github.com/jwt/ruby-jwt) Ruby gem, which is a standards-compliant library for building JWTs in Ruby. This meant that a lot of the validation of the specific requirements for Vonage was left to the user to figure out.

It also meant that assisted JWT generation for Ruby developers working with Vonage APIs was only possible in the SDK, even if they did not require the full functionality of the SDK, they still needed to install it in their application.

These reasons led us to create a separate library specifically for JWT generation, [nexmo-jwt](https://github.com/Nexmo/nexmo-jwt-ruby). This Vonage JWT Ruby gem could be used inside the Ruby SDK *and*, equally important, outside of the SDK in a standalone manner as well.

As an added feature, we have worked to also simplify what you need to know for generating JWTs for Vonage APIs. We also guide you with custom exception handling when your parameters need improvement.

### Generating a JWT

The `nexmo-jwt` gem can be used inside the Nexmo Ruby SDK and standalone, as mentioned. Inside the SDK, we have maintained the same method name and structure for backward compatibility:

```ruby
  claims = {
    application_id: application_id,
    private_key: 'path/to/private_key',
    ttl: 800,
    subject: 'My_Subject'
  }
token = Nexmo::JWT.generate(claims)
```

If you used the Nexmo Ruby SDK to generate a JWT previously, you are probably accustomed to providing the `private_key` as a separate parameter to the method. While you can do that, it is no longer necessary. You can include the `private_key` inside the `claims` hash as shown above.

Another item you will notice is that we are no longer providing an explicit expiration parameter with an `exp` key and a value of an integer representing Unix machine time.

Instead, we calculate that data for you with what the Vonage APIs require. You can modify the end result by providing a custom `ttl` or "time to live" value of an integer representing a number of seconds.

However, that is not necessary either. The default is to add 900 seconds (15 minutes) from the moment the JWT is generated to calculate its time until expiration.

The process for generating a JWT using `nexmo-jwt` outside of the SDK is similar, but with some slight differences:

```ruby
require 'nexmo-jwt'

@builder = Nexmo::JWTBuilder.new(application_id: application_id, private_key = 'path/to/private/key')
@token = @builder.jwt.generate
```

### Customizing a JWT

You can also add any of these custom parameters, in addition to `ttl` as we mentioned above, in the instantiation of the `Nexmo::JWTBuilder` class:

* `nbf`: Unix Timestamp (UTC+0), in seconds, when the JWT becomes valid
* `paths`: Path information in a Hash for access control to API routes
* `sub`: “Subject” or user-created String and associated with the Nexmo Application

For example, if you wanted to create a token with custom `paths`, `subject` and `ttl` information you would do so as follows:

```ruby
@builder = Nexmo::JWTBuilder.new(
  application_id: YOUR_APPLICATION_ID,
  private_key: YOUR_PRIVATE_KEY,
  ttl: 500,
  paths: {
    "acl": {
      "paths": {
        "/messages": {
          "methods": ["POST", "GET"],
          "filters": {
            "from": "447977271009"  
          }     
        }  
      }   
    }
  },
  subject: 'My_Custom_Subject'
)

@token = @builder.jwt.generate
```

To find out more about the Nexmo Ruby SDK and the Vonage APIs you can read the documentation on [RubyDoc](https://rubydoc.info/github/nexmo/nexmo-ruby) and find code snippets, guides, tutorials and more on our [developer portal](https://developer.nexmo.com).