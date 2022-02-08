---
title: Monitor Your Applications with the Nexmo Audit Events API and Python
description: The Nexmo Audit API helps you gain insight into events that take
  place on your account. This tutorial shows you how to create a web app to
  explore them all.
thumbnail: /content/blog/get-nexmo-audit-events-with-python-dr/audit-api.png
author: abedford
published: true
published_at: 2018-10-09T16:02:27.000Z
updated_at: 2021-05-03T22:19:53.950Z
category: tutorial
tags:
  - python
  - audit-api
comments: true
redirect: ""
canonical: ""
---
In this blog post you'll see how to create a web application in Python that allows you to view Nexmo audit events. Within Nexmo this monitoring of accounts is achieved through the Audit API.

Some reasons for using the Nexmo Audit API include:

* Monitoring possible fraudulent access to accounts.
* Compliance including SOX, SSAE16/SOC, ISO27001 and others.
* Monitoring to help meet service level agreements.

## Nexmo Audit Events API

Nexmo provides the Audit API for analyzing events that occur within a Nexmo account. The API allows you to easily:

* Retrieve a list of all supported event types.
* Obtain filtered lists of events (you can filter on one or more event type and use text search).
* Retrieve details of a specific audit event.

In this blog post you will see how to:

1. Retrieve supported event types.
2. Obtain a list filtered on one event type.
3. Obtain a list of all events.

You can review the [Nexmo Audit API documentation](https://developer.nexmo.com/audit/overview) for additional functionality, for example you can:

* Retrieve audit events between a date range.
* Retrieve audit events based on text search.
* Combine various filters to obtain a very specific list of events.

This blog post only provides an introduction to using the Nexmo Audit API with Python.

The Nexmo Audit Events API is currently Beta. Currently, there is no support available in [client libraries](https://developer.nexmo.com/tools).

## REST API Endpoints

The main REST API endpoint is:

```
https://api.nexmo.com/beta/audit/events
```

You can obtain a list of all audit events using a `GET`. You can also obtain a list of supported event types by using `OPTIONS` on the endpoint.

Audit event requests can be filtered using query parameters. For example:

``` bash
curl "https://api.nexmo.com/beta/audit/events?event_type=$EVENT_TYPE&search_text=$SEARCH_TEXT&date_from=$DATE_FROM&date_to=$DATE_TO" \
     -u "$NEXMO_API_KEY:$NEXMO_API_SECRET"
```

`EVENT_TYPE` can be a comma-delimited list of event types, for example:

``` bash
curl "https://api.nexmo.com/beta/audit/events?event_type=APP_CREATE,APP_DELETE&search_text=some_string&date_from=2018-09-01&date_to=2018-09-30" \
     -u "$NEXMO_API_KEY:$NEXMO_API_SECRET"
```

## Simple Web Application

The web application in this blog post has been deliberately kept very simple, so you can focus on the key Nexmo Audit API calls you need to make to obtain a list of audit events.

There's a simple form containing a drop-down list populated with the supported event types. You can chose a specific event type from the list or select `ALL` for all event types. You then click the form button to select your choice. A table containing the list of recorded events is returned and displayed.

The Python web application here has two prerequisites: 

1. [Requests](http://docs.python-requests.org/en/master/#) - provides an easy way to make REST API calls.
2. [Flask](http://flask.pocoo.org/) - provides a web application framework.

Installation instructions for these two libraries can be found on their web sites, but can be easily installed with `pip`.

The application presented here was only tested with Python 3.

The Python web application source code:

``` python
import requests
from requests.auth import HTTPBasicAuth
from flask import Flask, request, jsonify

NEXMO_API_KEY = 'YOUR_NEXMO_API_KEY'
NEXMO_API_SECRET = 'YOUR_NEXMO_API_SECRET'

app = Flask(__name__)

template1 = '''
<html>
  <head>
    <title>Audit Event Types</title>
  </head>
  <body>
    <form action='/events' method='get'>
      <select name='event_type'>
        <option value='ALL'>ALL -- All the event types</option>
        {SELECT_OPTIONS}
      </select>
      <input type='submit'>
    </form>
  </body>
</html>
'''

template2 = '''
<html>
  <head>
    <title>Audit Events Listing</title>
  </head>
  <body>
    <table border='1'>
      <tr><th>Audit Event Type</th><th>Date/time of event</th><th>Event source</th><th>Context</th></tr>
        {TABLE_ROWS}
    </table>
  </body>
</html>
'''

@app.route("/")
def root():
    # Retrieve all supported event types
    # This is then used to populate a drop-down list of event types.
    r = requests.options('https://api.nexmo.com/beta/audit/events', auth=HTTPBasicAuth(NEXMO_API_KEY, NEXMO_API_SECRET))
    j = r.json()
    event_types = j['eventTypes']
    
    # Build options list based on event types
    select_options = ""
    for evt_t in event_types:
        select_options = select_options + "<option value='" + evt_t['type'] + "'>" + evt_t['type'] + " -- " + evt_t['description'] + "</option>"
    html = template1.format(SELECT_OPTIONS=select_options)
    return (html)

@app.route("/events")
def events():
    params = request.args
    EVT_TYPE = params['event_type']
    if EVT_TYPE == 'ALL':
        r = requests.get('https://api.nexmo.com/beta/audit/events', auth=HTTPBasicAuth(NEXMO_API_KEY, NEXMO_API_SECRET))
    else:
        r = requests.get('https://api.nexmo.com/beta/audit/events?event_type='+EVT_TYPE, auth=HTTPBasicAuth(NEXMO_API_KEY, NEXMO_API_SECRET))
    
    j = r.json()
    if '_embedded' in j:
        events = j['_embedded']['events']
    else:
        return ("No Events Found")

    table_rows = ""
    for evt in events:
        if 'context' in evt:
            event_context = str(evt['context'])
        else:
            event_context = 'None'
        table_rows = table_rows + "<tr><td>" + (evt['event_type'] + "</td><td>" + evt['created_at'] + "</td><td>" + evt['source'] + "</td><td>" + event_context + "</td></tr>")
    
    html = template2.format(TABLE_ROWS=table_rows)
    return(html)

if __name__ == '__main__':
    app.run(port=3000)
```

For test purposes you can run the web application locally.

To test out the web app:

1. Navigate your browser to `http://localhost:3000`.
2. You can select a specific event type to view from the drop-down list, or select `ALL` from the drop-down list to view all events.
3. Click `Submit` to receive a list of events.

## Source Code

The latest source code for the example web application is hosted at [Nexmo Community](https://github.com/nexmo-community/get-audit-events-with-python) on GitHub.

## Summary

In this blog post you've seen how to create a simple Python web application that allows you to retrieve a list of audit events from your Nexmo account. Using this web app you can monitor your account for suspicious behaviour, or for potential issues.

## Further Reading

You can find out more about the Nexmo Audit Event API from the following resources:

* [Nexmo Audit API docs](https://developer.nexmo.com/audit/overview)
* [Get audit events with filtering](https://developer.nexmo.com/audit/building-blocks/get-events-with-filtering)
* [Get event types](https://developer.nexmo.com/audit/building-blocks/get-event-types)
* [A tutorial on using Audit API](https://developer.nexmo.com/tutorials/retrieve-audit-events)