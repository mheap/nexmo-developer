---
title: New Year, New Rails
description: "Some personal impressions of the Rails 7 release. TLDR: I'm excited!"
thumbnail: /content/blog/new-year-new-rails/new-year_new-rails.png
author: karl-lingiah
published: true
published_at: 2022-02-02T11:55:20.239Z
updated_at: 2022-01-31T11:37:06.868Z
category: inspiration
tags:
  - ruby-on-rails
  - ruby
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The start of a new year is often seen as the time for reinvention of the `self`. Take out that gym membership, eat more healthily, learn a new language, and so on. I've never really been a fan of 'new year, new you' type resolutions, but based on initial impressions, I'm certainly a fan of 'new year, new Rails'.

Okay, that 'new year' part isn't *entirely* accurate; [Rails 7.0](https://edgeguides.rubyonrails.org/7_0_release_notes.html) was released at the end of last year, on December 15th. We've already had a [7.0.1](https://rubyonrails.org/2022/1/6/Rails-7-0-1-has-been-released) patch update since then to support Ruby 3.1. The 'new Rails' part feels accurate, though. A major version update always brings a sense of newness, but Rails 7.0 goes beyond that. It feels like a bold and exciting departure from previous versions.

During Rails' early years, its use of convention over configuration, and opinionated defaults in terms of tooling and components, was considered somewhat controversial. These key tenets of the Rails approach, which ultimately formed part of [The Rails Doctrine](https://rubyonrails.org/doctrine), were also what attracted a lot of developers to the framework. Sure, you had to get comfortable with the defaults and learn the conventions, but once you did that, Rails was simply a pleasure to work with. That overall approach supported the first pillar of The Rails Doctrine: [Optimize for programmer happiness](https://rubyonrails.org/doctrine#optimize-for-programmer-happiness).

One of the strengths of Rails as a framework has been its ability to evolve with the ever-changing tech landscape. Over the past few years, much of this change has taken place on the front-end, where a desire for reactive interfaces led to the rise in Single Page Applications (SPAs) and the associated shift in application logic away from the server and towards the client. One of the impacts of this shift was to add complexity to the front-end development process in terms of managing dependencies, transpilation, bundling of assets, and so on. Since Rails 5.2, the answer to managing this front-end complexity has been [Webpacker](https://guides.rubyonrails.org/webpacker.html).

## Does Webpacker Spark Joy?

Although Webpacker abstracted away some of the complexity of managing front-end dependencies and configuration, it always seemed like something of a workaround, albeit a necessary one. It was a way of hooking a Rails app into the existing front-end ecosystem rather than an in-built front-end solution. Great when everything worked, but you could still end up having to deal with some complex Node package dependency issues or debugging various compilation errors -- probably not the sort of things most Rails developers want to be spending too much time on.

It looks like the Rails team have taken the [Marie Kondo approach](https://konmari.com/marie-kondo-rules-of-tidying-sparks-joy/) to Webpacker because, in Rails 7, it's gone. The [thinking behind this move](https://world.hey.com/dhh/modern-web-apps-without-javascript-bundling-or-transpiling-a20f2755) is based on recent advancements in the wider web and internet environment, namely the now universal browser support for ES6 combined with the widespread adoption of HTTP/2. The former removes the need for transpiling ES6 code down to ES5, and the multiplexing capabilities of the latter mitigates the latency hit of requesting multiple small files instead of one large bundled 'pack'.

So you might be thinking, 'but I still need all of my Node packages, how do I get them?'. The answer to this is [import maps](https://github.com/WICG/import-maps), combined with CDNs that can serve ES modules, like [Skypack](https://www.skypack.dev/) or [JSPM](https://jspm.org/docs/cdn). This combination removes the need for build tools or even having Node installed locally at all. The `importmap-rails` [gem](https://github.com/rails/importmap-rails), included by default in Rails 7, essentially maps 'bare module specifiers' to a source for loading that module. You set up the configuration for your importmap in a `config/importmap.rb` file. The specific modules are requested at runtime as and when needed by specific layouts via a `<script>` tag of type `"importmap"` in the `<head>` of that layout. Pretty awesome!

This approach isn't going to work for everyone. Some developers are going to want to use React with JSX or use Typescript, and so will still require a compilation/ transpilation step and the ability to hook into the Node ecosystem. Well, you can still do this in Rails 7. The `jsbundling-rails` [gem](https://github.com/rails/jsbundling-rails) lets you use esbuild, rollup.js, or Webpack to bundle your JavaScript and then deliver it via the asset pipeline in Rails.

Although some developers are still going to want to use that kind of split front-end/ back-end approach, the message from Rails 7 is that for most use-cases, you don't necessarily need some sort of heavy-weight front-end framework or lots of custom JavaScript on the front-end to provide a reactive user experience in the browser. You can provide that experience using a much more unified application architecture by using [Hotwire](https://hotwired.dev/).

## Hotwire is Rails-y

Hotwire isn't completely new -- it could be used in Rails 6 with some setup -- but it is now the default approach in Rails 7. Hotwire, developed by the teams at Basecamp and Hey, is comprised of three libraries: Turbo, Stimulus, and the yet-to-be-released Strada.

**Turbo**

Turbo does most of the heavy lifting. It uses Server-Side Rendering (SSR) to send HTML over the wire instead of JSON, thus removing the requirement on the front-end for rendering, state-management, and so on. Turbo combines several complementary concepts and techniques.

- Drive: Intercepts link clicks and form submissions, issues a `fetch` request for the new content, and renders the HTML response.
- Frames: Allows you to split up a view into individual parts or components so that link clicks or form submissions refresh only specific parts of the webpage rather than performing an entire page reload.
- Streams: Delivers partial page refreshes in response to asynchronous actions sent over WebSocket or a Server-Sent Event.

That might all sound like pretty standard SPA functionality. The key difference about Turbo is that the logic for all of that front-end responsiveness isn't being split out into a separate framework bolted onto the front of your Rails app. Instead, it's right there in your Rails models, views, and controllers, using clear, logical, and elegant conventions.

This article isn't intended to be a tutorial, so I won't go into the details of these conventions here, but be sure to check out the Turbo [Handbook](https://turbo.hotwired.dev/handbook/introduction) and [developer reference](https://turbo.hotwired.dev/reference/drive), as well as the [README](https://github.com/hotwired/turbo-rails/blob/main/README.md) page for the Rails implementation of Turbo, `turbo-rails`.

**Stimulus**

Stimulus bills itself as a "JavaScript framework with modest ambitions" and is intended to complement Turbo. It leans heavily on HTML data attributes, using JavaScript objects called *controllers* to respond to browser events fired by elements with a matching `data-controller` attribute or mapping specific actions to DOM events using `data-action` attributes. Again, I won't delve into the specifics here, but you can find out more in the Stimulus [Handbook](https://stimulus.hotwired.dev/handbook/introduction), [developer reference](https://stimulus.hotwired.dev/reference/controllers), and the [README](https://github.com/hotwired/stimulus-rails/blob/main/README.md) page for the Rails implementation of Stimulus `stimulus-rails`.

---

Hotwire is designed to be framework agnostic. But it makes a lot of sense in a Rails context, especially given the way that the Rails implementations of the libraries integrate with `ActiveRecord`. For example, you can use a `broadcasts_to` helper in your models to set up various callbacks that publish to a particular named channel, say `:todo_list`, when any data changes are made within the context of that model (i.e., through create, update, or destroy actions).

```ruby
class Todo < ApplicationRecord
  broadcasts_to :todo_list
end
```

You can then set up Turbo Stream elements to subscribe to the `:todo_list` broadcast. Those elements are appropriately updated when data changes occur. Anyone viewing a page containing a stream element subscribed to that particular broadcast will see their browser update that element of the page in real-time.

This functionality uses `ActionCable`, which has long been a component of Rails, in the background. What `turbo-rails` does is wire everything together in a logical and accessible way.

The big thing for me about Hotwire is that it feels Rails-y. It abstracts away a lot of front-end complexity via an innovative approach and some solid conventions. That's always been the Rails way, and its integration into Rails 7 seems like it adheres much more closely to the Rails doctrine than the Webpacker compromise ever could.

## Other Highlights

Although the headline-grabbing change in Rails 7 is the new default approach to working with the front-end, there are also some notable changes in terms of the back-end. The most interesting of which are concerned with various aspects of working with data.

- Active Record Encryption provides an extra layer of security by adding [encrypted attributes](https://edgeguides.rubyonrails.org/active_record_encryption.html) to `ActiveRecord`.
- Parallel Query Loading delivers performance improvements for situations where your controller actions need to load multiple unrelated queries concurrently.

---

Personally, I'm super excited about Rails 7 and looking forward to building some cool things this year using Rails 7 and the Vonage APIs. I'd love to hear what you think about Rails 7! Let me know over on [Twitter](https://twitter.com/KarlLingiah).
