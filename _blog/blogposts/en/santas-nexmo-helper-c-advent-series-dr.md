---
title: Santa’s Nexmo Helper C# Advent Series
description: Create an FAQ bot for Santa that can be reached over, and respond
  to Facebook Messenger, WhatsApp, and SMS using Nexmo Messages API
thumbnail: /content/blog/santas-nexmo-helper-c-advent-series-dr/E_Santas-Helper_1200x600.jpg
author: stevelorello
published: true
published_at: 2019-12-19T09:01:01.000Z
updated_at: 2021-05-18T11:22:04.263Z
category: tutorial
tags:
  - dotnet
  - azure
  - messages-api
comments: true
redirect: ""
canonical: ""
---
'Tis the season of Advent, such a busy time for so many, but none more than Ol' St. Nick, whose feast day the Eastern Rite celebrates today. In honor of the season of [C# Advent](https://crosscuttingconcerns.com/The-Third-Annual-csharp-Advent) that's upon us, we're going to help Santa out by automating some of his correspondence and providing him more modern means of fielding questions than the postal service.

To crystallize our goal here, we are going to create an FAQ bot for Santa that can be reached over, and respond via, Facebook Messenger, WhatsApp, and SMS.

We're going to build this with the help of [QnAMaker](https://www.qnamaker.ai/) and of course the [Nexmo Messages API](https://developer.nexmo.com/messages/overview)

## Prerequisites

<sign-up number></sign-up>

* Visual Studio 2019 version 16.3 or higher
* An Azure Account
* Optional: [Ngrok](https://ngrok.com/) for test deployment
* Optional: For Facebook Messenger, we will need to link a Facebook Page to our Nexmo account—you can see step by step instructions on [Nexmo Developer](https://developer.nexmo.com/use-cases/sending-facebook-messenger-messages-with-messages-api). Completing [part 2](https://developer.nexmo.com/use-cases/sending-facebook-messenger-messages-with-messages-api#part-2-link-your-facebook-page-to-your-nexmo-application) of the guide will create a Nexmo App with a linked Facebook Page; be sure to save the private key file that is generated for this application.

> Note: The code in this demo will work with WhatsApp Messages once WhatsApp Business is configured. That said, WhatsApp is more meant for a business case—to see more details about getting an app configured for WhatsApp you can look at the guide on [Nexmo Developer](https://developer.nexmo.com/use-cases/sending-whatsapp-messages-with-messages-api)

## Building Our Bot

### Setup

To build out our bot we are going to head over to [QnAMaker](https://www.qnamaker.ai/) and sign in using an Azure account.

Click "Create a Knowledge Base".

Follow the instructions in step 1 for creating a QnA service in Azure.

For Step 2, set the following:

* Microsoft Azure Directory ID
* The Subscription's name from the Azure account
* The QnA service we're going to use (this will match the Service Name we just created in the Azure Portal)
* The language of our bot

![Build QnAMaker gif](/content/blog/santa’s-nexmo-helper-c-advent-series/image-graphic1.png)

For Step 3 we're going to name our knowledge base "Santa's Nexmo Helper."

Step 4 is where QnA Maker gets cool—populating this bot's knowledge base is as easy as linking it to an FAQ page or uploading an FAQ file. Of course for this demo, we're going to use the official Santa Claus website's [FAQ page](http://www.santaclaus.com/2014/11/santas-faq-page-frequently-ask-questions-about-santa-claus/).

We're also going to add some chitchat to our bot—since our bot is going to be an honorary elf, we're going to use the witty chitchat selection

With all this set, click Create Knowledge Base.

This will ingest the FAQ's that we pointed QnA Maker at and will bring us to a page that looks like this:

![QnA Maker Knowledgebase edit screen](/content/blog/santa’s-nexmo-helper-c-advent-series/qnamaker_kb_edit_screen.png)

### Editing, Publishing, and Testing Our Knowledgebase

This is our Knowledgebase edit screen. From here we can see what our knowledge base looks like. We can also freely edit it if we want to change some answers; e.g. maybe let's shorten the "Who Is Santa Claus?" answer.

After editing the Knowledge Base sufficiently, clicking `Save and Train` will save and train the Bot.

To test, click the `Test` button in the upper right-hand corner. This will open the testing dialog, you can send id a question e.g. `how do reindeer fly?` and the bot will respond!

![Test Question](/content/blog/santa’s-nexmo-helper-c-advent-series/testquestion.png)

It's even possible to inspect how the bot made its determination. Click the inspect link and the inspection dialog will pop out. This will show the bot's confidence in its answer and some alternatives it came up with.

![Inspect Drill down](/content/blog/santa’s-nexmo-helper-c-advent-series/inspect_drill_down.png)

When the bot's ready to go, click publish on the top of the page, then click publish inside the dialog that shows up. When this completes there will be a screen that pops up with some helpful request structures that can be used to generate an answer from the bot. It'll look something like:

```text
POST /knowledgebases/YOUR_KNOWLEDGE_BASE_ID/generateAnswer
Host: https://nexmofaqbot.azurewebsites.net/qnamaker
Authorization: EndpointKey YOUR_KNOWLEDGE_BASE_ENDPOINT_KEY
Content-Type: application/json
{"question":"YOUR_QUESTION"}
```

Save this string—it's going to be used to create the WebService that will drive our bot over the Messages API.

## Building Our App

Start by opening Visual Studio and selecting "Create a New Project." In the dialog that opens, select an ASP.NET Core Web Application. Name it something like "QnAMakerMessagesDemo." Select ASP.NET Core 3.0, "Web Application (Model-View-Control)" as the type and click create.

### Install NuGet Packages

In Visual Studio go to Tools -> NuGet Package Manager -> Manage NuGet Packages for Solution.

Install the following NuGet packages:

* Newtonsoft.Json
* Nexmo.Csharp.Client
* BouncyCastle
* jose-jwt

### Building Our Token Generator

Create a class called TokenGenerator and add the following code to it:

```csharp
public static string GenerateToken(IConfiguration config)
{
    // retrieve appID and privateKey from configuration
    var appId = config["Authentication:appId"];
    var priavteKeyPath = config["Authentication:privateKey"];
    string privateKey = "";
    using (var reader = File.OpenText(priavteKeyPath)) // file containing RSA PKCS1 private key
        privateKey = reader.ReadToEnd();

    //generate claims list
    const int SECONDS_EXPIRY = 3600;
    var t = DateTime.UtcNow - new DateTime(1970, 1, 1);
    var iat = new Claim("iat", ((Int32)t.TotalSeconds).ToString(), ClaimValueTypes.Integer32); // Unix Timestamp for right now
    var application_id = new Claim("application_id", appId); // Current app ID
    var exp = new Claim("exp", ((Int32)(t.TotalSeconds + SECONDS_EXPIRY)).ToString(), ClaimValueTypes.Integer32); // Unix timestamp for when the token expires
    var jti = new Claim("jti", Guid.NewGuid().ToString()); // Unique Token ID
    var claims = new List<Claim>() { iat, application_id, exp, jti };

    //create rsa parameters
    RSAParameters rsaParams;
    using (var tr = new StringReader(privateKey))
    {
        var pemReader = new PemReader(tr);
        var kp = pemReader.ReadObject();
        var privateRsaParams = kp as RsaPrivateCrtKeyParameters;
        rsaParams = DotNetUtilities.ToRSAParameters(privateRsaParams);
    }

    //generate and return JWT
    using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider())
    {
        rsa.ImportParameters(rsaParams);
        Dictionary<string, object> payload = claims.ToDictionary(k => k.Type, v => (object)v.Value);
        return Jose.JWT.Encode(payload, rsa, Jose.JwsAlgorithm.RS256);
    }
}
```

This will generate the JWT that's needed to authenticate against the Messages App created as part of the prerequisites.

### Add appId and the Private Key Path to the Configuration

The JWT generator calls on an appId and path to the private key saved earlier to be in the appsettings.json file.

Open this file and add the following to the configuration object:

```json
"Authentication": {
    "appId": "NEXMO_APPLICATION_ID",
    "privateKey": "C:\\Path\\to\\Private\\key.key"
  }
```

### Build Data Structures to Receive and Send Data

A couple of POCO's are needed for this demo; they're a tad verbose, and don't do anything except define the messages objects per the [spec](https://developer.nexmo.com/api/messages-olympus), so the full structure is omitted from this post. Simply add the following classes to the project:

[InboundMessage.cs](https://github.com/nexmo-community/QnAMakerMessagesDemo/blob/master/QnAMakerMessagesDemo/InboundMessage.cs)
[MessageRequest.cs](https://github.com/nexmo-community/QnAMakerMessagesDemo/blob/master/QnAMakerMessagesDemo/MessageRequest.cs)

### Send Messages

With the structures sorted the next step is to send messages across the Nexmo messages API. Create a class called `MessageSender`, this will have a single static method `SendMessage` which will simply create a Message Request, create a JWT, create a request, and send the request to the Messages API—it should look something like this:

```csharp
public static void SendMessage(string message, string fromId, string toId, IConfiguration config, string type)
{
    const string MESSAGING_URL = @"https://api.nexmo.com/v0.1/messages";
    try
    {
        var jwt = TokenGenerator.GenerateToken(config);

        //construct message Request
        var requestObject = new MessageRequest()
        {
            to = new MessageRequest.To()
            {
                type = type
            },
            from = new MessageRequest.From()
            {
                type = type
            },
            message = new MessageRequest.Message()
            {
                content = new MessageRequest.Message.Content()
                {
                    type = "text",
                    text = message
                }
            }
        };

        //special messenger request formatting (use to/from id rather than number, set category to RESPONSE)
        if (type == "messenger")
        {
            requestObject.message.messenger = new MessageRequest.Message.Messenger()
            {
                category = "RESPONSE"
            };
            requestObject.to.id = toId;
            requestObject.from.id = fromId;
        }
        else
        {
            requestObject.to.number = toId;
            requestObject.from.number = fromId;
        }

        //Generate Request payload from requestObject
        var requestPayload = JsonConvert.SerializeObject(requestObject, new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Ignore, DefaultValueHandling = DefaultValueHandling.Ignore });

        //build request
        var httpWebRequest = (HttpWebRequest)WebRequest.Create(MESSAGING_URL);
        httpWebRequest.ContentType = "application/json";
        httpWebRequest.Accept = "application/json";
        httpWebRequest.Method = "POST";
        httpWebRequest.PreAuthenticate = true;
        httpWebRequest.Headers.Add("Authorization", "Bearer " + jwt);
        using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
        {
            streamWriter.Write(requestPayload);
        }

        //handle response
        using (var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse())
        {
            using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                Console.WriteLine("Message Sent");
            }
        }
    }
    catch (Exception e)
    {
        Debug.WriteLine(e.ToString());
    }
}
```

### Ask the Bot a Question and Send a Response

Now it's time to talk to the FAQ bot from the app. This is where the sample REST calls that QnAMaker presented earlier will come into play. Recall this string from earlier.

```text
POST /knowledgebases/YOUR_KNOWLEDGE_BASE_ID/generateAnswer
Host: https://AZURE_APP_NAME.azurewebsites.net/qnamaker
Authorization: EndpointKey YOUR_KNOWLEDGE_BASE_ENDPOINT_KEY
Content-Type: application/json
{"question":"YOUR_QUESTION"}
```

Use that string to create some useful constants/readonly's for the Questioner—fill in with appropriate values from the string above:

```csharp
//TODO: fill in with Knowledgebase ID
const string kb_id = "YOUR_KNOWLEDGE_BASE_ID";

//TODO: fill in with Knowledgebase Endpoint key
const string ENDPOINT_KEY = "YOUR_KNOWLEDGE_BASE_ENDPOINT_KEY";

const string QUESTION_FORMAT = @"{{'question': '{0}'}}";

//TODO fill in base url
static readonly string URI = $"https://AZURE_APP_NAME.azurewebsites.net/qnamaker/knowledgebases/{kb_id}/generateAnswer";
```

Next, create a task to ask the question:

```csharp
public static async Task<string> RequestAnswer(string question)
{
    using (var client = new HttpClient())
    using (var request = new HttpRequestMessage())
    {
        request.Method = HttpMethod.Post;
        request.RequestUri = new Uri(URI);
        var formatted_question = string.Format(QUESTION_FORMAT, question);
        request.Content = new StringContent(formatted_question, Encoding.UTF8, "application/json");
        request.Headers.Add("Authorization", "EndpointKey " + ENDPOINT_KEY);
        var response = await client.SendAsync(request);
        var jsonResponse = await response.Content.ReadAsStringAsync();
        JObject obj = JObject.Parse(jsonResponse);
        var answer = ((JArray)obj["answers"])[0]["answer"];
        return answer.ToString();
    }
}
```

This simply formats the question from the messages API and sends the request off as a generateAnswer post request to the QnAMaker bot.

Finally, create a method to drive the request and reply with an answer.

```csharp
public static async Task AskQuestion(string to, string from, string type, string question, IConfiguration config)
{
    question = HttpUtility.JavaScriptStringEncode(question);
    var response = await RequestAnswer(question);
    MessageSender.SendMessage(response, from, to, config, type);
}
```

### Build Controller to Receive Incoming Messages

The final piece of the puzzle is the controller that will handle the influx of messages from the Messages API. Create an empty MVC controller called `MessagesController`.

#### Dependency Injection and Configuration

Add an IConfiguration field called _config to this and set up Dependency injection of configuration by creating a controller constructor taking an IConfiguration object:

```csharp
private IConfiguration _config;

public MessagesController(IConfiguration config)
{
    _config = config;
}
```

#### Status Request

Next create a Status Post request that simply returns no content:

```csharp
[HttpPost]
public HttpStatusCode Status()
{
    return HttpStatusCode.NoContent;
}
```

#### Inbound Messages

Next, add a Post Request for inbound messages from the Messages API.

This method will extract the inbound message from the body, then forward on the Questioner tasks from the content of the request body.

```csharp
[HttpPost]
public HttpStatusCode Inbound([FromBody]InboundMessage message)
{
    Debug.WriteLine(JsonConvert.SerializeObject(message));
    if (message.from.type == "messenger")
    {
        _ = Questioner.AskQuestion(message.from.id, message.to.id, message.from.type, message.message.content.text, _config);
    }
    else
    {
        _ = Questioner.AskQuestion(message.from.number, message.to.number, message.from.type, message.message.content.text, _config);
    }
    return HttpStatusCode.NoContent;
}
```

#### Inbound SMS

Finally, add an HttpGet request to manage the inbound SMS messages. This will similarly extract the needed information from the inbound message and ask the question of the questioner.

```csharp
[HttpGet]
public HttpStatusCode InboundSms([FromQuery] SMS.SMSInbound inboundMessage)
{
    _ = Questioner.AskQuestion(inboundMessage.msisdn, inboundMessage.to, "sms", inboundMessage.text, _config);
    return HttpStatusCode.NoContent;
}
```

With this sorted, the service is ready for deployment.

## Testing

The last thing needed is to fire up the service, expose it to the internet, and wire up the Nexmo Messages App to send webhooks to the service.

### IIS Express Configuration

For simplicity this demo uses IIS. To make setting up ngrok easier disable SSL for IIS Express by going into the project Debug properties and unchecking the "Enable SSL" setting:

![Debug settings](/content/blog/santa’s-nexmo-helper-c-advent-series/iis_config.png)

Take note of the port number in the app URL field, it will be used in the next step.

### Setting up Ngrok

The next step is to expose this endpoint to the internet. For this demo, something like [ngrok](https://ngrok.com/) can be used to create a tunnel back to the IIS Express port. After installing ngrok use a command like:

```bash
ngrok http --host-header="localhost:PORT_NUMBER" http://localhost:PORT_NUMBER
```

To set up the tunnel, replace 'PORT_NUMBER' with the IIS Express port number noted earlier. This will create an output that looks something like this:

![ngrok output](/content/blog/santa’s-nexmo-helper-c-advent-series/ngrok-1.png)

Take note of the http base url here—in the image above the base url is http<span></span>://dc0feb1d<span></span>.ngrok<span></span>.io.

### Configuring webhooks

The final step before turning the service on is to configure the webhooks to callback into the service.

#### Inbound SMS

Go do the [Nexmo Dashboard](https://dashboard.nexmo.com/) and go to `Settings`. Set the Inbound Messages URL for SMS to the ngrok_baseurl/messages/InboundSms, given the example above.

```text
http://dc0feb1d.ngroke.io/messages/InboundSms
```

#### Other Inbound Messages

In the [Nexmo Dashboard](https://dashboard.nexmo.com/) open Messages and Dispatch -> Your Applications. Open the application associated with the linked accounts, and click 'Edit'. Under Capabilities in the Messages section, set the Inbound URL and Status URL to match the ngrok baseurl /Messages/Inbound and /Messages/Status respectively and click save.

Per the example ngrok tunnel it will look something like:

![messages urls](/content/blog/santa’s-nexmo-helper-c-advent-series/messages_urls.png)

> NOTE: The 8 characters preceding ngrok<span></span>.io are not fixed on the free tier. This means every time the ngrok command is run it will be necessary to change where the webhooks are aiming. It's possible to create a static hostname by upgrading to a paid ngrok tier.

## Fire It Up and Test

And that's it! Santa's Nexmo Helper is ready to deploy. Fire up IIS Express and message away. This can be reached over any channel configured to reach the messages app.

Here's an example from Facebook:

![Facebook Example](/content/blog/santa’s-nexmo-helper-c-advent-series/facebook_sample.jpg)

And one from SMS:

![SMS Example](/content/blog/santa’s-nexmo-helper-c-advent-series/sms_sample.jpg)

Well, there it is, Santa's Nexmo Helper is up and operational.

## Further reading

* Full source code for this demo can be found in [GitHub](https://github.com/nexmo-community/QnAMakerMessagesDemo)
* For more info on QnAMaker check out their website [here](https://www.qnamaker.ai/)
* For fully interactive bots check out [Luis Ai](https://www.luis.ai/)
* For more information on the Nexmo Messages API, check out the documentation on [Nexmo Developer](https://developer.nexmo.com/messages/overview)
* For more APIs by Nexmo check out our [Developer site](https://developer.nexmo.com/)
* To check out the Nexmo .NET SDK you can take a look at out our [GitHub Repo](https://github.com/nexmo/nexmo-dotnet)