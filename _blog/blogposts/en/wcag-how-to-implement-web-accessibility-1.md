---
title: "WCAG: How to implement web accessibility "
description: "Learn how to improve your application's accessibility by making it
  WCAG compliant "
thumbnail: /content/blog/wcag-how-to-implement-web-accessibility/web-accessiblity_1200x627.jpg
author: yinon-oved
published: true
published_at: 2021-11-11T11:10:49.772Z
updated_at: 2021-11-08T19:14:50.242Z
category: inspiration
tags:
  - wcag
  - accessibility
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
An accessible application is one that anyone, even individuals with disabilities, can use. Unfortunately, many organizations ignore accessibility during development. Companies often perceive accessibility as a feature rather than a necessity, which results in web content accessibility guidelines (WCAG) remaining overlooked until they fade off in the backlog. Prioritizing accessibility might even feel extraneous to users we assume are non-disabled.

Accessibility, however, is not a feature: it is a social issue. Everyone has the right to access the internet, and companies need to make sure they create their applications to allow people with disabilities to use them. To help improve accessibility, organizations can educate teams, recruit in-house experts, and even get 3rd party services to support repair processes. 

Here are some things to think about when creating an accessibility strategy for your application. 

### Prioritize

WCAG defines three levels of conformance (A, AA, AAA) an organization may adopt. Most countries' laws require UX to comply with at least the first level (A).

Your company can start with level A and work your way up to higher levels. 

Product teams should include [accessibility targets](https://www.ibm.com/able/toolkit/plan/release#establishing-the-accessibility-scope-for-the-release) in each release. Each team member should take on specific tasks to ensure they set up the product for success. This process  will result in improved, sustainable accessibility.

Remember, every feature you make more accessible improves the experience for some users. You don't have to solve it all at once to improve.

### Tooling

You can use automated tools, such as tests, linters, browser addons, and IDE plugins to help find accessibility problems. 

At Vonage, we [maintain a library](https://github.com/Vonage/vivid) (Vivid), so our engineers can enjoy the benefits of UI-based components built from the ground up to meet WCAG's success criteria.

Vonage's Vivid web UI library helps you integrate the library across Vonage products and makes it easy to handle violations in a single codebase.

Here are a few other tools you may find helpful. 

* [Deque's Axe](https://www.deque.com/axe)
* [Microsoft accessibility insights](http://accessibilityinsights.io/)
* [Wave](https://wave.webaim.org/)
* [Site improve](https://siteimprove.com/) (big pile of services)
* [Pope.tech](https://pope.tech/)
* [Assistive labs](https://assistivlabs.com/) (Like BrowserStack for screen readers)

Remember that automated tools generally pick up less than 40% of errors, and they are superficial (e.g., color contrast, inputs associated with labels, and more). 

Furthermore, compliance does not equal a genuinely accessible site. You must manually test and review your code in addition to using tools. 

### Services

If you have the resources, consider using 3rd party services that review applications by actual users, some even with relevant disabilities, which will provide actual "field" data on UX failures. Here are some services you can consider using. 

* [Deque](https://www.deque.com/).
* [Level Access](https://www.levelaccess.com/).
* [Audioeye](https://www.audioeye.com/).
* [Vision Australia Digital Access](https://www.visionaustralia.org/services/digital-access).
* [Digital Accessibility Centre (DAC)](http://digitalaccessibilitycentre.org/).

### Communicate

Your application should also have an accessibility statement to: 

* Show your users that you care about accessibility and them.
* Provide them with information about the accessibility of your content.
* Demonstrate commitment to accessibility and social responsibility.

You can [learn more about developing an accessibility statement here](https://www.w3.org/WAI/planning/statements). 

Here is a [tool for generating your statement](https://www.accessibilitystatementgenerator.com/) you may find helpful. 

In addition to your accessibility statement, make sure you keep an open channel for users' feedback on your application as well. 

### Summary

Accessibility is a human right, not a feature.  

Once your organization adopts this mindset, your team will think of accessibility as a top priority, not something to push into your team's backlog. 

I encourage everyone who is starting to learn about accessibility to initiate action in their organizational environment.

Please raise any questions, arguments, concerns in the comments. I would love to hear back.

You can [reach us on Twitter](https://twitter.com/vonagedev) or [on Slack](https://developer.nexmo.com/community/slack). 

Thank you for reading!