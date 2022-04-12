---
title: How to generate JWTs
description: This topic explains how to generate JWTs for use in your app. JSON Web Tokens (JWTs) and Access Control Lists (ACLs) are a key concept to understand in order to authenticate your apps and users.
navigation_weight: 3
---

# How to generate JWTs

## JWTs

### Overview

The Vonage Client SDKs use [JWTs](https://jwt.io/) for authentication when a user logs in. These JWTs are generated using the application ID and private key that is provided [when a new application is created](/tutorials/client-sdk-generate-test-credentials#create-a-nexmo-application).

### Claims

Using that `private.key` and the application ID, we can mint a new JWT. In order to log a user into a Vonage client, the JWT will need the following claims:

|Claim | Description |
| --------- | ----------- |
| `sub`| The "subject". The subject, in this case, will be the name of the user created and associated with your Vonage Application. |
| `acl`| Access control list. The Client SDK uses this as a permission system for users. Read more about it in the [ACL overview](#acls). |
| `application_id`| This is the ID of the Vonage Application you created. |
| `iat`| "Issued at time" This is the time the JWT was issued, in unix epoch time. |
| `jti`| "JWT ID". This is a unique identifier for this JWT. |
| `exp`| "Expiration time" This is the time in the future that the JWT will expire, in unix epoch time.  |

> *The `exp` claim is optional.* If the claim is not provided, then the JWT will expire by default in 15 minutes. The max expiration time for a JWT is 24 hours. JWTs should typically be short-lived, as it is trivial to create a new JWT and some JWTs can have multiple far-reaching permissions.

### Sample JWT Payload

Once all the claims have been provided, the resulting claims should appear like so:

```json
{
  "iat": 1532093588,
  "jti": "705b6f50-8c21-11e8-9bcb-595326422d60",
  "sub": "alice",
  "exp": "1532179987",
  "acl": {
    "paths": {
      "/*/users/**": {},
      "/*/conversations/**": {},
      "/*/sessions/**": {},
      "/*/devices/**": {},
      "/*/image/**": {},
      "/*/media/**": {},
      "/*/applications/**": {},
      "/*/push/**": {},
      "/*/knocking/**": {},
      "/*/legs/**": {}
    }
  },
  "application_id": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
}
```

## ACLs

### Overview

In the previous section, you can see that the `acl` claim has a `paths` object containing multiple endpoints. These endpoints correspond with certain permissions a user can have when utilizing Client SDK features.

### Paths

|Endpoint | Description |
| --------- | ----------- |
| `/*/sessions/**`| Log in as a user|
| `/*/users/**`| Create and manage users|
| `/*/conversations/**`| Create and manage conversations & send/receive messages|
| `/*/image/**`| Send and receive images|
| `/*/media/**`| Send and receive audio|
| `/*/knocking/**`| Start phone calls|
| `/*/push/**`| Receive push notifications|
| `/*/devices/**`| Send push notifications|
| `/*/applications/**`| Upload push notification certificate|
| `/*/legs/**`| Create and manage legs in a conversation|

You should provide the user you are generating with permissions to access only the relevant paths. For instance, if a user is not going to upload or receive push notifications, you can create a JWT without including the `/*/applications/**`or `/*/push/**` paths.

## Vonage Server SDKs

### Vonage CLI

You can use the [Vonage CLI](https://github.com/vonage/vonage-cli) to create a JWT including the appropriate claims.

```sh
vonage jwt --private_key=./private.key --subject=alice --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' --app_id=YOUR_APP_ID
```

### Node

The beta version of the [Vonage Node Server SDK](https://github.com/Nexmo/nexmo-node/tree/beta#jwt) can also create a JWT [including the appropriate claims](https://github.com/Nexmo/nexmo-node/tree/beta#jwt).

```js
const aclPaths = {
  "paths": {
    "/*/users/**": {},
    "/*/conversations/**": {},
    "/*/sessions/**": {},
    "/*/devices/**": {},
    "/*/image/**": {},
    "/*/media/**": {},
    "/*/applications/**": {},
    "/*/push/**": {},
    "/*/knocking/**": {},
    "/*/legs/**": {}
  }
}

Nexmo.generateJwt(PRIVATE_KEY, {
            application_id: "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
            sub: "alice",
            //expire in 24 hours
            exp: Math.round(new Date().getTime()/1000)+86400,
            acl: aclPaths
          })
```

### PHP

The current version of the [Vonage PHP Server SDK](https://github.com/Nexmo/nexmo-php) can also create a JWT including the appropriate claims when using the Keypair authentication.

```php
$keypair = new \Vonage\Client\Credentials\Keypair(
    file_get_contents('/path/to/private.key'),
    'aaaaaaaa-bbbb-cccc-dddd-0123456789ab'
);
$client = new \Vonage\Client($keypair);

$claims = [
    'acl' => [
        'paths' => [
            '/*/users/**' => (object) [],
            '/*/conversations/**' => (object) [],
            '/*/sessions/**' => (object) [],
            '/*/devices/**' => (object) [],
            '/*/image/**' => (object) [],
            '/*/media/**' => (object) [],
            '/*/applications/**' => (object) [],
            '/*/push/**' => (object) [],
            '/*/knocking/**' => (object) [],
            '/*/legs/**' => (object) [],
        ]
    ]
];
$token = $client->generateJwt($claims);
$tokenString = (string) $token;
```

### Java / Kotlin

The [Nexmo JWT JDK library](https://github.com/Nexmo/nexmo-jwt-jdk) can be used to generate a signed JWT with claims.

```kotlin
val token : String = Jwt.builder()
    .applicationId("aaaaaaaa-bbbb-cccc-dddd-0123456789ab")
    .privateKeyPath("/path/to/private.key")
    .issuedAt(ZonedDateTime.now())
    .subject("alice")
    .addClaim("acl", mapOf(
        "paths" to mapOf(
            "/*/users/**" to mapOf<String, Any>(),
            "/*/conversations/**" to mapOf(),
            "/*/sessions/**" to mapOf(),
            "/*/devices/**" to mapOf(),
            "/*/image/**" to mapOf(),
            "/*/media/**" to mapOf(),
            "/*/applications/**" to mapOf(),
            "/*/push/**" to mapOf(),
            "/*/knocking/**" to mapOf(),
            "/*/legs/**" to mapOf()
        )
    ))
    .build()
    .generate()
```

### Other languages

Creating a JWT with the appropriate claims for authenticating a Vonage user is not currently provided in any of the other Vonage Client Libraries. Instead, you are encouraged to use your Server SDK of choice to create a new JWT with the [Sample JWT Payload](#sample-jwt-payload). [JWT.io](https://jwt.io/#libraries-io) has a selection of libraries for generating JWTs in multiple languages.
