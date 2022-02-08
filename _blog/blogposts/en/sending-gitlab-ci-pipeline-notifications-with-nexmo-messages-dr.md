---
title: Sending GitLab CI Pipeline Notifications with Nexmo Messages
description: See how to improve the CI / CD process by including SMS
  notifications powered by Nexmo in the event of a failure
thumbnail: /content/blog/sending-gitlab-ci-pipeline-notifications-with-nexmo-messages-dr/E_GitLab-CI-Pipeline_1200x600.jpg
author: nraboy
published: true
published_at: 2019-09-30T08:00:36.000Z
updated_at: 2021-05-07T13:25:41.260Z
category: tutorial
tags:
  - sms-api
  - messages-api
comments: true
spotlight: true
redirect: ""
canonical: ""
---
I operate my own blog, [The Polyglot Developer](https://www.thepolyglotdeveloper.com), which publishes as part of a continuous integration and continuous deployment pipeline. Essentially, the following series of events happens every time a `git push` is done:

1. The static site is pushed to GitLab
2. The build process of the pipeline starts
3. The deploy process of the pipeline starts
4. The static site is published and is ready for consumption

In more circumstances than I'd like to admit, the process fails because either my build failed or the deploy failed. The thing is, I don't often know that these failures happen, which sometimes causes a lot of back-tracking.

We're going to see how to improve the CI / CD process by including SMS notifications powered by Nexmo in the event of a failure.

## Understanding the GitLab CI Configuration and Process

In case you're unfamiliar with GitLab, you can make use of their CI services by including a **.gitlab-ci.yml** file at the root of your Git project. This file might look something like this:

```
image: "node:alpine"

stages:
  - build
  - deploy

build:
  stage: build
  script: 
    - npm install
    - npx gulp build
    artifacts:
      paths:
        - dist

deploy:
  stage: deploy
  script:
    - npm install
    - npx gulp deploy
```

The above configuration is fictional, but it follows a correctly formatted **.gitlab-ci.yml** file. In the above scenario, there is a `build` stage which runs the `build` gulp task and a `deploy` stage which runs the `deploy` gulp task.

If either of the two stages fails, what happens?

With GitLab CI you're able to define when certain stages run which means you can design a stage to run when there is a failure. With this in mind, we could update our **.gitlab-ci.yml** to look something like the following:

```
image: "node:alpine"

stages:
  - build
  - deploy
  - failure

build:
  stage: build
  script: 
    - npm install
    - npx gulp build
    artifacts:
      paths:
        - dist

deploy:
  stage: deploy
  script:
    - npm install
    - npx gulp deploy

failure:
  stage: failure
  script:
    - echo "failure"
  when: on_failure
```

The important piece of information is the `when` property that exists on the `failure` stage.

So now that we know how to create a GitLab CI configuration, how do we use that to our advantage for notifying us whenever there is a failure in the pipeline?

This is where Nexmo and the SMS service is valuable.

## Using the Nexmo SMS API

When our pipeline fails, we can make use of the SMS service from Nexmo to send us a text message which might include pipeline information, commit information, or really anything that might be valuable to us or the team responsible for the project.

<sign-up></sign-up>

To use the Nexmo SMS API, you'll need an account. Within the **Settings** section of your account, take note of the API key and the API secret.

![Settings](/content/blog/sending-gitlab-ci-pipeline-notifications-with-nexmo-messages/nexmo-settings.jpeg "Settings")

The API information will be required when sending SMS messages automatically.

If we really wanted to, and we shouldn't, we could create a cURL statement and hard-code all of our API and phone number information and add it directly into the GitLab CI configuration. We could, but we shouldn't. Instead, we should create pipeline environment variables in GitLab.

In the **CI / CD -> Settings** tab of your GitLab project, expand the **Variables** section.

![Gitlab env variables](/content/blog/sending-gitlab-ci-pipeline-notifications-with-nexmo-messages/gitlab-env-variables.jpeg "Gitlab env variables")

This is where you're going to want to add your sensitive information so it isn't exposed to everyone working on your project. Add the API key and API secret information as well as the destination phone number for the SMS. To protect it from the pipeline log output, make sure these variables are **Masked**, so they don't show up.

Now let's revisit the **.gitlab-ci.yml** file. To make it easier to understand, let's trim it down a bit and make it look like the following:

```
image: "alpine:latest"

stages:
  - build
  - notify

build:
  stage: build
  script: 
    - exit 1

notify:
  stage: notify
  script:
    - apk add curl
    - curl -X "POST" "https://rest.nexmo.com/sms/json" -d "from=15404161937" -d "text=${CI_PROJECT_NAME} ${CI_COMMIT_SHORT_SHA} Failed!" -d "to=${to}" -d "api_key=${api_key}" -d "api_secret=${api_secret}"
  when: on_failure
```

Notice we have just two stages, one of which only happens when there is a failure. In the `build` stage we are forcing a failure for example purposes. This failure triggers the `notify` stage where the cURL application is downloaded and an HTTP request is made to the Nexmo SMS API.

In the cURL request, certain variables are used. The `${CI_PROJECT_NAME}` and `${CI_COMMIT_SHORT_SHA}` variables are [predefined by GitLab](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html), but the `${to}`, `${api_key}`, and `${api_secret}` variables are what we had defined containing our Nexmo information.

If you push your Git project, it should send an SMS upon failure and that SMS should include the project that failed as well as the commit that failed.

## Expanding the Messaging Options with the Nexmo Messages API

The Nexmo SMS API is great, but what if you want to reach other platforms beyond simple SMS? This is where the Nexmo Messages API comes into play, which offers SMS, Facebook Messenger, Viber, and WhatsApp support.

There is a little more setup involved, but you get a lot more features as a result.

To get started, you're going to need some kind of backend service. Since Nexmo supports Node.js, it makes sense to use Node.js and JavaScript to avoid having to manufacture your own HTTP requests.

Create a new project directory, something that will be hosted outside your GitLab project. Within this directory, execute the following:

```
npm init -y
npm install nexmo@beta express --save
touch main.js
```

The above commands will create a new **package.json** file, a **main.js** file for all of the application logic, and install each of the dependencies.

The point of this backend is to control webhooks that the Nexmo service will use. When working with the Nexmo Messages API, a **status** webhook and an **inbound** webhook are required as part of the message flow.

Open the **main.js** file and include the following:

```
const Express = require("express");
const Nexmo = require('nexmo');

const server = Express();

server.use(Express.json());
server.use(Express.urlencoded({ extended: false }));

const nexmo = new Nexmo({
    apiKey: "NEXMO_API_KEY",
    apiSecret: "NEXMO_API_SECRET",
    applicationId: "NEXMO_APPLICATION_ID",
    privateKey: "NEXMO_PATH_TO_PRIVATE_KEY"
});

server.post("/status", (request, response, next) => {
    console.log(request.body);
    response.send(request.body);
});

server.post("/inbound", (request, response, next) => {
    console.log(request.body);
    response.send(request.body);
});

server.listen("3000", () => {
    console.log("Listening at :3000...");
});
```

For now, go ahead and ignore the tokens. We'll worry about obtaining those in a moment.

The above code creates a simple Node.js server with two API endpoints which will represent the necessary webhooks. In our scenario, we're only going to print out the requests that flow into the webhooks and bounce it back to the requestor.

A request coming into the **status** webhook might look like this:

```
{
    message_uuid: 'UUID_STRING',
    to: { number: 'RECIPIENT_PHONE_NUMBER', type: 'sms' },
    from: { number: 'SENDER_PHONE_NUMBER', type: 'sms' },
    timestamp: '2019-09-09T23:18:25.308Z',
    usage: { price: '0.0062', currency: 'EUR' },
    status: 'delivered'
}
```

Because we won't be receiving messages from users, the **inbound** webhook isn't too relevant for us, even though it is required.

So let's jump back into the token information:

```
const nexmo = new Nexmo({
    apiKey: "NEXMO_API_KEY",
    apiSecret: "NEXMO_API_SECRET",
    applicationId: "NEXMO_APPLICATION_ID",
    privateKey: "NEXMO_PATH_TO_PRIVATE_KEY"
});
```

As of now, you should already have the `apiKey` and `apiSecret` values from the previous example where the SMS API was used directly with cURL in the event of a failed deployment. What we don't have is the `applicationId` and the `privateKey` which is actually a file.

Within the Nexmo Dashboard, click on **Messages and Dispatch** and proceed to creating a new application.

![Nexmo Messages Application](/content/blog/sending-gitlab-ci-pipeline-notifications-with-nexmo-messages/nexmo-messages-application.png "Create messages application")

Give the application a name and provide the URL to each of the webhooks that you just created. If you're still testing locally, consider using ngrok to tunnel into localhost so that you can continue to test without deploying your application. Choose to generate a new private and public key pair and move the private key that downloads into your Node.js project directory.

When viewing the applications that you've created in the Nexmo Dashboard, you should have access to the application id of the application that we just created. Provide both the application id and the path to the private key in the `nexmo` variable that exists in our Node.js project.

In theory, as long as you're serving the webhook application, you have two options for sending messages from GitLab:

1. You can create another endpoint that uses the JavaScript SDK to send.
2. You can use cURL, but also generate a JWT.

The easier of the two options is to just add another endpoint to the webhook application, something that GitLab can execute in the event of a failure because the JavaScript SDK handles JWT generation automatically.

Within the Node.js project, include the following:

```
server.post("/notify", (request, response, next) => {
    nexmo.channel.send(
        { type: "sms", number: request.body.recipient },
        { type: "sms", number: request.body.sender },
        {
            content: {
                type: "text",
                text: request.body.message
            }
        },
        (error, data) => {
            if(error) {
                return response.status(500).send(error);
            }
            response.send(data);
        },
        { useBasicAuth: true },
    );
});
```

In the above scenario, the recipient and sender information, as well as message information, is sent with the request. Then the application will send the message and the webhooks will be used in the process.

If we were to update our GitLab CI configuration, it might look like this:

```
image: "alpine:latest"

stages:
  - build
  - notify

build:
  stage: build
  script: 
    - exit 1

notify:
  stage: notify
  script:
    - apk add curl
    - curl -X "POST" "http://HOST/notify" -H 'content-type: application/json' -d '{ "sender": "15404161937", "recipient": "${to}", "message": "${CI_PROJECT_NAME} ${CI_COMMIT_SHORT_SHA} Failed!" }'
  when: on_failure
```

In the above configuration, the Node.js application is used and a JSON payload is sent. The information in the payload is the data that was previously added as pipeline variables for the GitLab project.

Remember, with the Messages API, you can use messaging techniques beyond SMS, even though SMS was the basis of this example.

## Conclusion

You just saw how to include SMS notifications to your continuous integration and continuous deployment pipeline using Nexmo and GitLab. While we didn't create a very extravagant project in this tutorial, the concepts that were used could easily be taken to a more complex project. The point here is that you can take your Nexmo information, create environment variables for your pipeline, and set up a failure stage to notify your team with SMS.