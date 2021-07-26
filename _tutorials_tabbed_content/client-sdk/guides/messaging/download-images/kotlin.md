---
title: Kotlin
language: kotlin
---

```kotlin
// ==== LOAD IMAGE USING COIL ==== 
// https://github.com/coil-kt/coil
private fun loadImageUsingCoil(url: String, jwt: String, context: Context) {
    imageView.load(
        Uri.parse(url),
        context.imageLoader,
    ) {
        addHeader("Authorization", "bearer $jwt")
    }
}

// ==== LOAD IMAGE USING GLIDE ==== 
// https://github.com/bumptech/glide
private fun loadImageUsingGlide(url: String, jwt: String, context: Context) {
    val build = LazyHeaders.Builder()
        .addHeader("Authorization", "bearer $jwt")
        .build()

    val glideUrl = GlideUrl(url, build)

    Glide.with(context)
        .load(glideUrl)
        .into(imageView)
}

// ==== LOAD IMAGE USING PICASSO ====
// https://github.com/square/picasso

// Define custom Authentication interceptor
class AuthenticationInterceptor(private val jwt: String) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response = chain.request().let {
        val newRequest = it.newBuilder()
            .header("Authorization", "bearer $jwt")
            .build()

        chain.proceed(newRequest)
    }
}

// Create Picasso instance that uses the Authenticator
private fun getPicassoInstance(jwt: String): Picasso {
    val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(AuthenticationInterceptor(jwt))
        .build()

    return Picasso.Builder(requireContext()).downloader(OkHttp3Downloader(okHttpClient)).build()
}

// Load image using custom picasso instance (that under the hood uses the authentication interceptor)
private fun loadImageUsingPicasso(url: String, jwt: String, context: Context) {
    getPicassoInstance(jwt)
        .load(url)
        .into(imageView)
}
```
