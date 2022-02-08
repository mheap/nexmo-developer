---
title: OpenAPI Makes Easier Integrations
description: We use the OpenAPI specification extensively in our documentation.
  Find out more about how having these specs can help you build better
  integrations.
thumbnail: /content/blog/openapi-makes-easier-integrations/Blog_OpenAPI_1200x600.png
author: lornajane
published: true
published_at: 2020-06-03T07:31:23.000Z
updated_at: 2021-05-05T12:56:51.669Z
category: community
tags:
  - open-api
  - documentation
comments: true
redirect: ""
canonical: ""
---
We take our [developer documentation](https://developer.nexmo.com) very seriously, especially our [API Reference](https://developer.nexmo.com/api/). The reference docs are generated from a machine-readable description of each API, in [OpenAPI](https://openapis.org) format. Working with a text-based, machine-readable format makes maintaining the docs easier. That's lovely for us, your documentation caretakers, but how does it help you, the user? I'm glad you asked!

Take a look at any one of our API reference pages. There is a button there labeled "Download OpenAPI 3 Specification" and if you click that, you'll receive the gift of YAML. You can also find all our specs in the `definitions/` folder of our [API Specifications GitHub repository](https://github.com/nexmo/api-specification).

Using a standard API description format like OpenAPI gives you access to so many different tools that understand these files. I'm going to show you a few of my favorite things to do with an OpenAPI spec!

## Import OpenAPI Spec Into Postman

When you're trying out an unfamiliar API, it can be frustrating to try to dig through the documentation to understand how to put together a particular request. Postman supports importing OpenAPI spec files and will turn them into a ready-made collection of API requests. This is a brilliant way to try out a new API without having to spend too much time reading docs and copying field names over into my HTTP client.

I'm a big fan of this approach and use it, very frequently, even on APIs I know so well that I could type the curl commands blindfolded. It's such a quick way to correctly interact with an API and I find it very helpful.

## Generate Local Reference Documentation

When I travel, I sometimes end up without a reliable internet connection. If I have the OpenAPI spec file locally (spoiler: I always have the spec files locally, I work on this repo a lot!), then I can use one of the OpenAPI documentation tools to create docs I can use on my laptop.

One option is to use the tool we use ourselves, this is [Nexmo OAS Renderer](https://github.com/nexmo/nexmo-oas-renderer). It's a Ruby-based open-source tool that we create and publish ourselves. It isn't tied to our specs though, I mostly use it for our own APIs but it should work on any valid OpenAPI v3 spec file.

The other approach I sometimes use is another open-source tool, this time in NodeJS, called [ReDoc](https://github.com/Redocly/redoc/). Again, it is useful to create HTML documentation from an OpenAPI spec. Try both options and then choose your favorite!

## Mock the API Locally During Development

The API description has information about every aspect of an API. So much information, in fact, that you could do a very good impersonation of that API with all the details that are included.

A very good impersonation of the API from an OpenAPI spec is exactly what [Prism from Stoplight](https://stoplight.io/open-source/prism) provides. It's a NodeJS tool; install it with `npm` and then start it up locally, and you have your own private copy of the API from an OpenAPI spec file!

I use this most during development where I might be calling the same API endpoint many times to make sure that I'm handling the various responses correctly. A mock server is both faster than a remote API _and_ much cheaper. There are no rate limits either. For anyone integrating with an API, tools like mock servers are a huge boost. For us as an API provider, we don't need to build or support a sandbox so that people can develop their integrations in a safe space; we get that as a side benefit of using OpenAPI.

## OpenAPI is a Gift for API Integrations

I've picked three things that I feel make a big difference to API users when their API provider makes OpenAPI specifications available. Vonage isn't particularly remarkable in publishing API descriptions; I would expect most modern API providers to do the same. Hopefully, you've got some ideas for what you'd like to try to improve your next API integration. Let us know if you're already using one of these approaches, or which one you'd like to try next?

## More OpenAPI Resources

Curious about OpenAPI and our tools? Here's some further reading for you:

* The OpenAPI Initiative: [https://www.openapis.org](https://www.openapis.org)
* Best place to look for tools to use with OpenAPI: [https://openapi.tools](https://openapi.tools)
* Postman for importing a spec to make a collection of requests to use: [https://postman.com](https://postman.com)
* Prism the mock server: [https://stoplight.io/open-source/prism](https://stoplight.io/open-source/prism)
* More Vonage-specific docs on OpenAPI, including more detailed information on using Postman and Prism, and generating docs: [https://developer.nexmo.com/concepts/guides/openapi](https://developer.nexmo.com/concepts/guides/openapi)

