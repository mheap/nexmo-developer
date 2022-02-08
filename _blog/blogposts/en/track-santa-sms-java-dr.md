---
title: Tracking Santa with SMS and Java
description: Use Number Insight to detect a user's country and provide
  information on how far Santa is from their house via SMS with Java in this
  Christmas tutorial
thumbnail: /content/blog/track-santa-sms-java-dr/Tracking-Santa-with-SMS.png
author: cr0wst
published: true
published_at: 2018-12-07T19:11:13.000Z
updated_at: 2021-05-10T10:28:37.455Z
category: tutorial
tags:
  - java
  - number-insight-api
  - sms-api
comments: true
redirect: ""
canonical: ""
---
Since December of 2004, [Google](http://google.com) has provided an annual Christmas-themed site which allows users to track Santa during Christmas Eve. Additionally, [NORAD](http://www.norad.mil/) has been tracking Santa since 1955. While no official API exists, there is an [unofficial API](https://santa-api.appspot.com/info?client=web) which can be used to track Santa’s whereabouts.

In celebration of the Christmas season, I wanted to create a [Spring Boot](http://spring.io/projects/spring-boot) application that could be used to get updates on Santa’s location via SMS. The full code for this Java application can be found on [GitHub](https://github.com/nexmo-community/santa-tracker-sms).

First, I want to explain how the application works on a higher level. Then we can dive into some of the more challenging problems, and ways to work around them.

## See it in Action

When an SMS is received on my Nexmo number, a payload gets sent to my registered webhook. Information such as the sender's phone number and the message contents are then used to determine how to respond to the message.

Here's how it looks in action:

![The santa tracker in action.](/content/blog/tracking-santa-with-sms-and-java/tracker-in-action.png "The santa tracker in action.")

### The Initial Message

The first time a message is received, the user is always presented with Santa's current location. They are also asked if they would like to provide their postal code to get distance information.

### Location Lookup

Location lookup is not a trivial task. Postal codes are not consistent worldwide, and it helps to know which country the user is contacting from in order to narrow down our search.

If the user elects to provide postal code information, I use [Nexmo Number Insight](https://developer.nexmo.com/number-insight/overview) to lookup the country that they are sending messages from. They are then asked to provide their postal code. From this, I use a service called [GeoNames](http://www.geonames.org/) to lookup the latitude and longitude for that postal code.

This information gets saved in the database along with their phone number. The latitude and longitude is used to calculate how far Santa is from them:

![A response with Santa's location](/content/blog/tracking-santa-with-sms-and-java/where-response.png "A response with Santa's location")

## Getting More Technical

At its surface, the application doesn't seem all that complicated. However, there are quite a few challenges that I ran into during the development process. I'd like to highlight some of the more technical aspects of the code.

### Routing Incoming Messages

My Nexmo number is configured to send `POST` requests to a webhook URL. I have an `IncomingMessageController` setup to handle the incoming messages:

```java
@PostMapping
public void post(@RequestParam("msisdn") String from,
        @RequestParam("to") String nexmoNumber,
        @RequestParam("keyword") String keyword,
        @RequestParam("text") String text
) {
  Phone phone = findOrCreatePhone(from, nexmoNumber);
  findHandler(phone, keyword).handle(phone, text);
}
```

The `findOrCreatePhone` method is used to persist a new `Phone` entity, or to lookup an existing entity. Here's what the phone entity looks like:

```java
@Entity
public class Phone {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  private String number;
  private String nexmoNumber;
  private String countryCode;

  @Enumerated(EnumType.STRING)
  private Stage stage;

  @OneToOne
  private Location location;

  // Getters and Setters
}
```

The entity contains the phone number, the Nexmo number, a country code, and the current stage that the user is in. I will talk about the `Stage` enum in a later section.

The `findHandler` method is used to lookup an appropriate `KeywordHandler` to handle the message:

```java
public interface KeywordHandler {
  void handle(Phone phone, String text);
}
```

Each handler is responsible for handling a specific keyword. The keywords that the application knows about are:

* **HELP** which provides contextual information to assist the user.
* **CANCEL** which cancels the current series of questions.
* **REMOVE** which removes the user from the database.
* **YES** in which the user is responding to the question in the affirmative.
* **NO** in which the user is responding to the question in the negative.
* **WHERE** which responds with Santa's current location.
* **LOCATION** which allows the user to update their location.

Each `KeywordHandler` is registered as a Spring Managed Bean. The `HelpKeywordHandler`, for example, looks like this:

```java
@Component
public class HelpKeywordHandler implements KeywordHandler {
  @Override
  public void handle(Phone phone, String text) {
    // Logic here
  }
}
```

All of the `KeywordHandler` implementations are injected into a `keywordHandler` map on the `IncomingMessageController`:

```java
private final Map<String, KeywordHandler> keywordHandlers;

@Autowired
public IncomingMessageController(Map<String, KeywordHandler> keywordHandlers) {
  this.keywordHandlers = keywordHandlers;
}
```

When injecting into a map, Spring will use `camelCase` class names as the key, and the instantiated class as the value. For example, the `HelpKeywordHandler` is stored with the key `helpKeywordHandler`:

```java
HelpKeywordHandler handler = keywordHandlers.get("helpKeywordHandler");
```

The appropriate `KeywordHandler` is then picked using a variant of the [Strategy Pattern](https://dzone.com/articles/java-the-strategy-pattern). If no valid `KeywordHandler` is found, then the `DefaultKeywordHandler` is used to respond.

```java
private KeywordHandler findHandler(Phone phone, String keyword) {
  // New users should always go to the default handler
  if (phone.getStage() == null) {
    return keywordHandlers.get("defaultKeywordHandler");
  }

  KeywordHandler handler = keywordHandlers.get(keywordToHandlerName(keyword));
  return (handler != null) ? handler : keywordHandlers.get("defaultKeywordHandler");
}

private String keywordToHandlerName(String keyword) {
  return keyword.toLowerCase() + "KeywordHandler";
}
```

Routing messages like this allows for flexibility when new keywords need to be added.

### Handling the Various Stages

Each handler is responsible for messages that start with its keyword. However, how does the `YesKeywordHandler` know which question the user is responding to? This is where the `Stage` enum inside of the `Phone` class comes in.

The `Phone` entity can exist in the following intermediary stages:

* **No Stage (`null`)** for users that have just been created and have not been asked a question yet.
* **`INITIAL`** for users who have been responded to with the first message containing Santa's location and a prompt on whether or not they would like to provide a postal code.
* **`COUNTRY_PROMPT`** for users who have been asked if their country code is correct.
* **`POSTAL_PROMPT`** for users who have been asked to provide a postal code.

Once the questions have been asked, they are put in the following final stages:

* **`REGISTERED`** for users who have provided a postal code and will receive more detailed information.
* **`GUEST`** for users who did not wish to provide postal code information and will only receive Santa's current location with no distance calculated.

This is how the `YesKeywordHandler` uses stages:

```java
@Override
public void handle(Phone phone, String text) {
  if (phone.getStage() == Phone.Stage.INITIAL) {
    handlePromptForCountryCode(phone);
  } else if (phone.getStage() == Phone.Stage.COUNTRY_PROMPT) {
    handlePromptForPostalCode(phone);
  } else {
    outgoingMessageService.sendUnknown(phone);
  }
}
```

A user that is answering in the `INITIAL` stage must be answering the question "Would you like to provide postal code information?" 

A user answering in the `COUNTRY_PROMPT` stage must be answering the question "I see you're messaging from the US. Reply YES, a 2-character country code, or CANCEL if you've changed your mind."

### Getting the Country Code

In order to lookup the postal code more accurately, it helps to know the country the user is messaging from. I created a `PhoneLocationLookupService` which uses Nexmo Basic Number Insight to lookup the country information for the phone number:

```java
@Service
public class PhoneLocationLookupService {
  private final InsightClient insightClient;

  @Autowired
  public PhoneLocationLookupService(NexmoClient nexmoClient) {
    this.insightClient = nexmoClient.getInsightClient();
  }

  public String lookupCountryCode(String number) {
    try {
      return this.insightClient.getBasicNumberInsight(number).getCountryCode();
    } catch (IOException | NexmoClientException e) {
      return null;
    }
  }
}
```

The application will ask the user to confirm their country just in case they are travelling and want to set themselves in a different country instead.

### Lookup for Postal Codes

It turns out that looking up latitude and longitude information for postal codes is not a trivial task. I chose to work with GeoNames because the service is free.

I created a `PostCodeLookupService` to handle looking up the postal code information. The `getLocation` method first looks to see if we already know about the postal code in the database. This is a good practice as it helps limit the number of calls to the third party service.

If there isn't an existing `Location` entity, the third party service is called, and a new entity is persisted. If we couldn't find a location matching that postal code, we return an empty `Optional` so that the application knows to ask the user to try again:

```java
private Optional<Location> getLocation(String country, String postalCode) {
  Optional<Location> locationOptional = locationRepository.findByPostalCode(postalCode);
  if (locationOptional.isPresent()) {
    return locationOptional;
  }

  LocationResponse response = getLocationResponse(country, postalCode);
  if (response.getPostalCodes().isEmpty()) {
    return Optional.empty();
  }

  Location newLocation = buildLocation(response, postalCode);
  return Optional.of(locationRepository.save(newLocation));
}
```

### Calculating Distance

Once we have the user's latitude and longitude we can lookup Santa's current location and use a formula to determine how far away the user is from Santa. This is done in the `DistanceCalculationService`:

```java
 public double getDistanceInMiles(double lat1, double lng1, double lat2, double lng2) {
  double theta = lng1 - lng2;
  double dist = Math.sin(Math.toRadians(lat1))
          * Math.sin(Math.toRadians(lat2))
          + Math.cos(Math.toRadians(lat1))
          * Math.cos(Math.toRadians(lat2))
          * Math.cos(Math.toRadians(theta));

  dist = Math.acos(dist);
  dist = Math.toDegrees(dist);
  dist = dist * 60 * 1.1515;

  return dist;
}
```

## Conclusion

This was a look into how one might create an application that allows you to get Santa's location updates via SMS. We covered routing messages based on keywords, using multiple stages to determine which questions a user is responding to, and using Nexmo Number Insight to get the country code for a phone number.

For more detailed information, I would recommend looking at the code on [GitHub](https://github.com/nexmo-community/santa-tracker-sms). The `README` file contains all the information you need to get up and running with the application itself.

Be sure to check out [Google's Santa Tracker](https://santatracker.google.com/) or [NORAD Santa Tracker](http://www.noradsanta.org/) around Christmas Eve as an additional way to keep tabs on Santa.