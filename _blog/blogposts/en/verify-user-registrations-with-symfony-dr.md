---
title: Verify User Registrations with Symfony
description: Users registering with false information can be a pest, which is
  especially the case when registering with phone numbers that you expect to be
  contactable. Vonage’s Verify API provides a solution to this by enabling you
  to confirm that the phone number is correct and owned by the user. The API
  takes a phone number, […]
thumbnail: /content/blog/verify-user-registrations-with-symfony-dr/Blog_Symfony_Verify_1200x600.png
author: greg-holmes
published: true
published_at: 2020-04-20T16:53:59.000Z
updated_at: 2021-04-19T11:20:56.348Z
category: tutorial
tags:
  - verify-api
  - php
  - symfony
comments: true
redirect: ""
canonical: ""
---
Users registering with false information can be a pest, which is especially the case when registering with phone numbers that you expect to be contactable. [Vonage's Verify API](https://developer.nexmo.com/api/verify) provides a solution to this by enabling you to confirm that the phone number is correct and owned by the user. The API takes a phone number, sends a pin code to that phone number and expects it to be relayed back through the correct source.

In this tutorial, you'll extend an existing basic user authentication system, built-in [Symfony 5](https://symfony.com/5), by implementing multi-factor authentication with the [Vonage Verify API](https://developer.nexmo.com/api/verify) ([Formerly Nexmo](https://twitter.com/VonageDev/status/1237835302200389633) Verify API).

You can find the finished code under the `end-tutorial` branch in this [GitHub repository](https://github.com/nexmo-community/verify-user-registrations-with-symfony).

## Prerequisites

* [Docker](https://www.docker.com/)
* [Node Package Manager (NPM)](https://www.npmjs.com/get-npm)
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

<sign-up number></sign-up>

## Getting Started

### Cloning the Repository

Clone the existing repository by copying this command into your Terminal, and then change directory into the project:

```bash
git clone git@github.com:nexmo-community/verify-user-registrations-with-symfony.git
cd verify-user-registrations-with-symfony
```

### Database Credentials

Within the `symfony/` directory create a `.env.local` file, to store your local environment variables you don't wish to be committed to your repository. For example, your code needs to know the method and credentials to connect to your database. Copy the following line into your `.env.local` file:

```env
DATABASE_URL=postgresql://user:password@postgres:5432/test?serverVersion=11&charset=utf8
```

The above example contains several pieces of information needed to connect to the database.

* `postgresql` is the protocol used to connect.
* `user` and `password` is the set of credentials used to authenticate to the database.
* `postgres` is the address for the domain.
* `5432` is the port to connect to the database.
* `test` is the database name.

### Installing Third-Party Libraries

There several third-party libraries already defined in this project need to be installed, both via Composer and yarn packages.

Run the following three commands:

```bash
# Install libraries such as Symfony framework bundle and Doctrine Orm bundles (for manipulating the database).
composer install
# Install Symfony Webpack encore for integrating bootstrap and front end technologies into the Symfony application.
yarn install
# Compile front end files ready for development use.
yarn run dev
```

### Running Docker

For this tutorial and to ensure that the server requirements are the same for everyone, a Docker config has been set up to use containers with predefined configurations.

Within the `docker/` directory run:

```bash
docker-compose up -d
```

Once the `docker-compose` command has finished, you should be able to see the following confirmation that the three containers are running:

![Image showing Terminal output of Docker containers successfully running](/content/blog/verify-user-registrations-with-symfony/docker-up.png)

### Running Database Migrations

In your terminal, connect to the PHP Docker container by running the following command:

```bash
docker-compose exec php bash
```

To create the database tables and execute all files found in symfony/src/migrations/, run the following command:

```bash
php bin/console doctrine:migrations:migrate
```

This command creates a user database table with the relevant columns.

### Test Run the Registration

Go to: `http://localhost:8081/register` in your browser, and you will see a registration page similar to what you see in the image below:

![Initial template render of registration page with form.](/content/blog/verify-user-registrations-with-symfony/initial-register.png)

Enter a test telephone number and password. On submission of the form, you should now see the profile page!

> ***Note:*** Using your phone number here will create you a new user, so be ready to delete that registration from the user database table.

If you're at this point, you're all set up, and ready for this tutorial.

## Installing Nexmo PHP SDK

> ***Note:*** Composer commands are required to run from within the PHP docker container. From the **Running the Database Migrations** tutorial step, you remotely accessed the terminal for the PHP docker container. If you leave the container's terminal session, you can get back to it by running `docker-compose exec php bash` from the `docker/` directory.

The tutorial uses Vonage Verify API. The easiest way to use this in PHP is to install our PHP SDK.

To install this run:

```bash
composer require nexmo/client
```

In your [Vonage Developer Dashboard](https://dashboard.nexmo.com/getting-started-guide), you'll find "Your API credentials", make a note of these.

Within the directory `symfony/`, add the following two lines to your `.env.local` file (replacing the api_key and api_secret with your key and secret):

```env
VONAGE_API_KEY=<api_key>
VONAGE_API_SECRET=<api_secret>
```

Create a new directory called `Util` inside `symfony/src/`, and within that directory create a new file called `VonageUtil.php`.

This Utility class will handle any code that uses the Nexmo PHP SDK. The example below will not do anything other than creating a NexmoClient object with the authentication credentials you've saved in `.env.local`. Copy the example below into your newly created `VonageUtil.php`:

```php
<?php

// symfony/src/Util/VonageUtil.php

namespace App\Util;

use App\Entity\User;
use Nexmo\Client as NexmoClient;
use Nexmo\Client\Credentials\Basic;
use Nexmo\Verify\Verification;

class VonageUtil
{
    /** @var NexmoClient */
    protected $client;

    public function __construct()
    {
        $this->client = new NexmoClient(
            new Basic(
                $_ENV['VONAGE_API_KEY'],
                $_ENV['VONAGE_API_SECRET']
            )
        );     
    }
}
```

## Creating a Verification Page

### Verify New Columns

New properties are needed inside the `User` entity to process verification of a new user correctly.

Within your Docker Terminal, type

```bash
php bin/console make:entity
```

You're going to create three new properties. So following the steps in the above command, enter the values as listed below:

Where it asks for an Entity type `User`

```
- New property name: countryCode
- Type: string
- Length: 2
- Is Nullable: false
```

```
- New property name: verificationRequestId
- Type: string
- Length: 255
- Is Nullable: true
```

```
- New property name: verified
- Type: boolean
- Is Nullable: false
```

The `countryCode` is needed to determine which country the phone number belongs to for the Verify API to make the call successfully.

The `verificationRequestId` the ID the Verify API initially returns to the server, which when paired with the verification code verifies the user.

The `verified` property allows the system to determine whether a user has verified or not.

You'll need to run the following to generate a new migration file with these database changes.

```bash
php bin/console make:migration
```

The above command detects any changes made to the `Entity` files in your project. It then converts these changes into SQL queries which, when run as a migration, will persist the changes to your database.

The generated migration files are inside `symfony/src/Migrations` if you wish to see the upcoming database changes.

If you're happy with these changes, run the command below to persist them to the database.

```bash
php bin/console doctrine:migrations:migrate
```

### Include Country Code in User Registration

Open your `RegistrationFormType` class in `symfony/src/Form/RegistrationFormType.php`. Add a new include for the ChoiceType class form type at the top of the file:

```php
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
```

In the same file, make the following changes:

```diff
public function buildForm(FormBuilderInterface $builder, array $options)
{
    $builder
+      ->add(
+          'countryCode',
+          ChoiceType::class,
+          [
+              'label' => false,
+              'attr' => [
+                  'class' => 'form-control form-control-lg'
+              ],
+              'choices' => [
+                  "United Kingdom" => "GB",
+                  "United States" => "US"
+              ]
+          ]
+      )
```

The only two options to choose from, in this demo, are GB and the US. However, other countries are supported. You can find the ISO list of countries along with their accompanying country code here: [ISO.org](https://www.iso.org/obp/ui/#search). Please make sure that the value in the array is the two-character ISO standard for your country of choice.

Within `symfony/templates/registration/register.html.twig` you'll find a form row for `phoneNumber`. Above this add the `countryCode` equivalent:

```diff
+ {{ form_row(registrationForm.countryCode) }}
  {{ form_row(registrationForm.phoneNumber) }}
```

If you have Docker running, you can check the registration page at [http://localhost:8081/register](http://localhost:8081/register/) and see a page similar to what's shown below:

![Registration page with country code for use with the phone number](/content/blog/verify-user-registrations-with-symfony/register-form.png)

You're welcome to use the registration form, but please do not use your number or be ready to delete that registration from the user database table.

### Verify Phone Number Is Valid

When calling a number to provide a verification code, the system requires a brand name. So in the `symfony/` directory, open `.env.local` and add a new line. Replacing `VerifyWithVonage` with whatever company/brand you're representing for the verification:

```env
VONAGE_BRAND_NAME=VerifyWithVonage
```

To verify a number is a valid phone number, you need to check to make sure the phone number is in the correct format and is valid for the region (country code) you've provided. For this, you're going to use [Giggsey's PHP port of Google libphonenumber](https://packagist.org/packages/giggsey/libphonenumber-for-php).

Run the command below to install this library.

```bash
composer require giggsey/libphonenumber-for-php
```

Open your `VonageUtil` file, found in `symfony/src/Util`. Within this class, you need to add a method to validate the phone number and country code. This method also checks whether the phone number is a match for that region. If it is, the method will return the phone number in an internationalised format. Copy the following into this class:

```php
private function getInternationalizedNumber(User $user): ?string
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
```

The method uses the `$user` object to do the following:

* parse the phone number and country code using the `libphonenumber` library,
* checks that this is a valid number for the region provided (by country code).

If the number and region are valid, it formats the phone number into an internationalised one.

## Sending a Verification Call on Registration

Create a method in `VonageUtil` that will make use of this private method. This new public method will ensure the user's input is valid and using the Verify API, start the verification process.

```php
public function sendVerification(User $user)
{
    // Retrieves the internationalized number using the previous util method created.
    $internationalizedNumber = $this->getInternationalizedNumber($user);

    // If the number is not valid or valid for the country code provided, then return null
    if (!$internationalizedNumber) {
        return null;
    }

    // Initialize the verification process with Vonage
    $verification = new Verification(
        $internationalizedNumber,
        $_ENV['VONAGE_BRAND_NAME'],
        ['workflow_id' => 3]
    );

    return $this->client->verify()->start($verification);
}
```

To save the jumping between different files, you're going to add another method to this utility class. This new method will allow you to get the `request_id` which is returned within the `Verification` object when necessary.

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

These new methods you've created inside the `VonageUtil` class don't do anything right now. For them to be useful, you'll need to call the functionality from within the `RegistrationController` so open this controller found within `symfony/src/Controller/`.

First, you'll need to inject the `VonageUtil` into the `RegistrationController` as a service:

```diff
+use App\Util\VonageUtil;

class RegistrationController extends AbstractController
{
+    /** @var VonageUtil */
+    protected $vonageUtil;
+
+    public function __construct(VonageUtil $vonageUtil)
+    {
+        $this->vonageUtil = $vonageUtil;
+    }
```

Within your `register` method find the three `$entityManager` lines and add functionality to `setVerified()` as false as shown below:

```diff
+$user->setVerified(false);
$entityManager = $this->getDoctrine()->getManager();
$entityManager->persist($user);
$entityManager->flush();
```

Below `$entityManager->flush()` make the request to initiate the verification process. So, add the following two lines that first calls the `VonageUtil` method to send the verification request, the second line parses the response, and saves the `requestId` as a variable:

```php
$verification = $this->vonageUtil->sendVerification($user);
$requestId = $this->vonageUtil->getRequestId($verification);
```

In the class find the following code:

```php
return $guardHandler->authenticateUserAndHandleSuccess(
    $user,
    $request,
    $authenticator,
    'main' // firewall name in security.yaml
);
```

Replace this with functionality that first checks whether you've set the `requestId`, saves the `requestId` to the user, and then authenticates the user:

```php
if ($requestId) {
    $user->setVerificationRequestId($requestId);
    $entityManager->flush();

    return $guardHandler->authenticateUserAndHandleSuccess(
        $user,
        $request,
        $authenticator,
        'main' // firewall name in security.yaml
    );
}
```

### Verify Form

Within your Docker Terminal, run the command below, and then follow the instructions entering the values as listed:

```bash
php bin/console make:form
```

```
- Name: VerifyFormType
- Entity name: User
```

![Creating a verify form in Symfony](/content/blog/verify-user-registrations-with-symfony/verify-form.png)

By submitting this, you should have a new class inside `symfony/src/Form/` called `VerifyFormType.php`. Some changes are needed for this form to work as expected:

Replace the following lines:

```php
->add('phoneNumber')
->add('roles')
->add('password')
->add('countryCode')
->add('verificationRequestId')
->add('verified')
```

with:

```php
->add('verificationCode', TextType::class, [
    'mapped' => false,
    'attr' => [
        'class' => 'form-control form-control-lg'
    ],
    'constraints' => [
        new NotBlank([
            'message' => 'Please enter a verification code',
        ]),
        new Length([
            'min' => 4,
            'max' => 4,
            'minMessage' => 'The verification code is a 4 digit number.',
        ]),
    ],
])
```

You've just removed form fields that shouldn't be updated, added a new unmapped field (a field not mapped to the database table) called `verificationCode`. The `verificationCode` is sent to the API to verify the phone number.

At the top of the file, add three more includes. These are the fully qualified class names of classes used in the example code above.

```php
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Validator\Constraints\Length;
use Symfony\Component\Validator\Constraints\NotBlank;
```

## Verifying the Code

In your `VonageUtil` class, you need a new method to call the Vonage API to verify that the code provided by the user is valid. Put the example below into your `VonageUtil` class:

```php
public function verify(string $requestId, string $verificationCode)
{
    $verification = new Verification($requestId);

    return $this->client->verify()->check($verification, $verificationCode);
}
```

Create a new template file inside `symfony/templates/registration` called `verify.html.twig`

```twig
{% extends 'base.html.twig' %}

{% block title %}Verify{% endblock %}

{% block body %}
    <div class="row justify-content-center align-items-center h-100">
        <div class="col col-sm-6 col-md-6 col-lg-4 col-xl-3">
            <h1 class="h3 mb-3 font-weight-normal">Verify</h1>

            {{ form_start(verificationForm) }}
                <div class="form-group">
                    {{ form_row(verificationForm.verificationCode) }}
                </div>

                <button class="btn btn-info btn-lg btn-block" type="submit">Verify</button>
            {{ form_end(verificationForm) }}
        </div>
    <div>
{% endblock %}
```

Inside your `RegistrationController` a new method is required to display the above template and handle the form submission.

First, include the `VerifyFormType` and a Vonage class `Verification` at the top:

```diff
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;
use Symfony\Component\Security\Guard\GuardAuthenticatorHandler;
+use App\Form\VerifyFormType;
+use Nexmo\Verify\Verification;
```

Then, create the new method:

```php
/**
 * @Route("/register/verify", name="app_register_verify")
 */
public function verify(Request $request): Response
{
    $user = $this->getUser();
    $form = $this->createForm(VerifyFormType::class, $user);
    $form->handleRequest($request);

    if ($form->isSubmitted() && $form->isValid()) {
        $verify = $this->vonageUtil->verify(
            $user->getVerificationRequestId(),
            $form->get('verificationCode')->getData()
        );

        if ($verify instanceof Verification) {
            $user->setVerificationRequestId(null);
            $user->setVerified(true);

            $entityManager = $this->getDoctrine()->getManager();
            $entityManager->flush();

            return $this->redirectToRoute('profile');
        }
    }

    return $this->render('registration/verify.html.twig', [
        'verificationForm' => $form->createView(),
    ]);
}
```

At this point in the tutorial, the registration process is as follows:

* on `/register` enter a phone number and password
* a phone call is received quoting a four-digit number
* redirected to `/profile`

There is currently no checking to ensure the user is verified.

## Enforcing Verification

In this step, you're going to implement an event subscriber that checks for whether the user has verified before allowing them to access secured pages. If the user is not verified, they get redirected back to the verify form to input their verification code.

In your Docker Terminal, type the command to make a new event subscriber and follow the instructions in the screen with the following values:

```bash
php bin/console make:subscriber
```

```
- Class name: `VerifiedUserSubscriber`
- Event to subscribe to: `kernel.controller`
```

The image below shows an example of what is input to complete the command:

![Verified user event subscriber](/content/blog/verify-user-registrations-with-symfony/verify-subscriber.png)

Open `VerifiedUserSubscriber` which can be found in `symfony/src/EventSubscriber/`.

Add the checks and restrictions to the onKernelController method.

First you want to check whether the user is trying to access the profile URL or not. If they aren't then return and allow them to proceed to their destination page:

```php
if (!preg_match('/^\/profile/i', $event->getRequest()->getPathInfo())) {
    return;
}
```

You now want to check whether the user has authenticated or not. To do this, inject the `tokenStorage` service into the event subscriber. While doing this, to save time, inject the `router` service for functionality after the user check.

At the top of the file along with the other class inclusions add the following:

```php
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\Routing\RouterInterface;
```

Next, inject the two services via the constructor of the class and set these services as properties within the class:

```php
/** @var RouterInterface */
protected $router;

/** @var TokenStorageInterface */
private $tokenStorage;

/**
 * @param RouterInterface $router
 * @param TokenStorageInterface $tokenStorage
 */
public function __construct(
    RouterInterface $router,
    TokenStorageInterface $tokenStorage
) {
    $this->router = $router;
    $this->tokenStorage = $tokenStorage;
}
```

Back within the `onKernelController` function, below the check for whether the user is accessing the profile or not, add the following, which checks whether the user has authenticated and whether they're verified:

```php
if (null === $user = $this->tokenStorage->getToken()->getUser()) {
    return;
}

// Check whether the user is verified, if they are, allow them to continue to their destination.
if ($user->getVerified()) {
    return;
}
```

Finally, if the user is at this point, they're a logged-in user, they're trying to access the profile section, and they're not verified. So redirect them to the verify route to make sure they have to verify their account before proceeding.

```php
$route = $this->router->generate('app_register_verify');
$event->setController(function () use ($route) {
    return new RedirectResponse($route);
});
```

## Test It!

The full method of testing this tutorial now is to register a new account on [register](http://localhost:8081/register) with a valid phone number. You are taken to [verify](http://localhost:8081/register/verify) when you submit this form.

The phone number will receive a call quoting a four-digit code, which you'll need to enter into the form on the verify page. Now [the profile](http://localhost:8081/profile) is accessible.

You've now integrated a two-step registration process into your Symfony application using the Vonage Verify API. The example provided is just one of many ways to use the Verify API. Whether it be via multi-factor authentication during login or verifying, a user's phone number is valid to ensure they are contactable.

If this tutorial has piqued your interest in our Verify API, but PHP isn't the language of your choice, other tutorials in various languages or services can be found here on the Vonage blog, such as:

* [Flexible Workflows for Verify API](https://learn.vonage.com/blog/2019/10/02/flexible-workflows-for-verify-api-dr)
* [Adding 2-Factor Authentication to WordPress with Nexmo Verify API](https://learn.vonage.com/blog/2019/10/09/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api-dr)
* [Verify Phone Numbers with Node-RED](https://learn.vonage.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [Building a Check-In App with Nexmo’s Verify API and Koa.js](https://learn.vonage.com/blog/2019/06/27/building-a-check-in-app-with-nexmos-verify-api-dr)

The finished code for this tutorial can be found on the [GitHub repository](https://github.com/nexmo-community/verify-user-registrations-with-symfony/tree/end-tutorial) in the `end-tutorial` branch.