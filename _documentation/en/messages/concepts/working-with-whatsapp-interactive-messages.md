---
title: Working with WhatsApp Interactive Messages
navigation_weight: 6
description: General workflow for working with WhatsApp interactive messages, and examples of lists and reply buttons
---

# Working with WhatsApp Interactive Messages

Interactive Messages is a feature within WhatsApp for Business. The [Vonage Messages API](/messages/overview) enables you to leverage this feature through use of its API endpoints and webhooks.

## Basic Application Flow


The basic flow for working with WhatsApp Interactive Messages is as follows:

1. Send a `POST` request to the `/v1/messages` endpoint. The request body should contain the required JSON data, with the `channel` set to `whatsapp` and the `message_type` set to `custom`. The `custom` field must be populated with a suitably formatted [custom object](/messages/concepts/custom-objects). The actual structure of the custom object will vary depending on the type of interactive message being sent (e.g. reply button or list).

2. The appropriate message type will then be rendered in the specified WhatsApp chat. The customer can interact with the message, such as clicking a reply button or selecting an option from a list (depending on the message type). The Vonage Messages API will then inform you of this interaction via a callback with the message payload using a pre-configured [inbound message webhook](messages/code-snippets/inbound-message)

3. Based on the contents of the payload received via the callback, you can perform any actions as appropriate, such as sending a further request.

> **NOTE:** The inbound message webhook for receiving the callbacks **must** be set up as part of a [Vonage Application](/application/overview)

### Setting up your Application

You can set up your Vonage Application in a number of ways, such as via the [Dashboard](https://dashboard.nexmo.com/), via call to the Applications API, or via the Vonage CLI. Below we describe setting up an application via the Dashboard.

1. Create a new application under Your applications (providing it with an appropriate name, etc)
2. Under Capabilities, enable Messages
3. Enabling Messages should expose fields for inbound and status webhooks. Set the inbound webhook to the URL where you want to receive the callbacks for the WhatsApp Interactive Messages.
4. Set the Messages API version to v1 using the drop-down menu
5. Click on Generate new application
6. Once the application is generated, a 'Link social channels' tab will be exposed. Under this tab, you can link your WhatsApp Business number

<img src="/images/messages/messages-application-webhooks-and-version-settings.png" alt="UI for Messages webhook and version settings">

> **NOTE:** Vonage Applications mandate the usage of JWT (JSON Web Tokens) to authenticate requests to the API, i.e. HTTP Basic authentication is not an option when using Messages API v1 with webhooks. [Read more about JWTs](/concepts/guides/authentication#json-web-tokens-jwt).

## Interactive Messages: Examples

The structure of the JSON object will vary depending on the type of interactive message, and also from message to message. As standard though, you'll need to include the `from` and `to` numbers, a `channel` key set to `whatsapp`, and a `message_type` of `custom`. You'll then need to set a `custom` key, the value of which is a [custom object](/messages/concepts/custom-objects). The custom object should have a `type` key of `interactive`, and an `interactive` key, the value of which is itself an object.

The `interactive` object defines the interactive message. It should have a `type` key set to either `button` or `list`, and will generally also include four main parts: `header`, `body`, `footer`, and `action`. The `action` determines the interactive elements within the message, such as buttons or list options.

### Reply Buttons: Example

Here is an example of the body of a request for sending a WhatsApp interactive message with three reply buttons:

```json
"from": "YOUR_WABA_NUMBER",
"to": "USERS_NUMBER",
"channel": "whatsapp",
"message_type": "custom",
"custom": {
    "type": "interactive",
    "interactive": {
      "type": "button",
      "header": {
          "type": "text",
          "text": "Delivery time"
      },
      "body": {
          "text": "Which time would you like us to deliver your order at?"
      },
      "footer": {
          "text": "Please allow 15 mins either side of your chosen time"
      },
      "action": {
          "buttons": [
              {
                  "type": "reply",
                  "reply": {
                      "id": "slot-1",
                      "title": "15:00"
                  }
              },
              {
                  "type": "reply",
                  "reply": {
                      "id": "slot-2",
                      "title": "16:30"
                  }
              },
              {
                  "type": "reply",
                  "reply": {
                      "id": "slot-3",
                      "title": "17:15"
                  }
              }
          ]
      }
    }
  }
}
```

The resulting message will appear like this:

<img src="/images/messages/whatsapp-reply-button-example-1.png" alt="Whatsapp interactive message reply buttons displaying a choice of delivery times">

In the WhatsApp UI, the message changes its appearance as if the user had answered to that message with the text of one of the buttons. Additionally, that button becomes unclickable while the others remain clickable.

<img src="/images/messages/whatsapp-reply-button-example-2.png" alt="Whatsapp interactive message reply buttons displaying chosen option">

If the user selects the first option, you would subsequently receive something like this via the inbound webhook:

```json
{
    "to": "YOUR_WABA_NUMBER",
    "from": "USERS_NUMBER",
    "channel": "whatsapp",
    "message_uuid": "00000000-0000-0000-0000-000000000000",
    "timestamp": "2021-08-10T00:00:00Z",
    "message_type": "reply",
    "reply": {
        "id": "slot-1",
        "title": "15:00"
    }
}
```

## List Messages: Example

Here is an example of the body of a request for sending a WhatsApp interactive list message with four options classified in two sections:

```json
"from": "YOUR_WABA_NUMBER",
   "to": "USERS_NUMBER",
   "channel": "whatsapp",
   "message_type": "custom",
   "custom": {
    "type": "interactive",
    "interactive": {
      "type": "list",
      "header": {
        "type": "text",
        "text": "Select which pill you would like "
      },
      "body": {
        "text": "You will be presented with a list of options"
      },
      "footer": {
        "text": "There are no wrong choices"
      },
      "action": {
        "button": "Select",
        "sections": [
          {
            "title": "Section A - pills",
            "rows": [
              {
                "id": "row1",
                "title": "Red",
                "description": "Take the red pill"
              },
              {
                "id": "row2",
                "title": "Blue",
                "description": "Take the blue pill"
              },
              {
                "id": "row3",
                "title": "Green",
                "description": "Take the green pill"
              }
            ]
          },
          {
            "title": "Section B - no pills",
            "rows": [
              {
                "id": "row4",
                "title": "Nothing",
                "description": "Do not take a pill"
              }
            ]
          }
        ]
      }
    }
  }
}
```

The resulting message will appear like this:

<img src="/images/messages/whatsapp-list-message-example-1.png" alt="Whatsapp interactive list message displaying a select button to display the options">

When the user clicks on the 'Select' button, the available options are displayed. Then, the user can select one option (maximum) and click on the 'Send' button.

<img src="/images/messages/whatsapp-list-message-example-2.png" alt="Whatsapp interactive list message displaying a choice of various options in two sections">

The appearance of the message changes as if the user had replied to the message with the text of the title and description fields of the API request.

<img src="/images/messages/whatsapp-list-message-example-3.png" alt="Whatsapp interactive list message displaying a choice of various options in two sections">

If the customer selected the first option from Section A, you would subsequently receive something like this via the inbound webhook:

```json
{
    "to": "YOUR_WABA_NUMBER",
    "from": "USERS_NUMBER",
    "channel": "whatsapp",
    "message_uuid": "00000000-0000-0000-0000-000000000000",
    "timestamp": "2021-08-10T00:00:00Z",
    "message_type": "reply",
    "reply": {
        "id": "row1",
        "title": "Red",
        "description": "Take the red pill"
    }
}
```


## Further information

- [WhatsApp Developers Guide: Sending Interactive Messages](https://developers.facebook.com/docs/whatsapp/guides/interactive-messages)
