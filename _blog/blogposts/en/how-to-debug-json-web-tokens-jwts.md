---
title: How To Debug JSON Web Tokens (JWTs)
description: In this post you'll see some best practices and tips to implement
  on how to debug issues with JSON Web Tokens (JWTs), regardless of programming
  language.
thumbnail: /content/blog/how-to-debug-json-web-tokens-jwts/Blog_Debug-JWT_1200x600.png
author: lornajane
published: true
published_at: 2020-08-26T13:13:19.000Z
updated_at: 2021-05-11T17:17:26.985Z
category: tutorial
tags:
  - jwt
  - json
comments: true
redirect: ""
canonical: ""
---
Many modern web applications, both client-side and server-side, use JSON Web Tokens (JWTs) for authentication, which is an excellent approach. However, when things don't work, it can be tricky to work out why.

This post aims to give you some tactics for understanding and correcting problems with JWTs. If you're just getting started, check out the [documentation on working with JWTs and our APIs](https://developer.nexmo.com/concepts/guides/authentication#json-web-tokens-jwt) first.

## Does Your JSON Web Token Look Plausible?

Sometimes the problem is as simple as knowing whether you even passed the right value into the right place, the equivalent to "is it plugged in?" question.

So, add a little debugging to your code to output the JWT somewhere you can see, such as your error log or console.

Then take a look for the following:

* Does this look like a token? It should be three sets of garbled-looking alphanumeric strings (technically, upper and lower case characters, numeric digits, `+` and `/` are permitted, with `=` used for padding), separated by dots.
* Is there whitespace around it, including a newline at the end? Pesky, errant whitespaces can trip up some tools.
* Is it there at all? I have mistyped a variable name and regenerated the token a few times before realising that the problem is me, not the token.

If the token passes visual inspection, then we need to get out some more specific tools.

## Check the JSON Web Token at jwt.io

There is an excellent [JWT debugging tool](https://jwt.io/#debugger-io) (thanks, Auth0!) that can help us to understand when things are not what we were aiming for.

![Screenshot of the JWT.io debugger tool, with default values](/content/blog/how-to-debug-json-web-tokens-jwts/jwtio.png)

Paste your JWT into the left-hand pane, and if it parses, the details of the three sections will show up on the right-hand side.

The first section is the header, showing the type and algorithm used. For signing Vonage API calls, this will usually be `typ` of `JWT` and `alg` of `RS256` (the JWTs on the [Messages API signed webhooks](https://developer.nexmo.com/messages/concepts/signed-webhooks) are `HS256`).

The middle section contains most of the actual data. There are a few expected fields here for Vonage API calls with JWTs:

* `iat` stands for "issued at" and should be a UNIX timestamp
* `exp` is the "expiration time" and is also a UNIX timestamp
* `jti` stands for "JWT ID", and should be a unique identifier (format not specified)
* `application_id` is required for Vonage API calls, and it must match the Private Key used to sign the token.

You may also see a `sub` field (the Client SDKs use this) or something called `nbf` which is the timestamp that this token is "Not Before", meaning the token isn't valid until that moment.

The third and final section in the jwt.io debugger is the signature. JWTs get created with a private key that will not be part of the payload.

The private key is essentially a shared secret between you and Vonage. You can check that the signature checks out by adding your private key into the web interface in this section.

## Regenerate Your JWT

Sometimes the problem we think is the token is something completely different! Here are some tactics to try when the first two steps have not helped.

### Try a New Application

Creating a new application, generating new keys, making sure you have the correct file named `private key`—these are all steps that really shouldn't make a difference, but sometimes are all that is needed. It's my "one weird trick" for JWT problems, and perhaps it will help you too?

### Generate a Different JSON Web Token

Try generating a token and then using it either in your application or in a raw API call from your favourite HTTP client.

You can generate a JWT from the [Nexmo CLI tool](https://github.com/Nexmo/nexmo-cli), using your application ID and Private Key, like this:

```
nexmo jwt:generate path/to/private.key application_id=asdasdas-asdd-2344-2344-asdasdasd345
```

Alternatively, we have a web-based helper on our Developer Portal that you can use to generate a JWT: <https://developer.nexmo.com/jwt>.

## Debugging is a Skill

Fault finding is a skill set all of its own, and hopefully, there was something in this post that helps you move forward with building something awesome. If you have more tips to share, let us know! We're [@VonageDev on Twitter](https://twitter.com/VonageDev).