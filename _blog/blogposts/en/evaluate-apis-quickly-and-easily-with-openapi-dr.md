---
title: Evaluate APIs Quickly and Easily with OpenAPI
description: Sharing more best practice knowledge from our own processes, this
  post explains how you can use Open API Specifications to better your
  development workflow.
thumbnail: /content/blog/evaluate-apis-quickly-and-easily-with-openapi-dr/OpenAPI-Specification_1200x600.jpg
author: lornajane
published: true
published_at: 2019-09-13T08:00:46.000Z
updated_at: 2021-05-10T15:14:01.138Z
category: tutorial
tags:
  - open-api
comments: true
redirect: ""
canonical: ""
---
At Nexmo, we publish OpenAPI specifications for all our APIs. This makes it easier for developers to explore, evaluate and integrate our APIs into their own applications. Read on to find out more about OpenAPI and why we share these API specifications with developers.

## What Is OpenAPI?

[OpenAPI](https://openapis.org) is a machine-readable way to describe an API. It is written in either YAML or JSON, and describes the overall purpose, authentication mechanism, and other details of the API (if you've heard of Swagger, OpenAPI is the successor to that). It also describes each of the API's endpoints in detail. For example, here's an excerpt from our Account API, showing how you can check the balance on your Nexmo account:

```yaml
  /account/get-balance:
    servers:
      - url: "https://rest.nexmo.com"
    get:
      operationId: getAccountBalance
      summary: Get Account Balance
      description: Retrieve the current balance of your Nexmo account
      parameters:
        name: api_key
        description: Your Nexmo API key. You can find this in the [dashboard](https://dashboard.nexmo.com)
        in: query
        required: true
        schema:
          type: string
          example: abcd1234
        name: api_secret
        description: Your Nexmo API secret. You can find this in the [dashboard](https://dashboard.nexmo.com)
        in: query
        required: true
        schema:
          type: string
          example: ABCDEFGH01234abc
```

As you can see, the API description format is very verbose. That's because it needs to describe an API so well that even the machines can understand it. The sample shown here has the URL, verb and parameters needed to get information about the account balance. The spec also provides a way to describe the responses statuses and payloads that might be returned, both the successful ones and the other kind!

## Download an OpenAPI Specification

OpenAPI specifications are widely used within API provider companies. The machine-readable spec can be very powerful in the development cycle, enabling automated code generation, testing, and library SDKs.

However the OpenAPI spec becomes even more useful when it is shared widely outside of the API provider's own organisation. It's a good indicator of modern API practices, and it is much quicker to grab a standard-format file to use within your own tools than it is to wade through unfamiliar documentation looking for information. We're seeing lots of API providers offering OpenAPI specs for their APIs and we love it :)

If you look at a Nexmo API reference page, you will see a button like this:

![A big blue Download OpenAPI 3 Description button](/content/blog/evaluate-apis-quickly-and-easily-with-openapi/download-oas.png "A big blue Download OpenAPI 3 Description button")

The API reference documentation is generated from the OpenAPI specification itself, and clicking the download button gives you the source YAML file. You can also find all our specifications [on GitHub](https://github.com/nexmo/api-specification).

## Explore the API in Postman

Our favourite thing to do with an OpenAPI file we haven't seen before is to import it into [Postman](https://www.getpostman.com/). If you're not already familiar with this excellent tool, it is a really nice HTTP client that is really valuable when working with APIs (it's actually much more than that, check it out for yourself).

Postman now has support for OpenAPI v3 files. You can import a file when creating a collection:

![Shows the import dialog when creating a collection](/content/blog/evaluate-apis-quickly-and-easily-with-openapi/import-postman.png "Shows the import dialog when creating a collection")

Importing an OpenAPI spec will produce a ready-made "Collection" of API requests, and each individual endpoint already has a request created for you. You can quickly add your API key, secret, and any other parameters needed for this request and run it.

![check balance postman](/content/blog/evaluate-apis-quickly-and-easily-with-openapi/check-balance-postman.png "check balance postman")

I find this such a speedy way of exploring an API that I'm not familiar with. Rather than having to read the docs and piece together some example API calls to try to figure out if this particular API will meet my needs, everything is in front of me.

**Pro-Tip:** feel free to try this now with the Nexmo API. You need to [sign up for an account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) first, but don't worry, it comes with a little free credit for you to play with.

## Generate Your Own SDK

At Nexmo we publish Server SDKs in six and a half different tech stacks - but not every API provider does, or may not offer the programming language you were looking for. As a halfway house between a decent SDK and nothing at all, you can use a code generator to create a basic wrapper for the API. Check out the "SDK Generators" section on <https://openapi.tools/#sdk> for some examples.

Having either the "real" SDK or a generated one can speed up API integrations quite a bit; autocomplete features in your IDE is much quicker than looking things up in the documentation at every step. Generating an SDK for just one part of the API can also lead to fewer dependencies or a smaller codebase and in some situations that really matters. Choosing an API provider that will give you the OpenAPI spec is very helpful in those scenarios.

## Editor's Note: Learn More About OpenAPI

<em>If you're interested in knowing more about OpenAPI, why not come along to our [Vonage Campus event](https://www.vonage.com/campus/#developers) in San Francisco? Lorna (the author of this post) is going to be there to give a talk about OpenAPI - and she loves to chat about OpenAPI in general so it's a great opportunity to hang out with the Nexmo crowd and talk APIs.</em>