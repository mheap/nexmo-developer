## Generate a JWT

> **TIP:** You only need to do this step if you are testing with Curl, as the client libraries generate JWTs as needed for you.

Once you have created a Vonage API Application you can use the Application ID and the private key file, `private.key`, to generate a JWT.

> **TIP:** If you are using the [Server SDK](/messages/code-snippets/server-sdk) for Node (or other languages when supported), the dynamic creation of JWTs is done for you.

If you're using the Vonage CLI, the command to create the JWT is:

``` shell
JWT="$(vonage jwt --key_file=private.key --app_id=APPLICATION_ID)"
```

You can then view the JWT with:

``` shell
echo $JWT
```

Alternatively, you can use our [JWT web app](/jwt) to generate a JWT.

> **TIP:** You can test your generated JWT at [jwt.io](https://jwt.io)
