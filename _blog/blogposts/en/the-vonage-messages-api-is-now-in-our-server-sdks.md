---
title: The Vonage Messages API is Now in Our Server SDKs
description: Announcing that the Vonage Messages API has been added to Server
  SDKs for Ruby, Node, Python, PHP, Java, and .net
thumbnail: /content/blog/the-vonage-messages-api-is-now-in-our-server-sdks/sdk_updates.png
author: karl-lingiah
published: true
published_at: 2022-07-05T09:51:10.765Z
updated_at: 2022-07-05T09:51:12.743Z
category: announcement
tags:
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Vonage's [Messages API](https://developer.vonage.com/messages/overview) offers developers the ability to integrate messaging functionality into their applications across multiple channels such as **SMS**, **MMS**, **WhatsApp**, **Facebook Messenger**, and **Viber**.

Up until now though, if you wanted to use the Messages API, you needed to access the endpoint directly. That meant dealing with all the various low-level concerns such as managing the Request/Response cycle, creating headers, dealing with authentication, and serializing data.

I'm super excited to announce that our [Server SDKs](https://developer.vonage.com/tools) now support the Messages API. So, if you're a developer working with [Ruby](https://github.com/vonage/vonage-ruby-sdk), [Node](https://github.com/vonage/vonage-node-sdk), [PHP](https://github.com/vonage/vonage-php-sdk), [Python](https://github.com/vonage/vonage-python-sdk), [Java](https://github.com/Vonage/vonage-java-sdk), or [.net](https://github.com/vonage/vonage-dotnet-sdk), you can let our SDKs deal with the low-level detail for you and instead focus on building your application!

Let's take a look at just a few of the things you can do using the Messages API via our SDKs.

## SMS

One of the things you can do with the Messages API is to send SMS messages. You may have already have sent SMS messages using our Server SDKs via our [SMS API](https://developer.vonage.com/messaging/sms/overview). You now have the option to use either the SMS API or the Messages API to send SMS messages.

There are some differences between the two APIs. A couple of examples would be the authentication options and the set-up for webhooks. There are also differences in terms of how these different APIs are implemented in our Server SDKs.

Here are examples of sending an SMS via the Messages API using the **Ruby SDK** and **Node SDK**.

### Ruby SDK

```ruby
# instantiating a client object
client = Vonage::Client.new(
  application_id: '76543a12-1b87-4c32-a1b2-1d9876543210',
  private_key: File.read('private.key')
)

# creating an SMS message object
message = Vonage::Messaging::Message.sms(
  message: "A SMS message sent using the Vonage Messages API"
)

# sending the SMS
client.messaging.send(
  from: '447700900000',
  to: '447700900001',
  **message
)
```


### Node SDK

```javascript
// initializing dependencies
const Vonage = require('@vonage/server-sdk')
const SMS = require('@vonage/server-sdk/lib/Messages/SMS');
const fs = require('fs');

// reads the private key file
let privateKey = fs.readFileSync('private.key', 'utf8');

// instantiating a client object
const vonage = new Vonage({
  apiKey: VONAGE_API_KEY,
  apiSecret: VONAGE_API_SECRET,
  applicationId: '76543a12-1b87-4c32-a1b2-1d9876543210',
  privateKey: privateKey
})

// sending the SMS
vonage.messages.send(
  new SMS("This is an SMS text message sent using the Messages API", '447700900001', '447700900000'),
  (err, data) => {
    if (err) {
      console.error(err);
    } else {
      console.log(data.message_uuid);
    }
  }
);
```

## MMS

Another Messages API channel now available in the SDKs is MMS (Multimedia Message Service). This channel lets you send messages that include multimedia content such as images, audio, video, and vCards (`.vcf` files).

Here's an example of sending an MMS image message using the **.net SDK**.

```c#
using System;
using System.Threading.Tasks;
using Vonage;
using Vonage.Messages;
using Vonage.Request;

namespace DotnetCliCodeSnippets.Messages.Mms;

public class SendMmsImage : ICodeSnippet
{
    public async Task Execute()
    {
        var to = Environment.GetEnvironmentVariable("TO_NUMBER") ?? "TO_NUMBER";
        var brandName = Environment.GetEnvironmentVariable("VONAGE_BRAND_NAME") ?? "VONAGE_BRAND_NAME";
        var apiKey = Environment.GetEnvironmentVariable("VONAGE_API_KEY") ?? "VONAGE_API_KEY";
        var apiSecret = Environment.GetEnvironmentVariable("VONAGE_API_SECRET") ?? "VONAGE_API_SECRET";

        var credentials = Credentials.FromApiKeyAndSecret(
            apiKey,
            apiSecret
        );

        var vonageClient = new VonageClient(credentials);

        var request = new Vonage.Messages.Mms.MmsImageRequest
        {
            To = to,
            From = brandName,
            Image = new Attachment
            {
                Url = "https://example.com/image.jpg"
            }
        };

        var response = await vonageClient.MessagesClient.SendAsync(request);
        Console.WriteLine($"Message UUID: {response.MessageUuid}");
    }
}
```

## WhatsApp

WhatsApp is a messaging channel that has exploded in popularity over recent years. WhatsApp in a business context is great for transactional messaging, as well as being really well suited to conversational commerce use-cases. With the Vonage Messages API, you can send and receive WhatsApp messages using a WhatsApp Business Account. With Messages now in the SDKs, it's even easier to incorporate WhatsApp messaging flows into your applications.

The Messages API supports numerous WhatsApp message types, including text, image, audio, and video, among others, with support for more messages types to be added soon! [Find out more about WhatsApp messaging and setting up a WhatsApp Business Account](https://developer.vonage.com/messages/concepts/whatsapp).

Below is an example of sending a WhatsApp video message using the the **PHP SDK**.

```php
// creating a Keypair object using private key and app id
$keypair = new \Vonage\Client\Credentials\Keypair(
    file_get_contents('private.key'),
    '76543a12-1b87-4c32-a1b2-1d9876543210'
);

// instantiating a Client object using the Keypair
$client = new \Vonage\Client($keypair);


// instantiating a VideoObject message attachment
$videoObject = new \Vonage\Messages\MessageObjects\VideoObject(
    'https://example.com/video.mp4',
    'This is an video file'
);

// instantiating a WhatsAppVideo message which contains the VideoObject attachment
$whatsApp = new \Vonage\Messages\MessageType\WhatsApp\WhatsAppVideo(
    '447700900001',
    '447700900000',
    $videoObject
);

// sending the WhatsAppVideo message
$client->send($whatsApp);
```


## Facebook Messenger

Similarly to WhatsApp, the Messages API lets you use Facebook Messenger in a business context to enable conversations between Facebook users and Facebook Pages. Again, there are multiple message types within this channel such as text, image, audio, video, and file.

You can find out more about Messenger in our documentation, and check out an example below of using the **Java SDK** to send a Messenger audio message.

```java
import com.vonage.client.VonageClient;
import static com.vonage.quickstart.Util.envVar;

String VONAGE_APPLICATION_ID = envVar("VONAGE_APPLICATION_ID");
String VONAGE_PRIVATE_KEY_PATH = envVar("VONAGE_PRIVATE_KEY_PATH");
String FROM_ID = envVar("FROM_ID");
String TO_ID = envVar("TO_ID");

VonageClient client = VonageClient.builder()
                                  .applicationId(VONAGE_APPLICATION_ID)
                                  .privateKeyPath(VONAGE_PRIVATE_KEY_PATH)
                                  .build();

client.getMessagesClient().sendMessage(
   MessengerAudioRequest.builder()
                        .from(FROM_ID).to(TO_ID)
                        .url("https://example.com/audio.mp3")
                        .build()
);
```

## Viber

Another messaging channel available in the Messages API is Viber. Viber can be used to send text or image messages. Find out more about Viber [in our documentation](https://developer.vonage.com/messages/concepts/viber).

Below is an example of how you would send a Viber text message using the **Python SDK**.

```python
# initializing dependencies
import vonage

# instantiating a Client object with app id and private key
client = vonage.Client(
    application_id='76543a12-1b87-4c32-a1b2-1d9876543210',
    private_key='private.key',
)

# sending a message using the Messages object's send_message method
client.messages.send_message(
    {
        'channel': 'viber_service',
        'message_type': 'text',
        'to': '447700900000',
        'from': '9876543210',
        'text': 'This is a Viber message from the Vonage Messages API'
    }
)
```

---

Want to get started using the Messages API today? Then create a free [Vonage Developer account](https://ui.idp.vonage.com/ui/auth/registration), install the server SDK for your preferred programming language, and try out some of the language-specific [code examples](https://developer.vonage.com/messages/code-snippets/before-you-begin) in our docs!
