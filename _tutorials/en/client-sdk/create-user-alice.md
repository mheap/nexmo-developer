---
title: Create a User
description: In this step you learn how to create a Client SDK User.
---

# Create a User

[Users](/conversation/concepts/user) are a key concept when working with the Vonage Client SDKs. When a user authenticates with the Client SDK, the credentials provided identify them as a specific user. Each authenticated user will typically correspond to a single user in your users database.

To create a user named `Alice`, run the following command using the Vonage CLI:

```bash
vonage apps:users:create "Alice"
```

This will return a user ID similar to the following:

```bash
User ID: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```
