---
title: Add Two-Factor Authentication to Android Apps with Nexmo’s Verify API
description: This two-factor authentication (2FA) tutorial explains how to set
  up an Android app to network with a server configured to use Nexmo Verify.
  You'll learn how to implement all of the endpoints necessary to follow a
  verification flow.
thumbnail: /content/blog/add-two-factor-authentication-to-android-apps-with-nexmos-verify-api-dr/nexmo-2fa_android.jpg
author: chrisguzman
published: true
published_at: 2018-05-10T16:08:22.000Z
updated_at: 2021-05-12T20:43:43.709Z
category: tutorial
tags:
  - 2fa
  - android
  - verify-api
comments: true
redirect: ""
canonical: ""
---
[Two-factor authentication](https://www.nexmo.com/blog/2014/11/11/why-two-factor-authentication-2fa/) (2FA) adds an extra layer of security for users that are accessing sensitive information. In this tutorial, we will cover how to implement two-factor authentication for a user's phone number with Nexmo's Verify API endpoints.

After reading the blog post about [how to set up a server to use Nexmo Verify](https://www.nexmo.com/blog/2018/05/10/nexmo-verify-api-implementation-guide-dr) you're now ready to set up an Android app to network with the server.

## Prequisites

<sign-up></sign-up>

This app will have only two dependencies: [Retrofit](http://square.github.io/retrofit/) for making network calls and [Moshi](https://github.com/square/moshi) for serializing and deserializing JSON.

The app will need to do a few things. Store a `requestId` so that a verification request can be canceled or completed. As well as make a network call to three endpoints: 

* Start a verification
* Check a verification code
* Cancel a verification request

To get started, I've set up a [simple demo app](https://github.com/nexmo-community/verify-android-example) with a login screen asking for the user's email address, password, and phone number for [two-factor authentication](https://developer.nexmo.com/tutorials/two-factor-authentication) (2FA). Clone the following repo and navigate to the getting started branch:

```
git clone git@github.com:nexmo-community/verify-android-example.git
cd verify-android-example
git checkout getting-started
```

## Integrating with Proxy Server

In the blog post about how to set up a proxy server for the Verify API, we covered three endpoints:

* Make a verification request.
* Check a verification code.
* Cancel a verification request.

So we're going to need to have our app send `POST`s to those three endpoints. To do this we're going to use Retrofit and Moshi.

## Making Network Requests

The build.gradle file should include the following dependencies. Retrofit for networking, Moshi for JSON parsing, and OkHttp for logging.

```groovy
//app/build.gradle
implementation 'com.squareup.retrofit2:retrofit:2.4.0'
implementation 'com.squareup.retrofit2:converter-moshi:2.4.0'
implementation 'com.squareup.okhttp3:logging-interceptor:3.10.0'
```

We can start using them to network with our proxy API.

First, we'll set up an interface for the three endpoints our app needs to hit:

```java
public interface VerifyService {

    @POST("request")
    Call<VerifyResponse> request(@Body PhoneNumber phoneNumber);

    @POST("check")
    Call<CheckVerifyResponse> check(@Body VerifyRequest verifyRequest);

    @POST("cancel")
    Call<CancelVerifyResponse> cancel(@Body RequestId requestId);
}
```

I won't go over each of the models for the responses, but you can <a href="https://github.com/nexmo-community/verify-android-example/tree/finished/app/src/main/java/com/nexmo/twofactorauth/models" rel="noopener" target="_blank">view them in more detail here</a>. For the purpose of this tutorial I've matched the structure of the models to the JSON that [Verify API expects](https://developer.nexmo.com/api/verify).

Now that there is an interface of endpoints, we can write a `VerifyUtil` that will instantiate Retrofit and make the network requests:

```java
public class VerifyUtil {

    private final Retrofit retrofit;
    private VerifyService verifyService;
    private static VerifyUtil instance = null;

    private VerifyUtil() {
        //Use OkHttp for logging
        HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
        interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
        OkHttpClient client = new OkHttpClient.Builder().addInterceptor(interceptor).build();

        retrofit = new Retrofit.Builder()
                .client(client)
                //change this url to your own proxy API url
                .baseUrl("https://nexmo-verify.glitch.me")
                .addConverterFactory(MoshiConverterFactory.create())
                .build();

        verifyService = retrofit.create(VerifyService.class);
    }

    public static VerifyUtil getInstance() {
        if (instance == null) {
            instance = new VerifyUtil();
        }
        return instance;
    }

    public VerifyService getVerifyService() {
        return verifyService;
    }

    public Retrofit getRetrofit() {
        return retrofit;
    }
}
```

I've made `VerifyUtil` a singleton that can be called from any Activity. 

Let's start by making some changes to our LoginActivity. The `signInBtn` already has an OnClickListener that calls `start2FA()` so we can add to that method.

## Login Activity

```java
private void start2FA(final String phone) {
    //clear out the previous error (if any) that was shown.
    errorTxt.setText(null);
    //start the verification request. Wrap `String phone` in a `PhoneNumber` class so it is correctly serialized into JSON
    Call<VerifyResponse> request = VerifyUtil.getInstance().getVerifyService().request(new PhoneNumber(phone));
    request.enqueue(new Callback<VerifyResponse>() {
        @Override
        public void onResponse(Call<VerifyResponse> call, Response<VerifyResponse> response) {
            if (response.isSuccessful()) {
                //parse the response
                VerifyResponse requestVerifyResponse = response.body();
                storeResponse(phone, requestVerifyResponse);
                startActivity(new Intent(LoginActivity.this, PhoneNumberConfirmActivity.class));
            } else {
                //if the HTTP response is 4XX, Retrofit doesn't pass the response to the `response.body();`
                //So we need to convert the `response.errorBody()` to the `VerifyResponse`
                Converter<ResponseBody, VerifyResponse> errorConverter = VerifyUtil.getInstance().getRetrofit().responseBodyConverter(VerifyResponse.class, new Annotation[0]);
                try {
                    VerifyResponse verifyResponse = errorConverter.convert(response.errorBody());
                    Toast.makeText(LoginActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
                    errorTxt.setText(verifyResponse.getErrorText());
                } catch (IOException e) {
                    Log.e(TAG, "onResponse: ", e);
                }
            }
        }

        @Override
        public void onFailure(Call<VerifyResponse> call, Throwable t) {
            Toast.makeText(LoginActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
            Log.e(TAG, "onFailure: ", t);
        }
    });
}
```

Whenever someone clicks on the "Sign In" button, the app will send the phone number to the proxy API we've set up in the earlier blog. This app will ignore anything in the email or password screens since this app is a proof of concept.

If there is an error with the request, the proxy API will send a `400` response and we'll handle it in the `else` block of the `onResponse()` callback. If there's any other error, the proxy server will respond with a `500` and the app can handle the error in the `onFailure()` callback.

If the request is successful, the app will store the phone number the user sent and the `responseId` the proxy server returned, then the app will start the `PhoneNumberConfirmActivity` so that the user can enter their code. It's important to store the phone number and request ID because those fields are needed to cancel or check the status of any verification request. And while a user may remember their phone number to cancel or check the status of a verification, they can't be expected to remember a multi-character, randomly generated request ID string. So when the app makes a verification request, we'll store the `requestId` in `SharedPreferences` to retrieve later in case the user backgrounds the app or the activity is restarted.

## PhoneNumberConfirmActivity

Once a user enters the phone number and the server responds with a `200`, the app will start the PhoneNumberConfirmActivity. I've already started the [activity on the `getting-started` branch](https://github.com/nexmo-community/verify-android-example/blob/getting-started/app/src/main/java/com/nexmo/twofactorauth/PhoneNumberConfirmActivity.java)

The basic structure of the activity is already built. All that's left is to use the `requestId` and phone number to confirm the PIN code or cancel the verification.

First, we'll start with fetching the phone number and requestId from `SharedPreferences`. We'll need the phone number and `requestId` to confirm the verification code or cancel the verification process.

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_phone_number_confirm);

    //Get user's phone number and request ID from SharedPreferences
    SharedPreferences sharedPref = getSharedPreferences(TWO_FACTOR_AUTH, Context.MODE_PRIVATE);
    String phoneNumber = sharedPref.getString(PHONE_NUMBER, null);
    Log.d(TAG, "phone: " + phoneNumber);
    requestId = sharedPref.getString(phoneNumber, null);
    Log.d(TAG, "request id: " + requestId);

    //Set up rest of views on OnClickListeners...
}
```

Then once the user clicks on the "Confirm" button, the app needs to send the PIN code and the `requestId` to the proxy API. We can wire up the "Confirm" button's `OnClickListener` to kick off that request.

```java
private void confirmCode(String code) {
    //clear out the previous error (if any) that was shown.
    verifyTxt.setText(null);
    //Confirm the verification code. Wrap `String code` and requestId in a `VerifyRequest` class so it is correctly serialized into JSON
    VerifyUtil.getInstance().getVerifyService().check(new VerifyRequest(code, requestId)).enqueue(new Callback<CheckVerifyResponse>() {
        @Override
        public void onResponse(Call<CheckVerifyResponse> call, Response<CheckVerifyResponse> response) {
            if (response.isSuccessful()) {
                verifyTxt.setText("Verified!");
                Toast.makeText(PhoneNumberConfirmActivity.this, "Verified!", Toast.LENGTH_LONG).show();
            } else {
                //if the HTTP response is 4XX, Retrofit doesn't pass the response to the `response.body();`
                //So we need to convert the `response.errorBody()` to a `CheckVerifyResponse`
                Converter<ResponseBody, CheckVerifyResponse> errorConverter = VerifyUtil.getInstance().getRetrofit().responseBodyConverter(CheckVerifyResponse.class, new Annotation[0]);
                try {
                    CheckVerifyResponse checkVerifyResponse = errorConverter.convert(response.errorBody());
                    verifyTxt.setText(checkVerifyResponse.getErrorText());
                    Toast.makeText(PhoneNumberConfirmActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
                } catch (IOException e) {
                    Log.e(TAG, "onResponse: ", e);
                }
            }
        }

        @Override
        public void onFailure(Call<CheckVerifyResponse> call, Throwable t) {
          Toast.makeText(PhoneNumberConfirmActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
          Log.e(TAG, "onFailure: ", t);
        }
  });
}
```

The network request to confirm the PIN code is similar to the request made earlier to start the verification process. If all goes well the server will respond with a `200` OK and we can let the user know they are authenticated. If the server responds with a `400` or `500` then we can check the `errorText` of the response and alert the user of the issue either with a toast or by displaying the error in the `verifyTxt` `TextView` I've created.

There may be times when users want to cancel a verification request. This may be because they entered the wrong phone number, want to log in with another account, or just don't want to verify themselves at this time. The app needs to handle this scenario so we can add a "Cancel" button to our activity and wire it up to send a cancellation network request. I've already added the "Cancel" button and added an `OnClickListener` with a callback of `cancelRequest()`, now we can just add the networking code to that method.

```java
private void cancelRequest() {
    //clear out the previous error (if any) that was shown.
    verifyTxt.setText(null);
    //Cancel the verification request
    VerifyUtil.getInstance().getVerifyService().cancel(new RequestId(requestId)).enqueue(new Callback<CancelVerifyResponse>() {
        @Override
        public void onResponse(Call<CancelVerifyResponse> call, Response<CancelVerifyResponse> response) {
            if (response.isSuccessful()) {
                Toast.makeText(PhoneNumberConfirmActivity.this, "Cancelled!", Toast.LENGTH_LONG).show();
                finish();
            } else {
                //if the HTTP response is 4XX, Retrofit doesn't pass the response to the `response.body();`
                //So we need to convert the `response.errorBody()` to a `CancelVerifyResponse`
                Converter<ResponseBody, CancelVerifyResponse> errorConverter = VerifyUtil.getInstance().getRetrofit().responseBodyConverter(CancelVerifyResponse.class, new Annotation[0]);
                try {
                    CancelVerifyResponse cancelVerifyResponse = errorConverter.convert(response.errorBody());
                    verifyTxt.setText(cancelVerifyResponse.getErrorText());
                    Toast.makeText(PhoneNumberConfirmActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
                } catch (IOException e) {
                    Log.e(TAG, "onResponse: ", e);
                }
            }
        }

        @Override
        public void onFailure(Call<CancelVerifyResponse> call, Throwable t) {
            Toast.makeText(PhoneNumberConfirmActivity.this, "Error Will Robinson!", Toast.LENGTH_LONG).show();
            Log.e(TAG, "onFailure: ", t);
        }
    });
}
```

## Wrapping It Up

Now we've implemented all of the endpoints necessary to follow a verification flow. If you'd like to see the finished product of this Android app, [the source code is on the `finished` branch on GitHub.](https://github.com/nexmo-community/verify-android-example)

## Next Steps

If you'd like you can implement the rest of the endpoints in the Verify API. Note that this will require you to add more endpoints in the API proxy server.
You can also add additional endpoints to cover the Number Insights API. This will also require you to add more endpoints in the API proxy server.
There's also an iOS version of this post. [Read more from our developer advocate Eric Giannini.](https://www.nexmo.com/blog/2018/05/10/add-two-factor-authentication-to-swift-ios-apps-dr)

## Risks/Disclaimer

You may want to inspect the SSL certificate of the responses from your proxy API to ensure the client app isn't subject to a MITM attack. For more details, [visit the Android developer docs](https://developer.android.com/training/articles/security-ssl).