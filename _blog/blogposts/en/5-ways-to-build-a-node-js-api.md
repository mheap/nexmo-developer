---
title: 5 Ways to Build a Node.js API
description: 5 ways to build lightweight Node.js APIs, using popular frameworks
  or Node's standard libraries.
thumbnail: /content/blog/5-ways-to-build-a-node-js-api/Blog_Node-js_APIs_1200x600.png
author: lukeoliff
published: true
published_at: 2020-08-11T13:28:42.000Z
updated_at: 2021-05-11T17:52:25.237Z
category: inspiration
tags:
  - express
  - node
  - http
comments: true
redirect: ""
canonical: ""
---
This article will help you build a small API in five ways, using [Node.js](https://nodejs.org/en/) and four popular frameworks.

[Express.js](https://expressjs.com/) is one of the many HTTP frameworks available for [Node.js](https://nodejs.org/en/). We use it for a lot of our [Node.js](https://nodejs.org/en/) content, due to the large variety of addons and its large support community.

The similarities of producing the same functionality in different frameworks may help to provide some insight when implementing one of our demos in a different framework to the one in the tutorial. I hope.

## Express.js

We'll start with the familiar. [Express.js](https://expressjs.com/) is a lightweight and "unopinionated" framework for producing [Node.js](https://nodejs.org/en/) based web and mobile applications.

### Create a Server

Make a project directory with your IDE or this command.

```shell
mkdir rest-express
cd rest-express
```

Create a file for your application (usually `app.js` or `index.js`).

```shell
touch index.js
```

Initialise the project with NPM by generating basic NPM package files without having to answer any questions with the `y` flag.

```shell
npm init -y
```

Install the [Express.js](https://expressjs.com/) package.

```shell
npm install express
```

Modify `index.js` and add the following source code to create your app and the `example` route.

```js
// index.js

const express = require('express')

const app = express()
const port = process.env.PORT || 3000

app.get('/example', (req, res) => {
  res.json({ message: 'Looks good to me!' })
})

app.listen(port, () => {
  console.log(`listening on port ${port}`)
})
```

### Run the Server

Start the app using the `node` command line. You might be used to `npm start` which in a lot of instances just runs this command on your application file anyway.

```shell
node index.js
```

Now you can make a request using Postman to see the response.

![Screenshot of making a request to the Express.js example API using Postman](/content/blog/5-ways-to-build-a-node-js-api/rest-express.png)

## Node.js Standard Libraries

[Node.js](https://nodejs.org/en/) has built-in packages capable of listening for HTTP requests, and constructing responses. The other frameworks simplify this, along with adding multiple other features you'd otherwise have to build.

### Create a Server

Make a project directory with your IDE or this command.

```shell
mkdir rest-node-only
cd rest-node-only
```

Create a file for your application (usually `app.js` or `index.js`).

```shell
touch index.js
```

We don't need to initialise NPM until we need to install packages. For this example, we'll use packages built into [Node.js](https://nodejs.org/en/) so we don't need NPM or any package files (🎉🎉🎉 AND NO `node_modules` DIRECTORY 🎉🎉🎉).

Modify `index.js` and add the following source code to create your app and the `example` route.

```js
// index.js

const http = require('http')

const port = process.env.PORT || 3000

const requestHandler = (req, res) => {
  if (req.url === '/example'  && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ message: 'Node.js only: Looks good to me!' }))
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ message: 'Not found!' }))
  }
}

const server = http.createServer(requestHandler)

server.listen(port, () => {
  console.log(`listening on port ${port}`)
})
```

### Run the Server

Start the app using the `node` command line.

```shell
node index.js
```

Now you can make a request using Postman to see the response.

![Screenshot of making a request to the Node.js example API using Postman](/content/blog/5-ways-to-build-a-node-js-api/rest-node-only.png)

## Koa.js

[Koa.js](https://koajs.com/), designed by the same devs behind [Express.js](https://expressjs.com/), has been built to be more lightweight and expressive, allowing for thinner code and greatly increase error-handling. As such, it comes with less baked-in features and a large suite of community extensions.

### Create a Server

Make a project directory with your IDE or this command.

```shell
mkdir rest-koa
cd rest-koa
```

Create a file for your application (usually `app.js` or `index.js`).

```shell
touch index.js
```

Initialise the project with NPM by generating basic NPM package files without having to answer any questions with the `y` flag.

```shell
npm init -y
```

Install [Koa.js](https://koajs.com/) and the supporting packages for routing and sending JSON responses. ***Note:** Koa doesn't support routing (besides url conditions), or JSON responses, without extra package.*

```shell
npm install koa @koa/router koa-json
```

Modify `index.js` and add the following source code to create your app and the `example` route.

```js
// index.js

const Koa = require('koa')
const Router = require('@koa/router')
const json = require('koa-json')

const app = new Koa()
const router = new Router()
const port = process.env.PORT || 3000

app
  .use(router.routes())
  .use(router.allowedMethods())
  .use(json({ pretty: false }))

router.get('/example', (ctx) => {
  ctx.body = { message: 'Koa.js: Looks good to me!' }
})

app.listen(3000)
```

### Run the Server

Start the app using the `node` command line.

```shell
node index.js
```

Now you can make a request using Postman to see the response.

![Screenshot of making a request to the Koa.js example API using Postman](/content/blog/5-ways-to-build-a-node-js-api/rest-koa.png)

## Restify

[Restify](http://restify.com/) is a [Node.js](https://nodejs.org/en/) framework optimised for building semantically correct RESTful web services ready for production use at scale.

### Create a Server

Make a project directory with your IDE or this command.

```shell
mkdir rest-restify
cd rest-restify
```

Create a file for your application (usually `app.js` or `index.js`).

```shell
touch index.js
```

Initialise the project with NPM by generating basic NPM package files without having to answer any questions with the `y` flag.

```shell
npm init -y
```

Install the [Restify](http://restify.com/) package.

```shell
npm install restify
```

Modify `index.js` and add the following source code to create your app and the `example` route.

```js
// index.js

var restify = require('restify')

const port = process.env.PORT || 3000
var server = restify.createServer()

server.get('/example', (req, res, next) => {
  res.json({ message: 'Restify: Looks good to me!' })
  next()
})

server.listen(port, function() {
  console.log(`listening on port ${port}`)
})
```

### Run the Server

Start the app using the `node` command line.

```shell
node index.js
```

Now you can make a request using Postman to see the response.

![Screenshot of making a request to the Restify example API using Postman](/content/blog/5-ways-to-build-a-node-js-api/rest-restify.png)

## Hapi

[hapi](https://hapi.dev/) is an extremely scalable and capable framework for [Node.js](https://nodejs.org/en/). Developed initially to handle Walmart’s Black Friday traffic at scale, [hapi](https://hapi.dev/) continues to be the proven choice for enterprise-grade backend needs.

### Create a Server

Make a project directory with your IDE or this command.

```shell
mkdir rest-hapi
cd rest-hapi
```

Create a file for your application (usually `app.js` or `index.js`).

```shell
touch index.js
```

Initialise the project with NPM by generating basic NPM package files without having to answer any questions with the `y` flag.

```shell
npm init -y
```

Install the [hapi](https://hapi.dev/) package.

```shell
npm install @hapi/hapi
```

Modify `index.js` and add the following source code to create your app and the `example` route.

```js
// index.js

const Hapi = require('@hapi/hapi')

const port = process.env.PORT || 3000

const init = async () => {
  const server = Hapi.server({
    port: port,
    host: 'localhost'
  })

  server.route({
    method: 'GET',
    path: '/example',
    handler: (req, h) => {
      return { message: 'hapi: Looks good to me!' }
    }
  })

  await server.start()
  console.log('Server running on %s', server.info.uri)
}

init()
```

### Run the Server

Start the app using the `node` command line.

```shell
node index.js
```

Now you can make a request using Postman to see the response.

![Screenshot of making a request to the hapi example API using Postman](/content/blog/5-ways-to-build-a-node-js-api/rest-hapi.png)

## Conclusion

[Node.js](https://nodejs.org/en/) can be used barebones, but you pay the price in supporting your own solutions to features like routing and response types. Your application will be fast, with little package bloat, if you're familiar with how best to optimise your code for performance. You **can** find open-source solutions for routing and other features, without using a framework like those here, but at that point, you may as well use a framework.

While [Express.js](https://expressjs.com/) is unopinionated, it has a lot of built-in features. It's not the fastest, but that doesn't mean it's slow. It is certainly the easiest to get started with.

[Restify](http://restify.com/) is built purposely to scale RESTful applications and despite its simplicity is used in some of the largest [Node.js](https://nodejs.org/en/) deployments in the world.

[hapi](https://hapi.dev/) is built to scale fast while being feature complete and enterprise-ready.

[Koa.js](https://koajs.com/) is an async-friendly alternative to [Express.js](https://expressjs.com/), without the built-in features.

Lots of developers will pick the one with the best support or largest community, which for me is a clear choice between [hapi](https://hapi.dev/) and [Express.js](https://expressjs.com/).

## All the Code

You can find [a single repository with all the code in on GitHub](https://github.com/lukeocodes/example-node-apis), in case you have trouble with the examples here.

## Further Reading

* [How to Add Two-Factor Authentication](https://www.nexmo.com/blog/2020/07/17/how-to-add-two-factor-authentication-with-node-js-and-express)
* [Building a Check-In App with Nexmo’s Verify API and Koa.js](https://www.nexmo.com/blog/2019/06/27/building-a-check-in-app-with-nexmos-verify-api-dr)
* [Add SMS Verification in a React Native App Using Node.js and Express](https://www.nexmo.com/blog/2020/05/26/add-sms-verification-in-a-react-native-app-using-node-js-and-express-dr)
* [Forward a Call Via Voice Proxy With Koa.js](https://www.nexmo.com/blog/2019/02/05/forward-call-with-koa-js-dr)
* [Forward Nexmo SMS to Slack using Express and Node](https://www.nexmo.com/blog/2020/01/01/forward-nexmo-sms-to-slack-using-express-and-node-dr)
* [Getting Started with Nexmo’s Number Insight APIs on Koa.js](https://www.nexmo.com/blog/2019/02/21/getting-started-with-nexmos-number-insight-apis-on-koa-js-dr)
* [How to Send and Receive SMS Messages With Node.js and Express](https://www.nexmo.com/blog/2019/09/16/how-to-send-and-receive-sms-messages-with-node-js-and-express-dr)
* [Building a Check-In App with Nexmo’s Verify API and Koa.js](https://www.nexmo.com/blog/2019/06/27/building-a-check-in-app-with-nexmos-verify-api-dr)
* [Creating a Voice Chat Application with Vue.js and Express](https://www.nexmo.com/blog/2019/08/05/voice-chat-with-vue-and-express-dr)
* [Trusted Group Authentication with SMS and Express](https://www.nexmo.com/blog/2019/06/18/trusted-group-auth-with-sms-and-express-dr)
* [Build an Interactive Voice Response Menu using Node.js and Express](https://www.nexmo.com/blog/2019/04/08/build-interactive-voice-response-node-express-javascript-dr)
* [Create Custom Voicemail with Node.js, Express and Socket.io
  ](https://www.nexmo.com/blog/2019/04/02/voicemail-with-express-and-socketio-dr)
* [Build a Full Stack Nexmo App with Express and React](https://www.nexmo.com/blog/2019/03/15/full-stack-nexmo-with-express-react-dr)