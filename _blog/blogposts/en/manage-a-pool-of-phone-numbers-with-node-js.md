---
title: Manage a Pool of Phone Numbers With Node.js
description: Looking to redirect phone numbers on the fly? Find out how to
  manage a pool of phone numbers using the Vonage Number Management API and
  Node.js.
thumbnail: /content/blog/manage-a-pool-of-phone-numbers-with-node-js/Dev_Numbers_Node-js_1200x600.png
author: kevinlewis
published: true
published_at: 2020-04-23T13:59:34.000Z
updated_at: 2021-05-05T11:06:05.903Z
category: tutorial
tags:
  - node
  - number-management-api
comments: true
redirect: ""
canonical: ""
---
You may not always be near your office phone, and when this is the case, customers may struggle to get in touch with you. In this tutorial, we'll be building an application that uses the [Number Management API](https://developer.nexmo.com/api/numbers) for Vonage APIs to manage multiple masked phone numbers. Each number will redirect calls to another number, such as a private mobile that can be used from home.

We'll also make sure that users of our application can only see numbers bought and managed by it, rather than every number in your Vonage API account. Finally, we'll do some work to make sure that only users you know are given access and that it isn't accessible from the public web without a password. 


![The final application screenshot, showing a pool of phone numbers and management options including update and delete](/content/blog/manage-a-pool-of-phone-numbers-with-node-js/application.png)

## Can I Use This Project Now?

The completed code for this project is in Glitch. You can visit [the project](https://glitch.com/edit/#!/vonage-number-manager), click the *Remix to Edit* button in the top-right, and add your own credentials to the `🔑.env` file. You can then use the project right away by clicking the *Show* button at the top of the page.

You can also find the completed code on [GitHub](https://github.com/nexmo-community/phone-number-pool-manager-node).

## Prerequisites

* A [Glitch account](https://glitch.com)

Note: Nexmo recently rebranded to Vonage after being acquired in 2016. You'll notice that we make calls to a Nexmo URL in this tutorial so don't be alarmed by this. 

<sign-up></sign-up>

## Creating a Base Project

There is a boilerplate [Glitch](https://glitch.com/) project to get you up and running quickly. This application has:

* Installed and included our dependencies, which you could do in a new Express project by opening the Glitch terminal and typing `pnpm install express body-parser cors nedb-promises axios qs express-basic-auth`.
* Created a new [nedb](https://github.com/louischatriot/nedb) database in the `.data` folder in Glitch. This folder is specific to your version of the application and can't be viewed by others or copied. 
* Initialized a basic Express application, and served the `views/index.html` file when people navigate to our project URL
* Included Vue.js and Axios libraries in the `index.html` file, created a new Vue.js application, and added some basic styling in the `public/style.css` file. 

Log in to your Glitch account, and then [click on this link to remix](https://glitch.com/edit/#!/remix/vonage-number-manager-starter) (copy) our boilerplate into your account. 

Whether you start from scratch or use our boilerplate, you'll need to go to your Vonage API Dashboard, get your API key and secret and put them in your project's  `🔑.env` file. These values are not publicly visible but can be accessed in your application using `process.env.PROPERTY`.

## Build an Endpoint to Buy Numbers

This endpoint will require a `country` to be provided, as that is what the Number Management API requires.

Above the final line of your application, include the following code:

```js
app.post('/numbers', async (req, res) => {
    try {
        const { NEXMO_API_KEY, NEXMO_API_SECRET } = process.env;
        const availableNumbers = await axios.get(`https://rest.nexmo.com/number/search?api_key=${NEXMO_API_KEY}&api_secret=${NEXMO_API_SECRET}&country=${req.body.country}&features=SMS,VOICE`);
        const msisdn = availableNumbers.data.numbers[0].msisdn;
        res.send(msisdn);
    } catch (err) {
        res.send(err);
    }
});
```

When you send a POST request to `/numbers`, the application will make a GET request to the Number Management API to find an available MSISDN (phone number) and returns the first one.

Open your terminal and run the following command to test the new API endpoint: `curl -H "Content-Type: application/json" -X POST -d '{"country": "GB"}' https://YOUR_GLITCH_PROJECT_NAME.glitch.me/numbers`, being sure to substitute your Glitch project name. If successful, it should return an available phone number.

Replace `res.send(msisdn)` with the following:

```js
await axios({
    method: 'POST',
    url: `https://rest.nexmo.com/number/buy?api_key=${NEXMO_API_KEY}&api_secret=${NEXMO_API_SECRET}`,
    data: qs.stringify({ country: req.body.country, msisdn }),
    headers: { 'content-type': 'application/x-www-form-urlencoded' }
});
await db.insert({ msisdn });
res.send('Number successfully bought');
```

This takes the first MSISDN from the results, purchases it from available account credit, and stores a new database record for the MSISDN. The `qs` package formats the data as an `x-www-form-encoded` string, which is what the Number Management API requires.

**Checkpoint! Repeat the API call to your application from the terminal. You should get a success message, and a new number should be accessible in your Vonage API account.**

*Note - there are multiple reasons why the Vonage API call might fail in your application that have nothing to do with your code. [Check if you can use the Number Management API](https://help.nexmo.com/hc/en-us/articles/204015043-Which-countries-does-Nexmo-have-numbers-in-) to get a number in your country. If it still doesn't work, you [may require an address](https://help.nexmo.com/hc/en-us/articles/115009205227-Why-do-some-virtual-numbers-require-an-address-) and means you must get the number via the Vonage API Dashboard*

## Build a Frontend to Buy Numbers

Your POST request endpoint might be working fine, but it's time to create a more friendly frontend to use it. Open `views/index.html` and add the following to your HTML:

```html
<div id="app">
    <h1>Number Manager</h1>
    <section>
        <h2>Buy New Number</h2>
        <input type="text" v-model="country" placeholder="Country Code" />
        <button @click="buyNumber">Buy new number</button>
    </section>
</div>
```

Update the contents of your `<script>` to the following:

```js
const app = new Vue({
    el: '#app',
    data: {
        country: ''
    },
    methods: {
        async buyNumber() {
            try {
                if(this.country && confirm('Are you sure you would like to buy a number?')) {
                    await axios.post('/numbers', {
                        country: this.form.country
                    })
                    alert('Successfully bought new number');
                }
            } catch(err) {
                alert('Error buying new number', err);
            }
        }
    }
})
```

Open the application by clicking *Show* at the top of your Glitch window. Type "GB" in the box and click "Buy new number." The `confirm()` function prompts the user with a popup box and is a good practice to avoid accidental purchases. While this application uses Vue.js, you can build any application that can make HTTP requests.

## Build an Endpoint to List Numbers

Create a new endpoint in your Express application before the final line of code:

```js
app.get("/numbers", async (req, res) => {
    try {
        res.send('ok');
    } catch (err) {
        res.send(err);
    }
});
```

At the top of the `try` block, retrieve all local database entries and all numbers from the Vonage Number Management API for Vonage APIs. 

```js
const { NEXMO_API_KEY, NEXMO_API_SECRET } = process.env;
const dbNumbers = await db.find();
const vonageNumbers = await axios.get(`https://rest.nexmo.com/account/numbers?api_key=${NEXMO_API_KEY}&api_secret=${NEXMO_API_SECRET}`);
```

Then, create a new array which filters `vonageNumbers` to just those that also appear in the local database. Doing this ensures you only return numbers in this Vonage API account which are managed by this application.

```js
const numbersInBothResponses = vonageNumbers.data.numbers.filter(vonageNumber => {
    return dbNumbers.map(dbNumber => dbNumber.msisdn).includes(vonageNumber.msisdn)
});
```

Next, create one object which amalgamates both data sources for each number:

```js
const combinedResponses = numbersInBothResponses.map(vonageNumber => {
    return {
        ...vonageNumber,
        ...dbNumbers.find(dbNumber => dbNumber.msisdn == vonageNumber.msisdn)
    }
})
```

`combinedResponses` now contains data which is good to send to the user, so replace `res.send('ok');` with `res.send(combinedResponses);`.

## Build a Frontend to List Numbers

In your `index.html` file, create a new method to get the numbers from our Express endpoint:

```js
async getNumbers() {
    const { data } = await axios.get('/numbers')
    this.numbers = data;
}
```

Update the `data` object to the following:

```js
data: {
    numbers: [],
    country: ''
}
```

Load this data by adding a `created()` function just below your `data` object:

```js
created() {
    this.getNumbers();
}
```

Add the following your HTML to display the numbers:

```html
<section>
    <h2>Current Numbers</h2>
    <div class="number" v-for="number in numbers" :key="number.msisdn">
        <h3>{{number.msisdn}}</h3>
        <label for="name">Friendly Name</label>
        <input type="text" v-model="number.name" placeholder="New name">
        <label for="forward">Forwarding Number</label>
        <input type="text" v-model="number.voiceCallbackValue" placeholder="Update forwarding number">
    </div>
</section>
```

**Checkpoint! Click *Show* at the top of your Glitch editor and open your frontend application. When it loads, you should see your managed phone numbers.**

Finally for this section, update the `buyNumber()` method to include `this.getNumbers();` after the success `alert()`. Once you buy a new number, the list will now be updated without a page refresh.

## Building an Endpoint and Frontend to Update Numbers

There are two types of phone number updates this application will support. When updating a number's friendly name, you will be editing entries in the local database, and when updating the forwarding number, you will be updating the number via the Number Management API. Our endpoint must support both and will use the passed data to decide which to update. In `server.js` add the following:

```js
app.patch("/numbers/:msisdn", async (req, res) => {
    try {
        const { NEXMO_API_KEY, NEXMO_API_SECRET } = process.env;
        if(req.body.name) {
            await db.update({ msisdn: req.params.msisdn }, { $set: { name: req.body.name } })
        }
        if(req.body.forward) {
            await axios({
                method: "POST",
                url: `https://rest.nexmo.com/number/update?api_key=${NEXMO_API_KEY}&api_secret=${NEXMO_API_SECRET}`,
                data: qs.stringify({ 
                    country: req.body.country, 
                    msisdn: req.params.msisdn,
                    voiceCallbackType: 'tel',
                    voiceCallbackValue: req.body.forward
                }),
                headers: { "content-type": "application/x-www-form-urlencoded" }
            })
        }
        res.send('Successfully updated')
    } catch(err) {
        res.send(err)
    }
})
```

This PATCH endpoint includes the phone number you are updating. If the body contains a `name` property, the local database will be updated, and if it contains `forward`, the number's settings will be updated via the Number Management API.

In `index.html`, create the following method:

```js
async updateNumber(number) {
    try {
        const { msisdn, country, name, voiceCallbackValue } = number
        const payload = { country }
        if(name) payload.name = name
        if(voiceCallbackValue) payload.forward = voiceCallbackValue
        await axios.patch(`/numbers/${msisdn}`, payload)
        alert('Successfully updated number');
        this.getNumbers(); 
    } catch(err) {
        alert('Error updating number', err);
    }
}
```

You must also call this method from the template - which will happen when a user presses enter while focused on one of the text inputs. Update the inputs to the following:

```html
<label for="name">Friendly Name</label>
<input type="text" v-model="number.name" @keyup.enter="updateNumber(number)" placeholder="New name">
<label for="forward">Forwarding Number</label>
<input type="text" v-model="number.voiceCallbackValue" @keyup.enter="updateNumber(number)" placeholder="Update forwarding number">
```

**Checkpoint! Update a friendly name of a number. Then try updating the forwarding number (remember that it must be in [a valid format](https://help.nexmo.com/hc/en-us/articles/206515367-Destination-number-format))**

## Building an Endpoint and Frontend to Cancel Numbers

When a number is no longer required, you may choose to cancel it which immediately releases it from your account. This is the final key part of managing your virtual phone number pool. In `server.js` add the following above the final line of code:

```js
app.delete("/numbers/:msisdn", async (req, res) => {
    try {
        const { NEXMO_API_KEY, NEXMO_API_SECRET } = process.env;
        await axios({
            method: "POST",
            url: `https://rest.nexmo.com/number/cancel?api_key=${NEXMO_API_KEY}&api_secret=${NEXMO_API_SECRET}`,
            data: qs.stringify({ 
                country: req.body.country, 
                msisdn: req.params.msisdn
            }),
            headers: { "content-type": "application/x-www-form-urlencoded" }
        })
        res.send('Successfully cancelled')
    } catch(err) {
        res.send(err)
    }
})
```

In `index.html` add a `deleteNumber()` method:

```js
async deleteNumber(number) {
    try {
        if(confirm('Are you sure you would like to delete this number?')) {
            const { msisdn, country } = number
            await axios.delete(`/numbers/${msisdn}`, { data: { country } })
            alert('Successfully deleted number')
            this.getNumbers()
        }
    } catch(err) {
        alert('Error deleting number', err);
    }
}
```

Finally, add a button in the template just below the forwarding number input:

```html
<button @click="deleteNumber(number)">Delete number</button>
```

**Checkpoint! Delete a number.**

*You may have noted that you are not deleting the number from the local database. You may choose to implement this, but as the GET numbers endpoint only returns numbers that exist in both your Vonage API account and the local database, the deleted numbers will not be returned.*

## Housekeeping

This application is almost complete, but there are a couple of pieces of housekeeping left to do. 

### Only Allow API Calls From Our Frontend

At the moment, anyone can open their terminal and manage your numbers without permission. Near the top of `server.js`, just below the `app.use()` statements, add the following:

```js
app.use(cors({ origin: `https://${process.env.PROJECT_NAME}.glitch.me` }));
```

`process.env.PROJECT_NAME` is an environment variable provided by Glitch and is equal to the name of this project. This setting only allows requests from our Glitch URL.

### Adding Basic Authentication

Even if people can't access your API from their own applications, they can still stumble across your live site. Fortunately, setting up basic HTTP authentication has just two steps.

Firstly, add a passphrase in your `🔑.env` file. Next, add the following line to the bottom of the `app.use()` statements:

```js
app.use(basicAuth({ users: { admin: process.env.ADMIN_PASSWORD }, challenge: true }));
```

Now, when you load your application, you will need to give `admin` as the username and your provided password. 

## What Next?

This simple application will handle most team's requirements, but there are certainly a few improvements you might make:

* Only giving certain users the ability to buy numbers
* Confirming the cost of each number before purchase
* Adding more data to each number in our local database
* Better error handling

Remember, the completed code for this project is also on [GitHub](https://github.com/nexmo-community/phone-number-pool-manager-node).

You can read more about the Number Management API for Vonage APIs through [our documentation](https://developer.nexmo.com/api/numbers), and if you need any additional support, feel free to reach out to our team through our [Vonage Developer Twitter](https://twitter.com/vonagedev) account or the [Vonage Community Slack](https://developer.nexmo.com/community/slack).