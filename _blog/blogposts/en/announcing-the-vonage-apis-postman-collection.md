---
title: Announcing the Vonage APIs Postman Collection
description: We've released a Postman API collection for the Vonage APIs. Find
  out what we've implemented and how it can help you build with our APIs.
thumbnail: /content/blog/announcing-the-vonage-apis-postman-collection/Blog_Postman_1200x600.png
author: julia
published: true
published_at: 2020-09-16T10:53:56.000Z
updated_at: 2021-05-11T15:33:20.020Z
category: release
tags:
  - open-api
  - postman
comments: true
redirect: ""
canonical: ""
---
At Vonage, we publish OpenAPI specifications for all our APIs. These specs enable our developer community to explore, evaluate, and integrate the Vonage APIs efficiently.

As [Lorna](https://twitter.com/lornajane) mentioned in her article on [evaluating APIs using OpenAPI](https://www.nexmo.com/blog/2019/09/13/evaluate-apis-quickly-and-easily-with-openapi-dr), downloading an [OpenAPI Spec](https://developer.nexmo.com/concepts/guides/openapi) and exploring it in [Postman](https://www.postman.com/) is a great way to familiarize yourself with new APIs.

I couldn't agree more! If you're not already familiar with [Postman](https://www.postman.com/), it's a friendly graphical interface to a powerful cross-platform HTTP client that I encourage you to try.

We're excited to announce that exploring the Vonage APIs has just gotten even quicker and easier! We've added a "Run in Postman" button to the [Postman page on our developer portal](https://developer.nexmo.com/tools/postman), so now you're only a couple of clicks away from making your first request.

It is also discoverable on the [main Postman network](https://explore.postman.com/network/search?q=vonage) if you'd rather browse it there.

Once you click on the **Run in Postman** button, you'll be taken to your Postman instance of choice, and all of the Vonage API Calls will be waiting for you, nicely organized into a collection.

![Vonage APIs Postman collection imported view](/content/blog/announcing-the-vonage-apis-postman-collection/vonage-apis-postman-collection.png)

A great thing about using a Postman Collection is that we can prepare the requests for you, so there's minimal work involved in making the API calls.

It also has some neat features, like the ability to configure environment variables. This collection comes with a **Vonage Environment** that lists *API_KEY*, *API_SECRET*, and *JWT*, which are the most commonly used parameters, but feel free to add others as you go.  You can find the environments by clicking the cog icon in the top right-hand corner.

![Vonage environment variables in Postman Collection](/content/blog/announcing-the-vonage-apis-postman-collection/postman-environment-variables.png)

To add your credentials, update the current values of *API_KEY* and *API_SECRET* with the API key and secret found in your [Vonage dashboard](dashboard.nexmo.com/) (no need to set up JWT for now).

## Using the Vonage APIs Postman Collection

Next, let's have a closer look at using the Vonage APIs Postman Collection to explore the *[Numbers API](https://developer.nexmo.com/numbers/overview)*. 

Expand the collection folder and find the *Numbers* folder inside it.

![Numbers requests in Vonage APIs Postman collection](/content/blog/announcing-the-vonage-apis-postman-collection/numbers-in-postman-collection.png)

Vonage's Numbers API allows you to manage your virtual number inventory programmatically. To find out more about the available operations, make sure to check out the [Numbers API Reference](https://developer.nexmo.com/api/numbers?theme=dark).  

For this example, let's try out the *List numbers you own* entry.

Your `api_key` and `api_secret` will be pulled in dynamically from the Vonage Environment, so double-check that you've set those values in the environment, then click send.

![Numbers API List numbers you own response body](/content/blog/announcing-the-vonage-apis-postman-collection/numbers-api-postman-request-body.png)

Et voilà! You've successfully made your first Vonage API request using our Postman collection!

Give it a try, have fun, and let us know what you think! 

## Where Next?

* [Vonage APIs Postman Collection](https://developer.nexmo.com/tools/postman)
* [OpenAPI Makes Easier Integrations](https://www.nexmo.com/blog/2020/06/03/openapi-makes-easier-integrations)
* [Evaluate APIs Quickly and Easily with OpenAPI](https://www.nexmo.com/blog/2019/09/13/evaluate-apis-quickly-and-easily-with-openapi-dr)
* [Postman Docs](https://learning.postman.com/docs/getting-started/introduction/)