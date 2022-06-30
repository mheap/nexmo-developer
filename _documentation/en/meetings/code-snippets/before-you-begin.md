---
title: Before you begin
navigation_weight: 0
---

# Before you begin

## What are Code Snippets?

Code snippets are short pieces of code you can reuse in your own applications.
The code snippets utilize code from the [Vonage Curl Code Snippets](https://github.com/Nexmo/nexmo-curl-code-snippets) repository.

Please read this information carefully, so you can best use the code snippets.

## Prerequisites

**Vonage Developer Account**: If you don’t have a Vonage account yet, you can get one here: [Vonage Developers Account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav).

**Meetings API Activation**: To activate the Meetings API, you need to register with us. Please send an email request, with your API key from the [Vonage API Dashboard](https://dashboard.nexmo.com), to the [Meetings API Team](mailto:meetings-api@vonage.com).

**Application ID and Private Key**: Once you’re logged in to the [Vonage API Dashboard](https://dashboard.nexmo.com), click on Applications and create a new Application. Generate a public and private key and record the private key.

**JSON Web Token (JWT)**: Use the [JWT Generator](https://developer.vonage.com/jwt) to create a JWT using the Application ID and Private Token mentioned above. For further details about JWTs, please see [Vonage Authentication](/concepts/guides/authentication).

## Replaceable variables

### Generic replaceable

The following replaceable information depends on the library and specific call:

```snippet_variables
- VONAGE_API_KEY
- VONAGE_API_SECRET
- VONAGE_APPLICATION_PRIVATE_KEY_PATH
- VONAGE_APPLICATION_PRIVATE_KEY
- VONAGE_APPLICATION_ID
```

### Numbers

All phone numbers are in E.164 format.

```snippet_variables
- VONAGE_NUMBER
- TO_NUMBER.VOICE
- SECOND_NUMBER.VOICE
```
