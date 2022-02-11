---
title: How to Use The Number Insight API with PHP
description: Find out how to use the Nexmo Number Insight API with PHP to
  validate, gain useful insight and information about any phone number.
thumbnail: /content/blog/how-to-use-number-insight-with-php-dr/Blog_PHP_Numbers-Insight_1200x600.png
author: lornajane
published: true
published_at: 2019-03-29T09:00:52.000Z
updated_at: 2021-05-20T10:07:47.516Z
category: tutorial
tags:
  - insight-api
  - php
comments: true
redirect: ""
canonical: ""
---
In this post I'll show you an example application I made recently that uses the Nexmo Number Insight API to validate and gain information about any phone number. You could either use my project as a starting point (the code is [on GitHub](https://github.com/nexmo-community/php-number-insights)), or adapt the examples here to use in your own applications. Number Insights API is ideal for checking that a phone number is valid, current, and in a particular geography so it's commonly used to verify contact details at signup time.

## Before You Begin

<sign-up number></sign-up>

This example uses PHP and a few dependencies installed via Composer. 

You will want to get the code from the [GitHub repository](https://github.com/nexmo-community/php-number-insights) - clone or download this to your development machine.

## About Number Insights API

The Number Insights API gives information about a given phone number, and is available in various levels of service with corresponding pricing levels.

The Basic level is free and is very useful to check that a number exists and is valid. Using a tool like this is great practice if you expect users to supply valid contact details because it enables you to check that this is indeed the case.

The Standard level gives everything from Basic plus information about the type of number and also the carrier it uses. With Advanced, all the above is included along with roaming and reachability information.

> The Advanced Number Insight API is also available as an asynchronous call. You can find examples of this on the [developer portal](https://developer.nexmo.com/number-insight/code-snippets/number-insight-advanced-async).

There is a good [feature comparison table](https://developer.nexmo.com/number-insight/overview#feature-comparison) available in the developer documentation.

## Set Up The Application

To begin, change into the directory where you put the project code. Use [Composer](https://getcomposer.org) to install the dependencies by running this command:

```sh
composer install
```

Copy `config.php.sample` to `config.php` and edit to add your Nexmo API key and secret (these can be found in your [dashboard](https://dashboard.nexmo.com)).

Finally, change into the `public/` directory and start the webserver:

```sh
php -S localhost:8080
```

If you visit http://localhost:8080/ in your browser, you will see a form to input the number you are interested in and what level of insight to go for.

![Screenshot of number insights form](/content/blog/how-to-use-the-number-insight-api-with-php/screenshot-form-1200x600.png)

## Number Insights API with PHP

One of the dependencies of the project is `nexmo/client`, and it makes it very easy for us to use the API from any PHP application. You've seen that I'm using SlimPHP today but the PHP library can be used in any framework or other project.

Take a look around the project structure, most of the PHP action is in `public/index.php`. The top level route simply loads a page template (look in `templates/main.php` to see it) so that the user can see the form. The form submits to `/insight` and this route is where most of the activity occurs.

```php
    $params = $request->getParsedBody();

    $basic = new \Nexmo\Client\Credentials\Basic(
        $this->config['api_key'],
        $this->config['api_secret']
    );
    $client = new \Nexmo\Client($basic);

    // choose the correct insight type
    switch($params['insight']) {
        case "standard":
            $insight = $client->insights()->standard($params['number']);
            break;
        case "advanced":
            $insight = $client->insights()->advanced($params['number']);
            break;
        default:
            $insight = $client->insights()->basic($params['number']);
            break;
    }
```

First we grab those form parameters into `$params` (this helper function is the only Slim-specific bit!), then we instantiate the `\Nexmo\Client` object and supply our API key and secret to it.

Next, there's a switch statement so that the correct Number Insights API endpoint gets called, with "basic" as the default type - because we never trust user input! It's a form, they could send us anything.

The response gets stored in `$insight` and the action passes it through to the template for display. The `$insight` value is an object, but its data fields are accessible via array notation, for example `$insight['status']` or `$insight['country_code'`. In the template, the fields are displayed in a tabular layout, showing the fields that were returned for this level of Number Insight, as shown below:

![Screenshot of the number insights output](/content/blog/how-to-use-the-number-insight-api-with-php/screenshot-with-results.png)

There is also handling for an error outcome: if `status` is non-zero, that indicates an error and the status code and message are passed through to the template and displayed there above the form. You can test this by entering an invalid phone number.

## Further Reading

Here are some places you might like to go next:

* The [API Reference docs](https://developer.nexmo.com/api/number-insight) are probably a good place to start!
* [Code Snippets](https://developer.nexmo.com/number-insight/overview#code-snippets) are available on the developer portal in other programming languages.
* For one-off number lookups, you could [use Number Insights API from the CLI](https://developer.nexmo.com/number-insight/guides/number-insight-via-cli).
* There's a tutorial on [Fraud Scoring and Phone Number Verification](https://developer.nexmo.com/tutorials/fraud-scoring-and-phone-number-verification) (warning, contains Ruby).