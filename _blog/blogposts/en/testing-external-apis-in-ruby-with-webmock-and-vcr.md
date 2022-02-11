---
title: Testing External APIs in Ruby with Webmock and VCR
description: Testing external APIs comes with certain challenges. Ruby libraries
  like Webmock and VCR can help us overcome them.
thumbnail: /content/blog/testing-external-apis-in-ruby-with-webmock-and-vcr/webmock_vcr.png
author: karl-lingiah
published: true
published_at: 2021-11-22T12:02:16.627Z
updated_at: 2021-11-18T14:57:27.773Z
category: tutorial
tags:
  - ruby
  - testing
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Automated testing has long been an integral part of the software development and deployment process, the benefits of which are well-established. Among other things, we use tests to ensure code quality, to prevent regression, and in the context of Test-Driven Development (TDD), as part of the code-writing process.

As developers, we're familiar and comfortable with the concept of writing automated test suites as part of our development workflow. When our application leverages external APIs, however, writing those tests comes with a particular set of challenges. Let's explore some of those with an example.

### Example: Sending an SMS with the Vonage Messages API

Imagine a scenario where we're developing an application that includes the functionality to send text messages via SMS. This would be an excellent use-case for the [Vonage Messages API](https://developer.vonage.com/messages/overview). In order to implement this functionality using the Messages API, our application could perhaps include a `MessagesClient` class which defines a `send_sms` method. The purpose of this method would be to send an appropriately formatted `POST` request to use the [Messages API endpoint](https://developer.vonage.com/api/messages-olympus#SendMessage):

`https://api.nexmo.com/v1/messages`

In terms of the dependencies required for testing, our `Gemfile` might look something like this (though in reality, our application would likely include some additional dependencies).

*`Gemfile`*

```ruby
# Gemfile

source "https://rubygems.org"
ruby "3.0.0"

gem 'faraday'

group :test do
  gem 'rspec'
end
```

The [Faraday](https://github.com/lostisland/faraday) gem is a Ruby library for managing HTTP requests and responses.

Our application file would define the `MessagesClient` class with its `send_sms` method.

*`app.rb`*

```ruby
# app.rb
require "json"

class MessagesClient
  URI = 'https://api.nexmo.com/v1/messages'

  def send_sms(from_number, to_number, message)
    headers = generate_headers(message)
    body = {
      message_type: 'text',
      channel: 'sms',
      from: from_number,
      to: to_number,
      text: message
    }
    Faraday.new.post(URI, body.to_json, headers)
  end

  # additional methods omitted for brevity

end
```

In the above example, our `send_sms` method defines parameters for the message text, to number, and from number. It includes these details in a message `body` which is sent in a `POST` request to the API endpoint using Faraday's `post` method. The `send_sms` method then returns an object representing the HTTP response received by the Faraday instance.

So, how would we approach testing this method? One approach for testing the happy path would be to write a test that invokes the method, thus hitting the live API endpoint, and asserting that we receive a response code that indicates success. In the case of the Messages API v1, this would be a HTTP response code of `202`.

*`messages_client_spec.rb`*

```ruby
require "spec_helper"

describe MessagesClient do
  let(:app) { MessagesClient.new }

  describe "#send_sms" do
    let(:from_number) { "447700900000" }
    let(:to_number) { "447700900001" }
    let(:message) { "Hello world!" }

    it "returns status 202 Accepted" do
      response = app.send_sms(from_number, to_number, message)

      expect(response.status).to eq 202
    end
  end
end
```

There are some issues with this testing approach.

First of all, any test that interacts with an external dependency, such as a database or external API, is likely to be much slower than one that doesn't. If we look at an example run for this test, we can see that it takes `1.63` seconds.

```terminal
Finished in 1.63 seconds (files took 0.36557 seconds to load)
1 example, 0 failures
```

While this might not *seem* that slow, this is a single test for a single method. Depending on the size and complexity of our application, we could have numerous similar tests. In such a scenario, running the entire test suite would become painfully slow.

Secondly, since our test relies on an HTTP request being sent over the network and being processed by an external dependency, we can't be certain on the fact that a valid response will be received, or indeed any response at all. There could be network issues, temporary outages, or other external factors beyond our control, which mean that we might not receive the expected response *every time* we run our test.

There's plenty of discussion on the topic of best practices for writing automated testing, and what different types of tests should and shouldn't do. Some generally agreed principles though, particularly when working with unit tests and small integration tests, is that we should try to make our tests **fast** and **deterministic**.

The further down the 'testing pyramid' we go, the more tests we have, and the more often we run them. Fast tests are therefore important at this level. Additionally, when using tests as part of the development process or for early feedback, it's important that our tests be deterministic; in other words, we want to be sure that, when provided with a specific input, the test should produce a pre-determined output.

Considering these principles in the context of our `send_sms` test presents with a problem. We want our test to be fast and deterministic, but the issues involved with hitting the live API endpoint go against those principles.

There are other possible considerations when using an external API, such as non-idempotent HTTP methods (for example, the `POST` request in our method will create an actual SMS messages will be created every time we run our test), or potential issues with costs or rate limits. Many of these additional issues could be addressed by using an API sandbox, and the Messages API [provides a sandbox](https://developer.vonage.com/messages/concepts/messages-api-sandbox) for some messaging channels.

Using a sandbox is more relevant to tests higher up the pyramid, such as end-to-end or functional tests and some larger integration test, and doesn't really solve our speed and determinism issues. What we really want for our lower level tests is a way of *not hitting the external dependency at all*. One solution to this is *mocking*.

## Mocking

For anyone not familiar with the term, mocking is a technique in testing whereby a mock or 'fake' response is used as a stand-in for a real response from an internal or external part of our application. At an internal level, this could mean a mock object being returned by a method or function call. In the context of external APIs, it will generally mean substituting a real HTTP response with a mocked one.

A big advantage of this approach when working with an external API is that, by not sending a request out over the network and waiting for the response, running a test becomes much faster. Additionally, by pre-defining the HTTP response, we make our tests deterministic.

Mocking sounds like it's ideally suited to addressing the issues we've identified with our current test set-up, so how can we implement it in our `send_sms` test?

### Introducing Webmock

[Webmock](https://github.com/bblimke/webmock) is a Ruby library for stubbing and setting expectations on HTTP requests. It supports a number of of different HTTP libraries, and can be integrated into various testing frameworks, including `rspec`.

As a high-level mental model, Webmock essentially does the following:

- Intercepts any outgoing HTTP requests made by our application
- Matches those requests against a pre-registered 'stub'
- Returns a pre-defined response for that request, in place of the actual HTTP response

Let's explore this mental model in action by adding Webmock to our test set-up.

### Updated Example: Mocking our HTTP responses with Webmock

First, we need to add `webmock` to our `Gemfile` and run `bundle install`.

*`Gemfile`*

```ruby
# Gemfile

source "https://rubygems.org"
ruby "3.0.0"

gem 'faraday'

group :test do
  gem 'rspec'
  gem 'webmock'
end
```

Note: we also need to add `require 'webmock/rspec'` to our `spec_helper`.

We can then update our test to use Webmock.

*`messages_client_spec.rb`*

```ruby
require "spec_helper"

describe MessagesClient do
  let(:app) { MessagesClient.new }

  describe "#send_sms" do
    let(:from_number) { "447700900000" }
    let(:to_number) { "447700900001" }
    let(:message) { "Hello world!" }

    it "returns status 202 Accepted" do
      stub_request(:post, "https://api.nexmo.com/v1/messages").to_return(status: 202)
      response = app.send_sms(from_number, to_number, message)

      expect(response.status).to eq 202
    end
  end
end
```

Our updated test registers a *stub*, using Webmock's `stub_request` method. The stub is set to match any `POST` request to `https://api.nexmo.com/v1/messages`, and return a `:status` of `202`.

Webmock intercepts the outgoing HTTP request, and instead returns the pre-determined response, so running our test is *much* quicker than before:

```terminal
Finished in 0.00749 seconds (files took 0.50786 seconds to load)
1 example, 0 failures
```

### Limitations of mocking

Adding Webmock has made our test fast and deterministic, and so it seems likes a good fit for our testing needs. Using a mocking tool for testing external APIs does, however, come with some caveats.

**Mocks can be time-consuming to write**

Our example mock is only defining the `:status` code for the response. Other mocks might need to also define the response  `:headers`  and/ or `:body`. Depending on the API being tested, those headers and body could be quite large and complex, and require a fair amount of time to define in the mock.

Scale that up for multiple tests against multiple API endpoints, and we could soon looking at a significant time investment for writing those mocks.

**Mocks can be difficult to maintain**

Related to this first point is *maintenance*. External APIs can change over time, adding new features or releasing new versions. For example, the Vonage Messages API [recently released a new version](https://learn.vonage.com/blog/2021/11/16/announcing-vonage-messages-api-version-1-0/). If we have a large number of complex mocks for our tests, maintaining those mocks to keep up with the changes can take a lot of time and effort that could be better invested elsewhere.

**Mocks might make incorrect assumptions about dependencies**

Since mocks are written to *represent* a particular response rather than being an *actual* response, they are necessarily based on assumptions about what that actual response would be. This might not be an issue for our example test, but as the responses we want to mock  increase in complexity, so too does the possibility of making an incorrect assumption about that response. Such incorrect assumptions could lead to code which passes the mocked test but doesn't work correctly. Hopefully we'd have tests higher up the pyramid that would identify such issues, but ideally we want to catch them as early as possible with our lower-level tests.

In order to address these limitations, we can look to another Ruby library: VCR.

## VCR

[VCR](https://github.com/vcr/vcr) is a library which follows the 'record and replay' testing pattern in the context of HTTP requests and responses. Essentially, it records a test suite's HTTP interactions and replays them during future test runs.

VCR implements this pattern using the idea of 'cassettes' (based on the cassette tapes from the obsolete [Video Cassette Recorder](https://en.wikipedia.org/wiki/Videocassette_recorder) technology). Each 'cassette' is a file, containing data which represents a recording of a specific HTTP interaction. The first time a test is run, an actual HTTP request/ response cycle occurs and the details of this cycle are recorded as a cassette.

The cassette includes information about both the request and response. The request data is used for request matching during subsequent test runs, and the response data is used for mocking the expected response for those runs. Since the 'mocks' use *actual* response data, this deals with the issues outlined earlier surrounding the time to write and maintain mocks and the assumptions made in doing so.

This way in which VCR works might be easier to visualise if we examine it in the context of our test set-up.

### Updated Example: Integrating VCR to our testing set-up

We first need to add `vcr` to our `Gemfile` and run `bundle install`

*`Gemfile`*

```ruby
# Gemfile

source "https://rubygems.org"
ruby "3.0.0"

gem 'faraday'

group :test do
  gem 'rspec'
  gem 'webmock'
  gem 'vcr'
end
```

We can then update our test to use VCR.

*`messages_client_spec.rb`*

```ruby
require "spec_helper"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

describe MessagesClient do
  let(:app) { MessagesClient.new }

  describe "#send_sms" do
    let(:from_number) { "447700900000" }
    let(:to_number) { "447700900001" }
    let(:message) { "Hello world!" }

    it "returns status 202 Accepted" do
      response = VCR.use_cassette('send_sms') do
        app.send_sms(from_number, to_number, message)
      end

      expect(response.status).to eq 202
    end
  end
end
```

In this file we require `vcr` and then configure our VCR set-up, (though if we had multiple spec files, we could move the configuration to our `spec_helper` file).

- The `cassette_library_dir` configuration tells VCR where to store the 'cassettes'. Here we specify a directory `spec/cassettes`, if this directory doesn't exist, VCR will create it.

- The `hook_into` configuration tells VCR how to hook into the HTTP requests. Since, we already have `webmock` as a dependency we specify it here (though we could remove it from our `Gemfile` and hook straight into Faraday instead).

There are also plenty of [other configuration options](https://relishapp.com/vcr/vcr/v/6-0-0/docs/configuration) available.

In the test itself, we've removed Webmock's stubbed request. Instead, we set the `response` variable to the return value of VCR's `use_cassette` method, to which we pass in a cassette name as an argument and also a block. Under the default recording configuration, if the cassette exists, VCR will use it to construct a response object that we can then assert against in our test. If the cassette doesn't exist, VCR will call the block and use what it returns to create the cassette.

When we *first* run our test, since the cassette doesn't exist at that point, we hit the API endpoint and VCR uses that HTTP interaction to create a `send_sms.yml` file, which stores details of the HTTP request and response.

*`send_sms.yml`*

```yaml
---
http_interactions:
- request:
    method: post
    uri: https://api.nexmo.com/v1/messages
    body:
      encoding: UTF-8
      string: '{"message_type":"text","channel":"sms","from":"447700900000","to":"447700900001","text":"Hello
        world!"}'
    headers:
      User-Agent:
      - Faraday v1.8.0
      Authorization:
      - Basic xxxxxxxxxxxxxxxxxxxxxxxxxxx==
      Content-Type:
      - application/json
      Host:
      - api.nexmo.com
      Content-Length:
      - '12'
      Accept-Encoding:
      - gzip;q=1.0,deflate;q=0.6,identity;q=0.3
      Accept:
      - "*/*"
  response:
    status:
      code: 202
      message: Accepted
    headers:
      Server:
      - nginx
      Date:
      - Thu, 18 Nov 2021 12:35:49 GMT
      Content-Type:
      - application/json
      Content-Length:
      - '55'
    body:
      encoding: UTF-8
      string: '{"message_uuid":"c26213be-2916-4c64-903e-4125158eedd8"}'
  recorded_at: Thu, 18 Nov 2021 12:35:49 GMT
recorded_with: VCR 6.0.0
```

When the test is first run, since we are hitting the API endpoint, the run is just as slow as when we weren't using Webmock or VCR at all.

```terminal
Finished in 1.61 seconds (files took 0.58899 seconds to load)
1 example, 0 failures
```

On all *subsequent* test runs, VCR will use the cassette. First it will check that the request details for the test execution match those recorded in the cassette. If they *do* match, then the response details from the cassette will be used to create a response object. In this case, the response code recorded is `202` and so this will be set as the `status` for our response object. Since our test is asserting that `response.status` should equal `202`, our test passes.

These subsequent test runs are also *much* quicker than the first.

```terminal
Finished in 0.01033 seconds (files took 0.55884 seconds to load)
1 example, 0 failures
```

### VCR tips and tricks

VCR provides lots of flexibility in terms of configuration options.

**Configure request matching**

In order to replay a recording, VCR needs to match new HTTP requests against the details of a previously recorded one. That [matching](https://relishapp.com/vcr/vcr/v/6-0-0/docs/request-matching) can be done against various elements of a request.

The default configuration is to match against the HTTP method and the URI, but this configuration can be amended to match the host and path separately (rather than the full URI), query parameters, request headers, and request body.

Additionally, custom matchers can be created to provide even more flexibility.

**Re-record, not fade away**

As previously mentioned, external API can change over time or release new versions, meaning that recordings can go 'out of date'. If this happens, rather than having to re-write an entire mock (as we would do with a standard mocking set-up) we can record a new HTTP interaction to replace the outdated one. There's a few ways to approach re-recording:

- The most brute-force way is to delete the file for the current recording. If no recording exists for a specific test, VCR will automatically record a new one.

- There are also various [recording modes](https://relishapp.com/vcr/vcr/v/6-0-0/docs/record-modes) that can be set to determine when new recordings are made. For example, `:once` (which is the default) only records new interactions if there is no cassette file, whereas `:new_episodes` will record a new interaction if there is an existing file for a test but the request details for that test don't exactly match those recorded in the file.

- We can enable automatic re-recording in order to re-record interactions at regular intervals. We can set the `:re_record_interval` option in the setup for a particular cassette. When that cassette is then used, VCR will check the `recorded_at` timestamp in the cassette against the current time. If more time has elapsed than specified by the `:re_record_interval`, the interaction will be re-recorded.

**Beware of sensitive data**

When interacting with an external API, depending on the authentication method for that API, we may well be including sensitive data such as API keys as part of our requests, such as in an [Authorization](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization) header. This data will be present in the VCR recording as part of the interaction. If we're also making our project code publicly available, say by pushing it to a public repository on GitHub, this can present us with a problem.

One solution might be to add individual recordings, or our entire `cassettes` directory, to a `.gitignore` file. Alternatively, we can make use of VCR's `filter_sensitive_data` [configuration option](https://relishapp.com/vcr/vcr/v/6-0-0/docs/configuration/filter-sensitive-data) to specify a substitution string for certain data, which will be shown in the recording in place of the actual data.

**Use the documentation**

VCR provides some [detailed usage documentation](https://relishapp.com/vcr/vcr/v/6-0-0/docs) for these, and many other, configuration options, as well as [API documentation](https://www.rubydoc.info/gems/vcr/frames) for the library itself.

## Alternative tools

The tools covered here are well-established within the Ruby eco-system, but there are also many alternatives available, for both Rubyists and non-Rubyists.

In terms of mocking capabilities, the `rspec-mocks` [library](https://github.com/rspec/rspec-mocks) can provide mocking capabilities to `rspec`. Some HTTP libraries such as [Faraday](https://lostisland.github.io/faraday/adapters/testing) provide adapters that let you define stubbed requests. The Faraday mocking functionality (among others) is also compatible with VCR.

Additionally, there are many ports of VCR to other programming languages, such as [vcrpy](https://github.com/kevin1024/vcrpy) for Python, [php-vcr](https://php-vcr.github.io/) for PHP, and [scotch](https://github.com/mleech/scotch) and [Betamax.Net](https://github.com/mfloryan/Betamax.Net) for .net/ C#. [Nock](https://github.com/nock/nock) provides functionality similar to the VCR and Webmock combination for Node.

There are plenty more ports to other languages listed in the VCR [README](https://github.com/vcr/vcr), so whichever language you use there should be hopefully a record and replay tool for you to use.

Happy testing!
