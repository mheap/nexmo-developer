---
title: Insights from Incorporating Static Type Checking in Ruby
description: Whilst adding static type checking to the Nexmo Ruby Client
  Library, Developer Advocate Ben Greenberg learned a lot. Here he shares those
  learnings!
thumbnail: /content/blog/lessons-learned-along-the-way-with-static-type-checking-in-ruby-dr/E_Static-Type-Checking_1200x600.png
author: ben-greenberg
published: true
published_at: 2020-03-23T16:02:04.000Z
updated_at: 2021-05-24T22:01:50.905Z
category: tutorial
tags:
  - ruby
  - sdk
comments: true
redirect: ""
canonical: ""
---
Nexmo offers SDKs in a variety of languages to support the developer community in working with our diverse API offerings. It is quite possible to interact directly with each REST API through HTTP calls that a developer custom builds. However, taking advantage of an SDK lets a developer achieve their goals faster and with less overhead in their work. 

The task therefore of crafting and iterating on each SDK is one that we as a team take very seriously. Tens of millions of API calls are made monthly through the SDKs from users throughout the globe working on initiatives that range from small hobby projects all the way to multi-national business infrastructure. 

As a result, we are continuously looking for ways to improve the developer experience with each SDK. Each SDK strives to meet the goals set forth in the [Server Library Specification](https://github.com/Nexmo/server-sdk-specification/blob/master/SPECIFICATION.md) taking into consideration the unique constraints of each language.

One of the [General Principles](https://github.com/Nexmo/server-sdk-specification/blob/master/SPECIFICATION.md#general-principles) outlined in the Specification is the following:

> Our libraries should be explicit.


This is taken to mean that ideally every class, method, constant and more should be defined and its value and its parameters known to the developers who rely on the SDK. Explicit code is easier to incorporate code, which in turn leads to code that is more straightforward to debug and to resolve inevitable issues when they arise.

In order to work towards that goal in the [Ruby SDK](https://github.com/Nexmo/nexmo-ruby) we have begun to incorporate static type checking in our codebase using the [Sorbet](https://sorbet.org/) type checker gem. The [v6.3.0 release](https://www.nexmo.com/blog/2020/02/26/nexmo-ruby-new-release-host-overriding-dr) of the SDK includes the installation and initialization of the gem and method signatures for the SMS class. 

Were there educational moments along the way of this process? Refactoring a dynamically typed codebase in a language that has always been traditionally dynamically typed produces some observations that are worth sharing. During the work for the v6.3.0 release we unearthed the following two gems:

* [Thinking Through The Interface](#thinking-through-the-interface)
* [Follow Each Method](#follow-each-method-all-the-way-through)

<h2 id="thinking-through-the-interface">Thinking Through The Interface</h2>

The Ruby SDK leverages the `private` and `protected` keywords to distinguish between different components of the architecture of the library. Code not defined within one of the aforementioned two keywords is part of the public interface.

What does that mean practically for you as a user of the SDK? It is important to frame these differentiations for several reasons. 

Namely, code defined inside the `public` interface is code that you as a user can expect to remain stable and any refactoring should not bring about breaking changes to that code without the proper notice to users and semantic version change. The classes and methods laid out within the `public` interface of the SDK are the mechanisms that you rely on directly to get your work done in your use cases. This is code that you will be interacting with directly by invoking it by name in your method calls, i.e. `client.sms.send`.

When we turn to examine our usage of the `private` and `protected` keywords, we must understand when we ought to use one or the other. 

Classically, Rubyists did not spend a lot of time worrying about these distinctions. In fact, for many their very usage was often seen as more of a "good practice" and not a "must-do" as is the case in other languages, like Java. After all, utilizing the `#send` method lets a developer circumvent the interface definition anyways and access the methods defined therein directly. Yet, when we begin integrating static typing into Ruby, these interface definitions take on more importance and they require of us more exactitude in our application of them.

In Ruby, the difference between `private` and `protected` is whether a method can be accessed outside of the scope of the class it was defined inside. Let's take a look at an example using the `private` keyword:

```ruby
class MyExample
  def public_method
    puts "This is public"
  end

  private

  def private_method
    puts "This is private"
  end
end
```

Within the above example, I can call the `#private_method` from within the `MyExample` class, but if I had another class, even if it inherited from `MyExample`, the method would not be available to it. For example, if I had a class defined as follows:

```ruby
class MySecondExample < MyExample
end
```

The private method `MyExample.private_method` would not be accessible to the scope of the `MySecondExample` class. This is true even though the second class is a subclass of the `MyExample` class.

Whereas, methods defined inside the `protected` keyword are accessible to subclasses that inherit from the parent class. Therefore, if the `private` keyword in the above example was reclassified as `protected`, then methods written therein would be accessible in the `MySecondExample` class scope.

Regardless of whether the method is within the `protected` or `private` scope, the message to developers using the SDK it conveys is that these methods are subject to change without much notice to the outside world. Any change to them should not impact the public behavior of the application. If it does, it raises questions about whether this method really does belong in a non-public interface. 

As we began integrating static type checking through the Sorbet gem, one of the first issues we encountered was the type checker reporting errors that methods could not be reached. 

For example, the `SMS` class, as do many other classes in the SDK, take advantage of the `Nexmo::Namespace#request` method to send the request to the API. Because of the inherent flexibility with the strictness of the interface definitions in Ruby, the fact that this method was defined under the `private` keyword and being used in a subclass did not prevent it from actually executing the way it was architected. Yet, in best conventions of interface design since this method was being used in a subclass implicitly it should be defined inside the `protected` keyword. As such before we redefined the interface to `protected` the type checker reported the following error:

```ruby
lib/nexmo/sms.rb:109: Method request does not exist on Nexmo::SMS https://srb.help/7003
```

One of the helpful features of Sorbet is that each error comes with a URL appended to it referencing the documentation for that error code. In this case, the documentation on error 7003 states: `This error indicates a call to a method we believe does not exist (a la Ruby’s NoMethodError exception).` The documentation continues by providing sample problem code examples and ways to address them, along with further explication of the error. In our case, I believe the second reason for why Sorbet might throw this error applied to our code:

> Even if the method exists when run, Sorbet still might report an error because the method won’t always be there.

A method defined inside the `private` interface is invisible to anything outside the scope of the class it was defined in. While it may be possible to take advantage of Ruby's flexibility to still invoke it, that doesn't ameliorate its inherent invisibility. As such, Sorbet insists on code being visible in the place that it is called from. This ensures an explicit codebase.

<h2 id="follow-each-method-all-the-way-through">Follow Each Method All The Way Through</h2>

The second gem we unearthed in the process of introducing Sorbet to the codebase was thinking deeply through all the implications of each method that is called and used in the code. 

Oftentimes, even though an application may be architected well some items may slip from our focus. A serious attempt can be given to testing both the success and failure routes of the application. The code is built to handle most of the common edge cases that may arise, but nonetheless, there may still happen unintended consequences. 

One area where this surfaced for us was the default return value for retrieving an object from a parameters hash. The code invoked `#unicode?`, a small method that checked whether the value of the object was in Unicode format or not:

```ruby
if unicode?(params[:text]) && params[:type] != 'unicode'

...

private

def unicode?(text)
  !GSM7.encoded?(text)
end
```

The `#unicode?` method would return a boolean depending on the value of the parameter. What happens though if there is no `:text` object inside the parameters? The possibility of that happening is incredibly slim during implementation, but nonetheless, from the perspective of the code, it impacts the return value of the `#unicode?` method. 

If we simulate that action with no value for `params[:text]` let's see what it returns:

```ruby
params[:text]
=> nil
```

Ruby returns `nil` when the key cannot be found inside a hash. This would, therefore, explain why Sorbet returned an error when this method was type-checked. The method signature created for the `#unicode?` method states:

```ruby
sig { params(text: String).returns(T::Boolean) }
```

The above signature declares that the method accepts an input of the `String` type and returns a value of a `Boolean` type. However, in the case where the parameter is `nil` the input becomes `nil` and not a `String`. 

At this point, there are a couple of options. One option would be to rewrite the method signature to allow for `Nilable` parameters as a method input. This would eliminate the technical problem. It would not though eliminate the underlying architectural problem that Sorbet uncovered.

The code does not want a situation where the input is `nil` ever. If the parameter is `nil`, then something is wrong. In that case, the code should actually raise an error to the user rather than continue functioning as normal. That error will improve the experience of using the SDK because it will help those developing with it to catch, diagnose and treat their bugs in their code faster and earlier in their iterative process.

Since the goal here is to address the architectural underlying issue and not the symptom, the solution is to utilize a method that does not return `nil` when there is no value provided. The call to the parameters data becomes refactored to:

```ruby
params.fetch(:text)
```

The `#fetch` method as discussed in the [Ruby API docs](https://apidock.com/ruby/Hash/fetch) will raise a `KeyError` exception if the object key cannot be found:

```ruby
KeyError (key not found: :text)
```

That exception, when returned to the user, is informative and can help guide improving their code early on in its development.

## Next Steps

Before we embarked on the process of incorporating static type checking into our Ruby SDK, we had a lot of conversation on the merits and demerits of doing so. One unknown before beginning down the path was knowing if it would lead to concrete benefits in our SDK development, and what they would be. At this point, the resolution to that unknown question is a clear affirmative yes. 

Introducing static typing to our Ruby codebase has helped focus our work as developers of the SDK into deep thinking about the implications of every design choice, method utilization and more. We have maintained a thorough review process of every pull request in our team. We take advantage of running automated integration tests, and we build tests that cover success and failure routes. The addition of static typing is a new layer of ensuring code quality and positive developer experience. 

Static typing in Ruby or any other dynamically typed language, also brings about paradigmatic shifts in the way the code is written. It enforces standardization where previously there was a lot more flexibility. This point is a controversial one in the Ruby community. What is the preferred approach? Perhaps the answer to that controversy is that it lies somewhere in the middle of the two extremes. Some flexibility preserves the magic of Ruby while increasing standardization and convention reduces the prospect of bugs or heretofore undiscovered edge cases being discovered much later in the process.

Insofar as the Nexmo Ruby SDK is concerned, we will continue to gradually implement types in the codebase over the course of the next several months. The goal is to achieve a 100% typed codebase and to do so incrementally. 

Nexmo Ruby is open-source and we welcome contributions! If you want to get involved you can find us on [GitHub](https://github.com/nexmo/nexmo-ruby)
