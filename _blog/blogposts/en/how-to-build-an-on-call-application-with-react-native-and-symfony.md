---
title: How To Build an On-Call Application With React Native and Symfony
description: Learn how to build an on call application using React Native and Symfony
thumbnail: /content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/symfony-native_oncall_1200x600.png
author: greg-holmes
published: true
published_at: 2021-03-17T13:32:06.397Z
updated_at: 2021-03-02T15:19:51.088Z
category: tutorial
tags:
  - sms-api
  - voice-api
  - react-native
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Are you a developer? Have you ever been on call and had to install one of those pesky apps that notify you whenever something is a bit off? The threshold for errors has exceeded, or the server is taking too long to give responses, for example? If so, have you ever thought, "I'd like to build myself one of those services?" Well, with this tutorial, you're about to start the basics of building one of these applications and using Vonage to perform the communications.

This tutorial will help you build the beginning of an API in PHP using [Symfony](https://symfony.com/) and the mobile application using [React Native](https://reactnative.dev/).

The complete code for this tutorial can be found at our: [Community Repository](https://github.com/nexmo-community/on-call-application-api). Be sure to checkout to the `end-tutorial` branch.

## Prerequisites

To complete this tutorial you will need the following:

* [Docker](https://www.docker.com/) installed
* [Node, NPM](https://nodejs.org/en/download/),
* [Expo](https://expo.io/tools#cli)

<sign-up number></sign-up>

## Clone the Repository

```bash
git clone https://github.com/nexmo-community/on-call-application-api
cd on-call-application-api
```

## Building The API

### Generate JWT Keypair

This project will be using a mobile app built in React Native.  
You'll need to authenticate the user between the mobile application and the API. This project uses JWT to handle authentication, so certificates need to be generated to make the JWT tokens.  
In the root of your project, run the following three commands:

```bash
mkdir -p API/var/jwt # Creates a directory to store your private and public key files.
openssl genpkey -out API/var/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 # Generates your private key file
openssl pkey -in API/var/jwt/private.pem -out API/var/jwt/public.pem -pubout # Generates the public key file
```

### Exposing Your Application to the Internet

Making a phone call with Vonage requires a virtual phone number. You'll also want to set up a webhook to log the events that happen whenever a phone call is made, answered, rejected, or ended.  
For this tutorial, [ngrok](https://ngrok.com/download) is the service of choice to expose the application to the Internet. Install ngrok, and run the following command in a new Terminal window:

```bash
ngrok http 8080 # Creates an http tunnel to the Internet from your computer on port 8080
```

Make sure to copy your ngrok HTTPS URL, as you'll need this later when configuring the project.

### Environment Variables

Inside the `Docker` directory is a file called `.env.dist`; copy or rename this file to `.env`.

The first fields to update are your database credentials. The example below shows the credentials I've used for this tutorial, but please use more secure ones. 

```env
DATABASE_URL=mysql://db_user:db_password@mysql:3306/on_call?serverVersion=8.0

MYSQL_DATABASE=on_call
MYSQL_USER=db_user
MYSQL_PASSWORD=db_password
MYSQL_ROOT_PASSWORD=root_password
```

Update the values for both `VONAGE_API_KEY=` and `VONAGE_API_SECRET=`, which you can find inside the [Vonage Developer Dashboard](https://dashboard.nexmo.com/sign-in).

Then, in the dashboard, navigate to "Your Applications". Create a new application, making sure to download the `private.key` file to the project's root directory, and ensuring your application has voice capabilities.

You need to set the Event webhook URL when using the Voice API. Set this to the ngrok HTTPS URL you copied in the last section.

Update the following two:

```env
VONAGE_APPLICATION_PRIVATE_KEY_PATH=/var/www/API/private.key
VONAGE_APPLICATION_ID=<Vonage Application ID>
```

Next, link your previously purchased Vonage virtual number to your application. Then in your code, update the following inside your `.env` file inside `Docker`:

```env
VONAGE_BRAND=OnCallAlerts
VONAGE_NUMBER=<Your Vonage Virtual Number>

JWT_PASSPHRASE=<Your JWT Passphrase>
```

Finally, find `ON_CALL_NUMBER=` in the same file, and add your phone number to this value. It will need to be a real number and able to receive SMS messages and voice calls.

### Start Docker

Run the following five commands—the comments to the right of each describe what they do:

```bash
cd Docker
docker-compose up -d # To start all Docker containers for this project
docker-compose exec php bash # To create a tunnel into your PHP container
composer install # Installing all third-party libraries used in this project
php bin/console doctrine:migrations:migrate # Creates the user table already defined in `/API/migrations`
```

### Time to Build the API!

#### Make Database Entities

There are three new database tables for this project. `Alerts`, `OnCall`, and a table to link Alerts and Users together, `UserAlerts`.  
To start, run the command below and follow the instructions for input below:

```bash
php bin/console make:entity
```

For each field, please add the following:

* Class name: Alert
* Property name: title (String, 255, Not null)
* Property name: description (String, 255, Not null)
* Property name: status (String, 255, Not null)

When the command is complete, open the new file: `src/Entity/Alert.php`

There are three other classes used within this new Entity file. Add these imports at the top of the file:

```php
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Gedmo\Timestampable\Traits\TimestampableEntity;
```

One of these new classes is the TimestampableEntity, which adds `created_at` and `updated_at` fields to the database. Add `use TimestampableEntity;` at the top of the class, as shown below:

```php
class Alert
{
    use TimestampableEntity;
```

We need to add some default values within the class, so create a new construct and default the values as shown below:

```php
    public function __construct()
    {
        $this->status = 'raised';
        $this->createdAt = new \DateTime();
        $this->updatedAt = new \DateTime();
    }
```

While we're in this class, add the two functions below.  
The `getUserAssigned()` function determines which user is the current user responsible for the alert. The second function, `toArray()`, converts the values of the class into an array, ready for the API responses. 

```php
    public function getUserAssigned(): ?User
    {
        if ($this->getUserAlerts()->isEmpty()) {
            return null;
        }

        return $this
            ->getUserAlerts()
            ->first()
            ->getUser();
    }

    public function toArray()
    {
        return [
            'id' => $this->getId(),
            'title' => $this->getTitle(),
            'description' => $this->getDescription(),
            'status' => $this->getStatus(),
            'dateRaised' => $this->getCreatedAt()->format('Y-m-d H:i:s'),
            'assigned' => $this->getUserAssigned()->getName(),
            'incidentId' => $this->getId()
        ];
    }
```

To make the `OnCall` entity, which we're using to store which person is on call each week, run the command below and follow the instructions for input as listed:

```bash
php bin/console make:entity
```

For each field, please add the following:

* Class name: OnCall
* Property name: user (relation, User, ManyToOne, Not null, Add Property to User Yes)
* Property name: startDate (datetime, Not null)
* Property name: endDate (datetime, Not null)

When the command is complete, open the new file: `src/Entity/OnCall.php`

There is one other class used within this new Entity file. Add this import at the top of the file:

```php
use Gedmo\Timestampable\Traits\TimestampableEntity;
```

One of these new classes is the TimestampableEntity, which adds `created_at` and `updated_at` fields to the database, add `use TimestampableEntity;` at the top of the class as shown below:

```php
class OnCall
{
    use TimestampableEntity;
```

We need to add some default values within the class, so create a new construct and default the values as shown below:

```php
    public function __construct()
    {
        $this->createdAt = new \DateTime();
        $this->updatedAt = new \DateTime();
    }
```

To link your User and Alert entities together, you need to create a new Entity called `UserAlert`. Follow the instructions below:

```bash
php bin/console make:entity
```

* Class name: UserAlert
* Property name: user (relation, User, ManyToOne, Not null, Add Property to User Yes)
* Property name: alert (relation, Alert, ManyToOne, Not null, Add Property to Alert yes)
* Property name: smsSentAt (datetime, null)
* Property name: voiceSentAt (datetime, null)

When the command is complete, open the new file: `src/Entity/UserAlert.php`

There is one other class used within this new Entity file. Add this import at the top of the file:

```php
use Gedmo\Timestampable\Traits\TimestampableEntity;
```

One of these new classes is the TimestampableEntity, which adds `created_at` and `updated_at` fields to the database, add `use TimestampableEntity;` at the top of the class as shown below:

```php
class UserAlert
{
    use TimestampableEntity;
```

We need to add some default values within the class, so create a new construct and default the values as shown below:

```php
    public function __construct()
    {
        $this->createdAt = new \DateTime();
        $this->updatedAt = new \DateTime();
    }
```

#### Run the Migrations!

It's now time to make and run the migrations, creating new tables and columns in your database to reflect these newly created entities.

In your Terminal run:

```bash
php bin/console make:migration
php bin/console doctrine:migrations:migrate # If you wish to see what is being migrated, check the `API/migrations/` files for the SQL query
```

#### Make DataFixtures

We need to make some predefined fixtures for the `OnCall` database table to determine who is on call at a certain time. To do so, run the following command and follow the instructions listed:

```bash
php bin/console make:fixture
```

Entering the name `OnCallFixtures` will create a file inside `API/src/DataFixtures` called `OnCallFixtures.php`. Replace the contents of this file with the following:

```php
<?php

namespace App\DataFixtures;

use App\Entity\OnCall;
use Carbon\CarbonImmutable;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;
use Doctrine\Persistence\ObjectManager;

class OnCallFixtures extends Fixture implements DependentFixtureInterface
{
    public function load(ObjectManager $manager)
    {
        $currentWeek = CarbonImmutable::now();

        $onCall = new OnCall();
        $onCall
            ->setUser($this->getReference('user_1'))
            ->setStartDate($currentWeek->startOfWeek())
            ->setEndDate($currentWeek->endOfWeek());

        $manager->persist($onCall);

        $manager->flush();
    }

    public function getDependencies(): array
    {
        return [
            UserFixtures::class,
        ];
    }
}
```

Let's run your fixtures so that we have a user and an on-call record! In your terminal run:

```bash
php bin/console doctrine:fixtures:load
```

#### Make Form

When handling an API request for raising an alert, we need to validate the input to ensure it's what we expect. With Symfony, the easiest way to do this is by using a Form. With a Form, we can define what values we expect and any constraints on these values. Start by running the command below:

```bash
php bin/console make:form
```

Follow the instructions, as shown in the image:

![Creating an Alert Form Type](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/create-alert-form.png)

Now, open the newly created `AlertType.php` file found within `src/Form/` and replace the contents of the file with:

```php
<?php

namespace App\Form;

use App\Entity\Alert;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Validator\Constraints\NotBlank;
use Symfony\Component\Validator\Constraints\Length;

class AlertType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('title', TextType::class, [
                'required' => true,
                'constraints' => [
                    new Length(['min' => 5]),
                    new NotBlank()
                ]
            ])
            ->add('description', TextType::class, [
                'required' => true,
                'constraints' => [
                    new Length(['min' => 5]),
                    new NotBlank()
                ]
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults([
            'data_class' => Alert::class,
            'csrf_protection' => false,
        ]);
    }
}
```

The new code you've added to the `AlertType` class adds further constraints and requirements on the two fields in this form, `title` and `description`, to ensure they have a minimum length and are not blank.

#### Build a Vonage Util

A Utility class is needed to handle Vonage API requests when sending SMS messages and making voice calls.

In `API/src`, create a new directory called `Util`, along with a new file within this new directory called `VonageUtil.php`

You've already stored your Vonage credentials in the `.env` file earlier in this tutorial, and you'll be making use of these in this new PHP class.

In the new file add the following code:

```php
<?php

namespace App\Util;

use Vonage\Client;
use Vonage\SMS\Message\SMS;
use Vonage\Voice\Endpoint\Phone;
use Vonage\Voice\NCCO\NCCO;
use Vonage\Voice\NCCO\Action\Talk;
use Vonage\Voice\OutboundCall;

class VonageUtil
{
    /**
     * @var Client
     */
    protected $client;

    public function __construct(Client $client)
    {
        $this->client = $client;
    }
}
```

Right now, this code initialises a new PHP Class and creates a new client for Vonage API, using the Vonage Symfony wrapper for the PHP SDK.

Next, within this class, you're going to want to add two new functions, which will handle making the request to the API to send an SMS or make a voice call. Add the following two:

```php
    public function sendSms(string $to, string $from, string $text): bool
    {
        $response = $this->client->sms()->send(
            new SMS($to, $from, $text)
        );

        $message = $response->current();

        if ($message->getStatus() == 0) {
            return true;
        }

        return false;
    }

    public function makePhoneCall(string $to, string $from, string $text)
    {
        $outboundCall = new OutboundCall(
            new Phone($to),
            new Phone($from)
        );

        $ncco = new NCCO();
        $ncco->addAction(new Talk($text));
        $outboundCall->setNCCO($ncco);

        $this->client->voice()->createOutboundCall($outboundCall);
    }
```

#### Build the Webhook Controller

Before making the controller, we're going to need a Repository function to pull specific data from the database. Open the `OnCallRepository.php` found within `src/Repository`. Inside the class below the `__construct()` function, add the new function `findCurrentOnCall` which will find the current user on call.

```php
    public function findCurrentOnCall(\Carbon\Carbon $date)
    {
        return $this->createQueryBuilder('o')
            ->andWhere('o.startDate <= :date')
            ->andWhere('o.endDate >= :date')
            ->setParameter('date', $date->format('Y-m-d H:i:s'))
            ->getQuery()
            ->getOneOrNullResult();
    }
```

We've created the functionality to pull the data. Next, let's create a controller to handle any requests and pull the data.  
First, in your Terminal, run the following:

```bash
php bin/console make:controller
```

When asked for the name of your controller, input `WebhookController`.

Open the newly created file: `API/src/Controller/WebhookController.php`.

We will be using all of the following classes, so let's make sure we include them from the beginning. At the top of the file, just below `namespace App\Controller;` add the following:

```php
use App\Entity\Alert;
use App\Entity\OnCall;
use App\Entity\UserAlert;
use App\Form\AlertType;
use App\Util\VonageUtil;
use Carbon\Carbon;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\EventDispatcher\EventDispatcher;
use Symfony\Component\Form\Form;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
```

Your class needs a construct for Symfony to inject the EntityManager and the VonageUtil classes. At the top of your class, add:

```php
    /** @var VonageUtil */
    protected $vonageUtil;

    /** @var EntityManagerInterface */
    private $entityManager;

    public function __construct(
        VonageUtil $vonageUtil,
        EntityManagerInterface $entityManager
    ) {
        $this->vonageUtil = $vonageUtil;
        $this->entityManager = $entityManager;
    }
```

Now replace the `index()` function with the code below to create new alerts. This new function handles the POST request body, creates this data as a new `Alert`, and passes that alert into the Form to validate the values. If all is as expected, it will then create a new `UserAlert`, with the person currently on call as the person receiving the alert.

```php
    /**
     * @Route("/webhooks/raise_alert", name="raise_alert", methods={"POST"})
     */
    public function index(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        // Create an alert.
        $alert = (new Alert())
            ->setStatus('raised');

        $form = $this->createForm(AlertType::class, $alert);
        $form->submit($data);

        if ($form->isSubmitted() && $form->isValid()) {
            $entityManager = $this->getDoctrine()->getManager();
            $entityManager->persist($alert);
            $entityManager->flush();

            // Get the on call user
            $onCall = $this->entityManager
                ->getRepository(OnCall::class)
                ->findCurrentOnCall(Carbon::now());

            if (!$onCall) {
                return new JsonResponse(['message' => 'No Alerts found.'], 400);
            }

            // Create a UserAlert
            $userAlert = (new UserAlert())
                ->setUser($onCall->getUser())
                ->setAlert($alert);
            $entityManager->persist($userAlert);

            // Notify the on call user
            $this->vonageUtil->sendSms(
                $onCall->getUser()->getPhoneNumber(),
                getenv('VONAGE_BRAND'),
                'A new alert has been raised, please log into the mobile app to investigate.'
            );

            // Save this update to the user alert
            $userAlert->setSmsSentAt(Carbon::now());

            $entityManager->flush();

            return new JsonResponse([], 201);
        }

        return new JsonResponse($this->getErrorMessages($form), 400);
    }
```

You may have noticed that the function `$this->getErrorMessages()` is called at the bottom, but your class doesn't have it yet. You'll need to add this function next. It will retrieve all the form errors found when the endpoint is triggered, but some data is missing. Below your `index()` method, add the following:

```php
    private function getErrorMessages(Form $form): array
    {
        $errors = [];

        foreach ($form->getErrors() as $key => $error) {
            if ($form->isRoot()) {
                $errors['#'][] = $error->getMessage();
            } else {
                $errors[] = $error->getMessage();
            }
        }

        foreach ($form->all() as $child) {
            if (!$child->isValid()) {
                $errors[$child->getName()] = $this->getErrorMessages($child);
            }
        }

        return $errors;
    }
```

We're at a point where we can test this now!

#### Test the Authentication

There are two endpoints at this part of the tutorial that we can test with our API, so with Docker still running in the background, make a `POST` request to `http://localhost:8080/api/login_check` with the JSON body of:

```json
{
    "username": "dev+1@company.com",
    "password": "test_pass"
}
```

The response will be a JSON object with a key `token`, and the value is a JWT token.

The image below shows an example of doing this with Postman:

![An example of authenticating with Postman](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/login.png)

#### Test Raising an Alert

You don't need to be authenticated in this example to raise an alert, so no need to use the JWT from the previous example. 

To raise an alert, update the URL field: `http://localhost:8080/webhooks/raise_alert`, keep the method as a `POST` request, and the JSON body of:

```json
{
    "title": "ERRORRRRRR ASAP FIX NOW ITS BORKED",
    "description": "THE PAGE AINT LOADING TOP PRIORITY FIX ASAP."
}
```

The response will be an empty array and the HTTP status code of 201 (created). You can see an example of this request in Postman in the image below:

![An example of raising an alert with Postman](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/raise-alert.png)

#### How to Handle an Alert

Symfony's Workflow component allows you to define a life cycle your object can go through with its statuses. Each step your object can go through is called a place, with the transitions defining the action the object needs to take to get from one place to another.

Workflows will allow you to define which places your alert can be in to get from being `raised` to the last step, which is either `cancelled` or `completed`.

Open the `workflow.yaml` file found within `config/packages/` and replace the contents with the example below:

```yaml
framework:
    workflows:
        alerts:
            type: 'state_machine'
            supports:
                - App\Entity\Alert
            marking_store:
                type: 'method'
                property: 'status'
            initial_marking: new
            places:
                - new
                - raised
                - accepted
                - cancelled
                - completed
            transitions:
                raise:
                    from: [new]
                    to: raised
                accept:
                    from: [raised]
                    to: accepted
                cancel:
                    from: [raised, accepted]
                    to: cancelled
                complete:
                    from: [accepted]
                    to: completed
```

A controller is now needed to handle all of the API requests regarding `Alerts`. So, run the command below to start making our new AlertsApiController:

```bash
php bin/console make:controller
```

When it asks for a Controller name, submit `AlertsApiController`. This command will create a new `AlertsApiController.php` file within `src/Controllers`. So open this new file.

We will be using all of the following classes, so let's make sure we include them from the beginning. At the top of the file, just below `namespace App\Controller;` add the following:

```php
use App\Entity\Alert;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Workflow\Registry;
```

Add your class based routing as shown in the example below, so that any routes within this class are prefixed with `/api/alerts/`:

```php
/** 
 * @Route("/api/alerts")
 */
class AlertsApiController extends AbstractController
{
```

This controller will use the `$workflowRegistry` and `$entityManager` in several places of this class, so to avoid rewriting code in several places, we'll place these inside the construct. Add the following code to the top of your class:

```php
    /** Registry */
    private $workflowRegistry;

    /** EntityManagerInterface */
    private $entityManager;

    public function __construct(Registry $workflowRegistry, EntityManagerInterface $entityManager)
    {
        $this->workflowRegistry = $workflowRegistry;
        $this->entityManager = $entityManager;
    }
```

When the controller was created, a function named `index()` was automatically added. We're not going to need it for this project, so delete that function.

Now we'll create our `listAction()` which will retrieve all alerts from the database and return them as a JSON response. Add the `listAction()` to your controller as shown below:

```php
    /**
     * @Route("", methods={"GET"})
     */
    public function listAction(): JsonResponse
    {
        $data = $this->entityManager
            ->getRepository(Alert::class)
            ->findAll();

        $alerts = [];

        foreach ($data as $alert) {
            $alerts[] = $alert->toArray();
        }

        return new JsonResponse(
            $alerts, 
            JsonResponse::HTTP_OK
        );
    }
```

Next, we'll create `readAction()` to retrieve one alert by ID from the database and return it as a JSON response. Add `readAction()` to your controller as shown below:

```php
    /**
     * @Route("/{id}", methods={"GET"})
     */
    public function readAction(int $id): JsonResponse
    {
        $alert = $this->entityManager
            ->getRepository(Alert::class)
            ->findOneById($id);
        
        if (!$alert) {
            return new JsonResponse(
                null,
                JsonResponse::HTTP_NOT_FOUND
            );
        }

        return new JsonResponse(
            $alert->toArray(), 
            JsonResponse::HTTP_OK
        );
    }
```

We'll create our `acceptAction()`, which will find an alert by ID from the database; if one is found, it will try to transition the status of this alert from `pending` to `accepted`. The response will be an empty JSON response with the HTTP status code of 200.  
Add the `acceptAction()` to your controller as shown below:

```php
    /**
     * @Route("/{id}/accept", methods={"POST"})
     */
    public function acceptAction(int $id): JsonResponse
    {
        $alert = $this->entityManager
            ->getRepository(Alert::class)
            ->findOneById($id);

        if (!$alert) {
            return new JsonResponse(null, JsonResponse::HTTP_NOT_FOUND);
        }

        $workflow = $this->workflowRegistry->get($alert);

        try {
            $workflow->apply($alert, 'accept');

            $this->entityManager->flush();
        } catch (LogicException $exception) {
            return new JsonResponse(['message' => $exception->getMessage()], 400);
        }

        return new JsonResponse([], 200);
    }
```

Next, we'll create our `completeAction()`, which will find an alert by ID from the database; if one is found, it will try to transition the status of this alert from `accepted` to `completed`. The response will be an empty JSON response with the HTTP status code of 200.  
Add the `completeAction()` to your controller as shown below:

```php
    /**
     * @Route("/{id}/complete", methods={"POST"})
     */
    public function completeAction(int $id): JsonResponse
    {
        $alert = $this->entityManager
            ->getRepository(Alert::class)
            ->findOneById($id);

        if (!$alert) {
            return new JsonResponse(null, JsonResponse::HTTP_NOT_FOUND);
        }

        $workflow = $this->workflowRegistry->get($alert);

        try {
            $workflow->apply($alert, 'complete');

            $this->entityManager->flush();
        } catch (LogicException $exception) {
            return new JsonResponse(['message' => $exception->getMessage()], 400);
        }

        return new JsonResponse([], 200);
    }
```

Finally, we'll create our `cancelAction()`, which will find an alert by ID from the database; if one is found, it will try to transition the status of this alert from `accepted` or `pending` to `cancelled`. The response will be an empty JSON response with the HTTP status code of 200.  
Add the `cancelAction()` to your controller as shown below:

```php
    /**
     * @Route("/{id}/cancel", methods={"POST"})
     */
    public function cancelAction(int $id): JsonResponse
    {
        $alert = $this->entityManager
            ->getRepository(Alert::class)
            ->findOneById($id);

        if (!$alert) {
            return new JsonResponse(null, JsonResponse::HTTP_NOT_FOUND);
        }

        $workflow = $this->workflowRegistry->get($alert);

        try {
            $workflow->apply($alert, 'cancel');

            $this->entityManager->flush();
        } catch (LogicException $exception) {
            return new JsonResponse(['message' => $exception->getMessage()], 400);
        }

        return new JsonResponse([], 200);
    }
```

To summarise, we've added a configuration to our project that controls our alert's flow through its lifecycle. We've then created an API controller that will allow us to retrieve a list of our alerts, retrieve a specific alert, accept, decline, cancel or complete the alerts depending on their status.

#### Create the Escalation Command

What if the SMS hasn't been received? Or is it ignored?! Well, worry not! The next step is to implement a Symfony Command that will run as a time-based job scheduler (Cron job) and escalate all alerts older than 10 minutes. 

Before creating this command, we'll need to add a repository method to retrieve alerts requiring escalation. Open your `UserAlertRepository.php` file within `API/src/Repository/`.

At the top of this file, add some more third party libraries for importing:

```php
use App\Entity\Alert;
use App\Entity\UserAlert;
use Carbon\Carbon;
```

Next, add the repository method to retrieve all alerts that have had an SMS sent over 10 minutes ago but are still in the status of `raised`:

```php
    public function findRaisedUserAlerts()
    {
        $queryBuilder = $this->createQueryBuilder('ua');
        $lastAlertSent = (Carbon::now())
            ->sub('10 minutes');

        return $queryBuilder
            ->join(Alert::class, 'a', Join::WITH, $queryBuilder->expr()->andX(
                $queryBuilder->expr()->eq('a', 'ua.alert'),
                $queryBuilder->expr()->eq('a.status', ':alertStatus')
            ))
            ->where($queryBuilder->expr()->isNull('ua.voiceSentAt'))
            ->andWhere($queryBuilder->expr()->lte('ua.smsSentAt', ':smsSentAt'))
            ->setParameter('alertStatus', 'raised')
            ->setParameter('smsSentAt', $lastAlertSent->format('Y-m-d H:i:s'))
            ->getQuery()
            ->getResult();
    }
```

This new Symfony Command will escalate all retrieved alerts. To create it, run the following command in your Terminal:

```bash
php bin/console make:command
```

When asked for the command name, enter `app:escalate-alert`, which creates a new file called `EscalateAlertCommand.php` within `API/src/Command`. Open this new file.

We will be using all of the following classes, so let's make sure we include them from the beginning. At the top of the file, just below `namespace App\Command;` add the following:

```php
use App\Entity\UserAlert;
use App\Util\VonageUtil;
use Carbon\Carbon;
use Doctrine\ORM\EntityManagerInterface;
```

The class needs two objects injecting into it, the `VonageUtil` and `EntityManagerInterface`. With Symfony, the easiest way to do this is via the constructor. At the top of your class, add the following functionality:

```php
    /** @var VonageUtil */
    protected $vonageUtil;

    /** @var EntityManagerInterface */
    private $entityManager;

    public function __construct(
        VonageUtil $vonageUtil,
        EntityManagerInterface $entityManager
    ) {
        $this->vonageUtil = $vonageUtil;
        $this->entityManager = $entityManager;

        parent::__construct();
    }
```

Now it's time to write the functionality for this command. It will retrieve all Alerts with an SMS sent over 10 minutes ago, but still with `raised` status. If there are any of these, it will retrieve the user assigned to the alert and send them a Text-To-Speech voice call notification. Replace current functionality within `protected function execute()` with:

```php
        $io = new SymfonyStyle($input, $output);

        $userAlertRepository = $this->entityManager->getRepository(UserAlert::class);
        $userAlerts = $userAlertRepository->findRaiseduserAlerts();

        if (!$userAlerts) {
            $io->warning('There are no alerts needing to be raised.');
        }

        /** @var UserAlert $userAlert */
        foreach ($userAlerts as $userAlert) {
            $this->vonageUtil->makePhoneCall(
                $userAlert->getUser()->getPhoneNumber(),
                getenv('VONAGE_NUMBER'),
                'A new alert has been raised, please log into the mobile app to investigate.'
            );

            $userAlert->setVoiceSentAt(Carbon::now());
            $this->entityManager->flush();
        }

        return Command::SUCCESS;
```

### Test the API

Your user needs authenticating to test these new endpoints.  
First, make sure you get your JWT token by sending a `POST` request to `http://localhost:8080/api/login_check` with your fixtured users credentials.

Once you've copied your JWT, update the type to be a `GET` request and the URL to be `http://localhost:8080/api/alerts`. You need to provide a header with the key `Authorisation` and the value as `Bearer <JWT>` replacing `<JWT>` with your token.

The list Alerts endpoint returns a JSON array, which you can see in the Postman example below:

![An example of listing alerts through Postman](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/list-alerts.png)

Let's keep that alert in its current state and use it later when testing the mobile application.

You've built an API; it's now time to create the mobile application.

## Build the Mobile App

Update `config.json` where the value of the `APIURL` is the ngrok URL you saved previously.

Open a new Terminal window and run the following commands:

```bash
cd MobileApp
npm install
expo start
```

After a little while, a web browser opens. On the left-hand side, there are multiple options to run the application through, whether on your mobile device, iOS simulator or Android simulator. Choose the option that suits you, and when the application boots up, the Login Screen will be the first screen you see. 

The fixtured user's credentials in the database are:

```
username: dev+1@company.com
password: test_pass
```

As shown in the image below:

![Example of a login screen on a mobile phone](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/login-screen.jpg)

A successful log in won't currently do anything! We need to implement more screens first, but to double-check your login was correct, check your Terminal where you ran `expo start`. You should see the line: `You Successfully logged in!`.

### Alerts API

### Showing a List of Alerts

Inside the `API` directory, create a new file called `alerts.js`.   
Add the example below, which imports the `client.js` file to use the functionality from `getClient()`.  
This new function called `getAlerts()` makes a request to the API on the endpoint `/api/alerts`. We can add the other API calls, accept, complete, and cancel alerts while we're here.

```js
import { getClient } from "./client.js";

export function getAlerts() {
  return getClient()
    .then(function(client) {
      return client.get("/api/alerts");
    });
};

export function acceptAlert(alertId) {
  return getClient()
    .then(function(client) {
      return client.post(`/api/alerts/${alertId}/accept`);
    });
};

export function cancelAlert(alertId) {
  return getClient()
    .then(function(client) {
      return client.post(`/api/alerts/${alertId}/cancel`);
    });
};

export function completeAlert(alertId) {
  return getClient()
    .then(function(client) {
      return client.post(`/api/alerts/${alertId}/complete`);
    })
};
```

Now that we have the functionality to get the alerts, build the AlertsScreen component. Create a new file inside `components/` called `AlertsScreen.js`.

```js
import React, { Component } from 'react'
import { FlatList, Text, View, StyleSheet, StatusBar } from 'react-native'
import { TouchableOpacity } from 'react-native-gesture-handler';
import { getAlerts } from '../api/alerts.js'

class AlertsScreen extends Component {

}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: StatusBar.currentHeight || 0,
  },
  header: {
    backgroundColor: '#03A5C9',
    padding: 10,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
  },
  body: {
    padding: 10,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  item: {
    marginVertical: 8,
    marginHorizontal: 16,
    paddingBottom: 10,
    borderWidth: 1,
    borderRadius: 20
  },
  title: {
    fontSize: 24,
  },
  incidentId: {
    textAlign: 'right'
  }
});

export default AlertsScreen;
```

We now have an empty `AlertsScreen` class and some styling. Lets add to this class to show something:

```js
  state = {
    alerts: []
  }

  renderItem = ({ item }) => (
    <View style={styles.item}>
      <TouchableOpacity onPress={() => this.onPress(item)}>
        <View style={styles.header}>
          <Text style={styles.title}>
            {item.title}
          </Text>
        </View>
        <View style={styles.body}>
          <Text>
            {item.dateRaised}
          </Text>
          <Text>
            {item.assigned !== '' ? item.assigned : 'Unassigned'}
          </Text>
          <Text style={styles.incidentId}>
            #{item.incidentId}
          </Text>
        </View>
      </TouchableOpacity>
    </View>
  );

  render() {
    return (
      <View>
        <FlatList
          data={this.state.alerts}
          renderItem={this.renderItem}
          keyExtractor={item => item.id}
        />
      </View>
    );
  }
```

Ok, this is showing us our page. But it isn't retrieving any information and doesn't tell us what to do next!

Above your `renderItem()` method, add the following:

```js
  componentDidMount() {
    getAlerts()
      .then(response => {
        return response.data.map(alert => ({
          id: `${alert.id}`,
          title: `${alert.title}`,
          description: `${alert.description}`,
          dateRaised: `${alert.dateRaised}`,
          assigned: `${alert.assigned}`,
          incidentId: `${alert.incidentId}`,
          status: `${alert.status}`
        }))
      })
      .then(alerts => {
        this.setState({ alerts: alerts });
      })
      .catch((err) => console.log(err));
  }

  onPress = (item) => {
    return this.props.navigation.navigate('Alert', {
      alert: item,
    })
  }
```

### Showing a Specific Alert

Create a new file in `components` called `AlertScreen.js`, which shows the specific alert by ID.

```js
import React, { Component } from 'react'
import { Text, View, ScrollView, StyleSheet, StatusBar, TouchableOpacity } from 'react-native'
import { acceptAlert, cancelAlert, completeAlert } from '../api/alerts.js'

class AlertScreen extends Component {
  state = {
    alert: {}
  }
  
  const = this.state.alert = this.props.route.params.alert;

  onPressComplete = () => {
    completeAlert(this.state.alert.id)
      .then(() => {
        this.setState({ alert: { ...this.state.alert, status: 'completed'} });
      })
      .catch((err) => console.log(err));
  }

  onPressCancel = () => {
    cancelAlert(this.state.alert.id)
      .then(() => {
        this.setState({ alert: { ...this.state.alert, status: 'cancelled'} });
      })
      .catch((err) => console.log(err));
  }

  onPressAccept = () => {
    acceptAlert(this.state.alert.id)
      .then(() => {
        this.setState({ alert: { ...this.state.alert, status: 'accepted'} });
      })
      .catch((err) => console.log(err));
  }

  render() {
    let buttons;

    if (this.state.alert.status === 'raised') {
      buttons = <View style={styles.buttonContainer}>
          <View style={styles.buttonView}>
            <TouchableOpacity
              style={styles.button}
              onPress={() => this.onPressAccept()}
              underlayColor='#fff'>
              <Text style={styles.actionText}>Accept</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.buttonView}>
            <TouchableOpacity
              style={styles.button}
              onPress={() => this.onPressCancel()}
              underlayColor='#fff'>
              <Text style={styles.actionText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
    } else if (this.state.alert.status === 'accepted') {
      buttons = <View style={styles.buttonContainer}>
          <View style={styles.buttonView}>
            <TouchableOpacity
              style={styles.button}
              onPress={() => this.onPressComplete()}
              underlayColor='#fff'>
              <Text style={styles.actionText}>Complete</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.buttonView}>
            <TouchableOpacity
              style={styles.button}
              onPress={() => this.onPressCancel()}
              underlayColor='#fff'>
              <Text style={styles.actionText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
    }

    return (
      <View style={styles.item}>
        <View style={styles.header}>
          <Text style={styles.title}>
            {this.state.alert.title}
          </Text>
        </View>
        <View style={styles.body}>
          <Text>
            Date Raised: {this.state.alert.raisedDate}
          </Text>
          <Text>
            Assignee: {this.state.alert.assigned !== '' ? this.state.alert.assigned : 'Unassigned'}
          </Text>
          <Text style={styles.incidentId}>
            Incident ID: #{this.state.alert.incidentId}
          </Text>
          <Text style={styles.status}>
            Status: {this.state.alert.status}
          </Text>
        </View>
        {buttons}
        <View style={styles.scrollView}>
          <ScrollView>
            <Text style={styles.text}>
              {this.state.alert.description}
            </Text>
          </ScrollView>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: StatusBar.currentHeight || 0,
  },
  header: {
    backgroundColor: '#03A5C9',
    padding: 10,
  },
  body: {
    padding: 10,
  },
  item: {
    paddingBottom: 10,
  },
  title: {
    fontSize: 24,
  },
  buttonContainer: {
    flex: 1,
    flexDirection: "row",
    alignItems: 'center',
    justifyContent: 'center',
    paddingBottom: 30
  },
  buttonView: {
    flex: 1,
    height: 10
  },
  button: {
    marginRight: 40,
    marginLeft: 40,
    marginTop: 10,
    paddingTop: 10,
    paddingBottom: 10,
    backgroundColor: '#1E6738',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff'
  },
  actionText: {
      color: '#fff',
      textAlign: 'center',
      paddingLeft: 10,
      paddingRight: 10
  },
  text: {
    fontSize: 20,
  },
});

export default AlertScreen;
```

Your application currently has no instruction on how to show these two new screens you've created. In `navigation/MainStackNavigator.js` below `import Login`, add the following two lines:

```js
import Alert from '../components/AlertScreen';
import Alerts from '../components/AlertsScreen';
```

Then below the Login `Stack.Screen`, add two new Screens:

```js
        <Stack.Screen 
          name='Alerts' 
          component={Alerts} 
          options={{ title: 'Alerts Screen' }}
        />
        <Stack.Screen
          name='Alert'
          component={Alert}
          options={({route, navigation}) => (
            {headerTitle: 'Alert Screen', 
            route: {route}, 
            navigation: {navigation}}
          )}
        />
```

Back in your `LoginScreen.js` file, find the line showing: `console.log('You Successfully logged in!');` and add the snippet below to redirect the user on a successful login.

```js
  return this.props.navigation.navigate('Alerts');
```

## Testing

To test this app in your Terminal, make sure you've navigated to the `MobileApp` directory, and run the following command:

```bash
expo start
```

After a little while, a web browser should open. On the left-hand side, there are multiple options to run the application through, whether it's on your mobile device, iOS simulator or Android simulator. Choose the option that suits you. When the application starts, the first screen you see is the Login screen.

The fixtured user's credentials in the database are:

```
username: dev+1@company.com
password: test_pass
```

On successful login, the next screen you see is the Alerts screen. However, this will be empty right now because, in the database, there aren't any alerts.

![An example of raising an alert with Postman](/content/blog/how-to-build-an-on-call-application-with-react-native-and-symfony/raise-alert.png)

Now, retry logging into your mobile application. You'll see the new alert, and you'll also be able to click on this alert to be taken to a screen that shows more information. 

You can also transition this alert, whether it is to be accepted or cancelled.

## Conclusion

In this tutorial, we've learned how to build an API using a PHP framework called Symfony. We've also built a mobile application using React Native. Vonage's APIs allowed us to send notifications via SMS and Text-To-Speech voice calls. By applying all of these together, we've built ourselves a functional on-call application for developers or system administrators to be alerted when anything goes wrong. Having a webhook allows us to integrate our on-call system with multiple services to cover as many as possible.

Below are a few other tutorials we've written implementing the Vonage Voice API into projects:

* [Befriending Service with Symfony and Vonage](https://learn.vonage.com/blog/2020/06/08/befriending-service-with-symfony-and-vonage/)
* [Text-To-Speech: Let Your Application Speak, Now in 50 Languages!](hhttps://learn.vonage.com/blog/2020/12/01/text-to-speech-let-your-application-speak-now-in-50-languages/)
* [AWS Transcribe With Nexmo Voice Using PHP](https://learn.vonage.com/blog/2020/02/14/aws-transcribe-with-nexmo-voice-using-php-dr/)

As always, if you have any questions, advice or ideas you’d like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack). I'd love to hear how you've gotten on with this tutorial and how your project works.
