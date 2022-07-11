---
title: Why Experience Composer API Is Great
description: Learn how the Experience Composer API can enhance video calls by
  capturing the look and feel of your web application using the Vonage Video
  API.
thumbnail: /content/blog/cory-althoff-joins-the-vonage-developer-relations-team/experience-composer-api.png
author: javier-molina-sanz
published: true
published_at: 2022-07-12T19:11:11.196Z
updated_at: 2022-07-12T19:11:11.225Z
category: announcement
tags:
  - video-api
  - experience-composer
  - node
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Vonage has recently released [Experience Composer (EC) API](https://tokbox.com/developer/guides/experience-composer/). This offering provides an API-driven cloud service to capture the entire experience of your web application using the Vonage Video API. This means that the look and feel of your web application can now be entirely recorded, broadcasted via HLS or RTMP, or published as a new stream into a video session. 

In this post, we will go through how you can use Experience Composer to add a new video stream to an existing Vonage session containing your brand logo, custom HTML elements, and an iframe with Google Calendar. You can see a of what the application looks like at the end of this post.

![Diagram of the host's view of the stream with a calendar to the left and on the right in a column from top to bottom is the host camera feed with a Vonage logo overlay, a data table with columns, number, status and Assignee, and a video guest feed](/content/blog/why-experience-composer-api-is-great/host-view.png "Host View Diagram")

Imagine a project planning session between a product manager and a software developer. The product manager, as the host, will publish a product planning calendar with deadlines and an HTML table containing work items with assignees and statuses. The host’s video feed will have the brand logo overlaid. The host view will contain all these items as well as the video from the guest.

The software developer, as the guest, is a consumer of the host’s stream which includes the calendar, data table, and the host’s video with the brand overlay.

## Prerequisites

1. A Vonage Video API account. If you don’t have an account, you can [sign up](https://www.tokbox.com/account/user/signup) and create one.
2. Node.js version >= 14.17.5
3. Experience Composer API enabled for your account. You can do so in the [account portal](https://tokbox.com/account/).

We will use [Bootstrap](https://getbootstrap.com/) from the CDN and CSS grid to speed up development time. I am not going to go into the details of CSS, but you can have a look at the CSS files along with the complete code in the GitHub [repo](https://github.com/nexmo-se/experience-composer-blog). 

## Architecture Diagram

The following diagram shows the architecture of what we’re going to build. Everything will stay in one single Vonage video session, Video Session A. To start, the host, Stream A, will be published into the session along with the guest, Stream B. However, the guest won’t subscribe to the host yet. Experience Composer will subscribe to Stream A and publish a new stream, Stream A (Composite) containing the video from the host with brand overlay along with the Google Calendar, and data table. The guest will consume this composite stream. Both users will be able to communicate with each other.

![Diagram showing how the video feeds are fed into the Experience Composer and transformed into a composite stream.](/content/blog/why-experience-composer-api-is-great/architecture-diagram.png "Architecture Diagram")

## The Server

The server creates rooms, creates sessions, generates tokens, and sends requests to the Experience Composer API to [start](https://tokbox.com/developer/rest/#starting_experience_composer) and [stop](https://tokbox.com/developer/rest/#delete_experience_composer) streams.

> Note: The Experience Composer API is not supported in the Vonage Server SDK currently. Starting and stopping Experience Composer streams will be done through REST calls.

The `/render` endpoint in our server will take the `sessionId` and the `roomName` from our client-side’s POST request. The `sessionId` is then passed into `createRender` which will start Experience Composer and return some data about the Render. The `id` is then extracted and saved to the `sessions` Object under the `roomName` as `renderId`.

```javascript
app.post('/render', async (req, res) => {
  try {
    const { sessionId, roomName } = req.body;
    if (sessionId && roomName) {
      const data = await createRender(sessionId);
      const { id } = data;
      sessions[roomName].renderId = id;
      res.status(200).send({ id });
    } else {
      res.status(500);
    }
  } catch (e) {
    res.status(500).send({ message: e });
  }
});
```

Likewise, to stop the stream published by the Experience Composer, our `/render/stop/:id` endpoint will take the Render `id` needed to stop the Experience Composer instance.

```javascript
app.get('/render/stop/:id', async (req, res) => {
  try {
    const { id } = req.params;
    if (id) {
      console.log('trying to stop render ' + id);
      const data = await deleteRender(id);
      res.status(200).send(data);
    } else {
      res.status(500);
    }
  } catch (e) {
    res.status(500).send({ message: e });
  }
});
```

> Note: The code for the `createRender` and `deleteRender` functions can be found in the [index.js file](https://github.com/nexmo-se/experience-composer-blog/blob/main/index.js#L129). 

To authenticate the requests with the API, we need to create a JSON Web Token (JWT) as explained in the [developer documentation](https://tokbox.com/developer/rest/#authentication). I have used the `jsonwebtoken` package from [npm](https://www.npmjs.com/package/jsonwebtoken), but feel free to use any other package.

In order to create the render, we need to pass a few parameters in the JSON body as per [the documentation](https://tokbox.com/developer/rest/#starting_experience_composer). Some of the parameters are mandatory such as the `url`, `sessionId`, `token`, and `projectId`. Pay special attention to the `url` parameter. Think of it as the URL that the “invisible user”, Experience Composer, will visit. Then [JavaScript code](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/index.js#L99) will be loaded so that Experience Composer only subscribes to the host and a new stream will be published into the `sessionId`.

You may have noticed in the [`createRender` function](https://github.com/nexmo-se/experience-composer-blog/blob/main/index.js#L125) that there’s an extra object `properties` that contains a `name` parameter. This name will prove useful when we listen to `streamCreated` events on the client-side. We will come back to that in a bit but all you need to know for now is that this is the name of the stream we are going to publish into the session.

Our server will also be responsible for serving the static HTML content to the client. We will set up a few routes for the different views in our application. A route for the host (the presenter that will publish the calendar, table, etc), another one for the guest or consumer of the host stream, and one more for the Experience Composer (that’s the `url` parameter we send in the JSON body mentioned earlier).

```javascript
app.get('/host', (req, res) => {
  res.sendFile(__dirname + '/src/host.html');
});

app.get('/ec', (req, res) => {
  res.sendFile(__dirname + '/src/ec.html');
});

app.get('/user', (req, res) => {
  res.sendFile(__dirname + '/src/user.html');
});
```

## Client-side

We are going to create a Vanilla JS sample app, but you could use Experience Composer with any framework of your choice. The client-side code resides within the [src folder](https://github.com/nexmo-se/experience-composer-blog/tree/main/src). 

### Guest view

Think of the guest as a viewer of the host’s composite stream while also sending their video and audio to communicate with the host.

The code for the guest view can be found in the HTML file [`user.html`](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/user.html) with the JavaScript and CSS included.  The guest is going to publish their video stream and only subscribe to the stream published by Experience Composer. We can selectively subscribe to the stream published by the Experience Composer because we set a name for the stream.

When we set up the `streamCreated` event listener, we will only subscribe to the stream if the stream’s name is EC. This is to prevent the guest from subscribing to the host’s regular video stream (without table, overlay, and iframe).

```javascript
session.on('streamCreated', function streamCreated(event) {
  if (event.stream.name === 'EC') {
    const subscriberOptions = {
      width: '800px',
      height: '500px',
    };
    session.subscribe(
      event.stream,
      'subscriber',
      subscriberOptions,
      handleError
    );
  }
});
```

This is what the guest view looks like. You can see two different streams. On the left, the guest is publishing their video stream while on the right, subscribing to the composite stream published by the Experience Composer that contains the video feed from the host, the calendar, overlay, and data table.

![Diagram of the Guest View with the guest's video feed on the left and in a box on the right that contains a calendar to the left and on the right in a column from top to bottom is the host camera feed with a Vonage logo overlay, a data table with columns, number, status and Assignee](/content/blog/why-experience-composer-api-is-great/guest-view.png "Guest View Diagram")

### Host View

The host, in this case, is the person who will publish the video feed along with some custom elements specific to the application. In this view, the host has their video feed and will subscribe to the video feed from the guest. The layout of the host view will also have the custom elements (Google calendar, a data table, and brand overlay) that will be published into the session by the Experience Composer.

The host view will load on the `/host` route of our application. I also decided to add a query parameter to identify the host and the Experience Composer. So the full route of our host will be `${applicationUrl}/host?role=host`.

Again, this is what the host view will look like.

![Diagram of the host's view of the stream with a calendar to the left and on the right in a column from top to bottom is the host camera feed with a Vonage logo overlay, a data table with columns, number, status and Assignee, and a video guest feed](/content/blog/why-experience-composer-api-is-great/host-view.png "Host View Diagram")

The host and Experience Composer will share the same [JavaScript file](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/index.js) but have separate HTML files. The markup file for the host can be found [here](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/host.html). To determine whether host or EC, I have created two functions, `isHost` and `isExperienceComposer`.

```javascript
function isHost() {
  return queryString === '?role=host' && window.location.pathname === '/host';
}

function isExperienceComposer() {
  return (
    queryString === '?role=experience_composer' &&
    window.location.pathname === '/ec'
  );
}
```

This will allow us to selectively subscribe to the streams we need to. The host does not need to subscribe to the stream created by the Experience Composer because then they would be subscribing to their own stream. Therefore we can selectively subscribe to the stream whose name is different from EC.

```javascript
session.on('streamCreated', function (event) {
  if (isHost() && event.stream.name !== 'EC') {
    subscribe(event.stream);
  }
});
```

The `subscribe` function will decide where to append the publisher depending on whether it is the host or the Experience Composer subscribing to the stream. If it’s the host trying to subscribe, we will want to append the video from the other user (guest) to the DOM element whose id is `subscriber`, that is, on the bottom right of the Host view.

```javascript
function subscribe(stream) {
  session.subscribe(
    stream,
    isExperienceComposer() ? 'publisher' : 'subscriber',
    {
      width: '100%',
      height: '100%',
    },
    handleError
  );
}
```

Since this is a sample application, I also added for convenience two buttons to start and stop the Experience Composer stream. These buttons will be only visible to the host but you can publish the Experience Composer stream programmatically once the `streamCreated` event for the host fires up.

The fetch calls to start and stop the Experience Composer stream are implemented in the [`src/index.js`](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/index.js#L28) and the functions are called by clicking on the buttons in the [host.html file](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/host.html#L29).

Another important difference between the host and the Experience Composer is that we explicitly need to tell the host to publish. So once we are connected to the session we will only publish if it’s the host.

```javascript
session.connect(token, function (error) {
  if (error) {
    handleError(error);
  } else {
    if (isHost()) {
      const publisher = OT.initPublisher(
        'publisher',
        {
          width: '100%',
          height: '100%',
          name: 'host',
        },
        handleError
      );
      publish(publisher);
    }
  }
 });
```

The Experience Composer will automatically publish into the session so our JavaScript code does not need to instruct the Experience Composer to publish.

### Experience Composer View

The Experience Composer will load the URL we pass server-side when making the API call. It will load the JavaScript code and publish into the session (also passed as a parameter). Think of Experience Composer as an invisible user that joins the URL, captures the screen, and publishes the result as a new stream into the session.

Since we created a few helper functions to know if it’s the Experience Composer or the host joining, we can prevent the Experience Composer from publishing through our [JavaScript code](https://github.com/nexmo-se/experience-composer-blog/blob/main/src/index.js#L110) once it connects to the session.  See the previous section.

It is also important to take into account that the Experience Composer only needs to subscribe to the stream from the host because we want the stream published to only contain the host’s composite video feed.

```javascript
session.on('streamCreated', function (event) {
  if (isExperienceComposer() && event.stream.name === 'host') {
    subscribe(event.stream);
  }
});
```

If you have a look at the desired layout from the Experience Composer view, we need to append the subscriber to the top right corner of the page, which corresponds to the `publisher` DOM element

```
function subscribe(stream) {
  session.subscribe(
    stream,
    isExperienceComposer() ? 'publisher' : 'subscriber',
    {
      width: '100%',
      height: '100%',
    },
    handleError
  );
}
```

This is the Experience Composer view with the subscribed stream from the host at the top right.

![Diagram of the Experience Composer's view of the stream with a calendar to the left and on the right in a column from top to bottom is the host camera feed with a Vonage logo overlay, a data table with columns, number, status and Assignee](/content/blog/why-experience-composer-api-is-great/ec-view.png "Experience Composer View Diagram")

## Video Demo

The following video shows you the host view and the guest view.

<iframe width="560" height="315" src="https://www.youtube.com/embed/AwtdlsxtHbk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Recording and Broadcasting

This application does not implement archiving/recording. However, you can do so by setting the `streamMode` to "manual" mode when you [start the archiving](https://tokbox.com/developer/rest/#start_archive) and then adding the streams you want to be included in the [recording](https://tokbox.com/developer/rest/#selecting-archive-streams). 

In this case, we only want to have the stream from Experience Composer and the stream from the guest archived. Otherwise, if we added the three streams or set `streamMode` to auto, we would have 3 streams in the recording, 2 of which would be the host. 

The stream published by Experience composer can also be broadcasted via HLS or RTMP to a wider audience.

## Conclusion

Experience composer is a very powerful offering that allows you to provide a richer experience to your video calls by publishing streams with pretty much anything you can think of, as long as it renders on a web page.

Going to give the new Experience Composer a try? We welcome your feedback on the [Vonage Community Slack](https://developer.vonage.com/community/slack).
