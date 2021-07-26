---
title: Java
language: java
---

```java
// ==== LOAD IMAGE USING GLIDE ==== 
// https://github.com/bumptech/glide
private void loadImageUsingGlide(String url, String jwt, Context context) {
    LazyHeaders build = new LazyHeaders.Builder()
            .addHeader("Authorization", "bearer " + jwt)
            .build();

    GlideUrl glideUrl = new GlideUrl(url, build);

    Glide.with(context)
            .load(glideUrl)
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .into(imageView);
}

// ==== LOAD IMAGE USING PICASSO ====
// https://github.com/square/picasso

// Define custom Authentication interceptor
class AuthenticationInterceptor implements Interceptor {
    private String jwt;
    public AuthenticationInterceptor(String jwt) {
        this.jwt = jwt;
    }
    @NotNull
    @Override
    public Response intercept(@NotNull Chain chain) throws IOException {
        Request request = chain.request();

        Request newRequest = request.newBuilder()
                    .header("Authorization", "bearer " + jwt)
                    .build();

        return chain.proceed(newRequest);
    }
}

// Create Picasso instance that uses the Authenticator
private Picasso getPicassoInstance(String jwt) {
    OkHttpClient okHttpClient = new OkHttpClient.Builder()
            .addInterceptor(new AuthenticationInterceptor(jwt))
            .build();

    return new Picasso.Builder(requireContext())
            .downloader(new OkHttp3Downloader(okHttpClient))
            .build();
}

// Load image using custom picasso instance (that under the hood uses the authentication interceptor)
private void loadImageUsingPicasso(String url, String jwt, Context context) {
    getPicassoInstance(jwt)
            .load(url)
            .into(imageView);
}
```
