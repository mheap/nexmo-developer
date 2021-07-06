---
title: Objective-C
language: objective_c
menu_weight: 2
---

You can download the image using `URLSession`:

```objective_c
- (void)loadImageWithURLString:(NSString *)urlString
                         token:(NSString *)token
             completionHandler:(void (^_Nonnull)(UIImage * _Nullable image))completionHandler {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    if (url) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
        NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data && response) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
                    completionHandler([[UIImage alloc] initWithData:data]);
                }
            }
            completionHandler(nil);
        }];
        
        [task resume];
    }
}
```

When calling the above function make sure to update your `UIImageView` on the main thread:

```objective_c
[self loadImageWithURLString:@"IMAGE_URL" token:@"JWT" completionHandler:^(UIImage * _Nullable image) {
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
    }
}];
```
