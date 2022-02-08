---
title: How to Send SMS Messages With Elixir
description: Learn how to send SMS messages using Elixir and the Nexmo SMS API.
  With a few lines of code you get get up and started today.
thumbnail: /content/blog/how-to-send-sms-messages-with-elixir-dr/E_SMS-Elixir_1200x600.png
author: ben-greenberg
published: true
published_at: 2020-02-12T09:51:46.000Z
updated_at: 2021-04-28T13:39:49.936Z
category: tutorial
tags:
  - elixir
  - sms-api
comments: true
redirect: ""
canonical: ""
---
SMS continues to drive much of our global communication today, and with the new experimental [Nexmo Elixir SDK](https://github.com/nexmo-community/nexmo-elixir) you can get started sending SMS messages in Elixir. All you need is a Nexmo account, a virtual phone number, and a few lines of code. 

In this tutorial, we will walk through the steps to send your first SMS message in Elixir. You only need a basic understanding of Elixir to get started—we'll do the rest together!

If you prefer, you can also [clone a fully working version](https://github.com/nexmo-community/nexmo-elixir-send-sms) of this code on GitHub.

## Prerequisites

For this tutorial you will need the following:

* [Elixir](https://elixir-lang.org/) installed on your computer

<sign-up></sign-up>

## Your Nexmo Credentials and Phone Number

In order to send an SMS, you need to obtain your Nexmo API key and secret. You also need to set up a Nexmo provisioned virtual phone number. Let's do that together now.

### Your API Credentials

Once you have signed into the [Nexmo Dashboard](https://dashboard.nexmo.com), you will see your API credentials at the very top of the page.

![API credentials in the Vonage Developer Dashboard](/content/blog/how-to-send-sms-messages-with-elixir/elixir-api-credentials.png "API credentials in the Vonage Developer Dashboard")

Take note of them and save them somewhere safe, we will be using them in just a moment.

### Your Virtual Phone Number

Our next step in getting ready to send an SMS is to provision a virtual phone number. From the Nexmo Dashboard, you will see a drop-down link called `Numbers` in the left sidebar. When you click on it, the drop-down will expand and you will see several options. Click on the option entitled `Buy Numbers`.

![Buy numbers menu option](/content/blog/how-to-send-sms-messages-with-elixir/elixir-buy-numbers-sidebar.png "Buy numbers menu option")

Once you navigate to the `Buy Numbers` section you will be able to search for a phone number based on `Country`, `Features`, `Type`. You can also narrow it down to display only phone numbers with specific combinations of numbers.

![Buy Numbers interface](/content/blog/how-to-send-sms-messages-with-elixir/elixir-buy-numbers-search.png "Buy Numbers interface")

Search for a phone number with a country code that is convenient for you. You only need `SMS` for `Features` and a `Type` of `Mobile`. After you click on the `Search` button, you will see a list of potential numbers. You can choose any you like by clicking the orange colored `Buy` button on the right-hand side.

![Buy number buttons in list of available numbers](/content/blog/how-to-send-sms-messages-with-elixir/elixir-buy-number-button.png "Buy number buttons in list of available numbers")

You have now successfully provisioned a Nexmo virtual phone number. As you did with your API credentials, copy your new phone number somewhere safe. We will be using it in our next step as we send our first SMS with Elixir.

## Sending an SMS With Elixir

### Setting up Our Code Structure

From your terminal create a new directory to house your Elixir project, then navigate into that directory. For the sake of this tutorial, we will call it `send-sms-elixir`.

```bash
mkdir send-sms-elixir

cd send-sms-elixir
```

We will need three files for our project. As a reminder, if you are planning to commit this project to public version control, make sure you do not check in your `.env` file, as it contains your sensitive credential information. 

```bash
touch mix.exs send-sms.ex .env
```

Once you are finished you should have three files inside your `./send-sms-elixir` folder:

```
├── mix.exs
├── send-sms.ex
├── .env
```

### Defining Our Mix File

Every Elixir project that has an external dependency needs to create a Mix file that installs that dependency into your project. Mix, for those unfamiliar, is similar to Bundler in Ruby or npm in Node.js. 

Within our `mix.exs` file we will define the name of our project and two dependencies, which are the experimental Nexmo Elixir SDK and Envy, a Hex package that helps us manage our environment variables:

```elixir
defmodule SendSms.Mixfile do
  use Mix.Project

  def project do
    [app: :send_sms,
     version: "0.0.1",
     deps: deps]
  end

  defp deps do
     [
       {:nexmo, "0.4.0", hex: :nexmo_elixir},
       {:envy, "~> 1.1.1"}
     ]
  end
end
```

### Defining Our Environment Variables

We previously created our Nexmo virtual phone number and obtained our Nexmo API credentials. Now we are going to integrate them into our application by storing them in our `.env` file. Inside your `.env` file put the following, supplying your API key, API secret, and Nexmo phone number in the appropriate places:

```
NEXMO_API_KEY=
NEXMO_API_SECRET=
NEXMO_NUMBER=
SMS_API_ENDPOINT="https://rest.nexmo.com/sms/json"
```

In addition to our API key, secret and phone number, we also provide the Nexmo SMS API endpoint in our `.env` file to be used by the SDK. 

### Defining Our Elixir Code

Now we are ready to create the code that will send our first SMS! Open up the `send_sms.ex` file and add the following:

```elixir
defmodule SendSms do
  use Application

  def start(_type, _args) do
    unless Mix.env == :prod do
      Envy.auto_load
    end
  end

  def send_msg(to_number, message)
    Nexmo.Sms.send(
      from: System.get_env("NEXMO_NUMBER"),
      to: to_number,
      text: message
    )
  end
end
```

In the above, we define a module called `SendSms` that has a `SendSms.start/2` function that loads our environment variables from the `.env` file using the Envy package. 

Then we create a second function called `SendSms.send/2` that accepts an argument of the recipient number we wish to send the text to and the actual message. Within the function, we call the Nexmo Elixir SDK `Nexmo.Sms.send/1` function and pass in our Nexmo virtual number (stored as an environment variable), the `to_number`, and the `message`.

That's it! We are now ready to run our code and send the message.

### Running The Application

The simplest way for you to run your application and send an SMS is to load your project in iex, an interactive Elixir shell.

Let's first compile our `send_sms.ex` file, which will make the `send_msg/2` function available inside the shell. To compile it all we need to do is run from the command line: `elixirc send_sms.ex`. That should only take a moment, and once it is finished we can run our application inside iex.

To run your project in iex from your command line execute the following: `iex -S mix`. This will start your project and launch it inside the shell.

You will see a shell prompt that looks like this:

```
Interactive Elixir (1.9.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 
```

At this point, you can send your SMS!

```
iex(1)> SendSms.send_msg(RECIPIENT_NUMBER, "This is powered by Nexmo on Elixir!")
```

You will receive back from the Nexmo SMS API confirmation that you sent the message successfully with an HTTP status code of 200.

Congratulations, you did it!

## Further Reading

If you are interested in exploring more on SMS and Nexmo, feel free to check out the following:

* [SMS API Overview](https://developer.nexmo.com/messaging/sms/overview)
* [Receiving Concatenated SMS](https://developer.nexmo.com/use-cases/receiving-concat-sms)
* [SMS API Reference](https://developer.nexmo.com/api/sms)