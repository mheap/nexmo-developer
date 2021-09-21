---
title: Generate JWTs
description: In this step you learn how to generate valid JWTs for each User in your In-App Voice Call.
---

# Generate JWTs

You need to generate a JWT for each user. The JWT is used to authenticate the user. Run the following commands, remember to replace the `APPLICATION_ID` variable with id of your application and `PRIVATE_KEY` with the name of your private key file.

> **NOTE:** To quickly get your application id you can run the Vonage CLI command, `vonage apps`, to view a list of your applications.

For Alice:

``` shell
vonage jwt --app_id=APPLICATION_ID --subject=Alice --key_file=./PRIVATE_KEY --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

And for Bob:

``` shell
vonage jwt --app_id=APPLICATION_ID --subject=Bob --key_file=./PRIVATE_KEY --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

The above commands set the expiry of the JWT to one day from now, which is the maximum.

Make a note of the JWT you generated for each user:

![terminal screenshot of a generated sample JWT](/screenshots/tutorials/client-sdk/generated-jwt-key-vonage.png)

> **NOTE**: In a production environment, your application should expose an endpoint that generates a JWT for each client request.

## Further information

* [JWT guide](/concepts/guides/authentication#json-web-tokens-jwt)
