---
title: Befriending Service with Symfony and Vonage
description: With the current global situation, most countries are in some form
  of lockdown. Social distancing is critical right now to reduce the impact of
  Covid-19. While some of us may have packed calendars of virtual hangouts,
  others may not have such a large pool of people to call or connect with to
  pass the time. […]
thumbnail: /content/blog/befriending-service-with-symfony-and-vonage/Blog_Befriending_Symfony_Voice-Verify_1200x600.png
author: greg-holmes
published: true
published_at: 2020-06-08T15:03:16.000Z
updated_at: 2021-04-19T11:04:10.688Z
category: tutorial
tags:
  - php
  - verify-api
  - voice-api
comments: true
redirect: ""
canonical: ""
old_categories:
  - developer
  - tutorial
---
With the current global situation, most countries are in some form of lockdown. Social distancing is critical right now to reduce the impact of Covid-19.
While some of us may have packed calendars of virtual hangouts, others may not have such a large pool of people to call or connect with to pass the time. My grandmother, for example, isn't very technical, so is reliant on phone calls. Although she is lucky enough to have thirteen grandchildren, she often says she hasn't heard from anyone some days and would like to speak to someone daily. At Vonage, we have regular opportunities to build something for our learning. In this opportunity, I chose to create a befriending service, which would introduce users that are vulnerable, lonely, or want a different person to talk to daily. The idea behind this is to enable people to make new friends while in lockdown, or at any time.

## Prerequisites

* Two active phone numbers (For testing)
* [Docker](https://www.docker.com/)
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Yarn](https://yarnpkg.com/getting-started)

<sign-up number></sign-up>

## Getting Started

Through this tutorial, you will build a new PHP project using [Symfony](https://symfony.com/). You will use [Vonage Verify](https://www.vonage.com/communications-apis/verify/), [Vonage Voice](https://www.vonage.com/communications-apis/voice/) and [MapQuest](https://www.mapquest.com/) APIs. This project, once complete, will provide a service to allow users to register with their phone number, name, town, and county/state. On registration, the user will receive a verification code, which they are required to input into the website. Once verified, users get added to a list of people that each day, will receive a phone call, connected to another user to converse with. Finally, at the end of each day, each user will again receive an automated call requesting feedback regarding the call they'd had on that day.

### Clone the Repository

The project uses the [Docker](https://www.docker.com/) containers [Nginx](https://www.nginx.com/), [MySQL](https://www.mysql.com/), [PHP](https://www.php.net/), and [Ngrok](https://ngrok.com/) containers for minimal server configuration changes.

Start this tutorial by cloning the existing repository. Cloning can be done by copying the following command into your Terminal, and then changing directory the project directory:

```bash
git clone git@github.com:nexmo-community/befriending-service-with-symfony.git
cd befriending-service-with-symfony
```

Your Terminal will output two directories:

* `docker` where your Docker configurations are found (No need to change anything, unless you're setting different database credentials)
* `project` which is where your fresh [Symfony](https://symfony.com/) project is stored

### Run Docker

In your Terminal, change directory to the `docker/` directory and run the following command to build and start your docker containers:

```bash
docker-compose up -d
```

The command above downloads all of the preconfigured `Docker` containers, adding any custom changes defined in the files found within the `docker/` directory. Build then compiles these containers and runs them as services for you to run your web application.

Once the command has completed, you will see a confirmation that the `Docker` containers are running, as shown in the example below:

![Successfully Running Docker](/content/blog/befriending-service-with-symfony-and-vonage/docker-up.png)

Your docker containers and servers are now ready for development to begin!

## The Application

### User Registration and Verification

#### Install Symfony

If you look in the `project` directory, you'll see the file structure of an empty Symfony installation the same as below:

![Fresh Symfony Installation](/content/blog/befriending-service-with-symfony-and-vonage/fresh-symfony-structure.png)

Still within the docker/ directory, run the command below to install all of the PHH libraries described in the composer.json file:

```bash
docker-compose exec php composer install
```

The database configs for this Symfony project need to be stored somewhere. So in your IDE, under the `project/` directory, create a new file called `.env.local`. Once created, add the following line to this new file:

```env
DATABASE_URL=mysql://user:password@mysql:3306/befriending?serverVersion=8.0.17&charset=utf8
```

A description of a breakdown of the line above is listed below:

* Database name: `befriending`
* Database User: `user`
* Database Password: `password`
* Database Host and Port: `mysql:3306`

These are values preset inside the `docker/docker-compose.yml` file. The current username and password are not secure, for security purposes, if you wish to change these please do so in both `project/.env.local` and `docker/docker-compose.yml`, then run:

```bash
docker-compose build
```

#### Create a User Entity

A `User` entity is needed, which is the class that correctly defines the structure of the `user` database table. This table is the table where new user registrations get stored.

To do this, Symfony has released a `make` library, which allows users to use the Command Line Interface (CLI) to create certain classes.

Run the command below and follow the instructions listed to create the properties for the `User` entity:

```bash
docker-compose exec php bin/console make:entity
```

* Class name of the entity to create or update (e.g. DeliciousGnome):

  * `User`
* Property 1

  * Name: `phoneNumber`
  * Type: `string`
  * Field Length: `255`
  * Can Be Null?: `no`
* Property 2

  * Name: `name`
  * Type: `string`
  * Field Length: `255`
  * Can Be Null?: `no`
* Property 3

  * Name: `town`
  * Type: `string`
  * Field Length: `255`
  * Can Be Null?: `no`
* Property 4

  * Name: `county`
  * Type: `string`
  * Field Length: `255`
  * Can Be Null?: `no`
* Property 5

  * Name: `countryCode`
  * Type: `string`
  * Field Length: `2`
  * Can Be Null?: `no`
* Property 6

  * Name: `verificationRequestId`
  * Type: `string`
  * field Length: `255`
  * Can Be Null?: `yes`
* Property 7

  * Name: `verified`
  * Type: `boolean`
  * Can Be Null?: `no`
* Property 8

  * Name: `active`
  * Type: `boolean`
  * Can Be Null?: `no`

On completion of this command, two new files get created:

* `project/src/Entity/User.php`
* `project/src/Repository/UserRepository.php`

The `UserRepository` is a repository class where developers will find custom queries for the `User` entity. Ignore this class for now.

The entity created, is doesn't currently reflect what's in the database. To make the database reflect what you've defined in the `User` entity, run the command below to generate a new migration file:

```bash
docker-compose exec php bin/console make:migration
```

If you wish to see the upcoming database changes, the generated migration files get saved to `project/src/Migrations/`.

So long as you're happy with these changes, to persist them to the database, run the command below:

```bash
docker-compose exec php bin/console doctrine:migrations:migrate
```

The `User` entity still needs some further changes that couldn't happen with the `maker` CLI. To make these changes open this class, which you can find in `project/src/Entity/User.php`.

First, a class `UniqueEntity` is used as an annotation to ensure one of the properties in your User class is Unique (so only one entry with that value). Add this class at the top:

```diff
use Doctrine\ORM\Mapping as ORM;
+ use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
```

Add the following two lines:

```diff
/**
 * @ORM\Entity(repositoryClass="App\Repository\UserRepository")
 + * @ORM\Table(name="`user`")
 + * @UniqueEntity("phoneNumber")
 */
```

The first alteration you've made is adding a hardcoded annotation for the table name. The reason is the word `user` is a keyword in MySQL. So the system needs the `user` table name wrapped in quotes to ensure whenever a query is made this change stops the code from mistaking the table name for the keyword.

The second change is adding the property `phoneNumber` as a `UniqueEntity`. Using `UniqueEntity` will stop the chance of multiple users having the same phone number.

Now, update the definition of the `phoneNumber` property to be a unique field:

```diff
/**
-  * @ORM\Column(type="string", length=255)
+  * @ORM\Column(type="string", length=255, unique=true)
 */
private $phoneNumber;
```

The final change to the `User` entity is to ensure `active`, and `verified` fields are defaulted to false so create a `__construct()` function to do this:

```php
public function __construct()
{
    $this->setActive(false);
    $this->setVerified(false);
}
```

You've now created a new User entity, which is how the system creates new users, as well as saving and editing users to the database.

#### Install Webpack Encore

Bootstrap is used in this tutorial to make the designs of the pages better designed and laid out. Symfony recently released Webpack Encore, which is a much simpler way to integrate Webpack into your Symfony or PHP application. To install Webpack Encore, run the following commands:

```bash
docker-compose exec php composer require symfony/webpack-encore-bundle
cd ../project/
yarn install
```

Running the `yarn install` command will set up the project to handle Javascript files too. This command creates an `assets` directory, and within this directory, there is a `js/app.js` file and a `css/app.css` file.

Now Bootstrap is installed with the following command:

```bash
yarn add bootstrap --dev
```

The Symfony application doesn't know Bootstrap exists yet. To include this into the project, open the `project/assets/css/app.scss` file and add the following line:

```css
@import "../../node_modules/bootstrap";
```

Bootstrap JS required jQuery and PopperJs, so install these with the command below:

```bash
yarn add jquery popper.js --dev
```

Again, the Symfony application doesn't know what jQuery and PopperJs are. So include them into the project by opening the `project/assets/js/app.js` file and adding the following updates to it:

```diff
import '../css/app.css';
+ import $ from 'jquery';

+ require('bootstrap');
```

These CSS and JS files need compiling to get accessed in the templates. To do this run the following command:

```bash
yarn run dev
```

The required frontend parts are installed and configured!

#### Install Vonage SDK and libphonenumber-for-php

This tutorial requires two further PHP libraries:

* the Vonage SDK,

  * to send verification requests,
  * verify users
  * make phone calls
  * handle DTMF phone call input.
* Giggsey's libphonenumber-for-php, which manipulates phone numbers into internationalized or nationalized formats.

To install the Vonage PHP SDK run:

```bash
# Note, if you're not inside the `docker` directory in your terminal run this command first:
# cd ../docker/

docker-compose exec php composer require nexmo/client
```

To use environment variables from the file you'll create in the next step, Symfony's `DotEnv` component is needed. To install this component run the following command from your Terminal:

```bash
docker-compose exec php composer require symfony/dotenv
```

On the [Vonage Developer Dashboard](https://dashboard.nexmo.com/getting-started-guide), you'll find "Your API credentials", make a note of these.

Within the `project/` directory, add the following three lines to the `.env.local` file (replacing the api_key and api_secret with your key and secret):

The `VONAGE_BRAND_NAME` is the name of the company/brand you're representing for the verification:

```env
VONAGE_API_KEY=<api_key>
VONAGE_API_SECRET=<api_secret>
VONAGE_BRAND_NAME=Befriending
```

A way to verify telephone numbers are valid before making the verification check is needed. You also need to make sure the phone number is in the correct format for the Verify API to know which region (country code) the number belongs to). You're going to use [Giggsey's PHP port of Google libphonenumber](https://packagist.org/packages/giggsey/libphonenumber-for-php) to make sure phone numbers are formatted correctly.

Run the command below to install `libphonenumber-for-php`:

```bash
docker-compose exec php composer require giggsey/libphonenumber-for-php
```

You now have the two key libraries needed to:

* Format phone numbers,
* Ensure phone numbers are valid,
* Verify with Vonage Verify API
* Make phone calls

#### Build the Verify Util

Create a new directory inside `project/src/` called `Util`, and within this new directory, create a new file called `VonageVerifyUtil.php`. This new file is the utility class that contains the functionality to verify users when they register. Inside this new file copy the code below:

```php
<?php

namespace App\Util;

use App\Entity\User;
use Nexmo\Client as VonageClient;
use Nexmo\Client\Credentials\Basic;
use Nexmo\Verify\Verification;

class VonageVerifyUtil
{
    /** @var VonageClient */
    protected $client;

    public function __construct()
    {
        $this->client = new VonageClient(
            new Basic(
                $_ENV['VONAGE_API_KEY'],
                $_ENV['VONAGE_API_SECRET']
            )
        );     
    }
}
```

Add two new methods to this class. The purpose of these two methods is to:

* convert the telephone number to an internationalized format.
* convert the telephone number to a nationalized number format.

```php
public function getInternationalizedNumber(User $user): ?string
{
    $phoneNumberUtil = \libphonenumber\PhoneNumberUtil::getInstance();

    $phoneNumberObject = $phoneNumberUtil->parse(
        $user->getPhoneNumber(),
        $user->getCountryCode()
    );

    if (!$phoneNumberUtil->isValidNumberForRegion(
        $phoneNumberObject,
        $user->getCountryCode())
    ) {
        return null;
    }

    return $phoneNumberUtil->format(
        $phoneNumberObject,
        \libphonenumber\PhoneNumberFormat::INTERNATIONAL
    );
}

public function getNationalizedNumber(string $phoneNumber)
{
    $phoneNumberUtil = \libphonenumber\PhoneNumberUtil::getInstance();
    $phoneNumberObject = $phoneNumberUtil->parse($phoneNumber);

    return '0' . $phoneNumberObject->getNationalNumber();
}
```

The next function the system needs is to make the verification request for new registrations. Add the method below to do process the creation of a verification request:

```php
public function sendVerification(User $user)
{
    $internationalizedNumber = $this->getInternationalizedNumber($user);

    if (!$internationalizedNumber) {
        return null;
    }

    $verification = new Verification(
        $internationalizedNumber,
        $_ENV['VONAGE_BRAND_NAME'],
        ['workflow_id' => 2]
    );

    return $this->client->verify()->start($verification);
}
```

**note** if you're interested in a different workflow for the verification process, please look at the [Vonage documentation](https://developer.nexmo.com/verify/guides/workflows-and-events).

The next step to verifying is to take users input of the verification code and send a request to verify with the verification code:

```php
public function verify(string $requestId, string $verificationCode)
{
    $verification = new Verification($requestId);

    return $this->client->verify()->check($verification, $verificationCode);
}
```

The last function isn't used in this utility class but will be in several places of the project. This function extracts the `requestId` from an API response. Add the following:

```php
public function getRequestId(Verification $verification): ?string
{
    $responseData = $verification->getResponseData();

    if (empty($responseData)) {
        return null;
    }

    return $responseData['request_id'];
}
```

### Create a new user

To create a new `Register` controller with Symfony's `make` library, run the command below:

```bash
docker-compose exec php bin/console make:controller
```

Where it says: `Choose a name for your controller class (e.g. AgreeableGnomeController):` type `RegisterController` and press enter.

You will see the output in your Terminal for two new generated files:

```
created: src/Controller/RegisterController.php
created: templates/registration/index.html.twig
```

The `VonageVerifyUtil` needs injecting as a service into the newly created `RegisterController` so open the file `src/Controller/RegisterController.php` and inject it in the `__construct()` function.

```diff
+ use App\Util\VonageVerifyUtil;

class RegisterController extends AbstractController
{
+     /** @var VonageVerifyUtil */
+     protected $vonageVerifyUtil;

+     public function __construct(VonageVerifyUtil $vonageVerifyUtil)
+     {
+         $this->vonageVerifyUtil = $vonageVerifyUtil;
+     }
```

In your browser, open the `register` page with the URL [http://localhost:8081/register](http://localhost:8081/register/). You get greeted with:

![The view in a web page showing the default RegisterController output](/content/blog/befriending-service-with-symfony-and-vonage/register-view.png)

It's time to create the Register page!

Symfony's `make` library is proving to be very useful, so far it has created an `Entity`, a `Controller`, and now it's going to create a `Form`. To create the `UserType` form, run the following command:

```php
docker-compose exec php bin/console make:form
```

When it asks for a name, enter `UserType`, and when it asks for an `Entity` type: `User`.

You will find the newly created `UserType` in `project/src/Form/UserType.php`. Open it, locate the `buildForm()` function and replace its contents with:

```php
$builder
    ->add('phoneNumber', TelType::class, [
        'attr' => [
            'class' => 'form-control form-control-lg'
        ]
    ])
    ->add('name', TextType::class, [
        'constraints' => [
            new NotBlank(),
            new Length(['min' => 3]),
        ],
        'attr' => [
            'class' => 'form-control form-control-lg'
        ],
    ])
    ->add('town', TextType::class, [
        'constraints' => [
            new NotBlank(),
            new Length(['min' => 3]),
        ],
        'attr' => [
            'class' => 'form-control form-control-lg'
        ],
    ])
    ->add('county', TextType::class, [
        'constraints' => [
            new NotBlank(),
            new Length(['min' => 3]),
        ],
        'attr' => [
            'class' => 'form-control form-control-lg'
        ],
    ])
    ->add('countryCode', ChoiceType::class, [
        'label' => false,
        'attr' => [
            'class' => 'form-control form-control-lg'
        ],
        'choices' => [
            "United Kingdom" => "GB",
            "United States" => "US"
        ]
    ])
    ->add('submit', SubmitType::class, [
        'label' => 'Sign up',
        'attr' => [
            'class' => 'btn btn-info btn-lg btn-block'
        ],
    ])
;
```

At the top of the class, several new classes will need to be included, `ChoiceType`, `SubmitType`, `Length`, `NotBlank`, `TelType`, `TextType`. Add these to the top of the file, as shown below:

```diff
use App\Entity\User;
use Symfony\Component\Form\AbstractType;
+use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
+use Symfony\Component\Form\Extension\Core\Type\SubmitType;
+use Symfony\Component\Form\Extension\Core\Type\TelType;
+use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
+use Symfony\Component\Validator\Constraints\Length;
+use Symfony\Component\Validator\Constraints\NotBlank;
```

#### Create Registration Template

The base template needs to include Bootstrap for our Bootstrap CSS classes to be recognised and displayed.

Open `project/templates/base.html.twig`, the base template that will be included by all other templates in the project, and replace the contents with:

```twig
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>{% block title %}Welcome!{% endblock %}</title>
        {% block stylesheets %}
            {{ encore_entry_link_tags('app') }}
        {% endblock %}
    </head>
    <body>
        <nav class="navbar navbar-dark bg-dark navbar-expand-lg">
            <a class="navbar-brand" href="#">Welcome</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
        </nav>
        <div class="container-fluid h-100">
            {% block body %}{% endblock %}
        </div>
        {% block javascripts %}
            {{ encore_entry_script_tags('app') }}
        {% endblock %}
    </body>
</html>
```

Now that the template has Bootstrap included, time to update the `index.html.twig` template to display our form and any other information. Open `project/templates/register/index.html.twig` and replace everything in between `{% block body %}` and `{% endblock %}` with:

```twig
<div class="row justify-content-center align-items-center h-100">
    <div class="col col-sm-6 col-md-6 col-lg-4 col-xl-3">
        {{ form_start(form) }}
            <h1 class="h3 mb-3 font-weight-normal">Sign up</h1>
        {{ form_end(form) }}
    </div>
</div>
```

#### Complete Registration Process

You've now built a template and a form class, but the project currently uses neither of these files. You need to include these into your `RegisterController` method called `index()`. Head back to `project/src/Controller/RegisterController.php`.

Update the contents of the method `index()` as shown below:

```diff
/**
 * @Route("/register", name="register")
 */
-public function index()
+public function index(Request $request)
{
+ $user = new User();
+
+ $form = $this->createForm(
+     UserType::class,
+     $user
+ );
+ $form->handleRequest($request);
+
+ if ($form->isSubmitted() && $form->isValid()) {
+    $entityManager = $this->getDoctrine()->getManager();
+    $entityManager->persist($user);
+    $entityManager->flush();
+
+    $verification = $this->vonageVerifyUtil->sendVerification($user);
+    $requestId = $this->vonageVerifyUtil->getRequestId($verification);
+
+    if ($requestId) {
+        $user->setVerificationRequestId($requestId);
+        $entityManager->flush();
+    }
+ }
+
  return $this->render('register/index.html.twig', [
+    'controller_name' => 'RegisterController',
+    'form' => $form->createView(),
  ]);
}
```

The changes in the example above do the following:

* Creates a new empty `User` object,
* Creates a new instance of the `UserType` form class using the new User object as the data class with which to structure the form with,
* Handles the form request to determine whether the form:

  * has been submitted,
  * form content is valid (for example, whether `phoneNumber` is empty, is not unique)
* If the form is submitted and valid, then the function:

  * persists the new user to the database
  * flushes these changes
  * Sends a new request to the `Verify` API,
  * saves the verification request id to the user record in the database
* If the form hasn't been submitted or isn't valid the function renders the template to the user, with the form included into the template.

Several classes need importing into the current class, such as `User` and `UserType`, include those at the top as shown below:

```diff
+use App\Entity\User;
+use App\Form\UserType;
use App\Util\VonageVerifyUtil;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
+use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
```

To summarise, you've just created a new `RegisterController`, a `User` entity and `UserType` form. You've updated your template for the `index()` method inside the `RegisterController` to display the form fields you're expecting the user to see.

You can see these changes on `http://localhost:8081/register`, or as shown in the example below:

![Template of registration page being displayed in a web browser](/content/blog/befriending-service-with-symfony-and-vonage/registration-page.png)

#### Create Verify Form

Create the `VerifyType` form with the following command:

```bash
docker-compose exec php bin/console make:form
```

For the name input: `VerifyType`
And for which Entity to use, choose `User`

On submission, you'll see something as shown in the image below:

![Terminal output confirming creation of VerifyForm class](/content/blog/befriending-service-with-symfony-and-vonage/verify-form-creation.png)

Creating the `VerifyType` form this way means that the system has automatically inserted all of the `User` entity properties into this form. None of these fields are required, so update the code with the following:

```diff
$builder
-    ->add('phoneNumber')
-    ->add('name')
-    ->add('town')
-    ->add('county')
-    ->add('countryCode')
-    ->add('verificationRequestId')
-    ->add('verified')
-    ->add('active')
+->add('verificationCode', TextType::class, [
+    'mapped' => false,
+    'attr' => [
+        'class' => 'form-control form-control-lg'
+    ],
+    'constraints' => [
+        new NotBlank([
+            'message' => 'Please enter a verification code',
+        ]),
+        new Length([
+            'min' => 4,
+            'max' => 4,
+            'minMessage' => 'The verification code is a 4 digit number.',
+        ]),
+    ],
+])
+->add('submit', SubmitType::class, [
+    'label' => 'Verify',
+    'attr' => [
+        'class' => 'btn btn-info btn-lg btn-block'
+    ],
+])
;
```

The above code defines the form that is expected for submitting a verification code. This form contains two fields, the `verificationCode` and `submit`. Each field has its unique attributes for validation and display purposes on the form or submission of the form.

At the top of the class, some class imports need importing. So copy the code in the top of the class, as shown below:

```diff
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
+use Symfony\Component\Form\Extension\Core\Type\SubmitType;
+use Symfony\Component\Form\Extension\Core\Type\TextType;
+use Symfony\Component\Validator\Constraints\Length;
+use Symfony\Component\Validator\Constraints\NotBlank;
```

#### Handle Verification

So, you've built your registration page, but what next? You need to create a page for the user to input the verification code they receive from the `Verify` API. Inside the `RegisterController` create a new method below the `index()` one called `verify()`. The example below shows this and the contents of that method:

```php
/**
 * @Route("/register/verify/{user}", name="app_register_verify")
 * @ParamConverter("user", class="App:User")
 */
public function verify(Request $request, User $user): Response
{
    $form = $this->createForm(VerifyType::class, $user);
    $form->handleRequest($request);

    if ($form->isSubmitted() && $form->isValid()) {
        $verify = $this->vonageVerifyUtil->verify(
            $user->getVerificationRequestId(),
            $form->get('verificationCode')->getData()
        );

        if ($verify instanceof Verification) {
            $user->setVerificationRequestId(null);
            $user->setVerified(true);
            $user->setActive(true);

            $entityManager = $this->getDoctrine()->getManager();
            $entityManager->flush();
        }
    }

    return $this->render('register/verify.html.twig', [
        'form' => $form->createView(),
    ]);
}
```

At the top of the class, include the `Response`, `VerifyType`, `ParamConverter`, and `Verification` classes as shown below:

```diff
use App\Entity\User;
use App\Form\UserType;
use App\Util\VonageVerifyUtil;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
+use Nexmo\Verify\Verification;
+use Symfony\Component\HttpFoundation\Response;
+use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
+use App\Form\VerifyType;
```

The template to display this form is now needed. Create a new file in `project/templates/register/` called `verify.html` and copy the contents of the code block below into this file:

```twig
{% extends 'base.html.twig' %}

{% block title %}Verify{% endblock %}

{% block body %}
    <div class="row justify-content-center align-items-center h-100">
        <div class="col col-sm-6 col-md-6 col-lg-4 col-xl-3">
            <h1 class="h3 mb-3 font-weight-normal">Verify</h1>

            {{ form_start(form) }}
                <div class="form-group">
                    {{ form_row(form.verificationCode) }}
                </div>

            {{ form_end(form) }}
        </div>
    <div>
{% endblock %}
```

#### Handling a Successful Verification

Within the `RegisterController` the project now needs a success page for when the user has successfully verified. Creating a new `registerSucess()` method, which will display a template with the message output that the registration was successful:

```php
/**
 * @Route("/register/success", name="app_register_success")
 */
public function registerSuccess(): Response
{
    return $this->render('register/success.html.twig');
}
```

Now create a new file in `project/templates/register/` called `success.html.twig` and output the following:

```twig
{% extends 'base.html.twig' %}

{% block title %}Registration Successful!{% endblock %}

{% block body %}
    <div class="row justify-content-center align-items-center h-100">
        <div class="col col-sm-6 col-md-6 col-lg-4 col-xl-3">
            <h1 class="h3 mb-3 font-weight-normal">Sign up Successful!</h1>

            <p>Thank you for verifying your phone number.</p>

            <p>Your details have been added to the database to participate in the Befriending Service.</p>

            <p>You will be automatically contacted at 2pm every day and connected with another user in the system.</p>
        </div>
    </div>
{% endblock %}
```

There are a few small changes needed to finalise the verification part. Redirects are required when each form submission is successful in moving the user on to the next page. So, in `RegisterController`, under `public function index()`, find and add the following:

```diff
if ($requestId) {
    $user->setVerificationRequestId($requestId);
    $entityManager->flush();

+    return $this->redirectToRoute('app_register_verify', ['user' => $user->getId()]);
}
```

And inside the method `public function verify(Request $request, User $user)`, find and add the following:

```diff
if ($verify instanceof Verification) {
    $user->setVerificationRequestId(null);
    $user->setVerified(true);

    $entityManager = $this->getDoctrine()->getManager();
    $entityManager->flush();

+    return $this->redirectToRoute('app_register_success');
}
```

#### Latitude and Longitude

In preparation for finding registered users geographically close to other registered users, the system needs to have the latitude and longitude of each user, on registration. The project will use a service called `MapQuest`, which takes the Town and County/State of the user and converts it into the required latitude and longitude.

Register for an account on: [MapQuest](https://developer.mapquest.com/).

Open `.env.local` and add the following new entries (replacing <api_key> with your MapQuest API key):

```env
MAP_QUEST_API_KEY=<api_key>
MAP_QUEST_API_URL=https://www.mapquestapi.com/geocoding/v1/
```

The `User` entity needs two properties to store the latitude and longitude. To update this entity, run Symfony's `make` command as shown below, and follow the instructions:

```bash
docker-compose exec php bin/console make:entity
```

* Class name of the entity to create or update (e.g. DeliciousGnome):

  * `User`
* Property 1

  * Name: `latitude`
  * Type: `decimal`
  * Precision: 20
  * Scale: 16
  * Can Be Null?: `yes`
* Property 2

  * Name: `longtitude`
  * Type: `decimal`
  * Precision: 20
  * Scale: 16
  * Can Be Null?: `yes`

Running the command below will generate a new migration file with these database changes:

```bash
docker-compose exec php bin/console make:migration
```

If you wish to see the upcoming database changes, the generated migration files get saved to `project/src/Migrations/`.

So long as you're happy with these changes, to persist them to the database, run the command below:

```bash
docker-compose exec php bin/console doctrine:migrations:migrate
```

Guzzle is a PHP HTTP client that allows projects to make requests to other web services, such as POST and GET requests to APIs. Guzzle makes it easy to make a GET request to Map Quest's API endpoint to receive latitude and longitudes of the user's location.

The next step is to create a `MapQuestUtil` to make this GET request and handle the response to only retrieve the required fields. Create a new file in `project/src/Util/` called `MapQuestUtil.php` and copy the following code into the newly created file:

```php
<?php

namespace App\Util;

use App\Entity\User;
use App\Util\MapQuestUtil;
use GuzzleHttp\Client as GuzzleClient;

class MapQuestUtil
{
    public function getLatLongByAddress(User $user): ?array
    {
        $client = new GuzzleClient(
          ['base_uri' => $_ENV['MAP_QUEST_API_URL']]
        );

        $response = $client->request(
            'GET',
            'address', [
                'query' => [
                    'key' => $_ENV['MAP_QUEST_API_KEY'],
                    'inFormat' => 'kvp',
                    'outFormat' => 'json',
                    'location' => $user->getTown() . ',' . $user->getCounty(),
                    'thumbMaps' => 'false'
                ]
            ]
        );

        if ($response->getStatusCode() !== 200) {
            return null;
        }

        $body = json_decode($response->getBody()->getContents(), true);

        if (!is_array($body) || empty($body)) {
            return null;
        }

        if (!array_key_exists('results', $body) || empty($body['results'])) {
            return null;
        }

        return $body['results'][0]['locations'][0]['latLng'];
    }
}
```

The code above is a new method that takes a `User` object and makes a request to MapQuest's API providing the users `location` which is their `Town` and their `County`. There are then several steps following this request to make sure that a location gets returned, and whether the expected fields for the latitude and longitude get included in the response.

Time to call this `MapQuestUtil` class and `getLatLongByAddress()` method. Open the `RegisterController`.

The new Utility class needs injecting as a service. In the `__construct()` method update it as shown below:

```diff
use App\Form\VerifyType;
+use App\Util\MapQuestUtil;

class RegisterController extends AbstractController
{
    /** @var VonageVerifyUtil */
    protected $vonageVerifyUtil;

+    /** @var MapQuestUtil */
+    protected $mapQuestUtil;

-    public function __construct(VonageVerifyUtil $vonageVerifyUtil)
-    {
+    public function __construct(
+        VonageVerifyUtil $vonageVerifyUtil,
+        MapQuestUtil $mapQuestUtil
+    ) {
        $this->vonageVerifyUtil = $vonageVerifyUtil;
+        $this->mapQuestUtil = $mapQuestUtil;
    }
```

Now that the `MapQuestUtil` has been injected, you need to call the function and then store the details returned to the `User`. In the `index()` function, find the line `if ($form->isSubmitted() && $form->isValid()) {` and add a new line below. Adding the following:

```diff
if ($form->isSubmitted() && $form->isValid()) {
+    $latLng = $this->mapQuestUtil->getLatLongByAddress($user);
+
+    if (null !== $latLng) {
+        $user
+          ->setLatitude($latLng['lat'])
+          ->setLongitude($latLng['lng']);
+    }
```

At this point in the tutorial, you have created a new Symfony project, configured this project with your database. You've also created a new `User` entity, which maps with your `user` database table. You've created two new forms, a `UserType` and `VerifyType`, which get used to validate your new users and whether the input verification code is valid. You've also created several pages for the user to access, a `/register`, `/verify`, and `/success`.

You're now at a natural breakpoint, halfway in this tutorial! You can now test the registration process of your project.

Go to [the registration page](http://localhost:8081/register) and follow the instructions over the next two pages. Please input a valid phone number. Otherwise, you will not be able to verify your account.

### Befriending

#### Match Users

##### Create Match Entity

A new entity is needed to connect two users: gather their feedback, and store records of users who get connected. This new entity will store a relationship to the two callers in the matched object and the name of the conference call (the names of both users concatenated by '-'). To do this, make use of the `make` library as shown below, and follow its instructions for the three new properties:

```bash
docker-compose exec php bin/console make:entity
```

* Name: Match
* 1 - callerOne - ManyToOne - User - not nullable - rest defaults
* 2 - callerTwo - ManyToOne - User - not nullable - rest defaults
* 3 - conferenceName - string - 255 - not nullable

Before you make the migration, another is needed. There is an extensions bundle for `Doctrine` that allows the code to make use of Doctrine extensions such as `Timestampable`, to use two lines in our entities for having `createdAt` and `updatedAt` fields. To do this install `stof/doctrine-extensions-bundle`:

```bash
docker-compose exec php composer require stof/doctrine-extensions-bundle
```

The config is needed for this new extensions bundle. Open `stof_doctrine_extensions.yaml` found in: `project/config/packages/` and update it to mirror:

```yml
stof_doctrine_extensions:
    default_locale: en_GB
    orm:
        default:
            timestampable: false
```

You need to make some further changes in the newly created `Match` entity. Open this class, which you can find in `project/src/Entity/Match.php`.

First, include the `TimestampableEntity` into the project by adding the following import:

```diff
use Doctrine\ORM\Mapping as ORM;
+use Gedmo\Timestampable\Traits\TimestampableEntity;
```

Now use the `TimestampableTrait` in the `Match` class, as shown below:

```diff
 class Match
 {
+     use TimestampableEntity;
```

Running the command below will generate a new migration file with these database changes:

```bash
docker-compose exec php bin/console make:migration
```

If you wish to see the upcoming database changes, the generated migration files get saved to `project/src/Migrations/`.

So long as you're happy with these changes, to persist them to the database, run the command below:

```bash
docker-compose exec php bin/console doctrine:migrations:migrate
```

#### Configure Ngrok

Ngrok is a cross-platform application that allows users to expose their development server to the Internet without having to configure their router. Ngrok does this by creating a tunnel between your server and the Ngrok subdomain.

Time to configure Ngrok to allow the Vonage Application (which is created in the next step), to have an Ngrok sub-domain to make its webhook requests.

In the directory `docker/ngrok/` rename the file `ngrok.conf.local` to `ngrok.conf`, and replace `<auth_token>` with your Ngrok auth token:

 **Note**  You can find your `auth token` in your [dashboard on Ngrok](https://dashboard.ngrok.com/auth/your-authtoken)

```
authtoken: <auth_token>
```

Now, to update your Docker containers with the correct Ngrok subdomain URL, Docker needs to be restarted. You can restart Docker with the following command:

```bash
docker-compose restart
```

Once you have restarted Docker, go to <https://0.0.0.0:4040>, and copy the Ngrok subdomain shown on the status page.

![Ngrok Status Page](/content/blog/befriending-service-with-symfony-and-vonage/ngrok-status-page-1.png)

If you now take that Ngrok subdomain and access it: `ngroksubdomain/register`, replacing `ngroksubdomain` with your Ngrok subdomain, you'll see your registration page. For me, the example was: `https://a551f0297ed8.ngrok.io/register`.

Please take note of this Ngrok subdomain because it'll be needed next to configure your Vonage Application.

#### Create a Vonage Application

Log into your [Vonage Dashboard](https://dashboard.nexmo.com/). On the left of the page is a link `Your Applications`, click this. Once loaded, click the `Create a new Application` button.

Set the `Application Name`, for the tutorial, I set the name to `Befriending Service`, but it can be whatever you want.

Click the button to `Generate public and private key`. Your browser will have a download for the `private.key` file. Save this into your `project/` directory.

Under `Capabilities`, toggle on `Voice`.

Update all three input boxes you now see with the webhook URLs needed for Vonage to make callbacks during phone calls. For example, for the events text box: `https://a551f0297ed8.ngrok.io/webhooks/events`, remember to replace `a551f0297ed8` with your subdomain you created in the step above. Make sure to do this for all three input boxes:

* Event - https://<ngrok url>/webhooks/event
* Answer - https://<ngrok url>/webhooks/answer
* Fallback - https://<ngrok url>/webhooks/fallback

Finally, click `Generate new application`.

The page that now loads will display your `Application ID`. Make a note of this!

In your `project/` directory, open `.env.local` and add the following two lines, making sure to replace `<application id>` with your application id, and replace `<ngrok_url>` with your Ngrok URL:

```env
VONAGE_APPLICATION_ID=<application id>
VONAGE_APPLICATION_PRIVATE_KEY_PATH=/var/www/symfony/private.key
VONAGE_NUMBER=<your virtual Vonage number>

NGROK_URL=<ngrok_url>
```

You've now created a Vonage Application and stored the credentials within your project. Storing these credentials enable the project to now make and receive phone calls.

#### Vonage Call Util

Create a new file in `project/src/Util/` called `VonageCallUtil.php`.

```php
<?php

namespace App\Util;

use App\Util\VonageVerifyUtil;
use Nexmo\Client as VonageClient;
use Nexmo\Client\Credentials\Keypair;

class VonageCallUtil
{
    /** @var VonageClient */
    protected $client;

    /** @var VonageVerifyUtil */
    protected $vonageVerifyUtil;

    public function __construct(VonageVerifyUtil $vonageVerifyUtil)
    {
        $keypair = new Keypair(
            file_get_contents($_ENV['VONAGE_APPLICATION_PRIVATE_KEY_PATH']),
            $_ENV['VONAGE_APPLICATION_ID']
        );

        $this->client = new VonageClient($keypair);
        $this->vonageVerifyUtil = $vonageVerifyUtil;
    }
}
```

This Utility class currently does nothing other than inject two new services on creation. These services are the `VonageClient`, which is the part that makes use of the Vonage Voice API to make and receive calls. The other service injected is the `VonageVerifyUtil`, which gets called when the project needs specific methods from within this Util.

The Utility class gets used to initiate the call between two users. So the first method needed will be `createConferenceBetween()`

```php
public function createConferenceBetween(User $callerOne, User $callerTwo): Match
{
    $conferenceName = $callerOne->getName() . '_' . $callerTwo->getName();

    // Save conference name to the database, along with the callerOne and callerTwo.
    $match = (new Match())
        ->setCallerOne($callerOne)
        ->setCallerTwo($callerTwo)
        ->setConferenceName($conferenceName)
        ->setCreatedAt((new \DateTime()))
        ->setUpdatedAt((new \DateTime()));

    $ncco = [
        [
            'action' => 'talk',
            'voiceName' => 'Amy',
            'text' => 'You are on a Befriending service call, I will connect you to someone random from my database that shouldn\'t be far from your town. Please enjoy your call. If you would like to join now, enter 1 for yes, or 2 for no.'
        ],
        [
            'action' => 'input',
            'maxDigits' => 1,
            'eventUrl' => [
                $_ENV['NGROK_URL'] . '/webhooks/joinConference'
            ],
            'timeOut' => 10
        ]
    ];

    $this->makeCall($callerOne, $ncco);
    $this->makeCall($callerTwo, $ncco);

    return $match;
}
```

The code above is a method that takes two users as arguments of that method. The method then generates a new object of the `Match` entity as a connection between the two users. A Nexmo Call Control Object  (NCCO) array is created, which is a set of instructions for Vonage Voice to know what to expect and steps expected to make the call.

This array contains two further array elements. The first is to use the persona `Amy` to introduce the user to the call and explain what the phone call is regarding. `Amy` asks the user if they'd like to join a conference call or not, requesting them to enter 1 for yes or 2 for no. The second array is to direct the user to the next webhook endpoint, which is to join the conference.

You may have noticed that there are two calls to a `makeCall()` method, which you haven't yet created. Create this new method by copying the following code into your `VonageCallUtil`:

```php
public function makeCall(User $caller, array $ncco)
{
    try {
        $number = $this->vonageVerifyUtil->getInternationalizedNumber($caller);

        $call = $this->client->calls()->create([
            'to' => [[
                'type' => 'phone',
                'number' => preg_replace('/\s+/', '', $number)
            ]],
            'from' => [
                'type' => 'phone',
                'number' => $_ENV['VONAGE_NUMBER']
            ],
            'ncco' => $ncco
        ]);
    } catch (\Exception $e) {

    }
}
```

This method first calls another method, `getInternationalizedNumber()`, found within the `vonageVerifyUtil`. It takes the `$caller` which is an instance of `User` and converts the country code and phone number into an `Internationalized` number for Vonage to call.

The next step in the above method is to initialize the call by setting a `to`, `from` and inserting the `ncco` object.

Finally, within this `VonageCallUtil` several classes need to be included as they get used in the examples above. Copy the additions shown in the example below into your file:

```diff
namespace App\Util;

+use App\Entity\Match;
+use App\Entity\User;
use App\Util\VonageVerifyUtil;
use Nexmo\Client as VonageClient;
use Nexmo\Client\Credentials\Keypair;
```

To summarise, the functionality above doesn't yet get called, but it creates a new Match object, saves two users to it, and then makes two calls for each user. No conference gets made or any way to link the two calls together yet. The conference call is made next!

### Matching Users

Because the project is to have daily calls, a command is needed, which will get run as a cronjob. In your Terminal, inside the `docker/` directory, make use of the `make` library to create a new command:

```bash
docker-compose exec php bin/console make:command
```

When the library requests a name for your new command enter `app:match-users`.

Running this command will create a new file called `MatchUsersCommand.php` inside: `project/src/Command/MatchUsersCommand.php`.

Open this the newly created `MatchUsersCommand.php` file.

The command you generated has some default settings, most of which you won't need for this project. Find `protected function configure()` and replace the contents of this function with:

```php
$this
    ->setDescription('Match users together for a phone call')
;
```

Two services need injecting into the class via the `__construct()` method. The two services required are the `EntityManagerInterface`, which allows the code to make database queries or have access to the repository methods for your entities. The second service needed is the `VonageCallUtil` to call our previously created functionality that calls two users and connects them.

Update the following code inside the `MatchUsersCommand.php` file to match as shown below:

```diff
+use App\Entity\Match;
+use App\Entity\User;
+use App\Util\VonageCallUtil;
+use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class MatchUsersCommand extends Command
{
    protected static $defaultName = 'app:match-users';

+    /** @var VonageCallUtil */
+    protected $vonageCallUtil;
+
+    /** @var EntityManagerInterface */
+    protected $entityManager;
+
+    public function __construct(
+        VonageCallUtil $vonageCallUtil,
+        EntityManagerInterface $entityManager
+    ) {
+        $this->vonageCallUtil = $vonageCallUtil;
+        $this->entityManager = $entityManager;
+
+        parent::__construct();
+    }
```

Now it's time to start building the command functionality!

For the query to work, the project needs some Doctrine Extensions that you're going to write in the next step. These extensions come from a third party library by [Benjamin Eberlei](https://github.com/beberlei). To install this library, inside your Terminal run the following command:

```bash
docker-compose exec php composer require beberlei/doctrineextensions
```

Now, to enable the required extensions. Open `project/config/packages/doctrine.yaml`, and with the same indentation of `auto_generate_proxy_classes`, `naming_strategy`, `auto_mapping`, and `mappings` add:

**Note:** Please pay attention to how it is indented to make sure that it is correct YAML format.

```yaml
dql:
    numeric_functions:
        acos: DoctrineExtensions\Query\Mysql\Acos
        cos: DoctrineExtensions\Query\Mysql\Cos
        radians: DoctrineExtensions\Query\Mysql\Radians
        sin: DoctrineExtensions\Query\Mysql\Sin
```

Back inside your `MatchUsersCommand` find the `execute()` function. This function is the location where all of the work happens for the command.

To start with, delete all of the contents of this method.

The first part needed in this method is to have an instance of the `Match` and `User` Repositories into variables, and to get all users that are marked as active:

```php
$matchRepository = $this->entityManager->getRepository(Match::class);
$userRepository = $this->entityManager->getRepository(User::class);
$activeUsers = $userRepository->findByActive(true);
```

Following this, it's time to loop through each active user, to initiate calls and connect them with another user. Add the following loop:

```php
foreach ($activeUsers as $key => $callerOne) {

}
```

Now the system needs to find users geographically close to the current `$callerOne` to connect them. The query is quite a lengthy one and will belong inside the `UserRepository`. Open the file `project/src/Repository/UserRepository.php`

Below the `__construct` method, add the following new method:

```php
public function findPossibleMatchesByDistance(User $user, array $activeUsers, int $distance)
{
    $queryBuilder = $this->createQueryBuilder('u');

    return $this->createQueryBuilder('u')
        ->addSelect(
            '( 3959 * acos(cos(radians(:latitude))' .
                '* cos(radians(u.latitude))' .
                '* cos(radians(u.longitude)' .
                '- radians(:longitude))' .
                '+ sin(radians(:latitude))' .
                '* sin(radians(u.latitude)))) as distance'
        )
        ->andWhere($queryBuilder->expr()->eq('u.active', ':isActive'))
        ->andWhere($queryBuilder->expr()->eq('u.verified', ':isVerified'))
        ->andWhere($queryBuilder->expr()->neq('u', ':user'))
        ->having($queryBuilder->expr()->lt('distance', ':distance'))
        ->setParameters([
            'latitude' => $user->getLatitude(),
            'longitude' => $user->getLongitude(),
            'user' => $user,
            'distance' => $distance,
            'isActive' => true,
            'isVerified' => true
        ])
        ->getQuery()
        ->getResult();
}
```

The method in the code block above, takes a user object, an array of the current active users and an integer variable of a predetermined distance.

This method creates a new query which calculates the distance of all users from the given user and ensures they're all active and verified. The last check is to make sure that the returned users are within the given distance of the passed in user.

Back inside the `MatchUsersCommand` find the line: `foreach ($activeUsers as $activeUser) {` and add the following:

```php
// Retrieve all active users within a 30 mile radius of current callerOne
$matches = $userRepository->findPossibleMatchesByDistance($callerOne, $activeUsers, 30);

// If there are less than 5 users returned, increase the search to 100 mile radius.
if (count($matches) < 5) {
    $matches = $userRepository->findPossibleMatchesByDistance($callerOne, $activeUsers, 100);
}

// If there are no users within a 100 mile radius return 0
if (count($matches) === 0) {
    unset($activeUsers[$key]);

    continue;
}

// Shuffle returned matches.
shuffle($matches);
// Remove callerOne from list of active users
unset($activeUsers[$key]);

$callerTwo = $matches[0][0];

// Remove callerTwo from list of active users
$matchKey = array_search($callerTwo, $activeUsers);
unset($activeUsers[$matchKey]);

// Make a call to createConferenceBetween() inside VonageCallUtil to connect the two users via phone call.
$match = $this->vonageCallUtil->createConferenceBetween($callerOne, $callerTwo);

// If successful, save the Match to the database.
if ($match instanceof Match) {
    $this->entityManager->persist($match);
    $this->entityManager->flush();
}
```

The command gets created to find users to match together and initiate the call. However, webhook URLs are needed to progress the call from automated introduction to connecting the users into a conference call.

### Webhooks

You now need a `WebhooksController`, so in your Terminal, make use of the `make` library to run the following command:

```bash
docker-compose exec php bin/console make:controller
```

Where it says: `Choose a name for your controller class (e.g. AgreeableGnomeController):` type `WebhooksController` and press enter.

You've now created two new files:

```
created: src/Controller/WebhooksController.php
created: templates/webhooks/index.html.twig
```

Open the newly created `WebhooksController.php` found within `project/src/Controller/`

This Controller will need to make use of three services, `VonageVerifyUtil`, `VonageCallUtil`, and `EntityManagerInterface`. So start by injecting them into the Controller's construct, as shown below:

```diff
+
+ use App\Util\VonageVerifyUtil;
+ use App\Util\VonageCallUtil;
+ use Doctrine\ORM\EntityManagerInterface;

class WebhooksController extends AbstractController
{
+    /** @var VonageVerifyUtil */
+    protected $vonageVerifyUtil;
+
+    /** @var VonageCallUtil */
+    protected $vonageCallUtil;
+
+    /** @var EntityManagerInterface */
+    protected $entityManager;
+
+    public function __construct(
+        VonageCallUtil $vonageCallUtil,
+        VonageVerifyUtil $vonageVerifyUtil,
+        EntityManagerInterface $entityManager
+    ) {
+        $this->vonageCallUtil = $vonageCallUtil;
+        $this->vonageVerifyUtil = $vonageVerifyUtil;
+        $this->entityManager = $entityManager;
+    }
}
```

The two methods below do what their naming states. The first one is to find a user by their phone number, while the second finds a `Match` instance by a `User` that you created today. Add these to your `WebhooksController`.

```php
private function findUserByNumber(string $phoneNumber)
{
    return $this->entityManager->getRepository(User::class)->findOneByPhoneNumber(
        $this->vonageVerifyUtil->getNationalizedNumber('+' . $phoneNumber)
    );
}

private function findMatchByUser(User $user)
{
    return $this->entityManager
        ->getRepository(Match::class)
        ->findByDateUser($user, (new \DateTime()));
}
```

One method called in the above example doesn't yet exist, this is to find matches by the user and current date. Open `project/src/Repository/MatchRepository.php` and inside this class, add the method shown below:

```php
public function findByDateUser(User $user, DateTime $date)
{
    $queryBuilder = $this->createQueryBuilder('m');

    return $this->createQueryBuilder('m')
        ->andWhere(
            $queryBuilder->expr()->orX(
                $queryBuilder->expr()->eq('m.callerOne', ':user'),
                $queryBuilder->expr()->eq('m.callerTwo', ':user')
            )
        )
        ->andWhere(
            $queryBuilder->expr()->like('Date(m.createdAt)', ':date')
        )
        ->setParameters([
            'user' => $user,
            'date' => $date->format('Y-m-d') . '%'
        ])
        ->getQuery()
        ->getResult();
}
```

At the top of the file add the import for the entity `User`:

```diff
use App\Entity\Match;
+use App\Entity\User;
```

The above query finds a `Match` entry where the user is either `callerOne` or `callerTwo` and the `Match` was created today. There is a query function that Doctrine doesn't know of in here. `Date(m.createdAt)`. When calculating the distance between people you installed `beberlei/doctrineextensions`. This library has functionality to include the `Date` extension. So open `project/config/packages/doctrine.yaml` and add the following two lines:

```diff
dql:
    numeric_functions:
        acos: DoctrineExtensions\Query\Mysql\Acos
        cos: DoctrineExtensions\Query\Mysql\Cos
        radians: DoctrineExtensions\Query\Mysql\Radians
        sin: DoctrineExtensions\Query\Mysql\Sin
+    datetime_functions:
+        Date: DoctrineExtensions\Query\Mysql\Date
```

Previously, you created a method called `createConferenceBetween()`, inside this method was an `NCCO` array that referenced a URL of `/webhooks/joinConference`, if you were to run the example now, nothing would happen as the URL doesn't exist. Create a new `joinConference()` method inside your `WebhooksController` with the annotation containing this URL.

The method will have two purposes. The first is to validate the user's input, ensuring they only enter valid options before proceeding. These inputs are 1 for yes, and 2 for no.

The second purpose of this method is to respect the user's input. If they choose to progress to the call, then redirect them to the next action, which connects them to the conference call. If the user selects '2', to not join a call with someone, the system responses confirming their request not to join a call and ends the call.

```php
/**
 * @Route("/webhooks/joinConference", name="match_join")
 */
public function joinConference(Request $request)
{
    $content = json_decode($request->getContent(), true);

    if (!in_array($content['dtmf'], ['1', '2'])) {
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Please only enter 1 or 2. Would you like to join a call with someone?',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $_ENV['NGROK_URL'] . '/webhooks/joinConference'
                ],
                'timeOut' => 10
            ]
        ];
    } elseif ($content['dtmf'] === '1') {
        // Find user by number.
        $user = $this->findUserByNumber($content['to']);
        // Find match by user and today.
        $match = $this->findMatchByUser($user)[0];

        // Make next request.
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Thank you. I will now connect you.',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'conversation',
                'name' => $match->getConferenceName()
            ]
        ];
    } else {
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Ok, we will not put you in a call with someone at this time. Goodbye.',
                'voiceName' => 'Amy',
            ]
        ];
    }

    return new JsonResponse($ncco);
}
```

Four classes get used here that we haven't included into our file, `Request`, `Match`, `User`, and `JsonResponse`. Include these above the class:

```diff
+use App\Entity\Match;
+use App\Entity\User;
use App\Util\VonageCallUtil;
use App\Util\VonageVerifyUtil;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
+use Symfony\Component\HttpFoundation\Request;
+use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Doctrine\ORM\EntityManagerInterface;
```

At this point, you now have a user registration form, which takes the user through the verification process. You also have a command that when run will loop through all active and verified users connecting them to other active and verified users within a maximum of a 100-mile radius of each other.

You can now test this! If you have two phone numbers available to you, go ahead and register on your [registration page](https://127.0.0.1:8081/register). Be sure to follow the verification process, and make sure that the location you've entered for both users are within 30 miles from each other.

Once you've registered users, in your Terminal, inside the `docker/` directory, run the following command:

```bash
docker-compose exec php bin/console app:match-users
```

Both phone numbers will receive a call and asked if they'd like to connect to a call with another person!

### Get Feedback

A second command is needed to retrieve feedback from each user. This command will collect feedback from the calls of the current day from each user. This command will also be a cronjob scheduled to run several hours after the matching call has finished.

But before making this new command, the `Match` entity needs updating, as when you created the `Match` entity with the `make` library, you can also update it with new properties. Run the following command in your Terminal and follow the instructions of each step below:

```bash
docker-compose exec php bin/console make:entity
```

* Class name of the entity to create or update (e.g. DeliciousGnome):

  * `Match`
* Property 1

  * Name: `callerOneFeedbackAccepted`
  * Type: `boolean`
  * Can Be Null?: `yes`
* Property 2

  * Name: `callerTwoFeedbackAccepted`
  * Type: `boolean`
  * Can Be Null?: `yes`
* Property 3

  * Name: `callerOneCallSuccessful`
  * Type: `boolean`
  * Can Be Null?: `yes`
* Property 4

  * Name: `callerTwoCallSuccessful`
  * Type: `boolean`
  * Can Be Null?: `yes`

The updated entity doesn't currently reflect what's in the database. To make the database reflect what you've defined in the `Match` entity, run the command below to generate a new migration file:

```bash
docker-compose exec php bin/console make:migration
```

If you wish to see the upcoming database changes, the generated migration files get saved to `project/src/Migrations/`.

So long as you're happy with these changes, to persist them to the database, run the command below:

```bash
docker-compose exec php bin/console doctrine:migrations:migrate
```

First, you need to get a list of today's matches. So in your `MatchRepository` add a new function that queries the database to find all matches for the current day. This query will only find matched users where the `callerOneCallSuccessful` flag is empty:

```php
public function getTodaysMatches()
{
    $queryBuilder = $this->createQueryBuilder('m');

    return $this->createQueryBuilder('m')
        ->andWhere(
            $queryBuilder->expr()->isNull('m.callerOneCallSuccessful'),
            $queryBuilder->expr()->like('Date(m.createdAt)', ':date')
        )
        ->setParameter('date', (new \DateTime())->format('Y-m-d') . '%')
        ->getQuery()
        ->getResult();
}
```

Now it's time to create the new command that makes use of the new changes, in your terminal type:

```bash
docker-compose exec php bin/console make:command
```

When it asks for a command name enter: `app:get-feedback`. This command will generate a new command file inside `project/src/command/` called `GetFeedbackCommand.php` Open the newly created file.

This controller needs two services injected into it through the `__construct()` method. The same two services injected into the `MatchUsersCommand`. Copy the adjustments shown below into your `GetFeedbackCommand`:

```diff
+use App\Entity\Match;
+use App\Util\VonageCallUtil;
+use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class GetFeedbackCommand extends Command
{
    protected static $defaultName = 'app:get-feedback';

+    /** @var VonageCallUtil */
+    protected $vonageCallUtil;
+
+    /** @var EntityManagerInterface */
+    protected $entityManager;
+
+    public function __construct(
+        VonageCallUtil $vonageCallUtil,
+        EntityManagerInterface $entityManager
+    ) {
+        $this->vonageCallUtil = $vonageCallUtil;
+        $this->entityManager = $entityManager;
+
+        parent::__construct();
+    }
```

By carrying out the changes above, your command now has access to the `VonageCallUtil` and `EntityManagerInterface`.

Update the contents of `configure()` with what's shown in the example below. This example sets the description of the command:

```php
$this
    ->setDescription('Contact all previous matches to get their feedback.');
```

It's time to implement the functionality to initiate collecting feedback from matched users. Replace the contents of the method `execute()` with:

```php
$matchRepository = $this->entityManager->getRepository(Match::class);

// Get matches that haven't had any feedback.
$matches = $matchRepository->getTodaysMatches();

if (empty($matches)) {
    return 0;
}

// Loop through all retrieved matches
foreach ($matches as $match) {
    if (null === $match->getCallerOneCallSuccessful()) {
        // Call callerOne as we do not have feedback from them.
        $this->vonageCallUtil->makeFeedbackCall(
            $match->getCallerOne()
        );
    }

    if (null === $match->getCallerTwoCallSuccessful()) {
        // Call callerTwo as we do not have feedback from them.
        $this->vonageCallUtil->makeFeedbackCall(
            $match->getCallerTwo()
        );
    }

    // Save changes to the database.
    $this->entityManager->flush();
    $this->entityManager->clear();
}

return 0;
```

The above functionality collects the matches for the day, it then loops through each match initiating a call with caller one and caller two requesting feedback from each on their previous call.

As you can see you've made a call to `makeFeedbackCall()` from the `VonageCallUtil`, but the method doesn't exist yet. So open the `VonageCallUtil` inside `project/src/util/VonageCallUtil.php` and add a new method:

```php
public function makeFeedbackCall(User $user)
{
    $ncco = [
        [
            'action' => 'talk',
            'text' => 'Thank you for using the Befriending service. Could you please provide feedback for your call today? Enter 1 for yes, or two for no.',
            'voiceName' => 'Amy',
        ],
        [
            'action' => 'input',
            'maxDigits' => 1,
            'eventUrl' => [
                $_ENV['NGROK_URL'] . '/webhooks/userFeedback'
            ],
            'timeOut' => 10
        ]
    ];

    $this->makeCall($user, $ncco);
}
```

The example above references to an `eventUrl` which is your Ngrok URL and `/webhooks/userFeedback`. This endpoint doesn't exist in our `WebhooksController` yet.

The method will have two purposes. The first is to validate the user's input, ensuring they only enter valid options before proceeding. These inputs are 1 for yes, and 2 for no.

The second purpose of this method is to respect the user's input. If they choose to progress to give feedback, then redirect them to the next action, which is asking the first feedback question. If the user selects '2', do not provide feedback, the system responses confirming their request not give feedback and ends the call.

So in the `WebhooksController` create a new method called `getUserFeedback()` as shown below:

```php
/**
 * @Route("/webhooks/userFeedback", name="match_feedback")
 */
public function getUserFeedback(Request $request)
{
    $content = json_decode($request->getContent(), true);

    if (!in_array($content['dtmf'], ['1', '2'])) {
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Please only enter 1 or 2. Would you like to provide feedback for the service?',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $request->getScheme().'://'.$request->getHost().'/webhooks/userFeedback'
                ],
                'timeOut' => 10
            ]
        ];
    } else {
        // Find user by number.
        $user = $this->findUserByNumber($content['to']);
        // Find match by user and today.
        $match = $this->findMatchByUser($user)[0];
        // Determine if user is first or second caller.
        $isFirstOrSecond = $this->isFirstOrSecondCaller($match, $user);

        // Save entry to database.
        if ($isFirstOrSecond === 1) {
            $method = 'setCallerOneFeedbackAccepted';
        } elseif ($isFirstOrSecond === 2) {
            $method = 'setCallerTwoFeedbackAccepted';
        } else {
            return new JsonResponse([]);
        }

        $mapResponse = [
            '1' => true,
            '2' => false
        ];

        $match->$method($mapResponse[$content['dtmf']]);
        $this->entityManager->flush();

        // Make next request.
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Thank you. Was the call successful? Please enter 1 for yes, or 2 for no.',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $_ENV['NGROK_URL'] . '/webhooks/userFeedbackCallSuccess'
                ],
                'timeOut' => 10
            ]
        ];
    }

    return new JsonResponse($ncco);
}
```

The example above references to an `eventUrl` which is your Ngrok URL and `/webhooks/userFeedbackCallSuccess`. This endpoint doesn't exist in our `WebhooksController` yet.

The method will have two purposes. The first is to validate the user's input, ensuring they only enter valid options before proceeding. These inputs are 1 for yes, and 2 for no.

The second purpose of this method is to respect the user's input. If they choose either '1' or '2', then save the users input to either the property `setCallerOneCallSuccessful` or the property `setCallerTwoCallSuccessful` as true or false (whether they enjoyed the call or not).

Following a successful option entry, the code then redirects the user to the next action of the call, which is the endpoint `/webhooks/userFeedbackContinue`

So in the `WebhooksController` create a new method called `getUserFeedbackCallSuccess()` as shown below:

```php
/**
 * @Route("/webhooks/userFeedbackCallSuccess", name="match_call_success")
 */
public function getUserFeedbackCallSuccess(Request $request)
{
    $content = json_decode($request->getContent(), true);

    if (!in_array($content['dtmf'], ["1", "2"])) {
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Please only enter 1 or 2. Was the call successful? Please enter 1 for yes or 2 for no.',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $request->getScheme().'://'.$request->getHost().'/webhooks/userFeedbackCallSuccess'
                ],
                'timeOut' => 10
            ]
        ];
    } else {
        // Find user by number.
        $user = $this->findUserByNumber($content['to']);
        // Find match by user and today.
        $match = $this->findMatchByUser($user)[0];
        // Determine if user is first or second caller.
        $isFirstOrSecond = $this->isFirstOrSecondCaller($match, $user);

        // Save entry to database.
        if ($isFirstOrSecond === 1) {
            $method = 'setCallerOneCallSuccessful';
        } elseif ($isFirstOrSecond === 2) {
            $method = 'setCallerTwoCallSuccessful';
        } else {
            return new JsonResponse([]);
        }

        $mapResponse = [
            '1' => true,
            '2' => false
        ];

        $match->$method($mapResponse[$content['dtmf']]);
        $this->entityManager->flush();

        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Would you like to have another call tomorrow? Please enter 1 for yes or 2 for no.',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $_ENV['NGROK_URL'] . '/webhooks/userFeedbackContinue'
                ],
                'timeOut' => 10
            ]
        ];
    }

    return new JsonResponse($ncco);
}
```

The example above references to an `eventUrl` which is your Ngrok URL and `webhooks/userFeedbackContinue`. This endpoint doesn't exist in our `WebhooksController` yet.

The method will have two purposes. The first is to validate the user's input, ensuring they only enter valid options before proceeding. These inputs are 1 for yes, and 2 for no.

The second purpose of this method is to respect the user's input. If they choose '1', then they continue to be subscribed to the service for a call the following day.

If the user chooses '2', then they are set to inactive and no longer called.

The call ends following a successful option entry.

So in the `WebhooksController` create a new method called `getUserFeedbackContinue()` as shown below:

```php
/**
 * @Route("/webhooks/userFeedbackContinue", name="match_user_continue")
 */
public function getUserFeedbackContinue(Request $request)
{
    $content = json_decode($request->getContent(), true);

    if (!in_array($content['dtmf'], ["1", "2"])) {
        $ncco = [
            [
                'action' => 'talk',
                'text' => 'Please only enter 1 or 2. Would you like to have another call tomorrow? Please enter 1 for yes or 2 for no.',
                'voiceName' => 'Amy',
            ],
            [
                'action' => 'input',
                'maxDigits' => 1,
                'eventUrl' => [
                    $_ENV['NGROK_URL'] . '/webhooks/userFeedbackContinue'
                ],
                'timeOut' => 10
            ]
        ];
    } else {
        // Find user by number.
        $user = $this->findUserByNumber($content['to']);
        // Find match by user and today.
        $match = $this->findMatchByUser($user);

        if (!$match) {
            return new JsonResponse([]);
        }

        $mapResponse = [
            '1' => true,
            '2' => false
        ];

        if ($content['dtmf'] === "2") {
            $user->setActive(false);
            $this->entityManager->flush();

            $ncco = [
                [
                    'action' => 'talk',
                    'text' => 'Thank you for your feedback. Your number has been removed from the list.',
                    'voiceName' => 'Amy',
                ]
            ];
        } else {
            $ncco = [
                [
                    'action' => 'talk',
                    'text' => 'Thank you for your feedback. Goodbye.',
                    'voiceName' => 'Amy'
                ],
            ];
        }
    }

    return new JsonResponse($ncco);
}
```

The last addition required to the project is a function that you may have noticed being called `isFirstOrSecondCaller()` but needs creating. This method takes an instance of `Match` and a single `User` object; it then determines whether the user given is `callerOne` or `callerTwo` of the `Match`. Add this to the bottom of your class:

```php
private function isFirstOrSecondCaller(Match $match, User $user): ?int
{
    if ($match->getCallerOne() === $user) {
        return 1;
    }

    if ($match->getCallerTwo() === $user) {
        return 2;
    }

    return null;
}
```

### Conclusion

If you have followed this tutorial from start to finish, you have now created a project from a fresh Symfony installation.

This new project has a registration page, which on submission sends a verification request to Vonage Verify. This request triggers an SMS for the owners of the phone number on registration. The verification code in the SMS needs entering into the next page the user sees. On successful verification, the user is redirected to a success page letting them know of what time to expect phone calls.

The second part of this project is the Vonage Voice feature. By using commands, the users get matched, called, and joined into a conference call. Later that day, a second command is run to request feedback from each person matched on the current day.

The finished code for this tutorial can be found on the end-tutorial branch on this [GitHub repository](https://github.com/nexmo-community/befriending-service-with-symfony/tree/end-tutorial).

Below are a few other tutorials we've written implementing Vonage Verify or Voice into projects:

* [Add SMS Verification in a React Native App Using Node.js and Express](https://learn.vonage.com/blog/2020/05/26/add-sms-verification-in-a-react-native-app-using-node-js-and-express-dr/)
* [Download Vonage Voice API Recordings with Golang](https://learn.vonage.com/blog/2020/05/18/download-vonage-voice-api-recordings-with-golang/)
* [Number Verification in Python with AWS Lambda and Vonage](https://learn.vonage.com/blog/2020/05/06/number-verification-in-python-with-aws-lambda-and-vonage/)

Don't forget, if you have any questions, advice or ideas you'd like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack). I'd love to hear back from anyone that has implemented this tutorial and how your project works.