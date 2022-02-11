---
title: A Better Way of Creating Android Views with JetPackCompose
description: An introduction to JetPackCompose, a modern way of building Android Views
thumbnail: /content/blog/a-better-way-of-creating-android-views-with-jetpackcompose/andriod_jetpack-compose_1200x600.png
author: igor-wojda
published: true
published_at: 2021-06-15T09:19:33.607Z
updated_at: 2021-06-03T13:57:51.764Z
category: inspiration
tags:
  - JetPack
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## A Bit Of History

Users are interacting with mobile applications via various screens, usually composed of multiple Views. The way developers deal with these user interactions has changed a lot during the Android platform lifetime by using multiple patterns. In the early days, developers were using the Model-View-Controller pattern then the Model-View-Presenter pattern (or Model-View-Intent). Finally, we moved to the Model-View-ViewModel pattern recommended by Google. The “view manager” has evolved (Controller/Presenter/ViewModel), but the “View” part itself hasn’t changed that much. The most significant change was the usage of Fragment as building blocks for UI instead of Activities like in the early days.

Through all this time, we were primarily using XML to define layouts for the application views. Of course, we could define these views using code-only, but this approach has its downsides. Usually, applications may have few complex, dynamic views defined in code, but most application layouts are still defined in XML files nowadays.

In the meantime, Kotin language was introduced and had this cool feature that allowed to define views using custom Kotln DSL. This feature was an interesting concept, but it has never gained enough attention from the Android developer community. It had its issues, but the biggest ones were not supporting advanced use cases and lacked official support from Android Studio.

## Why JetPack Compose

Some time ago, Google decided to unify the way we develop Android applications. As a part of the [JetPack](https://jetpack.com/) suite, Google unified many aspects of Android application creation. From navigation, through database access to background jobs, and much more. In addition, Google has provided a solid foundation to help developers follow best practices and reduce boilerplate code. As a part of this family comes the [JetPack Compose](https://developer.android.com/jetpack/compose) – a new way of dealing with UI. JetPack Compose utilizes Kotlin and custom DSL language to configure screen layouts, define themes, manage view state and add UI animations. All of this is achieved via a declarative approach that is already widely spread in ReactNative, Flutter, and iOS apps.

## JetPack Compose In Practice

We have a little background, so now let’s take a quick look at how we can use JetPack Compose and what we can do with this toolkit. First of all, we have to use Android Studio Arctic Fox 2020.3.1 (or newer). Then we have to create a new Android project (Select a Project Template window, select Empty Compose Activity and click Next).

> Detailed instruction can below found [here](https://developer.android.com/jetpack/compose/setup).

Open `MainActivity` and notice that Activity extends [ComponentActivity](https://developer.android.com/reference/androidx/activity/ComponentActivity):

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // … view
    }
}
```

Instead of using XML files to define views, we will be defining views in the `setContent` lambda (custom method defined in Kotlin) that is a main building block for the JetPack Compose DSL:

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            // … view
        }
    }
}
```

Instead of using XML tags to define views, we will use the custom layouts and views provided by JetPack Compose - Column, Row, Box, etc.:

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            Column {
                Text("Alfred Sisley")
                Text("3 minutes ago")
              }
        }
    }

    @Preview
    @Composable
    fun SampleView() {
        
    }
}
```

The above code creates a single column with “two rows” (each row contains a single view with the Text). 

![A preview of outputting text on multiple lines in a single view](/content/blog/a-better-way-of-creating-android-views-with-jetpackcompose/preview1.png)

We will learn how to generate the preview in a while. 

Each component can define its view hierarchy to allow the straightforward creation of more complex views. Our view code can be extracted into Comosable "components" by creating a method annotated with Composable annotation:

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            SampleView()
        }
    }

    @Composable
    fun SampleView () {
        Column {
            Text("Apple Juice")
            Text("100 ml")
        }
    }
}
```

These methods (annotated with [Composable](https://developer.android.com/reference/kotlin/androidx/compose/runtime/Composable) annotation) are providing basic building blocks for the Applications UI. To be able to see the preview in the Android Studio we should annotate a method with the Preview annotation and build the app:

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            SampleView()
        }
    }

    @Preview
    @Composable
    fun SampleView () {
        Column {
            Text("Apple Juice")
            Text("100 ml")
        }
    }
}
```

![A preview of outputting text on multiple lines in a single view](/content/blog/a-better-way-of-creating-android-views-with-jetpackcompose/preview1.png)

We can also apply changes to the properties of individual items. Let’s change background colors for each line of the text:

```kotlin
@Preview
@Composable
fun SampleView() {
    Column {
        Box(
            Modifier.background(Color.Green)
        ) {
            Text("Apple Juice")
        }
        Box(
            Modifier.background(Color.Blue)
        ) {
            Text("100 ml")
        }
    }
}
```

![A preview of outputting text on multiple lines in a single view](/content/blog/a-better-way-of-creating-android-views-with-jetpackcompose/preview2.png)

We can also add parameters to these views to make juice name and volume dynamic:

```kotlin
@Composable
fun SampleView(name: String, volume: Int) {
    Column {
        Box(
            Modifier.background(Color.Green)
        ) {
            Text(name)
        }
        Box(
            Modifier.background(Color.Blue)
        ) {
            Text("$volume ml")
        }
    }
}
```

Unfortunately, we can’t preview parametrized views, so we have to create another view to enable the preview. Now `SampleViewPreview` is annotated with Preview annotation, and it uses previously defined `SampleView`:

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            SampleViewPreview()
        }
    }

    @Preview
    @Composable
    fun SampleViewPreview() {
        SampleView("Orange Juice", 50)
    }

    @Composable
    fun SampleView(name: String, volume: Int) {
        Column {
            Box(
                Modifier.background(Color.Green)
            ) {
                Text(name)
            }
            Box(
                Modifier.background(Color.Blue)
            ) {
                Text("$volume ml")
            }
        }
    }
}
```

JetPack Compose is all about composition, so we can easily use more than one instance of our SampleView:

```kotlin
@Preview
@Composable
fun SampleViewPreview() {
    Column {
        SampleView("Orange Juice", 50)
        SampleView("Mango Juice", 100)
    }
}
```

![A preview of outputting text on multiple lines in a single view with various colours](/content/blog/a-better-way-of-creating-android-views-with-jetpackcompose/preview3.png)

## Summary

JetPack Compose is easy to use and has great potential. You can use it to build modern, interactive, and dynamic UIs. You can even use it to build desktop UI for the apps (still alpha). The only downside is JetPack Compose is not stable yet (as of Jun 2021), but this will change soon, and it will most likely become a new standard for the Android UI. Learning JetPack compose requires a bit of mind shift, but with UI becoming more and more dynamic, this state drive approach will make every developer's life easier.

Links
- [JetPack Compose](https://developer.android.com/jetpack/compose)
- [Compose Samples](https://github.com/android/compose-samples)
- [JetBrains Compose Samples](https://www.jetbrains.com/lp/compose/)
