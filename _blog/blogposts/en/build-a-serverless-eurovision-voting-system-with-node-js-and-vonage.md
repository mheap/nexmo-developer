---
title: Build a Serverless Eurovision Voting System with Node.js and Vonage
description: Are you a Eurovision fan? Follow this tutorial to learn how to
  build a fully-working voting system using Node.js, MongoDB, and the Vonage
  APIs.
thumbnail: /content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/Blog_Eurovision-Voting_1200x600.png
author: kevinlewis
published: true
published_at: 2020-06-17T13:30:36.000Z
updated_at: 2021-05-04T13:50:48.721Z
category: tutorial
tags:
  - mongodb
  - netlify
  - messages-api
comments: true
redirect: ""
canonical: ""
---
Eurovision is one of my favorite events of the year. For those who don't know, Eurovision is a singing competition which is [weird](https://www.youtube.com/watch?v=Ovt7YGHAj8I), [wonderful](https://www.youtube.com/watch?v=WXwgZL4zx9o) and [wacky](https://www.youtube.com/watch?v=NTjmX1JPoSA) in equal measures. Each participating country submits one act to perform an original song - which are often [ridiculous](https://youtu.be/hfjHJneVonE) and [brilliant](https://www.youtube.com/watch?v=gAh9NRGNhUU). Go on then - [have](https://www.youtube.com/watch?v=R3D-r4ogr7s) [a](https://www.youtube.com/watch?v=C-VMHOlCyW8) [few](https://www.youtube.com/watch?v=L_dWvTCdDQ4) [more](https://www.youtube.com/watch?v=SaolVEJEjV4) [links](https://www.youtube.com/watch?v=Eo5H62mCIsg).

<youtube id="HU6TOk_bU14"></youtube>

Countries that make it to the final perform live before people in participating countries vote for their favorite act (not including their own). Votes from each country are counted, and as a result, each gives out 58 points: 12 for the top, then 10, and finally 8 through 1. In recent years, professional juries make up half the vote for each country, but we'll forget they exist for the sake of this project.

![2019 Eurovision Leaderboard](/content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/2019-leaderboard.jpg "2019 Eurovision Leaderboard")

I'm a massive Eurovision fan, and thought it would be a fun project to build a fully-working voting system using the Vonage Number Insights API to validate the origin of a number. 

We'll first be setting up a database with every participating country. This dataset will also highlight who the finalists are (using 2019's contestants). Then, we'll handle incoming votes via SMS, store votes if valid, and reply using the [Vonage Messages API](https://developer.nexmo.com/messages/overview). Finally, we'll build a front-end that will allow us to get results per-country with an updating leaderboard. The whole project will be hosted on Netlify with Vue.js used for our minimal front-end. 

If you just want to see the finished code you can find it at <https://github.com/nexmo-community/eurovision-voting-system-js>.

Ready? Let's go!

## Prerequisites

We're going to need a few accounts to get this to work. If you haven't already, get a:

* [Vonage API Account](https://dashboard.nexmo.com/sign-up)
* [MongoDB Atlas Account](https://www.mongodb.com/cloud/atlas)
* [GitHub Account](https://github.com/join)
* [Netlify Account](https://app.netlify.com/signup)

Open the terminal, create a new empty directory for this project, and initialize a new project by typing `npm init -y`. Once completed, install required dependencies by running `npm install dotenv encoding mongodb netlify-lambda nexmo@beta`.

You'll also need the Nexmo CLI. Run `npm install -g nexmo-cli@beta` to install it, go to your account online to get your API Key/Secret, and then run `nexmo setup <api_key> <api_secret>`.

<sign-up></sign-up>

## Set up a MongoDB Database

We'll be using a hosted MongoDB instance on MongoDB Atlas. Log in to your Mongo DB Atlas account and create a new project with any name you want. Create a new cluster (free tier is fine)—I'm calling mine `Eurovision`—and wait for the changes to be deployed.

Click the *Connect* button in your new cluster, add your current IP Address, and create a new MongoDB User who can access this database (take note of the password).

On the next pane, we are presented with a number of ways to connect to your database. Choose *Connect your application* and copy the URI to your clipboard.

### Create .env File

Before we continue, we must create a new `.env` file in the project directory to contain all of our sensitive strings that we don't want others to see. The content of the file should be:

```
DB_URL=<Mongo DB URI>
```

Replace `<password>` with your MongoDB User password, and `<dbname>` with `eurovision`.

### Create Collections

Click the *Collections* button in your cluster, then *Add My Own Data* to create a new collection. We should create two:

1. Database name: `eurovision`, collection name: `countries`
2. Database name: `eurovision`, collection name: `votes`

### Allow Access From Anywhere

We added our own IP address to the list, which allows access to this database from our local application. However, when we later deploy this project, we won't have access to Static IP Addresses. Click *Network Access* in the sidebar, then *Add IP Address*, and finally *Allow Access From Anywhere*. Confirm your changes to lift the restrictions will be lifted.

## Populate With Countries

In 2019, there were 42 Eurovision entries, of which 26 made it through to the final. As we only need to populate this data once, I have written a script to automate this data entry. Create a folder called `boilerplate`, and inside of it a file called `addCountries.js`. Put the following code in the file:

```js
// Load environment variables
require('dotenv').config()
 // Initialize MongoClient
const { MongoClient } = require('mongodb')
const mongo = new MongoClient(process.env.DB_URL, { useUnifiedTopology: true })
 const countriesList = [
  { "iso": "ALB", "name": "Albania", "final": true },
  { "iso": "ARM", "name": "Armenia", "final": false },
  { "iso": "AUS", "name": "Australia", "final": true },
  { "iso": "AUT", "name": "Austria", "final": false },
  { "iso": "AZE", "name": "Azerbaijan", "final": true },
  { "iso": "BLR", "name": "Belarus", "final": true },
  { "iso": "BEL", "name": "Belgium", "final": false },
  { "iso": "HRV", "name": "Croatia", "final": false },
  { "iso": "CYP", "name": "Cyprus", "final": true },
  { "iso": "CZE", "name": "Czech Republic", "final": true },
  { "iso": "DNK", "name": "Denmark", "final": true },
  { "iso": "EST", "name": "Estonia", "final": true },
  { "iso": "FIN", "name": "Finland", "final": false },
  { "iso": "FRA", "name": "France", "final": true },
  { "iso": "DEU", "name": "Germany", "final": true },
  { "iso": "GEO", "name": "Georgia", "final": false },
  { "iso": "GRC", "name": "Greece", "final": true },
  { "iso": "HUN", "name": "Hungary", "final": false },
  { "iso": "ISL", "name": "Iceland", "final": true },
  { "iso": "IRL", "name": "Ireland", "final": false },
  { "iso": "ISR", "name": "Israel", "final": true },
  { "iso": "ITA", "name": "Italy", "final": true },
  { "iso": "LVA", "name": "Latvia", "final": false },
  { "iso": "LTU", "name": "Lithuania", "final": false },
  { "iso": "MKD", "name": "North Macedonia", "final": true },
  { "iso": "MLT", "name": "Malta", "final": true },
  { "iso": "MDA", "name": "Moldova", "final": false },
  { "iso": "MNE", "name": "Montenegro", "final": false },
  { "iso": "NLD", "name": "Netherlands", "final": true },
  { "iso": "NOR", "name": "Norway", "final": true },
  { "iso": "POL", "name": "Poland", "final": false },
  { "iso": "PRT", "name": "Portugal", "final": false },
  { "iso": "ROU", "name": "Romania", "final": false },
  { "iso": "RUS", "name": "Russia", "final": true },
  { "iso": "SMR", "name": "San Marino", "final": true },
  { "iso": "SRB", "name": "Serbia", "final": true },
  { "iso": "SVN", "name": "Slovenia", "final": true },
  { "iso": "ESP", "name": "Spain", "final": true },
  { "iso": "SWE", "name": "Sweden", "final": true },
  { "iso": "CHE", "name": "Switzerland", "final": true },
  { "iso": "UKR", "name": "Ukraine", "final": false },
  { "iso": "GBR", "name": "United Kingdom", "final": true }
]
 // Connect to database, and insert all items in the countryList in the countries collection
mongo.connect().then(async () => {
  try {
    const countries = await mongo.db('eurovision').collection('countries')
    const result = await countries.insertMany(countriesList)
    console.log(`Added ${result.insertedCount} documents to the collection`)
    mongo.close()
  } catch(e) {
    console.error(e)
  }
})
```

Save the file, open your terminal, and run `node boilerplate/addCountries.js`. Once completed, check your collection in MongoDB Atlas and you should see 42 documents in the countries collection.

![Country entries populated in Atlas](/content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/countries-collection.png "Country entries populated in Atlas")

## Set up a Netlify Function

There are two endpoints we need to create for the Vonage API integration. The first is a status endpoint which, for this application, doesn't need any logic but must return a HTTP 200 status. To build and host these endpoints, we'll use Netlify Functions. Before we do, there's some setup required. 

In your `package.json` file, replace the `scripts` section with the following:

```json
"scripts": {
  "netlify:serve": "netlify-lambda serve functions/src",
  "netlify:build": "netlify-lambda build functions/src"
},
```

Create a `netlify.toml` file in your project's root directory and write the following code:

```
[build]
  functions = "./functions/build"
```

Finally, create a `functions` directory in your project, and inside of it create a `src` directory. All of our Netlify Functions will be created in this directory.

In the new `functions/src` directory create a `status.js` file. In it, create the function:

```js
const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type'
}
 exports.handler = async (event, context) => {
  try {
    return { headers, statusCode: 200, body: 'ok' }
  } catch(e) {
    console.error('Error', e)
    return { headers, statusCode: 500, body: 'Error: ' + e }
  }
}
```

In the terminal run `npm run netlify:serve`. In another terminal, try out the new endpoint by running `curl http://localhost:9000/status`. The terminal should show a response of `ok`.

## Accept Incoming Messages

We will also require an endpoint to receive data when our Long Virtual Number (LVN) is sent a message. Copy and paste the content of `status.js` into a new file called `inbound.js`. 

### Create the Inbound Endpoint

At the top of the file, require the querystring package (built into Node.js):

```js
const qs = require('querystring');
```

At the top of the `try` block, add the following code:

```js
const { msisdn, to: lvn, text } = qs.parse(event.body)
const vote = text.toUpperCase().trim()
console.log(vote)
```

Restart the netlify-lambda server, open a new terminal, and run `npx ngrok http 9000` to create a publicly-accessible version of your netlify-lambda server for testing. Take note of the temporary ngrok URL.

### Set Up A Vonage API Application

In your project directory, run `nexmo app:create`:

* Application Name: anything you want
* Select Capabilities: messages
* Messages Inbound URL: `<ngrok_url>/inbound`
* Messages Status URL: `<ngrok_url>/status`
* Public/Private: leave blank

This operation creates a `.nexmo-app` file in your directory. We'll be using it later, but don't share it as it contains your private key. Take note of the new Application ID shown in your terminal (you can also find it in the `.nexmo-app` file later).

Next, we need to buy and link a LVN with this application. Run:

```
nexmo number:search GB --sms
```

Copy a number and then run:

```
nexmo number:buy <number>
nexmo link:app <number> <application_id>
nexmo numbers:update <number> --mo_http_url=<ngrok_url>/inbound
```

Now the LVN is set up and forwarding requests to the application. Try sending a message to it and see it appear in your terminal.

![Message logged in terminal](/content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/clg.png "Message logged in terminal")

Add the following to the `.env` for later:

```
VONAGE_KEY=<your_api_key>
VONAGE_SECRET=<your_api_secret>
VONAGE_APP=<your_application_id>
VONAGE_PRIVATE_KEY=<your_private_key>
```

You can find your application's private key in the `.nexmo_app` file.

## Store Vote in the Database

At the very top of `inbound.js`, require and initialize `MongoClient`:

```js
require('dotenv').config()
const { MongoClient } = require('mongodb')
const mongo = new MongoClient(process.env.DB_URL, { useUnifiedTopology: true })
```

Below the `console.log(vote)` statement, connect to the database and push a new entry into the collection to test it's working:

```js
await mongo.connect()
const votes = await mongo.db('eurovision').collection('votes')
const countries = await mongo.db('eurovision').collection('countries')
 await votes.insertOne({ msisdn, lvn, vote })
```

Wait for your netlify-lambda server to restart automatically and send another message to your LVN. If you check your votes collection in Atlas, a new document should appear. 

## Get Number Insights

The Vonage Number Insights API will, given a phone number (MSISDN), provide insights about it. There are three tiers—basic, standard and advanced. For this application, we want to know a number's country of origin, which is returned as part of a basic lookup. 

Just above where the `headers` are defined, require and initialize the Nexmo node client library:

```js
const Nexmo = require('nexmo')
const nexmo = new Nexmo({
  apiKey: process.env.VONAGE_KEY,
  apiSecret: process.env.VONAGE_SECRET,
  applicationId: process.env.VONAGE_APP,
  privateKey: Buffer.from(process.env.VONAGE_PRIVATE_KEY.replace(/\\n/g, "\n"), 'utf-8')
})
```

*Note: We must create a Buffer and replace `\n` for this application to work once hosted on Netlify. In non-Netlify hosted applications, you can provide this directly as `process.env.VONAGE_PRIVATE_KEY`.*

At the very bottom of the file, create a new function to get the country code from a number:

```js
function getCountryCodeFromNumber(number) {
  return new Promise((resolve, reject) => {
    nexmo.numberInsight.get({level: 'basic', number}, async (err, res) => {
      if(err) reject(err)
      else resolve(res.country_code_iso3)
    })
  })
}
```

There are other pieces of information that the Number Insights API will return. For this application, we only require the 3 digit ISO code associated with the phone number. This ISO code is also stored against every participating country in our `countries` collection.

Above the `votes.insertOne()` statement add:

```js
const votersCountry = await getCountryCodeFromNumber(msisdn)
console.log(votersCountry)
```

Send another message to your LVN. The country code should be logged in the terminal.

## Send a Response to the User

When we receive a message, we should respond to the user and let them know. At the very bottom of your application add a function to do this:

```js
function sendMessage(sender, recipient, text) {
  return new Promise((resolve, reject) => {
    const to = { type: 'sms', number: recipient }
    const from = { type: 'sms', number: sender }
    const message = { content: { type: 'text', text } } 
    nexmo.channel.send(to, from, message, (err, res) => {
      if(err) reject(err)
      resolve({ headers, statusCode: 200, body: 'ok' })
    })
  })
}
```

We can now use the function to send a message to users, and then return its value directly. Replace the `return` statement in the `try {}` block with our new function call:

```js
return await sendMessage(lvn, msisdn, 'Thank you for voting!')
```

Send a message to your LVN and you should receive a response.

## Check If Vote Is Valid

We don't want to store every vote that is sent to us. There are some checks that are required for it to be valid. Below the `votersCountry` variable, create the checks:

```js
const existingVote = await votes.findOne({ msisdn: msisdn })
const countryInFinal = await countries.findOne({ iso: vote, final: true })
const votersCountryCanVote = await countries.findOne({ iso: votersCountry })
 if(existingVote) {
  return await sendMessage(lvn, msisdn, 'You have already voted')
}
if(!countryInFinal) {
  return await sendMessage(lvn, msisdn, 'That country is not in the final, or your message is not a valid country code.')
}
if(!votersCountryCanVote) {
  return await sendMessage(lvn, msisdn, 'Your number is not from a participating country')
}
if(votersCountry == vote) {
  return await sendMessage(lvn, msisdn, 'You cannot vote for your own country')
}
```

Change the object inside of `votes.insertOne()` to include the information we want to store:

```js
votes.insertOne({ msisdn, vote, votersCountry })
```

As there are return statements in the if statements, the vote will only be inserted if none of the conditions are met, meaning it is valid.

## Populate With Votes

Our voting system is now complete. However, to build results endpoints, we'll need thousands of votes. Like before, here is a script that will add 20k votes. Add this code in a new `addVotes.js` file in the boilerplate directory:

```js
require('dotenv').config()
const { MongoClient } = require('mongodb')
const mongo = new MongoClient(process.env.DB_URL, { useUnifiedTopology: true })
 mongo.connect().then(async () => {
  try {
    const countries = await mongo.db('eurovision').collection('countries')
    const votes = await mongo.db('eurovision').collection('votes')
    const list = await countries.find().toArray()
     const votesList = []
    for(let i=0; i<20000; i++) {
      const { iso: votersCountry } = list[Math.floor(Math.random() * list.length)]
      const availableCountries = list.filter(c => c != votersCountry && c.final)
      const { iso: vote } = availableCountries[Math.floor(Math.random() * availableCountries.length)]
       votesList.push({
        msisdn: String(Math.ceil(Math.random() * 100000)),
        votersCountry, vote
      })
    }
    
    const result = await votes.insertMany(votesList)
    console.log(`Added ${result.insertedCount} documents to the collection`)
    mongo.close()
  } catch(e) {
    console.error(e)
  }
})
```

Delete your existing documents, and then run this script 5 or 6 times. Your MongoDB Atlas database should now have plenty of sample votes.

![12000 records in the votes collection](/content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/lots-of-docs.png "12000 records in the votes collection")

## Create Endpoints for the Front-end

There are a few moving parts in our front-end—we need an endpoint to return countries to populate the dropdown, and an endpoint to return a given country's scores.

![Completed dashboard](/content/blog/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/client.png "Completed dashboard")

### Get the Country List

Create a new file in `/functions/src/countries.js`:

```js
require('dotenv').config()
const { MongoClient } = require('mongodb')
const mongo = new MongoClient(process.env.DB_URL, { useUnifiedTopology: true })
 const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type'
}
 exports.handler = async (event, context) => {
  try {
    await mongo.connect()
    const countries = await mongo.db('eurovision').collection('countries')
    const list = await countries.find().toArray()
    return { headers, statusCode: 200, body: JSON.stringify(list) }
  } catch(e) {
    console.error('Error', e)
    return { headers, statusCode: 500, body: 'Error: ' + e }
  }
}
```

Restart your netlify-lambda server and then try it by running `curl http://localhost:9000/countries`.

### Get Results

This endpoint will accept a query parameter of `?country=CODE`. Copy and paste the countries endpoint code into a new file called `results.js`. Replace the content of the `try {}` block with the following:

```js
await mongo.connect()
const countries = await mongo.db('eurovision').collection('countries')
const votes = await mongo.db('eurovision').collection('votes')
 const { country } = event.queryStringParameters
 const topTen = await votes.aggregate([
  { $match: { votersCountry: country } },
  { $group: { _id: '$vote', votes: { $sum: 1 } } },
  { $sort: { votes: -1 } },
  { $limit: 10 }
]).toArray()
 const points = [ 12, 10, 8, 7, 6, 5, 4, 3, 2, 1 ]
 const list = await countries.find().toArray()
 const results = topTen.map((votes, i) => {
  const countryRecord = list.find(c => c.iso == votes._id)
  return {
    ...votes,
    points: points[i],
    country: countryRecord.name
  }
})
 return { headers, statusCode: 200, body: JSON.stringify(results) }
```

The `topTen` variable uses a MongoDB aggregation to return the top 10 entries as voted by the provided country. We then add a points value to each of the entries with their given point value in the `points` array.

Restart the server, and run `curl http://localhost:9000/results?country=GBR` to test.

## Scaffold Front-end

Create a new file at the project root called `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Eurovision Results Pane</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="app">
    <div id="leaderboard">
      <h1>Leaderboard</h1>
      <div class="list">
        <div class="country" v-for="country in leaderboard">
          <span class="name">{{country.name}}</span>
          <span class="score">{{country.score}}</span>
        </div>
      </div>
    </div>
    <div id="admin">
      <h1>Get Results</h1>
      <form>
        <select v-model="toReveal">
          <option disabled value="">Select country</option>
          <option v-for="country in leftToReveal" :value="country.iso">{{country.name}}</option>
        </select>
        <input type="submit" @click.prevent="getScores" value="Get Scores">
      </form>
      <div id="results">
        <h2>{{resultsCountry}}</h2>
        <div class="result" v-for="result in results">
          <span class="name">{{result.country}}</span>
          <span class="points">+{{result.points}}</span>
        </div>
      </div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/vue"></script>
  <script src="client.js"></script>
</body>
</html>
```

Create a `style.css` file in the project root:

```css
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;900&display=swap');
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: #050636; font-family: 'Montserrat', sans-serif; }
#app { display: grid; grid-template-columns: auto 350px; grid-gap: 1em; padding: 1em; }
#leaderboard { background: white; color: #050636; padding: 1em 1em 0; }
.list { columns: 2; column-gap: 1em; margin-top: 1em; }
.country, .result { padding: 0.5em; background: #f0f0f0; margin-bottom: 1em; width: 100%; display: flex; flex-direction: row; justify-content: space-between; font-size: 1.25em; align-items: center; }
.score { font-size: 1.25em; font-weight: bold; }
#admin { background: #2a2b87; color: white; padding: 1em; }
form { display: grid; grid-template-columns: 225px auto; grid-gap: 1em; }
form { margin: 1em 0; }
.result { background: #4c4eb3; margin-top: 0.5em; }
```

Create a `client.js` file in the project root: 

```js
const app = new Vue({
  el: '#app',
  async created() {
    const countryResp = await fetch(this.baseURL + '/countries');
    const countries = await countryResp.json();
    this.countries = countries.map(country => {
      return { ...country, results: false, score: 0 }
    })
  },
  data: {
    countries: [],
    toReveal: undefined,
    results: undefined,
    resultsCountry: undefined
  },
  computed: {
    leaderboard() {
      return this.countries.filter(c => c.final).sort((a, b) => b.score - a.score)
    },
    leftToReveal() {
      return this.countries.filter(c => !c.results)
    },
    baseURL() {
      return "http://localhost:9000"
    },
    toRevealCountry() {
      const country = this.countries.find(c => c.iso == this.toReveal)
      return country.name
    }
  },
  methods: {
    async getScores() {
      // Get results
      const resultsResp = await fetch(this.baseURL + '/results?country=' + this.toReveal);
      this.results = await resultsResp.json();
       // Assign points to countries
      for(let result of this.results) {
        const country = this.countries.find(c => c.iso == result._id)
        country.score += result.points
      }
       // Remove item from results select
      const votingCountry = this.countries.find(c => c.iso == this.toReveal)
      votingCountry.results = true
      
      // Show country name in results pane
      this.resultsCountry = votingCountry.name
    }
  }
})
```

Some key things to note:

* In `created()` we add two properties to every country—an initial score of 0, and a `results` property which we set to true once we've got results for that country.
* The `leftToReveal` computed property only includes countries who have `results` set to `true`, so we can't accidentally double-count a country.

## Persist Results Between Refreshes

This is a pretty good, fairly robust system. One place we can improve it is persisting scores between refreshes (should this happen while presenting results). 

At the bottom of the `getScores()` method add the `countries` data to localStorage:

```js
localStorage.setItem('countries', JSON.stringify(this.countries))
```

Update `created()` to only fetch fresh country data if we don't have any in localStorage:

```js
async created() {
  if(localStorage.getItem('countries')) {
    this.countries = JSON.parse(localStorage.getItem('countries')) 
  } else {
    const countryResp = await fetch(this.baseURL + '/countries');
    const countries = await countryResp.json();
    this.countries = countries.map(country => {
      return { ...country, results: false, score: 0 }
    })
  }
},
```

## Host on Netlify

Create a new file in your project root called`.gitignore`. The files and directories listed in this file won't be included in a git repository. Your file should look like this:

```
node_modules
functions/build
.env
.nexmo-app
```

Push this repository to GitHub and then log in to your Netlify account. Click *New site from Git*, pick the repository and in the **Basic build settings** the Build command should be `npm run netlify:build`. In the **Advanced build settings** add each item in your `.env` file.

Once deployed, there are two changes you'll need to make:

1. Update your URLs in your Vonage API Application to `<netlify_url>/.netlify/functions/status` (or `/inbound`).
2. In `client.js` update your `baseURL` method to the following:

```js
baseURL() {
  if(location.hostname == 'localhost' || location.hostname == "127.0.0.1") {
    return "http://localhost:9000"
  }  else {
    return "<netlify_url>/.netlify/functions"
  }
},
```

Push a new commit and your Netlify site will re-deploy automatically. 

## Wrap Up & Next Steps

There are quite a few moving parts in this application. However, each part does its job to create a Eurovision voting system that actually works. 

You can get multiple LVNs from different countries using the Nexmo CLI or through the web dashboard. Users will still only be able to vote once regardless of which LVN they message. One improvement you may wish to make is to shut down the voting window so all countries have the same period to vote.

You can find the final project at <https://github.com/nexmo-community/eurovision-voting-system-js>

As ever, if you need any support feel free to reach out in the [Vonage Developer Community Slack](https://developer.nexmo.com/community/slack). We hope to see you there.

[Iceland](https://www.youtube.com/watch?v=1HU7ocv3S2o) had the best 2020 entry, by the way.