---
title: Build a Secure Facial ID Application Using the Vonage Video API
description: In this tutorial, you will learn to build a secure facial ID app
  using the Vonage Video API and personalize the attributes into custom solution
  builds.
thumbnail: /content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/Blog_Facial-ID-Application_1200x600-1.png
author: akshita-arun
published: true
published_at: 2020-10-21T16:39:50.000Z
updated_at: 2021-05-10T20:47:52.618Z
category: tutorial
tags:
  - facial-id
  - video-api
comments: true
redirect: ""
canonical: ""
---
In the current global pandemic, many industry verticals have maximized digital adoption to scale productivity and bring effective implementation techniques to serve widespread use cases for their client base. Facial ID has become more prevalent evidencing widespread proliferation of this technology in industry verticals such as:

1. Hospitality (Airlines and hotel management)

* Payment process at hotel check-ins on mobile phone or camera supplied by their vendors
* Flight check-ins and boarding process



2. Telemedicine

* Patient identification where emergency services are needed to help minimize manual paperwork
* Hospital management services, by screening face of doctors, patients and nurse practitioners to avoid miscommunication and provide consistent information to be passed on



3. Customer Service

* User identification
* Fraud prevention



4. Voter registration

* Handle voter fraud



In all the use cases mentioned above, facial ID can be enabled using the [Vonage Video API](https://tokbox.com/account/user/signup) that will drive contactless services while also protecting your user data and personal information while helping you deliver secure and safe custom solutions.

In this blog post, we will walk you through our Video API using Facial ID. It will only take a few methods and functions for your developers to understand the workflow, including subscribe, detect, identify and match facial ID by personalizing these attributes into their custom solution builds. Our goal is to reduce development time by kicking off with a good head start using our sample code base that is ready to use for facial ID using our [opentok platform](https://gist.github.com/rktalusani/3b0bb3c61bc6d5b6020612f189e644fe). 

## Abstract

To build a complete facial ID application using our Video API, we use methods and objects as mentioned in our sample code snippet, you can find more information on our [opentok reference code](https://gist.github.com/rktalusani/3b0bb3c61bc6d5b6020612f189e644fe) integrated with Microsoft face API.

## Technologies and Prerequisites

* Opentok JS API
* Microsoft face API
* [Vonage Video API Account](https://tokbox.com/account/#/)

## Uploading Screenshot of Subscriber Image To the Server

In the appropriate use case mentioned, the customer provides their photograph during the sign up process, which is then stored in the backend. When the customer has joined the video call, we can use the Vonage Video API to grab a screenshot of the customer’s video stream and upload it to the server for face detection.

In the code below, we have used `subscriber.getImgData()` to get a screen of the video stream and upload it to the backend.

```js
function sendScreenShot() {
    var imgdata = undefined;
    if (subscriber) {
        imgdata = subscriber.getImgData();
    }
    if (imgdata != undefined) {
        try {
            var blob = this.b64toBlob(imgdata, "image/png");
            let formData = new FormData();
            formData.append('customer', blob);
            let res = await $HTTPDEMO.post('/faceIDDemo.php',
                formData, {
                    headers: {
                        'Content-Type': 'multipart/form-data'
                    }

                }
            );
            console.log(res.data);
            if (res.data.status != "success") {
                alert("Error uploading the file");
            } else {

            }
        } catch (error) {
            alert("error posting screenshot");
            console.log(error);
        }
    }
}
```

![step 1](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/step-1-upload-an-image.png "step 1")

b64toBlob is a helper method called by sendScreenShot function that converts base64 string into a byte array so we can post it as multipart/form-data to the server.

```js
function b64toBlob(b64Data, contentType, sliceSize) {
    contentType = contentType || '';
    sliceSize = sliceSize || 512;
    var byteCharacters = atob(b64Data);
    var byteArrays = [];
    for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }
    var blob = new Blob(byteArrays, {
        type: contentType
    });
    return blob;
}
```

## Identifying FaceID Using Microsoft API To Compare Matched Face ID Results

![Identifying FaceID Using Microsoft API To Compare Matched Face ID Results ](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/identify.png "Identifying FaceID Using Microsoft API To Compare Matched Face ID Results ")

## Detecting FaceID in Opentok

detectFace method runs on the server side. It detects the facial features from a given image and returns an identifier. We call this method twice: first when the image of the customer has uploaded at the time of sign-up (id1) and then with the screenshot from the video stream (id2).

Below is the sample code snippet:

```js
function detectFace($img){
        global $faceid_endpoint, $data_dir_url,$faceid_key;

        $client = new GuzzleHttp\Client([
            'base_uri' => $faceid_endpoint
        ]);

        $resp = $client->request('POST', 'face/v1.0/detect?recognitionModel=recognition_02&detectionModel=detection_02', [
            'headers' => [
                'Content-Type' => 'application/json',
                'Ocp-Apim-Subscription-Key' => $faceid_key
            ],
            'json' => ['url'=> $data_dir_url.$img]
        ]);

        $json = json_decode($resp->getBody(),true);
       
        return $json[0];
}
```

![Detecting FaceID in Opentok](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/3.png "Detecting FaceID in Opentok")

## Verifying FaceID in OpenTok

For the last piece of verification, we use the verifyFace() method and pass image IDs id1 and id2 as the inputs. Here, Microsoft face API compares these two faces(id1 & id2), compares the snapshot with the photograph submitted during the sign up process, and provides a result that includes match/mismatch and a score.

```js
function verifyFace($id1,$id2){
        global $faceid_endpoint, $data_dir_url,$faceid_key;
        $client = new GuzzleHttp\Client([
            'base_uri' => $faceid_endpoint
        ]);

        $resp = $client->request('POST', 'face/v1.0/verify', [
            'headers' => [
                'Content-Type' => 'application/json',
                'Ocp-Apim-Subscription-Key' => $faceid_key
            ],
            'json' => [
                'faceid1'=>$id1,
                'faceid2'=>$id2
            ]
        ]);

        return $resp->getBody();
}
```

![Verifying FaceID in OpenTok](/content/blog/build-a-secure-facial-id-application-using-the-vonage-video-api/4.png "Verifying FaceID in OpenTok")

### Background

The customer solutions team at Vonage API's primary objective is to enable our developers to cross barriers of innovation by extending development, integration, and support services. We work with our global leaders who share a common goal to achieve sustainable business aiming to become profitable customer-centric enterprises by accelerating your global growth rate.

Part of our accelerated service offering is to minimize your development timeline by providing guided implementation, deployment and best-guided adoption that will help optimize, scale your application and get into the market sooner.

## Conclusion

At Vonage, we focus on our core values by placing the customer interest first. With our constant efforts in relentless innovation, we are committed to serving our developer community with the latest and greatest features—enabling you to customize your application to best suit your use case scenarios.

We consistently see an increased spike in our video usage and with our incremental demand for Video, we are more focused on deploying qualified resources to better help and serve you to achieve successful integrations with our partners and us. It is simple to get started with the Vonage Video API, so [sign up for your free account](https://www.vonage.com/log-in/?icmp=utilitynav_login_novalue) and take full advantage of our offering today!

We would love to hear your feedback on features, developer docs and blog post content. Please leave a comment below, reach out to us on [Twitter](https://twitter.com/VonageDev) or join our [Community Slack Channel](https://developer.nexmo.com/community/slack).