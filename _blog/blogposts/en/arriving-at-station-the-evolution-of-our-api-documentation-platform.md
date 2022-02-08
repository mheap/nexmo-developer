---
title: "Arriving at Station: The Evolution of Our API Documentation Platform"
description: We've been building our documentation platform since 2017. Vonage
  has now created Station, a customisable platform that decouples content from
  code.
thumbnail: /content/blog/arriving-at-station-the-evolution-of-our-api-documentation-platform/Blog_Arriving-at-Station_1200x600.png
author: fabianrodiguez
published: true
published_at: 2020-09-02T07:18:22.000Z
updated_at: 2021-05-11T16:56:04.539Z
category: tutorial
tags:
  - open-api
  - station
comments: true
redirect: ""
canonical: ""
---
Three years ago, our documentation platform was born. Little did we know the impact that some of the design decisions that we made then were going to have now. For example, we chose to build an open-source web application using Ruby on Rails instead of static site generators for markdown files, e.g., Jekyll, Middleman, etc.

## The Story So Far

A web framework, such as Rails, was the perfect choice because they don't make assumptions about what will be built with them, which gives you the flexibility to say yes to everything.

Three years ago, we did not know what our project's scope would ultimately be as a fast-moving API company. It is hard to imagine how far our documentation platform has grown, and it is even harder to imagine what it might become in the future.

Fast forward to the present, and the tooling around the platform has increased significantly. From automated spell checking, internationalization, to API specification checks for validity and style, and the list keeps growing.

Since its inception, the platform has powered [Vonage API Developer](https://developer.nexmo.com). Vonage API Developer began its life as Nexmo Developer, and in the years since its creation, it has become a part of Vonage, the leading unified cloud communications provider globally. As a result, the demands and expectations of the platform have grown seemingly exponentially. 

That was not the end of the story of the evolution of the platform.

## The Story Continues...

Six months ago, another product team in the business reached out to us because the tool they were using for their documentation site reached its end of life. They were excited about transitioning to a simple copy of the Vonage API Developer platform, but unfortunately, it wasn't ready for them to use. Not only did the platform's code and Vonage API Developer's documentation live in the same repository, but also, some of the pages and features weren't built to support other modalities of content that were unique to that product line.

The increasing complexity of tooling needs imposed upon a single monolith Rails application, coupled with an increased interest in the platform's adoption by various product lines in Vonage, led us to search for a better alternative. 

That search was how we arrived at [Station](https://github.com/Nexmo/station).

## What Is Station?

For the past several months, we separated the prose from the platform's code. We refactored it into a content-agnostic platform that can support a plethora of content forms and media and empower other teams throughout the business. 

Station is a platform tool. By defining a few configuration files and setting the path to where your content lives, a website can be instantiated with one command from the terminal.

It is built to provide the following out of the box:

* A solution for creating text-driven content websites quickly
* The ability for everyone, regardless of programming expertise, to contribute content in a streamlined fashion
* Highly customizable to meet each site's needs through a set of configuration files

At its core, Station is a highly tailored Ruby on Rails (and Webpack) application bundled into a Ruby Gem—a reusable software package in the Ruby programming language. For the experienced Rails developer, it will feel familiar. For a person not acquainted with Rails, it will be unnecessary to learn the nuances of the framework to run or contribute content to a Station powered site.

## What Does Station Do?

A Station install supports most of the things you would expect from a content site from the get-go: render media-rich content, and OpenAPI specification files, step-by-step Tutorials, custom created web pages, Use Cases, ability to provide feedback, search for content, and the list goes on.

Not only the content, but most parts of the site can be customized with configuration files. The following snippet corresponds to the configuration file for the header and footer of the site.

![Configuration File](/content/blog/arriving-at-station-the-evolution-of-our-api-documentation-platform/config-file.png)

This is how they then get rendered on the page.

![Header](/content/blog/arriving-at-station-the-evolution-of-our-api-documentation-platform/header.png)

![Footer](/content/blog/arriving-at-station-the-evolution-of-our-api-documentation-platform/footer.png)

## What's Next?

While we are glad we built a robust platform that supports any content site and is currently powering the documentation site of two of our teams, it is still not entirely available for everyone to use.

Even though it is open-sourced, the gem is being released using Github's package registry, and the releases are not available to the public yet. However, we plan on releasing a public v1.0 soon, which will be available to everyone via Rubygems.

In upcoming posts, we'll talk about some of the toolings mentioned above, we built to keep our documentation and Open API specifications top-notch.