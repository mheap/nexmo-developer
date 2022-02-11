---
title: A Strawberry Or Not? Classify an Image with MLKit for Android
description: Find out how to build an in app image classification system by
  combining Google's MLKit and Firebase.
thumbnail: /content/blog/a-strawberry-or-not-classify-an-image-with-mlkit-for-android-dr/Whos-afraid-V2-1.001.jpeg
author: brittbarak
published: true
published_at: 2018-09-25T11:00:52.000Z
updated_at: 2021-05-04T13:52:56.907Z
category: tutorial
tags:
  - android
  - firebase
comments: true
redirect: ""
canonical: ""
---
Not too long ago, machine learning (ML) used to sound like a magic ?. Details on what, and how, it should be used were quite vague for many of us for some time.

That was then. Fast forward to now, and one of the most exciting announcements of [Google I/O 2018](https://events.google.com/io/), for me, was [MLKit](https://firebase.google.com/products/ml-kit/). Briefly, MLKit takes some common ML use cases, and wraps them up with a nice API.

In addition to this, if your app handles a specific use case, MLKit allows you to create and use custom models, along with useful version management features.

One of the out-of-the-box use cases is _image labelling_, also known as _image classification_. This means taking an image and detecting the entities it contains, such as: animals, fruits, activities and so on. Each image input will get an output of a list of entities (labels) with a score that represents the level of confidence that this entity is indeed present in the image. These labels can be used in order to perform actions such as content moderation, filtering or search.

Also, because mobile devices have limited resources and minimizing data consumption is often a blessing, working with metadata rather than an entire photo can help with matters of performance, privacy, bandwidth, offline support and more. For example, on a chat app, being able to send only labels and not an entire photo, can benefit a lot.

This tutorial will guide you through writing a mobile app that can take an image and detect the entities it contains. It has 3 parts:

- [Overview and what you will do](#what-you-will-do)

- [Running MLKit on device model](#running-a-local-on-device-model)

- [Running MLKit cloud base detectors](#running-a-cloud-based-model)

Hands down, my favourite food in the world is strawberries ?! I can eat them everyday, all day, and it would make me so happy!

Let’s create an app that will take an image, and then detect if in contains a strawberry or not!

### The app you will create:
***

The user selects an image, and a button to choose how to classify it.

The UI passes the image ([`Bitmap`](https://developer.android.com/reference/android/graphics/Bitmap) object) to `ImageClassifier` class, which will send the image to a specific Classifier that was selected (`LocalClassifier`, `CloudClassifier` or `CustomClassifier`. This tutorial will only cover the first two). Each Classifier will process the input, run the model, process the output if needed, and then send the result to `ImageClassifier` that will prepare it to make it as easy as possible for the UI to display.

***
### Before getting started:

1. Clone this project with code to get started, and the implementation per step [https://github.com/brittBarak/MLKitDemo](https://github.com/brittBarak/MLKitDemo)

2. Add Firebase to your app:

- Log into Firebase console : [https://console.firebase.google.com](https://console.firebase.google.com/)

- Create a new project, or select an existing one

- On the left hand side menu go to settings →
***
- Under General tab → under Your Apps section, choose 'add app'.
***
- Follow the steps in the Firebase tutorial, to add Firebase to your app.
***

3. Add `firebase-ml-vision` library to your app: on your app-level `build.gradle` file add:

```groovy
dependencies {
// …
implementation ‘com.google.firebase:firebase-ml-vision:17.0.0’
}
```

As mentioned, this tutorial will cover running both local and cloud based detectors. Each has 4 steps:

1. Setting up (it’s not cheating :) doesn’t really count as a step…)
2. Setup the Classifier
3. Process the input
4. Process the output

**Note**: If you prefer to follow long with the final code, you can find it on branch [1.run_local_model](https://github.com/brittBarak/MLKitDemo/tree/1.run_local_model) of the demo's [repo](https://github.com/brittBarak/MLKitDemo).

## Running a local (on-device) model

Choosing a local model is the lightweight, offline supported option, and it's free. In return, it has 400+ labels so the accuracy is limited, which we must take into account.

The UI takes the bitmap → calls `ImageClassifier.executeLocal(bitmap)`→ `ImageClassifier` calls `LocalClassifier.execute()`

If you prefer to follow along with the final code, get it on branch [1.run_local_model](https://github.com/brittBarak/MLKitDemo/tree/1.run_local_model).

### Step 0: Setting up

1. Adding to your app the local detector, facilitated by Firebase MLKit:

On your app-level `build.gradle` file add:

```groovy
dependencies {
  // ...
  implementation 'com.google.firebase:firebase-ml-vision-image-label-model:15.0.0'
}
```

**Optional, but recommended**: by default, the ML model itself will be downloaded only once you execute the detector. It means that there will be some latency at the first execution, as well as network access required. To bypass that, and have the ML model downloaded as the app is installed from Play Store, simply add the following declaration to your app's AndroidManifest.xml file:

```xml

...

<!-- To use multiple models: android:value="label,barcode,face..." -->

```

### Step 1: Setup the Classifier

Create `LocalClassifier` class that holds the detector object:

```java
public class LocalClassifier {
  detector = FirebaseVision.getInstance().getVisionLabelDetector();
}
```

This is the basic detector instance. You can be more picky about the output returned, and add *Confidence Threshold*, which is between 0–1, with 0.5 as a default.

```java
class LocalClassifier {
  //...

  FirebaseVisionImage image;
  public void execute(Bitmap bitmap) {
    image = FirebaseVisionImage.fromBitmap(bitmap);
  }
}
```

### Step 2: Process The Input

`FirebaseVisionLabelDetector` knows how to work with an input of type `FirebaseVisionImage`. You can obtain a `FirebaseVisionImage` instance from either:

`Bitmap` (this is what we'll use here) , `Image Uri`, [`MediaImage`](https://developer.android.com/reference/android/media/Image.html) (from media, for example the device camera), `ByteArray`, or `ByteBuffer`.

Processing a `Bitmap` is done like this:

```java
public class LocalClassifier {
  //...

  public void execute(Bitmap bitmap, OnSuccessListener successListener, OnFailureListener failureListener) {
    //...
    detector.detectInImage(image)
      .addOnSuccessListener(successListener)
      .addOnFailureListener(failureListener);
  }
}
```

**Tip**: One of the reasons we'd want to use a local model is because the execution is quicker, however, executing any model takes some time. If you use the model on a real-time application, you might need the results even faster. Reducing the bitmap size before moving to the next step, can improve the model's processing time.

### Step 3: Run The Model

This is where the magic happens! ? Since the model does take some computation time, we should have the model run asynchronously and return the success or failure result using listeners.

```java
public class LocalClassifier {
  //...

  public void execute(Bitmap bitmap, OnSuccessListener successListener, OnFailureListener failureListener) {
    //...
    detector.detectInImage(image)
      .addOnSuccessListener(successListener)
      .addOnFailureListener(failureListener);
  }
}
```

### Step 4: Process The Output

The detection output is provided on `OnSuccessListener`. I prefer to have the `OnSuccessListener` passed to `LocalClassifier` from `ImageClassifier`, that handles the communication between the UI and `LocalClassifier`.

The UI calls `ImageClassifier.executeLocal()` , which should look something like that:

On `ImageClassifier.java`:

```java
localClassifier = new LocalClassifier();

public void executeLocal(Bitmap bitmap, ClassifierCallback callback) {
  successListener = new OnSuccessListener<List>() {

  public void onSuccess(List labels) {
    processLocalResult(labels, callback, start);
  }
};

localClassifier.execute(bitmap, successListener, failureListener);

```

`processLocalResult()` just prepares the output labels to display in the UI.

In my specific case, I chose to display the 3 results with highest probability. You may choose any other format type. To complete the picture, this is my implementation:

`OnImageClassifier.java`:

```java
void processLocalResult(List labels, ClassifierCallback callback) {
  labels.sort(localLabelComparator);
  resultLabels.clear();
  FirebaseVisionLabel label;
  for (int i = 0; i < Math.min(3, labels.size()); ++i) {
    label = labels.get(i);
    resultLabels.add(label.getLabel() + “:” + label.getConfidence());
  }
  callback.onClassified(“Local Model”, resultLabels);
}
```

`ClassifierCallback` is a simple interface I created, in order to communicate the results back to the UI display. We could have also used any other other methods available to do this. It's a matter of preference.

```java
interface ClassifierCallback {
  void onClassified(String modelTitle, List topLabels);
}
```

***

### That’s it!

You used your first ML model to classify an image! ? How simple was that?!

Let's run the app and see some results!
Get the final code for this part on this demo’s [repo](https://github.com/brittBarak/MLKitDemo) , on branch [1.run_local_model](https://github.com/brittBarak/MLKitDemo/tree/1.run_local_model)

***

Pretty good! We got some general labels like 'food' or 'fruit', that definitely fit the image. For some apps use cases this model fits perfectly fine. It can help group images, perform a search and so on. But for our case, we expect a model that can specify which fruit is in the photo.

Let’s try to get some more indicative and accurate labels, by using the cloud based detector, which has 10,000|+ labels available:

## Running a cloud based model

### Step 0: Setting up

MLKit's Cloud based models belong to the _Cloud Vision API_, which you have to make sure is enabled for your project:

1. Using a cloud-based model requires payment over a quota of 1000+ monthly uses. For demo and development purposes, it’s not likely that you’ll get near that quota. However, you must upgrade your Firebase project plan, so that theoretically it can be charged if needed. Upgrade your _Spark_ plan project, which is free, to a _Blaze_ plan, which is pay as you go, and enables you to use the Cloud Vision APIs. You can do so in the [Firebase console](https://console.firebase.google.com/).

2. Enable the Cloud Vision API, on the [Cloud Console API library](https://console.cloud.google.com/apis/library/vision.googleapis.com/). On the top menu, select your Firebase project, and if not already enabled, click Enable.

***

**Note**: For development, this configuration will do. However, prior to deploying to production, you should take some extra steps to ensure that no unauthorised calls are being made with your account. For that case, check out the instructions [here](https://firebase.google.com/docs/ml-kit/android/secure-api-key).

### Step 1: Setup The Classifier

Create a `CloudClassifier` class that holds the detector object:

```java
public class CloudClassifier {
  detector = FirebaseVision.getInstance().getVisionCloudLabelDetector();
}
```

This is almost the same as the above `LocalClassifier`, except the type of the detector.

There are a few extra options we can set on the detector:

- `setMaxResults()` — by default 10 results will return. If you need more than that, you'd have to specify it. On the other end, when designing the demo app I decided to only present the top 3 results. I can define it here and make the computation a little faster.

- `setModelType()` — can be either [STABLE_MODEL](https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/cloud/FirebaseVisionCloudDetectorOptions.html#STABLE_MODEL) or [LATEST_MODEL](https://firebase.google.com/docs/reference/android/com/google/firebase/ml/vision/cloud/FirebaseVisionCloudDetectorOptions.html#LATEST_MODEL), the latter is default.

```java
public class CloudClassifier {
  options = new FirebaseVisionCloudDetectorOptions.Builder()
  .setModelType(FirebaseVisionCloudDetectorOptions.LATEST_MODEL)
  .setMaxResults(ImageClassifier.RESULTS_TO_SHOW)
  .build();

  detector = FirebaseVision.getInstance().getVisionCloudLabelDetector(options);
}
```

### Step 2: Process The Input

Similarly to `LocalDetector`, `FirebaseVisionCloudLabelDetector` uses an input of `FirebaseVisionImage`, which we will obtain it from a `Bitmap`, to facilitate the UI;

```java
public class CloudClassifier {
  //...
  FirebaseVisionImage image;
  public void execute(Bitmap bitmap) {
    image = FirebaseVisionImage.fromBitmap(bitmap);
  }
}
```

### Step 3: Run The Model

As the previous steps, this step is incredibly similar the what we did to run the local model:

```java
public class CloudClassifier {
  public void execute(Bitmap bitmap, OnSuccessListener successListener, OnFailureListener failureListener) {
  //...
  detector.detectInImage(image)
    .addOnSuccessListener(successListener)
    .addOnFailureListener(failureListener);
  }
}
```

### Step 4: Process The Output

As the local model is different than the cloud based model, their outputs will be different, so that the object type we get as the response on `OnSuccessListener` is different per detector. Yet, the objects are quite the same to work with.

On `ImageClassifier.java`:

```java
cloudClassifier = new CloudClassifier();

public void executeCloud(Bitmap bitmap, ClassifierCallback callback) {
  successListener = new OnSuccessListener<List>() {

    public void onSuccess(List labels) {
      processCloudResult(labels, callback, start);
    }
  };
  cloudClassifier.execute(bitmap, successListener, failureListener);
}
```

Once again, processing the results for the UI to present is down to your own decision on what the UI presents. For this example:

```java
processCloudResult(List labels, ClassifierCallback callback) {
  labels.sort(cloudLabelComparator);
  resultLabels.clear();
  FirebaseVisionCloudLabel label;
  for (int i = 0; i < Math.min(RESULTS_TO_SHOW, labels.size()); ++i) {
    label = labels.get(i);
    resultLabels.add(label.getLabel() + ":" + label.getConfidence());
  }
  callback.onClassified("Cloud Model", resultLabels);
}
```

### That’s pretty much it! ?

Let's see some results:
The code for this post can be found on the repo, on branch [2.run_cloud_model](https://github.com/brittBarak/MLKitDemo/tree/2.run_cloud_model)

***

As expected, the model took a little longer, but can now tell which specific fruit is in the image. Also, it is more than 90% confident of the result, comparing to 70–80% confidence for the local model.

***

I hope this helps you to understand how simple and fun it is to use Firebase MLKit. Using the other models: face detection, barcode scanning, etc.. works in a very similar way and I encourage you to try it out!

Can we get even better results? We’ll explore that using a custom model as well, on an upcoming post.

### What’s Next?

If you want to learn more about what machine learning is and how does it work, check out these developer friendly intro blog posts: [bit.ly/brittML-1](http://bit.ly/brittML-1), [bit.ly/brittML-2](http://bit.ly/brittML-2), [bit.ly/brittML-3](http://bit.ly/brittML-3)

For more information on why to use MLKit see [this post](http://bit.ly/brittML-4) and the [official documentation](https://firebase.google.com/products/ml-kit/)